# CHANGELOG

## 3.6.0 (2026-05-03)

### Restructure, Bug Fix & Remote Config Tests

**Presets relocation** — `lib/src/config/presets/` → `lib/src/presets/` (ngang hàng với `client/`).
Public API không thay đổi; `lib/presets.dart` (CLI barrel) và `lib/caxilo_config.dart` đều cập nhật tự động.

**Bug fix** — `CaxiloConfigClient.fetchSettings`: generic `catch (e)` trước đây dùng `rethrow`
nên ném ra exception gốc (`FormatException`, ...) thay vì `CaxiloConfigFetchException`. Đã sửa
thành `throw fetchEx` để đảm bảo caller luôn nhận `CaxiloConfigException` subtype.

**Config exports output** — Default output dir của `tool/export_config.dart` chuyển từ
`conductor/config_exports/` sang `packages/caxilo_config/config_exports/` (trong package).
Makefile targets cập nhật theo.

**Remote config URLs** — Staging và prod URLs chính thức:
- Staging: `https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_staging.json`
- Prod: `https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_prod.json`

**Tests** — Thêm `test/src/remote_config_test.dart`:
- 5 unit tests (mock HTTP): base64 decode, 404, malformed body, `sync()` call, `sync()` no-op
- 2 live tests (`--tags live`): staging URL, prod URL — hit GitHub raw thật

---

## 3.5.0 (2026-05-03)

### Config Export & 3-Mode Management

- **`CaxiloConfigPresets.toJsonString(env, {pretty})`** — Exports preset config as a
  formatted JSON string. `pretty: true` (default) = 2-space indent for review/diff;
  `pretty: false` = compact, suitable for base64 encoding.
- **`CaxiloConfigPresets.toBase64String(env)`** — Exports config as base64-encoded JSON,
  compatible with `CaxiloConfigClient.fetchSettings()`, `--dart-define CASINO_CONFIG_JSON`,
  and GitHub raw file hosting.
- **`tool/export_config.dart`** — CLI script with two modes:
  - Generate: `dart run tool/export_config.dart [dev|staging|prod|all] [output_dir]`
  - Encode: `dart run tool/export_config.dart --encode <json_file>` (re-encode edited JSON)
- **`CASINO_CONFIG_JSON` dart-define** (app-side, `lib/features/game/game_providers.dart`) —
  New Priority 1 override: bakes a base64-encoded JSON config into the binary at build time,
  taking precedence over remote sync. Used for local staging/prod testing before GitHub push.
- **Makefile targets**: `export-casino-config`, `encode-casino-config`,
  `run-local-staging`, `run-local-prod`, `build-local-staging`, `build-local-prod`.
- **Documentation**: `conductor/CAXILO_CONFIG_MANAGEMENT.md` — comprehensive guide covering
  preset file structure, editing examples, mode switching, and troubleshooting.

**No breaking changes.** Dart preset files, model classes, client behavior, and JSON wire
format are all unchanged.

---

## 3.4.0 (2026-05-03)

### Sub-model Suffix Rename: `*Settings` → `*Config`

Pure rename — no logic change, no JSON wire format change, no behavior change.

**Class renames:**

| Old | New |
|-----|-----|
| `DisplaySettings` | `DisplayConfig` |
| `LobbySettings` | `LobbyConfig` |
| `LobbySectionSettings` | `LobbySectionConfig` |
| `LobbySectionSettingsX` | `LobbySectionConfigX` |
| `CategorySettings` | `CategoryConfig` |
| `InHouseGameSettings` | `InHouseConfig` |
| `ExternalProviderSettings` | `ExternalConfig` |
| `ExternalProviderSettingsX` | `ExternalConfigX` |

**File renames:**

| Old | New |
|-----|-----|
| `display_settings.dart` | `display_config.dart` |
| `lobby_settings.dart` | `lobby_config.dart` |
| `category_settings.dart` | `category_config.dart` |
| `in_house/in_house_game_settings.dart` | `in_house/in_house_config.dart` |
| `external/external_provider_settings.dart` | `external/external_config.dart` |

**Not renamed:** `ExternalProviderConfig` (already uses `Config` suffix), `InHouseGame`, `InHouseGameVisibility`, `ExternalGame`, `CaxiloFilter`, `CaxiloFilterStrategy`.

**Rationale:** Align sub-model suffix with root model `CaxiloConfig` and package name `caxilo_config`. See [`conductor/CAXILO_NAMING_CONVENTION.md`](../../conductor/CAXILO_NAMING_CONVENTION.md).

---

## 3.3.0 (2026-05-03)

### Package Rename: `casino_settings` → `caxilo_config`

- **Package renamed** — directory `packages/casino_settings/`, pubspec name, and barrel file updated to `caxilo_config`.
- **Class renames** (pure rename, no behavior change):
  - `CasinoSettings` → `CaxiloConfig`
  - `CasinoSettingsClient` → `CaxiloConfigClient`
  - `CasinoSettingsException` / `*ParseException` / `*FetchException` / `*NotFoundException` → `CaxiloConfig*`
  - `CasinoSettingsStatus` / `*Initial` / `*Loading` / `*Loaded` / `*Failure` → `CaxiloConfigStatus*`
  - `CasinoSettingsPresets` → `CaxiloConfigPresets`
  - `CasinoFilter` → `CaxiloFilter`
  - `CasinoFilterStrategy` → `CaxiloFilterStrategy`
  - `CasinoEnvironment` → `CaxiloEnvironment`
  - `CasinoGameImages` → `CaxiloGameImages`
