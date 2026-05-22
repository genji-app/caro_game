# 📜 Đặc tả Kỹ thuật JSON — Casino Settings v2

Tài liệu này cung cấp chi tiết kỹ thuật về cấu trúc file JSON được sử dụng trong package `caxilo_config`. Đây là tài liệu tham chiếu chính thức dành cho **Backend Teams** và **Operations Teams** khi thực hiện cấu hình hệ thống.

---

## 1. Cấu trúc Root

| Field | Kiểu | Bắt buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `version` | `Integer` | ✅ | Phiên bản schema. App dùng để kiểm tra tính tương thích. |
| `updated_at` | `String` | ✅ | Thời điểm cập nhật cuối (ISO 8601). |
| `environments` | `Object` | ✅ | Map các Base URL. Key tham chiếu bởi `base_url_key`. |
| `display` | `Object` | ✅ | Cấu hình trình bày danh sách game (Shared across modules). |
| `categories` | `List<Object>` | ✅ | Danh sách các danh mục game hiển thị trên UI (Đa hình). |
| `lobby_sections` | `List<Object>` | ✅ | Danh sách các section định nghĩa layout trang chủ. |
| `in_house` | `Object` | ✅ | Khối cấu hình chính cho game In-House. |

---

## 2. Global Display Section (`display`)
Cấu hình trình bày danh sách game dùng chung cho toàn bộ module Casino.

| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `order` | `List<String>` | Thứ tự sắp xếp game theo `game_code`. |
| `featured` | `List<String>` | Danh sách các game nổi bật (hiển thị banner). |
| `new` | `List<String>` | Danh sách các game mới cần được gắn tag đặc biệt. |

---

## 3. Lobby Sections (`lobby_sections`)
Section này định nghĩa cấu trúc của trang chủ Lobby, sử dụng cấu trúc **Đa hình (Polymorphic)** dựa trên trường `type`.

### 3.1 Các trường dùng chung (Common Fields)
| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `type` | `String` | Loại section: `strategy`, `in_house`, `game_type`, `provider`, `banner`. |
| `title` | `String` | Tiêu đề hiển thị của section (Trừ loại `banner`). |
| `limit` | `Integer` | (Optional) Giới hạn số lượng game hiển thị (-1 là không giới hạn). |

### 3.2 Cấu hình theo từng `type`
*   **Nếu `type == "strategy"`**:
    *   `strategy_id` (String): ID của chiến lược lọc (e.g. `new`).
    *   `params` (Object): Tham số bổ sung cho chiến lược.
*   **Nếu `type == "in_house"`**: Không yêu cầu thêm trường nào khác.
*   **Nếu `type == "game_type"`**:
    *   `game_type_id` (String): ID của loại game (e.g. `slot`).
*   **Nếu `type == "provider"`**:
    *   `provider_id` (String): ID của nhà cung cấp.
*   **Nếu `type == "banner"`**:
    *   `banner_id` (String): ID của banner truyền thông.

---

## 4. Categories Section (`categories`)
Cấu hình động cho các tab/danh mục hiển thị trong sảnh Casino. Section này sử dụng cấu trúc **Đa hình (Polymorphic)** dựa trên trường `type`.

### 4.1 Các trường dùng chung (Common Fields)
| Field | Kiểu | Bắt buộc | Mô tả |
| :--- | :--- | :--- | :--- |
| `type` | `String` | ✅ | Loại danh mục: `gameType`, `inHouse`, `custom`. |
| `id` | `String` | ✅ | Khóa chính của danh mục (e.g. `slots`, `sunwin`). |
| `translation_key` | `String` | ✅ | Key đa ngôn ngữ (i18n) cho tên danh mục. |
| `icon` | `String` | ✅ | Tên file icon trạng thái bình thường. |
| `icon_active` | `String` | ✅ | Tên file icon trạng thái đang chọn. |

### 4.2 Cấu hình theo từng `type`
Tùy thuộc vào giá trị của `type`, object sẽ yêu cầu các trường khác nhau:

