import 'dart:async';

import '../client/reconciliation_service.dart';
import '../processor/message_processor.dart';
import '../processor/message_key.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';
import 'i_sport_api_service.dart';

/// Trigger types for auto refresh.
enum AutoRefreshTrigger {
  /// Initial data fetch on first connect
  initial,

  /// Periodic timer trigger
  timer,

  /// Pending queue exceeded threshold
  pendingThreshold,

  /// After WebSocket reconnection
  reconnection,

  /// Manual user action
  manual;

  /// Human-readable description for logging
  String get description {
    switch (this) {
      case AutoRefreshTrigger.initial:
        return '🚀 INITIAL (first connect)';
      case AutoRefreshTrigger.timer:
        return '⏱️ TIMER (periodic refresh)';
      case AutoRefreshTrigger.pendingThreshold:
        return '⚠️ PENDING_THRESHOLD (queue overflow)';
      case AutoRefreshTrigger.reconnection:
        return '🔄 RECONNECTION (socket reconnected)';
      case AutoRefreshTrigger.manual:
        return '👆 MANUAL (user action)';
    }
  }
}

/// Result of an auto refresh operation.
class AutoRefreshResult {
  /// What triggered this refresh
  final AutoRefreshTrigger trigger;

  /// Whether the refresh succeeded
  final bool success;

  /// How long the refresh took
  final Duration duration;

  /// Number of leagues added
  final int addedLeagues;

  /// Number of leagues updated
  final int updatedLeagues;

  /// Number of leagues removed
  final int removedLeagues;

  /// Number of pending messages flushed
  final int flushedPending;

  /// Error message if failed
  final String? errorMessage;

  /// When this refresh occurred
  final DateTime timestamp;

