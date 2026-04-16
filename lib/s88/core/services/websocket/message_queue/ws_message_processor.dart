/// WebSocket Message Processor
///
/// Main coordinator that combines all message queue components:
/// - Queue: Circular buffer for messages
/// - RateLimiter: Timer-based processing (changed from Ticker for reliability)
/// - SportFilter: Filter by current sport
/// - PopupForwarder: Priority forwarding to popup
/// - Monitor: Performance tracking and logging
///
/// This is the single entry point for SbWebSocket to use.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../websocket_messages.dart';
import 'ws_queued_message.dart';
import 'ws_message_queue.dart';
import 'ws_rate_limiter.dart';
import 'ws_sport_filter.dart';
import 'ws_popup_forwarder.dart';
import 'ws_performance_monitor.dart';
import 'ws_queue_config.dart';

/// Callback for processing a batch of filtered messages
typedef FilteredBatchCallback = void Function(List<WsQueuedMessage> messages);

/// Main processor coordinating all message queue components
class WsMessageProcessor with WidgetsBindingObserver {
  /// Message queue (circular buffer)
  late final WsMessageQueue _queue;

  /// Rate limiter (timer-based)
  late final WsRateLimiter _rateLimiter;

  /// Sport filter
  final WsSportFilter _sportFilter = WsSportFilter();

  /// Popup forwarder
  final WsPopupForwarder _popupForwarder = WsPopupForwarder();

  /// Performance monitor
  late final WsPerformanceMonitor _monitor;

  /// Callback when batch of messages is ready for processing
  final FilteredBatchCallback onBatchProcess;

  /// Whether the processor is initialized
  bool _isInitialized = false;

  /// Whether queue is bypassed (for rollback)
  bool bypassQueue = false;

  WsMessageProcessor({
    required this.onBatchProcess,
    int maxQueueSize = WsQueueConfig.maxQueueSize,
    int messagesPerTick = WsQueueConfig.messagesPerFrame,
    Duration tickInterval = WsQueueConfig.tickInterval,
    Duration logInterval = WsQueueConfig.logInterval,
    bool debugMode = WsQueueConfig.debugMode,
  }) {
    _queue = WsMessageQueue(maxSize: maxQueueSize);

    _rateLimiter = WsRateLimiter(
      queue: _queue,
      messagesPerTick: messagesPerTick,
      tickInterval: tickInterval,
      onProcess: _onRateLimiterProcess,
    );

    _monitor = WsPerformanceMonitor(
      logInterval: logInterval,
      debugMode: debugMode,
      queue: _queue,
    );
  }

  /// Initialize the processor
  ///
  /// Must be called before enqueuing messages.
  /// TickerProvider parameter kept for API compatibility but not used
  /// (Timer-based processing works regardless of UI state).
  void initialize(dynamic tickerProvider) {
    if (_isInitialized) return;

    _rateLimiter.start(tickerProvider);
    _monitor.start();
    WidgetsBinding.instance.addObserver(this);

    _isInitialized = true;
  }

  /// Whether the processor is initialized
  bool get isInitialized => _isInitialized;

  /// Set/get current sport ID filter
  int? get currentSportId => _sportFilter.currentSportId;
  set currentSportId(int? sportId) => _sportFilter.currentSportId = sportId;

  /// Set/get debug mode
  bool get debugMode => _monitor.debugMode;
  set debugMode(bool value) => _monitor.debugMode = value;

  /// Set/get sequence tracking mode
  /// When enabled, logs message flow patterns (e.g., event_ins -> market_up -> odds_up)
  bool get enableSequenceTracking => _monitor.enableSequenceTracking;
  set enableSequenceTracking(bool value) =>
      _monitor.enableSequenceTracking = value;

  /// Force flush current sequence log
  void flushSequenceLog() => _monitor.flushSequenceNow();

  /// Stream for popup priority messages
  Stream<WsQueuedMessage> get popupMessageStream =>
      _popupForwarder.popupMessageStream;

  /// Register a popup for priority forwarding
  void registerPopup(int eventId) {
    _popupForwarder.registerPopup(eventId);
  }

  /// Unregister popup
  void unregisterPopup() {
    _popupForwarder.unregisterPopup();
  }

