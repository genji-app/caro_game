# Caxilo Config — Hướng dẫn quản lý cấu hình

**Tác giả:** Trippy  
**Cập nhật:** 2026-05-03 (v3.6.0)  
**Package:** `packages/caxilo_config`

---

## Tổng quan

`caxilo_config` quản lý toàn bộ cấu hình casino của app: danh sách game, thứ tự hiển thị, danh mục sidebar, whitelist provider bên ngoài và base URL cho từng môi trường.

Hệ thống được thiết kế với **3 chế độ hoạt động rõ ràng** để hỗ trợ toàn bộ vòng đời phát triển — từ dev hàng ngày đến release production.

---

## 3 chế độ hoạt động

```
┌────────────────┬──────────────────────────────────────┬─────────────────────────────┐
│ Mode           │ Khi nào dùng                         │ Config source               │
├────────────────┼──────────────────────────────────────┼─────────────────────────────┤
│ Dev            │ Phát triển hàng ngày                 │ Dart preset (hardcoded)     │
│ Local Test     │ Test staging/prod trước GitHub push  │ JSON file export ra local   │
│ Remote         │ Staging/prod đã lên GitHub           │ URL remote (GitHub raw)     │
└────────────────┴──────────────────────────────────────┴─────────────────────────────┘
```

### Sơ đồ luồng

```
Dart preset files (*_presets.dart)   ← NGUỒN SỰ THẬT DUY NHẤT
        │
        │  make export-casino-config
        ▼
packages/caxilo_config/config_exports/
  caxilo_config_dev.json      ← review / diff
  caxilo_config_dev.b64
  caxilo_config_staging.json  ← chỉnh sửa nếu cần
  caxilo_config_staging.b64   ─────────────────────────────────┐
  caxilo_config_prod.json                                      │
  caxilo_config_prod.b64      ─────────────────────┐           │
        │                                          │           │
        │  --dart-define                           │  push to  │
        │  CASINO_CONFIG_JSON=...                  │  GitHub   │
        ▼                                          ▼           ▼
  App (local test)                           GitHub raw URL
                                                   │
                                          CASINO_CONFIG_URL
                                                   │
                                            App (remote)
```

### Priority trong app

Khi app khởi động, `caxiloConfigClientProvider` áp dụng theo thứ tự ưu tiên:

| Priority | Dart-define / env | Mô tả |
|----------|-------------------|-------|
| 1 | `CASINO_CONFIG_JSON` | JSON được bake vào binary — dùng cho local test |
| 2 | `CASINO_CONFIG_URL` | Sync từ GitHub URL — dùng cho remote mode |
| 3 | _(không có gì)_ | Dart preset fallback — dev mode mặc định |

---

## Preset files — Nguồn sự thật

Preset được viết bằng **Dart thuần** (không phải JSON/YAML) vì:

- **Type-safe** — Compiler báo lỗi ngay nếu cấu trúc sai
- **Comment inline** — Ghi chú ý nghĩa từng game, từng field ngay tại chỗ
- **IDE support** — Refactor, autocomplete, Go to Definition
- **Git history rõ ràng** — `git diff` cho thấy chính xác game nào thay đổi, không bị nhiễu format

### Cấu trúc file

```
packages/caxilo_config/lib/src/presets/
├── caxilo_config_presets.dart   ← entry point: CaxiloConfigPresets, CaxiloEnvironment
├── urls_presets.dart            ← base URLs theo môi trường
├── display_presets.dart         ← thứ tự hiển thị + collections (lobby SDUI)
├── categories_presets.dart      ← danh mục sidebar
├── in_house_presets.dart        ← game nội bộ Sunwin
├── external_presets.dart        ← whitelist game từ provider ngoài
└── backup_presets.dart          ← backup reference (không dùng ở runtime)
```

Tất cả file ngoại trừ `caxilo_config_presets.dart` đều dùng cú pháp `part of` — không import trực tiếp.

---

## Mô tả từng preset file

### `urls_presets.dart` — Base URLs

Định nghĩa base URL cho từng server game theo môi trường (`dev`, `staging`, `prod`).

```dart
const _devUrls = {
  "avenger_base_url": "https://avenger.sunwin.live",
  "pirates_base_url": "https://haitac.sunwin.live",
  "table_games_base_url": "https://gamebai.sunwin.live",
  "fish88_base_url": "https://fish-s88.sandboxg1.win",
  "aquarium_base_url": "https://thuycung.sunwin.live",
  "thantai_base_url": "https://thantai.sunwin.live",
};
```

> Các key này được dùng bởi `InHouseGame.baseUrlKey` để resolve URL thực tế khi launch game.

---

### `display_presets.dart` — Thứ tự & Collections

Kiểm soát **thứ tự hiển thị** game trên toàn bộ màn hình và **collections** (nhóm game đặc biệt).

