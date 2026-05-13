import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:game_api_client/game_api_client.dart' as gac;

import 'models/caxilo_game_block.dart';

/// Mapper and extensions to handle conversion between [caxiloconfig.GameType] and [gac.GameType].
///
/// This is placed in the repository layer to keep [caxilo_config] clean
/// of [game_api_client] dependencies.
extension GameTypeMapper on caxiloconfig.GameType {
  /// Maps [gac.GameType] from the API client to our local [caxiloconfig.GameType].
  static caxiloconfig.GameType fromPackageGameType(gac.GameType? packageType) {
    if (packageType == null) return caxiloconfig.GameType.unknown;

    // Use value-based mapping for stability
    return switch (packageType.value) {
      1 => caxiloconfig.GameType.slot,
      2 => caxiloconfig.GameType.sport,
      3 => caxiloconfig.GameType.jackpot,
      4 => caxiloconfig.GameType.card,
      5 => caxiloconfig.GameType.dice,
      6 => caxiloconfig.GameType.live,
      7 => caxiloconfig.GameType.lottery,
      8 => caxiloconfig.GameType.miniGame,
      9 => caxiloconfig.GameType.fishing,
      20 => caxiloconfig.GameType.others,
      _ => caxiloconfig.GameType.fromJson(packageType.name),
    };
  }

  /// Maps our local [caxiloconfig.GameType] back to [gac.GameType].
  gac.GameType toPackageGameType() {
    return switch (this) {
      caxiloconfig.GameType.slot => gac.GameType.slot,
      caxiloconfig.GameType.sport => gac.GameType.sport,
      caxiloconfig.GameType.jackpot => gac.GameType.jackpot,
      caxiloconfig.GameType.card => gac.GameType.card,
      caxiloconfig.GameType.dice => gac.GameType.dice,
      caxiloconfig.GameType.live => gac.GameType.live,
      caxiloconfig.GameType.lottery => gac.GameType.lottery,
      caxiloconfig.GameType.miniGame => gac.GameType.miniGame,
      caxiloconfig.GameType.fishing => gac.GameType.fishing,
      caxiloconfig.GameType.others => gac.GameType.others,
      caxiloconfig.GameType.unknown => gac.GameType.unknown,
    };
  }
}

/// {@template caxilo_game_block_mapper}
/// A dedicated mapper responsible for transforming various data sources
/// (Remote API, In-house Config) into [CaxiloGameBlock] domain models.
/// {@endtemplate}
class CaxiloGameBlockMapper {
  CaxiloGameBlockMapper._();

  /// Maps a [caxiloconfig.InHouseGame] configuration into an [CaxiloGameBlockInHouse].
  static CaxiloGameBlock fromInHouseConfig(caxiloconfig.InHouseGame config) {
    return CaxiloGameBlock.inHouse(
      providerId: config.providerId,
      providerName: config.providerName,
      productId: config.productId,
      gameCode: config.gameCode,
      gameName: config.gameName,
      lang: config.lang,
      gameType: config.gameType,
      image: config.image,
      enableHostMessage: config.enableHostMessage,
      mobileOrientation: config.mobileOrientation.isEmpty
          ? caxiloconfig.GameOrientation.landscape
          : config.mobileOrientation,
      tabletOrientation: config.tabletOrientation.isEmpty
          ? caxiloconfig.GameOrientation.landscape
          : config.tabletOrientation,
      desktopOrientation: config.desktopOrientation.isEmpty
          ? caxiloconfig.GameOrientation.all
          : config.desktopOrientation,
    );
  }

  /// Maps a raw [gac.Game] DTO into a [CaxiloGameBlock].
  static CaxiloGameBlock fromGame({
    required gac.Game game,
    required String providerId,
    required String providerName,
    required String image,
    caxiloconfig.ExternalConfig? externalSettings,
    bool enableHostMessage = false,
    List<caxiloconfig.GameOrientation>? mobileOrientation,
    List<caxiloconfig.GameOrientation>? tabletOrientation,
    List<caxiloconfig.GameOrientation>? desktopOrientation,
    bool? forceLandscapeViewportOnIpad,
    bool? openInNewTab,
    bool isInHouseGame = false,
  }) {
    // 1. Resolve hybrid provider-specific configuration overrides (Remote > Local Fallback)
    final providerConfig = externalSettings?.getConfigForProvider(providerId);

    // 2. Map fields, prioritizing: Explicit Argument > Hybrid Provider Config > Package/API default
    final resolvedGameType =
        providerConfig?.gameType ?? GameTypeMapper.fromPackageGameType(game.gameType);

    final resolvedMobileOrientation =
        mobileOrientation ?? providerConfig?.mobileOrientation ?? caxiloconfig.GameOrientation.all;

    final resolvedTabletOrientation =
        tabletOrientation ?? providerConfig?.tabletOrientation ?? caxiloconfig.GameOrientation.all;

    final resolvedDesktopOrientation =
        desktopOrientation ??
        providerConfig?.desktopOrientation ??
        caxiloconfig.GameOrientation.all;

    final resolvedForceLandscape =
        forceLandscapeViewportOnIpad ?? providerConfig?.forceLandscapeViewportOnIpad ?? false;

    final resolvedOpenInNewTab =
        openInNewTab ?? providerConfig?.openInNewTabOnIOSSafariWeb ?? false;

    final resolvedSessionGuard = providerConfig?.requiresSessionGuard ?? false;

    final resolvedDebounce = Duration(milliseconds: providerConfig?.loadStopDebounceMs ?? 0);

    // 3. Create the appropriate subclass
    if (isInHouseGame) {
      return CaxiloGameBlock.inHouse(
        productId: game.productId,
        gameCode: game.gameCode,
        gameName: game.gameName,
        lang: game.lang,
        providerId: providerId,
        providerName: providerName,
        image: image,
        gameType: resolvedGameType,
        mobileOrientation: resolvedMobileOrientation,
        tabletOrientation: resolvedTabletOrientation,
        desktopOrientation: resolvedDesktopOrientation,
        enableHostMessage: enableHostMessage,
        loadStopDebounce: resolvedDebounce.inMilliseconds > 0 ? resolvedDebounce : null,
      );
    }

    return CaxiloGameBlock.liveStream(
      productId: game.productId,
      gameCode: game.gameCode,
      gameName: game.gameName,
      lang: game.lang,
      lobbyUrl: game.lobbyUrl,
      cashierUrl: game.cashierUrl,
      mobileLogin: game.mobileLogin,
      providerId: providerId,
      providerName: providerName,
      image: image,
      gameType: resolvedGameType,
      mobileOrientation: resolvedMobileOrientation,
      tabletOrientation: resolvedTabletOrientation,
      desktopOrientation: resolvedDesktopOrientation,
      forceLandscapeViewportOnIpad: resolvedForceLandscape,
      openInNewTabOnIOSSafariWeb: resolvedOpenInNewTab,
      requiresSessionGuard: resolvedSessionGuard,
      loadStopDebounce: resolvedDebounce.inMilliseconds > 0 ? resolvedDebounce : null,
    );
  }
}
