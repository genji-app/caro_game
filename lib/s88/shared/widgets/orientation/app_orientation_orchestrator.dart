import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:co_caro_flame/s88/shared/widgets/orientation/app_orientation_provider.dart';

/// Provides the platform-specific implementation of [OrientationController].
final _orientationControllerProvider = Provider<OrientationController>((ref) {
  return createOrientationController();
});

/// A shared widget that provides the global orientation context
/// for the entire application.
class AppOrientationOrchestrator extends ConsumerWidget {
  /// Creates an [AppOrientationOrchestrator].
  const AppOrientationOrchestrator({required this.child, super.key});

  /// The widget subtree (e.g. [MaterialApp]).
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_orientationControllerProvider);
    final activePolicy = ref.watch(activeOrientationPolicyProvider);

    // Fall back to adaptive resolver if no explicit override is in the stack.
    final OrientationPolicy effectivePolicy =
        activePolicy ?? const OrientationAdaptiveResolver().resolve(context);

    return GlobalOrientationOrchestrator(
      // key: ValueKey(
      //   'orient-${effectivePolicy.debugLabel}-${effectivePolicy.targets.join()}',
      // ),
      controller: controller,
      defaultPolicy: effectivePolicy,
      child: child,
    );
  }
}
