import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart';

import 'game_event.dart';
import 'game_failure.dart';
import 'game_in_house_api_client/game_in_house_api_client.dart';
import 'game_storage.dart';
import 'game_utils.dart';
import 'models/game_block.dart';
import 'models/game_filter.dart';
import 'supported_games_whitelist.dart';

/// {@template game_repository}
/// A repository that manages game data with in-memory caching.
///
/// On [warmup], local games (via [LocalGame]) are seeded into cache
/// immediately, then remote data is fetched and merged. When the remote
/// fetch completes a [GameDataChanged] event is emitted on [events],
/// allowing UI providers to react reactively without polling.
///
/// All games returned are filtered by [SupportedGamesWhitelist] — only
/// confirmed-working games are included.
/// {@endtemplate}
class GameRepository {
  /// {@macro game_repository}
  GameRepository({
    required GameApiClient client,
    GameInHouseApiClient? inHouseClient,
    GameStorage? storage,
    SupportedGamesWhitelist? whitelist,
    GameUtils? utils,
  }) : _client = client,
       _inHouseClient = inHouseClient ?? GameInHouseApiClient(),
       _storage = storage ?? InMemoryGameStorage(ttl: const Duration(hours: 1)),
       _whitelist = whitelist ?? SupportedGamesWhitelist(),
       _utils = utils ?? GameUtils();

  final GameApiClient _client;
  final GameInHouseApiClient _inHouseClient;
  final GameStorage _storage;
  final SupportedGamesWhitelist _whitelist;
  final GameUtils _utils;

  /// Future representing an ongoing API fetch to prevent redundant
  /// concurrent requests.
  Future<List<GameBlock>>? _activeFetchFuture;

  /// Broadcast controller for repository events.
  final _eventController = StreamController<GameEvent>.broadcast();

  /// Stream of repository events (data changes, errors, etc.).
  ///
  /// Emits [GameDataChanged] whenever the cache is refreshed with new data.
  /// UI providers should watch this to stay in sync.
  Stream<GameEvent> get events => _eventController.stream;

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Sunwin provider ID — single source of truth.
  static const String sunwinProviderId = GameInHouseApiClient.sunwinProviderId;

  /// Sunwin provider display name.
  static const String sunwinProviderName =
      GameInHouseApiClient.sunwinProviderName;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Pre-loads the game cache for instant access.
  ///
  /// 1. Seeds local Sunwin games into cache (sync, instant).
  /// 2. Fetches the full game list from API and merges with local data.
  ///
  /// Call once at app init (after login). If never called, [getGames]
  /// will still work — it triggers a fetch internally as a fallback.
  ///
  /// Throws [GetGamesFailure] if the network request fails.
  Future<void> warmup() async {
    _seedLocalGames();
    await _fetchGames(forceRefresh: true);
  }

  /// Returns games matching the given [query] and/or [filter].
  ///
  /// Searches through cached games by game name, provider name,
  /// and game code (all case-insensitive). If no arguments are provided,
  /// returns **all** cached games.
  ///
  /// ```dart
  /// final results = await repository.getGames(query: 'dragon');
  ///
  /// final filtered = await repository.getGames(
  ///   filter: GameFilter.byGameTypes(gameTypes: [GameType.slot]),
  /// );
  /// ```
  ///
  /// Throws [GetGamesFailure] if the underlying API call fails.
  Future<List<GameBlock>> getGames({String? query, GameFilter? filter}) async {
    final games = await _fetchGames();
    final q = query?.toLowerCase().trim() ?? '';

    List<GameBlock> filterGames(List<GameBlock> list) {
      return list.where((block) {
        if (filter != null && !filter.matches(block)) {
          return false;
        }
        return q.isEmpty || _matchesQuery(block, q);
      }).toList();
    }

    var result = filterGames(games);

    // If the cached result is empty but there's an active fetch (e.g., during warmup),
    // wait for it to complete to capture the fresh data.
    if (result.isEmpty && _activeFetchFuture != null) {
      debugPrint(
        '🔄 GameRepository: Empty cached result, waiting for active fetch...',
      );
      final freshGames = await _activeFetchFuture!;
      result = filterGames(freshGames);
    }

    return result;
  }

  /// Returns the top [limit] popular games (Sunwin, default 5).
  ///
  /// Throws [GetGamesFailure] if the underlying API call fails.
  Future<List<GameBlock>> getPopularGames({int limit = 5}) async {
    final allGames = await _fetchGames();
    return allGames
        .where((b) => b.providerId.toLowerCase() == sunwinProviderId)
        .take(limit)
        .toList();
  }

