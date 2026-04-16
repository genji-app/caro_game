/// Web browser detection utilities (conditional import barrel).
///
/// On non-web platforms, all getters return `false`.
/// On web, the real detection is performed via `package:web`.
///
/// Usage:
/// ```dart
/// import 'package:co_caro_flame/s88/core/utils/web_browser_detect.dart';
///
/// if (isIOSSafariWeb) { /* iOS Safari-specific logic */ }
/// ```
library;

export 'web_browser_detect_stub.dart'
    if (dart.library.js_interop) 'web_browser_detect_web.dart';
