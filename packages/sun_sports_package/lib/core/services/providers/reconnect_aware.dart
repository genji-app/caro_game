/// Contract cho notifier cần refresh dữ liệu khi internet kết nối lại.
///
/// Trong Dart đóng vai trò "interface" (pure contract). Notifier implement
/// [refreshOnReconnect] để coordinator gọi khi [NetworkManagerEvent.connectionRestored].
abstract class ReconnectAware {
  /// Gọi khi [NetworkManagerEvent.connectionRestored].
  void refreshOnReconnect();
}