  /// Returns a launch URL for the specified game.
  ///
  /// This method distinguishes between:
  /// 1. **Local Games**: Handled via [_localGames] (e.g., Sunwin in-house).
  ///    An auth token is required from [_tokenProvider].
  /// 2. **Remote Provider Games**: Handled via API call to [_client].
  ///
  /// Errors:
  /// - Throws [GameUnderDevelopmentFailure] if a local game is recognized but
  ///   doesn't have a functional URL implemented.
  /// - Throws [GetGameUrlFailure] if the API request fails or any unexpected
  ///   error occurs.
  Future<String> getGameUrl({
    required String providerId,
    required String productId,
    required String gameCode,
    String? lang,
    bool? isMobileLogin,
  }) async {
    try {
      if (_inHouseClient.isLocalProvider(providerId)) {
        final localUrl = await _inHouseClient.getGameUrl(
          gameCode: gameCode,
          isWeb: kIsWeb,
        );
        debugPrint('Local Game URL: $localUrl');
        return localUrl;
      }

      return await _client.getGameUrl(
        GetGameUrlRequest(
          providerId: providerId,
          productId: productId,
          gameCode: gameCode,
          lang: lang,
          isMobileLogin: isMobileLogin,
        ),
      );
    } on GameInHouseUrlFetchException catch (error, stackTrace) {
      Error.throwWithStackTrace(GetGameUrlFailure(error), stackTrace);
    } on GameInHouseUnderDevelopmentException catch (error, stackTrace) {
      debugPrint('⚠️ GameRepository: Game is under maintenance: $gameCode');
      Error.throwWithStackTrace(GameMaintenanceFailure(error), stackTrace);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetGameUrlFailure(error), stackTrace);
    }
  }

  /// Clears the in-memory cache.
  ///
  /// Call on logout or when data might be stale.
  void clearStorage() => _storage.clear();

  /// Disposes the event stream controller.
  ///
  /// Call on app shutdown or when this repository is no longer needed.
  void dispose() => _eventController.close();

  // ---------------------------------------------------------------------------
  // Internal — cache & fetch
  // ---------------------------------------------------------------------------

  /// Seeds local games into the cache when it is empty,
  /// so the UI has data to display immediately.
  void _seedLocalGames() {
    if (_storage.get() != null) return;
    final localGames = _inHouseClient.getAllLocalGames();
    if (localGames.isNotEmpty) {
      _storage.set(localGames);
      debugPrint('🌞 GameRepository: Seeded ${localGames.length} local games');
    }
  }

  /// Returns the cached games list, or fetches from the API if needed.
  ///
  /// Concurrent callers share the same in-flight future.
  /// Pass [forceRefresh] to bypass cache.
  Future<List<GameBlock>> _fetchGames({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storage.get();
      if (cached != null) return cached;
    }

    if (_activeFetchFuture != null) {
      debugPrint('🔄 GameRepository: Joined existing active fetch');
      return _activeFetchFuture!;
    }

    _activeFetchFuture = _fetchAndProcessGames();
    try {
      return await _activeFetchFuture!;
    } finally {
      _activeFetchFuture = null;
    }
  }

  /// Fetches from API, filters via whitelist, merges local games,
  /// and updates the cache.
  Future<List<GameBlock>> _fetchAndProcessGames() async {
    try {
      debugPrint('📡 GameRepository: Fetching games from API...');
      final raw = await _client.getGames();
      final filtered = _processRawGames(raw);

      final localGames = _inHouseClient.getAllLocalGames();
      filtered.addAll(localGames);
      debugPrint('📊 Added ${localGames.length} local games');

      _storage.set(filtered);
      _eventController.add(GameDataChanged(filtered));
      return filtered;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetGamesFailure(error), stackTrace);
    }
  }

  /// Maps raw [ProviderGames] into a flat, whitelist-filtered list.
  List<GameBlock> _processRawGames(List<ProviderGames> allGames) {
    final result = <GameBlock>[];
    var total = 0;

    for (final provider in allGames) {
      total += provider.gameList.length;
      for (final game in provider.gameList) {
        if (_whitelist.isSupported(
          providerId: provider.providerId,
          gameCode: game.gameCode,
        )) {
          result.add(
            GameBlock.fromGame(
              game: game,
              providerId: provider.providerId,
              providerName: provider.providerName,
              image: _utils.generateImageName(
                providerId: provider.providerId,
                gameCode: game.gameCode,
                gameName: game.gameName,
              ),
            ),
          );
        }
      }
    }

    debugPrint('📊 Games: $total total → ${result.length} after whitelist');
    return result;
  }

  /// Returns `true` if [block] matches the search term [q].
  bool _matchesQuery(GameBlock block, String q) {
    if (q.isEmpty) return true;

    final query = q.toLowerCase();

    // 1. Check direct matches (ID, Code, Name)
    final matchesRaw =
        block.gameName.toLowerCase().contains(query) ||
        block.gameCode.toLowerCase().contains(query) ||
        block.productId.toLowerCase().contains(query) ||
        block.providerName.toLowerCase().contains(query) ||
        block.providerId.toLowerCase().contains(query);

    if (matchesRaw) return true;

    // 2. Advanced: Normalized matching (e.g. "tai xiu" matches "Tài Xỉu")
    final normalizedQuery = _utils.removeDiacritics(query);
    return _utils
            .removeDiacritics(block.gameName)
            .toLowerCase()
            .contains(normalizedQuery) ||
        _utils
            .removeDiacritics(block.providerName)
            .toLowerCase()
            .contains(normalizedQuery);
  }
}
