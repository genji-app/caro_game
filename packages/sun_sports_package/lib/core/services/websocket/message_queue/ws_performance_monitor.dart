/// WebSocket Performance Monitor
///
/// Tracks and logs WebSocket message processing metrics.
/// Used to understand message patterns and identify optimization opportunities.
///
/// Features:
/// - Periodic stats logging (every 30s in production)
/// - Debug mode for detailed per-message logging
/// - Tracks message counts by type
/// - Tracks duplicate messages by eventId
/// - Monitors queue depth and latency
/// - Warns when drop rate is high

import 'dart:async';
import 'dart:developer' as developer;

import '../websocket_messages.dart';
import 'ws_queued_message.dart';
import 'ws_message_queue.dart';

/// Performance monitor for WebSocket message queue
class WsPerformanceMonitor {
  /// Log interval for periodic stats
  final Duration logInterval;

  /// Whether debug mode is enabled (logs each message)
  bool debugMode;

  /// Reference to the queue for stats
  final WsMessageQueue? queue;

  // ===== INTERVAL STATS (reset each interval) =====
  int _receivedThisInterval = 0;
  int _processedThisInterval = 0;
  int _droppedThisInterval = 0;
  int _filteredThisInterval = 0;
  int _popupForwardsThisInterval = 0;

  /// Message counts by type this interval
  final Map<WsMessageType, int> _messagesByType = {};

  /// Message counts by eventId this interval (for duplicate detection)
  final Map<int, int> _messagesByEventId = {};

  /// Latencies recorded this interval (ms)
  final List<int> _latencies = [];

  // ===== SEQUENCE TRACKING =====
  /// Whether sequence tracking is enabled
  bool enableSequenceTracking = true;

  /// Current sequence being tracked (messages in order)
  final List<_SequenceEntry> _currentSequence = [];

  /// Time when sequence tracking started
  DateTime? _sequenceStartTime;

  /// Max sequence length before auto-flush (prevent memory issues)
  static const int _maxSequenceLength = 500;

  /// Sequence timeout - flush if no messages for this duration
  static const Duration _sequenceTimeout = Duration(seconds: 5);

  /// Peak messages received per second this interval
  int _peakRateThisInterval = 0;
  int _messagesThisSecond = 0;
  DateTime _currentSecond = DateTime.now();

  // ===== CUMULATIVE STATS (since start) =====
  int _totalReceived = 0;
  int _totalProcessed = 0;
  int _totalDropped = 0;
  int _totalFiltered = 0;
  int _totalPopupForwards = 0;

  /// Timer for periodic logging
  Timer? _logTimer;

  /// Start time for rate calculations
  DateTime _startTime = DateTime.now();

  /// Last log time
  DateTime _lastLogTime = DateTime.now();

  WsPerformanceMonitor({
    this.logInterval = const Duration(seconds: 30),
    this.debugMode = false,
    this.queue,
  });

  /// Start periodic logging
  void start() {
    _startTime = DateTime.now();
    _lastLogTime = DateTime.now();
    _logTimer?.cancel();
    _logTimer = Timer.periodic(logInterval, (_) => _logStats());
  }

  /// Stop periodic logging
  void stop() {
    _logTimer?.cancel();
    _logTimer = null;
  }

  /// Pause periodic logging (alias for stop)
  void pause() => stop();

  /// Resume periodic logging (alias for start)
  void resume() => start();

  /// Record a message received
  void onMessageReceived(WsQueuedMessage message) {
    _receivedThisInterval++;
    _totalReceived++;

    // Track by type
    final type = message.type;
    _messagesByType[type] = (_messagesByType[type] ?? 0) + 1;

    // Track by eventId (if available)
    final eventId = message.eventId;
    if (eventId != null) {
      _messagesByEventId[eventId] = (_messagesByEventId[eventId] ?? 0) + 1;
    }

    // Track peak rate
    _updatePeakRate();

    // Track sequence (for understanding message flow)
    if (enableSequenceTracking) {
      _trackSequence(message);
    }

    // Debug logging
    if (debugMode) {
      _logMessageReceived(message);
    }
  }

