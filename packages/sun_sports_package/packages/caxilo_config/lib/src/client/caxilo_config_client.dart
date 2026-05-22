import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../presets/caxilo_config_presets.dart';
import 'caxilo_config_exceptions.dart';
import 'caxilo_config_state.dart';
import 'launch_strategy.dart';

/// {@template caxilo_config_client}
/// A unified client for fetching and managing Caxilo configurations and launching games.
///
/// This client handles remote configuration state and provides domain-level
/// logic to resolve launch URLs.
/// {@endtemplate}
// Formerly CasinoSettingsClient.
class CaxiloConfigClient {
  /// {@macro caxilo_config_client}
  CaxiloConfigClient({
    this.tokenProvider,
    this.refreshTokenProvider,
    this.initialUrl,
    http.Client? httpClient,
    Map<GameLaunchStrategy, LaunchStrategy>? launchStrategies,
  }) : _httpClient = httpClient ?? http.Client(),
       _launchStrategies =
           launchStrategies ??
           {
             GameLaunchStrategy.standard: StandardLaunchStrategy(),
             GameLaunchStrategy.fish: FishLaunchStrategy(),
             GameLaunchStrategy.underDevelopment: UnderDevelopmentLaunchStrategy(),
           };

  /// Factory method to create an initialized [CaxiloConfigClient] with fallback data.
  ///
  /// This ensures the client is always functional in "Offline-First" mode
  /// immediately after construction.
  static CaxiloConfigClient create({
    required CaxiloEnvironment environment,
    String? initialUrl,
    String Function()? tokenProvider,
    Future<String?> Function()? refreshTokenProvider,
  }) {
    final client = CaxiloConfigClient(
      initialUrl: initialUrl,
      tokenProvider: tokenProvider,
      refreshTokenProvider: refreshTokenProvider,
    );

    final fallbackMap = CaxiloConfigPresets.buildSettings(environment);
    client.loadFromMap(fallbackMap);

    return client;
  }

  /// Initial URL used for fetching settings if not provided in [fetchSettings].
  final String? initialUrl;

  /// Token provider for user authentication.
  final String Function()? tokenProvider;

  /// Refresh token provider for session recovery.
  final Future<String?> Function()? refreshTokenProvider;

  final http.Client _httpClient;
  final Map<GameLaunchStrategy, LaunchStrategy> _launchStrategies;

  // --- State ---

  CaxiloConfig? _config;
  CaxiloConfigStatus _status = const CaxiloConfigStatus.initial();

  final _configController = StreamController<CaxiloConfig>.broadcast();
  final _statusController = StreamController<CaxiloConfigStatus>.broadcast();

  /// Returns the current configuration, or null if not yet loaded.
  CaxiloConfig? get config => _config;

  /// Returns the current loading status.
  CaxiloConfigStatus get status => _status;

  /// Returns true if the client is in local mode (no initial URL provided).
  bool get isLocalMode => initialUrl == null;

  /// A stream that emits when the configuration changes.
  Stream<CaxiloConfig> get onConfigChanged => _configController.stream;

  /// A stream that emits when the loading status changes.
  Stream<CaxiloConfigStatus> get onStatusChanged => _statusController.stream;

  // --- Static Constants ---

  /// Sunwin provider ID (SSOT)
  static const String sunwinProviderId = 'sunwin';

  /// Sunwin provider display name
  static const String sunwinProviderName = 'Sunwin';

  /// Checks if the given [providerId] corresponds to an in-house provider.
  bool isInHouseGame(String providerId) => providerId == sunwinProviderId;

  // --- Operations ---

  /// Loads configuration from a given JSON map.
  void loadFromMap(Map<String, dynamic> json) {
    _updateStatus(const CaxiloConfigStatus.loading());
    try {
      final newConfig = CaxiloConfig.fromJson(json);
      _updateConfig(newConfig);
      _updateStatus(const CaxiloConfigStatus.loaded());
    } catch (e) {
      final exception = CaxiloConfigParseException('Failed to parse map: $e');
      _updateStatus(CaxiloConfigStatus.failure(exception));
      rethrow;
    }
  }

  /// Synchronizes settings using the [initialUrl] provided at construction.
  ///
  /// Throws [CaxiloConfigFetchException] if no URL was provided.
  Future<void> sync() async {
    final url = initialUrl;
    if (url == null) {
      debugPrint('⚠️ CaxiloConfigClient: sync() called in Local Mode (no initialUrl). Skipping.');
      return;
    }
    return fetchSettings(url);
  }

