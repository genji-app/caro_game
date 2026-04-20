import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../logger.dart';
import '../pl_runner_ctrl.dart';
import '../scripts/pl_runner_scripts.dart';

/// {@template pl_inapp_runner_ctrl}
/// InAppWebView implementation of [PLRunnerCtrl].
///
/// Manages the lifecycle, JS injection, and event streaming for the
/// `PLRunner` game WebView on Mobile (and Web via `flutter_inappwebview`).
///
/// ## Injection strategy
///
/// Scripts are injected at two levels:
///
/// 1. **[initialUserScripts]** — Registered as native `UserScript`s so the
///    engine injects them *before* any page JS executes. This is the primary
///    vector and ensures polyfills patch the environment before the game reads it.
///
/// 2. **[_applyAllInjections]** — Repeated `evaluateJavascript` calls at each
///    lifecycle stage (`onWebViewCreated`, `onLoadStart`, `onLoadStop`) as a
///    belt-and-braces backup for redirected navigations or lazy-loaded frames.
/// {@endtemplate}
class PLInAppRunnerCtrl extends PLRunnerCtrl {
  /// Creates a [PLInAppRunnerCtrl].
  ///
  /// [blockFullscreen] — prevents the game from requesting native fullscreen.
  /// Defaults to `true`.
  ///
  /// [forceLandscapeViewport] — injects orientation polyfill + viewport meta
  /// to force landscape mode on iOS WebKit. Defaults to `false`.
  ///
  /// [loadStopDebounce] — extra delay after `onLoadStop` before emitting
  /// [onLoadStop] stream event. Useful for games that perform additional
  /// redirects after load. Defaults to [Duration.zero].
  PLInAppRunnerCtrl({
    GameEngineLogger logger = silentLogger,
    this.blockFullscreen = true,
    this.forceLandscapeViewport = false,
    this.loadStopDebounce = Duration.zero,
  }) : _logger = logger {
    _checkPlatformCompatibility();
    _initUserScripts();
  }

  // ---------------------------------------------------------------------------
  // Configuration Fields
  // ---------------------------------------------------------------------------

  /// Whether to block native fullscreen requests.
  final bool blockFullscreen;

  /// Whether to force landscape viewport via JS polyfill.
  final bool forceLandscapeViewport;

  /// Debounce duration applied after [onLoadStop] fires.
  final Duration loadStopDebounce;

  // ---------------------------------------------------------------------------
  // State & Controllers
  // ---------------------------------------------------------------------------

  @override
  GameEngineLogger get logger => _logger;
  final GameEngineLogger _logger;

  PLRunnerState _state = PLRunnerState.idle;
  String? _currentUrl;

  /// The underlying [InAppWebViewController]. Set in [onWebViewCreated].
  InAppWebViewController? webViewController;

  final List<UserScript> _userScripts = [];

  final _stateController = StreamController<PLRunnerState>.broadcast();
  final _loadStartController = StreamController<void>.broadcast();
  final _loadStopController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // ---------------------------------------------------------------------------
  // Getter Overrides
  // ---------------------------------------------------------------------------

  @override
  PLRunnerState get state => _state;

  @override
  String? get currentUrl => _currentUrl;

  @override
  Stream<PLRunnerState> get onStateChanged => _stateController.stream;

  @override
  Stream<void> get onLoadStart => _loadStartController.stream;

  @override
  Stream<void> get onLoadStop => _loadStopController.stream;

  @override
  Stream<String> get onError => _errorController.stream;