  const AutoRefreshResult({
    required this.trigger,
    required this.success,
    required this.duration,
    this.addedLeagues = 0,
    this.updatedLeagues = 0,
    this.removedLeagues = 0,
    this.flushedPending = 0,
    this.errorMessage,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AutoRefreshResult(trigger: $trigger, success: $success, '
        'duration: ${duration.inMilliseconds}ms, '
        'leagues: +$addedLeagues/~$updatedLeagues/-$removedLeagues, '
        'flushed: $flushedPending)';
  }
}

/// Configuration for auto refresh.
class AutoRefreshConfig {
  /// How often to refresh LIVE tab (timer interval)
  final Duration refreshInterval;

  /// Refresh interval for TODAY tab
  final Duration todayRefreshInterval;

  /// Refresh interval for EARLY tab
  final Duration earlyRefreshInterval;

  /// Pending queue threshold to trigger refresh
  final int pendingQueueThreshold;

  /// Whether auto refresh is enabled
  final bool enabled;

  /// Minimum gap between refreshes
  final Duration minRefreshGap;

  /// Maximum retry attempts
  final int maxRetries;

  /// Base delay for exponential backoff
  final Duration retryDelay;

  const AutoRefreshConfig({
    this.refreshInterval = const Duration(seconds: 30),
    this.todayRefreshInterval = const Duration(seconds: 60),
    this.earlyRefreshInterval = const Duration(seconds: 120),
    this.pendingQueueThreshold = 300,
    this.enabled = true,
    this.minRefreshGap = const Duration(seconds: 5),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  /// Get refresh interval for specific time range
  Duration getIntervalForTimeRange(String timeRange) {
    switch (timeRange) {
      case TimeRange.live:
        return refreshInterval; // 30s
      case TimeRange.today:
        return todayRefreshInterval; // 60s
      case TimeRange.early:
        return earlyRefreshInterval; // 120s
      default:
        return refreshInterval;
    }
  }

  /// Live mode - faster refresh, lower threshold
  factory AutoRefreshConfig.live() => const AutoRefreshConfig(
        refreshInterval: Duration(seconds: 30),
        todayRefreshInterval: Duration(seconds: 60),
        earlyRefreshInterval: Duration(seconds: 120),
        pendingQueueThreshold: 300,
        maxRetries: 3,
      );

  /// Pre-match mode - slower refresh, higher threshold
  factory AutoRefreshConfig.preMatch() => const AutoRefreshConfig(
        refreshInterval: Duration(seconds: 60),
        todayRefreshInterval: Duration(seconds: 90),
        earlyRefreshInterval: Duration(seconds: 180),
        pendingQueueThreshold: 500,
        maxRetries: 3,
      );

  /// Disabled config
  factory AutoRefreshConfig.disabled() => const AutoRefreshConfig(
        enabled: false,
      );

  AutoRefreshConfig copyWith({
    Duration? refreshInterval,
    Duration? todayRefreshInterval,
    Duration? earlyRefreshInterval,
    int? pendingQueueThreshold,
    bool? enabled,
    Duration? minRefreshGap,
    int? maxRetries,
    Duration? retryDelay,
  }) {
    return AutoRefreshConfig(
      refreshInterval: refreshInterval ?? this.refreshInterval,
      todayRefreshInterval: todayRefreshInterval ?? this.todayRefreshInterval,
      earlyRefreshInterval: earlyRefreshInterval ?? this.earlyRefreshInterval,
      pendingQueueThreshold:
          pendingQueueThreshold ?? this.pendingQueueThreshold,
      enabled: enabled ?? this.enabled,
      minRefreshGap: minRefreshGap ?? this.minRefreshGap,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }
}

/// Manager for automatic data refresh from API.
///
/// Handles:
/// - Periodic timer-based refresh
/// - Pending queue threshold trigger
/// - Reconnection refresh
/// - Manual refresh
///
/// Refresh behavior by trigger:
/// - Timer/Manual: Refresh based on current TimeRange (LIVE/TODAY/EARLY)
/// - Reconnection/Threshold: FULL (Early + Live) to ensure data completeness
///
/// TimeRange intervals:
/// - LIVE: 30s (default)
/// - TODAY: 60s
/// - EARLY: 120s
class AutoRefreshManager {
  // ===== Dependencies =====
  final ISportApiService _apiService;
  final ReconciliationService _reconciliationService;
  final MessageProcessor _messageProcessor;
  final AutoRefreshConfig _config;
  final Logger _logger;

  // ===== State =====
  int _currentSportId;
  String _currentTimeRange;
  Timer? _timer;
  DateTime? _lastRefreshTime;
  DateTime? _timerStartTime;
  int _tickCount = 0;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  final StreamController<AutoRefreshResult> _resultController =
      StreamController<AutoRefreshResult>.broadcast();

  // ===== Constructor =====
  AutoRefreshManager({
    required ISportApiService apiService,
    required ReconciliationService reconciliationService,
    required MessageProcessor messageProcessor,
    required AutoRefreshConfig config,
    required int initialSportId,
    String initialTimeRange = TimeRange.live,
    Logger? logger,
  })  : _apiService = apiService,
        _reconciliationService = reconciliationService,
        _messageProcessor = messageProcessor,
        _config = config,
        _currentSportId = initialSportId,
        _currentTimeRange = initialTimeRange,
        _logger = logger ?? const NoOpLogger();

  // ===== Public API =====

  /// Stream of refresh results
  Stream<AutoRefreshResult> get onRefresh => _resultController.stream;

  /// Current sport ID
  int get currentSportId => _currentSportId;

  /// Current time range (LIVE/TODAY/EARLY)
  String get currentTimeRange => _currentTimeRange;

  /// Whether currently refreshing
  bool get isRefreshing => _isRefreshing;

  /// Whether manager is running
  bool get isRunning => _timer != null;

  /// Update time range (when user switches tab).
  ///
  /// This will restart timer with appropriate interval:
  /// - LIVE: 30s
  /// - TODAY: 60s
  /// - EARLY: 120s
  void updateTimeRange(String timeRange) {
    if (_currentTimeRange == timeRange) {
      _logger.debug('[AutoRefresh] TimeRange unchanged: $timeRange');
      return;
    }

    final oldInterval = _config.getIntervalForTimeRange(_currentTimeRange);
    final newInterval = _config.getIntervalForTimeRange(timeRange);

    _logger.info(
      '[AutoRefresh] TimeRange changed: $_currentTimeRange → $timeRange\n'
      '   └─ interval: ${oldInterval.inSeconds}s → ${newInterval.inSeconds}s',
    );

    _currentTimeRange = timeRange;

    // Restart timer with new interval if running
    if (isRunning) {
      _restartTimer();
    }
  }

  /// Restart timer with current timeRange's interval
  void _restartTimer() {
    _timer?.cancel();
    _tickCount = 0;
    _timerStartTime = DateTime.now();

    final interval = _config.getIntervalForTimeRange(_currentTimeRange);

    _timer = Timer.periodic(interval, (_) {
      _tickCount++;
      // ignore: avoid_print
      print(
          '[AutoRefresh] ⏱️ Timer tick #$_tickCount ($_currentTimeRange) at ${DateTime.now()} - triggering refresh...');
      _logger.info(
          '[AutoRefresh] ⏱️ Timer tick #$_tickCount - refreshing $_currentTimeRange...');
      triggerRefresh(AutoRefreshTrigger.timer);
    });

    _logger.info(
      '[AutoRefresh] ✅ TIMER RESTARTED\n'
      '   └─ timeRange: $_currentTimeRange\n'
      '   └─ interval: ${interval.inSeconds}s',
    );
  }

  /// Start the auto refresh timer
  void start() {
    _logger.info('[AutoRefresh] start() called - checking config...');
    _logger.info('[AutoRefresh]   enabled: ${_config.enabled}');
    _logger.info('[AutoRefresh]   isDisposed: $_isDisposed');
    _logger.info('[AutoRefresh]   timeRange: $_currentTimeRange');

    if (!_config.enabled) {
      _logger
          .warning('[AutoRefresh] ⏭️ NOT STARTING - config.enabled is FALSE');
      return;
    }

    if (_isDisposed) {
      _logger.warning('[AutoRefresh] ⏭️ NOT STARTING - manager is DISPOSED');
      return;
    }

    _timer?.cancel();
    _timerStartTime = DateTime.now();
    _tickCount = 0;

    final interval = _config.getIntervalForTimeRange(_currentTimeRange);

    _timer = Timer.periodic(interval, (_) {
      _tickCount++;
      // Use print() instead of debugPrint to avoid Flutter web buffering
      // ignore: avoid_print
      print(
          '[AutoRefresh] ⏱️ Timer tick #$_tickCount ($_currentTimeRange) at ${DateTime.now()} - triggering refresh...');
      _logger.info(
          '[AutoRefresh] ⏱️ Timer tick #$_tickCount - refreshing $_currentTimeRange...');
      triggerRefresh(AutoRefreshTrigger.timer);
    });

    _logger.info(
      '[AutoRefresh] ✅ TIMER STARTED\n'
      '   └─ timeRange: $_currentTimeRange\n'
      '   └─ interval: ${interval.inSeconds}s\n'
      '   └─ threshold: ${_config.pendingQueueThreshold}\n'
      '   └─ next tick in: ${interval.inSeconds}s',
    );
  }

  /// Stop the auto refresh timer
  void stop() {
    final wasRunning = _timer != null;
    _timer?.cancel();
    _timer = null;
    _logger.info('[AutoRefresh] ⏹️ STOPPED (was running: $wasRunning)');
  }

  /// Get diagnostic info for debugging
  Map<String, dynamic> getDiagnostics() {
    // Calculate seconds until next tick based on current timeRange interval
    int? secondsUntilNextTick;
    final currentInterval = _config.getIntervalForTimeRange(_currentTimeRange);
    if (_timerStartTime != null && isRunning) {
      final elapsed = DateTime.now().difference(_timerStartTime!);
      final intervalSeconds = currentInterval.inSeconds;
      final nextTickAt = ((_tickCount + 1) * intervalSeconds);
      secondsUntilNextTick = nextTickAt - elapsed.inSeconds;
      if (secondsUntilNextTick < 0) secondsUntilNextTick = 0;
    }

    return {
      'isRunning': isRunning,
      'isRefreshing': _isRefreshing,
      'isDisposed': _isDisposed,
      'currentSportId': _currentSportId,
      'currentTimeRange': _currentTimeRange,
      'tickCount': _tickCount,
      'secondsUntilNextTick': secondsUntilNextTick,
      'timerStartTime': _timerStartTime?.toIso8601String(),
      'lastRefreshTime': _lastRefreshTime?.toIso8601String(),
      'config': {
        'enabled': _config.enabled,
        'refreshInterval': _config.refreshInterval.inSeconds,
        'todayRefreshInterval': _config.todayRefreshInterval.inSeconds,
        'earlyRefreshInterval': _config.earlyRefreshInterval.inSeconds,
        'currentInterval': currentInterval.inSeconds,
        'pendingQueueThreshold': _config.pendingQueueThreshold,
        'minRefreshGap': _config.minRefreshGap.inSeconds,
        'maxRetries': _config.maxRetries,
      },
    };
  }

  /// Log current status
  void logStatus() {
    final diag = getDiagnostics();
    // ignore: avoid_print
    print(
      '[AutoRefresh] 📊 STATUS\n'
      '   └─ isRunning: ${diag['isRunning']}\n'
      '   └─ isRefreshing: ${diag['isRefreshing']}\n'
      '   └─ timeRange: ${diag['currentTimeRange']}\n'
      '   └─ tickCount: ${diag['tickCount']}\n'
      '   └─ nextTickIn: ${diag['secondsUntilNextTick'] ?? 'N/A'}s\n'
      '   └─ sportId: ${diag['currentSportId']}\n'
      '   └─ lastRefresh: ${diag['lastRefreshTime'] ?? 'never'}\n'
      '   └─ config.enabled: ${diag['config']['enabled']}\n'
      '   └─ config.interval: ${diag['config']['currentInterval']}s',
    );
  }

  /// Update sport ID (called when changeSport)
  void updateSportId(int sportId) {
    _currentSportId = sportId;
    _logger.debug('AutoRefreshManager sportId updated to $sportId');
  }

  /// Trigger a refresh with the specified trigger type.
  ///
  /// Returns the result of the refresh operation.
  Future<AutoRefreshResult?> triggerRefresh(AutoRefreshTrigger trigger) async {
    // Check if already refreshing
    if (_isRefreshing) {
      _logger.debug('Refresh already in progress, skipping');
      return null;
    }

    // Check minRefreshGap
    if (_lastRefreshTime != null) {
      final elapsed = DateTime.now().difference(_lastRefreshTime!);
      if (elapsed < _config.minRefreshGap) {
        _logger.debug(
          'Skipping refresh, min gap not met: ${elapsed.inSeconds}s < ${_config.minRefreshGap.inSeconds}s',
        );
        return null;
      }
    }

    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();

    try {
      final result = await _refreshWithRetry(trigger);
      if (!_isDisposed) {
        _resultController.add(result);
      }
      return result;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Check if pending queue exceeds threshold
  bool checkPendingThreshold() {
    final queueSize = _messageProcessor.pendingQueue.length;
    return queueSize >= _config.pendingQueueThreshold;
  }

  /// Dispose resources
  void dispose() {
    _isDisposed = true;
    stop();
    _resultController.close();
  }

  // ===== Internal Methods =====

  /// Refresh with retry mechanism
  Future<AutoRefreshResult> _refreshWithRetry(
      AutoRefreshTrigger trigger) async {
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < _config.maxRetries; i++) {
      try {
        final result = await _executeRefresh(trigger, stopwatch);
        return result;
      } catch (e, stack) {
        _logger.warning('Refresh attempt ${i + 1} failed: $e');
        _logger.debug('Stack trace: $stack');

        if (i < _config.maxRetries - 1) {
          // Exponential backoff
          final delay = _config.retryDelay * (i + 1);
          await Future<void>.delayed(delay);
        }
      }
    }

    // All retries failed
    stopwatch.stop();
    _logger.error('Refresh failed after ${_config.maxRetries} retries');

    return AutoRefreshResult(
      trigger: trigger,
      success: false,
      duration: stopwatch.elapsed,
      errorMessage: 'Failed after ${_config.maxRetries} retries',
      timestamp: DateTime.now(),
    );
  }

  /// Execute refresh based on trigger type
  Future<AutoRefreshResult> _executeRefresh(
    AutoRefreshTrigger trigger,
    Stopwatch stopwatch,
  ) async {
    _logger.info(
        '[AutoRefresh] ${trigger.description} - sportId=$_currentSportId, timeRange=$_currentTimeRange');

    switch (trigger) {
      case AutoRefreshTrigger.timer:
      case AutoRefreshTrigger.manual:
        // Refresh based on current TimeRange
        return _refreshCurrentTab(trigger, stopwatch);

      case AutoRefreshTrigger.initial:
      case AutoRefreshTrigger.reconnection:
      case AutoRefreshTrigger.pendingThreshold:
        // FULL refresh - ensure data completeness
        return _refreshFull(trigger, stopwatch);
    }
  }

  /// Refresh current tab based on _currentTimeRange
  ///
  /// Calls the appropriate API method:
  /// - LIVE: fetchLiveAndPopulate (30s interval)
  /// - TODAY: fetchTodayAndPopulate (60s interval)
  /// - EARLY: fetchEarlyAndPopulate (120s interval)
  Future<AutoRefreshResult> _refreshCurrentTab(
    AutoRefreshTrigger trigger,
    Stopwatch stopwatch,
  ) async {
    _logger.info(
        '[AutoRefresh] Fetching $_currentTimeRange & POPULATE (full hierarchy)...');

    final store = _reconciliationService.store;
    final leaguesBefore = store.getLeaguesBySport(_currentSportId).length;
    int eventsBefore = 0;
    for (final league in store.getLeaguesBySport(_currentSportId)) {
      eventsBefore += store.getEventsByLeague(league.leagueId).length;
    }

    // ⭐ KEY CHANGE: Fetch based on current time range
    switch (_currentTimeRange) {
      case TimeRange.live:
        await _apiService.fetchLiveAndPopulate(
          sportId: _currentSportId,
          store: store,
        );
        break;
      case TimeRange.today:
        await _apiService.fetchTodayAndPopulate(
          sportId: _currentSportId,
          store: store,
        );
        break;
      case TimeRange.early:
        await _apiService.fetchEarlyAndPopulate(
          sportId: _currentSportId,
          store: store,
        );
        break;
      default:
        // Fallback to LIVE
        await _apiService.fetchLiveAndPopulate(
          sportId: _currentSportId,
          store: store,
        );
    }

    // Calculate changes
    final leaguesAfter = store.getLeaguesBySport(_currentSportId).length;
    int eventsAfter = 0;
    for (final league in store.getLeaguesBySport(_currentSportId)) {
      eventsAfter += store.getEventsByLeague(league.leagueId).length;
    }

    // Cleanup pending queue after refresh
    final cleanedCount = _cleanupPendingQueue();

    stopwatch.stop();

    _logger.info(
      '[AutoRefresh] ✅ $_currentTimeRange REFRESH DONE - ${trigger.description}\n'
      '   └─ leagues: $leaguesBefore → $leaguesAfter\n'
      '   └─ events: $eventsBefore → $eventsAfter\n'
      '   └─ cleaned: $cleanedCount pending\n'
      '   └─ duration: ${stopwatch.elapsedMilliseconds}ms',
    );

    return AutoRefreshResult(
      trigger: trigger,
      success: true,
      duration: stopwatch.elapsed,
      addedLeagues: leaguesAfter - leaguesBefore,
      updatedLeagues: leaguesAfter,
      removedLeagues: 0,
      flushedPending: cleanedCount,
      timestamp: DateTime.now(),
    );
  }

  /// Full refresh with Early + Live data
  Future<AutoRefreshResult> _refreshFull(
    AutoRefreshTrigger trigger,
    Stopwatch stopwatch,
  ) async {
    _logger.info('[AutoRefresh] Fetching FULL (EARLY + LIVE) parallel...');

    // Parallel fetch Early + Live - API already returns Library LeagueData
    final results = await Future.wait([
      _apiService.fetchEarlyLeagues(sportId: _currentSportId),
      _apiService.fetchLiveLeagues(sportId: _currentSportId),
    ]);

    final earlyLeagues = results[0];
    final liveLeagues = results[1];

    // Combine all leagues
    final allLeagues = [...earlyLeagues, ...liveLeagues];

    _logger.info(
        '[AutoRefresh] API fetched - early: ${earlyLeagues.length}, live: ${liveLeagues.length}');

    // Use fullSync (atomic operation) - no UI flicker
    final result = _reconciliationService.fullSync(
      sportId: _currentSportId,
      apiLeagues: allLeagues,
    );

    // Cleanup pending queue after full data is loaded
    final flushedCount = _cleanupPendingQueue();

    stopwatch.stop();

    _logger.info(
      '[AutoRefresh] ✅ FULL REFRESH DONE - ${trigger.description}\n'
      '   └─ leagues: +${result.addedLeagues.length}/~${result.updatedLeagues.length}/-${result.removedLeagues.length}\n'
      '   └─ pending flushed: $flushedCount\n'
      '   └─ duration: ${stopwatch.elapsedMilliseconds}ms',
    );

    return AutoRefreshResult(
      trigger: trigger,
      success: true,
      duration: stopwatch.elapsed,
      addedLeagues: result.addedLeagues.length,
      flushedPending: flushedCount,
      timestamp: DateTime.now(),
    );
  }

  /// Cleanup pending queue after refresh.
  ///
  /// This method:
  /// 1. Flushes messages where parent EXISTS in store → Reprocess them
  /// 2. Removes orphan messages where parent DOESN'T exist → Cleanup
  ///
  /// Returns count of messages that were successfully reprocessed.
  int _cleanupPendingQueue() {
    final pendingQueue = _messageProcessor.pendingQueue;
    final store = _reconciliationService.store;

    if (pendingQueue.isEmpty) {
      _logger.debug('[AutoRefresh] 🧹 Pending queue empty, nothing to cleanup');
      return 0;
    }

    final storeEventIds = store.allEventIds.toSet();
    final pendingBefore = pendingQueue.length;
    final parentsBefore = pendingQueue.parentCount;

    _logger.info('[AutoRefresh] 🧹 Cleaning pending queue...');
    _logger.info('   └─ Store events: ${storeEventIds.length}');
    _logger.info(
        '   └─ Pending before: $pendingBefore items, $parentsBefore parents');

    // Step 1: Flush messages where parent EXISTS → Reprocess
    final flushedMessages = pendingQueue.flushByParents(storeEventIds);
    var reprocessedCount = 0;

    if (flushedMessages.isNotEmpty) {
      _logger.info(
          '   └─ 🔁 Flushed ${flushedMessages.length} messages to reprocess');

      for (final msg in flushedMessages) {
        _messageProcessor.onMessageProcessed?.call(
          ParsedMessage(
            type: msg.type,
            data: msg.data,
            raw: '',
            sportId: _currentSportId,
            timestamp: DateTime.now(),
          ),
        );
        reprocessedCount++;
      }
    }

    // Step 2: Remove orphan messages where parent DOESN'T exist
    final orphanResult = pendingQueue.removeOrphans(storeEventIds);

    if (orphanResult.removedCount > 0) {
      _logger.info(
          '   └─ 🗑️ Removed ${orphanResult.removedCount} orphan messages');
      if (orphanResult.orphanParentIds.length <= 5) {
        _logger.info('   └─ Orphan parents: ${orphanResult.orphanParentIds}');
      } else {
        _logger.info(
            '   └─ Orphan parents: ${orphanResult.orphanParentIds.take(5).toList()}... +${orphanResult.orphanParentIds.length - 5} more');
      }
    }

    _logger.info('   └─ Pending after: ${pendingQueue.length} items');

    return reprocessedCount;
  }
}
