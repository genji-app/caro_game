# Game Repository

A repository layer for fetching, caching, and filtering game data.

---

## File Structure

```
game_repository/
├── game_repository.dart          # Barrel export (public API)
└── src/
    ├── game_event.dart           # Sealed event types (GameDataChanged, ...)
    ├── game_failure.dart         # Typed error classes (GetGamesFailure, ...)
    ├── game_repository.dart      # Core implementation
    ├── game_storage.dart         # In-memory cache (InMemoryGameStorage)
    ├── game_utils.dart           # Utilities: slug, image name generation
    ├── local_game.dart           # Hardcoded local games (Sunwin, X88)
    ├── supported_games_whitelist.dart  # Allowlist of working game codes
    └── models/
        ├── game_block.dart       # Main game model (game + provider + image)
        └── game_filter.dart      # Filter criteria
```

---

## Quick Start

```dart
// 1. Create (usually via DI / Riverpod gameRepositoryProvider)
final repository = GameRepository(client: gameApiClient);

// 2. Warmup at app init — seeds local games immediately,
//    then fetches remote data in the background.
unawaited(repository.warmup());

// 3. Fetch games
final all   = await repository.getGames();
final live  = await repository.getGames(
  filter: GameFilter.byGameTypes(gameTypes: [GameType.live]),
);
final found = await repository.getGames(query: 'baccarat');

// 4. Listen for cache updates (remote data arrived)
repository.events.listen((event) {
  switch (event) {
    case GameDataChanged(:final games):
      print('Cache refreshed: ${games.length} games');
  }
});

// 5. Get a launch URL
final url = await repository.getGameUrl(
  providerId: 'amb-vn',
  productId: 'SEXY',
  gameCode: 'MX-LIVE-001',
);
```

---

## Event Stream

`GameRepository.events` is a broadcast `Stream<GameEvent>`. Providers watch
it to re-compute automatically when fresh data arrives — fixing the issue
where home screen groups showed local-only games before remote data loaded.

| Event | When emitted |
|---|---|
| `GameDataChanged(games)` | After every successful remote API fetch |

### Riverpod integration

```dart
// Bridge stream → Riverpod
final gameRepoEventsProvider = StreamProvider<GameEvent>((ref) {
  return ref.watch(gameRepositoryProvider).events;
});

// Auto re-fetch when cache refreshes
final gameGroupProvider = FutureProvider.family
    .autoDispose<List<GameBlock>, GameFilter>((ref, filter) async {
  ref.watch(gameRepoEventsProvider);   // ← reactive
  return ref.watch(gameRepositoryProvider).getGames(filter: filter);
});
```

---

## Caching

`InMemoryGameStorage` caches games with a **1-hour TTL**.

| Scenario | Behaviour |
|---|---|
| Cache empty → `getGames()` | Fetches from API, caches result |
| Cache valid → `getGames()` | Returns cached data immediately |
| `warmup()` called | Seeds local games, starts background API fetch |
| `clearStorage()` | Wipes cache (call on logout) |
| `dispose()` | Closes the event stream controller |

---

## Filtering

`GameFilter` supports multiple criteria:

```dart
// By game type
GameFilter.byGameTypes(gameTypes: [GameType.live, GameType.slot])

// By provider
GameFilter.byProviders(providerIds: ['sunwin', 'lcevo'])

// By popularity (local games first, then A-Z)
GameFilter.byPopularity()

// By text search
await repository.getGames(query: 'rồng hổ')

// Combine
GameFilter(
  gameTypes: [GameType.live],
  providerIds: ['vivo'],
)
```

---

## Whitelist

All API games pass through `SupportedGamesWhitelist`. Only game codes in the
allowlist appear in results. Local games (`LocalGame`) bypass the whitelist.

**Current statistics**: 4 providers, 34 games.

#### 1. AMB-VN (SEXY Gaming)
**Provider ID**: `amb-vn` | **Games**: 4

| Game Code | Game Name | Type |
|---|---|---|
| `MX-LIVE-001` | Baccarat Classic | Baccarat |
| `MX-LIVE-015` | Fish Prawn Crab | Bầu Cua |
| `MX-LIVE-006` | DragonTiger | Rồng Hổ |
| `MX-LIVE-009` | Roulette | Roulette |

