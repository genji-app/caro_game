# Changelog — caxilo_repository

## [2.0.0] — 2026-05-03

### ⚠️ Breaking Changes: API Refactor

- **Renamed `settingsClient` to `configClient`**: Updated the `CaxiloRepository` constructor and all internal mixins (`CaxiloCategoryMixin`, `CaxiloDataProcessorMixin`, `CaxiloLobbyMixin`, `CaxiloSearchEngineMixin`, `CaxiloUrlResolverMixin`) to use `configClient` for better consistency with the `caxilo_config` package.
- **Renamed `CaxiloBlock` to `CaxiloGameBlock`**: Refactored the core domain model and its subtypes:
  - `CaxiloGameBlock.liveStream` → `CaxiloGameBlockLiveStream`
  - `CaxiloGameBlock.inHouse` → `CaxiloGameBlockInHouse`
- **Removed Legacy Typedefs**: Cleaned up `caxilo_compat.dart` by removing redundant legacy type aliases (`GameInHouse`, `CaxiloFilterStrategy`, etc.).

### 🛠️ Internal Improvements

- **Standardized Import Aliases**: Changed `import as cc` to `import as caxiloconfig` across the package to improve code readability.
- **Documentation Fixes**: Corrected typos in `CaxiloCategoryMixin` and updated `README.md` examples to align with the new API.
- **Test Alignment**: Updated all unit tests and mocks in `test/` to reflect the naming changes.

---

## [1.8.0] — 2026-05-03

### 🔖 Dependency Rename: `casino_settings` → `caxilo_config`

- Updated dependency from `casino_settings` to `caxilo_config` (package rename, no API changes).
- All internal `import as cc` references initially updated to `package:caxilo_config/caxilo_config.dart` (later standardized to `as caxiloconfig` in v1.9.0).
- Re-export in `caxilo_repository.dart` now hides `CaxiloFilter`, `CaxiloFilterStrategy`, `$CaxiloFilterCopyWith`, `CaxiloFilterPatterns` to prevent ambiguity with the repository's own domain `CaxiloFilter`.
- No behavior changes — all public API and domain models remain identical.

---

## [1.7.0] — 2026-05-03

### ✨ Added — Remote-Configurable Lobby, Category & Sidebar

**`CaxiloCategoryMixin`**
- **`getCaxiloCategories()` reads from `CaxiloConfig.lobby`** — The "All/Home" tab config
  (`translationKey`, `icon`, `iconActive`) is now driven by `LobbySettings` fields on the
  server. Falls back to hardcoded `getLobbyCategory()` when any field is null (backward compatible).

- **`getCaxiloSidebarData()` uses `CategorySettings.groupKey`** — Server assigns each category to
  `'priority'` or `'standard'` group via the new `group_key` field. Falls back to type-based
  classification (in-house → priority, sport → excluded, others → standard) when `groupKey` is null.

- **`_classifyByType()` extracted** — Internal helper for backward-compatible type-based sidebar
  grouping; no behavior change for configs without `group_key`.

**`CaxiloLobbyMixin`**
- Updated to read `config?.lobby?.sections` (aligned with `caxilo_config` v3.2.0 schema).

### 🧪 Tests

- Added `getCaxiloCategories` test group (2 cases): remote lobby tab override, fallback to
  hardcoded when lobby fields are absent.
- Added `getCaxiloSidebarData` test group (2 cases): `groupKey`-driven classification, fallback
  type-based classification with sport excluded.

---

## [1.6.0] — 2026-05-02

### ✨ Added

- **`CaxiloFilter` presets** — 8 static const shorthands mirroring `display_presets` collections and strategies:
  `CaxiloFilter.featured`, `.popular`, `.newGames`, `.inHouse`, `.live`, `.slots`, `.cardGames`, `.jackpots`.
  Callers no longer need to construct filters manually for common cases.

- **Domain-typed failure hierarchy** — Replaced operation-typed failures with domain-typed sealed classes:
  `CaxiloNetworkFailure`, `CaxiloAuthFailure`, `CaxiloMaintenanceFailure`,
  `CaxiloComingSoonFailure`, `CaxiloDisabledFailure`, `CaxiloUnderDevelopmentFailure`,
  `CaxiloServerFailure`, `CaxiloBusinessFailure`, `CaxiloUnknownFailure`.
  Each carries `isRetryable` and preserves `source` for logging.
  `CaxiloBusinessFailure` exposes `.message` for operator-defined API error messages.

- **`mapToCaxiloFailure(Object)`** — Idempotent top-level function mapping any exception
  (`InHouseGameException` subtypes, `GameApiException` types, arbitrary errors) to the correct
  domain failure subtype.

- **Test coverage** — Three new test files:
  - `caxilo_failure_test.dart` — 26 cases covering all failure types, `isRetryable`, `source`, and mapper
  - `caxilo_sort_test.dart` — 11 cases for `mergeAndSortGames` mixed ordering
  - `caxilo_collection_order_test.dart` — 8 cases for per-section collection ordering

