import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api_client/game_api_client.dart';
import 'package:co_caro_flame/s88/core/services/auth/token_error_handler.dart';
import 'package:co_caro_flame/s88/core/services/network/dio_logger_interceptor.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart'
    show SbHttpManager, SbConfig;

/// {@template game_api_client_provider}
/// Provider that manages the lifecycle of [GameApiClient].
///
/// Configures the base URL from [SbConfig] and sets up the [Dio] client
/// with automatic token refresh via [TokenErrorHandler].
/// {@endtemplate}
final gameApiClientProvider = Provider<GameApiClient>((ref) {
  // Pre-configured full URL from remote config.
  // Previously: final domainUrl = SbConfig.gameApiUrl;
  // Previously: final gameBaseUrl = '$domainUrl/gameapi/public';
  final gameApiUrl = SbConfig.gameApiUrl;

  final dioClient = GameApiClient.createDioClient(gameApiUrl, () async {
    final refreshed = await TokenErrorHandler.instance.handleTokenError();
    return refreshed ? SbHttpManager.instance.userToken : null;
  });

  if (kDebugMode) {
    print('🎮 GameApiClient initialized:');
    print('  gameApiUrl: $gameApiUrl');
    dioClient.interceptors.add(DioLoggerInterceptor());
  }

  return GameApiClient(
    dio: dioClient,
    tokenProvider: () async => SbHttpManager.instance.userToken,
  );
});

/// {@template in_house_game_api_client_provider}
/// Provider for [GameInHouseApiClient], for in-house/local games.
/// {@endtemplate}
final gameInHouseApiClientProvider = Provider<GameInHouseApiClient>((ref) {
  return GameInHouseApiClient(
    tokenProvider: () => SbHttpManager.instance.userToken,
    fish88Url: 'https://fish-s88.sandboxg1.win',
  );
});

/// {@template game_repository_provider}
/// Provider for [GameRepository], which centralizes game data fetching
/// and caching logic.
/// {@endtemplate}
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final client = ref.watch(gameApiClientProvider);
  final gameInHouseApiClient = ref.watch(gameInHouseApiClientProvider);

  final repository = GameRepository(
    client: client,
    inHouseClient: gameInHouseApiClient,

    /// for test
    // storage: kDebugMode
    //     ? InMemoryGameStorage(ttl: const Duration(milliseconds: 1))
    //     : null,
  );

  ref.onDispose(repository.dispose);
  return repository;
});

/// {@template game_events_provider}
/// A [StreamProvider] that bridges [GameRepository.events] to Riverpod.
///
/// Emits [GameEvent]s whenever the repository state changes,
/// allowing UI components to reactively update.
/// {@endtemplate}
final gameEventsProvider = StreamProvider.autoDispose<GameEvent>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.events;
});

/// {@template all_games_provider}
/// A [FutureProvider] that fetches and caches the list of all available games.
///
/// Automatically re-runs when [gameEventsProvider] emits a new event,
/// ensuring the UI always has the freshest data.
/// {@endtemplate}
final allGamesProvider = FutureProvider.autoDispose<List<GameBlock>>((
  ref,
) async {
  ref.watch(gameEventsProvider);
  final repository = ref.watch(gameRepositoryProvider);
  return repository.getGames();
});