#### 2. Via Casino
**Provider ID**: `via-casino-vn` | **Games**: 7

| Game Code | Game Name | Type |
|---|---|---|
| `baccarat60s` | Baccarat | Baccarat |
| `ltbaccarat` | Lotto Baccarat | Lô Tô Bài |
| `sb60s` | Classic Sicbo | Xúc Xắc |
| `tx60s` | Tài Xỉu | Xúc Xắc |
| `dt60s` | Rồng Hổ | Rồng Hổ |
| `xd60s` | Xóc Dĩa | Xóc Dĩa |
| `wwmb` | Bi Lốc Xoáy | Đua Bi |

#### 3. Vivo Gaming
**Provider ID**: `vivo` | **Games**: 10

| Game Code | Game Name | Type |
|---|---|---|
| `baccarat` | Baccarat | Baccarat |
| `353` | Baccarat Dance | Baccarat |
| `roulette` | Roulette | Roulette |
| `1` | Galactic VIP Roulette | Roulette |
| `sicbo` | SicBo | Xúc Xắc |
| `420` | Sic Bo | Xúc Xắc |
| `dragontiger` | DragonTiger | Rồng Hổ |
| `425` | Dragon Tiger Jade | Rồng Hổ |
| `blackjack` | Blackjack | Blackjack |
| `16` | Oceania VIP Blackjack | Blackjack |

#### 4. Evolution
**Provider ID**: `lcevo` | **Games**: 13

| Game Code | Game Name | Type |
|---|---|---|
| `baccarat` | Baccarat Siêu Tốc A | Baccarat |
| `bacbo` | Bac Bo | Baccarat |
| `sicbo` | Siêu Tài Xỉu | Xúc Xắc |
| `scalableblackjack` | Blackjack Vô Cực | Blackjack |
| `scalablebetstackerbj` | Blackjack Chồng Phỉnh Cược | Blackjack |
| `holdem` | Poker | Poker |
| `thb` | Texas Hold'em Bonus Poker | Poker |
| `fantan` | Fan Tan | Fan Tan |
| `dragontiger` | Rồng Hổ | Rồng Hổ |
| `roulette` | Roulette Tự Động | Roulette |
| `crazytime` | Thời Gian Điên Rồ | Game Show |
| `lightningdice` | Lightning Dice | Game Show |
| `moneywheel` | Imperial Quest | Game Show |

### Adding / removing a game

1. Open `src/supported_games_whitelist.dart`
2. Add or remove the game code from the provider's set
3. Update this README (provider table above)

```dart
// supported_games_whitelist.dart
'via-casino-vn': {
  'baccarat60s',
  'ltbaccarat',
  'new-game-code', // ← add here
},
```

---

## Local Games

`LocalGame` provides hardcoded games for **Sunwin** and **X88** providers.
These are seeded into cache synchronously during `warmup()` so the UI has
something to show before the API call completes.

| Constant | Value |
|---|---|
| `LocalGame.sunwinProviderId` | `'sunwin'` |
| `LocalGame.sunwinProviderName` | `'Sunwin'` |
| `LocalGame.x88ProviderId` | `'x88'` |
| `LocalGame.x88ProviderName` | `'X88'` |

---

## Error Handling

All network methods throw typed `GameFailure` subclasses:

| Exception | Thrown by |
|---|---|
| `GetGamesFailure` | `getGames()`, `warmup()` |
| `GetGameUrlFailure` | `getGameUrl()` |

```dart
try {
  final url = await repository.getGameUrl(...);
} on GetGameUrlFailure catch (e) {
  logger.error('Launch failed', e.error);
}
```

---

## Utilities

`GameUtils` provides helpers used internally by `GameRepository`:

```dart
final utils = GameUtils();

// Build image filename from game info
// → "sunwin_SC_sun-ca_thumb.webp"
final name = utils.generateImageName(
  providerId: 'sunwin',
  gameCode: 'SC',
  gameName: 'Sun cá',
);

// Convert text to URL slug
utils.slugify('Xóc Đĩa Live'); // → "xoc-dia-live"

// Strip Vietnamese accents
utils.removeVietnameseAccents('Rồng Hổ'); // → "Rong Ho"
```