### 🛠️ Changed

- **`mergeAndSortGames` (BREAKING-BEHAVIOR)** — Simplified sort from 4-priority-group system to 3 rules:
  1. Both in `display.order` → follow exact server index (fully mixed in-house + remote allowed)
  2. Only one in `display.order` → ordered game comes first
  3. Neither → in-house before remote, then provider, then name

  **Impact**: Remote games can now appear before in-house games when `display.order` specifies it.
  This enables full SDUI-driven mixed ordering.

- **`applySearchAndFilter` — per-section collection ordering (Option B)** — When filter is
  `CollectionFilter`, results are sorted by the collection array order from `display.collections`,
  independent of the global `display.order`. Different sections can now have different orderings
  for the same game.

- **`getPopularGamesFromList` / `getPopularGames`** — Removed `limit` parameter.
  The `popular` collection is the single source of truth for how many games appear;
  client-side truncation was anti-SDUI. Now uses `CaxiloFilter.popular` preset internally.

- **`CaxiloUrlResolverMixin`, `CaxiloLobbyMixin`, `CaxiloRepository`** — All catch blocks now
  call `mapToCaxiloFailure()` and rethrow as domain failures, replacing ad-hoc operation-typed wrappers.

### ⚠️ Breaking Changes

- `getPopularGames({int limit = 5})` → `getPopularGames()` — `limit` parameter removed.
- `getPopularGamesFromList(games, {int limit = 5})` → `getPopularGamesFromList(games)` — same.
- Old operation-typed failure classes (`GetCaxiloGamesFailure`, `GetCaxiloLobbyFailure`,
  `GetCaxiloUrlFailure`) are removed. Callers should catch `CaxiloFailure` and switch on subtype.

---

## [1.5.0] — 2026-05-15

### ⚠️ Breaking Changes
- **Flattened `CaxiloCategory` Architecture**: Replaced multiple factory constructors with a single unified constructor to improve model consistency.
- **Mandatory Filter Property**: Added `filter` as a required parameter to `CaxiloCategory`, ensuring full compatibility with the latest SDUI requirements.
- **Extension Cleanup**: Simplified `CaxiloCategoryX` extension methods to reflect the updated class structure.

---

## [1.4.0] — 2026-05-02

### ✨ Added — Flattened SDUI Support (v3.0.0)

- **Architecture Alignment**: Updated `CaxiloCategory` logic to align with the flattened `CategorySettings` model from `caxilo_config` v3.0.0.
- **Improved Filter Mapping**: Enhanced `CaxiloFilter.fromStrategy` to support the `in_house` strategy directly.
- **Simplified Category Mixin**: Removed complex `when()` switching in `CaxiloCategoryMixin`, delegating all filtering logic to `CaxiloFilter.fromFilterConfig()`.
- **In-House Game Identification**: Optimized `InHouseFilter` to use the unified `isInHouse` strategy property.


All notable changes to this package are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.2.0] — 2026-05-02

### ✨ Added — Standardized SDUI Integration

- **Type-safe Strategy Mapping**: Refactored `CaxiloFilter.fromStrategy` to use the new `CaxiloFilterStrategy` Enum, eliminating String-based parsing errors.
- **Robust Fallback Mechanism**: Introduced `CaxiloFilter.none()` as a safe default when encountering unknown strategies, preventing application crashes.
- **Filter Mapping Helpers**: Added `CaxiloFilter.fromFilterConfig()` to streamline conversion from remote configuration models to domain filters.

### 🛠️ Changed

- **Mixin Modernization**: Updated `CaxiloCategoryMixin` and `CaxiloLobbyMixin` to utilize the unified filter schema, ensuring consistent categorization across the entire application.

---

## [1.1.0] — 2026-05-01

### ✨ Added — Dynamic Filtering

- **`CollectionFilter`**: New filter variant that allows client to filter games based on arbitrary named collections defined in `DisplaySettings` config.
- **`GameCodesFilter`**: New filter variant for explicit list-based matching, supporting dynamic game sets passed via category/section parameters.
- **Enhanced `fromStrategy`**: Strategy mapping now supports `'collection'` and `'by_game_codes'` keys, and automatically maps legacy `'new_games'` and `'popular_games'` to the collection-based logic.

### 🛠️ Changed

- **Refactored `CaxiloFilter`**: Removed non-functional `byReleaseDate` and `byPopularity` client-side filters in favor of server-driven collection logic.
- **`CaxiloSearchEngineMixin`**: Now injects the remote collections map into the filtering engine for real-time list matching.

---

## [1.0.0] — 2026-05-01

### ✨ Added — Core Repository

