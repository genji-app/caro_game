import 'package:flutter/widgets.dart';

import '../logger.dart';
import 'pl_runner_ctrl.dart';

/// {@template pl_runner_platform}
/// Abstract base widget for all PLRunner platform implementations.
///
/// Concrete implementations:
///
/// - [PLInAppRunnerView] — Mobile (iOS/Android) + Web via InAppWebView.
/// - [PLRunnerWebImpl] — Web only, using a native `<iframe>` element.
/// - [PLInAppRunnerView] (stub) — Unsupported platforms.
///
/// Consumer widgets should use [PLRunner], which selects the correct
/// implementation automatically.
/// {@endtemplate}
abstract class PLRunnerPlatform extends StatefulWidget {
  /// Base constructor. All fields have reasonable defaults.
  const PLRunnerPlatform({
    required this.gameUrl,
    this.logger = silentLogger,
    this.controller,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.viewId = 'pl-runner',
    this.forceLandscapeViewport = false,
    this.scaleContent = true,
    this.enableDimensionLock = false,
    this.blockFullscreen = true,
    this.loadStopDebounce,
  });

  /// The entry-point URL of the Provider-Live game.
  final String gameUrl;

  /// Custom logger implementation.
  final GameEngineLogger logger;

  /// Optional external controller.
  ///
  /// When `null`, each implementation creates and manages its own controller.
  final PLRunnerCtrl? controller;

  /// Extra delay after `onLoadStop` fires before emitting the event.
  final Duration? loadStopDebounce;

  // ---------------------------------------------------------------------------
  // Web-only configuration
  // ---------------------------------------------------------------------------

  /// CSS `id` for the iframe/container element.
  ///
  /// **Web only.** Ignored on mobile.
  final String viewId;

  /// Whether to apply CSS `scale()` to keep the internal game layout intact
  /// upon container resizes.
  ///
  /// **Web only.** Defaults to `true`. Ignored on mobile.
  final bool scaleContent;

  /// Whether to lock the iframe container dimensions to their initial pixel size.
  ///
  /// **Web only.** Prevents layout breakage in some game engines on resize.
  /// Defaults to `false`. Ignored on mobile.
  final bool enableDimensionLock;

  // ---------------------------------------------------------------------------
  // Shared configuration
  // ---------------------------------------------------------------------------

  /// Forces landscape viewport via JS polyfill.
  ///
  /// Set to `true` for games that incorrectly detect portrait on iPad.
  final bool forceLandscapeViewport;

  /// Blocks native fullscreen requests from the game.
  ///
  /// Defaults to `true`.
  final bool blockFullscreen;

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------

  /// Called when the page starts loading.
  final VoidCallback? onLoadStart;

  /// Called when the page finishes loading.
  final VoidCallback? onLoadStop;

  /// Called when a fatal load error occurs.
  final ValueChanged<String>? onError;
}
