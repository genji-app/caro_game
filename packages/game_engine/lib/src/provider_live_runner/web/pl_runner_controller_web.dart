import 'dart:async';

import 'package:web/web.dart' as web;

import '../../logger.dart';
import '../pl_runner_ctrl.dart';

/// Web implementation of [PLRunnerCtrl] using [web.HTMLIFrameElement].
class PLRunnerControllerWeb extends PLRunnerCtrl {
  /// Default constructor for [PLRunnerControllerWeb].
  PLRunnerControllerWeb({
    this.logger = silentLogger,
  });

  @override
  final GameEngineLogger logger;

  web.HTMLIFrameElement? _iframe;

  @override
  String get currentUrl => _iframe?.src ?? '';

  @override
  PLRunnerState get state => _state;
  PLRunnerState _state = PLRunnerState.idle;

  final _stateController = StreamController<PLRunnerState>.broadcast();

  @override
  Stream<PLRunnerState> get onStateChanged => _stateController.stream;

  final _loadStartController = StreamController<void>.broadcast();
  final _loadStopController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  @override
  Stream<void> get onLoadStart => _loadStartController.stream;

  @override
  Stream<void> get onLoadStop => _loadStopController.stream;

  @override
  Stream<String> get onError => _errorController.stream;

  /// Attaches an HTML iframe to the controller for Web control.
  void attach(web.HTMLIFrameElement iframe) {
    _iframe = iframe;
  }

  /// Handles the event when the WebView starts loading (Web).
  void handleLoadStart() {
    updateState(PLRunnerState.loading);
    if (!_loadStartController.isClosed) {
      _loadStartController.add(null);
    }
  }

  /// Handles the event when the WebView finishes loading (Web).
  void handleLoadStop() {
    updateState(PLRunnerState.loaded);
    if (!_loadStopController.isClosed) {
      _loadStopController.add(null);
    }
  }

  /// Handles the event when an error occurs during loading (Web).
  void handleLoadError(String message) {
    updateState(PLRunnerState.failure);
    if (!_errorController.isClosed) {
      _errorController.add(message);
    }
  }

  @override
  void updateState(PLRunnerState newState, {String? url, String? message}) {
    if (_state == newState) return;
    _state = newState;
    _stateController.add(_state);

    if (newState == PLRunnerState.failure) {
      if (!_errorController.isClosed) {
        _errorController.add(message ?? 'Failed to load iframe');
      }
    }
  }

  @override
  Future<void> reload() async {
    if (_iframe != null) {
      final oldSrc = _iframe!.src;
      _iframe!.src = '';
      await Future<void>.delayed(const Duration(milliseconds: 50));
      _iframe!.src = oldSrc;
    }
  }

  @override
  Future<dynamic> evaluateJavascript(String source) async {
    logger('warning',
        'evaluateJavascript is not fully supported on Web via IFrame due to security (CORS) constraints.');
    return null;
  }

  @override
  void dispose() {
    _stateController.close();
    _loadStartController.close();
    _loadStopController.close();
    _errorController.close();
    _iframe = null;
  }
}
