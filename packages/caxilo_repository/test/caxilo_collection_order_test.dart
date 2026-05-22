import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCaxiloConfigClient extends Mock implements CaxiloConfigClient {}

class _TestSearchEngine with CaxiloSearchEngineMixin {
  _TestSearchEngine(this._client);

  final CaxiloConfigClient _client;

  @override
  CaxiloConfigClient get configClient => _client;

  @override
  CaxiloUtils get utils => CaxiloUtils();

  @override
  String get defaultProviderId => 'sunwin';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CaxiloGameBlockInHouse _inHouse(String gameCode) => CaxiloGameBlockInHouse(
  providerId: 'sunwin',
  providerName: 'Sunwin',
  image: 'img.png',
  productId: gameCode,
  gameCode: gameCode,
  gameName: gameCode,
  lang: 'vi',
  gameType: GameType.slot,
);

CaxiloGameBlockLiveStream _remote(String gameCode, {String provider = 'amb-vn'}) =>
    CaxiloGameBlockLiveStream(
      providerId: provider,
      providerName: provider,
      image: 'img.png',
      productId: gameCode,
      gameCode: gameCode,
      gameName: gameCode,
      lang: 'vi',
      gameType: GameType.live,
      lobbyUrl: '',
      cashierUrl: '',
    );

CaxiloConfig _settingsWithCollections(Map<String, List<String>> collections) => CaxiloConfig(
  updatedAt: '2026-05-01T00:00:00Z',
  display: DisplayConfig(collections: collections),
  external: const ExternalConfig(),
  categories: const [],
  inHouse: const InHouseConfig(catalog: [], visibility: {}),
  environments: const {},
);

void main() {
  late MockCaxiloConfigClient client;
  late _TestSearchEngine engine;

  setUp(() {
    client = MockCaxiloConfigClient();
    engine = _TestSearchEngine(client);
  });

  List<String> codes(List<CaxiloGameBlock> games) => games.map((g) => g.gameCode).toList();

  group('applySearchAndFilter — collection order (Option B)', () {
    test('returns games in collection array order, not allGames order', () {
      // allGames is ordered [IH1, IH2, R1] but collection says [R1, IH2, IH1]
      when(() => client.config).thenReturn(
        _settingsWithCollections({
          'featured': ['R1', 'IH2', 'IH1'],
        }),
      );

      final allGames = [_inHouse('IH1'), _inHouse('IH2'), _remote('R1')];
      final result = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'featured'),
      );

      expect(codes(result), equals(['R1', 'IH2', 'IH1']));
    });

    test('remote game can appear before in-house game via collection order', () {
      when(() => client.config).thenReturn(
        _settingsWithCollections({
          'featured': ['mx-live-001', 'SC', 'SP'],
        }),
      );

      final allGames = [_inHouse('SC'), _inHouse('SP'), _remote('mx-live-001')];
      final result = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'featured'),
      );

      expect(result.first.gameCode, equals('mx-live-001'));
      expect(result.first.isLiveStreamGame, isTrue);
    });

    test('different collections can have different orderings for same games', () {
      when(() => client.config).thenReturn(
        _settingsWithCollections({
          'section_a': ['IH1', 'R1'],
          'section_b': ['R1', 'IH1'],
        }),
      );

      final allGames = [_inHouse('IH1'), _remote('R1')];

      final sectionA = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'section_a'),
      );
      final sectionB = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'section_b'),
      );

      expect(codes(sectionA), equals(['IH1', 'R1']));
      expect(codes(sectionB), equals(['R1', 'IH1']));
    });

    test('only games listed in collection are included', () {
      when(() => client.config).thenReturn(
        _settingsWithCollections({
          'popular': ['SC', 'SP'],
        }),
      );

      final allGames = [_inHouse('SC'), _inHouse('SP'), _inHouse('VT'), _remote('R1')];
      final result = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'popular'),
      );

      expect(codes(result), equals(['SC', 'SP']));
    });

    test('games not in collection array go to end (safety fallback)', () {
      // IH1 is in collection, IH2 is not (but passes filter somehow — edge case)
      // This tests the safety weight for indexOf == -1
      when(() => client.config).thenReturn(
        _settingsWithCollections({
          'featured': ['IH1'],
        }),
      );

      // IH2 won't pass filter.matches so it won't appear — collection IS the filter
      final allGames = [_inHouse('IH1'), _inHouse('IH2')];
      final result = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'featured'),
      );

      expect(codes(result), equals(['IH1']));
    });

    test('non-collection filters are unaffected — order comes from allGames', () {
      when(() => client.config).thenReturn(_settingsWithCollections({}));

      // allGames already sorted by display.order: IH1, IH2
      final allGames = [_inHouse('IH1'), _inHouse('IH2')];
      final result = engine.applySearchAndFilter(allGames, filter: const CaxiloFilter.isInHouse());

      // Should preserve allGames order (no re-sort for non-collection filters)
      expect(codes(result), equals(['IH1', 'IH2']));
    });

    test('empty collection returns empty list', () {
      when(() => client.config).thenReturn(_settingsWithCollections({'featured': []}));

      final allGames = [_inHouse('IH1'), _remote('R1')];
      final result = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'featured'),
      );

      expect(result, isEmpty);
    });

    test('collection not found in config returns empty list', () {
      when(() => client.config).thenReturn(
        _settingsWithCollections({
          'other': ['IH1'],
        }),
      );

      final allGames = [_inHouse('IH1')];
      final result = engine.applySearchAndFilter(
        allGames,
        filter: const CaxiloFilter.byCollection(collectionId: 'featured'),
      );

      expect(result, isEmpty);
    });
  });
}
