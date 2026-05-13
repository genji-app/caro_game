import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../../platform_ui/platform_ui.dart';
import 'dom_fullscreen_strategy.dart';
import 'fullscreen_strategy.dart';
import 'pwa_standalone_strategy.dart';
import 'safari_minimal_ui_strategy.dart';
import 'web_mobile_bypass_strategy.dart';

/// Factory function for Web platform.
///
/// Detects the browser environment and returns the optimal strategy.
FullscreenStrategy createFullscreenStrategy(PlatformUiController platformUi) {
  // 1. Temporary Bypass for Web Mobile
  // We want to avoid current UI/UX stability issues on mobile browsers.
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  if (isWebMobile && !_isPwaStandalone()) {
    return WebMobileBypassStrategy();
  }

  // 2. PWA Standalone Mode
  // Browser chrome is already hidden by the OS.
  if (_isPwaStandalone()) {
    return PwaStandaloneStrategy();
  }

  // 3. DOM Fullscreen API Support
  // Chrome, Firefox, and Safari 16.4+ (Desktop).
  if (_supportsDomFullscreen()) {
    return DomFullscreenStrategy();
  }

  // 4. Fallback: Safari iOS Minimal UI Trick
  // For older iOS Safari or versions where Fullscreen API is disabled.
  return SafariMinimalUiStrategy();
}

bool _isPwaStandalone() {
  try {
    return web.window.matchMedia('(display-mode: standalone)').matches;
  } on Object catch (_) {
    return false;
  }
}

bool _supportsDomFullscreen() {
  try {
    final element = web.document.documentElement;
    if (element == null) return false;

    // Check if requestFullscreen exists as a callable property.
    final method = (element as JSObject).getProperty<JSAny?>('requestFullscreen'.toJS);
    return method != null;
  } on Object catch (_) {
    return false;
  }
}
