import 'odds_data.dart';

/// Data emitted for EVERY odds update (not just direction changes).
///
/// Use this when you need to update UI with new odds values regardless
/// of whether the direction changed. For direction indicators only,
/// use [OddsChangeData] instead.
class OddsUpdateData {
  /// Event ID
  final int eventId;

  /// Market ID
  final int marketId;

  /// Offer ID
  final String offerId;

  /// Full odds data with all values
  final OddsData odds;

  /// Timestamp when update was received
  final DateTime timestamp;

  const OddsUpdateData({
    required this.eventId,
    required this.marketId,
    required this.offerId,
    required this.odds,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'OddsUpdateData(eventId: $eventId, marketId: $marketId, offerId: $offerId)';
  }
}
