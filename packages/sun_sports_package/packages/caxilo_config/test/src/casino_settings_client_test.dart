import 'package:caxilo_config/caxilo_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late CaxiloConfigClient client;
  late MockHttpClient mockHttpClient;

  final mockConfigData = CaxiloConfigPresets.buildSettings(CaxiloEnvironment.dev);

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = CaxiloConfigClient(
      httpClient: mockHttpClient,
      tokenProvider: () => 'test_token',
      refreshTokenProvider: () async => 'test_refresh_token',
    );
  });

  group('CaxiloConfigClient Merge Verification', () {
    test('should load config from map and expose it via mixin', () {
      client.loadFromMap(mockConfigData);
      expect(client.config, isNotNull);
      expect(client.config?.version, 2);
      expect(client.status, const CaxiloConfigStatus.loaded());
    });

    test('should return correct games from catalog', () {
      client.loadFromMap(mockConfigData);
      final games = client.getAllInHouseGames();
      expect(games, completion(isNotEmpty));
      expect(games, completion(anyElement((g) => g.gameCode == 'AVENGER')));
    });

    test('should generate correct URL using StandardLaunchStrategy', () async {
      client.loadFromMap(mockConfigData);
      // AVENGER uses 'avenger_base_url' which in dev is 'https://avenger.sunwin.live'
      final url = await client.getGameUrl(gameCode: 'AVENGER', isWeb: true);

      expect(url, contains('https://avenger.sunwin.live'));
      expect(url, contains('accessToken=test_token'));
      expect(url, contains('ru=flutter-web'));
    });

    test('should throw exception when game is not found', () async {
      client.loadFromMap(mockConfigData);
      expect(
        () => client.getGameUrl(gameCode: 'non_existent'),
        throwsA(isA<InHouseGameUnderDevelopmentException>()),
      );
    });
  });
}
