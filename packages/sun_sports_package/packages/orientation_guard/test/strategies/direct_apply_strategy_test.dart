import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/orientation_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DirectApplyStrategy strategy;

  setUp(() {
    strategy = const DirectApplyStrategy();
  });

  group('DirectApplyStrategy', () {
    test('apply returns matched result', () async {
      final policy = OrientationPolicy.portrait;
      final result = await strategy.apply(policy);

      expect(result.status, OrientationResultStatus.matched);
      expect(result.policy, policy);
      expect(result.canControlPlatform, true);
    });

    test('restore(policy) returns matched result', () async {
      final policy = OrientationPolicy.landscape;
      final result = await strategy.restore(policy);

      expect(result.status, OrientationResultStatus.matched);
      expect(result.policy, policy);
    });

    test('restore(null) returns matched result with all orientations', () async {
      final result = await strategy.restore(null);

      expect(result.status, OrientationResultStatus.matched);
      expect(result.policy.targets, unorderedEquals(DeviceOrientation.values));
    });

    test('isMatched returns true when orientation matches policy', () {
      const portraitPolicy = OrientationPolicy.portrait;
      
      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.portrait,
        ),
        true,
      );

      const landscapePolicy = OrientationPolicy.landscape;
      expect(
        strategy.isMatched(
          policy: landscapePolicy,
          currentOrientation: Orientation.landscape,
        ),
        true,
      );
    });

    test('isMatched returns false when orientation mismatches policy', () {
      const portraitPolicy = OrientationPolicy.portrait;
      
      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.landscape,
        ),
        false,
      );

      const landscapePolicy = OrientationPolicy.landscape;
      expect(
        strategy.isMatched(
          policy: landscapePolicy,
          currentOrientation: Orientation.portrait,
        ),
        false,
      );
    });
  });
}
