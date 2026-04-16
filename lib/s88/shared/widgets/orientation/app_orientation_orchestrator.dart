import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

/// Provides the platform-specific implementation of [OrientationController].
final _orientationControllerProvider = Provider<OrientationController>((ref) {
  if (kIsWeb) {
    return const WebOrientationController();
  } else {
    return const NativeOrientationController();
  }
});

/// A shared widget that provides the global orientation context
/// for the entire application.
class AppOrientationOrchestrator extends ConsumerWidget {
  /// Creates an [AppOrientationOrchestrator].
  const AppOrientationOrchestrator({
    required this.child,
    this.defaultPolicy,
    super.key,
  });

  /// The widget subtree (e.g. [MaterialApp]).
  final Widget child;

  /// The default orientation policy when no overrides are active.
  /// If not provided, it will be automatically determined based on screen size:
  /// - Mobile (< 600): Portrait
  /// - Tablet/Desktop (>= 600): Both
  final OrientationPolicy? defaultPolicy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_orientationControllerProvider);

    final effectivePolicy =
        defaultPolicy ?? const OrientationAdaptiveResolver().resolve(context);

    return GlobalOrientationOrchestrator(
      controller: controller,
      defaultPolicy: effectivePolicy,
      child: child,
    );
  }
}
