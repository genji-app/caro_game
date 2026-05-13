import 'dart:async';

import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart' as gac;

import 'caxilo_failure.dart';
import 'caxilo_storage.dart';
import 'caxilo_utils.dart';
import 'mixins/caxilo_category_mixin.dart';
import 'mixins/caxilo_data_processor_mixin.dart';
import 'mixins/caxilo_lobby_mixin.dart';
import 'mixins/caxilo_notification_mixin.dart';
import 'mixins/caxilo_search_engine_mixin.dart';
import 'mixins/caxilo_url_resolver_mixin.dart';
import 'models/models.dart';

/// {@template caxilo_repository}
/// A repository that manages game data with in-memory caching and reactive updates.
///
/// This repository acts as a bridge between remote game APIs and local in-house
/// configuration. It features:
/// - **Automatic Synchronization**: Listens to [caxiloconfig.CaxiloConfigClient] and
///   automatically refreshes the game cache when remote settings change.
/// - **Dynamic Categorization**: Generates UI categories on-the-fly based on
///   polymorphic configurations from the remote settings.
/// - **Unified Sorting**: Ensures all games (both remote and in-house) are
///   sorted according to the display priority defined in the settings.
/// - **Hybrid Whitelist Filtering**: Only includes games confirmed by the
///   whitelist (Remote Config > Local Fallback) defined in [caxiloconfig.CaxiloConfigClient].
///
/// On [warmup], local games are seeded into cache immediately, then remote data
/// is fetched and merged. When any data refresh completes, a [CaxiloDataChanged]
/// event is emitted on [events].
/// {@endtemplate}
class CaxiloRepository
    with
        CaxiloDataProcessorMixin,
        CaxiloCategoryMixin,
        CaxiloSearchEngineMixin,
        CaxiloUrlResolverMixin,
        CaxiloLobbyMixin,
        CaxiloNotificationMixin {
  /// {@macro caxilo_repository}
  CaxiloRepository({
    required gac.GameApiClient client,
    required caxiloconfig.CaxiloConfigClient configClient,
    CaxiloStorage? storage,
    CaxiloUtils? utils,
  }) : _client = client,
       _configClient = configClient,
       _storage = storage ?? InMemoryCaxiloStorage(ttl: const Duration(hours: 1)),
       _utils = utils ?? CaxiloUtils() {
    _initSettingsListener();
  }

  final gac.GameApiClient _client;
  final caxiloconfig.CaxiloConfigClient _configClient;
  final CaxiloStorage _storage;
  final CaxiloUtils _utils;

  // --- Mixin dependencies implementation ---
  @override
  gac.GameApiClient get gameApiClient => _client;

  @override
  caxiloconfig.CaxiloConfigClient get configClient => _configClient;

  @override
  CaxiloUtils get utils => _utils;

  @override
  String get defaultProviderId => sunwinProviderId;

  /// Subscription to settings changes.
  StreamSubscription<caxiloconfig.CaxiloConfigStatus>? _settingsSubscription;

  /// Future representing an ongoing API fetch to prevent redundant
  /// concurrent requests.
  Future<List<CaxiloGameBlock>>? _activeFetchFuture;

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Sunwin provider ID — single source of truth.
  static const String sunwinProviderId = caxiloconfig.CaxiloConfigClient.sunwinProviderId;

  /// Sunwin provider display name.
  static const String sunwinProviderName = caxiloconfig.CaxiloConfigClient.sunwinProviderName;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Pre-loads the game cache for instant access.
  ///
  /// 1. Seeds local Sunwin games into cache (sync, instant).
  /// 2. Fetches the full game list from API and merges with local data.
  ///
  /// Call once at app init (after login). If never called, [getCaxiloGames]
  /// will still work — it triggers a fetch internally as a fallback.
  ///
  /// Throws [GetCaxiloGamesFailure] if the network request fails.
  Future<void> warmup({String? settingsUrl}) async {
    // 1. Sync settings in background (non-blocking for UI rendering if fallback exists)
    // Nếu có settingsUrl mới thì fetch, nếu không thì dùng sync() mặc định của client
    if (settingsUrl != null) {
      unawaited(syncSettings(url: settingsUrl));
    } else {
      unawaited(syncSettings());
    }

    // 2. Seed local games into cache immediately
    await _seedLocalCaxiloGames();

    // 3. Fetch remote games and merge
    await _fetchCaxiloGames(forceRefresh: true);
  }

  /// Synchronizes the casino configuration with the remote server.
  ///
  /// This updates the [caxiloconfig.CaxiloConfigClient] state, which in turn
  /// triggers a game list refresh via the listener.
  Future<void> syncSettings({String? url}) async {
    try {
      if (url != null) {
        debugPrint('📡 CaxiloRepository: Syncing settings from explicit URL: $url...');
        await _configClient.fetchSettings(url);
      } else {
        debugPrint('📡 CaxiloRepository: Syncing settings using initial injected URL...');
        await _configClient.sync();
      }
    } catch (e) {
      debugPrint('⚠️ CaxiloRepository: Settings sync failed, using fallback/cache: $e');
      // We don't rethrow here to allow the app to work with fallback data
    }
  }

  /// Returns games matching the given [query] and/or [filter].
  ///
  /// Searches through cached games by game name, provider name,
  /// and game code (all case-insensitive). If no arguments are provided,
  /// returns **all** cached games.
  ///
  /// Throws [GetCaxiloGamesFailure] if the underlying API call fails or if the
  /// merged game list cannot be processed.
  @override
  Future<List<CaxiloGameBlock>> getCaxiloGames({String? query, CaxiloFilter? filter}) async {
    final games = await _fetchCaxiloGames();

    var result = applySearchAndFilter(games, query: query, filter: filter);

    // If the cached result is empty but there's an active fetch (e.g., during warmup),
    // wait for it to complete to capture the fresh data.
    if (result.isEmpty && _activeFetchFuture != null) {
      debugPrint('🔄 CaxiloRepository: Empty cached result, waiting for active fetch...');
      final freshGames = await _activeFetchFuture!;
      result = applySearchAndFilter(freshGames, query: query, filter: filter);
    }

    return result;
  }

  /// Returns the top [limit] popular games.
  ///
  /// Priority order:
  /// Returns games in the 'popular' collection as defined by remote settings.
  Future<List<CaxiloGameBlock>> getPopularGames() async {
    final allGames = await _fetchCaxiloGames();
    return getPopularGamesFromList(allGames);
  }

  // ---------------------------------------------------------------------------
  // Backward-compatible aliases (mirrors GameRepository public API)
  //
  // These allow the UI/presenter layer to call the same method names that existed
  // on GameRepository during incremental migration. Remove once UI is fully
  // updated to the Caxilo-prefixed names.
  // ---------------------------------------------------------------------------

  /// Alias for [getCaxiloGames] — maintains compatibility with [GameRepository.getGames].
  Future<List<CaxiloGameBlock>> getGames({String? query, CaxiloFilter? filter}) =>
      getCaxiloGames(query: query, filter: filter);

  /// Alias for [getCaxiloLobby] — maintains compatibility with [GameRepository.getGameLobby].
  Future<List<CaxiloLobbyBlock>> getGameLobby() => getCaxiloLobby();

  /// Alias for [getCaxiloUrl] — maintains compatibility with [GameRepository.getGameUrl].
  Future<String> getGameUrl({
    required String providerId,
    required String productId,
    required String gameCode,
    String? lang,
    bool? isMobileLogin,
  }) => getCaxiloUrl(
    providerId: providerId,
    productId: productId,
    gameCode: gameCode,
    lang: lang,
    isMobileLogin: isMobileLogin,
  );

  /// Alias for [getCaxiloCategories] — maintains compatibility with [GameRepository.getGameCategories].
  CaxiloCategories getGameCategories() => getCaxiloCategories();

  /// Returns the sidebar grouping data.
  CaxiloSidebarData getSidebarData() => getCaxiloSidebarData();

  /// Clears the in-memory cache.
  ///
  /// Call on logout or when data might be stale.
  void clearStorage() => _storage.clear();

  /// Disposes the event stream controller.
  ///
  /// Call on app shutdown or when this repository is no longer needed.
  void dispose() {
    _settingsSubscription?.cancel();
    disposeNotifications();
  }

  // ---------------------------------------------------------------------------
  // Internal — cache & fetch
  // ---------------------------------------------------------------------------

  /// Sets up a listener for remote settings updates.
  ///
  /// When settings are successfully re-loaded (v2), we force a re-fetch
  /// of the merged game list to ensure local games and visibility are current.
  void _initSettingsListener() {
    _settingsSubscription = _configClient.onStatusChanged.listen((status) {
      if (status is caxiloconfig.CaxiloConfigStatusLoaded) {
        debugPrint('🔔 CaxiloRepository: Settings updated, refreshing cache...');
        _fetchCaxiloGames(forceRefresh: true).catchError((Object e) {
          debugPrint('❌ CaxiloRepository: Failed to refresh after settings change: $e');
          return <CaxiloGameBlock>[];
        });
      }
    });
  }

  /// Seeds local games into the cache when it is empty,
  /// so the UI has data to display immediately.
  Future<void> _seedLocalCaxiloGames() async {
    if (_storage.get() != null) return;
    final localGames = await getInHouseGameBlocks();
    if (localGames.isNotEmpty) {
      _storage.set(localGames);
      debugPrint('🌞 CaxiloRepository: Seeded ${localGames.length} local games');
    }
  }

  /// Returns the cached games list, or fetches from the API if needed.
  ///
  /// Concurrent callers share the same in-flight future.
  /// Pass [forceRefresh] to bypass cache.
  Future<List<CaxiloGameBlock>> _fetchCaxiloGames({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storage.get();
      if (cached != null) return cached;
    }

    if (_activeFetchFuture != null) {
      debugPrint('🔄 CaxiloRepository: Joined existing active fetch');
      return _activeFetchFuture!;
    }

    _activeFetchFuture = _fetchAndProcessCaxiloGames();
    try {
      return await _activeFetchFuture!;
    } finally {
      _activeFetchFuture = null;
    }
  }

  /// Fetches from API, filters via hybrid whitelist, merges local games,
  /// and updates the cache.
  Future<List<CaxiloGameBlock>> _fetchAndProcessCaxiloGames() async {
    try {
      debugPrint('📡 CaxiloRepository: Fetching games from API...');
      final raw = await _client.getGames();
      final processedRemote = processRawGames(raw);

      final localGames = await getInHouseGameBlocks();

      final mergedAndSorted = mergeAndSortGames(
        processedRemoteGames: processedRemote,
        localGames: localGames,
      );

      _storage.set(mergedAndSorted);
      emitEvent(CaxiloDataChanged(mergedAndSorted));
      return mergedAndSorted;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToCaxiloFailure(error), stackTrace);
    }
  }
}
