import 'package:web/web.dart' as web;

/// Web implementation to get browser version
Future<String> getDeviceOsVersion() async {
  try {
    final userAgent = web.window.navigator.userAgent;
    return _parseBrowserVersion(userAgent);
  } catch (e) {
    return 'Web';
  }
}

/// Parse browser version from user agent
/// Returns format like "chrome 142.0.0.0" or "safari 17.0"
String _parseBrowserVersion(String userAgent) {
  // Chrome: "Chrome/142.0.0.0"
  final chromeMatch = RegExp(
    r'Chrome/(\d+\.\d+\.\d+\.\d+)',
  ).firstMatch(userAgent);
  if (chromeMatch != null) {
    return 'chrome ${chromeMatch.group(1)}';
  }

  // Safari: "Version/17.0 Safari/"
  final safariMatch = RegExp(
    r'Version/(\d+\.\d+).*Safari',
  ).firstMatch(userAgent);
  if (safariMatch != null) {
    return 'safari ${safariMatch.group(1)}';
  }

  // Firefox: "Firefox/120.0"
  final firefoxMatch = RegExp(r'Firefox/(\d+\.\d+)').firstMatch(userAgent);
  if (firefoxMatch != null) {
    return 'firefox ${firefoxMatch.group(1)}';
  }

  // Edge: "Edg/120.0.0.0"
  final edgeMatch = RegExp(r'Edg/(\d+\.\d+\.\d+\.\d+)').firstMatch(userAgent);
  if (edgeMatch != null) {
    return 'edge ${edgeMatch.group(1)}';
  }

  return 'Web';
}
