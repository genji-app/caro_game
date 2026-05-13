# Tài liệu Thiết kế: Game Viewport Mode

**Package:** `system_ui_manager`  
**Phạm vi:** Flutter App (Android, iOS) + Flutter Web (Chrome, Safari)  
**Phiên bản:** 1.1  
**Trạng thái:** RFC — Request For Comments  
**Cập nhật:** Tháng 4, 2026

---

## 1. Tổng quan

Tài liệu này định nghĩa yêu cầu và chiến lược kỹ thuật để đưa game (Cocos Creator qua WebView) vào trạng thái **Game Viewport Mode** trên từng nền tảng mà ứng dụng hỗ trợ.

### 1.1. Mục tiêu nghiệp vụ

> Khi người dùng bắt đầu phiên chơi game, hệ thống phải đảm bảo game luôn hiển thị trong **viewport đủ điều kiện** — có diện tích hiển thị tối đa, không bị che khuất bởi system chrome của nền tảng. Nếu điều kiện chưa được đáp ứng, hệ thống phải **chặn game** và hướng dẫn người dùng thực hiện thao tác để đạt trạng thái đó.

### 1.2. Lý do không dùng chung thuật ngữ "Fullscreen"

Mỗi nền tảng có cơ chế kỹ thuật khác nhau để đạt được cùng mục tiêu. Dùng chung một thuật ngữ "fullscreen" cho tất cả là không chính xác và dễ gây nhầm lẫn khi triển khai. Tài liệu này dùng thuật ngữ thống nhất là **Game Viewport Mode**.

---

## 2. Định nghĩa thuật ngữ

| Thuật ngữ | Định nghĩa |
|---|---|
| **Game Viewport Mode** | Tên business tổng quát. Trạng thái viewport dành cho game là tối đa theo khả năng của nền tảng, không bị che khuất bởi UI của hệ điều hành hoặc trình duyệt. |
| **Native Immersive Mode** | Cơ chế trên Flutter native app (Android/iOS). Sử dụng `SystemChrome` để ẩn status bar và navigation bar của hệ điều hành. |
| **Browser Fullscreen Mode** | Cơ chế trên trình duyệt hỗ trợ Fullscreen API chuẩn (Chrome, Firefox, Edge, Safari Desktop/iPad). Gọi `requestFullscreen()` để đưa trình duyệt vào chế độ toàn màn hình. |
| **Minimal UI Mode** | Cơ chế riêng cho Safari trên iPhone. Không dùng Fullscreen API. Yêu cầu người dùng cuộn trang để Safari tự thu gọn Address Bar và Navigation Toolbar. |
| **Game Viewport Gate** | Overlay chặn game, yêu cầu người dùng thực hiện thao tác để đạt Game Viewport Mode. Mỗi nền tảng có Gate với nội dung hướng dẫn khác nhau. |
| **Effective Viewport Height** | Chiều cao vùng hiển thị thực tế của game sau khi loại trừ system chrome. Đây là giá trị Cocos dùng để tính toán layout và canvas size. |
| **UI Trồi** | Hiện tượng Safari iPhone bung Address Bar và Navigation Toolbar ra trong khi đang chơi game, làm giảm `innerHeight` đột ngột. |

---

## 3. Nền tảng mục tiêu

### 3.1. Bảng tổng hợp

| Nền tảng | Cơ chế | Trigger | Chặn game nếu chưa đạt? |
|---|---|---|---|
| Flutter App — Android | Native Immersive (`SystemChrome.immersiveSticky`) | Tự động | Không |
| Flutter App — iOS | Native Immersive (`SystemChrome`) | Tự động | Không |
| Chrome Mobile (Android) | Browser Fullscreen API (`requestFullscreen()`) | User tap vào Gate | Có |
| Safari iPhone | Minimal UI Mode (Scroll-to-Hide) | User swipe lên | Có |
| Safari iPad | Browser Fullscreen API (ưu tiên), fallback Minimal UI | User tap vào Gate | Có |
| Safari macOS Desktop | Browser Fullscreen API | User tap vào Gate | Có |
| Chrome / Firefox Desktop | Browser Fullscreen API | User tap vào Gate | Có |
| PWA Mode (bất kỳ nền tảng nào) | Tự động fullscreen do manifest | Không cần thao tác | Không |

### 3.2. Chi tiết theo từng nền tảng

#### Flutter App — Android

