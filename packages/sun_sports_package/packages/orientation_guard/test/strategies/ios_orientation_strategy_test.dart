import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/orientation_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late IosOrientationStrategy strategy;

  setUp(() {
    strategy = const IosOrientationStrategy();
  });

  group('IosOrientationStrategy', () {
    test('apply returns matched result and uses workarounds', () async {
      final policy = OrientationPolicy.portrait;
      final result = await strategy.apply(policy);

      expect(result.status, OrientationResultStatus.matched);
      expect(result.policy, policy);
    });

    test('restore(policy) calls apply with policy', () async {
      final policy = OrientationPolicy.landscape;
      final result = await strategy.restore(policy);

      expect(result.status, OrientationResultStatus.matched);
      expect(result.policy, policy);
    });

    test('isMatched works correctly', () {
      const portraitPolicy = OrientationPolicy.portrait;
      
      expect(
        strategy.isMatched(
          policy: portraitPolicy,
          currentOrientation: Orientation.portrait,
        ),
        true,
      );
    });
  });
}
