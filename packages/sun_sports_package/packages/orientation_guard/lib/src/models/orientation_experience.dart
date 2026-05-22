import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'orientation_guard_config.dart';

/// Defines the type of user experience based on the device's physical
/// characteristics and screen size.
enum OrientationExperience {
  /// Handheld mobile devices (Phones).
  mobile,

  /// Standard tablets (iPad, Android tablets).
  tablet,

  /// Large tablets or foldable devices in large screen mode.
  largeTablet,

  /// Desktop browsers or laptops.
  desktop;

  /// Whether this device category typically supports physical rotation.
  bool get canRotate => this != desktop;

  /// Whether the orientation is primarily controlled via window resize
  /// rather than physical sensor rotation.
  bool get usesResize => !canRotate;
}

/// A classifier that categorizes the [OrientationExperience] based on
/// the screen's shortest side dimension.
class OrientationExperienceClassifier {
  /// Creates an [OrientationExperienceClassifier].
  const OrientationExperienceClassifier({
    this.mobileBreakpoint = 600.0,
    this.tabletBreakpoint = 1000.0,
    this.desktopBreakpoint = 1300.0,
  });

  /// The standard classifier instance.
  static const standard = OrientationExperienceClassifier();

  /// Shortest side below this value is considered [OrientationExperience.mobile].
  final double mobileBreakpoint;

  /// Shortest side below this value is considered [OrientationExperience.tablet].
  final double tabletBreakpoint;

  /// Shortest side below this value is considered [OrientationExperience.largeTablet].
  final double desktopBreakpoint;

  /// Classifies the experience based on the provided [BuildContext] and [config].
  OrientationExperience classify(BuildContext context, [OrientationGuardConfig? config]) {
    final override = config?.systemType ?? OrientationSystemType.auto;
    if (override != OrientationSystemType.auto) {
      switch (override) {
        case OrientationSystemType.mobile:
          return OrientationExperience.mobile;
        case OrientationSystemType.tablet:
          return OrientationExperience.tablet;
        case OrientationSystemType.desktop:
          return OrientationExperience.desktop;
        default:
          break;
      }
    }

    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return classifyFromSize(shortestSide);
  }

  /// Classifies the experience based on a raw [shortestSide] value.
  OrientationExperience classifyFromSize(double shortestSide) {
    if (shortestSide < mobileBreakpoint) {
      return OrientationExperience.mobile;
    }
    if (shortestSide < tabletBreakpoint) {
      return OrientationExperience.tablet;
    }
    if (shortestSide < desktopBreakpoint) {
      return OrientationExperience.largeTablet;
    }
    return OrientationExperience.desktop;
  }
}

/// Whether the current platform is a desktop web browser.
///
/// Returns true only when running on Web AND the OS is not mobile (iOS/Android).
/// This distinguishes "Desktop Browser resized to small" from an actual "Mobile Browser".
bool isDesktopWebPlatform([OrientationGuardConfig? config]) {
  final override = config?.systemType ?? OrientationSystemType.auto;
  if (override != OrientationSystemType.auto) {
    return override == OrientationSystemType.desktop;
  }

  // On Web, defaultTargetPlatform reflects the underlying OS (macOS, Windows, etc.)
  // regardless of the viewport size or User Agent string emulation in DevTools.
  // On Native, it also correctly identifies desktop operating systems.
  return defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android;
}
