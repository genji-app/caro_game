import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';

/// {@template platform_ui_controller_stub}
/// Stub implementation of [PlatformUiController] for unsupported platforms.
/// {@endtemplate}
class PlatformUiControllerStub implements PlatformUiController {
  /// {@macro platform_ui_controller_stub}
  PlatformUiControllerStub();

  @override
  PlatformUiConfig? get currentConfig => null;

  @override
  Future<void> apply(PlatformUiConfig config) async {
    throw UnsupportedError(
      'fullscreen_guard is not supported on this platform',
    );
  }

  @override
  Future<void> restore() async {
    throw UnsupportedError(
      'fullscreen_guard is not supported on this platform',
    );
  }

  @override
  void dispose() {}
}

/// Factory function that creates the appropriate [PlatformUiController].
PlatformUiController createPlatformUiController() => PlatformUiControllerStub();
