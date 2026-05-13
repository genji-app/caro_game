import 'package:caxilo_config/caxilo_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaxiloConfigPresets', () {
    test('buildSettings(dev) should return a valid config map', () {
      final configMap = CaxiloConfigPresets.buildSettings(CaxiloEnvironment.dev);

      expect(configMap, isA<Map<String, dynamic>>());
      expect(configMap['version'], isA<int>());
      expect(configMap['environments'], isNotNull);
      expect(configMap['in_house'], isNotNull);
      expect(configMap['external'], isNotNull);
      expect(configMap['categories'], isA<List>());
    });

    test('buildSettings(staging) should return a valid config map', () {
      final configMap = CaxiloConfigPresets.buildSettings(CaxiloEnvironment.staging);
      expect(configMap, isA<Map<String, dynamic>>());
    });

    test('buildSettings(prod) should return a valid config map', () {
      final configMap = CaxiloConfigPresets.buildSettings(CaxiloEnvironment.prod);
      expect(configMap, isA<Map<String, dynamic>>());
    });

    test('CaxiloConfig should be able to parse fallback data', () {
      final configMap = CaxiloConfigPresets.buildSettings(CaxiloEnvironment.dev);
      final settings = CaxiloConfig.fromJson(configMap);

      expect(settings.version, isNotNull);
      expect(settings.categories, isNotEmpty);
      expect(settings.inHouse.catalog, isNotEmpty);
      expect(settings.external.isSupported('lcevo', 'roulette'), isTrue);
    });

    test('CaxiloEnvironment enum should have all expected values', () {
      expect(CaxiloEnvironment.values.length, 3);
      expect(CaxiloEnvironment.values, contains(CaxiloEnvironment.dev));
      expect(CaxiloEnvironment.values, contains(CaxiloEnvironment.staging));
      expect(CaxiloEnvironment.values, contains(CaxiloEnvironment.prod));
    });
  });
}