Sử dụng `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` để ẩn hoàn toàn status bar và navigation bar. Khi user vuốt từ mép màn hình, hệ thống hiện lại tạm thời rồi tự ẩn sau vài giây — đây là hành vi mặc định của `immersiveSticky`, không cần xử lý thêm.

**Lưu ý kỹ thuật:**
- Android có thể reset SystemUI khi app về background rồi resume (nhận cuộc gọi, mở notification). Bắt buộc phải re-apply trong `AppLifecycleState.resumed`.
- Android 12+ với gesture navigation cần kiểm thử thực tế trên thiết bị.
- Màn hình có notch/cutout: cần thêm `android:windowLayoutInDisplayCutoutMode = shortEdges` trong `styles.xml`.

#### Flutter App — iOS

Sử dụng `SystemChrome` để ẩn status bar. iOS không có navigation bar kiểu Android nên chỉ cần xử lý status bar. Home Indicator (vạch ngang dưới cùng) không thể ẩn trên môi trường web hoặc Flutter web — đây là giới hạn của Apple.

**Lưu ý kỹ thuật:**
- `SafeArea` widget cần được xem xét tắt hoặc override cho màn hình game để tận dụng tối đa diện tích.
- Màn hình có notch (Dynamic Island, TrueDepth Camera): cần kiểm thử layout game không bị che.

#### Chrome Mobile — Android

Chrome Android hỗ trợ đầy đủ Fullscreen API. Tuy nhiên, `requestFullscreen()` **bắt buộc phải được gọi từ trong một user gesture** (sự kiện tap/click). Gọi tự động khi navigate vào route game sẽ bị browser từ chối mà không throw lỗi rõ ràng.

**Luồng xử lý:**
1. Vào game screen → Kiểm tra `document.fullscreenElement == null` → Hiện Gate.
2. User nhấn vào Gate → Trong handler của sự kiện click → Gọi `requestFullscreen()`.
3. Thành công → Lắng nghe `fullscreenchange` event → Ẩn Gate.
4. Trong game, user nhấn Escape hoặc Back → `fullscreenchange` event bắn, `document.fullscreenElement` trở về null → Hiện Gate lại.

#### Safari iPhone

Safari iPhone không hỗ trợ Fullscreen API cho phần tử div/canvas. Apple giới hạn API này vì lý do UX và bảo mật. Cơ chế duy nhất là **Minimal UI Mode**: Safari tự thu gọn Address Bar và Navigation Toolbar khi người dùng cuộn trang xuống, làm tăng `window.innerHeight` lên mức tối đa.

**Luồng xử lý:**

```
[Vào game screen]
       │
       ▼
Kiểm tra: window.innerHeight == MAX_HEIGHT?
       │
  Chưa đạt ──────────────────────────► Hiện Gate "Vuốt lên để chơi"
       │                                       │
       │                                 Mở body scroll (height: 150vh)
       │                                       │
       │                                 User vuốt lên
       │                                       │
       │                               resize event bắn
       │                                       │
       │                         innerHeight tăng đến MAX?
       │                               │ Có
       ▼                               ▼
  Đã đạt ◄─────────────── Khóa scroll (overflow: hidden)
       │                  Ẩn Gate
       │                  Thông báo Cocos resize canvas
       │
  Đang chơi game
       │
  resize event bắn
       │
  innerHeight GIẢM + innerWidth KHÔNG ĐỔI?
       │ Có (UI trồi)
       ▼
  Tạm dừng Cocos (cc.game.pause())
  Hiện Gate "Vuốt lên để tiếp tục"
  Mở lại scroll
```

**Phân biệt UI trồi vs. Xoay màn hình:**
- UI trồi: `innerWidth` giữ nguyên, `innerHeight` giảm.
- Xoay màn hình: Cả `innerWidth` và `innerHeight` đều thay đổi → KHÔNG kích hoạt Gate, cập nhật lại MAX_HEIGHT.

#### Safari iPad

iPad hỗ trợ Fullscreen API tốt hơn iPhone. Áp dụng chiến lược ưu tiên Fullscreen API, nếu thất bại (API trả về lỗi hoặc không available) thì fallback về Minimal UI tương tự iPhone.

#### Safari macOS / Desktop Browsers

Hỗ trợ Fullscreen API đầy đủ. Luồng giống Chrome Mobile nhưng không cần xử lý Minimal UI. Nếu user thoát fullscreen giữa chừng, hiện Gate và cho phép vào fullscreen lại.

