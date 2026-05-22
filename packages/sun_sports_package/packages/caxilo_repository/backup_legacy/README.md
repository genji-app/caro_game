# Game Repository

A robust repository layer for fetching, caching, and dynamically categorizing game data. It synchronizes remote provider games with in-house configurations.

---

## File Structure

```
game_repository/
├── game_repository.dart            # Barrel export (Facade, Public API)
└── src/
    ├── mixins/
    │   ├── game_url_resolver_mixin.dart # URL Launch logic
    │   ├── game_search_engine_mixin.dart # Search & Filter logic
    │   ├── game_data_processor_mixin.dart # API & In-house data merging
    │   ├── game_category_mixin.dart    # Dynamic categories building
    │   ├── game_lobby_mixin.dart        # Lobby SDUI processing
    │   └── game_notification_mixin.dart # Reactive notifications
    ├── game_failure.dart           # Typed errors (GetGamesFailure, GameMaintenanceFailure, ...)
    ├── game_mapper.dart            # Data mapping (DTO -> Domain)
    ├── game_repository.dart        # Core implementation (Coordinator)
    ├── game_storage.dart           # In-memory cache with TTL
    ├── game_utils.dart             # Helpers: slug, image name, diacritics
    ├── supported_games_whitelist.dart # Allowlist of confirmed working games
    └── models/
        ├── models.dart             # Barrel export for models
        ├── game_block.dart         # Main game model (Data Class)
        ├── game_filter.dart        # Advanced filter criteria (AND/OR logic)
        ├── game_category.dart      # Dynamic category models (Type, Provider, Custom)
        ├── game_categories.dart    # Wrapper for list of categories
        ├── game_lobby_block.dart    # Model for lobby items
        └── game_provider.dart      # Normalized provider model
```

---

## Quick Start

```dart
// 1. Create with required clients
final repository = GameRepository(
  client: gameApiClient,
  settingsClient: casinoSettingsClient,
);

// 2. Warmup at app init
//    Seeds in-house games immediately, then fetches remote data.
unawaited(repository.warmup());

// 3. Fetch categories (Dynamic based on Remote Config)
final categories = repository.getGameCategories();

// 4. Fetch games with Advanced Filtering
final liveGames = await repository.getGames(
  filter: GameFilter.byGameTypes(gameTypes: [GameType.live]),
);

// 5. Get Popular Games (Featured in Remote Config)
final popular = await repository.getPopularGames(limit: 10);

// 6. Get a launch URL (Handles both In-house & Remote)
final url = await repository.getGameUrl(
  providerId: 'amb-vn',
  productId: 'SEXY',
  gameCode: 'MX-LIVE-001',
);
```

---

## Dynamic Categorization

The UI no longer relies on hardcoded tabs. Categories are generated on-the-fly via `getGameCategories()` based on the polymorphic configuration from `CasinoSettingsClient`.

| Category Type | Description |
|---|---|
| `GameCategory.gameType` | Traditional grouping by type (Slots, Casino, etc.) |
| `GameCategory.provider` | All games from a specific provider (e.g., PG Soft) |
| `GameCategory.inHouse` | Exclusive games developed in-house (e.g., Sunwin) |
| `GameCategory.custom` | Defined by custom criteria (e.g., "New Games", "Hot") |

---

## Advanced Filtering

`GameFilter` is now a sealed class supporting complex logic:

```dart
// Combine multiple criteria (AND)
final filter = GameFilter.all(
  filters: [
    GameFilter.byGameTypes(gameTypes: [GameType.slot]),
    GameFilter.byProviders(providerIds: ['pg_soft']),
  ],
);

// Flexible OR logic
final newOrHot = GameFilter.any(
  filters: [
    GameFilter.byReleaseDate(daysAgo: 7),
    GameFilter.byPopularity(minPlayCount: 1000),
  ],
);

// Find in-house games
final sunwinOnly = const GameFilter.isInHouse();
```

---

## In-house Games Integration

The old `LocalGame` system is replaced by a direct integration with `CasinoSettingsClient`.
- **Sunwin** and other in-house providers are managed via remote config.
- These games are seeded into the cache **synchronously** during `warmup()` to ensure zero-latency UI display.
- They bypass the standard provider whitelist and use local asset paths for images.

---

## Whitelist

All remote API games must pass through `SupportedGamesWhitelist`. Local in-house games are always permitted.

**Current statistics**: 4 remote providers, 24 whitelisted games.

#### 1. AMB-VN (SEXY Gaming)
**Provider ID**: `amb-vn` | **Games**: 4
- `mx-live-001` (Baccarat), `mx-live-015` (Bầu Cua), `mx-live-006` (Rồng Hổ), `mx-live-009` (Roulette)

#### 2. Via Casino
**Provider ID**: `via-casino-vn` | **Games**: 6
- `baccarat60s`, `ltbaccarat`, `tx60s` (Tài Xỉu), `dt60s` (Rồng Hổ), `xd60s` (Xóc Dĩa), `wwmb` (Bi Lốc Xoáy)

#### 3. Vivo Gaming
**Provider ID**: `vivo` | **Games**: 5
- `353` (Baccarat Dance), `1` (VIP Roulette), `420` (Sic Bo), `425` (Dragon Tiger), `16` (VIP Blackjack)

#### 4. Evolution
**Provider ID**: `lcevo` | **Games**: 9
- `baccarat`, `bacbo`, `sicbo`, `scalablebetstackerbj` (Blackjack), `holdem`, `fantan`, `dragontiger`, `roulette`, `moneywheel`

---

## Error Handling

| Exception | Cause |
|---|---|
| `GetGamesFailure` | API error during fetch or processing |
| `GetGameUrlFailure` | Failed to retrieve a valid launch URL |
| `GameMaintenanceFailure` | Game is under development or server maintenance |

```dart
try {
  final url = await repository.getGameUrl(...);
} on GameMaintenanceFailure {
  showMaintenanceDialog();
} on GetGameUrlFailure catch (e) {
  logger.error('Launch failed', e.error);
}
```
