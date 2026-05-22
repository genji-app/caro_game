# 🌐 Đặc tả Remote Config — Casino Settings

Tài liệu này cung cấp cái nhìn tổng quan về hệ thống cấu hình từ xa (Remote Config) cho module Casino In-House. Hệ thống này cho phép quản trị viên điều phối môi trường, trạng thái vận hành và danh mục trò chơi mà không cần phát hành phiên bản ứng dụng mới.

---

## 1. Cơ chế hoạt động (The Flow)

Ứng dụng Flutter sử dụng một quy trình 3 bước để đồng bộ cấu hình:

1.  **Fetch**: Tải nội dung cấu hình từ URL (thường là GitHub Raw hoặc Firebase Remote Config). Dữ liệu được lưu trữ dưới dạng chuỗi **Base64** để đảm bảo tính toàn vẹn và tránh các vấn đề về encoding.
2.  **Decode & Parse**: Giải mã Base64 sang chuỗi JSON và chuyển đổi thành Model `CaxiloConfig` (Sử dụng bộ công cụ `freezed` & `json_serializable`).
3.  **Sync & React**: Các thay đổi được phát đi qua `Stream`, UI sẽ tự động cập nhật trạng thái (Bảo trì, Thứ tự game, Badge mới).

---

## 2. Cấu trúc Root (Schema v2)

Cấu hình JSON được chia thành 3 khu vực trách nhiệm chính:

```json
{
  "version": 2,
  "updated_at": "2026-04-24T08:00:00Z",
  "environments": {
    "avenger_base_url": "https://avenger.sunwin.live",
    "table_games_base_url": "https://gamebai.sunwin.live"
  },
  "display": {
    "order": ["AVENGER"],
    "featured": ["AVENGER"],
    "new": ["AVENGER"]
  },
  "categories": [
    {
      "type": "inHouse",
      "id": "sunwin",
      "translation_key": "txt_game_category_sunwin",
      "icon": "ic_sunwin.png",
      "icon_active": "ic_sunwin_active.png"
    }
  ],
  "lobby_sections": [
    {
      "type": "strategy",
      "title": "Trò chơi mới",
      "strategy_id": "new",
      "limit": 10
    },
    {
      "type": "in_house",
      "title": "Game bài Sunwin"
    }
  ],
  "in_house": {
    "catalog": [
      {
        "game_code": "AVENGER",
        "game_name": "Avenger",
        "game_type": "slot",
        "base_url_key": "avenger_base_url",
        "launch_strategy": "standard",
        "mobile_orientation": ["landscape"]
      }
    ],
    "visibility": {
      "AVENGER": { "is_visible": true, "status": "active" }
    }
  }
}
```

### 2.1 Các Section chính

| Section | Chủ sở hữu | Mục đích |
| :--- | :--- | :--- |
| `environments` | DevOps / Backend | Quản lý tập trung các Base URL để chuyển đổi domain nhanh khi bị chặn. |
| `in_house` | Product / Dev | Quản lý chi tiết danh mục game, quyền hiển thị và trình bày marketing. |

---

## 3. Section `in_house` (Cấu trúc phân lớp)

`in_house` được thiết kế theo nguyên tắc hội tụ dữ liệu, chia làm 3 bảng:

### 📊 3.1 Catalog (Dữ liệu kỹ thuật)
Chứa thông tin "tĩnh" của game: `game_code`, `game_name`, `game_type`, `launch_strategy`, và cấu hình `orientation`.
> [!NOTE]
> Đây là Source of Truth về mặt kỹ thuật.

### 👁️ 3.2 Visibility (Quyền hiển thị)
Kiểm soát trạng thái "động" của game: `active`, `maintenance`, `coming_soon`.
> [!TIP]
> Ops Team chỉ cần chỉnh sửa tại đây để bật/tắt game trong 30 giây.

### 🎨 3.3 Display (Trình bày)
Kiểm soát giao diện: Thứ tự (`order`), Game nổi bật (`featured`), và nhãn dán (`badges`).

---

## 4. Tài liệu chi tiết

Để tìm hiểu sâu hơn về từng thuộc tính và cách cấu hình, vui lòng tham khảo các tài liệu sau:

- 📖 **[Đặc tả kỹ thuật JSON (Detailed Spec)](./CASINO_SETTINGS_JSON_SPEC_v2.md)**: Chi tiết từng field, kiểu dữ liệu và bảng tra cứu Enum.
- 🏗️ **[Kiến trúc hệ thống (Design Document)](./CASINO_SETTINGS_FULL_DESIGN.md)**: Dành cho lập trình viên muốn tìm hiểu cách Package được xây dựng.

---
> [!IMPORTANT]
> Toàn bộ cấu hình phải tuân thủ chuẩn **UTF-8** và được encode sang **Base64** trước khi upload lên server.