  /// Fetches the configuration from a remote URL.
  Future<void> fetchSettings(String url) async {
    _updateStatus(const CaxiloConfigStatus.loading());
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw CaxiloConfigFetchException(
          'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      String body = response.body;
      if (_isBase64(body)) {
        body = utf8.decode(base64.decode(body.replaceAll('\n', '').trim()));
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final newConfig = CaxiloConfig.fromJson(json);

      _updateConfig(newConfig);
      _updateStatus(const CaxiloConfigStatus.loaded());
    } on CaxiloConfigException catch (e) {
      _updateStatus(CaxiloConfigStatus.failure(e));
      if (_config == null) rethrow;
    } catch (e) {
      final fetchEx = CaxiloConfigFetchException(e.toString());
      _updateStatus(CaxiloConfigStatus.failure(fetchEx));
      if (_config == null) throw fetchEx;
    }
  }

  /// Returns the launch URL for a specific local game code.
  ///
  /// [isWeb] specifies if the game is being launched from a web platform.
  ///
  /// Throws [InHouseGameUnderDevelopmentException] if the game is recognized
  /// as local but its entry point is not yet implemented or active.
  Future<String> getGameUrl({required String gameCode, bool isWeb = kIsWeb}) async {
    final token = tokenProvider?.call() ?? '';
    final refreshToken = await refreshTokenProvider?.call() ?? '';

    final currentConfig = config;
    if (currentConfig == null) {
      throw const CaxiloConfigFetchException('Configuration not loaded');
    }

    // 1. Resolve Game Metadata from Catalog
    final catalogEntry = currentConfig.inHouse.catalog
        .where((g) => g.gameCode == gameCode)
        .firstOrNull;

    if (catalogEntry == null) {
      throw const InHouseGameUnderDevelopmentException();
    }

    // 2. Check Visibility and Status
    final visibility = currentConfig.inHouse.visibility[gameCode];
    if (visibility != null) {
      if (!visibility.isVisible) {
        throw const InHouseGameUnderDevelopmentException();
      }

      switch (visibility.status) {
        case GameStatus.maintenance:
          throw const InHouseGameMaintenanceException();
        case GameStatus.comingSoon:
          throw const InHouseGameComingSoonException();
        case GameStatus.underDevelopment:
          throw const InHouseGameUnderDevelopmentException();
        case GameStatus.disabled:
          throw const InHouseGameDisabledException();
        case GameStatus.active:
          break;
        case GameStatus.unknown:
          break;
      }
    }

    // 3. Resolve Environment and Launch
    final baseUrlKey = catalogEntry.baseUrlKey;
    final environmentUrl = currentConfig.environments[baseUrlKey] ?? '';
    final baseUrl = environmentUrl.isNotEmpty ? environmentUrl : '';

    debugPrint(
      '[CaxiloConfigClient] Launching: $gameCode | Strategy: ${catalogEntry.launchStrategy}',
    );

    final finalUrl = await _generateUrl(
      baseUrl: baseUrl,
      strategy: catalogEntry.launchStrategy,
      token: token,
      refreshToken: refreshToken,
      isWeb: isWeb,
      gameId: catalogEntry.gameId,
    );

    debugPrint('[CaxiloConfigClient] Generated URL: $finalUrl');
    return finalUrl;
  }

  /// Returns the list of all local games from config (Dynamic + Fallback).
  ///
  /// Games are filtered by their visibility and sorted by the display order
  /// defined in the remote configuration.
  Future<List<InHouseGame>> getAllInHouseGames() async {
    final currentConfig = config;
    if (currentConfig == null) return [];

    final displayOrder = currentConfig.display.order;
    final inHouse = currentConfig.inHouse;

    final filteredCatalog = inHouse.catalog.where((game) {
      final visibility = inHouse.visibility[game.gameCode];
      return visibility?.isVisible ?? false;
    }).toList();

    filteredCatalog.sort((a, b) {
      final indexA = displayOrder.indexOf(a.gameCode);
      final indexB = displayOrder.indexOf(b.gameCode);

      final weightA = indexA == -1 ? 999 : indexA;
      final weightB = indexB == -1 ? 999 : indexB;

      return weightA.compareTo(weightB);
    });

    debugPrint('[CaxiloConfigClient] Total local games returned: ${filteredCatalog.length}');
    return filteredCatalog;
  }

  /// Disposes resources used by the client.
  void dispose() {
    _configController.close();
    _statusController.close();
    _httpClient.close();
  }

  // --- Helpers ---

  Future<String> _generateUrl({
    required String baseUrl,
    required GameLaunchStrategy strategy,
    required String token,
    required String refreshToken,
    required bool isWeb,
    int? gameId,
  }) async {
    final concreteStrategy = _resolveStrategy(strategy);
    return concreteStrategy.generateUrl(
      baseUrl: baseUrl,
      token: token,
      refreshToken: refreshToken,
      isWeb: isWeb,
      gameId: gameId,
    );
  }

  LaunchStrategy _resolveStrategy(GameLaunchStrategy strategy) {
    return _launchStrategies[strategy] ??
        _launchStrategies[GameLaunchStrategy.standard] ??
        StandardLaunchStrategy();
  }

  void _updateConfig(CaxiloConfig newConfig) {
    _config = newConfig;
    _configController.add(newConfig);
  }

  void _updateStatus(CaxiloConfigStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  bool _isBase64(String str) {
    try {
      base64.decode(str.replaceAll('\n', '').trim());
      return true;
    } catch (_) {
      return false;
    }
  }
}
