import 'package:flutter/widgets.dart';

import '../models/orientation_policy.dart';
import 'orientation_policy_resolver.dart';

/// A standard resolver that handles common mobile/tablet/desktop breakpoints.
class OrientationAdaptiveResolver extends OrientationPolicyResolver<void> {
  /// Creates a new [OrientationAdaptiveResolver].
  const OrientationAdaptiveResolver();

  /// Mobile breakpoint (up to 599).
  static const double mobileBreakpoint = 600.0;

  /// Desktop breakpoint (900 and above).
  static const double desktopBreakpoint = 900.0;

  /// Standard portrait policy for mobile.
  static const mobilePortrait = OrientationPolicy(
    targets: DeviceOrientations.portrait,
    blockOnMismatch: true,
    debugLabel: 'AdaptiveDefaultPortrait',
  );

  /// Standard "both" policy for tablets and desktops.
  static const both = OrientationPolicy(
    targets: DeviceOrientations.both,
    blockOnMismatch: false,
    debugLabel: 'AdaptiveDefaultBoth',
  );

  /// Fallback policy when MediaQuery is unavailable.
  static const fallback = OrientationPolicy(
    targets: DeviceOrientations.both,
    blockOnMismatch: false,
    debugLabel: 'AdaptiveFallback',
  );

  /// Resolves the effective [OrientationPolicy] based on screen dimensions.
  ///
  /// Logic:
  /// - Mobile (< 600): Portrait
  /// - Tablet (600 - 899): Both
  /// - Desktop (>= 900): Both
  @override
  OrientationPolicy resolve(BuildContext context, [void input]) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return fallback;
    }

    final shortestSide = mediaQuery.size.shortestSide;
    final isMobile = shortestSide < mobileBreakpoint;

    return isMobile ? mobilePortrait : both;
  }
}
