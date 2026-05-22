import 'package:flutter/foundation.dart';

import '../models/orientation_guard_config.dart';
import '../models/orientation_runtime_context.dart';
import 'direct_apply_strategy.dart';
import 'ios_orientation_strategy.dart';
import 'orientation_strategy.dart';
import 'web_noop_strategy.dart';

/// Resolves the appropriate [OrientationStrategy] for the current environment.
class OrientationStrategyResolver {
  /// Creates a new [OrientationStrategyResolver].
  const OrientationStrategyResolver({this.strategyOverride});

  /// Optional override for testing or custom requirements.
  final OrientationStrategy? strategyOverride;

  /// Returns the strategy to use for the given [context].
  OrientationStrategy resolve(
    OrientationRuntimeContext context, {
    OrientationGuardConfig config = const OrientationGuardConfig(),
  }) {
    if (strategyOverride != null) return strategyOverride!;

    if (context.isWeb) {
      return WebNoopStrategy(config: config);
    }

    switch (context.platform) {
      case TargetPlatform.iOS:
        return const IosOrientationStrategy();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const DirectApplyStrategy();
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        // Desktop platforms usually don't support orientation locking.
        return WebNoopStrategy(config: config);
    }
  }
}
