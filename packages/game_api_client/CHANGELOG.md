# Changelog

## 0.0.1 (2026-04-01)

### 📦 Initial Release

- Initial extraction of `game_api_client` from `lib/core` as a standalone Pure Dart package.
- Transitioned to Pure Dart (no depends on `sdk: flutter`) using `package:meta` and basic platform abstractions.
- Adopted VGV style architecture:
  - Internals hidden in `lib/src`.
  - Public interface exposed via `lib/game_api_client.dart`.
- Included models for:
  - `ProviderGames`: List of game providers and games.
  - `GetGameUrlRequest`: Game launch request data.
  - `GameUrlData`: Resulting game URL data.
  - `GameApiResponse`: Unified API response wrapper.
- Interceptors:
  - `GameApiErrorInterceptor`: Unified business error handling.
  - `GameApiTokenRefreshInterceptor`: Standard 401 token refresh mechanism.
- Analysis & Quality:
  - Enabled `flutter_lints` for coding standards.
  - Full support for `freezed` and `json_serializable` code generation.
