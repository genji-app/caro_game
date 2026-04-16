# Hướng dẫn Quản lý Danh mục Game (Game Categories)

## Tổng quan

Hệ thống danh mục game đã được đơn giản hóa để tập trung vào trải nghiệm người dùng nhanh chóng và mã nguồn sạch sẽ (clean code). Chúng ta sử dụng một cấp danh mục duy nhất (thay vì hai cấp như trước đây) để giảm thiểu sự phức tạp.

## Thành phần chính

### 1. GameCategory (Model)
Sử dụng `sealed class` với Freezed để định nghĩa các loại danh mục khác nhau:
- **GameTypeCategory**: Theo loại game (Casino, Slots, Sports, v.v.)
- **ProviderCategory**: Theo nhà cung cấp (PG Soft, Pragmatic, v.v.)
- **CustomCategory**: Theo tiêu chí tùy chỉnh (Game mới, Game Hot, v.v.)

```dart
// Ví dụ tạo danh mục Custom
const GameCategory.custom(
  categoryId: 'new_releases',
  displayLabel: 'Mới ra mắt',
  criteria: GameCategoryCriteria.byReleaseDate(daysAgo: 30),
)
```

### 2. GameCategorySelection (State)
Quản lý trạng thái danh mục đang được chọn. Khi `category` là `null`, hệ thống hiểu là đang chọn "Tất cả".

### 3. GameCategorySelector (UI)
Widget hiển thị danh sách các danh mục dưới dạng thanh cuộn ngang (horizontal scroll).

## Cách sử dụng

### Tích hợp vào màn hình
Sử dụng `GameCategorySelector` trong `Scaffold` hoặc `Column`:

```dart
Column(
  children: [
    const GameCategorySelector(),
    const Expanded(child: GameList()),
  ],
)
```

### Lọc danh sách Game
Sử dụng phương thức `matches` trong `GameCategorySelection` để lọc dữ liệu:

```dart
final selection = ref.watch(gameCategorySelectionProvider);
final filteredGames = allGames.where((game) => 
  selection.matches(game, game.providerId)
).toList();
```

## Khả năng mở rộng

Hệ thống được thiết kế để dễ dàng thêm các loại danh mục mới thông qua `GameFilter`. Bạn có thể tạo các bộ lọc phức tạp bằng cách kết hợp `filters`:

```dart
// Lọc game vừa mới ra mắt VÀ đang phổ biến
GameFilter.all(
  filters: [
    GameFilter.byReleaseDate(daysAgo: 7),
    GameFilter.byPopularity(minPlayCount: 1000),
  ],
)
```

## Ưu điểm của kiến trúc mới
- **Đơn giản**: Chỉ một cấp lọc giúp người dùng không bị bối rối.
- **Hiệu năng**: Giảm thiểu rebuild và logic phức tạp trong UI.
- **Mở rộng**: Dễ dàng thêm tab mới chỉ bằng cách cập nhật dữ liệu từ API hoặc Provider.
