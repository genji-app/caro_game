import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

/// A stack-based manager for application-level orientation policies.
class AppOrientationNotifier extends StateNotifier<List<OrientationPolicy>> {
  /// Creates an [AppOrientationNotifier].
  AppOrientationNotifier({required this.ref}) : super([]);

  /// The Riverpod Ref to access other providers.
  final Ref ref;

  /// Pushes a new [policy] onto the stack.
  void pushPolicy(OrientationPolicy policy) {
    if (state.isNotEmpty && state.last == policy) return;

    // ignore: avoid_print
    print('AppOrientationNotifier: PUSHING policy ${policy.debugLabel}');
    state = [...state, policy];
    _applyActive();
  }

  /// Removes the [policy] from the stack.
  void popPolicy(OrientationPolicy policy) {
    final index = state.lastIndexOf(policy);
    if (index != -1) {
      // ignore: avoid_print
      print('AppOrientationNotifier: POPPING policy ${policy.debugLabel}');
      state = List<OrientationPolicy>.from(state)..removeAt(index);
      _applyActive();
    }
  }

  void _applyActive() {
    // If the stack is empty, default to Portrait.
    final policy = state.isEmpty
        ? const OrientationPolicy(
            targets: DeviceOrientations.portrait,
            debugLabel: 'FallbackPortraitUp',
          )
        : state.last;

    // 1. Apply Orientation Policy via Controller
    ref.read(_orientationControllerProvider).apply(policy);

    // // 2. Orchestrate System UI side effects (Immersive mode)
    // // On web, FullscreenGuard handles fullscreen via the gate overlay.
    // // On native, orientation provider manages immersive mode directly.
    // if (!kIsWeb) {
    //   final config = policy.screenUi.immersive
    //       ? PlatformUiConfig.immersive(
    //           debugLabel: 'Policy: ${policy.debugLabel}',
    //         )
    //       : PlatformUiConfig.branded(
    //           debugLabel: 'Policy: ${policy.debugLabel}',
    //         );
    //   ref.read(platformUiControllerProvider).apply(config);
    // }
  }

  /// The active policy currently at the top of the stack.
  OrientationPolicy? get activePolicy => state.isNotEmpty ? state.last : null;
}

/// The hardware-level controller provider.
final _orientationControllerProvider = Provider<OrientationController>((ref) {
  return createOrientationController();
});

/// The global provider for the orientation policy stack.
final appOrientationNotifierProvider =
    StateNotifierProvider<AppOrientationNotifier, List<OrientationPolicy>>((
      ref,
    ) {
      return AppOrientationNotifier(ref: ref);
    });

/// Provider for the currently active [OrientationPolicy].
final activeOrientationPolicyProvider = Provider<OrientationPolicy?>((ref) {
  final stack = ref.watch(appOrientationNotifierProvider);
  return stack.isNotEmpty ? stack.last : null;
});

/// A declarative provider that manages the lifecycle of an [OrientationPolicy].
final appOrientationLifecycleProvider = Provider.autoDispose
    .family<void, OrientationPolicy>((ref, policy) {
      final notifier = ref.read(appOrientationNotifierProvider.notifier);

      // Use microtask to avoid "modify other providers during initialization"
      Future.microtask(() {
        notifier.pushPolicy(policy);
      });

      ref.onDispose(() {
        notifier.popPolicy(policy);
      });
    });
