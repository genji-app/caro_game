# Migration: `casino_settings` → `caxilo_config`

**Ngày thực hiện**: 2026-05-03  
**Branch**: `feature/improve_remote_settings_casino`

---

## Lý do

Package `casino_settings` cung cấp config models, client và enums cho casino domain, nhưng dùng prefix `Casino` không nhất quán với convention `caxilo_` đang được áp dụng trong toàn bộ codebase (`caxilo_repository`). Refactor này đồng bộ naming để:

- Tất cả casino-domain packages dùng prefix `caxilo_`
- Import alias `as cc` làm rõ nguồn gốc của types

---

## Nguyên tắc Bảo toàn Dữ liệu

Đây là rename thuần túy — **không thay đổi logic, JSON schema, hay API shape**.

| Nguyên tắc | Chi tiết |
|-----------|---------|
| JSON serialization | `@JsonKey` annotations giữ nguyên → JSON wire format không đổi |
| Freezed behavior | `copyWith`, `==`, `hashCode`, pattern matching hoạt động như cũ |
| `part` directives | Đã cập nhật khớp tên file mới trước khi `make gen` |
| Re-export chain | `caxilo_repository` re-export `caxilo_config` không bị gián đoạn |
| Legacy providers | Variable names giữ nguyên, chỉ type annotations được cập nhật |

---

## Bảng đổi tên Package

| Thành phần | Cũ | Mới |
|-----------|-----|-----|
| Thư mục | `packages/casino_settings/` | `packages/caxilo_config/` |
| pubspec name | `casino_settings` | `caxilo_config` |
| Barrel file | `lib/casino_settings.dart` | `lib/caxilo_config.dart` |
| Import alias | (không có) | `as cc` |

---

## Bảng đổi tên Class/Enum

| Cũ | Mới |
|----|-----|
| `CasinoSettings` | `CaxiloConfig` |
| `CasinoSettingsClient` | `CaxiloConfigClient` |
| `CasinoSettingsException` | `CaxiloConfigException` |
| `CasinoSettingsParseException` | `CaxiloConfigParseException` |
| `CasinoSettingsFetchException` | `CaxiloConfigFetchException` |
| `CasinoSettingsNotFoundException` | `CaxiloConfigNotFoundException` |
| `CasinoSettingsStatus` | `CaxiloConfigStatus` |
| `CasinoSettingsStatusInitial` | `CaxiloConfigStatusInitial` |
| `CasinoSettingsStatusLoading` | `CaxiloConfigStatusLoading` |
| `CasinoSettingsStatusLoaded` | `CaxiloConfigStatusLoaded` |
| `CasinoSettingsStatusFailure` | `CaxiloConfigStatusFailure` |
| `CasinoSettingsPresets` | `CaxiloConfigPresets` |
| `CasinoFilter` | `CaxiloFilter` |
| `CasinoFilterStrategy` | `CaxiloFilterStrategy` |
| `CasinoEnvironment` | `CaxiloEnvironment` |
| `CasinoGameImages` | `CaxiloGameImages` |

> **Không đổi tên**: `CategorySettings`, `DisplaySettings`, `LobbySettings`, `FilterSettings`, `GameType`, `GameStatus`, `GameLaunchStrategy`, `GameOrientation`, `InHouseGame`, `InHouseGameSettings`, `InHouseGameVisibility`, `ExternalGame`, `ExternalProviderSettings`

---

## Bảng đổi tên File trong `lib/src/`

| Cũ | Mới |
|----|-----|
| `client/casino_settings_client.dart` | `client/caxilo_config_client.dart` |
| `client/casino_settings_exceptions.dart` | `client/caxilo_config_exceptions.dart` |
| `client/casino_settings_state.dart` | `client/caxilo_config_state.dart` |
| `settings/casino_settings.dart` | `settings/caxilo_config.dart` |
| `settings/casino_game_images.dart` | `settings/caxilo_game_images.dart` |
| `settings/presets/casino_settings_presets.dart` | `settings/presets/caxilo_config_presets.dart` |

---

## Files bị ảnh hưởng

| File | Loại thay đổi |
|------|--------------|
| `packages/caxilo_config/pubspec.yaml` | Rename package name |
| `packages/caxilo_config/lib/caxilo_config.dart` | Rename barrel + update exports |
| `packages/caxilo_config/lib/src/client/*.dart` | Rename + update class names |
| `packages/caxilo_config/lib/src/settings/*.dart` | Rename + update class names |
| `packages/caxilo_config/lib/src/settings/common/filter_settings.dart` | Update class names |
| `packages/caxilo_config/lib/src/settings/presets/*.dart` | Rename + update part-of |
| `pubspec.yaml` (main app) | Update dependency key + path |
| `packages/caxilo_repository/pubspec.yaml` | Update dependency key + path |
| `packages/caxilo_repository/lib/caxilo_repository.dart` | Update re-export URL |
| 10 files trong `caxilo_repository/lib/src/` | `import as cc` + prefix types |
| `lib/core/utils/styles/app_images.dart` | `import as cc` + prefix `CaxiloGameImages` |
| `lib/features/game/game_providers.dart` | Update type references (legacy) |
| 8 test files trong `packages/caxilo_config/test/` | `import as cc` + prefix types |

---

## Hướng dẫn cho consumer code mới

```dart
// Import với alias cc
import 'package:caxilo_config/caxilo_config.dart' as cc;

// Sử dụng client
final client = cc.CaxiloConfigClient.create(
  environment: cc.CaxiloEnvironment.prod,
  initialUrl: configUrl,
);

// Sử dụng filter
const filter = cc.CaxiloFilter(
  strategy: cc.CaxiloFilterStrategy.byGameType,
);

// Sử dụng status
if (client.status is cc.CaxiloConfigStatusLoaded) { ... }
```

> Nếu đang dùng qua `caxilo_repository` (không import trực tiếp), types được re-export mà không cần `as cc`.
