import 'dart:async';

import 'key_extractor.dart';
import 'batch_parser.dart';
import 'priority_sorter.dart';
import 'pending_queue.dart';
import 'message_key.dart';
import '../utils/logger.dart';
import '../events/processor_metrics.dart';

/// Callback for processing parsed messages
typedef MessageCallback = void Function(ParsedMessage message);

/// Callback for batch processing completion
typedef BatchCallback = void Function(List<ParsedMessage> messages);

/// Main message processor coordinating the 3-layer pipeline.
///
/// Flow:
/// 1. Raw message arrives via onMessage()
/// 2. Layer 1: extractKeyFast() - O(1) key extraction
/// 3. Deduplication: _latestByKey[key] = ExtractedKey (overwrites old)
/// 4. Timer fires every sampleInterval
/// 5. Layer 2: Sort by TYPE (already extracted, no parsing needed)
/// 6. Layer 3: Batch parse JSON
/// 7. Apply to callbacks
class MessageProcessor {
  final KeyExtractor _keyExtractor;
  final BatchParser _batchParser;
  final PrioritySorter _prioritySorter;
  final PendingQueue _pendingQueue;
  final Logger _logger;

  /// Configuration
  final Duration _sampleInterval;
  final int _maxParsePerSample;

  /// Subscribed sports (empty = all)
  final Set<int> _subscribedSports = {};

  /// Primary sport ID for message routing.
  /// Only messages from primary sport will be processed to DataStore.
  /// If null, falls back to subscribed sports logic (backward compatibility).
  int? _primarySportId;

  /// Current sample's unique messages (deduplication)
  final Map<String, ExtractedKey> _latestByKey = {};

  /// Timers
  Timer? _sampleTimer;
  Timer? _cleanupTimer;
  Timer? _metricsTimer;

  /// Callbacks
  BatchCallback? onBatchProcessed;
  MessageCallback? onMessageProcessed;

  /// Metrics stream
  final StreamController<ProcessorMetrics> _metricsController =
      StreamController<ProcessorMetrics>.broadcast();

  Stream<ProcessorMetrics> get metricsStream => _metricsController.stream;

  /// Statistics for metrics
  int _receivedTotal = 0;
  int _processedTotal = 0;
  int _droppedTotal = 0;
  int _parseErrorsTotal = 0;
  final Map<String, int> _countByType = {};
  DateTime _statsStartTime = DateTime.now();

  /// Whether processor is running
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  MessageProcessor({
    Duration sampleInterval = const Duration(milliseconds: 200),
    int maxParsePerSample = 500,
    int maxPendingQueueSize = 5000,
    Duration pendingExpiration = const Duration(seconds: 10),
    Logger? logger,
  })  : _sampleInterval = sampleInterval,
        _maxParsePerSample = maxParsePerSample,
        _keyExtractor = KeyExtractor(),
        _batchParser = BatchParser(logger: logger),
        _prioritySorter = PrioritySorter(),
        _pendingQueue = PendingQueue(
          maxSize: maxPendingQueueSize,
          expirationTime: pendingExpiration,
        ),
        _logger = logger ?? const NoOpLogger();

  /// Start the processing loop
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _statsStartTime = DateTime.now();

    // Sample timer - process batch every interval
    _sampleTimer = Timer.periodic(_sampleInterval, (_) => _processSample());