  /// Check if popup is registered
  bool get hasActivePopup => _popupForwarder.hasActivePopup;

  /// Enqueue a WebSocket message for processing
  ///
  /// If bypassQueue is true, message is not queued (for rollback).
  void enqueue(WsMessage message) {
    if (bypassQueue) {
      // Bypass queue - process immediately (old behavior)
      final queuedMessage = WsQueuedMessage.fromMessage(message);
      onBatchProcess([queuedMessage]);
      return;
    }

    final queuedMessage = WsQueuedMessage.fromMessage(message);

    // Track received
    _monitor.onMessageReceived(queuedMessage);

    // Check popup forwarding first (immediate, bypasses queue)
    if (_popupForwarder.tryForward(queuedMessage)) {
      _monitor.onPopupForward(queuedMessage);
      // Still add to queue for normal processing too
    }

    // Add to queue
    final dropped = _queue.enqueue(queuedMessage);
    if (dropped) {
      // A message was dropped to make room
      _monitor.onMessageDropped(queuedMessage);
    }
  }

  /// Called by rate limiter when batch is ready
  void _onRateLimiterProcess(List<WsQueuedMessage> messages) {
    if (messages.isEmpty) return;

    // Apply sport filter
    final filteredMessages = _sportFilter.filter(messages);
    final filteredOutCount = messages.length - filteredMessages.length;

    if (filteredOutCount > 0) {
      _monitor.onMessagesFiltered(filteredOutCount);
    }

    if (filteredMessages.isEmpty) return;

    // Track processing
    _monitor.onBatchProcessed(filteredMessages);

    // Call the processing callback
    onBatchProcess(filteredMessages);
  }

  /// Handle app lifecycle changes
  ///
  /// Only pause on truly background states (paused, detached).
  /// Do NOT pause on inactive/hidden - these happen frequently during
  /// normal usage (notifications, dialogs, keyboard, etc.) and the
  /// Ticker should keep processing messages.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App truly in background - pause processing
        _rateLimiter.pause();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App still visible or temporarily obscured - keep processing
        // These states happen during: notifications, dialogs, split-screen, etc.
        break;
      case AppLifecycleState.resumed:
        _rateLimiter.resume();
        break;
    }
  }

  /// Get combined statistics
  WsProcessorStats get stats => WsProcessorStats(
    queue: _queue.stats,
    rateLimiter: _rateLimiter.stats,
    sportFilter: _sportFilter.stats,
    popupForwarder: _popupForwarder.stats,
    performance: _monitor.stats,
    isInitialized: _isInitialized,
    bypassQueue: bypassQueue,
  );

  /// Reset all statistics
  void resetStats() {
    _queue.resetStats();
    _rateLimiter.resetStats();
    _sportFilter.resetStats();
    _popupForwarder.resetStats();
    _monitor.resetAllStats();
  }

  /// Clear the queue
  void clearQueue() {
    _queue.clear();
  }

  /// Pause processing (when isolate is active or app backgrounded)
  void pause() {
    _rateLimiter.pause();
    _monitor.pause();
  }

  /// Resume processing
  void resume() {
    _rateLimiter.resume();
    _monitor.resume();
  }

  /// Whether processing is paused
  bool get isPaused => _rateLimiter.isPaused;

  /// Dispose all resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rateLimiter.dispose();
    _popupForwarder.dispose();
    _monitor.dispose();
    _isInitialized = false;
  }
}

/// Combined processor statistics
class WsProcessorStats {
  final WsQueueStats queue;
  final WsRateLimiterStats rateLimiter;
  final WsSportFilterStats sportFilter;
  final WsPopupForwarderStats popupForwarder;
  final WsPerformanceStats performance;
  final bool isInitialized;
  final bool bypassQueue;

  const WsProcessorStats({
    required this.queue,
    required this.rateLimiter,
    required this.sportFilter,
    required this.popupForwarder,
    required this.performance,
    required this.isInitialized,
    required this.bypassQueue,
  });

  @override
  String toString() {
    return '''
WsProcessorStats:
  initialized: $isInitialized, bypassQueue: $bypassQueue
  $queue
  $rateLimiter
  $sportFilter
  $popupForwarder
  $performance''';
  }
}
