# Tài liệu triển khai orientation cho Game Player

## Tổng quan

Hệ thống Game Player hiện tại đã có nền tảng tốt cho việc điều khiển orientation ở app native thông qua `GamePlayerNotifier.initializePlayer()` và `SystemUiService`, nhưng logic quyết định orientation vẫn chưa được gắn chặt với `GameBlock` như một nguồn cấu hình duy nhất. [cite:32][cite:27][cite:40]

Mô hình `GameBlock` đã chứa đầy đủ dữ liệu để quyết định orientation theo ngữ cảnh thiết bị, bao gồm `mobileOrientation`, `tabletOrientation`, `forceLandscapeViewport` và các cờ hành vi khác như `openInNewTab`. [cite:40] Vì vậy, bài toán còn lại không phải là bổ sung thêm nhiều cấu hình mới, mà là chuẩn hóa luồng đọc cấu hình từ model, áp dụng đúng cho native app, và dùng cơ chế chặn UI hợp lý trên web. [cite:40][cite:36][cite:38]

## 1. Vấn đề đang gặp phải

### 1.1 Nguồn cấu hình orientation chưa được dùng làm single source of truth

`GamePlayerNotifier.initializePlayer()` hiện nhận một tham số `GameOrientation orientation`, sau đó map sang `systemUi.setPortraitOnly()`, `setLandscapeOnly()` hoặc `setAllOrientations()`. [cite:32][cite:27] Điều này cho thấy orientation đã được xử lý ở tầng business logic, nhưng hướng màn hình vẫn phụ thuộc vào chỗ gọi hàm truyền giá trị vào, thay vì được resolve trực tiếp từ `GameBlock`. [cite:32][cite:40]

Khi orientation không được resolve tập trung từ model, code dễ rơi vào tình trạng nhiều nơi tự quyết định orientation bằng các điều kiện riêng, ví dụ dựa trên device type, layout, hoặc provider-specific rule. [cite:40] Về lâu dài, điều này làm tăng rủi ro lệch logic giữa web và app, cũng như giữa các màn hình khác nhau trong cùng một flow game player. [cite:32][cite:35]

### 1.2 Hành vi giữa web và app khác nhau về bản chất

Ở mobile app native, `SystemUiService` có thể tương tác trực tiếp với hệ điều hành bằng `SystemChrome.setPreferredOrientations(...)`, đồng thời còn có workaround cho iPadOS 16 bằng cách flush orientation mask trước khi lock orientation. [cite:27][cite:36] Cơ chế này phù hợp với iOS/Android vì app thật sự có thể yêu cầu OS đổi hướng hiển thị. [cite:27]

Ở web, đặc biệt là Flutter Web, orientation không nên được xem như thứ có thể “lock” ổn định theo kiểu native app. [cite:36][cite:38] Tài liệu nội bộ cho thấy các vấn đề thực tế trên web tập trung nhiều hơn vào iframe lifecycle, viewport init timing, và việc game bị mount/unmount hoặc khởi tạo sai kích thước khi orientation thay đổi trong lúc load. [cite:36][cite:38]

### 1.3 Nếu render game trên web khi orientation chưa phù hợp, game có thể load sai

Tài liệu `orientation-issues.md` mô tả rõ các bug trên Flutter Web: iframe có thể biến mất khi widget tree đổi type lúc xoay màn hình, và CSS/layout của game có thể bị vỡ nếu iframe đổi kích thước đúng lúc game engine đang khởi tạo splash screen. [cite:36] `game-player-issues.md` cũng ghi nhận rằng giải pháp hiện tại phải giữ widget tree ổn định bằng `AdaptiveGameLayout` và phải lock/unlock kích thước iframe theo thời gian để tránh game init sai viewport. [cite:38]

