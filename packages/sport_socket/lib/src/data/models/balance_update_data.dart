/// Data emitted when balance_up or user_bal message received.
///
/// Used by consumers to update balance displays.
class BalanceUpdateData {
  /// Balance value (parsed from server)
  final double balance;

  /// Currency code (if provided)
  final String? currency;

  /// Original raw value from server
  final String raw;

  /// Timestamp when update was received
  final DateTime timestamp;

  const BalanceUpdateData({
    required this.balance,
    this.currency,
    required this.raw,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'BalanceUpdateData(balance: $balance, currency: $currency)';
  }
}
