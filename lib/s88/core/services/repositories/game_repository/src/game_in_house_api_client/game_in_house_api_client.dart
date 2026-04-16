import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart';

import '../models/game_block.dart';

/// Base exception class for all [GameInHouseApiClient] related errors.
sealed class GameInHouseException implements Exception {
  /// {@macro game_in_house_exception}
  const GameInHouseException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when an [GameInHouseApiClient] game is requested but its
/// entry point (URL) has not been implemented yet.
class GameInHouseUnderDevelopmentException extends GameInHouseException {
  /// {@macro game_in_house_under_development_exception}
  const GameInHouseUnderDevelopmentException() : super('Game is not ready.');
}

/// Exception thrown when the URL for an [GameInHouseApiClient] game could
/// not be retrieved.
class GameInHouseUrlFetchException extends GameInHouseException {
  /// {@macro game_in_house_url_fetch_exception}
  const GameInHouseUrlFetchException(super.message);
}

typedef UrlProvider = String Function();

/// Client for fetching in-house/hardcoded games.
class GameInHouseApiClient {
  GameInHouseApiClient({
    this.tokenProvider,
    this.fish88Url = 'https://fish-s88.sandboxg1.win',
  });

  final String Function()? tokenProvider;
  final String? fish88Url;

  /// Sunwin provider ID (SSOT)
  ///
  /// Use this constant anywhere you need to reference the Sunwin provider.
  static const String sunwinProviderId = 'sunwin';

  /// Sunwin provider display name
  static const String sunwinProviderName = 'Sunwin';

  /// X88 provider ID (SSOT)
  static const String x88ProviderId = 'x88';

  /// X88 provider display name
  static const String x88ProviderName = 'X88';

  /// Checks if the given [providerId] corresponds to a local provider.
  bool isLocalProvider(String providerId) =>
      providerId == sunwinProviderId || providerId == x88ProviderId;

  /// Returns the launch URL for a specific local game code.
  ///
  /// [isWeb] specifies if the game is being launched from a web platform.
  ///
  /// Throws [GameInHouseUnderDevelopmentException] if the game is recognized
  /// as local but its entry point is not yet implemented.
  Future<String> getGameUrl({
    required String gameCode,
    bool isWeb = kIsWeb,
  }) async {
    final token = tokenProvider?.call() ?? '';
    if (gameCode == 'SC') {
      var url = '$fish88Url/?token=$token';
      url += isWeb ? '&ru=flutter-web' : '&ru=flutter-app';
      return url;
    }

    await Future<void>.delayed(const Duration(seconds: 1));
    // throw const GameInHouseUrlFetchException('Cannot get game url');
    throw const GameInHouseUnderDevelopmentException();
  }

  /// Returns the list of all local games.
  List<GameBlock> getAllLocalGames() {
    return [
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_SC',
        gameCode: 'SC',
        gameName: 'Sun cá',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_SC_sun-ca_thumb.webp',
        enableHostMessage: true,
        mobileOrientation: GameOrientation.landscape,
        tabletOrientation: GameOrientation.landscape,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_SP',
        gameCode: 'SP',
        gameName: 'Sun phụng',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_SP_sun-phung_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_VT',
        gameCode: 'VT',
        gameName: 'Volta',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_VT_volta_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_VTS',
        gameCode: 'VTS',
        gameName: 'Volta S',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_VTS_volta-s_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_SR',
        gameCode: 'SR',
        gameName: 'Sun rồng', // Bắn cá
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_SR_sun-rong_thumb.webp',
        enableHostMessage: true,
        mobileOrientation: GameOrientation.landscape,
        tabletOrientation: GameOrientation.landscape,
        // forceLandscapeViewportOnIpad: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: x88ProviderId,
        providerName: x88ProviderName,
        productId: 'x88_SB88',
        gameCode: 'SB88',
        gameName: 'Sicbo88',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.live,
        mobileLogin: true,
        image: 'x88_SB88_sicbo88_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_TP',
        gameCode: 'TP',
        gameName: 'Tài phú',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.slot,
        mobileLogin: true,
        image: 'sunwin_TP_tai-phu_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_XD-TL',
        gameCode: 'XD-TL',
        gameName: 'Xóc đĩa tứ linh',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_XD-TL_xoc-dia-tu-linh_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_TX-LIVE',
        gameCode: 'TX-LIVE',
        gameName: 'Tài xỉu live',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.live,
        mobileLogin: true,
        image: 'sunwin_TX-LIVE_tai-xiu-live_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_XD-LIVE',
        gameCode: 'XD-LIVE',
        gameName: 'Xóc đĩa live',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.live,
        mobileLogin: true,
        image: 'sunwin_XD-LIVE_xoc-dia-live_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_XD-TT-LIVE',
        gameCode: 'XD-TT-LIVE',
        gameName: 'Xóc đĩa thuỷ tinh live',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.live,
        mobileLogin: true,
        image: 'sunwin_XD-TT-LIVE_xoc-dia-thuy-tinh-live_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_BC-LT',
        gameCode: 'BC-LT',
        gameName: 'Bầu cua lộc thú',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_BC-LT_bau-cua-loc-thu_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
      const GameBlock(
        providerId: sunwinProviderId,
        providerName: sunwinProviderName,
        productId: 'sunwin_LODE',
        gameCode: 'LODE',
        gameName: 'Lô đề',
        lang: 'vi',
        lobbyUrl: '',
        cashierUrl: '',
        gameType: GameType.miniGame,
        mobileLogin: true,
        image: 'sunwin_LODE_lo-de_thumb.webp',
        enableHostMessage: true,
        isInHouseGame: true,
      ),
    ];
  }
}