Điều này dẫn tới một kết luận quan trọng: trên web, việc “bắt người dùng xoay đúng chiều trước khi cho game render” không chỉ là cải thiện UX, mà còn là một biện pháp giảm lỗi kỹ thuật khi game third-party phụ thuộc mạnh vào kích thước viewport lúc khởi tạo. [cite:36][cite:38]

### 1.4 `forceLandscapeViewport` không nên bị dùng sai vai trò

`GameBlock` có trường `forceLandscapeViewport`, nhưng field này mang tính chất workaround kỹ thuật cho viewport hoặc WebView behavior hơn là một luật UI tổng quát để yêu cầu người dùng xoay màn hình. [cite:40][cite:36] Nếu dùng field này để quyết định hiển thị màn “please rotate”, code sẽ dễ lẫn giữa hai khái niệm: orientation business rule của game và viewport-hack technical rule cho engine/webview. [cite:36][cite:40]

### 1.5 Restore system UI hiện chưa đúng trách nhiệm lifecycle

Trong `player_providers.dart`, logic `systemUi.restoreDefaultSystemUI()` hiện đang nằm bên trong nhánh `if (game.requiresSessionGuard)`. [cite:29] Điều này khiến việc restore orientation và system UI bị phụ thuộc vào session guard của provider, trong khi bản chất orientation/system UI là trách nhiệm chung của toàn bộ vòng đời game player screen, bất kể game đó có cooldown guard hay không. [cite:29][cite:27]

## 2. Giải pháp đề xuất

### 2.1 Dùng `GameBlock` làm nguồn cấu hình orientation duy nhất

Giải pháp trung tâm là resolve orientation trực tiếp từ model `GameBlock`, dựa trên device class hiện tại, thay vì truyền orientation thủ công từ nhiều nơi. [cite:40] `GameBlock` đã có sẵn `mobileOrientation` và `tabletOrientation`, nên chỉ cần thêm một lớp extension hoặc helper để chọn orientation theo breakpoint, ví dụ dựa trên `MediaQuery.size.shortestSide >= 600`. [cite:40]

Cách làm này biến `GameBlock` thành single source of truth cho orientation policy của game, giúp app và web dùng chung một rule nền tảng. [cite:40][cite:35] Nhờ đó, nếu sau này provider override thay đổi, logic hiển thị và logic native lock orientation sẽ tự đồng bộ theo model mà không cần chỉnh nhiều nơi. [cite:40]

### 2.2 Native app: tiếp tục dùng `SystemUiService`

Trên app native, flow hiện tại của `GamePlayerNotifier.initializePlayer()` là đúng hướng: khóa orientation theo `GameOrientation`, bật immersive mode, chờ một khoảng delay nếu cần, rồi mới tải game URL. [cite:32] `SystemUiService` đã có các hàm `setPortraitOnly()`, `setLandscapeOnly()`, `setAllOrientations()`, `hideStatusBarAndBottomNavigation()`, và `restoreDefaultSystemUI()` với các workaround iPadOS 16 cần thiết. [cite:27][cite:36]

Vì vậy, phần native không cần thay đổi triết lý xử lý. [cite:27][cite:32] Việc cần làm chỉ là đảm bảo orientation truyền vào `initializePlayer()` luôn được resolve từ `GameBlock`, thay vì đến từ logic phân tán ở UI layer. [cite:32][cite:40]

### 2.3 Web: không lock cứng, mà chặn render bằng orientation guard

Trên web, thay vì cố khóa orientation qua hệ điều hành hoặc browser API, giải pháp nên là tạo một `GameOrientationWebGuard`. [cite:36][cite:38] Widget này sẽ kiểm tra orientation hiện tại của UI, so sánh với orientation được resolve từ `GameBlock`, và chỉ cho phép render game khi hai thứ khớp nhau. [cite:40]

Nếu orientation chưa đúng, guard sẽ hiển thị màn hướng dẫn xoay thiết bị, ví dụ “Game này yêu cầu xoay ngang màn hình”. [cite:36] Cách này phù hợp với bản chất của Flutter Web, đồng thời giảm nguy cơ game khởi tạo sai layout hoặc bị hỏng viewport trong lúc load. [cite:36][cite:38][cite:24]