  /// Track message sequence for flow analysis
  void _trackSequence(WsQueuedMessage message) {
    final now = DateTime.now();

    // Check for sequence timeout - flush if no messages for a while
    if (_sequenceStartTime != null &&
        now.difference(
              _sequenceStartTime!.add(
                Duration(
                  milliseconds: _currentSequence.isNotEmpty
                      ? _currentSequence.last.timestamp
                      : 0,
                ),
              ),
            ) >
            _sequenceTimeout) {
      _flushSequence();
    }

    // Start new sequence on event_ins or league_ins
    if (message.type == WsMessageType.eventInsert ||
        message.type == WsMessageType.leagueInsert) {
      // Flush previous sequence if any
      if (_currentSequence.isNotEmpty) {
        _flushSequence();
      }
      // Start new sequence
      _sequenceStartTime = now;
    }

    // Only track if we have a sequence started
    if (_sequenceStartTime == null) return;

    // Add to sequence
    final entry = _SequenceEntry(
      type: message.type,
      eventId: message.eventId,
      marketId: message.marketId,
      timestamp: now.difference(_sequenceStartTime!).inMilliseconds,
    );
    _currentSequence.add(entry);

    // Auto-flush if sequence too long
    if (_currentSequence.length >= _maxSequenceLength) {
      _flushSequence();
    }
  }

  /// Flush and log current sequence
  void _flushSequence() {
    if (_currentSequence.isEmpty) return;

    final sequenceLog = _buildSequenceLog();
    developer.log(
      '\n[WsQueue SEQUENCE] Message flow (${_currentSequence.length} msgs):\n$sequenceLog',
      name: 'WsQueue',
    );

    _currentSequence.clear();
    _sequenceStartTime = null;
  }

  /// Build readable sequence log
  /// Format: event_ins:123(1) -> market_up:123(5) -> odds_up:123(10) -> ...
  String _buildSequenceLog() {
    if (_currentSequence.isEmpty) return 'empty';

    // Group consecutive same-type messages for readability
    final grouped = <_GroupedSequenceEntry>[];

    for (final entry in _currentSequence) {
      if (grouped.isEmpty ||
          grouped.last.type != entry.type ||
          grouped.last.eventId != entry.eventId) {
        // New group
        grouped.add(
          _GroupedSequenceEntry(
            type: entry.type,
            eventId: entry.eventId,
            count: 1,
            firstTimestamp: entry.timestamp,
            lastTimestamp: entry.timestamp,
          ),
        );
      } else {
        // Same type and eventId - increment count
        grouped.last.count++;
        grouped.last.lastTimestamp = entry.timestamp;
      }
    }

    // Build string
    final buffer = StringBuffer();
    var lineLength = 0;
    const maxLineLength = 100;

    for (var i = 0; i < grouped.length; i++) {
      final g = grouped[i];
      final typeName = _shortTypeName(g.type);
      final eventStr = g.eventId != null ? ':${g.eventId}' : '';
      final segment = '$typeName$eventStr(${g.count})';

      // Add arrow if not first
      final arrow = i > 0 ? ' -> ' : '';
      final toAdd = '$arrow$segment';

      // Check line length
      if (lineLength + toAdd.length > maxLineLength && lineLength > 0) {
        buffer.write('\n    ');
        lineLength = 4;
      }

      buffer.write(toAdd);
      lineLength += toAdd.length;
    }

    // Add summary
    final duration = _currentSequence.last.timestamp;
    buffer.write(
      '\n  [Total: ${_currentSequence.length} msgs in ${duration}ms]',
    );

    // Add type breakdown
    final typeCount = <WsMessageType, int>{};
    for (final entry in _currentSequence) {
      typeCount[entry.type] = (typeCount[entry.type] ?? 0) + 1;
    }
    final breakdown = typeCount.entries
        .map((e) => '${_shortTypeName(e.key)}=${e.value}')
        .join(', ');
    buffer.write('\n  [Breakdown: $breakdown]');

    return buffer.toString();
  }

  /// Force flush sequence (for manual trigger or testing)
  void flushSequenceNow() {
    _flushSequence();
  }

  /// Record a message dropped
  void onMessageDropped(WsQueuedMessage message) {
    _droppedThisInterval++;
    _totalDropped++;

    if (debugMode) {
      developer.log(
        '[WsQueue] DROP ${message.type.name} eventId=${message.eventId}',
        name: 'WsQueue',
      );
    }
  }

  /// Record messages processed
  void onBatchProcessed(List<WsQueuedMessage> messages) {
    _processedThisInterval += messages.length;
    _totalProcessed += messages.length;

    // Track latencies
    for (final message in messages) {
      final latency = message.ageMs;
      _latencies.add(latency);

      if (debugMode) {
        developer.log(
          '[WsQueue] PROC ${message.type.name} eventId=${message.eventId} latency=${latency}ms',
          name: 'WsQueue',
        );
      }
    }
  }

