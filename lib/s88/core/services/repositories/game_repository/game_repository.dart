/// Game Repository
///
/// A repository layer for managing game data with in-memory caching,
/// search, and error handling.
///
/// ## Usage
///
/// ```dart
/// final repository = GameRepository(client: gameApiClient);
///
/// // Pre-load cache at app init (seeds local games instantly, then
/// // fetches remote data and emits a [GameEvent] when ready).
/// await repository.warmup();
///
/// // Search / filter games
/// final games = await repository.getGames(query: 'dragon');
/// final liveGames = await repository.getGames(
///   filter: GameFilter.byGameTypes(gameTypes: [GameType.live]),
/// );
///
/// // React to cache updates (e.g. remote data just arrived)
/// repository.events.listen((event) {
///   switch (event) {
///     case GameDataChanged(:final games):
///       print('Cache updated: ${games.length} games');
///   }
/// });
///
/// // Get a launch URL for a specific game
/// final url = await repository.getGameUrl(
///   providerId: 'amb-vn',
///   productId: 'SEXY',
///   gameCode: 'MX-LIVE-XX',
/// );
/// ```
///
/// ## Event Stream
///
/// [GameRepository.events] is a broadcast [Stream] of [GameEvent]s.
/// Subscribe to react to cache changes without polling:
///
/// - [GameDataChanged] — emitted after every successful remote fetch.
///
/// ## Error Handling
///
/// All public methods that hit the network throw typed [GameFailure] subclasses:
///
/// - [GetGamesFailure] — fetching the games list
/// - [GetGameUrlFailure] — fetching a game launch URL
///
/// ## Key Types
///
/// - [GameRepository] — main entry point
/// - [GameBlock] — a single game with provider metadata and image path
/// - [GameFilter] — filter criteria (game type, provider, popularity, etc.)
/// - [LocalGame] — hardcoded local games (Sunwin, X88) seeded at startup
/// - [GameUtils] — slug / image-name generation utilities
/// - [SupportedGamesWhitelist] — allowlist of confirmed working games
/// - [Game] / [ProviderGames] / [GameType] — re-exported from game API client
library;

export 'package:game_api_client/game_api_client.dart'
    show ProviderGames, GameType;

export 'src/game_event.dart';
export 'src/game_failure.dart';
export 'src/game_in_house_api_client/game_in_house_api_client.dart';
export 'src/game_repository.dart';
export 'src/game_storage.dart';
export 'src/models/models.dart';
export 'src/supported_games_whitelist.dart';