*   **Nếu `type == "gameType"`**: Yêu cầu thêm trường `"game_type"` (tham chiếu Enum GameType). Dùng để tạo tab cho các game cụ thể như Slots, Bắn cá.
*   **Nếu `type == "inHouse"`**: Không yêu cầu thêm trường nào. Dùng để tạo tab hiển thị toàn bộ game nội bộ (Sunwin).
*   **Nếu `type == "custom"`**: Yêu cầu thêm 2 trường:
    *   `filter_strategy` (String): Tên chiến lược lọc (VD: `new`, `popular`). Client app sẽ dựa vào đây để chạy logic code tương ứng.
    *   `filter_params` (Object): Cấu hình động cho chiến lược lọc (VD: `{ "days_ago": 30 }`).

---

## 5. In-House Section (`in_house`)

Section này tập trung vào dữ liệu kỹ thuật và trạng thái của các game nội bộ.

### 5.1 Catalog (Mảng các Object)
Khai báo thông số kỹ thuật cơ bản cho từng game.

| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `game_code` | `String` | **Khóa chính (Unique ID)**. Dùng để map với Visibility và Display. |
| `game_name` | `String` | Tên hiển thị của trò chơi. |
| `provider_id` | `String` | ID nhà cung cấp (e.g. `sunwin`). |
| `provider_name` | `String` | Tên nhà cung cấp hiển thị. |
| `product_id` | `String` | ID định danh sản phẩm (e.g. `sunwin_AVENGER`). |
| `game_id` | `Integer` | (Optional) ID nội bộ của game đối với nhà cung cấp. |
| `lang` | `String` | Ngôn ngữ mặc định của game (e.g. `vi`). |
| `image` | `String` | Tên file ảnh thumbnail. |
| `game_type` | `String` | [Tra cứu bảng Enum GameType](#61-gametype) |
| `launch_strategy` | `String` | [Tra cứu bảng Enum LaunchStrategy](#62-launchstrategy) |
| `base_url_key` | `String` | Key tham chiếu trong `environments`. |
| `mobile_orientation` | `List<String>` | [Tra cứu bảng Enum Orientation](#64-orientation) trên điện thoại. |
| `tablet_orientation` | `List<String>` | Hướng màn hình hỗ trợ trên máy tính bảng. |
| `desktop_orientation` | `List<String>` | Hướng màn hình hỗ trợ trên máy tính. |
| `enable_host_message` | `Boolean` | Bật/tắt giao tiếp JS Bridge với Flutter host. |

### 5.2 Visibility (Map Object)
Dùng `game_code` làm key để quản lý trạng thái vận hành.

| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `is_visible` | `Boolean` | `false` ẩn hoàn toàn game khỏi UI. |
| `status` | `String` | [Tra cứu bảng Enum GameStatus](#63-gamestatus) |

---

## 6. Bảng tra cứu Enum

### 6.1 GameType
Dùng để phân loại logic và icon trong app.

| JSON Value | Giải thích | Alias supported |
| :--- | :--- | :--- |
| `slot` | Nổ hũ / Slot Machine | |
| `fish` | Bắn cá | `fishing` |
| `card` | Game bài | `cardgame` |
| `live` | Sòng bài trực tuyến | |
| `miniGame` | Các trò chơi nhanh (Tài xỉu, Xóc đĩa) | |
| `sport` | Thể thao | |
| `jackpot` | Game có quỹ thưởng lớn | |
| `dice` | Các trò chơi dùng xúc xắc | |
| `lottery` | Xổ số | |
| `others` | Các game khác | |

### 6.2 LaunchStrategy
Xác định cách thức build URL khởi chạy game.

| JSON Value | Ý nghĩa | Hành vi |
| :--- | :--- | :--- |
| `standard` | Tiêu chuẩn | Gắn token và query params cơ bản. Hỗ trợ `gameID`. |
| `fish` | Bắn cá | Sử dụng luồng login riêng dành cho sảnh bắn cá. |
| `underDevelopment` | Đang phát triển | Không cho phép bấm vào game, hiển thị thông báo. |

### 6.3 GameStatus
Trạng thái hiển thị tức thời trên UI.

| JSON Value | Hiển thị | Cho phép chơi? |
| :--- | :--- | :--- |
| `active` | Bình thường | ✅ Có |
| `maintenance` | Mờ + Icon bảo trì | ❌ Không |
| `coming_soon` | Mờ + Nhãn sắp ra mắt | ❌ Không |
| `disabled` | Ẩn hoàn toàn | ❌ Không |

### 4.4 Orientation (Hướng màn hình)
Định nghĩa các hướng xoay được phép khi load WebView.

| JSON Value | Expanded (Cơ chế Alias) |
| :--- | :--- |
| `"portrait"` | `[portraitUp, portraitDown]` |
| `"landscape"` | `[landscapeLeft, landscapeRight]` |
| `"all"` | `[portraitUp, portraitDown, landscapeLeft, landscapeRight]` |
| `"portraitUp"` | `[portraitUp]` |
| `"landscapeLeft"` | `[landscapeLeft]` |

---

## 5. External Providers Section (`external`)

Section này quản lý danh sách các trò chơi từ nhà cung cấp thứ 3 (External Providers) và các cấu hình ghi đè (overrides) cho từng provider.

### 5.1 Cấu trúc `external`
| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `test_mode` | `Boolean` | Nếu `true`, bỏ qua whitelist và hiển thị tất cả game (Dùng cho Debug). |
| `provider_configs` | `Map<String, Object>` | Map các cấu hình chi tiết theo `provider_id`. |

### 5.2 Cấu hình Provider (`ExternalProviderConfig`)
Mỗi provider có thể cấu hình các thông số sau:

| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `game_type` | `String` | Override loại game mặc định cho provider này. |
| `mobile_orientation` | `List<String>` | Hướng màn hình trên Mobile. |
| `tablet_orientation` | `List<String>` | Hướng màn hình trên Tablet. |
| `desktop_orientation` | `List<String>` | Hướng màn hình trên Desktop. |
| `force_landscape_viewport_on_ipad` | `Boolean` | Ép buộc iPad chạy landscape (fix UI bug). |
| `open_in_new_tab_on_ios_safari_web` | `Boolean` | Mở game trong tab mới trên iOS Safari (tránh crash). |
| `requires_session_guard` | `Boolean` | Bật cooldown guard khi chuyển đổi game. |
| `load_stop_debounce_ms` | `Integer` | Thời gian debounce khi game load xong (ms). |
| `games` | `List<Object>` | Danh sách các game được phép hiển thị (Whitelist). |

### 5.3 Object Game (`ExternalGame`)
| Field | Kiểu | Mô tả |
| :--- | :--- | :--- |
| `game_code` | `String` | Mã định danh game từ nhà cung cấp. |
| `image` | `String` | Tên file ảnh thumbnail. |

---

## 6. Logic Hoạt động Đặc biệt

### 5.1 Khả năng tự mở rộng Orientation (Alias Expansion)
Hệ thống sử dụng một trình chuyển đổi thông minh (`GameOrientationListConverter`). Khi bạn khai báo `"landscape"`, ứng dụng sẽ tự động cho phép xoay màn hình sang cả hai bên trái và phải. Điều này giúp tối giản hóa file cấu hình nhưng vẫn đảm bảo trải nghiệm người dùng tốt nhất trên mọi thiết bị.

### 5.2 Tính tương thích ngược (Backward Compatibility)
Mọi thuộc tính không bắt buộc đều có giá trị mặc định (Default values). Nếu một game được thêm vào `catalog` nhưng chưa được cấu hình trong `visibility`, hệ thống sẽ mặc định coi game đó là **ẩn (`is_visible: false`)** để đảm bảo an toàn.

---
> [!IMPORTANT]
> **Quy tắc quan trọng nhất**: Luôn sử dụng `game_code` chính xác và thống nhất giữa các section. Sai lệch `game_code` sẽ khiến game không thể hiển thị hoặc sai trạng thái bảo trì.
