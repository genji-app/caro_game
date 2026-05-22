import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';

/// The public interface for managing screen orientation.
///
/// Applications should interact with this interface rather than
/// platform-specific implementations.
abstract class OrientationController implements Listenable {
  /// Applies the given [policy] to the platform.
  Future<OrientationApplyResult> apply(OrientationPolicy policy);

  /// Restores the orientation to a previous state.
  ///
  /// If [previousPolicy] is provided, it attempts to re-apply that policy.
  /// If `null`, it usually unlocks the device to all orientations.
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]);

  /// Checks if the [currentOrientation] satisfies the [policy] requirements.
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  });

  /// The policy that was most recently applied via this controller.
  OrientationPolicy? get activePolicy;

  /// Whether an orientation change is currently being applied to the platform.
  ///
  /// UI components can use this to suppress flicker or mismatch warnings
  /// during the transition period.
  bool get isApplying;
}