```dart
const _sharedDisplay = {
  "order": ["SC", "SP", "VT", ...],  // thứ tự ưu tiên hiển thị (game code)
  "collections": {
    "featured": ["SC", "SP", ...],   // games nổi bật
    "popular":  ["SC", "SP", ...],   // games phổ biến
    "new":      ["AQUARIUM", ...],   // games mới
  },
};
```

Cũng chứa cấu hình lobby SDUI (`_sharedLobby`, `_sharedLobbySections`) — các section hiển thị trên Home tab.

---

### `categories_presets.dart` — Danh mục sidebar

Định nghĩa các tab danh mục trên sidebar (Sunwin, Slots, Live, v.v.).

```dart
const _sharedCategories = [
  {
    "id": "sunwin",
    "group_key": "priority",          // "priority" | "standard" | (bỏ trống)
    "translation_key": "txt_game_category_sunwin",
    "icon": "ic_sunwin_bw.png",
    "icon_active": "ic_sunwin.png",
    "filter": {"strategy": "in_house"},
  },
  {
    "id": "slots",
    "group_key": "standard",
    "filter": {"strategy": "by_game_type", "params": {"game_type": "slot"}},
  },
  // ...
];
```

`group_key` kiểm soát vị trí trong sidebar: `"priority"` xuất hiện trước, `"standard"` sau. Nếu không có `group_key` → phân loại tự động theo `game_type`.

---

### `in_house_presets.dart` — Game nội bộ Sunwin

Catalog đầy đủ của các game do Sunwin phát triển, kèm trạng thái visibility.

```dart
const _sharedInHouse = {
  "catalog": [
    {
      "provider_id": "sunwin",
      "game_code": "AVENGER",
      "game_name": "Avenger",
      "image": "sunwin_AVENGER_avenger_thumb.webp",
      "game_type": "slot",             // slot | fish | card | live | ...
      "mobile_orientation": ["landscape"],
      "base_url_key": "avenger_base_url",  // key trong urls_presets
      "launch_strategy": "standard",    // standard | fish | underDevelopment
      "enable_host_message": true,
    },
    // ...
  ],
  "visibility": {
    "AVENGER":    {"is_visible": true,  "status": "active"},
    "POKER-SUN":  {"is_visible": false, "status": "active"},        // ẩn game
    "SP":         {"is_visible": true,  "status": "under_development"}, // hiện nhưng báo đang phát triển
  },
};
```

**`visibility` map** — kiểm soát từng game:
- `is_visible: false` → game bị ẩn hoàn toàn
- `status: "under_development"` → hiển thị với badge "Đang phát triển"
- `status: "maintenance"` → hiển thị với badge "Bảo trì"

---

### `external_presets.dart` — Whitelist game provider ngoài

Danh sách game được hỗ trợ từ các nhà cung cấp bên ngoài (amb-vn, vivo, lcevo, ...).

```dart
const _sharedExternal = {
  "test_mode": false,  // true → bỏ qua whitelist (chỉ dùng khi test)
  "provider_configs": {
    "amb-vn": {
      "game_type": "live",
      "mobile_orientation": ["portraitUp", "portraitDown"],
      "open_in_new_tab_on_ios_safari_web": true,
      "requires_session_guard": true,
      "load_stop_debounce_ms": 777,
      "games": [
        {"game_code": "mx-live-001", "image": "amb-vn_MX-LIVE-001_baccarat-classic_thumb.webp"},
        // ...
      ],
    },
    // lcevo, vivo, via-casino-vn, ...
  },
};
```

Chỉ các game có `game_code` nằm trong `games[]` mới được phép load (trừ khi `test_mode: true`).

---

## Cách chỉnh sửa preset

### Thêm game mới vào in-house catalog

Mở `in_house_presets.dart`, thêm entry vào `catalog` và `visibility`:

```dart
// Trong catalog:
{
  "provider_id": "sunwin",
  "provider_name": "Sunwin",
  "product_id": "sunwin_NEW_GAME",
  "game_code": "NEW_GAME",        // phải unique
  "game_name": "Tên game",
  "image": "sunwin_NEW_GAME_ten-game_thumb.webp",
  "lang": "vi",
  "game_type": "slot",            // slot | fish | card | live | mini_game | ...
  "mobile_orientation": ["landscape"],
  "tablet_orientation": ["landscape"],
  "base_url_key": "avenger_base_url",  // key trong urls_presets.dart
  "launch_strategy": "standard",
  "enable_host_message": true,
},

// Trong visibility:
"NEW_GAME": {"is_visible": true, "status": "active"},
```

### Ẩn/hiện game

Chỉ sửa `visibility` map trong `in_house_presets.dart`:

```dart
// Ẩn game
"POKER-SUN": {"is_visible": false, "status": "active"},

// Hiện lại
"POKER-SUN": {"is_visible": true, "status": "active"},
```

