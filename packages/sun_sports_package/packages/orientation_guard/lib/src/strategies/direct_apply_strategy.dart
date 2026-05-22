import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';
import 'orientation_strategy.dart';

/// Strategy that directly applies orientation preferences via [SystemChrome].
///
/// Used on Android and as a generic fallback.
class DirectApplyStrategy implements OrientationStrategy {
  /// Creates a [DirectApplyStrategy].
  const DirectApplyStrategy();

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    try {
      final targets = policy.targets.isEmpty ? DeviceOrientation.values : policy.targets;
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
    if (previousPolicy != null) {
      // Small delay to ensure route transitions are handled
      await Future.delayed(const Duration(milliseconds: 50));
      return apply(previousPolicy);
    }

    try {
      await Future.delayed(const Duration(milliseconds: 50));
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      return OrientationApplyResult(
        status: OrientationResultStatus.matched,
        policy: const OrientationPolicy(targets: DeviceOrientation.values),
        canControlPlatform: true,
      );
    } catch (e) {
      return OrientationApplyResult(
        status: OrientationResultStatus.failed,
        policy: const OrientationPolicy(targets: DeviceOrientation.values),
        canControlPlatform: true,
        message: e.toString(),
      );
    }
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
