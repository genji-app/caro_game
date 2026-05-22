import 'package:flutter/material.dart';

import '../logger.dart';
import 'pl_runner_ctrl.dart';
import 'pl_runner_stub.dart'
    if (dart.library.io) 'inapp/inapp_runner_view.dart'
    if (dart.library.js_interop) 'web/pl_runner_web.dart';

export 'pl_runner_ctrl.dart';

/// {@template pl_runner}
/// Platform-agnostic WebView widget for running Provider-Live games.
///
/// The correct platform implementation is selected automatically at
/// compile-time via Dart's conditional import mechanism:
///
/// - **Mobile** (iOS / Android) — renders via `flutter_inappwebview`
///   ([PLInAppRunnerView]).
/// - **Web** — delegates to [PLRunnerWebImpl], which further switches
///   based on [useInAppWebViewOnWeb]:
///   - `true` (default) — uses `flutter_inappwebview` for maximum feature
///     parity with mobile (orientation polyfill, same JS bridge).
///   - `false` — uses a native `<iframe>` element; lighter but with limited
///     JS bridge support due to browser CORS restrictions.
///
/// ## Basic usage
///
/// ```dart
/// PLRunner(
///   gameUrl: 'https://game.example.com',
///   forceLandscapeViewport: true,
///   onLoadStop: () => setState(() => _loaded = true),
/// )
/// ```
///
/// ## Advanced: use an external controller
///
/// ```dart
/// final ctrl = PLInAppRunnerCtrl(
///   forceLandscapeViewport: true,
///   blockFullscreen: true,
/// );
///
/// // Inject custom JS
/// await ctrl.evaluateJavascript('window.postMessage("hello", "*")');
///
/// PLRunner(gameUrl: url, controller: ctrl)
/// ```
/// {@endtemplate}
class PLRunner extends StatelessWidget {
  /// Creates a [PLRunner] widget.
  const PLRunner({
    required this.gameUrl,
    this.logger = silentLogger,
    this.controller,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.viewId = 'pl-runner',
    this.forceLandscapeViewport = false,
    this.enableDimensionLock = false,
    this.blockFullscreen = true,
    this.useInAppWebViewOnWeb = true,
    this.loadStopDebounce,
  });

  /// Optional external controller for programmatic WebView access.
  ///
  /// When `null`, an internal controller is created and managed automatically.
  final PLRunnerCtrl? controller;

  /// The entry-point URL of the Provider-Live game.
  final String gameUrl;

  /// Custom logger implementation for diagnostic output.
  final GameEngineLogger logger;

  /// CSS `id` attribute for the container element (Web only).
  ///
  /// Ignored on mobile.
  final String viewId;

  /// Called when the page starts loading.
  final VoidCallback? onLoadStart;

  /// Called when the page has finished loading.
  final VoidCallback? onLoadStop;

  /// Called when a fatal load error occurs.
  final ValueChanged<String>? onError;

  /// Forces a landscape viewport via JS orientation polyfill.
  ///
  /// Set to `true` for games that require landscape mode on iPad.
  final bool forceLandscapeViewport;

  /// Locks the iframe container dimensions to their initial size (Web only).
  ///
  /// Ignored on mobile.
  final bool enableDimensionLock;

  /// Blocks native fullscreen requests from the game.
  ///
  /// Defaults to `true` to keep the betting UI in control of the viewport.
  final bool blockFullscreen;

  /// Whether to use `flutter_inappwebview` instead of `<iframe>` on Web.
  ///
  /// - `true` (default) — InAppWebView (more features, same polyfills as mobile).
  /// - `false` — native `<iframe>` (lighter; useful when game CSP blocks the shim).
  ///
  /// Ignored on mobile.
  final bool useInAppWebViewOnWeb;

  /// Extra delay after `onLoadStop` fires before emitting the event.
  ///
  /// Useful for games that perform additional redirects after the initial load.
  final Duration? loadStopDebounce;

  @override
  Widget build(BuildContext context) {
    // PLRunnerImpl is resolved at compile-time via conditional imports:
    //   - Mobile (dart.library.io)      → PLInAppRunnerView  (inapp/inapp_runner_view.dart)
    //   - Web (dart.library.js_interop) → PLRunnerWebImpl    (web/pl_runner_web.dart)
    //   - Fallback                      → PLInAppRunnerView  (pl_runner_stub.dart)
    return PLRunnerImpl(
      gameUrl: gameUrl,
      logger: logger,
      controller: controller,
      onLoadStart: onLoadStart,
      onLoadStop: onLoadStop,
      onError: onError,
      viewId: viewId,
      forceLandscapeViewport: forceLandscapeViewport,
      enableDimensionLock: enableDimensionLock,
      blockFullscreen: blockFullscreen,
      useInAppWebViewOnWeb: useInAppWebViewOnWeb,
      loadStopDebounce: loadStopDebounce,
    );
  }
}