### Thay đổi thứ tự hiển thị

Sửa mảng `order` trong `display_presets.dart`:

```dart
"order": [
  "SC",      // ← game xuất hiện đầu tiên
  "SP",
  "VT",
  "NEW_GAME", // ← thêm game mới vào vị trí mong muốn
  // ...
],
```

### Thêm game vào collection

```dart
"collections": {
  "popular": ["SC", "SP", "VT", "NEW_GAME"],  // ← thêm vào đây
  "featured": ["SC", "SP"],
},
```

### Thêm provider mới (external)

Thêm entry vào `provider_configs` trong `external_presets.dart`:

```dart
"new-provider": {
  "game_type": "live",
  "mobile_orientation": ["portraitUp", "portraitDown"],
  "games": [
    {"game_code": "game-001", "image": "new-provider_game-001_thumb.webp"},
  ],
},
```

---

## Export & Mode switching

### Lệnh Makefile

| Lệnh | Tác dụng |
|------|---------|
| `make export-casino-config` | Export tất cả preset → JSON + b64 trong `packages/caxilo_config/config_exports/` |
| `make encode-casino-config` | Re-encode các file JSON đã edit → b64 (không regenerate từ preset) |
| `make run-local-staging` | Chạy app với staging config local (không cần GitHub) |
| `make run-local-prod` | Chạy app với prod config local |
| `make build-local-staging` | Build web staging với local JSON baked in |
| `make build-local-prod` | Build web prod với local JSON baked in |

### Dev mode (mặc định)

```bash
flutter run
# → App dùng Dart preset (dev), không cần dart-define gì
```

### Local test mode (trước khi push GitHub)

```bash
# 1. Export preset thành file
make export-casino-config
# → packages/caxilo_config/config_exports/caxilo_config_staging.json

# 2. (Tuỳ chọn) Chỉnh sửa file JSON
nano packages/caxilo_config/config_exports/caxilo_config_staging.json
make encode-casino-config   # re-encode sau khi edit

# 3. Chạy / build với config local
make run-local-staging
make build-local-staging
```

### Remote mode (sau khi push GitHub)

```bash
# Build với URL remote từ GitHub
flutter build web --release \
  --dart-define APP_ENV=prod \
  --dart-define CASINO_CONFIG_URL=https://raw.githubusercontent.com/org/repo/main/caxilo_config_prod.b64
```

---

## Thêm môi trường mới

Nếu cần thêm một môi trường mới (ví dụ: `qa`):

1. Thêm value vào `CaxiloEnvironment` enum trong `caxilo_config_presets.dart`
2. Thêm URL map trong `urls_presets.dart`
3. Cập nhật `_getUrlsForEnv()` switch trong `caxilo_config_presets.dart`
4. Cập nhật `caxiloEnvProvider` trong `lib/features/game/game_providers.dart`
5. Chạy `make export-casino-config` để generate file cho môi trường mới

---

## Troubleshooting

### `make run-local-staging` báo "No such file"

```
cat: packages/caxilo_config/config_exports/caxilo_config_staging.b64: No such file or directory
```

→ Chạy `make export-casino-config` trước.

### App log in `❌ CaxiloConfig: CASINO_CONFIG_JSON parse failed`

Config JSON bị lỗi format. Kiểm tra bằng:

```bash
python3 -m json.tool packages/caxilo_config/config_exports/caxilo_config_staging.json
```

Nếu đã edit JSON thủ công, re-encode:

```bash
make encode-casino-config
```

### App vẫn dùng config cũ sau `make run-local-staging`

`String.fromEnvironment` được compile vào binary — cần **full restart** (không phải hot reload).

### Muốn test một game cụ thể mà không sửa Dart preset

```bash
# 1. Export
make export-casino-config

# 2. Edit JSON thủ công
nano packages/caxilo_config/config_exports/caxilo_config_dev.json

# 3. Re-encode
dart run packages/caxilo_config/tool/export_config.dart --encode \
  packages/caxilo_config/config_exports/caxilo_config_dev.json

# 4. Run với override
flutter run --dart-define APP_ENV=dev \
  --dart-define "CASINO_CONFIG_JSON=$(cat packages/caxilo_config/config_exports/caxilo_config_dev.b64)"
```

---

## Liên quan

- [`packages/caxilo_config/README.md`](../packages/caxilo_config/README.md) — Quick reference
- [`packages/caxilo_config/CHANGELOG.md`](../packages/caxilo_config/CHANGELOG.md) — Lịch sử thay đổi
- [`CAXILO_NAMING_CONVENTION.md`](CAXILO_NAMING_CONVENTION.md) — Convention đặt tên class
- [`packages/caxilo_config/docs/CAXILO_CONFIG_JSON_SPEC_v2.md`](../packages/caxilo_config/docs/CAXILO_CONFIG_JSON_SPEC_v2.md) — JSON schema đầy đủ
