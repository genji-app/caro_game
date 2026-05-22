import 'package:flutter/services.dart';

import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';

/// {@template platform_ui_controller_native}
/// Native (Android / iOS) implementation of [PlatformUiController].
///
/// Uses `SystemChrome` to manage system bar visibility and styling.
/// {@endtemplate}
class PlatformUiControllerNative implements PlatformUiController {
  /// {@macro platform_ui_controller_native}
  PlatformUiControllerNative();

  PlatformUiConfig? _currentConfig;

  @override
  PlatformUiConfig? get currentConfig => _currentConfig;

  @override
  Future<void> apply(PlatformUiConfig config) async {
    try {
      // 1. Apply system UI mode (visibility) FIRST
      if (config.systemUiMode != null) {
        final mode = _mapMode(config.systemUiMode!);
        if (mode == SystemUiMode.manual) {
          // Hide all bars (e.g. Splash)
          await SystemChrome.setEnabledSystemUIMode(mode, overlays: []);
        } else if (mode == SystemUiMode.edgeToEdge) {
          // Force all bars to be visible when returning from hidden state.
          // Using manual mode with all overlays is often more reliable on Android.
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        } else {
          await SystemChrome.setEnabledSystemUIMode(mode);
        }
      }

      // 2. Apply overlay style (colors/brightness) SECOND
      if (config.hasOverlayStyle) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: config.statusBarColor,
            statusBarIconBrightness: config.statusBarIconBrightness,
            statusBarBrightness: config.statusBarBrightness,
            systemNavigationBarColor: config.navigationBarColor,
            systemNavigationBarIconBrightness: config.navigationBarIconBrightness,
          ),
        );
      }

      _currentConfig = config;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> restore() async {
    // Reset to deterministic system defaults
    await apply(const PlatformUiConfig.systemDefault());
    _currentConfig = null;
  }

  @override
  void dispose() {}

  SystemUiMode _mapMode(PlatformSystemUiMode mode) => switch (mode) {
        PlatformSystemUiMode.edgeToEdge => SystemUiMode.edgeToEdge,
        PlatformSystemUiMode.immersive => SystemUiMode.immersive,
        PlatformSystemUiMode.manual => SystemUiMode.manual,
      };
}

/// Factory function that creates a native platform UI controller.
PlatformUiController createPlatformUiController() => PlatformUiControllerNative();
