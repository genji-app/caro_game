# S88 Game Feature - Technical Notes & Gotchas

Tài liệu này tổng hợp các quyết định kỹ thuật quan trọng, cấu hình đặc thù và các cách xử lý lỗi (workarounds) đã được áp dụng trong module `game`.

## 1. Quản lý Hướng Xoay Màn Hình (Orientation)
- **Phân tách theo thiết bị**: Trạng thái xoay màn hình được quản lý độc lập cho điện thoại và máy tính bảng thông qua 2 thuộc tính mới: `GameBlock.mobileOrientation` và `GameBlock.tabletOrientation`.
- **Responsive Context Check**: Sử dụng `ResponsiveBuilder.isMobile(context)` hoặc `MediaQuery.sizeOf(context).shortestSide` để xác định giao diện. Logic setup bắt buộc để trong `didChangeDependencies` của `GamePlayerSystemUI` thay vì `initState` để tránh lỗi gọi InheritedWidget sớm trước khi context sẵn sàng.
- **Rule riêng của Provider**:
  - `AMB-VN` (Sexy) và `Vivo`: Khoá cứng `portrait` (dọc) trên Điện thoại, nhưng sử dụng `landscape` (ngang) trên Tablet/iPad để tối ưu trải nghiệm.
  - `Evolution` (`lcevo`): Bắt buộc `portrait` trên Điện thoại, nhưng cho phép xoay tự do (`all`) khi mở trên Tablet/iPad.

## 2. Kiến trúc Engine (game_engine package)
- **Hợp nhất Runner**: Module game đã được refactor từ việc chia tách `GameWebView/CocosWebView` sang sử dụng bộ engine tập trung:
  - `IHRunner` (In-House): Dành cho game Cocos/Sandbox. Tích hợp sẵn `GameBridgeMixin` để giao tiếp 2 chiều qua JSON Protocol.
  - `PLRunner` (Platform/Provider): Dành cho game từ đối tác thứ 3. Tối ưu cho iframe (Web) và InAppWebView (Mobile).
- **Phát Video Nhúng (Inline Media Playback)**: Trên iOS (áp dụng cho `PLRunner` và module game), mặc định sẽ mở video HTML5 ngay bên trong khung web thay vì bật trình phát Native Fullscreen che khuất UI app. Điều này đạt được nhờ cấu hình `allowsInlineMediaPlayback: true` trong bộ Engine.
- **Xung đột iPadOS Multitasking**: Đã thiết lập `<key>UIRequiresFullScreen</key><true/>` trong tệp `ios/Runner/Info.plist` để hệ điều hành nhường lại quyền điều hướng cho Flutter thay vì cho phép Split View phá vỡ khóa xoay màn hình.

## 3. Chặn mã HTML5 Fullscreen API (Rất quan trọng)
- **Vấn đề**: Các game thứ ba (như AMB-VN) tự động gọi các hàm DOM gốc của HTML5 (`requestFullscreen`, `webkitRequestFullscreen`) thông qua JavaScript. Sự kiện này ném thẳng Native OS WebView ra toàn màn hình để che giấu thanh URL, hệ lụy là nó **nuốt luôn cả các widget nằm trôi nổi (VD: Nút Back)** của app Flutter.
- **Giải pháp**: Phải bơm (Inject) mã JavaScript chặn ngay từ bên trong qua phương thức `_injectFullscreenBlocker()` ở `GameWebViewMobileState`.
  - **Force Playsinline**: Liên tục quét (qua `setInterval`) các thẻ `<video>` tự sinh ra trong trang web của provider và chèn cờ `playsinline="true"` & `webkit-playsinline="true"`.
  - **Override Fullscreen Methods**: Vô hiệu hóa toàn bộ nguyên mẫu của DOM (`Element.prototype.requestFullscreen`, `webkitEnterFullscreen`...) bằng hàm rỗng trả về `Promise.resolve()`. Nhờ đó bên game gọi Fullscreen thoải mái nhưng không bị văng lỗi (crash JS) mà hệ điều hành thì không phản hồi.

