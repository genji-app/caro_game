import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../logger.dart';
import '../game_bridge_mixin.dart';
import '../game_media_control_mixin.dart';
import '../ih_runner_ctrl.dart';
import '../scripts/ih_runner_scripts.dart';

/// {@template ih_runner_view_controller_inapp}
/// Implementation of [IHRunnerCtrl] using the `flutter_inappwebview` engine.
/// This runner is specifically optimized for In-House games (e.g. Cocos engines).
/// {@endtemplate}
class IHInAppRunnerCtrl extends IHRunnerCtrl with GameBridgeMixin, GameMediaControlMixin {
  /// Initializes [IHInAppRunnerCtrl].
  IHInAppRunnerCtrl({
    GameEngineLogger logger = silentLogger,
    this.loadStopDebounce = Duration.zero,
    this.enableHostMessage = true,
  }) : _logger = logger;

  // ---------------------------------------------------------------------------
  // Fields & State
  // ---------------------------------------------------------------------------

  /// Specialized debounce for [onLoadStop] event.
  final Duration loadStopDebounce;

  /// Whether to allow injecting the Host Bridge. Defaults to `true`.
  final bool enableHostMessage;

  @override
  GameEngineLogger get logger => _logger;
  final GameEngineLogger _logger;

  IHRunnerState _state = IHRunnerState.idle;
  String? _currentUrl;

  /// The internal InAppWebViewController.
  InAppWebViewController? webViewController;

  final _stateController = StreamController<IHRunnerState>.broadcast();

  // ---------------------------------------------------------------------------
  // Getter Overrides
  // ---------------------------------------------------------------------------

  @override
  IHRunnerState get state => _state;

  @override
  String? get currentUrl => _currentUrl;

  @override
  Stream<IHRunnerState> get onStateChanged => _stateController.stream;

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  /// Callback called when the WebView is initialized.
  ///
  /// This sets up the Host Bridge and applies early environment fixes for Web.
  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    setupHostBridge();

    if (kIsWeb) {
      applyEarlyWebFixes();
    }
  }

  /// Compatibility bridge for older IHRunner implementations.
  void attach(InAppWebViewController controller) => onWebViewCreated(controller);

  @override
  void updateState(IHRunnerState newState, {String? url}) {
    if (_state == newState && _currentUrl == url) return;

    if (newState == IHRunnerState.loaded) {
      Timer(loadStopDebounce, () async {
        if (_stateController.isClosed) return;
        _state = newState;
        _currentUrl = url;
        _stateController.add(newState);

        // ✅ WEB: Apply post-load fixes (re-layout, orientation, etc.)
        if (kIsWeb) {
          await applyPostLoadWebFixes();
        }

        // ✅ BRIDGE: Inject host bridge shim if enabled
        if (enableHostMessage) {
          await injectHostBridge(url: url);
        }
      });
      return;
    }

    _state = newState;
    _currentUrl = url;
    _stateController.add(newState);
  }

  @override
  Future<void> reload() async {
    await webViewController?.reload();
  }

  @override
  Future<dynamic> evaluateJavascript(String source) async {
    return await webViewController?.evaluateJavascript(source: source);
  }

  /// Loads a new URL (mobile only).
  Future<void> loadUrl(String url) async {
    await webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  @override
  void addJavaScriptHandler({
    required String handlerName,
    required void Function(List<dynamic> args) callback,
  }) {
    if (kIsWeb) {
      logger(
        'warning',
        'addJavaScriptHandler is not supported on Web. Use postMessage instead.',
      );
      return;
    }
    webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: callback,
    );
  }

  @override
  void unregisterMessageListener() {}

  @override
  void cleanupIframe() {}

  @override
  void dispose() {
    disposeGameBridge();
    _stateController.close();
    webViewController = null;
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Applies early JavaScript environment fixes for Web compatibility.
  ///
  /// This fixes missing properties like `screen.orientation` that some
  /// game engines (e.g., Cocos) expect to be present.
  Future<void> applyEarlyWebFixes() async {
    await evaluateJavascript(IHRunnerScripts.earlyWebFix);
  }

  /// Applies JavaScript fixes after the page has finished loading on Web.
  ///
  /// This includes forcing layout recalculation and fixing engine-specific
  /// orientation state bugs.
  Future<void> applyPostLoadWebFixes() async {
    if (kIsWeb) {
      await evaluateJavascript(IHRunnerScripts.postLoadWebFix);
    }
  }
}
