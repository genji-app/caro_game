import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';

/// Interface for orientation application strategies.
///
/// Each platform (iOS, Android, Web) implements its own strategy to handle
/// the nuances of orientation locking and restoration.
abstract class OrientationStrategy {
  /// Applies the given [policy] to the platform.
  Future<OrientationApplyResult> apply(OrientationPolicy policy);

  /// Restores the platform orientation.
  ///
  /// If [previousPolicy] is provided, it attempts to restore to that policy.
  /// If `null`, it usually unlocks all orientations.
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]);

  /// Checks if the [currentOrientation] satisfies the [policy] targets.
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  });
}
