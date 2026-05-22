/// WebSocket Rate Limiter
///
/// Uses Timer to process messages at a controlled rate.
/// Processes a fixed number of messages per tick to prevent UI lag.
///
/// Default: 10 messages per 16ms = ~625 msg/s capacity
/// (Changed from Ticker to Timer because Ticker only fires during frame render,
/// which doesn't happen when app is idle)

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ws_queued_message.dart';
import 'ws_message_queue.dart';

/// Callback for processing a batch of messages
typedef MessageBatchCallback = void Function(List<WsQueuedMessage> messages);

/// Timer-based rate limiter for WebSocket messages
class WsRateLimiter {
  /// Queue to process messages from
  final WsMessageQueue queue;

  /// Callback when messages are ready to be processed
  final MessageBatchCallback onProcess;

  /// Maximum messages to process per tick
  final int messagesPerTick;

  /// Timer interval (default 16ms ≈ 60fps)
  final Duration tickInterval;

  /// Timer for periodic processing
  Timer? _timer;

  /// Whether the rate limiter is currently running
  bool _isRunning = false;

  /// Total ticks processed
  int _ticksProcessed = 0;

  /// Total messages processed
  int _messagesProcessed = 0;

  /// Whether the rate limiter is paused (e.g., app in background)
  bool _isPaused = false;

  WsRateLimiter({
    required this.queue,
    required this.onProcess,
    this.messagesPerTick = 10, // Increased from 5 to handle higher load
    this.tickInterval = const Duration(milliseconds: 16), // ~60fps
  });

  /// Whether the rate limiter is currently running
  bool get isRunning => _isRunning;

  /// Whether the rate limiter is paused
  bool get isPaused => _isPaused;

  /// Total ticks processed since start
  int get framesProcessed => _ticksProcessed;

  /// Total messages processed since start
  int get messagesProcessed => _messagesProcessed;

  /// Start the rate limiter
  ///
  /// Note: TickerProvider parameter kept for API compatibility but not used.
  /// Timer-based approach works regardless of UI state.
  void start(dynamic tickerProvider) {
    if (_isRunning) return;

    _timer = Timer.periodic(tickInterval, _onTick);
    _isRunning = true;
    _isPaused = false;

    debugPrint(
      '🚀 WsRateLimiter: Started (${messagesPerTick} msg/${tickInterval.inMilliseconds}ms = '
      '${(messagesPerTick * 1000 / tickInterval.inMilliseconds).round()} msg/s capacity)',
    );
  }

  /// Stop the rate limiter
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('🛑 WsRateLimiter: Stopped');
  }

  /// Pause processing (e.g., when app goes to background)
  void pause() {
    if (!_isRunning || _isPaused) return;
    _timer?.cancel();
    _timer = null;
    _isPaused = true;
    debugPrint('⏸️ WsRateLimiter: Paused (queue: ${queue.length})');
  }

  /// Resume processing (e.g., when app comes to foreground)
  void resume() {
    if (!_isRunning) {
      debugPrint('⚠️ WsRateLimiter: Cannot resume - not running');
      return;
    }
    if (!_isPaused) {
      // Already running, no need to resume
      return;
    }
    _timer = Timer.periodic(tickInterval, _onTick);
    _isPaused = false;
    debugPrint('▶️ WsRateLimiter: Resumed (queue: ${queue.length})');
  }

  /// Reset statistics
  void resetStats() {
    _ticksProcessed = 0;
    _messagesProcessed = 0;
  }

  /// Called every tick by the Timer
  void _onTick(Timer timer) {
    _ticksProcessed++;

    // Skip if queue is empty
    if (queue.isEmpty) return;

    // Dequeue up to messagesPerTick messages
    final messages = queue.dequeue(messagesPerTick);
    if (messages.isEmpty) return;

    _messagesProcessed += messages.length;

    // Call the processing callback
    onProcess(messages);
  }

  /// Get rate limiter statistics
  WsRateLimiterStats get stats => WsRateLimiterStats(
    isRunning: _isRunning,
    isPaused: _isPaused,
    framesProcessed: _ticksProcessed,
    messagesProcessed: _messagesProcessed,
    messagesPerFrame: messagesPerTick,
    queueLength: queue.length,
    tickIntervalMs: tickInterval.inMilliseconds,
  );

  /// Dispose resources
  void dispose() {
    stop();
  }
}

/// Rate limiter statistics snapshot
class WsRateLimiterStats {
  final bool isRunning;
  final bool isPaused;
  final int framesProcessed;
  final int messagesProcessed;
  final int messagesPerFrame;
  final int queueLength;
  final int tickIntervalMs;

  const WsRateLimiterStats({
    required this.isRunning,
    required this.isPaused,
    required this.framesProcessed,
    required this.messagesProcessed,
    required this.messagesPerFrame,
    required this.queueLength,
    this.tickIntervalMs = 16,
  });

  /// Theoretical max throughput (messages per second)
  int get maxThroughput => (messagesPerFrame * 1000 / tickIntervalMs).round();

  /// Average messages per tick (if ticks > 0)
  double get avgMessagesPerFrame =>
      framesProcessed > 0 ? messagesProcessed / framesProcessed : 0;

  @override
  String toString() {
    return 'RateLimiterStats(running: $isRunning, paused: $isPaused, '
        'ticks: $framesProcessed, messages: $messagesProcessed, '
        'queue: $queueLength, maxThroughput: $maxThroughput/s)';
  }
}
