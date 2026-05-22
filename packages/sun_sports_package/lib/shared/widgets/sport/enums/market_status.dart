/// Market status for betting availability
///
/// Values match sport_socket library format.
enum MarketStatus {
  /// Market đang hoạt động, có thể đặt cược
  active(0),

  /// Bị tạm ngưng thủ công
  suspended(1),

  /// Bị ẩn thủ công
  hidden(2),

  /// Bị tạm ngưng tự động (hệ thống)
  autoSuspended(3),

  /// Bị ẩn tự động (hệ thống)
  autoHidden(4);

  final int value;
  const MarketStatus(this.value);

  /// Có thể đặt cược không
  bool get canBet => this == MarketStatus.active;

  /// Có bị suspended không (manual hoặc auto)
  bool get isSuspended =>
      this == MarketStatus.suspended || this == MarketStatus.autoSuspended;

  /// Có bị hidden không (manual hoặc auto)
  bool get isHidden =>
      this == MarketStatus.hidden || this == MarketStatus.autoHidden;

  /// Có nên hiển thị không
  bool get isVisible => !isHidden;

  /// Parse từ int value
  static MarketStatus fromValue(int? value) {
    return MarketStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MarketStatus.active,
    );
  }

  /// Parse từ string
  static MarketStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
        return MarketStatus.active;
      case 'SUSPENDED':
        return MarketStatus.suspended;
      case 'HIDDEN':
        return MarketStatus.hidden;
      case 'AUTO_SUSPENDED':
      case 'AUTOSUSPENDED':
        return MarketStatus.autoSuspended;
      case 'AUTO_HIDDEN':
      case 'AUTOHIDDEN':
        return MarketStatus.autoHidden;
      default:
        return MarketStatus.active;
    }
  }
}