  /// Read-only snapshot of [UserScript]s registered for native injection.
  ///
  /// Pass this to `InAppWebView.initialUserScripts` so scripts are injected
  /// before any page JS executes.
  UnmodifiableListView<UserScript> get initialUserScripts =>
      UnmodifiableListView<UserScript>(_userScripts);

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  /// Called when the [InAppWebViewController] is ready.
  ///
  /// Triggers the first round of JS injections to patch the environment
  /// before the game URL has started loading.
  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    _applyAllInjections('onWebViewCreated');
  }

  @override
  void updateState(PLRunnerState newState, {String? url, String? message}) {
    if (_state == newState && _currentUrl == url) return;
    _state = newState;
    _currentUrl = url;
    _stateController.add(newState);

    switch (newState) {
      case PLRunnerState.loading:
        if (!_loadStartController.isClosed) _loadStartController.add(null);
        _applyAllInjections('onLoadStart');
      case PLRunnerState.loaded:
        // Immediate injection for fast responsiveness.
        _applyAllInjections('onLoadStop:immediate');
        // Debounced injection covers games that redirect after initial load.
        Timer(loadStopDebounce, () {
          if (_loadStopController.isClosed) return;
          _applyAllInjections('onLoadStop:debounced');
          _loadStopController.add(null);
        });
      case PLRunnerState.failure:
        if (!_errorController.isClosed) {
          _errorController.add(message ?? 'Failed to load game');
        }
      case PLRunnerState.idle:
        break;
    }
  }

  @override
  Future<void> reload() async {
    await webViewController?.reload();
  }

  @override
  Future<dynamic> evaluateJavascript(String source) async {
    return webViewController?.evaluateJavascript(source: source);
  }

  /// Loads [url] in the current WebView.
  Future<void> loadUrl(String url) async {
    await webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  /// Forwards a [ConsoleMessage] from the WebView to [logger].
  ///
  /// Only surfaces messages tagged with `[PLRunner` to reduce noise.
  void onConsoleMessage(ConsoleMessage message) {
    final text = message.message;
    if (!text.contains('[PLRunner')) return;
    switch (message.messageLevel) {
      case ConsoleMessageLevel.ERROR:
        logger('error', '[WebView] $text');
      case ConsoleMessageLevel.WARNING:
        logger('warning', '[WebView] $text');
      default:
        logger('info', '[WebView] $text');
    }
  }

  @override
  void dispose() {
    _stateController.close();
    _loadStartController.close();
    _loadStopController.close();
    _errorController.close();
    webViewController = null;
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Registers native [UserScript]s based on the active configuration.
  ///
  /// `initialUserScripts` is a native Mobile feature that guarantees injection
  /// *before* page JS. On Web, we rely on [_applyAllInjections] instead.
  ///
  /// Ordering matters: **polyfill must run before viewport** so that
  /// `detectIsLandscape()` inside the viewport script reads already-patched
  /// `screen.width`/`screen.height` values.
  ///
  /// Each script is registered at both [UserScriptInjectionTime.AT_DOCUMENT_START]
  /// and [UserScriptInjectionTime.AT_DOCUMENT_END] because:
  ///
  /// - `AT_DOCUMENT_START` = primary injection, before any page script.
  /// - `AT_DOCUMENT_END`   = backup for redirected navigations or dynamically
  ///   created iframes. Because both scripts are idempotent (guarded by
  ///   `window.__*Patched` flags), running them twice is safe.
  void _initUserScripts() {
    if (kIsWeb) return; // Web uses evaluateJavascript instead.

    if (forceLandscapeViewport) {
      _userScripts.addAll([
        UserScript(
          source: PLRunnerScripts.orientationPolyfill,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLRunnerScripts.landscapeViewport,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLRunnerScripts.orientationPolyfill,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
        UserScript(
          source: PLRunnerScripts.landscapeViewport,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
      ]);
    }

    if (blockFullscreen) {
      _userScripts.add(
        UserScript(
          source: PLRunnerScripts.fullscreenBlocker,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
      );
    }
  }

  /// Orchestrates all JS injections for a given lifecycle [trigger].
  ///
  /// Execution order: orientation polyfill → landscape viewport → fullscreen
  /// blocker → diagnostics (debug only).
  void _applyAllInjections(String trigger) {
    logger(
      'info',
      '[PLRunner] _applyAllInjections — trigger=$trigger forceLandscape=$forceLandscapeViewport',
    );

    _injectOrientationPolyfill();
    _injectLandscapeViewport();
    _injectFullscreenBlocker();

    if (kDebugMode) {
      _injectDiagnostics(trigger);
    }
  }

  void _injectOrientationPolyfill() {
    if (!forceLandscapeViewport) return;
    webViewController
        ?.evaluateJavascript(source: PLRunnerScripts.orientationPolyfill)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject orientation polyfill: $e');
    });
  }

  void _injectLandscapeViewport() {
    if (!forceLandscapeViewport) return;
    webViewController
        ?.evaluateJavascript(source: PLRunnerScripts.landscapeViewport)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject landscape viewport meta: $e');
    });
  }

  void _injectFullscreenBlocker() {
    if (!blockFullscreen) return;
    webViewController
        ?.evaluateJavascript(source: PLRunnerScripts.fullscreenBlocker)
        .catchError((Object e) {
      logger('error', '[PLRunner] Failed to inject fullscreen blocker: $e');
    });
  }

  void _injectDiagnostics(String trigger) {
    // Embed the trigger label into the tag for easy log filtering.
    final taggedScript = PLRunnerScripts.diagnostics.replaceFirst(
      '[PLRunner:DIAG]',
      '[PLRunner:DIAG:$trigger]',
    );
    webViewController?.evaluateJavascript(source: taggedScript).catchError(
      (Object e) {
        logger('error', '[PLRunner] Failed to inject diagnostics: $e');
      },
    );
  }

  /// Logs platform-specific warnings for incompatible configuration combos.
  void _checkPlatformCompatibility() {
    if (!kIsWeb) return;
    if (blockFullscreen) {
      logger(
        'warning',
        '[PLRunner] blockFullscreen might not work reliably on Web due to Browser security policies.',
      );
    }
    if (forceLandscapeViewport) {
      logger(
        'warning',
        '[PLRunner] forceLandscapeViewport on Web might cause unexpected layout on Desktop browsers.',
      );
    }
  }
}
