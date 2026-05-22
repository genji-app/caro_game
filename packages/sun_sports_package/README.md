# sun_sports

Sun Sports — embeddable Flutter package. Generated from the **s88-flutter**
app by `convert_to_package.sh`.

## Add to a host Flutter app

In the host's `pubspec.yaml`:

```yaml
dependencies:
  sun_sports:
    path: ../sun_sports_package        # or git: url: ..., ref: ...
  flutter_riverpod: ^2.5.1
```

In the host's `main.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/sun_sports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await SunSports.init();
  runApp(ProviderScope(
    overrides: overrides,
    child: const SunSportsApp(),
  ));
}
```

A runnable host lives under `example/`. From this directory:

```bash
flutter pub get
cd example && flutter pub get && flutter run
```

## What's in the public API

| Symbol           | Source file              | Purpose                                       |
| ---------------- | ------------------------ | --------------------------------------------- |
| `SunSports.init` | `sun_sports_init.dart`   | Async bootstrap; returns Riverpod overrides   |
| `SunSportsApp`   | `sun_sports_root.dart`   | Root widget the host renders                  |
| `App`            | `app.dart`               | Underlying widget (alias of `SunSportsApp`)   |

Everything else under `lib/` is implementation detail. Do not depend on it.

## Environment variables (READ THIS)

Sun Sports uses **compile-time** environment variables via `String.fromEnvironment(...)`. These are baked into the binary by the Dart compiler at build time. **When Sun Sports is consumed as a package, the `--dart-define` flag must be passed to the HOST app's `flutter build` / `flutter run` command** — the package itself is never built standalone anymore. The compiler propagates the define down into every imported package.

### `APP_ENV` (required, primary)

Source of truth: `lib/core/env/app_env.dart` (inside this package).

| Value     | Resolves to                                                  |
| --------- | ------------------------------------------------------------ |
| `staging` | Staging brand config + staging caxilo config                 |
| `prod`    | Production brand config + production caxilo config           |

> **Default when no `--dart-define` is passed**: `staging` (set at conversion time; change by re-running the convert script with `--env=prod|staging`).

What it controls (all derived from this single var):

* `AppEnv.brandConfigUrl` → which GitHub-hosted brand JSON Sun Sports fetches at startup
* `AppEnv.caxiloConfigUrl` → which casino config to sync from
* `AppEnv.isProd` / `AppEnv.isStaging` flags used throughout the codebase

Host build commands MUST include it:

```bash
# Host run
flutter run --dart-define=APP_ENV=staging
flutter run --dart-define=APP_ENV=prod

# Host build
flutter build apk --release --dart-define=APP_ENV=prod
flutter build ios --release --dart-define=APP_ENV=prod
flutter build web --release --dart-define=APP_ENV=prod --tree-shake-icons
```

**WARNING — silent fallback**: if the host forgets `--dart-define`, the app **silently** runs as `staging` (the default in `String.fromEnvironment`). No error, no warning. To avoid this, have the host's Makefile / CI / launch.json always pass it explicitly. The original Sun Sports `Makefile` had Shorebird-specific targets enforcing this — copy that pattern into the host repo if you use Shorebird.

### `CASINO_CONFIG_JSON` (optional, local-test only)

Source: `lib/features/game/game_providers.dart`.

Lets you bake a base64-encoded caxilo config JSON directly into the binary, bypassing the GitHub fetch. Useful for local development without internet, or for testing a config change before pushing it.

The pre-generated b64 files live inside this package at:

```
packages/sun_sports/packages/caxilo_config/config_exports/caxilo_config_{dev,staging,prod}.b64
```

From a host Makefile, use:

```makefile
# Path is relative to host's pubspec.yaml location.
# Adjust PKG_PATH if your host imports sun_sports from a different location.
PKG_PATH := .dart_tool/pub_dependencies/sun_sports
# Or if using a path: dependency:
# PKG_PATH := ../sun_sports_package

run-local-staging:
	flutter run --dart-define=APP_ENV=staging \
	  --dart-define="CASINO_CONFIG_JSON=$$(cat $(PKG_PATH)/packages/caxilo_config/config_exports/caxilo_config_staging.b64)"
