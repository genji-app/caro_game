import 'dart:async';

import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api_client/game_api_client.dart' as gac;
import 'package:mocktail/mocktail.dart';

class MockGameApiClient extends Mock implements gac.GameApiClient {}

class MockCaxiloConfigClient extends Mock implements CaxiloConfigClient {}

class MockCaxiloStorage extends Mock implements CaxiloStorage {}

void main() {
  late gac.GameApiClient gameApiClient;
  late CaxiloConfigClient configClient;
  late CaxiloRepository repository;

  setUpAll(() {
    registerFallbackValue(const gac.GetGameUrlRequest(providerId: '', productId: '', gameCode: ''));
    registerFallbackValue(const CaxiloFilter.isInHouse());
  });

  setUp(() {
    gameApiClient = MockGameApiClient();
    configClient = MockCaxiloConfigClient();

    // Default mocks must be set up before repository instantiation
    when(() => configClient.onStatusChanged).thenAnswer((_) => const Stream.empty());
    when(() => configClient.config).thenReturn(null);

    repository = CaxiloRepository(client: gameApiClient, configClient: configClient);
  });

  group('CaxiloRepository', () {
    test('warmup seeds local games and fetches remote games', () async {
      final localGames = [
        const InHouseGame(
          productId: 'P1',
          gameCode: 'G1',
          gameName: 'In House 1',
          providerId: 'sunwin',
          providerName: 'Sunwin',
          image: 'img1.png',
          lang: 'vi',
          gameType: GameType.slot,
          launchStrategy: GameLaunchStrategy.standard,
        ),
      ];

      final remoteGames = [
        const gac.ProviderGames(
          providerId: 'amb-vn',
          providerName: 'SEXY',
          gameList: [
            gac.Game(
              productId: 'SEXY',
              gameCode: 'mx-live-001',
              gameName: 'Baccarat',
              lang: 'vi',
              lobbyUrl: '',
              cashierUrl: '',
              gameType: gac.GameType.live,
            ),
          ],
        ),
      ];

      when(() => configClient.getAllInHouseGames()).thenAnswer((_) async => localGames);
      when(() => gameApiClient.getGames()).thenAnswer((_) async => remoteGames);
      when(() => configClient.sync()).thenAnswer((_) async {});

      // Mock ExternalConfig for whitelist
      const externalSettings = ExternalConfig(
        providerConfigs: {
          'amb-vn': ExternalProviderConfig(games: [ExternalGame(gameCode: 'mx-live-001')]),
        },
      );
      final config = CaxiloConfig(
        updatedAt: '2026-05-01T00:00:00Z',
        external: externalSettings,
        categories: [],
        display: const DisplayConfig(order: ['G1', 'mx-live-001']),
        inHouse: const InHouseConfig(catalog: [], visibility: {}),
        environments: {},
      );
      when(() => configClient.config).thenReturn(config);

      await repository.warmup();

      verify(() => configClient.sync()).called(1);
      verify(() => configClient.getAllInHouseGames()).called(2); // once for seed, once for merge
      verify(() => gameApiClient.getGames()).called(1);

      final games = await repository.getCaxiloGames();
      expect(games.length, equals(2));
      expect(games.any((g) => g.isInHouseGame), isTrue);
      expect(games.any((g) => g.isLiveStreamGame), isTrue);
    });

    test('getCaxiloUrl routes correctly between in-house and remote', () async {
      when(() => configClient.isInHouseGame('sunwin')).thenReturn(true);
      when(() => configClient.isInHouseGame('amb-vn')).thenReturn(false);

      when(
        () => configClient.getGameUrl(
          gameCode: 'G1',
          isWeb: any(named: 'isWeb'),
        ),
      ).thenAnswer((_) async => 'https://local-url.com');

      when(() => gameApiClient.getGameUrl(any())).thenAnswer((_) async => 'https://remote-url.com');

      final localUrl = await repository.getCaxiloUrl(
        providerId: 'sunwin',
        productId: 'P1',
        gameCode: 'G1',
      );
      expect(localUrl, equals('https://local-url.com'));

      final remoteUrl = await repository.getCaxiloUrl(
        providerId: 'amb-vn',
        productId: 'P2',
        gameCode: 'G2',
      );
      expect(remoteUrl, equals('https://remote-url.com'));
    });

    test('getPopularGames returns games in popular collection', () async {
      final games = [
        const CaxiloGameBlockInHouse(
          providerId: 'sunwin',
          providerName: 'Sunwin',
          image: 'img.png',
          productId: 'P1',
          gameCode: 'G1',
          gameName: 'Game 1',
          lang: 'vi',
          gameType: GameType.slot,
        ),
        const CaxiloGameBlockInHouse(
          providerId: 'sunwin',
          providerName: 'Sunwin',
          image: 'img.png',
          productId: 'P2',
          gameCode: 'G2',
          gameName: 'Game 2',
          lang: 'vi',
          gameType: GameType.slot,
        ),
      ];

      when(() => configClient.config).thenReturn(
        const CaxiloConfig(
          updatedAt: '2026-05-01T00:00:00Z',
          display: DisplayConfig(
            collections: {
              'popular': ['G2'],
            },
          ),
          external: ExternalConfig(),
          categories: [],
          inHouse: InHouseConfig(catalog: [], visibility: {}),
          environments: {},
        ),
      );

      final result = repository.getPopularGamesFromList(games);
      expect(result.length, equals(1));
      expect(result.first.gameCode, equals('G2'));
    });

    test('getPopularGames returns empty if popular collection is not configured', () async {
      final games = [
        const CaxiloGameBlockInHouse(
          providerId: 'sunwin',
          providerName: 'Sunwin',
          image: 'img.png',
          productId: 'P1',
          gameCode: 'G1',
          gameName: 'Game 1',
          lang: 'vi',
          gameType: GameType.slot,
        ),
      ];

      when(() => configClient.config).thenReturn(
        const CaxiloConfig(
          updatedAt: '2026-05-01T00:00:00Z',
          display: DisplayConfig(
            collections: {
              'featured': ['G1'],
            },
          ),
          external: ExternalConfig(),
          categories: [],
          inHouse: InHouseConfig(catalog: [], visibility: {}),
          environments: {},
        ),
      );

      final result = repository.getPopularGamesFromList(games);
      expect(result, isEmpty);
    });

    group('getCaxiloCategories', () {
      test('uses lobbyCategory from remote config for "all" tab', () {
        when(() => configClient.config).thenReturn(
          const CaxiloConfig(
            updatedAt: '2026-05-01T00:00:00Z',
            lobby: LobbyConfig(
              translationKey: 'txt_custom_home',
              icon: 'ic_custom_home.svg',
              iconActive: 'ic_custom_home_active.svg',
            ),
            categories: [
              CategoryConfig(
                id: 'slots',
                translationKey: 'txt_game_slots',
                icon: 'ic_slots.svg',
                iconActive: 'ic_slots_yellow.svg',
                filter: caxiloconfig.CaxiloFilter(
                  strategy: caxiloconfig.CaxiloFilterStrategy.byGameType,
                  params: {'game_type': 'slot'},
                ),
              ),
            ],
            external: ExternalConfig(),
            inHouse: InHouseConfig(catalog: [], visibility: {}),
            environments: {},
          ),
        );

        final result = repository.getCaxiloCategories();

        expect(result.all.translationKey, equals('txt_custom_home'));
        expect(result.all.icon, equals('ic_custom_home.svg'));
        expect(result.all.iconActive, equals('ic_custom_home_active.svg'));
        expect(result.categories, hasLength(1));
        expect(result.categories.first.categoryId, equals('slots'));
      });

      test('falls back to hardcoded lobby category when lobbyCategory is absent', () {
        when(() => configClient.config).thenReturn(
          const CaxiloConfig(
            updatedAt: '2026-05-01T00:00:00Z',
            categories: [
              CategoryConfig(
                id: 'live',
                translationKey: 'txt_game_live',
                icon: 'ic_live.svg',
                iconActive: 'ic_live_yellow.svg',
                filter: caxiloconfig.CaxiloFilter(
                  strategy: caxiloconfig.CaxiloFilterStrategy.byGameType,
                  params: {'game_type': 'live'},
                ),
              ),
            ],
            external: ExternalConfig(),
            inHouse: InHouseConfig(catalog: [], visibility: {}),
            environments: {},
          ),
        );

        final result = repository.getCaxiloCategories();

        expect(result.all.translationKey, equals('txt_game_category_all'));
        expect(result.all.icon, equals('ic_home.svg'));
        expect(result.categories, hasLength(1));
      });
    });

    group('getCaxiloSidebarData', () {
      test('uses groupKey from remote config to classify categories', () {
        when(() => configClient.config).thenReturn(
          const CaxiloConfig(
            updatedAt: '2026-05-01T00:00:00Z',
            categories: [
              CategoryConfig(
                id: 'sunwin',
                groupKey: 'priority',
                translationKey: 'txt_game_category_sunwin',
                icon: 'ic_sunwin.png',
                iconActive: 'ic_sunwin.png',
                filter: caxiloconfig.CaxiloFilter(
                  strategy: caxiloconfig.CaxiloFilterStrategy.inHouse,
                ),
              ),
              CategoryConfig(
                id: 'slots',
                groupKey: 'standard',
                translationKey: 'txt_game_slots',
                icon: 'ic_slots.svg',
                iconActive: 'ic_slots_yellow.svg',
                filter: caxiloconfig.CaxiloFilter(
                  strategy: caxiloconfig.CaxiloFilterStrategy.byGameType,
                  params: {'game_type': 'slot'},
                ),
              ),
            ],
            external: ExternalConfig(),
            inHouse: InHouseConfig(catalog: [], visibility: {}),
            environments: {},
          ),
        );

        final result = repository.getSidebarData();
        final priority = result.groups.firstWhere((g) => g.id == 'priority');
        final standard = result.groups.firstWhere((g) => g.id == 'standard');

        expect(priority.categories.map((c) => c.categoryId), containsAll(['all', 'sunwin']));
        expect(standard.categories.map((c) => c.categoryId), contains('slots'));
      });

      test('falls back to type-based classification when groupKey is absent', () {
        when(() => configClient.config).thenReturn(
          const CaxiloConfig(
            updatedAt: '2026-05-01T00:00:00Z',
            categories: [
              CategoryConfig(
                id: 'sunwin',
                // no groupKey → falls back to InHouseFilter → priority
                translationKey: 'txt_game_category_sunwin',
                icon: 'ic_sunwin.png',
                iconActive: 'ic_sunwin.png',
                filter: caxiloconfig.CaxiloFilter(
                  strategy: caxiloconfig.CaxiloFilterStrategy.inHouse,
                ),
              ),
              CategoryConfig(
                id: 'sports',
                // no groupKey + excludedType → excluded from both groups
                translationKey: 'txt_game_sports',
                icon: 'ic_football.svg',
                iconActive: 'ic_football_yellow.svg',
                filter: caxiloconfig.CaxiloFilter(
                  strategy: caxiloconfig.CaxiloFilterStrategy.byGameType,
                  params: {'game_type': 'sport'},
                ),
              ),
            ],
            external: ExternalConfig(),
            inHouse: InHouseConfig(catalog: [], visibility: {}),
            environments: {},
          ),
        );

        final result = repository.getSidebarData();
        final priority = result.groups.firstWhere((g) => g.id == 'priority');
        final standard = result.groups.firstWhere((g) => g.id == 'standard');

        expect(priority.categories.map((c) => c.categoryId), contains('sunwin'));
        expect(standard.categories, isEmpty);
        // sports excluded from both groups
        expect(
          result.groups.expand((g) => g.categories).map((c) => c.categoryId),
          isNot(contains('sports')),
        );
      });
    });

    group('Backward Compatibility', () {
      test('getGames delegates to getCaxiloGames', () async {
        when(() => gameApiClient.getGames()).thenAnswer((_) async => []);
        when(() => configClient.getAllInHouseGames()).thenAnswer((_) async => []);

        final result = await repository.getGames();
        expect(result, isEmpty);
      });
    });
  });
}
