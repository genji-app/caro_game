import 'dart:convert';

import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:sun_sports/core/env/app_env.dart';
import 'package:sun_sports/core/services/auth/token_error_handler.dart';
import 'package:sun_sports/core/services/auth/token_manager.dart';
import 'package:sun_sports/core/services/network/dio_logger_interceptor.dart';
import 'package:sun_sports/core/services/sportbook_api.dart'
    show SbHttpManager, SbConfig;

/// Chứa các cấu hình được truyền vào lúc build app (qua --dart-define)
class CaxiloEnv {
  const CaxiloEnv({required this.environment, this.configUrl});

  final CaxiloEnvironment environment;
  final String? configUrl;
}

/// Provider cung cấp biến môi trường cho Caxilo
final caxiloEnvProvider = Provider<CaxiloEnv>((ref) {
  // Môi trường được resolve tập trung tại [AppEnv] (qua --dart-define=APP_ENV).
  final environment = AppEnv.isProd
      ? CaxiloEnvironment.prod
      : CaxiloEnvironment.staging;

  return CaxiloEnv(
    environment: environment,
    configUrl: AppEnv.caxiloConfigUrl,
  );
});

/// {@template casino_settings_client_provider}
/// Provider for [CaxiloConfigClient], which manages remote configurations
/// and provides domain logic for in-house games.
/// {@endtemplate}
final caxiloConfigClientProvider = Provider<CaxiloConfigClient>((ref) {
  // Đọc cấu hình môi trường từ provider
  final env = ref.watch(caxiloEnvProvider);

  final client = CaxiloConfigClient.create(
    refreshTokenProvider: () => TokenManager.getRefreshToken(),
    tokenProvider: () => SbHttpManager.instance.userToken,
    environment: env.environment,
    initialUrl: env.configUrl,
  );

  // [MODE: Local Test] JSON config baked into binary via --dart-define.
  // Priority 1 — overrides both preset and remote sync.
  // Usage: make run-local-staging / run-local-prod
  const localConfig = String.fromEnvironment('CASINO_CONFIG_JSON');
  if (localConfig.isNotEmpty) {
    try {
      client.loadFromMap(
        jsonDecode(utf8.decode(base64.decode(localConfig)))
            as Map<String, dynamic>,
      );
      debugPrint('✅ CaxiloConfig: local-test mode (${env.environment.name})');
    } catch (e) {
      debugPrint('❌ CaxiloConfig: CASINO_CONFIG_JSON parse failed: $e');
    }
    return client;
  }

  // [MODE: Remote] Priority 2 — sync từ GitHub URL (staging/prod)
  if (env.environment != CaxiloEnvironment.dev && env.configUrl != null) {
    client.sync().catchError((Object e) {
      debugPrint('❌ CaxiloConfig Sync Error: $e');
      debugPrint(
        'ℹ️ Sync failed. Using ${env.environment.name} fallback settings.',
      );
    });
  }

  // [MODE: Dev] Priority 3 — Dart preset đã được load sẵn bởi CaxiloConfigClient.create()

  return client;
});

/// {@template game_api_client_provider}
/// Provider that manages the lifecycle of [GameApiClient].
///
/// Configures the base URL from [SbConfig] and sets up the [Dio] client
/// with automatic token refresh via [TokenErrorHandler].
/// {@endtemplate}
final gameApiClientProvider = Provider<gac.GameApiClient>((ref) {
  // Pre-configured full URL from remote config.
  // Previously: final domainUrl = SbConfig.gameApiUrl;
  // Previously: final gameBaseUrl = '$domainUrl/gameapi/public';
  final gameApiUrl = SbConfig.gameApiUrl;

  final dioClient = gac.GameApiClient.createDioClient(gameApiUrl, () async {
    final refreshed = await TokenErrorHandler.instance.handleTokenError();
    return refreshed ? SbHttpManager.instance.userToken : null;
  });

  if (kDebugMode) {
    print('🎮 GameApiClient initialized:');
    print('  gameApiUrl: $gameApiUrl');
    dioClient.interceptors.add(DioLoggerInterceptor());
  }

  return gac.GameApiClient(
    dio: dioClient,
    tokenProvider: () async => SbHttpManager.instance.userToken,
  );
});

/// {@template caxilo_repository_provider}
/// Provider for [CaxiloRepository], which centralizes game data fetching
/// and caching logic.
/// {@endtemplate}
final caxiloRepositoryProvider = Provider<CaxiloRepository>((ref) {
  final client = ref.watch(gameApiClientProvider);
  final configClient = ref.watch(caxiloConfigClientProvider);

  final repository = CaxiloRepository(
    client: client,
    configClient: configClient,

    /// for test
    // storage: kDebugMode
    //     ? InMemoryCaxiloStorage(ttl: const Duration(milliseconds: 1))
    //     : null,
  );

  ref.onDispose(repository.dispose);
  return repository;
});

/// {@template caxilo_events_provider}
/// A [StreamProvider] that bridges [CaxiloRepository.events] to Riverpod.
///
/// Emits [CaxiloEvent]s whenever the repository state changes,
/// allowing UI components to reactively update.
/// {@endtemplate}
final caxiloEventsProvider = StreamProvider.autoDispose<CaxiloEvent>((ref) {
  final repository = ref.watch(caxiloRepositoryProvider);
  return repository.events;
});

/// {@template all_games_provider}
/// A [FutureProvider] that fetches and caches the list of all available games.
///
/// Automatically re-runs when [caxiloEventsProvider] emits a new event,
/// ensuring the UI always has the freshest data.
/// {@endtemplate}
final allGamesProvider = FutureProvider.autoDispose<List<GameBlock>>((
  ref,
) async {
  ref.watch(caxiloEventsProvider);
  final repository = ref.watch(caxiloRepositoryProvider);
  return repository.getGames();
});