---

## 4. Phát hiện nền tảng (Platform Detection)

Service cần xác định chính xác nền tảng để áp dụng đúng cơ chế:

```dart
enum GameViewportPlatform {
  nativeAndroid,     // Flutter app, Android OS
  nativeIOS,         // Flutter app, iOS
  webSafariIPhone,   // Safari trên iPhone — Minimal UI flow
  webSafariIPad,     // Safari trên iPad — Fullscreen API ưu tiên
  webSafariDesktop,  // Safari trên macOS
  webSafariPWA,      // Bất kỳ nền tảng nào, đang chạy ở PWA/standalone
  webChrome,         // Chrome, Edge, Firefox (mobile + desktop)
  webOther,          // Các trình duyệt khác
}
```

**Logic phát hiện (ưu tiên từ trên xuống dưới):**
1. `kIsWeb == false` → Native. Kiểm tra `Platform.isAndroid` / `Platform.isIOS`.
2. `window.matchMedia('(display-mode: standalone)').matches` → `webSafariPWA`.
3. UserAgent chứa `iPhone` + `Safari` (không `Chrome`) → `webSafariIPhone`.
4. UserAgent chứa `iPad` + `Safari` (không `Chrome`) → `webSafariIPad`.
5. UserAgent chứa `Macintosh` + `Safari` (không `Chrome`) → `webSafariDesktop`.
6. Còn lại → `webChrome` / `webOther`.

---

## 5. Game Viewport Gate — Thiết kế Overlay

### 5.1. Yêu cầu chung

- Che toàn bộ viewport, nền tối (opacity >= 80%).
- Hiển thị rõ: icon hướng dẫn thao tác + text + lý do ngắn gọn.
- **Không có nút "Bỏ qua"** — Gate là bắt buộc, không có đường tắt.
- Tự động ẩn ngay khi phát hiện đã đạt Game Viewport Mode.
- Animation icon để thu hút sự chú ý (swipe up arrow pulse, tap ripple...).

### 5.2. Nội dung Gate theo nền tảng

| Nền tảng | Icon | Text chính | Text phụ |
|---|---|---|---|
| Chrome Mobile (Android) | Tap / Expand icon | "Nhấn để toàn màn hình" | "Để có trải nghiệm chơi game tốt nhất" |
| Safari iPhone (lần đầu) | Swipe up arrow (animation) | "Vuốt lên để bắt đầu chơi" | "Thu gọn thanh trình duyệt để chơi game" |
| Safari iPhone (giữa game) | Swipe up arrow | "Game tạm dừng. Vuốt lên để tiếp tục" | — |
| Safari iPad | Tap / Expand icon | "Nhấn để toàn màn hình" | "Để có trải nghiệm chơi game tốt nhất" |
| Safari / Chrome Desktop | Click / Expand icon | "Nhấn để toàn màn hình" | "Hoặc nhấn phím F11" |

### 5.3. Gate mid-game (Khi UI trồi lại)

Gate xuất hiện giữa game cần xử lý thêm:
- **Tạm dừng Cocos game ngay lập tức** qua JS Interop: `cc.game.pause()` và mute audio.
- **Sau khi đạt lại Game Viewport Mode:** Resume Cocos (`cc.game.resume()`) và ép resize canvas (`cc.view.resizeWithBrowserSize(true)`).

---

## 6. Tương tác với Cocos Creator (JS Interop)

Khi Gate xuất hiện hoặc ẩn, cần giao tiếp với game Cocos đang chạy trong WebView:

### 6.1. Từ Flutter → Cocos (qua WebViewController.evaluateJavascript)

```javascript
// Tạm dừng game khi Gate xuất hiện
cc.game.pause();
cc.audioEngine.pauseAll();

// Tiếp tục game khi Gate ẩn
cc.game.resume();
cc.audioEngine.resumeAll();

// Ép Cocos tính lại canvas size sau khi viewport thay đổi
cc.view.resizeWithBrowserSize(true);
cc.view.setDesignResolutionSize(window.innerWidth, window.innerHeight, cc.ResolutionPolicy.EXACT_FIT);
```

### 6.2. Từ Cocos → Flutter (qua JS message / URL scheme)

