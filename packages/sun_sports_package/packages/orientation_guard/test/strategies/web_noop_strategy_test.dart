import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/orientation_guard.dart';

void main() {
  late WebNoopStrategy strategy;

  setUp(() {
    strategy = const WebNoopStrategy();
  });

  group('WebNoopStrategy', () {
    test('apply returns unsupported result', () async {
      final policy = OrientationPolicy.portrait;
      final result = await strategy.apply(policy);

      expect(result.status, OrientationResultStatus.unsupported);
      expect(result.canControlPlatform, false);
    });

    test('restore returns unsupported result', () async {
      final result = await strategy.restore();
      expect(result.status, OrientationResultStatus.unsupported);
    });

    test('isMatched works based on viewport orientation for mobile web', () {
      // iOS = mobile web
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const portraitPolicy = OrientationPolicy.portrait;

      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.portrait,
        ),
        true,
      );

      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.landscape,
        ),
        false,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    test('isMatched ignores mismatch on Desktop platforms by default', () {
      // macOS = desktop web
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      const portraitPolicy = OrientationPolicy.portrait;

      // Even if orientation is landscape, it should return TRUE on desktop
      // (assuming ignoreMismatchOnDesktop is true in policy, which is default)
      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.landscape,
        ),
        true,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    test('isMatched ENFORCES mismatch on Desktop when flag is set', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      const strategy = WebNoopStrategy(
        config: OrientationGuardConfig(forceEnforcementOnDesktopWeb: true),
      );
      const portraitPolicy = OrientationPolicy.portrait;

      // Should return FALSE because orientation is landscape and flag is true
      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.landscape,
        ),
        false,
      );
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
