import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logger.dart';
import 'game_host_event.dart';
import 'inapp/inapp_runner_ctrl.dart';

export 'game_host_event.dart';

/// {@template ih_runner_state}
/// Represents the loading lifecycle of an [IHRunner] game WebView.
/// {@endtemplate}
enum IHRunnerState {
  /// Initial state — before loading has started or after a reset.
  idle,

  /// The WebView is currently loading a URL or content.
  loading,

  /// The WebView has successfully finished loading the page.
  loaded,

  /// An error occurred during the loading process.
  error,
}

/// {@template ih_runner_ctrl}
/// Abstract base interface for controlling an IHRunner game WebView.
///
/// Provides programmatic access to the underlying WebView engine and
/// bidirectional communication between Flutter and the game via the
/// [GameHostEvent] Host Bridge protocol.
///
/// ## Concrete implementations
///
/// - [IHInAppRunnerCtrl] — Mobile (iOS/Android) + Web via InAppWebView.
///
/// ## Factory constructor
///
/// ```dart
/// final ctrl = IHRunnerCtrl.inApp(logger: myLogger);
/// ```
/// {@endtemplate}
abstract class IHRunnerCtrl {
  /// Internal constructor for subclassing.
  @protected
  IHRunnerCtrl();

  /// Creates a controller backed by `flutter_inappwebview` (recommended).
  factory IHRunnerCtrl.inApp({GameEngineLogger logger = silentLogger}) =>
      IHInAppRunnerCtrl(logger: logger);

  // ---------------------------------------------------------------------------
  // Observable State
  // ---------------------------------------------------------------------------

  /// The logger used for this controller's diagnostic output.
  GameEngineLogger get logger;

  /// Current WebView lifecycle state.
  IHRunnerState get state;

  /// Stream that emits whenever [state] changes.
  Stream<IHRunnerState> get onStateChanged;

  /// Stream of typed [GameHostEvent]s received from the game via the bridge.
  Stream<GameHostEvent> get onHostMessage;

  /// Currently loaded URL, or `null` if the WebView has not navigated yet.
  String? get currentUrl;

  /// Shorthand for `state == IHRunnerState.loading`.
  bool get isLoading => state == IHRunnerState.loading;

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  /// Reloads the current page.
  Future<void> reload();

  /// Sends a typed [GameHostEvent] to the game.
  ///
  /// The game must have the Host Bridge registered to receive the event.
  Future<void> sendMessage(GameHostEvent event);

  /// Evaluates [source] as JavaScript in the context of the current page.
  ///
  /// Returns the evaluation result, or `null` if the WebView is not ready.
  Future<dynamic> evaluateJavascript(String source);

  /// Registers a platform-specific JavaScript handler.
  ///
  /// On Mobile, maps to `InAppWebViewController.addJavaScriptHandler`.
  /// On Web, this is a no-op — use `postMessage` via the bridge instead.
  void addJavaScriptHandler({
    required String handlerName,
    required void Function(List<dynamic> args) callback,
  });

  // ---------------------------------------------------------------------------
  // Internal / Bridge
  // ---------------------------------------------------------------------------

  /// Processes a raw message received from the game bridge.
  ///
  /// The [message] can be a JSON string or a `Map`. [defaultSource] is used
  /// as the `source` field when the message does not include one.
  void processHostMessage(dynamic message, {String defaultSource = 'game'});

  /// Updates the internal WebView state machine.
  ///
  /// Called by platform views on WebView lifecycle events. Not intended for
  /// direct use by consumers.
  void updateState(IHRunnerState newState, {String? url});

  /// Stops all media (video/audio) playback in the game.
  ///
  /// When [clearPage] is `true`, the WebView additionally navigates to
  /// `about:blank` to fully release embedded media resources.
  Future<void> stopAllMedia({bool clearPage = false});

  /// Injects the Host Bridge JavaScript shim into the current page.
  Future<void> injectHostBridge({String? url});

  // ---------------------------------------------------------------------------
  // Web-only (no-ops on mobile)
  // ---------------------------------------------------------------------------

  /// Unregisters the `postMessage` event listener (Web only).
  void unregisterMessageListener() {}

  /// Cleans up any `<iframe>` resources (Web only).
  void cleanupIframe() {}

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Releases all resources (streams, WebView references).
  ///
  /// Must be called when the controlling [State] is disposed, unless the
  /// controller is owned internally by [IHRunner].
  @mustCallSuper
  void dispose();
}