Nếu Cocos cần báo cho Flutter biết trạng thái game (ví dụ: game đang ở màn hình loading, đang ở trong game play, đang ở menu), Flutter có thể nhận thông điệp để quyết định có hiện Gate hay không khi `innerHeight` thay đổi trong một số trường hợp đặc biệt.

---

## 7. Kiến trúc Module

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│                                                             │
│   GameViewportGateWidget                                    │
│   ├── Hiện/Ẩn Overlay theo state                           │
│   ├── Nội dung Gate tùy theo GameViewportPlatform          │
│   └── Gọi JS Interop khi state thay đổi                    │
│                                                             │
│   GameViewportController                                    │
│   ├── Lắng nghe MinimalUIController (Safari iPhone)        │
│   ├── Lắng nghe Fullscreen API events (Chrome/Safari)      │
│   └── Emit state stream cho Widget                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
│                                                             │
│   SystemUIService (abstract)                                │
│   ├── SystemUIServiceIO (Android/iOS)                      │
│   └── SystemUIServiceWeb (Web Fullscreen API)              │
│                                                             │
│   MinimalUIController (Safari iPhone only)                 │
│   ├── Quản lý body scroll trick                            │
│   ├── Lắng nghe resize + visualViewport events             │
│   ├── Phân biệt: UI trồi / xoay màn hình / bàn phím ảo   │
│   └── Emit: minimalUIAchieved / minimalUILost stream       │
│                                                             │
│   GameViewportPlatformDetector                             │
│   └── Detect: GameViewportPlatform enum                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Platform API Layer                       │
│   SystemChrome    │   Fullscreen API   │   Scroll / DOM    │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Edge Cases và Xử lý

### 8.1. Xoay màn hình trong khi chơi

Khi user xoay thiết bị, `innerWidth` và `innerHeight` đều thay đổi đột ngột.

**Quy tắc xử lý:** Nếu `innerWidth` thay đổi cùng lúc với `innerHeight` → Là orientation change. KHÔNG kích hoạt Gate. Cập nhật lại `MAX_HEIGHT` reference cho hướng mới rồi kiểm tra lại trạng thái Minimal UI.

### 8.2. Bàn phím ảo (Virtual Keyboard)

Khi game có ô nhập liệu (chat, tên nhân vật), bàn phím ảo bật lên làm giảm `innerHeight` tương tự như UI trồi.

**Quy tắc xử lý:** Kiểm tra `document.activeElement`. Nếu là `input`, `textarea`, hoặc `select` → Bỏ qua sự kiện resize. Chỉ kiểm tra khi không có phần tử input nào đang focused. Nên kết hợp `window.visualViewport` API để phân biệt chính xác hơn.

### 8.3. PWA Mode (Add to Home Screen)

Khi app được cài về màn hình chính dạng PWA với `display: fullscreen` hoặc `standalone` trong `manifest.json`, toàn bộ browser chrome biến mất.

**Quy tắc xử lý:** Kiểm tra `window.matchMedia('(display-mode: standalone)').matches` khi khởi tạo. Nếu đúng, tắt hoàn toàn hệ thống Gate và MinimalUIController.

### 8.4. Cử chỉ hệ thống iOS từ mép màn hình

iOS có gesture hệ thống từ mép trên (mở Notification Center) và mép dưới (mở App Switcher). Đây là gesture của OS, không thể chặn từ phía web app hoặc Flutter app.

**Chấp nhận hạn chế:** Khi user vô tình trigger, Gate tự hiển thị. User vuốt lên để tiếp tục. Team thiết kế game Cocos cần tránh đặt nút tương tác quan trọng gần mép màn hình (khuyến nghị safe margin: 20px trên, 40px dưới).

### 8.5. iOS cũ (< iOS 13)

`window.visualViewport` API không tồn tại. Phân biệt bàn phím ảo vs. UI trồi sẽ kém chính xác hơn.

**Chiến lược:** Fallback về chỉ dùng `window.resize`. Chấp nhận khả năng false positive. Không cam kết hỗ trợ đầy đủ cho iOS < 13.

---

## 9. Acceptance Criteria

### Flutter App Android

- [ ] Vào game screen → `immersiveSticky` áp dụng tự động, không cần thao tác của user.
- [ ] Status bar và navigation bar ẩn hoàn toàn trong game.
- [ ] App về background rồi resume → immersive mode được re-apply tự động.
- [ ] Thoát game → Status bar và navigation bar hiển thị trở lại bình thường.

