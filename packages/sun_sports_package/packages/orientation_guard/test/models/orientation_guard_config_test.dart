import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/src/models/orientation_guard_config.dart';

void main() {
  group('OrientationGuardConfig', () {
    test('production preset has forceEnforcement disabled', () {
      const config = OrientationGuardConfig.production;
      expect(config.forceEnforcementOnDesktopWeb, isFalse);
    });

    test('devTesting preset has forceEnforcement enabled', () {
      const config = OrientationGuardConfig.devTesting;
      expect(config.forceEnforcementOnDesktopWeb, isTrue);
    });

    test('equality works correctly', () {
      const config1 = OrientationGuardConfig(forceEnforcementOnDesktopWeb: true);
      const config2 = OrientationGuardConfig(forceEnforcementOnDesktopWeb: true);
      const config3 = OrientationGuardConfig(forceEnforcementOnDesktopWeb: false);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
      expect(config1.hashCode, equals(config2.hashCode));
    });
  });
}
