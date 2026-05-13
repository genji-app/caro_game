import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart' as gac;

import '../caxilo_failure.dart';

/// Mixin responsible for resolving game launch URLs.
mixin CaxiloUrlResolverMixin {
  /// Remote API client for fetching URLs.
  gac.GameApiClient get gameApiClient;

  /// In-house settings client for checking local games.
  caxiloconfig.CaxiloConfigClient get configClient;

  /// Returns a launch URL for the specified game.
  ///
  /// Throws a [CaxiloFailure] subtype that reflects the domain error:
  /// - [CaxiloMaintenanceFailure] — game is under maintenance.
  /// - [CaxiloComingSoonFailure] / [CaxiloDisabledFailure] / [CaxiloUnderDevelopmentFailure]
  ///   — game is unavailable for a specific reason.
  /// - [CaxiloNetworkFailure] — connectivity or timeout issue.
  /// - [CaxiloAuthFailure] — session expired or unauthorized.
  /// - [CaxiloUnknownFailure] — any other unexpected error.
  Future<String> getCaxiloUrl({
    required String providerId,
    required String productId,
    required String gameCode,
    String? lang,
    bool? isMobileLogin,
  }) async {
    try {
      if (configClient.isInHouseGame(providerId)) {
        final localUrl = await configClient.getGameUrl(gameCode: gameCode, isWeb: kIsWeb);
        debugPrint('Local Game URL: $localUrl');
        return localUrl;
      }

      return await gameApiClient.getGameUrl(
        gac.GetGameUrlRequest(
          providerId: providerId,
          productId: productId,
          gameCode: gameCode,
          lang: lang,
          isMobileLogin: isMobileLogin,
        ),
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToCaxiloFailure(error), stackTrace);
    }
  }
}