### 2.4 Chỉ initialize/load game khi orientation web đã đúng

Trên web, không chỉ nên chặn phần render iframe, mà còn nên trì hoãn cả bước `initializePlayer()` hoặc ít nhất là bước bắt đầu load game URL cho tới khi orientation phù hợp. [cite:32][cite:36] Nếu hệ thống fetch URL, tạo iframe, hoặc mount `HtmlElementView` khi người dùng vẫn đang cầm sai chiều màn hình, game third-party có thể ghi nhận sai kích thước viewport ngay từ splash/init phase. [cite:36][cite:38]

Vì thế, điều kiện “orientation đã đúng chưa” cần được đưa vào luồng initialize của screen, không chỉ là điều kiện hiển thị giao diện. [cite:32][cite:36]

### 2.5 Phân định rõ vai trò các field trong `GameBlock`

Ba nhóm field liên quan cần được dùng đúng vai trò:

- `mobileOrientation` và `tabletOrientation`: quyết định game yêu cầu portrait, landscape hay both theo loại thiết bị. [cite:40]
- `forceLandscapeViewport`: dùng cho workaround viewport injection hoặc dimension stabilization khi engine/game cần giả lập hoặc ép viewport đặc biệt. [cite:36][cite:40]
- `openInNewTab`: dùng cho các provider cần chạy tab mới trên web, nhất là iOS Safari/heavy WebGL case. [cite:40][cite:38]

Việc tách bạch ba vai trò này sẽ giúp code dễ hiểu hơn và tránh nhầm lẫn giữa “business rule về orientation” với “technical workaround cho web engine”. [cite:36][cite:40]

### 2.6 Restore system UI cho mọi game, không phụ thuộc session guard

Cần sửa `player_providers.dart` để `systemUi.restoreDefaultSystemUI()` luôn chạy khi game player bị dispose, còn `sessionGuard.onSessionEnded()` chỉ chạy khi `requiresSessionGuard == true`. [cite:29][cite:27] Điều này giúp lifecycle orientation/system UI phản ánh đúng bản chất của màn hình game, đồng thời tránh để một số provider không có session guard bị bỏ sót bước restore UI. [cite:29]

## 3. Cách triển khai

### 3.1 Bước 1: Thêm extension resolve orientation từ `GameBlock`

Tạo một file mới, ví dụ `game_block_orientation_x.dart`, để resolve orientation theo `shortestSide`. [cite:40] Breakpoint nên được đặt tập trung một chỗ, mặc định 600 để phân biệt phone và tablet, vì đây cũng là ngưỡng được Flutter docs và ví dụ orientation policy thường dùng cho màn hình lớn. [cite:24][cite:6]

```dart
import 'package:sun_sports/features/game/game.dart';

extension GameBlockOrientationX on GameBlock {
  GameOrientation resolveOrientation({
    required double shortestSide,
    double tabletBreakpoint = 600,
  }) {
    final isTablet = shortestSide >= tabletBreakpoint;
    return isTablet ? tabletOrientation : mobileOrientation;
  }

  bool isRequiredOrientationMatched({
    required double shortestSide,
    required bool isPortrait,
    double tabletBreakpoint = 600,
  }) {
    final orientation = resolveOrientation(
      shortestSide: shortestSide,
      tabletBreakpoint: tabletBreakpoint,
    );

    switch (orientation) {
      case GameOrientation.portrait:
        return isPortrait;
      case GameOrientation.landscape:
        return !isPortrait;
      case GameOrientation.both:
        return true;
    }
  }
}
```

Sau bước này, mọi nơi trong app cần biết orientation mong muốn của game chỉ cần gọi `game.resolveOrientation(...)`. [cite:40]

