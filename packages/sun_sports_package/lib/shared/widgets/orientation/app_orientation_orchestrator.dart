import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

import 'app_orientation_provider.dart';

/// A shared widget that provides the global orientation context
/// for the entire application.
class AppOrientationOrchestrator extends ConsumerWidget {
  /// Creates an [AppOrientationOrchestrator].
  const AppOrientationOrchestrator({required this.child, super.key});

  /// The widget subtree (e.g. [MaterialApp]).
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(orientationControllerProvider);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isMobile = shortestSide < 600.0;
    final targets = isMobile
        ? DeviceOrientations.portrait
        : DeviceOrientations.both;

    // final blockOnMismatch = kIsWeb && isMobile;
    final blockOnMismatch = kIsWeb;

    return OrientationScope.root(
      controller: controller,
      // DO NOT block at root to allow smooth transitions.
      blockOnMismatch: blockOnMismatch,
      defaultPolicy: OrientationPolicy(
        targets: targets,
        // blockOnMismatch: true,
        blockOnMismatch: blockOnMismatch,
        debugLabel: isMobile ? 'AppDefaultPortrait' : 'AppDefaultBoth',
      ),
      config: orientationGuardConfig,
      child: child,
    );
  }
}
