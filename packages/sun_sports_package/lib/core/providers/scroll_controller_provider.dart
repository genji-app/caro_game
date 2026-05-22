import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cung cấp ScrollController cho main content
/// Được sử dụng để detect scroll và collapse/expand bottom navigation
final mainScrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Trạng thái hiển thị bottom navigation
/// - expanded: hiển thị đầy đủ navigation
/// - collapsed: thu gọn thành nút "Phiếu cược"
enum BottomNavVisibility { expanded, collapsed }

/// Provider quản lý trạng thái hiển thị bottom navigation
/// Dựa trên scroll velocity và hướng scroll để quyết định ẩn/hiện
class BottomNavVisibilityNotifier extends Notifier<BottomNavVisibility> {
  /// Ngưỡng velocity để trigger collapse (pixels/second)
  /// Scroll nhanh hơn ngưỡng này sẽ collapse
  static const double _velocityThreshold = 800.0;

  /// Khoảng cách scroll xuống để trigger expand (pixels)
  /// Phải scroll xuống ít nhất bao nhiêu pixel mới expand lại
  static const double _scrollDownThreshold = 50.0;

  /// Thời gian debounce để tránh toggle quá nhanh (ms)
  static const int _debounceMs = 100;

  DateTime? _lastToggleTime;

  /// Tích lũy khoảng cách scroll xuống khi đang collapsed
  double _accumulatedScrollDown = 0.0;

  /// Thời điểm bắt đầu tạm dừng scroll detection
  DateTime? _pauseUntil;

  /// Thời gian tạm dừng sau khi chuyển page (ms)
  static const int _pauseDurationMs = 500;

  @override
  BottomNavVisibility build() {
    // Tạm dừng scroll detection khi app mới khởi động
    // để tránh collapse do scroll events từ việc render content
    _pauseUntil = DateTime.now().add(const Duration(milliseconds: 1000));
    return BottomNavVisibility.expanded;
  }

  /// Tạm dừng scroll detection trong một khoảng thời gian
  /// Gọi khi user chuyển page để tránh trigger collapse
  void pauseDetection() {
    _pauseUntil = DateTime.now().add(
      const Duration(milliseconds: _pauseDurationMs),
    );
  }

  /// Xử lý scroll notification và quyết định collapse/expand
  /// Returns true nếu notification đã được xử lý
  bool handleScrollNotification(ScrollNotification notification) {
    // Bỏ qua nếu đang trong thời gian tạm dừng
    if (_pauseUntil != null && DateTime.now().isBefore(_pauseUntil!)) {
      return false;
    }

    // Chỉ xử lý scroll từ main content (depth 0)
    // Bỏ qua nested scrolls như chat, lists trong cards, etc.
    if (notification.depth != 0) {
      return false;
    }

    // Chỉ xử lý khi đang scroll
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      final scrollDelta = notification.scrollDelta ?? 0;
      final now = DateTime.now();

      // Bỏ qua bounce events (overscroll bounce back)
      // Khi ở cuối trang và kéo thêm rồi thả, bounce back sẽ có scrollDelta < 0
      // nhưng không phải user thực sự scroll xuống
      if (metrics.outOfRange) {
        return false;
      }

      // Bỏ qua khi đang ở edge và có bounce back
      // atEdge = true khi pixels == 0 hoặc pixels == maxScrollExtent
      // Kết hợp với scrollDelta để detect bounce back từ overscroll
      final isAtBottom = metrics.pixels >= metrics.maxScrollExtent - 1;
      final isAtTop = metrics.pixels <= metrics.minScrollExtent + 1;

      // Nếu đang ở cuối và scrollDelta < 0: có thể là bounce back từ overscroll dưới
      // Nếu đang ở đầu và scrollDelta > 0: có thể là bounce back từ overscroll trên
      if ((isAtBottom && scrollDelta < 0) || (isAtTop && scrollDelta > 0)) {
        return false;
      }

      // scrollDelta > 0: scroll lên (content đi lên, ngón tay kéo lên)
      // scrollDelta < 0: scroll xuống (content đi xuống, ngón tay kéo xuống)
      final isScrollingUp = scrollDelta > 0;
      final isScrollingDown = scrollDelta < 0;

      // Debounce để tránh toggle quá nhanh
      final shouldDebounce =
          _lastToggleTime != null &&
          now.difference(_lastToggleTime!).inMilliseconds < _debounceMs;

      if (state == BottomNavVisibility.expanded) {
        // Đang expanded -> chỉ collapse khi scroll LÊN nhanh
        if (isScrollingUp && !shouldDebounce) {
          // Tính velocity dựa trên delta (pixels per frame ~16ms -> pixels per second)
          final estimatedVelocity = scrollDelta.abs() * 60;

          if (estimatedVelocity > _velocityThreshold) {
            state = BottomNavVisibility.collapsed;
            _lastToggleTime = now;
            _accumulatedScrollDown = 0.0; // Reset tích lũy
          }
        }
      } else {
        // Đang collapsed -> expand khi scroll XUỐNG một đoạn
        if (isScrollingDown) {
          _accumulatedScrollDown += scrollDelta.abs();

          if (_accumulatedScrollDown >= _scrollDownThreshold &&
              !shouldDebounce) {
            state = BottomNavVisibility.expanded;
            _lastToggleTime = now;
            _accumulatedScrollDown = 0.0;
          }
        } else if (isScrollingUp) {
          // Reset tích lũy nếu scroll lên
          _accumulatedScrollDown = 0.0;
        }
      }
    }

    return false; // Không chặn notification
  }

  /// Force expand bottom navigation
  void expand() {
    state = BottomNavVisibility.expanded;
    _accumulatedScrollDown = 0.0;
  }

  /// Force collapse bottom navigation
  void collapse() {
    state = BottomNavVisibility.collapsed;
    _accumulatedScrollDown = 0.0;
  }

  /// Toggle trạng thái
  void toggle() {
    state = state == BottomNavVisibility.expanded
        ? BottomNavVisibility.collapsed
        : BottomNavVisibility.expanded;
    _accumulatedScrollDown = 0.0;
  }
}

/// Provider cho bottom navigation visibility
final bottomNavVisibilityProvider =
    NotifierProvider<BottomNavVisibilityNotifier, BottomNavVisibility>(
      BottomNavVisibilityNotifier.new,
    );