### 3.2 Bước 2: Tính orientation từ model ngay trong Game Player screen

Trong `GamePlayerScreen`, đọc `MediaQuery.sizeOf(context).shortestSide`, resolve orientation từ `GameBlock`, rồi dùng kết quả đó cho cả native app lẫn web guard. [cite:40] Điều này bảo đảm cùng một model sẽ sinh ra cùng một orientation policy trên mọi nền tảng. [cite:40][cite:35]

Pseudo-code:

```dart
final size = MediaQuery.sizeOf(context);
final shortestSide = size.shortestSide;
final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;

final requiredOrientation = game.resolveOrientation(
  shortestSide: shortestSide,
);

final isOrientationMatched = game.isRequiredOrientationMatched(
  shortestSide: shortestSide,
  isPortrait: isPortrait,
);
```

### 3.3 Bước 3: Native app vẫn initialize như hiện tại

Với Android/iOS, khi screen bắt đầu vào game, gọi `initializePlayer(requiredOrientation, isMobileLogin)` như hiện tại. [cite:32] Vì `GamePlayerNotifier.initializePlayer()` đã biết cách chuyển `GameOrientation` thành lệnh lock portrait/landscape/all orientations và bật immersive mode, phần này gần như chỉ cần đổi nguồn dữ liệu đầu vào. [cite:32][cite:27]

Pseudo-code:

```dart
if (!kIsWeb) {
  ref.read(gamePlayerProvider(game).notifier).initializePlayer(
    requiredOrientation,
    isMobileLogin,
  );
}
```

### 3.4 Bước 4: Tạo `GameOrientationWebGuard`

Tạo widget web guard để bọc phần game content. [cite:36][cite:38] Widget này không được mount iframe/game content nếu orientation hiện tại chưa phù hợp, vì tài liệu bug cho thấy mount sai thời điểm là nguyên nhân gây mất iframe hoặc init sai layout. [cite:36][cite:38]

```dart
import 'package:flutter/material.dart';
import 'package:sun_sports/features/game/game.dart';

class GameOrientationWebGuard extends StatelessWidget {
  const GameOrientationWebGuard({
    super.key,
    required this.requiredOrientation,
    required this.child,
  });

  final GameOrientation requiredOrientation;
  final Widget child;

  bool _matches(GameOrientation requiredOrientation, Orientation current) {
    switch (requiredOrientation) {
      case GameOrientation.portrait:
        return current == Orientation.portrait;
      case GameOrientation.landscape:
        return current == Orientation.landscape;
      case GameOrientation.both:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = MediaQuery.orientationOf(context);

    if (_matches(requiredOrientation, current)) {
      return child;
    }

    final isLandscapeRequired = requiredOrientation == GameOrientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.screen_rotation, size: 56, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  isLandscapeRequired
                      ? 'Game này yêu cầu xoay ngang màn hình'
                      : 'Game này yêu cầu xoay dọc màn hình',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vui lòng xoay thiết bị để tiếp tục.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3.5 Bước 5: Chỉ initialize trên web khi orientation đã đúng

Đây là bước quan trọng nhất ở web. [cite:36][cite:38] `initializePlayer()` hoặc ít nhất là phần `loadGameUrl()` chỉ nên được gọi khi `isOrientationMatched == true`, để tránh việc game engine khởi tạo trong sai chiều màn hình. [cite:32][cite:36]

Pseudo-code:

```dart
void maybeInitPlayer(BuildContext context, WidgetRef ref, GameBlock game) {
  final size = MediaQuery.sizeOf(context);
  final shortestSide = size.shortestSide;
  final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;

  final requiredOrientation = game.resolveOrientation(
    shortestSide: shortestSide,
  );

  final isMatched = game.isRequiredOrientationMatched(
    shortestSide: shortestSide,
    isPortrait: isPortrait,
  );

  if (kIsWeb && !isMatched) return;

  ref.read(gamePlayerProvider(game).notifier).initializePlayer(
    requiredOrientation,
    size.width < 600,
  );
}
```

Cách này giúp web không mount game hoặc gọi API load game quá sớm. [cite:32][cite:36][cite:38]

### 3.6 Bước 6: Bọc game content bằng web guard

Trong `build()` của screen, nếu là web thì bọc phần content bằng `GameOrientationWebGuard`. [cite:36][cite:38] Nếu orientation là `both`, guard sẽ luôn pass và không ảnh hưởng UX. [cite:40]

Pseudo-code:

```dart
final body = GamePlayerBody(game: game);

