import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCaxiloConfigClient extends Mock implements CaxiloConfigClient {}

// Minimal concrete class to test the mixin in isolation.
class _TestProcessor with CaxiloDataProcessorMixin {
  _TestProcessor(this._client);

  final CaxiloConfigClient _client;

  @override
  CaxiloConfigClient get configClient => _client;

  @override
  CaxiloUtils get utils => CaxiloUtils();

  String get defaultProviderId => 'sunwin';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CaxiloGameBlockInHouse _inHouse(String gameCode, {String gameName = ''}) => CaxiloGameBlockInHouse(
  providerId: 'sunwin',
  providerName: 'Sunwin',
  image: 'img.png',
  productId: gameCode,
  gameCode: gameCode,
  gameName: gameName.isEmpty ? gameCode : gameName,
  lang: 'vi',
  gameType: GameType.slot,
);

CaxiloGameBlockLiveStream _remote(
  String gameCode, {
  String provider = 'amb-vn',
  String providerName = 'AMB',
  String gameName = '',
}) => CaxiloGameBlockLiveStream(
  providerId: provider,
  providerName: providerName,
  image: 'img.png',
  productId: gameCode,
  gameCode: gameCode,
  gameName: gameName.isEmpty ? gameCode : gameName,
  lang: 'vi',
  gameType: GameType.live,
  lobbyUrl: '',
  cashierUrl: '',
);

CaxiloConfig _settingsWithOrder(List<String> order) => CaxiloConfig(
  updatedAt: '2026-05-01T00:00:00Z',
  display: DisplayConfig(order: order),
  external: const ExternalConfig(),
  categories: const [],
  inHouse: const InHouseConfig(catalog: [], visibility: {}),
  environments: const {},
);

void main() {
  late MockCaxiloConfigClient client;
  late _TestProcessor processor;

  setUp(() {
    client = MockCaxiloConfigClient();
    processor = _TestProcessor(client);
  });

  List<String> codes(List<CaxiloGameBlock> games) => games.map((g) => g.gameCode).toList();

  group('mergeAndSortGames — display.order controls position', () {
    test('both in order: follows exact server-defined sequence', () {
      when(() => client.config).thenReturn(_settingsWithOrder(['R1', 'IH1', 'R2', 'IH2']));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1'), _remote('R2')],
        localGames: [_inHouse('IH1'), _inHouse('IH2')],
      );

      expect(codes(result), equals(['R1', 'IH1', 'R2', 'IH2']));
    });

    test('remote can appear before in-house when order specifies it', () {
      when(() => client.config).thenReturn(_settingsWithOrder(['R1', 'IH1']));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1')],
        localGames: [_inHouse('IH1')],
      );

      expect(codes(result), equals(['R1', 'IH1']));
    });

    test('ordered games come before unordered games regardless of type', () {
      when(() => client.config).thenReturn(_settingsWithOrder(['R1']));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1'), _remote('R2')],
        localGames: [_inHouse('IH1')],
      );

      // R1 is in order → first; IH1 and R2 are not in order
      expect(result.first.gameCode, equals('R1'));
    });
  });

  group('mergeAndSortGames — fallback when not in order', () {
    test('in-house comes before remote when neither is in order', () {
      when(() => client.config).thenReturn(_settingsWithOrder([]));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1')],
        localGames: [_inHouse('IH1')],
      );

      expect(result.first.gameCode, equals('IH1'));
      expect(result.last.gameCode, equals('R1'));
    });

    test('remote games without order are sub-sorted by provider then name', () {
      when(() => client.config).thenReturn(_settingsWithOrder([]));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [
          _remote('Z1', provider: 'vivo', providerName: 'Vivo', gameName: 'Zebra'),
          _remote('A1', provider: 'amb-vn', providerName: 'AMB', gameName: 'Alpha'),
          _remote('A2', provider: 'amb-vn', providerName: 'AMB', gameName: 'Beta'),
        ],
        localGames: [],
      );

      // AMB before Vivo (alphabetical provider), then Alpha before Beta
      expect(codes(result), equals(['A1', 'A2', 'Z1']));
    });

    test('in-house games without order are sorted by game name', () {
      when(() => client.config).thenReturn(_settingsWithOrder([]));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [],
        localGames: [
          _inHouse('C', gameName: 'Cha'),
          _inHouse('A', gameName: 'Alpha'),
          _inHouse('B', gameName: 'Beta'),
        ],
      );

      expect(codes(result), equals(['A', 'B', 'C']));
    });
  });

  group('mergeAndSortGames — partial order', () {
    test('ordered games lead, unordered in-house before unordered remote at the tail', () {
      when(() => client.config).thenReturn(_settingsWithOrder(['IH2']));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1')],
        localGames: [_inHouse('IH1'), _inHouse('IH2')],
      );

      // IH2 ordered → first; IH1 unordered in-house → before R1 unordered remote
      expect(result[0].gameCode, equals('IH2'));
      expect(result[1].gameCode, equals('IH1'));
      expect(result[2].gameCode, equals('R1'));
    });

    test('multiple ordered interleaved with unordered tail', () {
      when(() => client.config).thenReturn(_settingsWithOrder(['R1', 'IH1']));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1'), _remote('R2')],
        localGames: [_inHouse('IH1'), _inHouse('IH2')],
      );

      // Ordered: R1, IH1 — Unordered: IH2 (in-house) before R2 (remote)
      expect(codes(result), equals(['R1', 'IH1', 'IH2', 'R2']));
    });
  });

  group('mergeAndSortGames — edge cases', () {
    test('empty order: all in-house before all remote', () {
      when(() => client.config).thenReturn(_settingsWithOrder([]));

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1'), _remote('R2')],
        localGames: [_inHouse('IH1'), _inHouse('IH2')],
      );

      expect(result.take(2).every((g) => g.isInHouseGame), isTrue);
      expect(result.skip(2).every((g) => g.isLiveStreamGame), isTrue);
    });

    test('empty games list returns empty', () {
      when(() => client.config).thenReturn(_settingsWithOrder(['G1']));

      final result = processor.mergeAndSortGames(processedRemoteGames: [], localGames: []);

      expect(result, isEmpty);
    });

    test('no config (null): falls back to in-house first', () {
      when(() => client.config).thenReturn(null);

      final result = processor.mergeAndSortGames(
        processedRemoteGames: [_remote('R1')],
        localGames: [_inHouse('IH1')],
      );

      expect(result.first.gameCode, equals('IH1'));
    });
  });
}
