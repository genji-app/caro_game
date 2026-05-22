import 'package:meta/meta.dart';

/// Performance metrics for the message processor.
///
/// Emitted periodically to monitor processing performance.
@immutable
class ProcessorMetrics {
  /// Total messages received since start
  final int receivedTotal;

  /// Messages received per second (average)
  final int receivedPerSecond;

  /// Total messages successfully processed
  final int processedTotal;

  /// Messages processed per second (average)
  final int processedPerSecond;

  /// Total messages dropped due to buffer overflow
  final int droppedTotal;

  /// Total parse errors
  final int parseErrorsTotal;

  /// Current pending queue size
  final int pendingQueueSize;

  /// Messages dropped from pending queue due to overflow
  final int pendingQueueDropped;

  /// Messages expired from pending queue
  final int pendingQueueExpired;

  /// Current deduplication buffer size
  final int bufferSize;

  /// Deduplication ratio (percentage of duplicate messages)
  final double dedupRatio;

  /// Message counts by type
  final Map<String, int> byMessageType;

  /// Timestamp when metrics were captured
  final DateTime timestamp;

  const ProcessorMetrics({
    required this.receivedTotal,
    required this.receivedPerSecond,
    required this.processedTotal,
    required this.processedPerSecond,
    required this.droppedTotal,
    required this.parseErrorsTotal,
    required this.pendingQueueSize,
    required this.pendingQueueDropped,
    required this.pendingQueueExpired,
    required this.bufferSize,
    required this.dedupRatio,
    required this.byMessageType,
    required this.timestamp,
  });

  /// Create empty metrics
  factory ProcessorMetrics.empty() {
    return ProcessorMetrics(
      receivedTotal: 0,
      receivedPerSecond: 0,
      processedTotal: 0,
      processedPerSecond: 0,
      droppedTotal: 0,
      parseErrorsTotal: 0,
      pendingQueueSize: 0,
      pendingQueueDropped: 0,
      pendingQueueExpired: 0,
      bufferSize: 0,
      dedupRatio: 0.0,
      byMessageType: const {},
      timestamp: DateTime.now(),
    );
  }

  /// Calculate efficiency (processed / received)
  double get efficiency {
    if (receivedTotal == 0) return 100.0;
    return (processedTotal / receivedTotal) * 100;
  }

  /// Total error count
  int get totalErrors => droppedTotal + parseErrorsTotal;

  /// Error rate percentage
  double get errorRate {
    if (receivedTotal == 0) return 0.0;
    return (totalErrors / receivedTotal) * 100;
  }

  /// Check if processor is healthy
  bool get isHealthy {
    // Consider unhealthy if:
    // - Error rate > 10%
    // - Pending queue is too large (> 1000)
    // - Dedup buffer is too large (> 5000)
    return errorRate < 10.0 && pendingQueueSize < 1000 && bufferSize < 5000;
  }

  /// Get most common message type
  String? get mostCommonType {
    if (byMessageType.isEmpty) return null;

    String? maxType;
    var maxCount = 0;

    for (final entry in byMessageType.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxType = entry.key;
      }
    }

    return maxType;
  }

  @override
  String toString() {
    return 'ProcessorMetrics('
        'received: $receivedPerSecond/s, '
        'processed: $processedPerSecond/s, '
        'dropped: $droppedTotal, '
        'pending: $pendingQueueSize, '
        'dedup: ${dedupRatio.toStringAsFixed(1)}%, '
        'healthy: $isHealthy)';
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'receivedTotal': receivedTotal,
      'receivedPerSecond': receivedPerSecond,
      'processedTotal': processedTotal,
      'processedPerSecond': processedPerSecond,
      'droppedTotal': droppedTotal,
      'parseErrorsTotal': parseErrorsTotal,
      'pendingQueueSize': pendingQueueSize,
      'pendingQueueDropped': pendingQueueDropped,
      'pendingQueueExpired': pendingQueueExpired,
      'bufferSize': bufferSize,
      'dedupRatio': dedupRatio,
      'byMessageType': byMessageType,
      'timestamp': timestamp.toIso8601String(),
      'efficiency': efficiency,
      'errorRate': errorRate,
      'isHealthy': isHealthy,
    };
  }
}