  /// Record messages filtered out
  void onMessagesFiltered(int count) {
    _filteredThisInterval += count;
    _totalFiltered += count;
  }

  /// Record popup forward
  void onPopupForward(WsQueuedMessage message) {
    _popupForwardsThisInterval++;
    _totalPopupForwards++;

    if (debugMode) {
      developer.log(
        '[WsQueue] POPUP_FWD ${message.type.name} eventId=${message.eventId}',
        name: 'WsQueue',
      );
    }
  }

  /// Update peak rate tracking
  void _updatePeakRate() {
    final now = DateTime.now();
    if (now.difference(_currentSecond).inSeconds >= 1) {
      // New second
      if (_messagesThisSecond > _peakRateThisInterval) {
        _peakRateThisInterval = _messagesThisSecond;
      }
      _messagesThisSecond = 1;
      _currentSecond = now;
    } else {
      _messagesThisSecond++;
    }
  }

  /// Log debug message for received message
  void _logMessageReceived(WsQueuedMessage message) {
    final eventId = message.eventId;
    final marketId = message.marketId;
    final sportId = message.sportId;

    // Check for potential duplicate
    final isDuplicate =
        eventId != null && (_messagesByEventId[eventId] ?? 0) > 1;
    final duplicateTag = isDuplicate ? ' (duplicate!)' : '';

    developer.log(
      '[WsQueue] RECV ${message.type.name} eventId=$eventId marketId=$marketId sportId=$sportId$duplicateTag',
      name: 'WsQueue',
    );
  }

  /// Log periodic stats
  void _logStats() {
    final intervalDuration = DateTime.now().difference(_lastLogTime);
    final intervalSeconds = intervalDuration.inMilliseconds / 1000.0;

    // Calculate rates
    final receivedRate = _receivedThisInterval / intervalSeconds;
    final processedRate = _processedThisInterval / intervalSeconds;

    // Calculate average latency
    final avgLatency = _latencies.isNotEmpty
        ? _latencies.reduce((a, b) => a + b) / _latencies.length
        : 0.0;

    // Count duplicates (events with >1 message)
    final duplicateEvents = _messagesByEventId.values
        .where((count) => count > 1)
        .length;
    final totalDuplicateMessages = _messagesByEventId.values
        .where((count) => count > 1)
        .fold<int>(0, (sum, count) => sum + count - 1);

    // Get queue depth
    final queueDepth = queue?.length ?? 0;
    final queueMax = queue?.maxSize ?? 9999;

    // Build type breakdown string
    final typeBreakdown = _buildTypeBreakdown();

    // Log main stats
    developer.log(
      '''
[WsQueue Stats - ${logInterval.inSeconds}s interval]
  Received: $_receivedThisInterval (${receivedRate.toStringAsFixed(1)}/s) | Processed: $_processedThisInterval (${processedRate.toStringAsFixed(1)}/s)
  Dropped: $_droppedThisInterval | Filtered: $_filteredThisInterval | Queue: $queueDepth/$queueMax | Popup Forwards: $_popupForwardsThisInterval
  By Type: $typeBreakdown
  Peak Rate: $_peakRateThisInterval msg/s | Avg Latency: ${avgLatency.toStringAsFixed(1)}ms
  Duplicates: $duplicateEvents events with ${totalDuplicateMessages} extra messages''',
      name: 'WsQueue',
    );

    // Warn if drop rate is high
    if (_droppedThisInterval > 100) {
      developer.log(
        '[WsQueue WARNING] High drop rate: $_droppedThisInterval messages dropped this interval!',
        name: 'WsQueue',
      );
    }

    // Warn if queue is filling up
    if (queueDepth > queueMax * 0.8) {
      developer.log(
        '[WsQueue WARNING] Queue near capacity: $queueDepth/$queueMax (${(queueDepth / queueMax * 100).toStringAsFixed(1)}%)',
        name: 'WsQueue',
      );
    }

    // Reset interval stats
    _resetIntervalStats();
    _lastLogTime = DateTime.now();
  }

  /// Build type breakdown string
  String _buildTypeBreakdown() {
    if (_messagesByType.isEmpty) return 'none';

    final sorted = _messagesByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(5) // Show top 5 types
        .map((e) => '${_shortTypeName(e.key)}=${e.value}')
        .join(', ');
  }

