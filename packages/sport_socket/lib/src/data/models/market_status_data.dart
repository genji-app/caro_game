import 'market_data.dart';

/// Data emitted when market_up message received.
///
/// Used by consumers to update market status displays.
class MarketStatusData {
  /// Event ID
  final int eventId;

  /// Market ID
  final int marketId;

  /// Sport ID
  final int sportId;

  /// Market status
  final MarketStatus status;

  /// Whether market is suspended
  final bool isSuspended;

  /// Timestamp when update was received
  final DateTime timestamp;

  const MarketStatusData({
    required this.eventId,
    required this.marketId,
    required this.sportId,
    required this.status,
    required this.isSuspended,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'MarketStatusData(eventId: $eventId, marketId: $marketId, '
        'status: $status, isSuspended: $isSuspended)';
  }
}
