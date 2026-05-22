import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_experience.dart';
import '../models/orientation_guard_config.dart';
import '../models/orientation_policy.dart';
import 'orientation_strategy.dart';

/// Strategy for Web (and other non-lockable platforms).
///
/// Web browsers generally do not allow web apps to force physical device
/// orientation for security and UX reasons. This strategy acts as a No-Op
/// but still provides mismatch detection.
class WebNoopStrategy implements OrientationStrategy {
  /// Creates a [WebNoopStrategy].
  const WebNoopStrategy({
    this.config = const OrientationGuardConfig(),
  });

  /// The global configuration for the guard.
  final OrientationGuardConfig config;

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    // We can't lock orientation on Web, but we report it's unsupported.
    return OrientationApplyResult.unsupported(
      policy,
      message: 'Orientation locking is not supported on Web.',
    );
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    return OrientationApplyResult.unsupported(
      previousPolicy ?? const OrientationPolicy(targets: []),
      message: 'Orientation restoration is not supported on Web.',
    );
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    final isDesktop = isDesktopWebPlatform(config);

    // Desktop web: skip mismatch check unless forceEnforcement is enabled.
    // This prevents rotation overlays from appearing on desktop browsers
    // when the window is resized to a small size.
    final skipDesktop =
        isDesktop && policy.ignoreMismatchOnDesktop && !config.forceEnforcementOnDesktopWeb;

    debugPrint(
      '[WebNoopStrategy] isMatched: ${policy.debugLabel ?? 'unnamed'}, '
      'orientation: $currentOrientation, '
      'isDesktop: $isDesktop, '
      'forceEnforcement: ${config.forceEnforcementOnDesktopWeb}, '
      'skipDesktop: $skipDesktop',
    );

    if (skipDesktop) {
      return true;
    }

    // Matching is still possible via viewport aspect ratio / Orientation media query.
    final result = policy.targets.any((target) {
      if (target.isPortrait) {
        return currentOrientation == Orientation.portrait;
      }
      if (target.isLandscape) {
        return currentOrientation == Orientation.landscape;
      }
      return false;
    });

    debugPrint('[WebNoopStrategy] result: $result for policy: ${policy.debugLabel}');
    return result;
  }
}
