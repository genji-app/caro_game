# caxilo_repository

A Flutter package providing a fully-featured repository layer for managing casino game data.  
Includes in-memory caching, reactive update streams, SDUI lobby building, search/filter engine, and a backward-compatible adapter for migrating from the legacy `game_repository`.

---

## Features

| Feature | Description |
|---|---|
| **In-memory caching** | Games are fetched once and cached in `CaxiloStorage`; cache is invalidated on settings change |
| **Reactive updates** | `CaxiloConfigClient` subscription triggers automatic re-fetch and broadcast via stream |
| **SDUI Lobby** | `getCaxiloLobby()` builds the home screen layout from remote `lobbySections` config |
| **Search & Filter** | `getCaxiloGames(query, filter)` — diacritic-aware search + `CaxiloFilter` DSL |
| **Category building** | `getCaxiloCategories()` maps remote config → typed `CaxiloCategory` sealed variants |
| **URL resolving** | `getCaxiloUrl()` — constructs authenticated game URLs per provider |
| **Popular games** | `getPopularGames()` — games in the `popular` collection as defined by remote config |
| **Hybrid whitelist** | Remote config takes precedence over local fallback for game support decisions |
| **Backward compat** | `GameBlock`, `InHouseGameBlock`, `LiveStreamGameBlock`, `GameFilter`, etc. are exported as type aliases |

---

## Architecture

```
CaxiloRepository
├── CaxiloCategoryMixin       ─ Builds CaxiloCategory list from CaxiloConfigClient
├── CaxiloDataProcessorMixin  ─ Processes & sorts raw ProviderGames API response
├── CaxiloSearchEngineMixin   ─ In-memory search (diacritics) + CaxiloFilter matching
├── CaxiloLobbyMixin          ─ SDUI lobby: maps LobbySectionConfig → CaxiloLobbyBlock
├── CaxiloUrlResolverMixin    ─ Authenticated game URL construction per provider
└── CaxiloNotificationMixin   ─ Reactive stream for game list change events
```

### Domain Models

```
CaxiloGameBlock (sealed / Freezed)
├── CaxiloGameBlockLiveStream – Remote live-stream games with iframe/orientation config
└── CaxiloGameBlockInHouse    – In-house games (e.g., Sunwin) loaded from local config

CaxiloCategory (sealed / Freezed)
├── CaxiloCategory.all        – "Lobby" / All-games catch-all
├── CaxiloCategory.gameType   – Filter by GameType enum
├── CaxiloCategory.inHouse    – In-house games section
└── CaxiloCategory.custom     – Arbitrary strategy-based filter

CaxiloLobbyBlock (sealed)
├── CaxiloGroupBlock   – Horizontal row of games with a label
└── CaxiloBannerBlock  – Promotional banner slot

CaxiloFilter (Freezed union)
├── CaxiloFilter.all
├── CaxiloFilter.isInHouse()
├── CaxiloFilter.byCollection(collectionId: '...')
├── CaxiloFilter.byGameTypes(gameTypes: [...])
├── CaxiloFilter.byProviders(providerIds: [...])
├── CaxiloFilter.byGameCodes(gameCodes: [...])
├── CaxiloFilter.fromStrategy(strategy, params)    ─ Remote-driven filter
└── CaxiloFilter.none()                            ─ Matches nothing (safe fallback)

CaxiloFilter presets (static const shorthands)
├── CaxiloFilter.featured   → byCollection('featured')
├── CaxiloFilter.popular    → byCollection('popular')
├── CaxiloFilter.newGames   → byCollection('new')
├── CaxiloFilter.inHouse    → isInHouse()
├── CaxiloFilter.live       → byGameTypes([GameType.live])
├── CaxiloFilter.slots      → byGameTypes([GameType.slot])
├── CaxiloFilter.cardGames  → byGameTypes([GameType.card])
└── CaxiloFilter.jackpots   → byGameTypes([GameType.jackpot])

CaxiloFailure (sealed domain hierarchy)
├── CaxiloNetworkFailure          ─ isRetryable = true
├── CaxiloAuthFailure             ─ session expired / 401
├── CaxiloMaintenanceFailure      ─ game under maintenance
├── CaxiloGameUnavailableFailure  ─ sealed base
│   ├── CaxiloComingSoonFailure
│   ├── CaxiloDisabledFailure
│   └── CaxiloUnderDevelopmentFailure
├── CaxiloServerFailure           ─ isRetryable = true
├── CaxiloBusinessFailure         ─ .message carries operator error text
└── CaxiloUnknownFailure
```

---

## Getting Started

### 1. Add dependency