  /// Get short name for message type
  String _shortTypeName(WsMessageType type) {
    switch (type) {
      case WsMessageType.oddsUpdate:
        return 'odds_up';
      case WsMessageType.oddsInsert:
        return 'odds_ins';
      case WsMessageType.oddsRemove:
        return 'odds_rmv';
      case WsMessageType.eventStatus:
        return 'event_up';
      case WsMessageType.eventInsert:
        return 'event_ins';
      case WsMessageType.eventRemove:
        return 'event_rm';
      case WsMessageType.marketStatus:
        return 'market_up';
      case WsMessageType.leagueInsert:
        return 'league_ins';
      case WsMessageType.balanceUpdate:
        return 'balance';
      case WsMessageType.scoreUpdate:
        return 'score';
      case WsMessageType.connection:
        return 'conn';
      case WsMessageType.heartbeat:
        return 'hb';
      case WsMessageType.unknown:
        return 'unknown';
    }
  }

  /// Reset interval stats
  void _resetIntervalStats() {
    _receivedThisInterval = 0;
    _processedThisInterval = 0;
    _droppedThisInterval = 0;
    _filteredThisInterval = 0;
    _popupForwardsThisInterval = 0;
    _messagesByType.clear();
    _messagesByEventId.clear();
    _latencies.clear();
    _peakRateThisInterval = 0;
    _messagesThisSecond = 0;
  }

  /// Reset all stats
  void resetAllStats() {
    _resetIntervalStats();
    _totalReceived = 0;
    _totalProcessed = 0;
    _totalDropped = 0;
    _totalFiltered = 0;
    _totalPopupForwards = 0;
    _startTime = DateTime.now();

    // Clear sequence tracking
    _currentSequence.clear();
    _sequenceStartTime = null;
  }

  /// Get cumulative statistics
  WsPerformanceStats get stats {
    final runtime = DateTime.now().difference(_startTime);
    return WsPerformanceStats(
      totalReceived: _totalReceived,
      totalProcessed: _totalProcessed,
      totalDropped: _totalDropped,
      totalFiltered: _totalFiltered,
      totalPopupForwards: _totalPopupForwards,
      runtimeSeconds: runtime.inSeconds,
      avgReceiveRate: runtime.inSeconds > 0
          ? _totalReceived / runtime.inSeconds
          : 0,
    );
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}

/// Performance statistics snapshot
class WsPerformanceStats {
  final int totalReceived;
  final int totalProcessed;
  final int totalDropped;
  final int totalFiltered;
  final int totalPopupForwards;
  final int runtimeSeconds;
  final double avgReceiveRate;

  const WsPerformanceStats({
    required this.totalReceived,
    required this.totalProcessed,
    required this.totalDropped,
    required this.totalFiltered,
    required this.totalPopupForwards,
    required this.runtimeSeconds,
    required this.avgReceiveRate,
  });

  /// Drop rate (0.0 to 1.0)
  double get dropRate => totalReceived > 0 ? totalDropped / totalReceived : 0;

  /// Processing rate (0.0 to 1.0)
  double get processRate =>
      totalReceived > 0 ? totalProcessed / totalReceived : 0;

  @override
  String toString() {
    return 'PerformanceStats(received: $totalReceived, processed: $totalProcessed, '
        'dropped: $totalDropped (${(dropRate * 100).toStringAsFixed(1)}%), '
        'filtered: $totalFiltered, popupFwd: $totalPopupForwards, '
        'runtime: ${runtimeSeconds}s, avgRate: ${avgReceiveRate.toStringAsFixed(1)}/s)';
  }
}

/// Internal class for tracking individual sequence entries
class _SequenceEntry {
  final WsMessageType type;
  final int? eventId;
  final int? marketId;
  final int timestamp; // ms from sequence start

  const _SequenceEntry({
    required this.type,
    this.eventId,
    this.marketId,
    required this.timestamp,
  });
}

/// Internal class for grouped sequence entries (for logging)
class _GroupedSequenceEntry {
  final WsMessageType type;
  final int? eventId;
  int count;
  final int firstTimestamp;
  int lastTimestamp;

  _GroupedSequenceEntry({
    required this.type,
    this.eventId,
    required this.count,
    required this.firstTimestamp,
    required this.lastTimestamp,
  });
}
