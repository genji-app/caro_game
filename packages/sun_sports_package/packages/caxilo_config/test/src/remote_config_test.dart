import 'package:caxilo_config/caxilo_config.dart' as cc;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

const _stagingUrl =
    'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_staging.json';
const _prodUrl = 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_prod.json';

void main() {
  group('Remote config — fetchSettings (unit)', () {
    late _MockHttpClient mockHttp;
    late cc.CaxiloConfigClient client;

    setUpAll(() => registerFallbackValue(Uri()));

    setUp(() {
      mockHttp = _MockHttpClient();
      client = cc.CaxiloConfigClient(
        httpClient: mockHttp,
        tokenProvider: () => 'test_token',
        refreshTokenProvider: () async => 'test_refresh_token',
      );
    });

    test('decodes base64 response and loads config', () async {
      final b64 = cc.CaxiloConfigPresets.toBase64String(cc.CaxiloEnvironment.staging);
      when(
        () => mockHttp.get(Uri.parse(_stagingUrl)),
      ).thenAnswer((_) async => http.Response(b64, 200));

      await client.fetchSettings(_stagingUrl);

      expect(client.status, const cc.CaxiloConfigStatus.loaded());
      expect(client.config, isNotNull);
      expect(client.config!.version, 2);
      expect(client.config!.inHouse.catalog, isNotEmpty);
      expect(client.config!.categories, isNotEmpty);
      expect(client.config!.external.providerConfigs, isNotEmpty);
    });

    test('throws CaxiloConfigFetchException on 404', () async {
      when(
        () => mockHttp.get(Uri.parse(_stagingUrl)),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      await expectLater(
        client.fetchSettings(_stagingUrl),
        throwsA(isA<cc.CaxiloConfigFetchException>()),
      );
      expect(client.status, isA<cc.CaxiloConfigStatusFailure>());
    });

    test('throws CaxiloConfigException when body is malformed', () async {
      when(
        () => mockHttp.get(Uri.parse(_stagingUrl)),
      ).thenAnswer((_) async => http.Response('not-valid-json-or-b64!!@@', 200));

      await expectLater(
        client.fetchSettings(_stagingUrl),
        throwsA(isA<cc.CaxiloConfigException>()),
      );
    });

    test('sync() — calls fetchSettings with initialUrl', () async {
      final b64 = cc.CaxiloConfigPresets.toBase64String(cc.CaxiloEnvironment.staging);
      when(
        () => mockHttp.get(Uri.parse(_stagingUrl)),
      ).thenAnswer((_) async => http.Response(b64, 200));

      final clientWithUrl = cc.CaxiloConfigClient(
        httpClient: mockHttp,
        initialUrl: _stagingUrl,
        tokenProvider: () => 'test_token',
        refreshTokenProvider: () async => null,
      );

      await clientWithUrl.sync();

      expect(clientWithUrl.status, const cc.CaxiloConfigStatus.loaded());
      verify(() => mockHttp.get(Uri.parse(_stagingUrl))).called(1);
    });

    test('sync() — no-op when initialUrl is null', () async {
      await client.sync();

      expect(client.status, const cc.CaxiloConfigStatus.initial());
      verifyNever(() => mockHttp.get(any()));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Live tests — hit actual GitHub URLs.
  // Run with: flutter test --tags live
  // ────────────────────────────────────────────────────────────────────────────
  group('Remote config — LIVE', () {
    cc.CaxiloConfigClient makeClient() => cc.CaxiloConfigClient(
      tokenProvider: () => 'test_token',
      refreshTokenProvider: () async => null,
    );

    test('staging URL — fetches and parses real config', () async {
      final client = makeClient();
      addTearDown(client.dispose);

      await client.fetchSettings(_stagingUrl);

      expect(client.status, const cc.CaxiloConfigStatus.loaded());
      final cfg = client.config!;
      expect(cfg.version, 2);
      expect(cfg.inHouse.catalog.length, greaterThanOrEqualTo(1));
      expect(cfg.categories.length, greaterThanOrEqualTo(1));
      expect(cfg.external.providerConfigs.keys, containsAll(['amb-vn', 'vivo', 'lcevo']));
    }, tags: ['live']);

    test('prod URL — fetches and parses real config', () async {
      final client = makeClient();
      addTearDown(client.dispose);

      await client.fetchSettings(_prodUrl);

      expect(client.status, const cc.CaxiloConfigStatus.loaded());
      final cfg = client.config!;
      expect(cfg.version, 2);
      expect(cfg.inHouse.catalog.length, greaterThanOrEqualTo(1));
      expect(cfg.categories.length, greaterThanOrEqualTo(1));
      expect(cfg.external.providerConfigs.keys, containsAll(['amb-vn', 'vivo', 'lcevo']));
    }, tags: ['live']);
  });
}
