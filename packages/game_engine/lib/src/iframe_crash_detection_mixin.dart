import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Mixin responsible for installing listeners to diagnose crash causes
/// on the Web platform (especially iOS Safari).
///
/// On iOS Safari, the WebContent process can crash when heavy game content
/// (WebGL + live video + WebSocket) exceeds memory limits. These listeners
/// capture diagnostic info BEFORE the crash to help identify the cause.
mixin IFrameCrashDetectionMixin<T extends StatefulWidget> on State<T> {
  web.EventHandler? _errorHandler;
  web.EventHandler? _rejectionHandler;
  web.EventHandler? _pagehideHandler;
  web.EventHandler? _visibilityHandler;

  /// Hook for handling top-level JS error.
  void onTopLevelJsError(web.Event event);

  /// Hook for handling unhandled promise rejection.
  void onUnhandledPromiseRejection(web.Event event);

  /// Hook for handling page hide event (e.g. Safari terminating WebContent).
  void onPageHide(web.Event event);

  /// Hook for visibility state changes.
  void onVisibilityChange(String visibilityState);

  /// Call this inside initState to install all listeners.
  void installCrashDetection() {
    final window = web.window;

    void errorHandler(web.Event event) {
      onTopLevelJsError(event);
    }

    _errorHandler = errorHandler.toJS;
    window.addEventListener('error', _errorHandler);

    void rejectionHandler(web.Event event) {
      onUnhandledPromiseRejection(event);
    }

    _rejectionHandler = rejectionHandler.toJS;
    window.addEventListener('unhandledrejection', _rejectionHandler);

    void pagehideHandler(web.Event event) {
      onPageHide(event);
    }

    _pagehideHandler = pagehideHandler.toJS;
    window.addEventListener('pagehide', _pagehideHandler);

    void visibilityHandler(web.Event event) {
      onVisibilityChange(web.document.visibilityState);
    }

    _visibilityHandler = visibilityHandler.toJS;
    web.document.addEventListener('visibilitychange', _visibilityHandler);
  }

  /// Call this inside dispose to clean up dynamically added event listeners.
  void removeCrashDetection() {
    final window = web.window;
    if (_errorHandler != null) {
      window.removeEventListener('error', _errorHandler);
    }
    if (_rejectionHandler != null) {
      window.removeEventListener('unhandledrejection', _rejectionHandler);
    }
    if (_pagehideHandler != null) {
      window.removeEventListener('pagehide', _pagehideHandler);
    }
    if (_visibilityHandler != null) {
      web.document.removeEventListener('visibilitychange', _visibilityHandler);
    }
  }
}
