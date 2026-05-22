import 'ncc_tab_opener_stub.dart'
    if (dart.library.js_interop) 'ncc_tab_opener_web.dart';

/// Một tab trình duyệt đã được mở sẵn (web) để điều hướng tới URL sau đó.
abstract interface class NccPendingTab {
  /// Điều hướng tab tới [url].
  void navigate(String url);

  /// Đóng tab (gọi khi launch thất bại / bị huỷ).
  void close();
}

/// Mở sẵn 1 tab trắng NGAY trong user-gesture (web) — tránh bị popup-blocker
/// chặn khi `window.open` được gọi sau `await`.
///
/// Trả `null` trên native (dùng `launchUrl` trình duyệt ngoài thay thế) hoặc
/// khi popup bị chặn ngay từ đầu.
NccPendingTab? openPendingTab() => openPendingTabImpl();
