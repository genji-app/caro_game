import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_policy_resolver.dart';

/// A standard resolver that handles common mobile/tablet/desktop breakpoints.
class OrientationAdaptiveResolver extends OrientationPolicyResolver<void> {
  /// Creates a new [OrientationAdaptiveResolver].
  const OrientationAdaptiveResolver();

  /// Mobile breakpoint (up to 599).
  static const double mobileBreakpoint = 600.0;

  /// Desktop breakpoint (900 and above).
  static const double desktopBreakpoint = 900.0;

  /// Resolves the effective [OrientationPolicy] based on screen dimensions.
  ///
  /// Logic:
  /// - Mobile (< 600): Portrait
  /// - Tablet (600 - 899): Both
  /// - Desktop (>= 900): Both
  @override
  OrientationPolicy resolve(BuildContext context, [void input]) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isMobile = shortestSide < mobileBreakpoint;

    return OrientationPolicy(
      targets: isMobile ? DeviceOrientations.portrait : DeviceOrientations.both,
      debugLabel: isMobile ? 'AdaptiveDefaultPortrait' : 'AdaptiveDefaultBoth',
    );
  }
}