if (kIsWeb) {
  return GameOrientationWebGuard(
    requiredOrientation: requiredOrientation,
    child: body,
  );
}

return body;
```

### 3.7 Bước 7: Sửa `player_providers.dart` để restore UI đúng lifecycle

Hiện `restoreDefaultSystemUI()` chỉ chạy khi `requiresSessionGuard` là true. [cite:29] Cần sửa lại để mọi game khi dispose đều restore orientation/system UI, còn session guard vẫn giữ logic riêng của nó. [cite:29][cite:27]

Đề xuất sửa:

```dart
ref.onDispose(() async {
  if (game.requiresSessionGuard) {
    sessionGuard.onSessionEnded(game.providerId);
  }

  await systemUi.restoreDefaultSystemUI();

  Future.microtask(() {
    userNotifier.logInfo('Balance refresh triggered on game exit');
    userNotifier.refreshBalance();
  });
});
```

### 3.8 Bước 8: Giữ nguyên các workaround web/native hiện có

Các workaround hiện tại như flush orientation mask cho iPadOS 16 trong `SystemUiService`, delay sau khi đổi orientation trong `GamePlayerNotifier`, `AdaptiveGameLayout` để tránh unmount iframe, và dimension lock/unlock trên web nên tiếp tục được giữ nguyên. [cite:27][cite:32][cite:36][cite:38] Những thay đổi đề xuất trong tài liệu này không thay thế chúng, mà chỉ bổ sung một lớp điều phối orientation rõ ràng hơn dựa trên `GameBlock`. [cite:36][cite:38]

## Kế hoạch áp dụng theo thứ tự

| Bước | Hạng mục | Mục tiêu |
|---|---|---|
| 1 | Thêm `GameBlockOrientationX` | Chuẩn hóa cách resolve orientation từ model [cite:40] |
| 2 | Sửa `GamePlayerScreen` | Lấy orientation từ model thay vì truyền tay [cite:32][cite:40] |
| 3 | Thêm `GameOrientationWebGuard` | Chặn render game khi web đang sai orientation [cite:36][cite:38] |
| 4 | Trì hoãn `initializePlayer()` trên web | Ngăn game load sớm trong sai viewport [cite:32][cite:36] |
| 5 | Sửa `player_providers.dart` | Restore system UI cho mọi game screen [cite:29][cite:27] |
| 6 | Retest trên mobile/web | Kiểm tra lại iPad, Chrome DevTools, Safari, Android [cite:35][cite:36][cite:38] |

## Kết quả mong đợi

Sau khi áp dụng, orientation rule của game sẽ được lấy thống nhất từ `GameBlock`, giúp app native và web cùng dùng một nguồn cấu hình chung. [cite:40] Trên native, game vẫn được lock orientation qua hệ điều hành như hiện tại. [cite:27][cite:32]

Trên web, người chơi sẽ được yêu cầu xoay màn hình trước khi game thực sự khởi tạo, từ đó giảm xác suất gặp lỗi iframe unmount, game init sai viewport, hoặc layout third-party bị vỡ trong giai đoạn splash/loading. [cite:36][cite:38] Đồng thời, lifecycle system UI khi rời màn hình game cũng sẽ đúng và nhất quán hơn cho mọi provider. [cite:29][cite:27]