- **`CaxiloRepository`** — Main repository class with mixin composition:
  - `CaxiloCategoryMixin` — Builds `CaxiloCategory` list from `CaxiloConfigClient.config.categories`
  - `CaxiloDataProcessorMixin` — Processes raw `ProviderGames`, applies hybrid whitelist, merges & sorts with in-house games
  - `CaxiloSearchEngineMixin` — In-memory search with Vietnamese diacritic normalization + `CaxiloFilter` predicate matching
  - `CaxiloLobbyMixin` — Builds SDUI lobby `List<CaxiloLobbyBlock>` from `lobbySections` remote config
  - `CaxiloUrlResolverMixin` — Authenticated game URL construction delegated per-provider
  - `CaxiloNotificationMixin` — Reactive stream (`gameUpdates`) that broadcasts on settings change

- **Public API**:
  - `getCaxiloGames({query, filter})` — Cached game list with optional search/filter
  - `getCaxiloLobby()` — SDUI home lobby
  - `getCaxiloUrl({providerId, productId, gameCode, lang, isMobileLogin})` — Game URL
  - `getCaxiloCategories()` — Typed category list
  - `getPopularGames({limit})` — Featured or in-house fallback list
  - `clearStorage()` — Evict in-memory cache
  - `dispose()` — Cancel subscriptions and stream controller

### ✨ Added — Domain Models (Freezed)

- **`CaxiloBlock`** sealed union:
  - `ExternalCaxiloBlock` — Remote provider game (slots, sports, live, etc.)
  - `LiveStreamCaxiloBlock` — Live-stream game with iframe/orientation/session-guard config
  - `InHouseCaxiloBlock` — In-house game (e.g., Sunwin) loaded from local asset config
  - Getters: `isInHouseGame`, `isLiveStreamGame`, `forceLandscapeViewportOnIpad`, `openInNewTabOnIOSSafariWeb`, `requiresSessionGuard`, `enableHostMessage`

- **`CaxiloCategory`** sealed union: `.all`, `.gameType`, `.inHouse`, `.custom`

- **`CaxiloFilter`** Freezed union:
  - `.all`, `.isInHouse()`, `.byGameTypes(...)`, `.byProviders(...)`, `.byGameCodes(...)`, `.fromStrategy(strategyId, params)`

- **`CaxiloCategories`** — Container holding `.all` lobby category + `categories` list

- **`CaxiloLobbyBlock`** sealed: `CaxiloGroupBlock`, `CaxiloBannerBlock`

- **`CaxiloProvider`** — Provider metadata model

### ✨ Added — Infrastructure

- **`CaxiloStorage`** — In-memory `List<CaxiloBlock>` cache with clear/read/write operations
- **`CaxiloUtils`** — `generateImageName()` + `removeDiacritics()` for Vietnamese search normalization
- **`CaxiloMapper` / `CaxiloBlockMapper`** — Maps `game_api_client.Game` → `CaxiloBlock` and `GameInHouse` → `InHouseCaxiloBlock`
- **`CaxiloFailure`** hierarchy — Typed failures (`GetCaxiloGamesFailure`, `GetCaxiloLobbyFailure`, `GetCaxiloUrlFailure`, etc.) wrapping underlying errors with stack trace

### ✨ Added — Backward Compatibility Layer

- **`caxilo_compat.dart`** — Type aliases exported from the barrel file to allow zero-change UI compilation during migration:
  - `GameBlock = CaxiloBlock`
  - `InHouseGameBlock = InHouseCaxiloBlock`
  - `LiveStreamGameBlock = LiveStreamCaxiloBlock`
  - `GameFilter = CaxiloFilter`
  - `GameCategory = CaxiloCategory`
  - `GameCategories = CaxiloCategories`
  - `GameLobbyBlock = CaxiloLobbyBlock`

- **Method aliases** on `CaxiloRepository`:
  - `getGames(...)` → `getCaxiloGames(...)`
  - `getGameLobby()` → `getCaxiloLobby()`
  - `getGameUrl(...)` → `getCaxiloUrl(...)`
  - `getGameCategories()` → `getCaxiloCategories()`

### 🔧 Fixed

- Removed stale generated files (`game_block.freezed.dart`, `game_block.g.dart`, `game_category.freezed.dart`, `game_filter.freezed.dart`) copied over from legacy `game_repository` that caused `undefined_class` compile errors
- Normalized `CaxiloDataProcessorMixin` method names (`getInHouseGameBlocks`, `processRawGames`, `mergeAndSortGames`) to match call sites in `CaxiloRepository`

---

## Origin

`caxilo_repository` was extracted and renamed from `lib/core/services/repositories/game_repository/` as part of the package modularization initiative.  
The public API surface is intentionally kept identical to the legacy `GameRepository` to allow incremental, safe migration of the UI layer.

[1.0.0]: https://github.com/internal/s88-flutter/tree/packages/caxilo_repository/v1.0.0
