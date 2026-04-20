import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';

/// The native implementation of [OrientationController] for Mobile.
/// Uses [SystemChrome] to force physical device orientation.
class NativeOrientationController implements OrientationController {
  /// Creates a new [NativeOrientationController].
  const NativeOrientationController();

  static const _defaultSystemUiMode = SystemUiMode.edgeToEdge;
  static const _defaultSystemUiOverlays = SystemUiOverlay.values;

  @override
  Future<OrientationViewState> apply(OrientationPolicy policy) async {
    debugPrint('Native applies policy: ${policy.targets.map((t) => t.name).join(', ')}');

    try {
      if (policy.screenUi.immersive) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        await SystemChrome.setEnabledSystemUIMode(_defaultSystemUiMode);
      }

      final requested = policy.targets;

      if (requested.isEmpty) {
        requested.addAll(DeviceOrientation.values);
      }

      await SystemChrome.setPreferredOrientations(requested);

      return OrientationViewState(
        policy: policy,
        status: OrientationStatus.matched,
        matched: true,
        canControlPlatform: true,
      );
    } catch (e, stack) {
      debugPrint('Failed to apply native orientation: $e\n$stack');
      return OrientationViewState(
        policy: policy,
        status: OrientationStatus.mismatched,
        matched: false,
        canControlPlatform: true,
      );
    }
  }

  @override
  Future<void> restore() async {
    debugPrint('Restoring default native capabilities');

    try {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      await SystemChrome.setEnabledSystemUIMode(
        _defaultSystemUiMode,
        overlays: _defaultSystemUiOverlays,
      );
    } catch (e, stack) {
      debugPrint('Failed to restore native orientation: $e\n$stack');
    }
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    return policy.targets.any((target) {
      if (target.isPortrait) {
        return currentOrientation == Orientation.portrait;
      }
      if (target.isLandscape) {
        return currentOrientation == Orientation.landscape;
      }
      return false;
    });
  }
}
