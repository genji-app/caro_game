// ignore_for_file: unnecessary_library_name

/// A robust fullscreen and system UI chrome management package for Flutter.
///
/// This package provides cross-platform fullscreen management with a gate
/// mechanism that handles browser gesture requirements on web, and
/// `SystemChrome` immersive mode on native platforms.
///
/// ## Quick start
///
/// 1. Wrap your app root with [FullscreenGuard]:
///
/// ```dart
/// FullscreenGuard(
///   child: MaterialApp.router(...),
/// )
/// ```
///
/// 2. Request fullscreen from any descendant widget:
///
/// ```dart
/// FullscreenGuard.of(context).request(
///   const FullscreenGateRequest(tag: 'gamePlayer'),
/// );
/// ```
///
/// 3. Clear when leaving the screen:
///
/// ```dart
/// FullscreenGuard.of(context).clear();
/// ```
///
/// ## Architecture
///
/// The package is built on two controller layers:
///
/// - [PlatformUiController] — platform abstraction for fullscreen and system
///   UI chrome (Web Fullscreen API / native `SystemChrome`). Observable via
///   [PlatformUiController.isFullscreen] (`ValueListenable<bool>`).
///
/// - [FullscreenGuardController] — gate state machine (`ChangeNotifier`) that
///   manages the request/satisfy/clear lifecycle and auto re-gates when
///   fullscreen is lost externally.
///
/// A single [FullscreenGuard] widget provides both controllers via
/// `InheritedWidget` and renders the gate overlay when active.
///
/// See the [README](https://github.com/user/fullscreen_guard) for detailed
/// API documentation.
library fullscreen_guard;

export 'src/platform_ui/platform_ui.dart';
export 'src/fullscreen_guard/fullscreen_guard.dart';
