/// WebSocket Message Queue (Circular Buffer)
///
/// A fixed-size circular buffer for queuing WebSocket messages.
/// When the queue is full, oldest messages are dropped to make room for new ones.
///
/// Features:
/// - O(1) enqueue and dequeue operations
/// - Automatic overflow handling (drops oldest)
/// - Tracks dropped message count for monitoring

import 'ws_queued_message.dart';

/// Circular buffer queue for WebSocket messages
class WsMessageQueue {
  /// Maximum number of messages the queue can hold
  final int maxSize;

  /// Internal buffer
  late final List<WsQueuedMessage?> _buffer;

  /// Index of the oldest message (head)
  int _head = 0;

  /// Index where next message will be inserted (tail)
  int _tail = 0;

  /// Current number of messages in queue
  int _count = 0;

  /// Total number of messages dropped due to overflow
  int _droppedCount = 0;

  /// Total number of messages ever enqueued
  int _totalEnqueued = 0;

  WsMessageQueue({this.maxSize = 9999}) {
    _buffer = List<WsQueuedMessage?>.filled(maxSize, null);
  }

  /// Number of messages currently in queue
  int get length => _count;

  /// Whether the queue is empty
  bool get isEmpty => _count == 0;

  /// Whether the queue is full
  bool get isFull => _count >= maxSize;

  /// Total messages dropped due to overflow
  int get droppedCount => _droppedCount;

  /// Total messages ever enqueued
  int get totalEnqueued => _totalEnqueued;

  /// Current fill percentage (0.0 to 1.0)
  double get fillPercentage => _count / maxSize;

  /// Add a message to the queue
  ///
  /// If the queue is full, the oldest message is dropped.
  /// Returns true if a message was dropped.
  bool enqueue(WsQueuedMessage message) {
    bool dropped = false;

    if (_count >= maxSize) {
      // Queue is full - drop oldest message
      _head = (_head + 1) % maxSize;
      _droppedCount++;
      _count--;
      dropped = true;
    }

    _buffer[_tail] = message;
    _tail = (_tail + 1) % maxSize;
    _count++;
    _totalEnqueued++;

    return dropped;
  }

  /// Remove and return the oldest message from the queue
  ///
  /// Returns null if queue is empty.
  WsQueuedMessage? dequeueOne() {
    if (_count == 0) return null;

    final message = _buffer[_head];
    _buffer[_head] = null; // Help GC
    _head = (_head + 1) % maxSize;
    _count--;

    return message;
  }

  /// Remove and return up to [count] oldest messages from the queue
  ///
  /// Returns a list of messages (may be less than [count] if queue doesn't have enough).
  List<WsQueuedMessage> dequeue(int count) {
    if (_count == 0) return const [];

    final actualCount = count > _count ? _count : count;
    final result = <WsQueuedMessage>[];

    for (int i = 0; i < actualCount; i++) {
      final message = _buffer[_head];
      if (message != null) {
        result.add(message);
      }
      _buffer[_head] = null; // Help GC
      _head = (_head + 1) % maxSize;
    }

    _count -= actualCount;
    return result;
  }

  /// Peek at the oldest message without removing it
  ///
  /// Returns null if queue is empty.
  WsQueuedMessage? peek() {
    if (_count == 0) return null;
    return _buffer[_head];
  }

  /// Peek at up to [count] oldest messages without removing them
  List<WsQueuedMessage> peekMany(int count) {
    if (_count == 0) return const [];

    final actualCount = count > _count ? _count : count;
    final result = <WsQueuedMessage>[];

    int index = _head;
    for (int i = 0; i < actualCount; i++) {
      final message = _buffer[index];
      if (message != null) {
        result.add(message);
      }
      index = (index + 1) % maxSize;
    }

    return result;
  }

  /// Clear all messages from the queue
  void clear() {
    for (int i = 0; i < maxSize; i++) {
      _buffer[i] = null;
    }
    _head = 0;
    _tail = 0;
    _count = 0;
  }

  /// Reset statistics (dropped count, total enqueued)
  void resetStats() {
    _droppedCount = 0;
    _totalEnqueued = 0;
  }

  /// Get queue statistics
  WsQueueStats get stats => WsQueueStats(
    length: _count,
    maxSize: maxSize,
    droppedCount: _droppedCount,
    totalEnqueued: _totalEnqueued,
    fillPercentage: fillPercentage,
  );

  @override
  String toString() {
    return 'WsMessageQueue(length: $_count/$maxSize, dropped: $_droppedCount)';
  }
}

/// Queue statistics snapshot
class WsQueueStats {
  final int length;
  final int maxSize;
  final int droppedCount;
  final int totalEnqueued;
  final double fillPercentage;

  const WsQueueStats({
    required this.length,
    required this.maxSize,
    required this.droppedCount,
    required this.totalEnqueued,
    required this.fillPercentage,
  });

  @override
  String toString() {
    final fillPct = (fillPercentage * 100).toStringAsFixed(1);
    return 'QueueStats(length: $length/$maxSize ($fillPct%), dropped: $droppedCount, total: $totalEnqueued)';
  }
}