```

Or copy the b64 files into the host repo and point at them there. The original `Makefile` (deleted by this script) has the full pattern at the top under "Caxilo Config Management".

### Custom URLs for a different brand

If the host needs to point at different brand/caxilo URLs than the hard-coded ones in `AppEnv`, the cleanest refactor is to convert `AppEnv` into a configurable singleton with an `AppEnv.configure({brandUrl, caxiloUrl})` method called from `SunSports.init()`. This is a manual follow-up — the script does not do it.

### Fastlane / deploy-time env vars

The Fastlane setup that lived in `fastlane/Fastfile` was deleted by this script (app-deploy infra doesn't belong in a library package). If the host repo still needs Fastlane, port the lanes there and keep using the same Ruby `ENV[...]` vars (`GMAIL_USERNAME`, `GMAIL_APP_PASSWORD`, `DIAWI_TOKEN`, `REMOTE_PATH_*`, `SERVER_HOST_*`, etc.). These are unrelated to Dart `--dart-define` and don't affect package code.

### Quick verification at runtime

After wiring up the host, add a debug print right after `SunSports.init()` to confirm the env was passed correctly:

```dart
import 'package:sun_sports/sun_sports.dart';
// Import only for the debug print — remove for production.
// ignore: implementation_imports
import 'package:sun_sports/core/env/app_env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await SunSports.init();
  debugPrint('SunSports running as: ${AppEnv.current.name}'); // staging or prod
  runApp(...);
}
```

If this prints `staging` when you expected `prod`, the host build command is missing `--dart-define=APP_ENV=prod`.

## Manual follow-up checklist

The script handles structure, public API, and example host. You still need to:

- [ ] **Environment variables** — host `flutter run` / `flutter build` commands MUST include `--dart-define=APP_ENV=staging` or `--dart-define=APP_ENV=prod`. See the "Environment variables" section above. Missing this silently falls back to `staging`.
- [ ] **Host AndroidManifest**: declare `<uses-permission android:name="android.permission.INTERNET" />` and any others (camera, microphone, network state) required by `webview_flutter`, `audioplayers`, `video_player`, `connectivity_plus`.
- [ ] **Host iOS Info.plist**: add `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSAppTransportSecurity` entries if those features are used.
- [ ] **Image assets**: bundled assets (under `assets/`) must be declared in this package's `pubspec.yaml` under `flutter: assets:`. Inside this package's source code, prefer `Image.asset('assets/foo.png', package: 'sun_sports')` so the asset resolves correctly when consumed by a host. Existing call sites in `lib/` may still use bare paths — audit and update.
- [ ] **Version pins**: host MUST use compatible major versions of `flutter_riverpod`, `hive`, `dio`, `freezed_annotation`. Version skew causes confusing runtime errors. Easiest fix: copy these dependency versions from this package's `pubspec.yaml` into the host's.
- [ ] **PiP support**: `flutter_in_app_pip` requires PiP plumbing in the host's `MainActivity` (Android) and `AppDelegate` (iOS). See that package's README.
- [ ] **Hive box names**: if the host also uses Hive, rename boxes to avoid collisions (`sun_sports_<box_name>`). Search for `Hive.openBox(` / `Hive.box(` in `lib/`.
- [ ] **Router ownership**: `lib/app.dart` owns its own `GoRouter` and `MaterialApp.router`. If the host wants to own routing, refactor `App` to expose a routerless variant.
- [ ] **WebSocket lifecycle**: streams are bound to the `App` widget's lifecycle — host must unmount `SunSportsApp` cleanly to cancel subscriptions.
- [ ] **Code generation**: from this directory, run `dart run build_runner build --delete-conflicting-outputs` after any model/state change.

## What the script removed

App-only scaffolding the package doesn't need:

- Native folders: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`
- `lib/main.dart` (entry point — replaced by `SunSports.init`)
- `firebase.json`, `Gemfile`, `Gemfile.lock`, `fastlane/`
- `test_scroll.html`, `TheCaoTopupView.ts`, `SUN88_v2/`
- `.idea/`, `.vscode/`, `.dart_tool/`, `build/`, `.git/`

Local packages under `packages/` are preserved and continue to be resolved by
relative `path:` references in this package's `pubspec.yaml`.