## 4. Quản lý Asset/Icon Game
- **Thay đổi Base Path**: Đã thống nhất xoá bỏ cơ cấu sử dụng prefix icon remote riêng cho game. Di dời sạch sẽ icon game về quản lý tập trung ở `assets/icons/` tại tệp `AppIcons.ASSETS_PATH`.
- Mọi logic ánh xạ chuỗi cho Icon liên quan đến Game, Banner, Category hiện tại đều tra cứu tự động qua extension tĩnh như `GameCategoryConfigAssetX.getIconPath` theo chuẩn mới thay vì rải thẻ cứng.

## 5. Quản lý Phiên Game (Game Session Guard)
- **Vấn đề**: Một số Provider (như `amb-vn`/SEXY) chỉ cho phép **1 phiên hoạt động duy nhất mỗi user**. Nếu mở game liên tục hoặc chưa đóng hẳn phiên cũ trên server mà mở ngay phiên mới, API của Provider sẽ trả về lỗi **1028 ("Unable to proceed")**.
- **Giải pháp**:
  - Tích hợp `GameSessionGuard` với thời gian chờ (cooldown) là **3 giây** giữa các lần đóng/mở game.
  - Sử dụng cờ `requiresSessionGuard: true` trong class `_ProviderOverride` của `GameBlock` để chỉ áp dụng cho những Provider cần thiết. Các Provider khác mặc định là `false` và không phải chịu thời gian chờ.
  - Gọi tập trung qua hàm `GamePlayerScreen.push` để mọi flow (từ Trang chủ, Filter, Search, Group) đều phải thông qua Guard. Nếu chưa hết cooldown, app sẽ hiện `AppToast.showError()`.

## 6. Tài liệu Game Player

Các vấn đề kỹ thuật chi tiết và giải pháp liên quan đến Game Player được lưu trong folder [`player/docs/`](player/docs/):

| Tài liệu | Mô tả |
|-----------|--------|
| [`game-player-issues.md`](player/docs/game-player-issues.md) | Tổng hợp tất cả issues đã biết & giải pháp (Android background, Web orientation, iOS Safari crash, v.v.) |
| [`orientation-issues.md`](player/docs/orientation-issues.md) | Chi tiết các phương pháp xử lý orientation trên iPadOS 16+ và Flutter Web |
| [`background-resume.md`](player/docs/background-resume.md) | Chiến lược reload game khi resume từ background |

## 7. Tìm kiếm & Chuẩn hoá (Search & Normalization)
- **Chuẩn hoá tiếng Việt (Diacritics Normalization)**: Xử lý tìm kiếm game không dấu và có dấu. Tính năng search trong `GameRepository` (hàm `_matchesQuery`) sử dụng `GameUtils.removeDiacritics` để bỏ dấu của danh sách game và từ khoá tìm kiếm, đảm bảo kết quả tìm kiếm nhất quán, ngay cả khi người dùng không sử dụng bộ gõ tiếng Việt. Lớp tiện ích xử lý dấu nằm gọn bên trong `core/services/repositories/game_repository/src/game_utils.dart` để tránh gây ô nhiễm (pollute) global `String` extension.

## 8. Cầu nối giao tiếp (Host Bridge - Unified)
- **GameBridgeMixin**: Được tích hợp trực tiếp vào `IHRunner`. Cung cấp pipeline truyền tin đồng nhất giữa Flutter (Host) và Game (JS) thông qua model `GameHostEvent`.
- **JSON Protocol**: Mọi sự kiện hiện nay đều được đóng gói dưới dạng JSON (e.g., `{"type": "EXIT_GAME", "data": {}}`) thay vì dùng string thô như trước đây.

## 9. Utilities & Reusable Components
- **GameSessionGuard**: Lớp `GameSessionGuard` chặn các truy vấn mở nhanh, tránh tạo nhiều session khiến Provider bị lỗi. Component này nằm tại `game/player/game_session_guard.dart`.
- **NewTabGamePlaceholder**: Component hiện thị màn hình fallback dành riêng cho các Game nặng trên iOS Web để tránh sập vì WebGL limit. Xuất khẩu trong `game.dart`.
