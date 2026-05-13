import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaxiloFilter', () {
    const inHouseGame = CaxiloGameBlockInHouse(
      providerId: 'sunwin',
      providerName: 'Sunwin',
      image: 'img.png',
      productId: 'P1',
      gameCode: 'G1',
      gameName: 'Game 1',
      lang: 'vi',
      gameType: GameType.slot,
    );

    const remoteGame = CaxiloGameBlockLiveStream(
      providerId: 'vivo',
      providerName: 'Vivo',
      image: 'img2.png',
      productId: 'P2',
      gameCode: 'G2',
      gameName: 'Game 2',
      lang: 'vi',
      gameType: GameType.live,
      lobbyUrl: '',
      cashierUrl: '',
    );

    test('isInHouse filter matches correctly', () {
      const filter = CaxiloFilter.isInHouse();
      expect(filter.matches(inHouseGame), isTrue);
      expect(filter.matches(remoteGame), isFalse);
    });

    test('byProviders filter matches correctly', () {
      final filter = CaxiloFilter.byProviders(providerIds: ['sunwin']);
      expect(filter.matches(inHouseGame), isTrue);
      expect(filter.matches(remoteGame), isFalse);
    });

    test('byGameTypes filter matches correctly', () {
      final filter = CaxiloFilter.byGameTypes(gameTypes: [GameType.slot]);
      expect(filter.matches(inHouseGame), isTrue);
      expect(filter.matches(remoteGame), isFalse);
    });

    test('byCollection filter matches correctly', () {
      const filter = CaxiloFilter.byCollection(collectionId: 'popular');
      const collections = {
        'popular': ['G1'],
      };

      expect(filter.matches(inHouseGame, collections: collections), isTrue);
      expect(filter.matches(remoteGame, collections: collections), isFalse);
    });

    test('byGameCodes filter matches correctly', () {
      final filter = CaxiloFilter.byGameCodes(gameCodes: ['G2']);

      expect(filter.matches(inHouseGame), isFalse);
      expect(filter.matches(remoteGame), isTrue);
    });

    test('all filter (AND) matches correctly', () {
      final filter = CaxiloFilter.all(
        filters: [
          const CaxiloFilter.isInHouse(),
          CaxiloFilter.byGameTypes(gameTypes: [GameType.slot]),
        ],
      );
      expect(filter.matches(inHouseGame), isTrue);

      final inHouseLive = inHouseGame.copyWith(gameType: GameType.live);
      expect(filter.matches(inHouseLive), isFalse);
    });

    test('any filter (OR) matches correctly', () {
      final filter = CaxiloFilter.any(
        filters: [
          const CaxiloFilter.isInHouse(),
          CaxiloFilter.byProviders(providerIds: ['vivo']),
        ],
      );
      expect(filter.matches(inHouseGame), isTrue);
      expect(filter.matches(remoteGame), isTrue);

      final otherGame = remoteGame.copyWith(providerId: 'other');
      expect(filter.matches(otherGame), isFalse);
    });

    test('fromStrategy maps correctly', () {
      final collectionFilter = CaxiloFilter.fromStrategy(
        caxiloconfig.CaxiloFilterStrategy.collection,
        {'id': 'custom_list'},
      );
      expect(
        collectionFilter,
        equals(const CaxiloFilter.byCollection(collectionId: 'custom_list')),
      );

      final gameCodesFilter = CaxiloFilter.fromStrategy(
        caxiloconfig.CaxiloFilterStrategy.byGameCodes,
        {
          'game_codes': ['G1', 'G2'],
        },
      );
      expect(gameCodesFilter, equals(const CaxiloFilter.byGameCodes(gameCodes: ['G1', 'G2'])));

      final unknownFilter = CaxiloFilter.fromStrategy(
        caxiloconfig.CaxiloFilterStrategy.unknown,
        null,
      );
      expect(unknownFilter, equals(const CaxiloFilter.none()));
    });

    test('fromFilterConfig maps correctly', () {
      const config = caxiloconfig.CaxiloFilter(
        strategy: caxiloconfig.CaxiloFilterStrategy.collection,
        params: {'id': 'hot_games'},
      );
      final filter = CaxiloFilter.fromFilterConfig(config);
      expect(filter, equals(const CaxiloFilter.byCollection(collectionId: 'hot_games')));
    });
  });
}
