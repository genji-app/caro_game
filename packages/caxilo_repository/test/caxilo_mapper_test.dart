import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api_client/game_api_client.dart' as gac;

void main() {
  group('CaxiloGameBlockMapper', () {
    test('fromInHouseConfig maps correctly', () {
      const config = InHouseGame(
        productId: 'sunwin_AVENGER',
        gameCode: 'AVENGER',
        gameName: 'Avengers',
        providerId: 'sunwin',
        providerName: 'Sunwin',
        image: 'assets/games/avenger.png',
        lang: 'vi',
        gameType: GameType.slot,
        launchStrategy: GameLaunchStrategy.standard,
        mobileOrientation: GameOrientation.landscape,
        tabletOrientation: GameOrientation.landscape,
        desktopOrientation: GameOrientation.landscape,
        enableHostMessage: true,
      );

      final result = CaxiloGameBlockMapper.fromInHouseConfig(config);

      expect(result, isA<CaxiloGameBlockInHouse>());
      expect(result.productId, equals('sunwin_AVENGER'));
      expect(result.gameCode, equals('AVENGER'));
      expect(result.gameName, equals('Avengers'));
      expect(result.providerId, equals('sunwin'));
      expect(result.providerName, equals('Sunwin'));
      expect(result.image, equals('assets/games/avenger.png'));
      expect(result.gameType, equals(GameType.slot));
      expect(result.isInHouseGame, isTrue);
      expect((result as CaxiloGameBlockInHouse).enableHostMessage, isTrue);
    });

    test('fromGame maps correctly without overrides', () {
      const game = gac.Game(
        productId: 'SEXY',
        gameCode: 'MX-LIVE-001',
        gameName: 'Baccarat Classic',
        lang: 'vi',
        lobbyUrl: 'https://lobby.com',
        cashierUrl: 'https://cashier.com',
        gameType: gac.GameType.live,
        mobileLogin: true,
      );

      final result = CaxiloGameBlockMapper.fromGame(
        game: game,
        providerId: 'amb-vn',
        providerName: 'SEXY',
        image: 'amb-vn_thumb.webp',
      );

      expect(result, isA<CaxiloGameBlockLiveStream>());
      expect(result.productId, equals('SEXY'));
      expect(result.gameCode, equals('MX-LIVE-001'));
      expect(result.gameName, equals('Baccarat Classic'));
      expect(result.providerId, equals('amb-vn'));
      expect(result.providerName, equals('SEXY'));
      expect(result.image, equals('amb-vn_thumb.webp'));
      expect(result.gameType, equals(GameType.live));
      expect(result.isLiveStreamGame, isTrue);

      final liveBlock = result as CaxiloGameBlockLiveStream;
      expect(liveBlock.lobbyUrl, equals('https://lobby.com'));
      expect(liveBlock.cashierUrl, equals('https://cashier.com'));
      expect(liveBlock.mobileLogin, isTrue);
    });

    test('fromGame applies overrides from ExternalConfig', () {
      const game = gac.Game(
        productId: 'SEXY',
        gameCode: 'MX-LIVE-001',
        gameName: 'Baccarat Classic',
        lang: 'vi',
        lobbyUrl: 'https://lobby.com',
        cashierUrl: 'https://cashier.com',
        gameType: gac.GameType.live,
      );

      const externalSettings = ExternalConfig(
        providerConfigs: {
          'amb-vn': ExternalProviderConfig(
            gameType: GameType.others,
            mobileOrientation: [GameOrientation.portraitUp],
            forceLandscapeViewportOnIpad: true,
            openInNewTabOnIOSSafariWeb: true,
            requiresSessionGuard: true,
            loadStopDebounceMs: 500,
          ),
        },
      );

      final result = CaxiloGameBlockMapper.fromGame(
        game: game,
        providerId: 'amb-vn',
        providerName: 'SEXY',
        image: 'overridden_image.webp',
        externalSettings: externalSettings,
      );

      expect(result.gameType, equals(GameType.others));
      expect(result.mobileOrientation, contains(GameOrientation.portraitUp));

      final liveBlock = result as CaxiloGameBlockLiveStream;
      expect(liveBlock.forceLandscapeViewportOnIpad, isTrue);
      expect(liveBlock.openInNewTabOnIOSSafariWeb, isTrue);
      expect(liveBlock.requiresSessionGuard, isTrue);
      expect(liveBlock.loadStopDebounce?.inMilliseconds, equals(500));
    });
  });
}
