import 'dart:async';

import '../proto/proto.dart';

/// Callback for batch processing completion
typedef PayloadBatchCallback = void Function(List<Payload> payloads);

/// Lightweight batch processor for V2 Protobuf messages.
///
/// Simplified from V1 MessageProcessor:
/// - No key extraction (server handles deduplication)
/// - No priority sorting (server sends in correct order)
/// - No JSON parsing (already Protobuf Payload objects)
/// - Reduced interval: 50ms (from 200ms) for faster UI updates
///
/// Flow:
/// 1. Payload arrives via add()
/// 2. Buffer payloads
/// 3. Timer fires every batchInterval (50ms default)
/// 4. Flush buffer → onBatch callback
class LightBatchProcessor {
  /// Batch interval (default 50ms for fast UI updates)
  final Duration batchInterval;

  /// Maximum payloads per batch (safety limit)
  final int maxBatchSize;

  /// Internal buffer
  final List<Payload> _buffer = [];

  /// Flush timer
  Timer? _flushTimer;

  /// Batch callback
  PayloadBatchCallback? onBatch;

  /// Whether processor is running
  bool _isRunning = false;

  /// Statistics
  int _receivedTotal = 0;
  int _batchesTotal = 0;
  int _processedTotal = 0;
  DateTime _statsStartTime = DateTime.now();

  bool get isRunning => _isRunning;
  int get bufferSize => _buffer.length;

  LightBatchProcessor({
    this.batchInterval = const Duration(milliseconds: 50),
    this.maxBatchSize = 1000,
  });

  /// Start the batch processing loop
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _statsStartTime = DateTime.now();

    _flushTimer = Timer.periodic(batchInterval, (_) => _flush());
  }

  /// Stop the batch processing loop
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    _flushTimer?.cancel();
    _flushTimer = null;

    // Flush remaining buffer
    _flush();
  }

  /// Add a payload to the buffer
  void add(Payload payload) {
    _receivedTotal++;
    _buffer.add(payload);

    // Start timer if not running (auto-start)
    if (!_isRunning) {
      start();
    }

    // Safety: if buffer exceeds max, flush immediately
    if (_buffer.length >= maxBatchSize) {
      _flush();
    }
  }

  /// Add multiple payloads at once
  void addAll(Iterable<Payload> payloads) {
    for (final p in payloads) {
      add(p);
    }
  }

  /// Flush the buffer and emit batch
  void _flush() {
    if (_buffer.isEmpty) return;

    // Take current buffer and clear
    final batch = List<Payload>.from(_buffer);
    _buffer.clear();

    _batchesTotal++;
    _processedTotal += batch.length;

    // Emit batch
    onBatch?.call(batch);
  }

  /// Force flush immediately (useful for cleanup)
  void flush() => _flush();

  /// Get current statistics
  LightBatchStats getStats() {
    final now = DateTime.now();
    final duration = now.difference(_statsStartTime);
    final seconds = duration.inSeconds > 0 ? duration.inSeconds : 1;

    return LightBatchStats(
      receivedTotal: _receivedTotal,
      receivedPerSecond: _receivedTotal ~/ seconds,
      processedTotal: _processedTotal,
      batchesTotal: _batchesTotal,
      avgBatchSize: _batchesTotal > 0 ? _processedTotal ~/ _batchesTotal : 0,
      bufferSize: _buffer.length,
      timestamp: now,
    );
  }

  /// Reset statistics
  void resetStats() {
    _receivedTotal = 0;
    _batchesTotal = 0;
    _processedTotal = 0;
    _statsStartTime = DateTime.now();
  }

  /// Dispose resources
  void dispose() {
    stop();
    _buffer.clear();
  }
}

/// Statistics for LightBatchProcessor
class LightBatchStats {
  final int receivedTotal;
  final int receivedPerSecond;
  final int processedTotal;
  final int batchesTotal;
  final int avgBatchSize;
  final int bufferSize;
  final DateTime timestamp;

  const LightBatchStats({
    required this.receivedTotal,
    required this.receivedPerSecond,
    required this.processedTotal,
    required this.batchesTotal,
    required this.avgBatchSize,
    required this.bufferSize,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LightBatchStats(received: $receivedTotal ($receivedPerSecond/s), '
        'processed: $processedTotal, batches: $batchesTotal, '
        'avgSize: $avgBatchSize, buffer: $bufferSize)';
  }
}