### Flutter App iOS

- [ ] Vào game screen → Status bar ẩn tự động.
- [ ] Thoát game → Status bar hiển thị trở lại.

### Chrome Mobile (Android)

- [ ] Vào game screen → Gate "Nhấn để toàn màn hình" xuất hiện.
- [ ] User nhấn Gate → Trình duyệt vào fullscreen, Gate ẩn.
- [ ] User nhấn Back/Escape thoát fullscreen → Gate hiện lại.
- [ ] Game không tương tác được khi Gate đang hiển thị.

### Safari iPhone

- [ ] Vào game screen → Gate "Vuốt lên để chơi" xuất hiện.
- [ ] User vuốt lên đạt Minimal UI → Gate tự động ẩn.
- [ ] Safari bar trồi ra trong khi chơi → Game tạm dừng, Gate hiện lại.
- [ ] User vuốt lên lại → Gate ẩn, game tiếp tục từ chỗ đã dừng.
- [ ] Xoay màn hình → Gate KHÔNG hiện nhầm, game resize và tiếp tục.
- [ ] Bàn phím ảo mở → Gate KHÔNG hiện nhầm.
- [ ] App đang chạy ở PWA mode → Gate KHÔNG bao giờ hiện.

### Chung (mọi nền tảng web)

- [ ] Gate không có cách nào bypass để vào chơi mà không đạt Game Viewport Mode.
- [ ] Thoát game → Mọi fullscreen / Minimal UI state được cleanup.
- [ ] Reload trang / navigate back → Không để lại state rác.

---

## 10. Hạn chế đã biết (Không thể thay đổi)

| Hạn chế | Nguyên nhân | Ảnh hưởng |
|---|---|---|
| Safari iPhone không thể fullscreen 100% | Apple giới hạn Fullscreen API cho canvas/div trên iPhone | Vẫn còn thanh status nhỏ trên cùng và Home Indicator dưới cùng |
| iOS Home Indicator không ẩn được trên web | Giới hạn WebKit trên iOS | Cocos canvas không thể chiếm vùng Home Indicator |
| Cử chỉ mép màn hình iOS không chặn được | OS-level gesture của iOS | Vô tình trigger sẽ làm Gate hiện lại, gián đoạn game |
| Fullscreen API yêu cầu user gesture | Chính sách bảo mật của tất cả browser hiện đại | Phải qua Gate, không thể tự động kích hoạt |
| Android reset SystemUI sau background | Hành vi OS Android | Phải re-apply trong `AppLifecycleState.resumed` |
| Safari iPhone Minimal UI không hoạt động ổn định qua lớp Native Overlay | Browser (đặc biệt CSS của iOS 15+) ngăn cản hoặc nhận diện sai thao tác cuộn nếu DOM bị can thiệp quá sâu bởi Flutter | Người dùng có thể bị kẹt không thao tác được Gate, hiện đang cung cấp nút bypass Click (tap) thay vì ép swipe triệt để |

---

## 11. Kế hoạch triển khai

```
Phase 1 — Đã hoàn thành (Core Service Layer)
  ✅ SystemUIService abstract interface
  ✅ SystemUIServiceIO (Android/iOS — SystemChrome)
  ✅ SystemUIServiceWeb (Web — Fullscreen API)
  ✅ SystemUIStateMachine (flexible, advisory warnings)
  ✅ SystemUIPreset + Preset Registry + copyWith()
  ✅ SystemUILogger + DefaultLogger
  ✅ SystemUIException sealed hierarchy
  ✅ SystemUIServiceFactory

Phase 2 — Tiếp theo (Platform Detection + Minimal UI)
  ⬜ GameViewportPlatform detector (UserAgent + API check)
  ⬜ MinimalUIController (Scroll-to-Hide logic cho Safari iPhone)
  ⬜ Edge case handling: orientation change, virtual keyboard, PWA detect

Phase 3 — Sau đó (Presentation Layer + Cocos Integration)
  ⬜ GameViewportGateWidget (Overlay UI, per-platform content)
  ⬜ GameViewportController (state management cho Gate)
  ⬜ Cocos JS Interop: pause / resume / resize
  ⬜ Integration với GoRouter / app navigation lifecycle
```

---

*Tài liệu phản ánh trạng thái thiết kế tháng 4, 2026. Các quyết định kỹ thuật có thể được cập nhật khi bắt đầu Phase 2.*
