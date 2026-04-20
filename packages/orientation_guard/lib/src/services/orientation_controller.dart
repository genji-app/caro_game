import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';

/// The core orchestration boundary for screen presentation logic.
/// Handles resolution, apply phase, mismatch checking, and clean restore.
abstract class OrientationController {
  /// Request the platform and UI layer to satisfy the given [policy].
  /// Returns a state object describing whether the device/viewport
  /// currently satisfies the target.
  Future<OrientationViewState> apply(OrientationPolicy policy);

  /// Return the app to default presentation behavior.
  Future<void> restore();

  /// Determine if the given [policy] matches the current UI layout orientation.
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  });
}
