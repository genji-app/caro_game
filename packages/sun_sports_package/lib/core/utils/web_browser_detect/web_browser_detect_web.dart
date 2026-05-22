import 'package:web/web.dart' as web;

/// Whether the current browser is Safari on an iPhone/iPod.
///
/// Detection is based on the User Agent string:
/// - **Safari on iPhone:**
///   `Mozilla/5.0 (iPhone; ...) AppleWebKit/... Version/17.0 Mobile/... Safari/604.1`
/// - **Chrome on iPhone:**
///   `Mozilla/5.0 (iPhone; ...) AppleWebKit/... CriOS/118.0 Mobile/... Safari/604.1`
/// - **Firefox on iPhone:**
///   `Mozilla/5.0 (iPhone; ...) AppleWebKit/... FxiOS/118.0 Mobile/... Safari/604.1`
///
/// Safari is identified by the presence of `Version/` and the absence of
/// third-party browser identifiers (`CriOS`, `FxiOS`, `EdgiOS`, `OPiOS`).
bool get isIOSSafariWeb {
  final ua = web.window.navigator.userAgent;

  // Check for iPhone or iPod (not iPad — iPadOS has higher memory limits)
  final isIPhone = ua.contains('iPhone') || ua.contains('iPod');
  if (!isIPhone) return false;

  // Safari on iOS includes 'Version/' but third-party browsers don't.
  // Instead they use their own identifiers:
  //   Chrome  → CriOS
  //   Firefox → FxiOS
  //   Edge    → EdgiOS
  //   Opera   → OPiOS
  final isSafari =
      ua.contains('Version/') &&
      !ua.contains('CriOS') &&
      !ua.contains('FxiOS') &&
      !ua.contains('EdgiOS') &&
      !ua.contains('OPiOS');

  return isSafari;
}

bool get isWebAndroidBrowser {
  return web.window.navigator.userAgent.contains('Android');
}

bool get isWebIOSBrowser {
  final ua = web.window.navigator.userAgent;
  return ua.contains('iPhone') || ua.contains('iPod') || ua.contains('iPad');
}
