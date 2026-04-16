import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

class SystemUiService with LoggerMixin {
  @override
  String get logTag => 'SystemUiService';

  static const defaultOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // White icons/text
    statusBarBrightness: Brightness.dark, // For iOS
  );

  static const splashOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Color(0xFF11100F), // Match splash screen background
    systemNavigationBarColor: Color(0xFF11100F),
  );

  static const defaultSystemUiMode = SystemUiMode.edgeToEdge;
  static const defaultSystemUiOverlays = SystemUiOverlay.values;

  /// Restores all system UI settings to their application defaults
  Future<void> restoreDefaultSystemUI() async {
    logInfo('Restoring default system UI properties');

    // Restore system UI mode
    try {
      await SystemChrome.setEnabledSystemUIMode(
        defaultSystemUiMode,
        overlays: defaultSystemUiOverlays,
      );
    } catch (e, stack) {
      logError('Failed to restore default UI mode', e, stack);
    }

    // Restore overlay styles
    setDefaultSystemUIOverlayStyle();
  }

  /// Overrides the system UI overlay styles
  void setSystemUIOverlayStyle(SystemUiOverlayStyle style) {
    try {
      SystemChrome.setSystemUIOverlayStyle(style);
      logInfo('System UI overlay style updated');
    } catch (e, stack) {
      logError('Failed to set system UI overlay style', e, stack);
    }
  }

  /// Sets the splash screen UI overlay style
  void setSplashSystemUIOverlayStyle() {
    logInfo('Applying splash screen system UI overlay style');
    setSystemUIOverlayStyle(splashOverlayStyle);
  }

  /// Sets the default app system UI overlay style
  void setDefaultSystemUIOverlayStyle() {
    logInfo('Applying default app system UI overlay style');
    setSystemUIOverlayStyle(defaultOverlayStyle);
  }

  /// Overrides the system UI mode (like immersive, edgeToEdge)
  Future<void> setEnabledSystemUIMode(
    SystemUiMode mode, {
    List<SystemUiOverlay>? overlays,
  }) async {
    try {
      await SystemChrome.setEnabledSystemUIMode(mode, overlays: overlays);
      logInfo('System UI mode overridden: $mode');
    } catch (e, stack) {
      logError('Failed to set system UI mode', e, stack);
    }
  }
}