- **Not renamed**: `CategorySettings`, `DisplaySettings`, `LobbySettings`, `FilterSettings`, `GameType`, `GameStatus`, `GameLaunchStrategy`, `GameOrientation`, `InHouseGame`, `InHouseGameSettings`, `ExternalGame`, `ExternalProviderSettings`.
- **Import convention**: consumers should use `import 'package:caxilo_config/caxilo_config.dart' as cc;`.
- **JSON wire format unchanged** — `@JsonKey` annotations preserved; serialization behavior identical.
- **Docs renamed**: `docs/CASINO_SETTINGS_FULL_DESIGN.md` → `docs/CAXILO_CONFIG_DESIGN.md`, `docs/CASINO_SETTINGS_JSON_SPEC_v2.md` → `docs/CAXILO_CONFIG_JSON_SPEC_v2.md`.

---

## 3.2.0 (2026-05-03)

### Lobby Settings Grouping (Breaking Schema Change)

- **`LobbySettings` model** — New Freezed model grouping all lobby-related config under a single `lobby` JSON key. Replaces the flat `lobby_category` + `lobby_sections` sibling fields.
  - `translation_key`, `icon`, `icon_active` — lobby tab presentation (optional; repository falls back to hardcoded preset when null)
  - `sections` — SDUI home layout (previously `lobby_sections`)
- **`CaxiloConfig.lobby`** — Replaces `CaxiloConfig.lobbyCategory` and `CaxiloConfig.lobbySections`.
- **`LobbySettings` removed** — Was an intermediate separate model (v3.1.0); its 3 fields are now inlined into `LobbySettings` to avoid unnecessary nesting.
- **Presets updated** — `_sharedLobby` replaces `_sharedLobbyCategory` + `_sharedLobbySections` in `display_presets.dart`.

**JSON schema change:**
```json
// Before (3.1.0)
{ "lobby_category": { "translation_key": "...", "icon": "...", "icon_active": "..." },
  "lobby_sections": [...] }

// After (3.2.0)
{ "lobby": { "translation_key": "...", "icon": "...", "icon_active": "...", "sections": [...] } }
```

## 3.1.0 (2026-05-02)

### Remote-Configurable Category & Sidebar

- **`CategorySettings.groupKey`** — New optional field `group_key` (`'priority'` | `'standard'`). Controls sidebar grouping in the repository. When absent, the repository falls back to type-based classification (backward compatible).
- **Presets updated** — `categories_presets.dart` adds `group_key` to all categories (`sunwin`, `jackpot` → `priority`; all others → `standard`; `sports` has no key → excluded from sidebar).

## 3.0.0 (2026-05-02)

### Casino SDUI Flattening (v3.0.0) 🏗️

- **Breaking Change**: Flattened `CategorySettings` architecture. Removed complex `sealed union` types (`gameType`, `inHouse`, `custom`) and replaced them with a mandatory `CaxiloFilter` property.
- **Model Standardization**: Converted Freezed models with a single factory from `sealed class` to `abstract class` for project-wide consistency (`CaxiloConfig`, `CategorySettings`, `CaxiloFilter`, `ExternalGame`, `ExternalProviderConfig`, `ExternalProviderSettings`).
- **In-House Strategy Support**: Added `in_house` value to `CaxiloFilterStrategy` to handle internal game filtering through the unified SDUI strategy pattern.
- **Preset Synchronization**: Updated `categories_presets.dart` to fully comply with the new JSON v3.0.0 schema.


## 2.8.0 (2026-05-02)

### SDUI Filter Standardization 🏗️

- **Unified Filter Schema**: Merged `CaxiloFilterStrategy` and `CaxiloFilter` into a single type-safe model, replacing separate strategy/params fields in `CategorySettings` and `LobbySectionSettings`.
- **Enum-based Strategies**: Replaced legacy String-based strategies with a structured `CaxiloFilterStrategy` Enum for better validation and exhaustiveness checking.
- **Improved Stability**: Added an explicit `unknown` strategy case with robust fallback handling to ensure app stability when encountering new server-side filtering logic.

## 2.7.0 (2026-05-01)

### Dynamic Collections & Flexibility 🎯

- **Introduced `collections` field**: Added `Map<String, List<String>> collections` to `DisplaySettings` to support arbitrary game lists defined by the server (e.g., "hot_games", "recommended").
- **Enhanced Presets**: Updated default environment configurations to include sample collections for "popular_games" and "new_games".
- **Schema Alignment**: Improved JSON schema extensibility by allowing dynamic grouping of games without requiring application binary updates.

## 2.6.0 (2026-04-30)

### Presets System & Optimization 🚀

