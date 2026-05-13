import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';

/// Riverpod bridge: single shared [PlatformUiController] instance.
///
/// Provides the same controller to both:
/// - [FullscreenGuard] widget (injected via `platformUiController` param)
/// - [AppOrientationNotifier] (accessed via `ref.read`)
///
/// This ensures native immersive mode and the fullscreen gate operate on
/// the same underlying platform object — no double-listeners or
/// conflicting state.
///
/// Note: Initial configuration is now managed by the [PlatformUiGuard] widget
/// to allow for declarative system UI control in the widget tree.
final platformUiControllerProvider = Provider<PlatformUiController>((ref) {
  final controller = createPlatformUiController();
  ref.onDispose(controller.dispose);
  return controller;
});
