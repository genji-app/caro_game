import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

/// Global configuration for orientation enforcement.
const orientationGuardConfig = OrientationGuardConfig(
  // use true for debug mode to test orientation enforcement on desktop web
  // forceEnforcementOnDesktopWeb: true,
  forceEnforcementOnDesktopWeb: false,
);

/// The hardware-level controller provider.
final orientationControllerProvider = Provider<OrientationController>((ref) {
  return createOrientationControllerV1(config: orientationGuardConfig);
});