- **Migrated Fallback to Presets**: Replaced the legacy `fallback` naming with `presets` to better describe environment-specific default configurations.
- **Removed `mobileLogin`**: Cleaned up the `InHouseGame` model by removing the deprecated `mobileLogin` field, aligning with the updated core application requirement.
- **Unified Settings Structure**: Consolidated all configuration models (Category, Display, Lobby, In-House, External) under `src/settings/` for better logical grouping.
- **Enhanced Lobby Customization**: Fully implemented the polymorphic `LobbySectionSettings` model (Strategy, In-House, GameType, Provider, Banner) to allow rich home screen layouts.
- **Documentation Sync**: Updated `README.md` and all design documents in `docs/` to reflect the latest directory structure and JSON schema enhancements.

## 2.5.0 (2026-04-30)

### External Provider Refactor 🎰

- **Consolidated Provider Fallbacks**: Migrated hardcoded provider data into `ExternalProviderSettings` as a type-safe `Map<String, ExternalProviderConfig>`.
- **SSOT Alignment**: Standardized `external_provider_settings.dart` to serve as the local fallback that complements remote `CaxiloConfig`.
- **Provider Reordering**: Unified provider configuration order to `amb-vn`, `via-casino-vn`, `vivo`, `lcevo` to match whitelist logic.
- **Cleaned Up Legacy Code**: Removed `BACKUP CODE TRACKING` section and resolved syntax errors from previous manual migrations.

## 2.4.0 (2026-04-30)

### Refactoring & Standardization 🏗️

- **Directory Structure Update**: 
    - Renamed `src/game/` to `src/in_house/` to clarify internal vs. external boundaries.
    - Renamed `src/provider/` to `src/external/` for clarity regarding 3rd-party game integrations.
- **Model Renaming**: 
    - Ensured configuration models consistently use `in_house` and `external` nomenclature.
    - Updated `ExternalGame` and `ExternalProviderSettings` definitions.
- **Flattened Architecture**:
    - Removed intermediate folders like `src/settings/` in favor of a completely flat `src/*` domain structure.

---

## 2.3.0 (2026-04-26)

### Resource Management 🖼️

- **Centralized Game Images**: Introduced `CaxiloGameImages` to manage game thumbnail filenames.
    - Decoupled filenames (managed by package) from base paths (managed by app).
    - Added `allGameImages` static list to facilitate batch preloading.
    - Standardized naming convention for 50+ game images.
- **Sorting Logic Improvements**: Refined game processing mixin to prioritize In-house games and group remote games by provider.

---

## 2.2.0 (2026-04-24)

### Standardized Naming 🏷️

- **Renamed Legacy Entities**:
    - Renamed `CasinoGameConfig` to `GameInHouse` to better reflect its role as an in-house game catalog entry.
    - Renamed `CasinoGameStatus` to `GameStatus` for brevity and clarity.
    - Renamed `CaxiloConfigClient` to `CaxiloConfigClient` to simplify the public API entry point.
- **Documentation Sync**: Updated all package documentation (`README.md`, `CASINO_SETTINGS_FULL_DESIGN.md`, `remote_config_spec.md`) to reflect these naming changes and corrected JSON schema examples.

---

## 2.1.0 (2026-04-23)

### Features 🚀

- **Dynamic Game Categories**: Introduced a polymorphic JSON configuration for game categories.
  - Supports filtering by `GameType`.
  - Supports dedicated `InHouse` hub category.
  - Supports `Custom` categories with pluggable strategies (e.g., `new_games`, `popular_games`).
- **Strategy Pattern Integration**: Decoupled configuration strings from filtering logic, allowing the app to implement complex filters dynamically.

### Bug Fixes 🛠️

- Fixed type warnings in `GameRepository` related to Stream handling and strict types.

---

## 2.0.0 (2026-04-23)

### Breaking Changes ⚠️

- **Refactored Package Structure**: 
    - Renamed `src/features/` to `src/settings/` for business logic.
    - Moved core infrastructure (`CaxiloConfigClient`, `CaxiloConfigException`) to `src/mixin/`.
    - Consolidated feature files into flat folder structures (e.g., `src/settings/game_in_house/`).
- **Standardized Naming**: Renamed `CasinoLaunchStrategy` to `GameLaunchStrategy` for project-wide consistency.
- **Updated JSON Schema (v2)**:
    - Moved `display` configuration from `in_house` section to the root level of the configuration JSON.
    - Updated `CaxiloConfig` root model and `GameInHouseSettings` to reflect this flattening.
- **Public API Exports**: Updated `lib/caxilo_config.dart` to export components from their new paths.

### Features 🚀

- Improved developer experience with a flatter, feature-based directory organization.
- Enhanced scalability for future third-party game provider integrations by separating core display logic from specific in-house catalogs.

### Bug Fixes 🛠️

- Fixed incorrect import paths in `CaxiloConfigClient` and associated tests.
- Fixed inconsistent mock data structure in `remote_config_mock.dart`.

---

## 1.1.0

### Features
- Added `GameOrientationListConverter` for alias expansion.
- Integrated `freezed` for all models.

## 1.0.0
- Initial release with In-house game support.
