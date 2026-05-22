import 'odds_data.dart';

/// Data emitted when odds value changes for a specific selection.
///
/// Used by consumers to update odds change indicators (up/down arrows)
/// without polling the DataStore.
class OddsChangeData {
  /// Event ID
  final int eventId;

  /// Market ID
  final int marketId;

  /// Offer ID (unique identifier for this odds line)
  final String offerId;

  /// Selection ID that changed (home/away/draw selection)
  final String selectionId;

  /// Type of selection: 'home', 'away', or 'draw'
  final String selectionType;

  /// Previous odds value (decimal format)
  final double previousValue;

  /// Current odds value (decimal format)
  final double currentValue;

  /// Direction of change (up/down/none)
  final OddsDirection direction;

  /// All odds formats for UI display
  final OddsStyleValues? styleValues;

  /// Timestamp when update was received
  final DateTime timestamp;

  const OddsChangeData({
    required this.eventId,
    required this.marketId,
    required this.offerId,
    required this.selectionId,
    required this.selectionType,
    required this.previousValue,
    required this.currentValue,
    required this.direction,
    this.styleValues,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'OddsChangeData(eventId: $eventId, marketId: $marketId, '
        'selectionId: $selectionId, type: $selectionType, '
        'prev: $previousValue, curr: $currentValue, dir: $direction)';
  }
}

/// All odds formats for a selection.
///
/// Contains odds in multiple formats so UI can display
/// according to user's preferred odds style.
class OddsStyleValues {
  /// Decimal odds (e.g., 2.50)
  final double decimal;

  /// Malaysian odds format (e.g., "0.50", "-0.80")
  final String? malay;

  /// Indonesian odds format (e.g., "-2.00", "1.50")
  final String? indo;

  /// Hong Kong odds format (e.g., "1.50", "0.80")
  final String? hk;

  const OddsStyleValues({
    required this.decimal,
    this.malay,
    this.indo,
    this.hk,
  });

  @override
  String toString() {
    return 'OddsStyleValues(decimal: $decimal, malay: $malay, indo: $indo, hk: $hk)';
  }
}
