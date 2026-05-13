import 'platform_ui_config.dart';

/// {@template platform_ui_controller}
/// Abstract interface for platform-specific system UI control.
///
/// Manages system chrome (status bar, navigation bar) across different
/// platforms.
///
/// Note: Fullscreen management is handled by the `FullscreenStrategy` layer
/// within the `fullscreen_gate` module.
/// {@endtemplate}
abstract class PlatformUiController {
  /// The configuration currently applied to the platform.
  ///
  /// `null` if no configuration has been applied yet or if the controller
  /// has been restored.
  PlatformUiConfig? get currentConfig;

  /// Applies a [PlatformUiConfig] to the platform.
  ///
  /// On native platforms, this interacts with `SystemChrome`. On Web, this is
  /// typically a no-op for system chrome but may store the config for state
  /// tracking.
  Future<void> apply(PlatformUiConfig config);

  /// Restores the platform UI to [PlatformUiConfig.systemDefault].
  Future<void> restore();

  /// Releases resources and listeners.
  void dispose();
}
