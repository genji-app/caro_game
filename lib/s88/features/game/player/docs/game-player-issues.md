# Game Player — Các vấn đề đã biết & Giải pháp

> Tài liệu này ghi lại các bug, workaround và giải pháp liên quan đến
> module **Game Player** (`lib/features/game/player/`).

---

## Mục lục

1. [Android: WebView mất kết nối khi resume từ background](#1-android-webview-mất-kết-nối-khi-resume-từ-background)
2. [Flutter Web: WebView bị unmount khi xoay màn hình](#2-flutter-web-webview-bị-unmount-khi-xoay-màn-hình)
3. [iPadOS: WebView render sai layout khi xoay màn hình](#3-ipados-webview-render-sai-layout-khi-xoay-màn-hình)
4. [iOS Safari: App crash/reset khi load game trong iframe](#4-ios-safari-app-crashreset-khi-load-game-trong-iframe)
5. [iPad: Game hiển thị Mobile layout dù đang ở Landscape](#5-ipad-game-hiển-thị-mobile-layout-dù-đang-ở-landscape)

---

## 1. Android: WebView mất kết nối khi resume từ background

| Mục | Chi tiết |
|-----|----------|
| **Ticket** | GSB-90 |
| **Platform** | Android (mobile) |
| **Trạng thái** | ✅ Đã fix |
| **File liên quan** | [`game_web_view_mobile.dart`](../web_view/game_web_view_mobile.dart) |

### Triệu chứng

Khi user mở game → đưa app vào background khoảng 30 giây đến 1 phút → mở lại
app → màn hình game hiển thị **error overlay** với thông báo lỗi:

```
code: -6
description: net::ERR_CONNECTION_ABORTED
errorType: WebResourceErrorType.connect
isForMainFrame: true
```

### Nguyên nhân gốc (Root Cause)

Android **tự động cắt kết nối mạng** của WebView khi app ở background nhằm tiết
kiệm tài nguyên và pin. Khi user quay lại app, WebView cố gắng tiếp tục load
tài nguyên nhưng tất cả các TCP connection đã bị hệ điều hành hủy →
`net::ERR_CONNECTION_ABORTED`.

Flow lỗi cũ:

```
App Background → Android kills WebView TCP connections
       ↓
App Resume → WebView reports ERR_CONNECTION_ABORTED (-6)
       ↓
_onWebResourceError() → gọi widget.onError?.call()
       ↓
GamePlayerNotifier.handleError() → set errorMessage
       ↓
_ErrorOverlay hiển thị lỗi ← User phải nhấn Retry thủ công ❌
```

### Giải pháp: Auto-Retry Transient Errors

Thêm cơ chế **auto-retry** trong `_onWebResourceError()` của
`game_web_view_mobile.dart`. Khi phát hiện lỗi thuộc nhóm **transient
connection error**, WebView sẽ tự động reload thay vì báo lỗi cho user.

#### Transient Error Codes được xử lý

| Code | Tên | Khi nào xảy ra |
|------|-----|-----------------|
| `-6` | `ERR_CONNECTION_ABORTED` | OS cắt connection khi app ở background |
| `-2` | `ERR_INTERNET_DISCONNECTED` | Mất mạng tạm thời |
| `-7` | `ERR_CONNECTION_TIMED_OUT` | Timeout sau resume |
| `-8` | `ERR_CONNECTION_RESET` | Connection bị reset bởi peer |
| `-15` | `ERR_SOCKET_NOT_CONNECTED` | Socket bị OS thu hồi |

#### Flow mới

```
App Resume → WebView reports transient error (-6, -2, -7, -8, -15)
       ↓
_onWebResourceError() kiểm tra:
  ├── retryCount < maxRetries (2)?
  │    ├── YES → log warning, chờ 500ms, gọi _controller.reload()
  │    │         Reset _hasNotifiedLoadStart/Stop cho chu kỳ load mới
  │    └── NO  → báo lỗi cho notifier (hiện Error Overlay)
  │
  └── Khi load thành công (_onPageFinished):
       → reset retryCount = 0 (sẵn sàng cho lần background tiếp theo)
```

#### Code reference

```dart
// game_web_view_mobile.dart

// Retry counter & max
int _transientRetryCount = 0;
static const _kMaxTransientRetries = 2;

// In _onWebResourceError:
const transientErrorCodes = {-6, -2, -7, -8, -15};

if (transientErrorCodes.contains(error.errorCode) &&
    _transientRetryCount < _kMaxTransientRetries) {
  _transientRetryCount++;
  Future<void>.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _controller.reload();
    }
  });
  return; // Don't report error to notifier
}

// In _onPageFinished:
_transientRetryCount = 0; // Reset for next background cycle
```

### Cách kiểm tra

1. Mở app trên thiết bị Android thật
2. Vào bất kỳ game nào (ví dụ: Sexy provider)
3. Đợi game load hoàn tất
4. Nhấn Home để đưa app vào background
5. Đợi 30 giây – 1 phút
6. Mở lại app

**Kết quả mong đợi:**
- Log hiện: `⚠️ Transient connection error (code: -6, attempt: 1/2). Auto-reloading WebView...`
- WebView tự reload thành công, **không hiện Error Overlay**
- Game tiếp tục hoạt động bình thường

**Kết quả nếu retry thất bại (sau 2 lần):**
- Log hiện error chi tiết
- Error Overlay hiển thị với nút Retry cho user

---

## 2. Flutter Web: WebView bị unmount khi xoay màn hình

| Mục | Chi tiết |
|-----|----------|
| **Platform** | Flutter Web (Chrome) |
| **Trạng thái** | ✅ Đã fix |
| **File liên quan** | [`game_player_scaffold.dart`](../widget/game_player_scaffold.dart), [`web/game_web_view_web.dart`](../web_view/src/web/game_web_view_web.dart) |

### Triệu chứng

Khi user xoay thiết bị (hoặc resize cửa sổ trên desktop), iframe WebView bị
**destroy và không thể tái tạo**. Game dừng lại hoàn toàn.

### Nguyên nhân gốc

`GamePlayerScaffold` trước đây dùng `OrientationBuilder` để switch giữa hai
layout khác nhau (Portrait: `Column`, Landscape: `Row`). Khi orientation thay
đổi, Flutter rebuild widget tree với widget type khác → `HtmlElementView`
(iframe) bị unmount → iframe bị hủy.

### Giải pháp

Thay thế `OrientationBuilder` + `Column`/`Row` bằng **`Stack` +
`AnimatedPositioned`** trong `_AdaptiveGameLayout`. Widget tree giữ nguyên
cấu trúc bất kể orientation — chỉ thay đổi vị trí (position) của các thành
phần:

- **Portrait**: Top bar (back button) + content bên dưới
- **Landscape**: Left sidebar + content + Right sidebar

Vì widget type không thay đổi → iframe không bị unmount → game tiếp tục chạy.

---

## 3. iPadOS: WebView render sai layout khi xoay màn hình

| Mục | Chi tiết |
|-----|----------|
| **Platform** | iPadOS 16+ (Stage Manager, Split Screen) |
| **Trạng thái** | ✅ Đã fix |
| **File liên quan** | [`game_player_notifier.dart`](../game_player_notifier.dart) |

### Triệu chứng

Trên iPad với Stage Manager hoặc Split Screen, khi chuyển từ Portrait sang
Landscape, WebView render layout Mobile thay vì Tablet.

### Nguyên nhân gốc

WebView được khởi tạo **quá nhanh** trong khi iOS đang thực hiện animation xoay
màn hình. WebView capture kích thước window **trước khi** rotation hoàn tất →
nhận được portrait bounds → render layout mobile.

### Giải pháp

Thêm delay `400ms` sau khi lock orientation trước khi set
`isOrientationReady = true` trong `GamePlayerNotifier.initializePlayer()`:

```dart
if (orientation != GameOrientation.portrait) {
  await Future<void>.delayed(const Duration(milliseconds: 400));
}
```

Delay này cho phép native rotation animation hoàn tất trước khi WebView đọc
kích thước window, đảm bảo nhận đúng landscape bounds.

---

## 4. iOS Safari: App crash/reset khi load game trong iframe

| Mục | Chi tiết |
|-----|----------|
| **Platform** | iOS Safari mobile (Flutter Web) |
| **Trạng thái** | ✅ Đã fix bằng open-in-new-tab strategy |
| **Provider bị ảnh hưởng** | `amb-vn`, `lcevo`, `vivo`, `via-casino-vn` |
| **File liên quan** | [`game_block.dart`](../../../../core/services/repositories/game_repository/src/models/game_block.dart), [`game_player_screen.dart`](../game_player_screen.dart), [`web/game_web_view_web.dart`](../web_view/src/web/game_web_view_web.dart), [`index.html`](../../../../../web/index.html) |

### Root cause: WebContent Process Sharing

Khi game load trong **iframe**, Flutter CanvasKit và game **chia sẻ cùng 1 WebContent process**.
Các provider nặng dùng WebGL + live video + WebSocket → tổng RAM/GPU vượt giới hạn iOS (~1GB) → Safari kill process → app reset.

Khi game mở ở **tab mới**, mỗi tab có **process riêng** với memory/GPU riêng → không bị crash.

### Giải pháp: Open-in-new-tab (ĐÃ IMPLEMENT)

- Thêm `openInNewTabOnIOSSafariWeb: true` vào `_providerOverrides` trong `game_block.dart` cho các provider nặng
- Khi `kIsWeb && isIOSSafariWeb && game.openInNewTabOnIOSSafariWeb`, `_WebViewLayer` hiển thị `NewTabGamePlaceholder` thay vì iframe
- Game tự động mở ở tab mới bằng `url_launcher`
- UI hiện placeholder "Game đang chơi ở tab khác" + nút "Mở lại game" + "Quay lại"

> **Thiết kế của `openInNewTabOnIOSSafariWeb`:**
> Flag này **chỉ có tác dụng trên iOS Safari Web**. Tên được đặt rõ ràng để tránh nhầm lẫn
> với các tính năng "open in new tab" mang tính chất khác.
> Trên Android, Chrome, PC — game vẫn load bình thường trong iframe.

### Provider đang áp dụng flag

| Provider ID | Lý do |
|-------------|-------|
| `amb-vn` | WebGL + live FLV video + 3 WebSocket (~1GB RAM peak) |
| `lcevo` | WebGL + live video (Evolution Gaming) |
| `vivo` | Heavy game engine |
| `via-casino-vn` | + `forceLandscapeViewportOnIpad: true` (xem Issue 5) |

### Triệu chứng

Khi user mở game trên iOS Safari → game bắt đầu load → khi game gần load xong
(WebSocket connected, game initialized) → toàn bộ app bị **reset về màn hình Login**.
Safari hiện dialog hỏi có muốn report crash hay không.

### Nguyên nhân đã điều tra

#### ❌ Cause 1: Top-level navigation hijack (ĐÃ THÊM SANDBOX — chưa fix)

Iframe game không có `sandbox` attribute. JavaScript trong iframe có thể truy
cập `window.top.location` và redirect toàn bộ Flutter app đi nơi khác.

**Đã thêm `sandbox` attribute** nhưng vấn đề vẫn xảy ra → không phải nguyên nhân chính.

#### 🔴 Cause 2: `index.html` Layout Thrashing (ĐÃ FIX)

```javascript
// TRƯỚC KHI FIX:
setInterval(hideLoading, 50);  // 20 lần/giây, FOREVER
MutationObserver trên toàn bộ body  // trigger mỗi DOM change
```

→ **Layout thrashing**: 20 force-layout/giây × tất cả element = CPU cực nặng → crash.

#### 🟡 Cause 3: Safari WebContent process crash (memory/GPU)

Game live casino dùng WebGL + FLV video + 3 WebSocket → vượt giới hạn RAM iOS (~1GB) → process crash.

### Giải pháp đã áp dụng

#### Fix 1: Iframe Sandbox + Feature Policy

```dart
_iframe!.setAttribute(
  'sandbox',
  'allow-scripts allow-same-origin allow-forms allow-popups '
      'allow-presentation allow-modals allow-popups-to-escape-sandbox',
);
_iframe!.setAttribute(
  'allow',
  'autoplay; fullscreen; encrypted-media; web-share',
);
```

#### Fix 2: Gỡ bỏ Layout Thrashing trong `index.html`

```diff
-setInterval(hideLoading, 50);  // RUN FOREVER → crash
+setTimeout(hideLoading, 100);
+setTimeout(hideLoading, 500);
+setTimeout(hideLoading, 1000);
+setTimeout(hideLoading, 2000);
+setTimeout(function() { observer.disconnect(); }, 3000);
```

### Sandbox permissions giải thích

| Permission | Mục đích | Có/Không |
|------------|----------|----------|
| `allow-scripts` | Game JS execution | ✅ Có |
| `allow-same-origin` | Cookies, WebSocket, localStorage | ✅ Có |
| `allow-forms` | Form submit trong game | ✅ Có |
| `allow-popups` | Popup cho payment/support | ✅ Có |
| `allow-presentation` | Fullscreen API | ✅ Có |
| `allow-modals` | alert/confirm dialogs | ✅ Có |
| `allow-popups-to-escape-sandbox` | Popup hoạt động bình thường | ✅ Có |
| `allow-top-navigation` | **Redirect parent window** | ❌ **BỊ CHẶN** |
| `allow-top-navigation-by-user-activation` | **Redirect khi user click** | ❌ **BỊ CHẶN** |

### Cách kiểm tra

1. Mở app trên iOS Safari mobile
2. Vào game của provider được cấu hình `openInNewTabOnIOSSafariWeb: true`
3. Game phải tự mở tab mới + hiện placeholder trong Flutter app

**Kết quả mong đợi:**
- Flutter app hiện `NewTabGamePlaceholder` (không crash)
- Game load ở tab Safari mới, không bị reset

---

## 5. iPad: Game hiển thị Mobile layout dù đang ở Landscape

| Mục | Chi tiết |
|-----|----------|
| **Platform** | iPad / iPadOS (native mobile — không phải Flutter Web) |
| **Trạng thái** | ✅ Đã fix |
| **Provider bị ảnh hưởng** | `via-casino-vn` và các provider có `forceLandscapeViewportOnIpad: true` |
| **File liên quan** | [`inapp_runner_ctrl.dart`](../../../../../packages/game_engine/lib/src/provider_live_runner/inapp/inapp_runner_ctrl.dart), [`game_block.dart`](../../../../core/services/repositories/game_repository/src/models/game_block.dart), [`game_extensions.dart`](../../game_extensions.dart) |

### Triệu chứng

Trên iPad, khi mở game live casino (ví dụ: VIA Casino), game **luôn hiển thị
layout Mobile** (giao diện thu hẹp, thiếu bảng cược full, v.v.) dù thiết bị
đang ở Landscape và app đã lock đúng `landscapeRight`.

### Nguyên nhân gốc

iOS/iPadOS có một quirk quan trọng: **`screen.width` và `screen.height` không
đổi theo chiều xoay của thiết bị** — chúng luôn trả về kích thước theo hướng
"boot orientation" (thường là portrait). Game engine lại phụ thuộc vào
`window.matchMedia('(orientation: landscape)')`, trong khi API này dựa trên
`window.innerWidth/innerHeight` (kích thước viewport thực tế).

**Vấn đề:** Trong giai đoạn khởi tạo WebView, `innerWidth` và `innerHeight` đều
là `0`. Khi đó `matchMedia('(orientation: landscape)')` → `0 > 0` → `false`
→ game engine khởi tạo layout Mobile và **không thay đổi sau đó**.

```
WebView created → innerWidth=0, innerHeight=0
       ↓
matchMedia('orientation: landscape') → 0 > 0 → FALSE
       ↓
Game engine: "Đây là portrait/mobile device"
       ↓
Game khởi tạo layout Mobile → KHÔNG tự thay đổi sau đó ❌
```

### Các giải pháp đã thử (thất bại)

| Phương pháp | Kết quả |
|-------------|---------|
| Patch `screen.width/height` | JS engine nhận đúng, nhưng `matchMedia` vẫn sai |
| Patch `screen.orientation.type` | Không đủ — game engine ưu tiên `matchMedia` |
| Delay WebView load | Tỉ lệ thành công ~85%, vẫn thất bại khoảng 1-2 lần/10 |

### Giải pháp: Patch `window.matchMedia` (ĐÃ IMPLEMENT)

**File:** `packages/game_engine/lib/src/provider_live_runner/inapp/inapp_runner_ctrl.dart`

Khi `forceLandscapeViewport = true`, inject script để intercept toàn bộ
`window.matchMedia` API. Các query về `orientation:landscape/portrait` được trả
về giá trị đúng **ngay từ đầu**, trước khi game engine khởi tạo.

```javascript
window.matchMedia = function(query) {
  const real = origMatchMedia(query);
  const isLandscapeQuery = query.includes('orientation') &&
                           query.includes('landscape');
  const isPortraitQuery  = query.includes('orientation') &&
                           query.includes('portrait');

  if (!isLandscapeQuery && !isPortraitQuery) return real; // pass-through

  const fake = Object.create(real);
  Object.defineProperty(fake, 'matches', {
    get: () => isLandscapeQuery, // landscape → true, portrait → false
  });
  // Support both modern addEventListener and legacy addListener
  fake.addEventListener = (type, listener) => {
    if (type === 'change') listener(fake); // fire immediately
  };
  fake.addListener = (listener) => listener(fake);
  return fake;
};
```

**Đặc điểm của patch:**
- **Idempotent**: kiểm tra `window.__matchMediaPatched` để không patch 2 lần
- **Targeted**: chỉ override orientation queries, các query khác (dark mode, width) pass-through
- **Zero side-effects**: dùng `Object.create(real)` để kế thừa toàn bộ properties gốc

### Kiến trúc sau khi fix

#### 1. Cấu hình trong `GameBlock`

```dart
// game_block.dart — _providerOverrides
'via-casino-vn': _ProviderOverride(
  tabletOrientation: [GameOrientation.landscapeRight],
  forceLandscapeViewportOnIpad: true,  // Kích hoạt JS polyfill trên iPad
  openInNewTabOnIOSSafariWeb: true,    // Mở tab mới trên iOS Safari Web
),
```

Trường `forceLandscapeViewportOnIpad` chỉ có tác dụng khi cả 2 điều kiện thỏa:
1. Thiết bị là **tablet** (`shortestSide >= 600`)
2. **Tất cả** `tabletOrientation` đều là landscape

#### 2. Logic kiểm tra tập trung tại `GameBlockX`

```dart
// game_extensions.dart
bool shouldForceLandscapeViewport(BuildContext context) {
  if (!forceLandscapeViewportOnIpad) return false;

  final shortestSide = MediaQuery.sizeOf(context).shortestSide;
  if (shortestSide < 600) return false; // Only for tablets

  // Only inject when ALL tablet orientations are landscape.
  return tabletOrientation.every((o) => o.isLandscape);
}
```

> **Tại sao tập trung ở đây?**
> Trước đây, logic này nằm inline trong `GamePlayerScreen` (UI layer).
> Đã move vào `GameBlockX` extension để: (1) dễ test, (2) nhất quán khi
> nhiều widget cần truy vấn giá trị này.

#### 3. Sử dụng trong UI

```dart
// game_player_screen.dart
PLRunner(
  forceLandscapeViewport: widget.game.shouldForceLandscapeViewport(context),
)
```

### Debug

Kiểm tra log `[PLRunner:DIAG]` trong Flutter console:

```json
{
  "screen_wh": "1210x834",
  "matchMedia_landscape": true,   // ← PHẢI là true khi đang landscape
  "matchMedia_portrait": false,
  ...
}
```

- `matchMedia_landscape: false` → polyfill chưa chạy hoặc bị skip
- Kiểm tra `shouldForceLandscapeViewport` có trả về `true`
- Kiểm tra log `[PLRunner] _applyAllInjections — forceLandscape=true`

### Cách kiểm tra

1. Mở app trên **iPad thật** (không phải Simulator)
2. Vào game VIA Casino (Lotto Baccarat hoặc tương tự)
3. App lock landscape → game load

**Kết quả mong đợi:**
- Game hiển thị **layout Tablet Landscape** (bảng cược full, UI rộng)
- Log: `matchMedia_landscape: true`

---

## Kiến trúc tổng quan Game Player

```
GamePlayerScreen (ConsumerStatefulWidget)
├── Material
│   └── PopScope (blocks back while loading)
│       └── _GameBackground (thumbnail + gradient)
│           └── Stack
│               ├── Positioned.fill
│               │   └── GamePlayerScaffold
│               │       └── _AdaptiveGameLayout (Stack + AnimatedPositioned)
│               │           ├── Top Bar / Left Sidebar (back button)
│               │           ├── AnimatedPositioned (content area)
│               │           │   └── _WebViewLayer
│               │           │       └── _AnimatedWebView (fade-in)
│               │           │           └── GameWebView (platform-specific)
│               │           └── Right Sidebar (landscape only)
│               ├── _LoadingOverlay (shimmer + touch blocker)
│               └── _ErrorOverlay (error + retry button)
│
├── GamePlayerNotifier (StateNotifier)
│   ├── initializePlayer() → setup orientation + fetch URL
│   ├── loadGameUrl() → API call
│   ├── onLoadStart() / onLoadStop() → WebView lifecycle
│   ├── handleError() → error state
│   └── retry() → reset + reload
│
└── GameWebView (conditional import)
    ├── game_web_view_mobile.dart → webview_flutter (Android/iOS)
    │   └── Auto-retry transient errors on background resume
    └── web/game_web_view_web.dart → HtmlElementView (Flutter Web)
        ├── iframe sandbox (prevent top-navigation hijack)
        └── iframe stabilization for orientation changes
```

---

*Cập nhật lần cuối: 2026-04-02*
