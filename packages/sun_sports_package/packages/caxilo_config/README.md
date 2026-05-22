# caxilo_config

A standalone Flutter package for managing in-house casino configurations, game visibility, display logic, game thumbnail resource mapping, and streamlined game launching strategies.

> Formerly `casino_settings`. All `Casino*` class names have been renamed to `Caxilo*` / unprefixed equivalents. See [`docs/CAXILO_CONFIG_MIGRATION.md`](docs/CAXILO_CONFIG_MIGRATION.md) for the full mapping.

---

## Key Features

- **Unified Models**: `GameType` and `GameOrientation` used project-wide.
- **Dynamic Configuration**: Freezed models for parsing complex remote JSON (catalog, visibility, display, lobby).
- **Flexible Launch Strategies**: Pluggable `LaunchStrategy` implementations (`StandardLaunchStrategy`, `FishLaunchStrategy`).
- **Game Image Management**: Centralized `CaxiloGameImages` constants for thumbnail filenames.
- **Data-Driven Categories**: Category generation fully driven by remote config via `CategoryConfig`.
- **Unified Client**: `CaxiloConfigClient` manages config lifecycle and game URL resolution.
- **Orientation Alias Support**: Expands server-side aliases (`portrait`, `landscape`, `all`) into Flutter orientations.
- **Environment Presets**: `CaxiloConfigPresets` for instant environment-safe initialization.

---

## Installation

```yaml
dependencies:
  caxilo_config:
    path: packages/caxilo_config
```

---

## Usage Guide

### 1. Initialize Client

`CaxiloConfigClient` is the single entry point for storing and parsing the remote configuration.
Use the `create` factory for an Offline-First setup with environment-specific presets.

```dart
import 'package:caxilo_config/caxilo_config.dart' as cc;

final settingsClient = cc.CaxiloConfigClient.create(
  environment: cc.CaxiloEnvironment.prod,
  tokenProvider: () => 'user-session-token',
  refreshTokenProvider: () => 'refresh-token',
);

print('Config version: ${settingsClient.config?.version}');
```

### 2. Game Image Mapping

Use `CaxiloGameImages` for consistent filename mapping instead of hardcoded strings.

```dart
// In your app's image styling class:
static String get gameThumb => '$IMAGES_BASE_PATH/${cc.CaxiloGameImages.sunwinAvengerAvenger}';

// Batch preloading:
final allUrls = cc.CaxiloGameImages.allGameImages.map((name) => '$base/$name').toList();
```

### 3. Get Game Launch URL

```dart
try {
  final url = await settingsClient.getGameUrl(gameCode: 'AVENGER');
  print('Launch URL: $url');
} on cc.CaxiloConfigException catch (e) {
  print('Error: ${e.message}');
}
```

### 4. Filter Config

```dart
const filter = cc.CaxiloFilter(
  strategy: cc.CaxiloFilterStrategy.byGameType,
  params: {'game_type': 'slot'},
);
```

---

## Directory Structure

```
lib/
├── caxilo_config.dart               — Main barrel (Flutter app)
├── presets.dart                     — Dart-only barrel (CLI tools, no dart:ui)
└── src/
    ├── client/
    │   ├── caxilo_config_client.dart    — Main client
    │   ├── caxilo_config_exceptions.dart
    │   └── caxilo_config_state.dart
    ├── config/
    │   ├── caxilo_config.dart           — CaxiloConfig (root Freezed model)
    │   ├── caxilo_game_images.dart      — CaxiloGameImages
    │   ├── common/                      — GameType, GameOrientation, CaxiloFilter
    │   ├── in_house/                    — InHouseGame, InHouseConfig
    │   ├── external/                    — ExternalGame, ExternalConfig, ExternalProviderConfig
    │   └── ...
    └── presets/
        ├── caxilo_config_presets.dart   — CaxiloConfigPresets, CaxiloEnvironment
        ├── urls_presets.dart
        ├── display_presets.dart
        ├── categories_presets.dart
        ├── in_house_presets.dart
        ├── external_presets.dart
        └── backup_presets.dart
```

---

## Config Management (3-Mode System)

| Mode | Lệnh | Config source |
|------|------|---------------|
| **Dev** | `flutter run` | Dart preset (hardcoded, mặc định) |
| **Local Test** | `make run-local-staging` | JSON file export tại `packages/caxilo_config/config_exports/` |
| **Remote** | `--dart-define CASINO_CONFIG_URL=<url>` | GitHub raw URL |

```bash
# Export preset → JSON + base64
make export-casino-config

# Test staging/prod locally (trước khi push GitHub)
make run-local-staging
make build-local-staging
```

Xem hướng dẫn đầy đủ: [`docs/CAXILO_CONFIG_MANAGEMENT.md`](docs/CAXILO_CONFIG_MANAGEMENT.md)

> **Staging URL**: `https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_staging.json`  
> **Prod URL**: `https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_prod.json`

---

## Development

- **Code gen**: `dart run build_runner build --delete-conflicting-outputs`
- **Export config**: `dart run tool/export_config.dart [dev|staging|prod|all] [output_dir]`
- **Analysis**: `dart analyze`
- **Docs**: [`docs/CAXILO_CONFIG_DESIGN.md`](docs/CAXILO_CONFIG_DESIGN.md), [`docs/CAXILO_CONFIG_JSON_SPEC_v2.md`](docs/CAXILO_CONFIG_JSON_SPEC_v2.md)

---

*Developed by Trippy*
