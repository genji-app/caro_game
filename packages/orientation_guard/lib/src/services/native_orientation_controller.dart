import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';

/// The native implementation of [OrientationController] for Mobile.
/// Uses [SystemChrome] to force physical device orientation.
class NativeOrientationController implements OrientationController {
  /// Creates a new [NativeOrientationController].
  const NativeOrientationController();

  @override
  Future<OrientationViewState> apply(OrientationPolicy policy) async {
    debugPrint('Native applies policy: ${policy.targets.map((t) => t.name).join(', ')}');

    try {
      final requested = policy.targets.isEmpty ? DeviceOrientation.values : policy.targets;

      // WORKAROUND (iOS Error 101): On iOS 16+, requesting a specific orientation
      // (like landscape) while the view controller's mask is restricted can fail.
      // We 'flush' the mask by briefly allowing all orientations before applying the target.
      final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
      if (isIos) {
        await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      // SECONDARY WORKAROUND: Forcing a single specific portrait orientation
      // if we are returning to portrait, helping to break stubborn sensor locks.
      // This is primarily for iOS where sensor locks are common after immersive sessions.
      final needsLockBreak = isIos &&
          requested.contains(DeviceOrientation.portraitUp) &&
          !requested.contains(DeviceOrientation.landscapeLeft);

      if (needsLockBreak) {
        debugPrint('Forcing temporary PortraitUp (iOS only) to break rotation lock...');
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      debugPrint('Finalizing native orientation: ${requested.join(', ')}');
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

/// Provides the native implementation of [OrientationController].
OrientationController getPlatformController() => const NativeOrientationController();
