import 'dart:async';
import 'dart:convert';

import 'ih_runner_ctrl.dart';
import 'scripts/ih_runner_scripts.dart';

export 'game_host_event.dart';

/// {@template game_bridge_mixin}
/// Core mixin that implements the Host Bridge communication layer for IHRunner.
///
/// Provides:
/// - A broadcast [Stream] of typed [GameHostEvent]s from the game.
/// - Message parsing from raw JS bridge payloads (string or Map).
/// - Sending typed events back to the game via `window.onFlutterMessage`.
/// - Injecting the `window.GameHost` JS shim into the WebView.
/// - Registering the `flutterChannel` InAppWebView JS handler.
///
/// ## Usage
///
/// Mix this into any [IHRunnerCtrl] subclass:
///
/// ```dart
/// class IHInAppRunnerCtrl extends IHRunnerCtrl with GameBridgeMixin {
///   void onWebViewCreated(InAppWebViewController ctrl) {
///     webViewController = ctrl;
///     setupHostBridge();  // registers 'flutterChannel' JS handler
///   }
///
///   @override
///   void dispose() {
///     disposeGameBridge();
///     ...
///   }
/// }
/// ```
/// {@endtemplate}
mixin GameBridgeMixin on IHRunnerCtrl {
  // ---------------------------------------------------------------------------
  // Stream
  // ---------------------------------------------------------------------------

  /// Internal broadcast controller for [GameHostEvent]s received via the bridge.
  final _hostMessageController = StreamController<GameHostEvent>.broadcast();

  @override
  Stream<GameHostEvent> get onHostMessage => _hostMessageController.stream;

  // ---------------------------------------------------------------------------
  // Message Processing
  // ---------------------------------------------------------------------------

  /// Parses [message] received from the JS bridge and emits a [GameHostEvent].
  ///
  /// [message] may be:
  /// - A `Map` already decoded from JSON.
  /// - A JSON `String` (common from InAppWebView handlers).
  /// - A plain `String` event type (legacy format).
  ///
  /// [defaultSource] is used when the message does not include a `source` key.
  @override
  void processHostMessage(dynamic message, {String defaultSource = 'game'}) {
    if (message == null) return;
    logger('info', '[IHRunner] Bridge received: $message');

    try {
      dynamic input = message;

      // Decode JSON string to Map if needed.
      if (message is String && message.trim().startsWith('{')) {
        try {
          input = jsonDecode(message);
        } catch (e) {
          logger('error', '[IHRunner] Failed to parse bridge JSON: $e');
        }
      }

      final event = GameHostEvent.fromJson(input);

      if (event.type.isNotEmpty) {
        _hostMessageController.add(
          GameHostEvent(
            type: event.type,
            source: event.source ?? defaultSource,
            data: event.data,
            raw: message.toString(),
          ),
        );
      }
    } catch (e, st) {
      logger(
        'error',
        '[IHRunner] Failed to process bridge message',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sending to Game
  // ---------------------------------------------------------------------------

  /// Sends a typed [GameHostEvent] to the game via `window.onFlutterMessage`.
  ///
  /// The game must have registered an `onFlutterMessage` handler to receive it.
  @override
  Future<void> sendMessage(GameHostEvent event) async {
    final payload = event.encode();
    final escaped = payload.replaceAll("'", r"\'");
    await evaluateJavascript(
      "if(window.onFlutterMessage) window.onFlutterMessage('$escaped');",
    );
  }

  // ---------------------------------------------------------------------------
  // Bridge Injection
  // ---------------------------------------------------------------------------

  /// Injects the `window.GameHost` JS shim into the current page.
  ///
  /// Called automatically on `onLoadStop` for mobile, or manually for web.
  /// The shim is idempotent — safe to call multiple times.
  @override
  Future<void> injectHostBridge({String? url}) async {
    try {
      await evaluateJavascript(IHRunnerScripts.bridgeShim);
      logger(
        'info',
        '[IHRunner] Bridge shim injected into: ${url ?? 'unknown'}',
      );
    } catch (e) {
      logger('error', '[IHRunner] Bridge shim injection failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Setup & Teardown
  // ---------------------------------------------------------------------------

  /// Registers the `flutterChannel` InAppWebView JS handler.
  ///
  /// Must be called in `onWebViewCreated` after the WebView is ready.
  /// On Web, [addJavaScriptHandler] is a no-op — web messages arrive via
  /// [WebMessageListenerMixin] instead.
  void setupHostBridge() {
    addJavaScriptHandler(
      handlerName: 'flutterChannel',
      callback: (args) {
        if (args.isEmpty) return;
        processHostMessage(args.first, defaultSource: 'ih_runner-game');
      },
    );
  }

  /// Closes the bridge stream controller.
  ///
  /// Must be called in the controller's [dispose] method.
  void disposeGameBridge() {
    _hostMessageController.close();
  }
}
