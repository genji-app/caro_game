import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';
import 'orientation_strategy.dart';

/// Strategy with iOS-specific workarounds for orientation control.
///
/// Reference: iOS 16+ has strict view controller mask rules.
/// We frequently need to 'flush' the mask by allowing all orientations
/// briefly before applying the final target.
class IosOrientationStrategy implements OrientationStrategy {
  /// Creates an [IosOrientationStrategy].
  const IosOrientationStrategy();

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    try {
      final targets = policy.targets.isEmpty ? DeviceOrientation.values : policy.targets;

      // WORKAROUND 1 (Flush Mask): Briefly allow all orientations.
      // This ensures the iOS view controller's mask doesn't block the next request.
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // WORKAROUND 2 (Lock Break): If moving to portrait, force it explicitly.
      // Helps break rotation locks left by landscape immersive sessions.
      final isTransitioningToPortrait = targets.contains(DeviceOrientation.portraitUp) &&
          !targets.contains(DeviceOrientation.landscapeLeft);

      if (isTransitioningToPortrait) {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      // Final Apply
      await SystemChrome.setPreferredOrientations(targets);

      return OrientationApplyResult.matched(policy);
    } catch (e) {
      return OrientationApplyResult(
        status: OrientationResultStatus.failed,
        policy: policy,
        canControlPlatform: true,
        message: e.toString(),
      );
    }
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    // We use apply() even for restore because iOS needs the workarounds
    // every time we change orientations.
    if (previousPolicy != null) {
      return apply(previousPolicy);
    }

    final allOrientations = OrientationPolicy(
      targets: DeviceOrientation.values,
      debugLabel: 'Restore All',
    );
    return apply(allOrientations);
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    if (policy.targets.isEmpty) return true;

    if (currentOrientation == Orientation.portrait) {
      return policy.allowsPortrait;
    } else {
      return policy.allowsLandscape;
    }
  }
}
