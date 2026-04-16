# Game Player Feature

Tính năng **Game Player** (`lib/features/game/player`) đảm nhiệm mở và hiển thị game của người chơi thông qua WebView, đồng thời giải quyết bài toán phức tạp về Device Orientation, System UI Overlay, và iframe lifecycle trên cả Mobile lẫn Web.

## Mục lục

- [Kiến trúc](#kiến-trúc)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Workarounds & Edge Cases](#workarounds--edge-cases)
- [Tài liệu chi tiết](#tài-liệu-chi-tiết)
- [Lưu ý phát triển](#lưu-ý-phát-triển)

---

## Kiến trúc

```
Widget Tree:

PopScope (blocks back while loading)
  └─ GamePlayerScaffold (background + adaptive layout)
      └─ _AdaptiveGameLayout (Stack-based, orientation-safe)
          └─ Stack
              ├─ _WebViewLayer   (WebView + fade-in)
              ├─ _LoadingOverlay (GamePlayerLoading + white-label shimmer)
              └─ _ErrorOverlay   (GamePlayerFailure + retry)
```

| Component | File | Vai trò |
|---|---|---|
| **GamePlayerNotifier** | `game_player_notifier.dart` | State controller: orientation lock → fetch game URL. Quản lý `finishLoadDelay` (777ms) |
| **IHRunner / PLRunner** | `package:game_engine` | Bộ engine thực thi game, xử lý bridge và viewport orchestration |
| **SystemUiService** | `core/services/system_ui/` | Platform-native orientation lock, status bar, immersive mode |
| **OrientationGuard** | `package:orientation_guard` | Widget chặn render game trên Web khi chưa đúng hướng xoay |

---

## Cấu trúc thư mục

```text
game/player/
├── README.md                           ← Bạn đang đọc file này
├── docs/                               ← Tài liệu chi tiết về bugs & fixes
│   ├── game-player-issues.md           ← Tổng hợp lỗi & giải pháp của Game Player
│   ├── orientation-issues.md           ← Orientation bugs (iPadOS + Flutter Web)
│   └── background-resume.md            ← Background/resume WebSocket fix
├── game_player_screen.dart             ← UI Screen (3 layers: webview, loading, error)
├── game_player_notifier.dart           ← Business logic (Riverpod StateNotifier)
├── game_player_notifier.freezed.dart   ← Generated Freezed code
├── game_session_guard.dart             ← Guard cooldown session limit của Game Provider
├── new_tab_game_placeholder.dart       ← Widget fallback cho iOS Safari khi WebGL quá tải
├── player.dart                         ← Central exports cho feature player
├── player_providers.dart               ← Riverpod providers
├── web_view_scale_mixin.dart           ← Mixin zoom/scale cho WebView (Web)
├── widget/                             ← UI Components (Scaffold & Status)
│   ├── game_player_scaffold.dart       ← Adaptive layout scaffold (với flag showControls)
│   ├── game_player_loading.dart        ← Loading state widget
│   ├── game_player_failure.dart        ← Error/Failure state widget
│   └── game_player_background.dart     ← Background layer
├── ../web_view/                      ← GameWebView platform implementations
│   ├── web_view.dart                 
│   └── src/                          
│       ├── game_web_view.dart
│       ├── game_web_view_mobile.dart
│       ├── web/
│       │   ├── game_web_view_web.dart
│       │   └── ...
├── ../cocos_web_view/                ← CocosWebView cho game Local/Sandbox
│   ├── cocos_web_view.dart
│   └── src/
│       ├── cocos_web_view.dart
│       ├── models/game_host_event.dart
│       ├── mixins/game_host_bridge_mixin.dart
│       └── web/ ...
```

---

## Workarounds & Edge Cases

Do sự phức tạp của Web Engine bên trong Flutter, đặc biệt khi đối đầu với luật khắt khe từ iOS/iPadOS, feature này mang theo nhiều workarounds:

### Tổng hợp nhanh

| # | Vấn đề | Nền tảng | Giải pháp | Doc |
|---|---|---|---|---|
| 1 | iPadOS 16+ Error 101 (orientation lock) | iOS | Flush orientation mask trước khi lock | [orientation-issues.md](docs/orientation-issues.md#1-flush-xả-orientation-mask-đã-fix-được-lỗi-101) |
| 2 | WebView render Mobile layout lần 2 | iOS | JS injection (`_injectLandscapeViewport`) + load `about:blank` | [orientation-issues.md](docs/orientation-issues.md#phương-pháp-5-khôi-phục-js-injection--xả-state-webview-giải-pháp-hiện-tại) |
| 3 | Stage Manager / Split-screen viewport | iOS | JS injection (`window.innerWidth/innerHeight`) | [orientation-issues.md](docs/orientation-issues.md#1-ipadosage-manager--split-screen-viewport-injection) |
| 4 | macOS transparent background crash | macOS | Skip `setBackgroundColor` on macOS | Inline in `game_web_view_mobile.dart` |
| 5 | Game reconnect screen sau background | iOS/Android | Detect background > 30s → reload fresh URL | [background-resume.md](docs/background-resume.md) |
| 6a | WebView biến mất khi xoay (Web) | Flutter Web | `_AdaptiveGameLayout` (Stack thay vì Column/Row) | [orientation-issues.md](docs/orientation-issues.md#6a-widget-tree-stabilization--ngăn-iframe-bị-unmount) |
| 6b | CSS vỡ khi xoay lúc đang load (Web) | Flutter Web | Iframe size lock/unlock pattern | [orientation-issues.md](docs/orientation-issues.md#6b-iframe-size-stabilization--ngăn-css-bị-vỡ-khi-xoay-lúc-load) |
| 7 | Iframe onLoad unreliable (CORS) | Flutter Web | Fallback timer (300ms) để dismiss loading overlay | Inline in `web/game_web_view_web.dart` |
| 8 | Game hiển thị Mobile layout trên iPad | iOS (tablet) | JS `window.matchMedia` polyfill, `forceLandscapeViewportOnIpad` | [orientation-issues.md §7](docs/orientation-issues.md#phương-pháp-7-patch-windowmatchmedia--fix-mobile-layout-trên-ipad-2026-04-02) |

### Quick Debug Guide

| Triệu chứng | Kiểm tra | Doc |
|---|---|---|
| WebView biến mất khi xoay thiết bị | Console: `Iframe dimensions locked?` / Scaffold dùng `_AdaptiveGameLayout`? | [orientation-issues.md §6A](docs/orientation-issues.md#6a-widget-tree-stabilization--ngăn-iframe-bị-unmount) |
| CSS game vỡ / to hơn bình thường | Console: `locked` → `unlocked` timing / Tăng `_kPostLoadBuffer` | [orientation-issues.md §6B](docs/orientation-issues.md#6b-iframe-size-stabilization--ngăn-css-bị-vỡ-khi-xoay-lúc-load) |
| Game hiển thị Mobile layout trên iPad | Log `matchMedia_landscape` óng `true`? / `shouldForceLandscapeViewport` trả `true`? | [orientation-issues.md §7](docs/orientation-issues.md#phương-pháp-7-patch-windowmatchmedia--fix-mobile-layout-trên-ipad-2026-04-02) |
| Game reconnect screen sau background | `_backgroundThreshold` phù hợp? / API trả đúng fresh URL? | [background-resume.md](docs/background-resume.md) |
| Error 101 trên iPadOS | `SystemUiService` có flush mask trước khi lock? | [orientation-issues.md §1](docs/orientation-issues.md#1-flush-xả-orientation-mask-đã-fix-được-lỗi-101) |

---

## Tài liệu chi tiết

| Document | Nội dung | Khi nào đọc |
|---|---|---|
| [docs/orientation-issues.md](docs/orientation-issues.md) | Toàn bộ lịch sử bugs xoay màn hình, 6 phương pháp đã thử, tuneable constants, troubleshooting | Debug lỗi xoay màn hình / layout vỡ |
| [docs/background-resume.md](docs/background-resume.md) | Fix game reload khi resume từ background, WebSocket reconnect strategy | Debug lỗi game sau khi bật lại app |
| [docs/game-player-issues.md](docs/game-player-issues.md) | Tổng hợp các lỗi chung và giải pháp cho toàn bộ feature Game Player | Cần tra cứu các workaround khác nhau trên từng nền tảng |

---

## Lưu ý phát triển

- **Luôn** gọi `systemUi.restoreDefaultSystemUI()` gắn ở `ref.onDispose` khi kết thúc Screen
- Đừng đặt logic URL/domain routing vào Notifier — nhường cho `GameUrlProvider` (SRP)
- Khi thêm widget mới vào tree path từ `GamePlayerScaffold` → `HtmlElementView`:
  **KHÔNG** dùng conditional widget types (ternary `? Type1 : Type2`) vì sẽ unmount iframe trên Web
- Test orientation changes trên **cả** Chrome DevTools (iPad Pro) **và** thiết bị thật
- Kiểm tra console logs (`Iframe dimensions locked/unlocked`) khi debug Web orientation issues
- **Khi thêm provider mới có game landscape-only trên iPad**: set `forceLandscapeViewportOnIpad: true` trong `_providerOverrides` của `game_block.dart`. Logic kích hoạt nằm ở `GameBlockX.shouldForceLandscapeViewport`
- **Không bao giờ** hardcode điều kiện `Platform.isIOS && isTablet` vào widget — luôn dùng `shouldForceLandscapeViewport(context)` để đảm bảo nhất quán với cấu hình `GameBlock`
- **Khi thêm provider crash trên iOS Safari Web**: set `openInNewTabOnIOSSafariWeb: true`. Flag này chỉ dành riêng cho iOS Safari Web, không ảnh hưởng các platform khác
