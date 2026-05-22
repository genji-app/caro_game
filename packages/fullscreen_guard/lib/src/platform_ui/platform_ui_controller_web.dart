import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';

/// {@template platform_ui_controller_web}
/// Web implementation of [PlatformUiController].
///
/// Note: Standard Web browsers do not allow programmatic control over
/// system status/navigation bar colors via Flutter's `SystemChrome`.
/// Fullscreen management is handled by the `FullscreenStrategy` layer.
/// {@endtemplate}
class PlatformUiControllerWeb implements PlatformUiController {
  /// {@macro platform_ui_controller_web}
  PlatformUiControllerWeb();

  PlatformUiConfig? _currentConfig;

  @override
  PlatformUiConfig? get currentConfig => _currentConfig;

  @override
  Future<void> apply(PlatformUiConfig config) async {
    _currentConfig = config;
  }

  @override
  Future<void> restore() async {
    _currentConfig = null;
  }

  @override
  void dispose() {}
}

/// Factory function that creates a web platform UI controller.
PlatformUiController createPlatformUiController() => PlatformUiControllerWeb();