```yaml
# pubspec.yaml
dependencies:
  caxilo_repository:
    path: ../caxilo_repository
```

### 2. Instantiate

```dart
import 'package:caxilo_repository/caxilo_repository.dart';

final repository = CaxiloRepository(
  gameApiClient: myGameApiClient,
  configClient: myCaxiloConfigClient,
);
```

### 3. Fetch games

```dart
// All games (cached)
final games = await repository.getCaxiloGames();

// With search
final results = await repository.getCaxiloGames(query: 'baccarat');

// With filter — verbose form
final slots = await repository.getCaxiloGames(
  filter: const CaxiloFilter.byGameTypes(gameTypes: [caxiloconfig.GameType.slot]),
);

// With filter — preset shorthand
final featured = await repository.getCaxiloGames(filter: CaxiloFilter.featured);
final live     = await repository.getCaxiloGames(filter: CaxiloFilter.live);
final popular  = await repository.getPopularGames(); // returns popular collection as-is
```

### 4. Build the SDUI lobby

```dart
final sections = await repository.getCaxiloLobby();
// Returns List<CaxiloLobbyBlock> — render with pattern-matching
for (final block in sections) {
  block.when(
    group: (label, games) => GroupRow(label: label, games: games),
    banner: (bannerId)   => BannerWidget(id: bannerId),
  );
}
```

### 5. Resolve a game URL

```dart
final url = await repository.getCaxiloUrl(
  providerId: 'evolution',
  productId: 'EVO',
  gameCode: 'baccarat_classic',
  lang: 'vi',
);
```

### 6. Reactive updates

```dart
repository.gameUpdates.listen((games) {
  // Called whenever CaxiloConfigClient refreshes
});
```

### 7. Handle errors

```dart
try {
  final url = await repository.getCaxiloUrl(...);
} on CaxiloFailure catch (failure) {
  switch (failure) {
    case CaxiloMaintenanceFailure():
      showMaintenanceScreen();
    case CaxiloNetworkFailure():
      showRetryPrompt(canRetry: failure.isRetryable);
    case CaxiloAuthFailure():
      redirectToLogin();
    case CaxiloComingSoonFailure() || CaxiloDisabledFailure() || CaxiloUnderDevelopmentFailure():
      showUnavailableMessage();
    case CaxiloBusinessFailure(:final message):
      showErrorDialog(message); // operator-defined text, safe to display
    case CaxiloServerFailure():
      showRetryPrompt(canRetry: failure.isRetryable);
    case CaxiloUnknownFailure():
      showGenericError();
  }
}
```

### 8. Cleanup

```dart
repository.dispose(); // cancel subscriptions & stream controller
repository.clearStorage(); // clear in-memory cache (e.g., on logout)
```

---

## Riverpod Integration (app layer)

```dart
// Provided via game_providers.dart
final caxiloRepositoryProvider = Provider<CaxiloRepository>((ref) {
  return CaxiloRepository(
    gameApiClient: ref.read(gameApiClientProvider),
    configClient: ref.read(caxiloConfigClientProvider),
  );
});

// Usage in a notifier
final games = await ref.read(caxiloRepositoryProvider).getCaxiloGames();
```

---

## Backward Compatibility

During the incremental migration from `game_repository`, `caxilo_repository` exports type aliases that allow existing UI code to compile without changes:

| Legacy name | Resolved type |
|---|---|
| `GameBlock` | `CaxiloGameBlock` |
| `InHouseGameBlock` | `CaxiloGameBlockInHouse` |
| `LiveStreamGameBlock` | `CaxiloGameBlockLiveStream` |
| `GameFilter` | `CaxiloFilter` |
| `GameCategory` | `CaxiloCategory` |
| `GameCategories` | `CaxiloCategories` |
| `GameLobbyBlock` | `CaxiloLobbyBlock` |

Method aliases on `CaxiloRepository`:

| Legacy method | Delegates to |
|---|---|
| `getGames(...)` | `getCaxiloGames(...)` |
| `getGameLobby()` | `getCaxiloLobby()` |
| `getGameUrl(...)` | `getCaxiloUrl(...)` |
| `getGameCategories()` | `getCaxiloCategories()` |

> **Migration note**: Remove these aliases once all UI references are updated to the `Caxilo`-prefixed names.

---

## Dependencies

| Package | Role |
|---|---|
| `caxilo_config` | Remote config, in-house game list, lobby sections |
| `game_api_client` | Raw game API (`ProviderGames`) |
| `freezed_annotation` | Sealed union models |
| `json_annotation` | JSON serialization |

---

## Running Tests

```bash
very_good test
```

---

## License

Internal package — not published to pub.dev.
