import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/orientation_guard.dart';

void main() {
  group('OrientationStrategyResolver', () {
    test('resolves WebNoopStrategy for Web', () {
      final context = OrientationRuntimeContext(
        platform: TargetPlatform.android,
        isWeb: true,
      );
      const resolver = OrientationStrategyResolver();
      final strategy = resolver.resolve(context);

      expect(strategy, isA<WebNoopStrategy>());
    });

    test('resolves IosOrientationStrategy for iOS Native', () {
      final context = OrientationRuntimeContext(
        platform: TargetPlatform.iOS,
        isWeb: false,
      );
      const resolver = OrientationStrategyResolver();
      final strategy = resolver.resolve(context);

      expect(strategy, isA<IosOrientationStrategy>());
    });

    test('resolves DirectApplyStrategy for Android Native', () {
      final context = OrientationRuntimeContext(
        platform: TargetPlatform.android,
        isWeb: false,
      );
      const resolver = OrientationStrategyResolver();
      final strategy = resolver.resolve(context);

      expect(strategy, isA<DirectApplyStrategy>());
    });

    test('resolves strategyOverride if provided', () {
      final context = OrientationRuntimeContext(
        platform: TargetPlatform.android,
        isWeb: false,
      );
      const override = WebNoopStrategy();
      final resolver = OrientationStrategyResolver(strategyOverride: override);
      final strategy = resolver.resolve(context);

      expect(strategy, override);
    });
  });
}
