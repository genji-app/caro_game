# Thiết kế & Kế hoạch Triển khai: Hệ thống Game Lifecycle & Giao tiếp UI-Controller

Mục tiêu: Xây dựng một luồng khởi tạo Game chuyên nghiệp (6 bước trạng thái) và cơ chế giao tiếp an toàn, 1 chiều giữa UI (View) và Controller (Notifier) cho `GameScreen`.

## Kiến trúc: 2 Layer (Notifier & UI)
Trước đây được thiết kế thành 3 Layer (thêm Process) nhưng đã được gộp lại thành 2 Layer để giảm bớt sự phức tạp (over-engineering) cho ứng dụng ví dụ (example app).

### 1. Controller / View-Model Layer (Presentation Logic)
#### [MODIFY] [mock_game_notifier.dart](file:///Users/admin/Documents/s88-flutter/packages/orientation_guard/example/lib/game/mock_game_notifier.dart)
- **Vai trò:** Quản lý State Machine thuần túy của Game, xử lý logic xoay màn hình (Orientation) và báo cáo dữ liệu cho UI.
- Khai báo `MockGameStatus`: `initial`, `settingUp`, `connecting`, `loadingAssets`, `playing`, `reconnecting`, `error`, `exiting`.
- Khai báo `GameEvent` (`GameExitEvent`, `GameMessageEvent`).
- Class `MockGameNotifier`:
  - Kế thừa `ChangeNotifier`.
  - Có các method: `initialize()`, `startLoading()`, `retry()`, `requestExit()`, `toggleFailMode()`.
  - Quản lý các luồng Timer/delay mô phỏng tiến trình game (0-100%).
  - Báo cáo sự thay đổi ra ngoài qua `notifyListeners()` và `Stream<GameEvent> events`.

### 2. Presentation Layer (UI)
#### [MODIFY] [game_screen.dart](file:///Users/admin/Documents/s88-flutter/packages/orientation_guard/example/lib/game/game_screen.dart)
- **Vai trò:** Lắng nghe Notifier và render giao diện tương ứng, xử lý các sự kiện một lần (One-off events).
- **Tích hợp Event Stream:**
  - Trong `didChangeDependencies`, subscribe vào `_notifier.events`.
  - Xử lý: Nhận `GameExitEvent` -> `Navigator.pop()`.
- **Cập nhật UI Switcher:**
  - Hiển thị UI tương ứng với trạng thái game trong Switcher.
  - Cập nhật `_GameBrandLoadingView` để hiển thị `LinearProgressIndicator` cho trạng thái `loadingAssets`.

---

## Verification Plan
### Manual Verification
1. Mở ứng dụng, vào màn hình Game.
2. Kiểm tra màn hình Initial hiển thị "Tap to Start".
3. Nhấn "Tap to Start". Quan sát chuỗi trạng thái: Setting Up -> Connecting -> Loading (Progress chạy 0-100%) -> Playing.
4. Bật chế độ "Simulate Failure" để kiểm tra luồng Error, sau đó thử Retry.
5. Kiểm tra tính năng Exit phát ra `GameExitEvent` và thoát ra an toàn.
