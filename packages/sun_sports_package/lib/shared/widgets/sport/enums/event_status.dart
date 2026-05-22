/// Event status matching sport_socket library
///
/// Server gửi 5 status:
/// - Active (0) - Đang hoạt động
/// - Suspended (1) - Tạm ngưng
/// - Hidden (2) - Ẩn
/// - AutoSuspended (3) - Tự động tạm ngưng
/// - AutoHidden (4) - Tự động ẩn
enum EventStatus { active, suspended, hidden, autoSuspended, autoHidden }

extension EventStatusX on EventStatus {
  /// Có thể đặt cược không
  bool get canBet => this == EventStatus.active;

  /// Có nên hiển thị không
  bool get isVisible =>
      this != EventStatus.hidden && this != EventStatus.autoHidden;

  /// Event bị ẩn/kết thúc (Hidden hoặc AutoHidden)
  bool get isHidden =>
      this == EventStatus.hidden || this == EventStatus.autoHidden;

  /// Event bị tạm ngưng (Suspended hoặc AutoSuspended)
  bool get isSuspended =>
      this == EventStatus.suspended || this == EventStatus.autoSuspended;

  /// Text hiển thị
  String get displayText {
    switch (this) {
      case EventStatus.active:
        return '';
      case EventStatus.suspended:
      case EventStatus.autoSuspended:
        return 'Tạm ngưng';
      case EventStatus.hidden:
      case EventStatus.autoHidden:
        return 'Hủy';
    }
  }

  /// Parse từ string (API/WebSocket)
  static EventStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
      case '0':
        return EventStatus.active;
      case 'SUSPENDED':
      case '1':
        return EventStatus.suspended;
      case 'HIDDEN':
      case '2':
        return EventStatus.hidden;
      case 'AUTOSUSPENDED':
      case 'AUTO_SUSPENDED':
      case '3':
        return EventStatus.autoSuspended;
      case 'AUTOHIDDEN':
      case 'AUTO_HIDDEN':
      case '4':
        return EventStatus.autoHidden;
      default:
        return EventStatus.active;
    }
  }
}