    // Cleanup timer - remove expired pending messages
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cleanupPending(),
    );

    // Metrics timer - emit metrics
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _emitMetrics(),
    );

    _logger.info('MessageProcessor started');
  }

  /// Stop the processing loop
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;

    _sampleTimer?.cancel();
    _sampleTimer = null;

    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    _metricsTimer?.cancel();
    _metricsTimer = null;

    _logger.info('MessageProcessor stopped');
  }

  /// Subscribe to a sport
  void subscribeSport(int sportId) {
    _subscribedSports.add(sportId);
    _logger.info('✅ Subscribed to sport: $sportId → $_subscribedSports');
  }

  /// Unsubscribe from a sport
  void unsubscribeSport(int sportId) {
    _subscribedSports.remove(sportId);
    _logger.info('❌ Unsubscribed from sport: $sportId → $_subscribedSports');
  }

  /// Clear all subscriptions
  void clearSubscriptions() {
    _subscribedSports.clear();
    _logger.info('🗑️ Cleared all subscriptions → $_subscribedSports');
  }

  /// Get subscribed sports
  Set<int> get subscribedSports => Set.unmodifiable(_subscribedSports);

  /// Set primary sport for message routing.
  /// Only messages from primary sport will be processed to DataStore.
  void setPrimarySport(int sportId) {
    _primarySportId = sportId;
    _logger.info('🎯 Primary sport set to: $sportId');
  }

  /// Get primary sport ID (null if not set)
  int? get primarySportId => _primarySportId;

  /// Handle incoming raw message from WebSocket
  void onMessage(String raw) {
    _receivedTotal++;

    // DEBUG: Log every 10th message to see if receiving
    if (_receivedTotal % 10 == 1) {
      _logger.debug(
        '📩 WS MSG #$_receivedTotal: ${raw.length > 80 ? '${raw.substring(0, 80)}...' : raw}',
      );
      _logger.debug('   └─ subscribedSports: $_subscribedSports');
    }

    // Layer 1: Fast key extraction
    final key = _keyExtractor.extract(raw);
    if (key == null) {
      _droppedTotal++;
      _logger.debug('⏭️ Dropped - key extraction failed');
      return;
    }

    // Filter by subscribed sports
    if (!_shouldProcess(key)) {
      _logger.debug(
        '⏭️ Filtered - sportId: ${key.sportId}, subscribed: $_subscribedSports',
      );
      return;
    }

    // Count by type
    _countByType[key.type] = (_countByType[key.type] ?? 0) + 1;

    // Deduplication - newer message overwrites older
    _latestByKey[key.key] = key;

    // If buffer is getting too large, trigger immediate processing
    if (_latestByKey.length >= _maxParsePerSample * 2) {
      _processSample();
    }
  }

  /// Check if message should be processed based on sport subscription.
  ///
  /// Routing logic:
  /// - balance_up, user_bal: ALWAYS process (no sportId)
  /// - odds_up, odds_ins, score_up, event_up: Process for ALL subscribed sports
  ///   (needed for bet slip updates when viewing different sport)
  /// - Other messages: Only process primary sport (to keep DataStore focused)
  bool _shouldProcess(ExtractedKey key) {
    // Global messages (no sportId) - always process
    if (key.type == 'balance_up' || key.type == 'user_bal') return true;

    // If sportId not extracted, process (safety)
    if (key.sportId == null) return true;

    // Check if sport is subscribed
    final isSubscribed =
        _subscribedSports.isEmpty || _subscribedSports.contains(key.sportId);

    // CRITICAL: odds_up, odds_ins, score_up, event_up should be processed
    // for ALL subscribed sports, not just primary.
    // This is needed for bet slip to receive updates when user views different sport.
    if (key.type == 'odds_up' ||
        key.type == 'odds_ins' ||
        key.type == 'score_up' ||
        key.type == 'event_up') {
      return isSubscribed;
    }

    // For other message types (league_ins, event_ins, market_up, etc.):
    // Only process primary sport to keep DataStore focused on current view
    if (_primarySportId != null) {
      return key.sportId == _primarySportId;
    }

    // Fallback: subscribed sports logic (backward compatibility)
    return isSubscribed;
  }

  /// Process current sample (called by timer)
  void _processSample() {
    if (_latestByKey.isEmpty) return;

    final stopwatch = Stopwatch()..start();

    // Take current sample and reset
    final keys = _latestByKey.values.toList();
    _latestByKey.clear();

    // Limit batch size
    final batchKeys = keys.length > _maxParsePerSample
        ? keys.sublist(0, _maxParsePerSample)
        : keys;

    // If we had to limit, put overflow back
    if (keys.length > _maxParsePerSample) {
      for (var i = _maxParsePerSample; i < keys.length; i++) {
        _latestByKey[keys[i].key] = keys[i];
      }
      _droppedTotal += keys.length - _maxParsePerSample;
    }

    // Layer 2: Sort by priority
    _prioritySorter.sortInPlace(batchKeys);

    // DEBUG: Print batch input types and IDs before parsing
    _debugPrintBatchInput(batchKeys);

    // Layer 3: Batch parse JSON (with odds expansion)
    final messages = _batchParser.parseWithOddsExpansion(batchKeys);

    _processedTotal += messages.length;
    _parseErrorsTotal += batchKeys.length - messages.length;

    stopwatch.stop();

    // DEBUG: Print parsed output types and IDs
    _debugPrintParsedOutput(messages);

    // Notify callbacks
    if (messages.isNotEmpty) {
      onBatchProcessed?.call(messages);

      if (onMessageProcessed != null) {
        for (final msg in messages) {
          onMessageProcessed!(msg);
        }
      }
    }

    // DEBUG: Print pending queue status after batch
    _debugPrintPendingQueue();

    _logger.debug(
      'Processed batch: ${messages.length} messages in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  /// Cleanup expired pending messages
  void _cleanupPending() {
    final removed = _pendingQueue.cleanupExpired();
    if (removed > 0) {
      _logger.debug('Cleaned up $removed expired pending messages');
    }
  }

  /// Emit current metrics
  void _emitMetrics() {
    final now = DateTime.now();
    final duration = now.difference(_statsStartTime);
    final seconds = duration.inSeconds > 0 ? duration.inSeconds : 1;

    final metrics = ProcessorMetrics(
      receivedTotal: _receivedTotal,
      receivedPerSecond: _receivedTotal ~/ seconds,
      processedTotal: _processedTotal,
      processedPerSecond: _processedTotal ~/ seconds,
      droppedTotal: _droppedTotal,
      parseErrorsTotal: _parseErrorsTotal,
      pendingQueueSize: _pendingQueue.length,
      pendingQueueDropped: _pendingQueue.droppedCount,
      pendingQueueExpired: _pendingQueue.expiredCount,
      bufferSize: _latestByKey.length,
      dedupRatio: _receivedTotal > 0
          ? ((_receivedTotal - _processedTotal) / _receivedTotal * 100)
          : 0.0,
      byMessageType: Map.from(_countByType),
      timestamp: now,
    );

    _metricsController.add(metrics);
  }

  /// Get current metrics snapshot
  ProcessorMetrics getMetrics() {
    final now = DateTime.now();
    final duration = now.difference(_statsStartTime);
    final seconds = duration.inSeconds > 0 ? duration.inSeconds : 1;

    return ProcessorMetrics(
      receivedTotal: _receivedTotal,
      receivedPerSecond: _receivedTotal ~/ seconds,
      processedTotal: _processedTotal,
      processedPerSecond: _processedTotal ~/ seconds,
      droppedTotal: _droppedTotal,
      parseErrorsTotal: _parseErrorsTotal,
      pendingQueueSize: _pendingQueue.length,
      pendingQueueDropped: _pendingQueue.droppedCount,
      pendingQueueExpired: _pendingQueue.expiredCount,
      bufferSize: _latestByKey.length,
      dedupRatio: _receivedTotal > 0
          ? ((_receivedTotal - _processedTotal) / _receivedTotal * 100)
          : 0.0,
      byMessageType: Map.from(_countByType),
      timestamp: now,
    );
  }

  /// Reset statistics
  void resetStats() {
    _receivedTotal = 0;
    _processedTotal = 0;
    _droppedTotal = 0;
    _parseErrorsTotal = 0;
    _countByType.clear();
    _statsStartTime = DateTime.now();
    _pendingQueue.resetStats();
  }

  /// Access to pending queue for data updater
  PendingQueue get pendingQueue => _pendingQueue;

  // ============ DEBUG METHODS ============

  /// Debug print batch input - types and IDs before parsing
  void _debugPrintBatchInput(List<ExtractedKey> batchKeys) {
    if (batchKeys.isEmpty) return;

    final typeGroups = <String, List<String>>{};

    for (final key in batchKeys) {
      final ids = <String>[];
      if (key.leagueId != null) ids.add('L:${key.leagueId}');
      if (key.eventId != null) ids.add('E:${key.eventId}');
      if (key.marketId != null) ids.add('M:${key.marketId}');
      if (key.isBatch) ids.add('BATCH');

      final idStr = ids.isNotEmpty ? ids.join(',') : key.key;
      typeGroups.putIfAbsent(key.type, () => []).add(idStr);
    }

    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln('╔══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ 📥 BATCH INPUT (before parsing) - ${batchKeys.length} messages');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');

    // for (final entry in typeGroups.entries) {
    //   buffer.writeln('║ 📌 ${entry.key}: ${entry.value.length} items');
    //   // Show first 10 IDs
    //   final displayIds = entry.value.take(10).join(', ');
    //   buffer.writeln('║    IDs: [$displayIds${entry.value.length > 10 ? ", ... +${entry.value.length - 10} more" : ""}]');
    // }

    // buffer.writeln('╚══════════════════════════════════════════════════════════════');
    // // ignore: avoid_print
    // print(buffer.toString());
  }

  /// Debug print parsed output - types and IDs after parsing
  void _debugPrintParsedOutput(List<ParsedMessage> messages) {
    if (messages.isEmpty) return;

    final typeGroups = <String, List<String>>{};

    for (final msg in messages) {
      final ids = <String>[];

      // Extract IDs from parsed data
      final leagueId = msg.getInt('leagueId') ?? msg.getInt('li');
      final eventId = msg.getInt('eventId') ?? msg.getInt('ei');
      final marketId = msg.getInt('marketId') ?? msg.getInt('mi');
      final offerId = msg.getString('strOfferId') ?? msg.getString('offerId');

      if (leagueId != null) ids.add('L:$leagueId');
      if (eventId != null) ids.add('E:$eventId');
      if (marketId != null) ids.add('M:$marketId');
      if (offerId != null) ids.add('O:$offerId');

      final idStr = ids.isNotEmpty ? ids.join(',') : 'no-id';
      typeGroups.putIfAbsent(msg.type, () => []).add(idStr);
    }

    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln('╔══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ 📤 STREAM OUTPUT (after parsing) - ${messages.length} messages');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');

    // for (final entry in typeGroups.entries) {
    //   buffer.writeln('║ ✅ ${entry.key}: ${entry.value.length} items');
    //   // Show first 10 IDs
    //   final displayIds = entry.value.take(10).join(', ');
    //   buffer.writeln('║    IDs: [$displayIds${entry.value.length > 10 ? ", ... +${entry.value.length - 10} more" : ""}]');
    // }

    // buffer.writeln('╚══════════════════════════════════════════════════════════════');
    // // ignore: avoid_print
    // print(buffer.toString());
  }

  /// Debug print pending queue status
  void _debugPrintPendingQueue() {
    final pending = _pendingQueue;
    if (pending.isEmpty) return;

    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln('╔══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ ⏳ PENDING QUEUE - ${pending.length} items waiting');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ Parents waiting: ${pending.parentCount}');
    // buffer.writeln('║ Dropped: ${pending.droppedCount} | Expired: ${pending.expiredCount}');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');

    // Group by parent ID and show details
    // var parentShown = 0;
    // for (final parentId in pending.pendingParentIds) {
    //   if (parentShown >= 5) {
    //     buffer.writeln('║ ... +${pending.parentCount - 5} more parents');
    //     break;
    //   }

    //   final items = pending.peekForParent(parentId);
    //   final typeCount = <String, int>{};
    //   for (final item in items) {
    //     typeCount[item.type] = (typeCount[item.type] ?? 0) + 1;
    //   }

    //   buffer.writeln('║ 🔑 ParentID: $parentId (${items.length} items)');
    //   for (final tc in typeCount.entries) {
    //     buffer.writeln('║    - ${tc.key}: ${tc.value}');
    //   }
    //   parentShown++;
    // }

    // buffer.writeln('╚══════════════════════════════════════════════════════════════');
    // // ignore: avoid_print
    // print(buffer.toString());
  }

  /// Dispose resources
  void dispose() {
    stop();
    _latestByKey.clear();
    _pendingQueue.clear();
    _metricsController.close();
  }
}
