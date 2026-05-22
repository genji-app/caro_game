import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logger.dart';

/// {@template pl_runner_state}
/// Represents the loading lifecycle of a [PLRunner] game WebView.
/// {@endtemplate}
enum PLRunnerState {
  /// Waiting for initialization; no URL has been loaded yet.
  idle,

  /// The WebView is currently fetching and rendering content.
  loading,

  /// Content has been loaded and rendered successfully.
  loaded,

  /// A fatal error occurred during loading.
  failure,
}

/// {@template pl_runner_ctrl}
/// Abstract base controller for PLRunner WebViews.
///
/// Provides common programmatic control — [reload], [evaluateJavascript] —
/// and typed streams for tracking load state and errors.
///
/// ## Concrete implementations
///
/// - [PLInAppRunnerCtrl] — Mobile (iOS/Android) + Web via InAppWebView.
/// - [PLRunnerControllerWeb] — Web via native `<iframe>` element.
///
/// Consumer code should depend on this interface only and receive a concrete
/// implementation via [PLRunner]'s `controller` parameter or construct one
/// directly for testing.
/// {@endtemplate}
abstract class PLRunnerCtrl {
  /// Internal constructor; subclass to create custom implementations.
  @protected
  PLRunnerCtrl();

  // ---------------------------------------------------------------------------
  // Observable State
  // ---------------------------------------------------------------------------

  /// Custom logger implementation.
  GameEngineLogger get logger;

  /// Current loading state.
  PLRunnerState get state;

  /// Stream that emits whenever [state] changes.
  Stream<PLRunnerState> get onStateChanged;

  /// The URL currently displayed in the WebView, or `null` if not yet loaded.
  String? get currentUrl;

  /// Emits a void event each time the page begins loading.
  Stream<void> get onLoadStart;

  /// Emits a void event each time the page finishes loading.
  ///
  /// The event may be debounced to avoid noise from intermediate redirects.
  Stream<void> get onLoadStop;

  /// Emits an error description when a fatal load error occurs.
  Stream<String> get onError;

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  /// Reloads the current page.
  Future<void> reload();

  /// Evaluates [source] as JavaScript in the context of the current page.
  ///
  /// Returns the evaluation result, or `null` if the WebView is not ready.
  Future<dynamic> evaluateJavascript(String source);

  /// Updates the internal state machine.
  ///
  /// Called by platform views on WebView lifecycle events. Not intended for
  /// direct use by consumers.
  void updateState(PLRunnerState newState, {String? url, String? message});

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Releases all resources (streams, WebView references).
  ///
  /// Must be called when the controlling [State] is disposed, unless the
  /// controller is owned internally by [PLRunner].
  @mustCallSuper
  void dispose();
}

/// {@template pl_runner_state_x}
/// Convenience accessors for [PLRunnerState].
/// {@endtemplate}
extension PLRunnerStateX on PLRunnerState {
  /// `true` when in [PLRunnerState.loading].
  bool get isLoading => this == PLRunnerState.loading;

  /// `true` when in [PLRunnerState.loaded].
  bool get isLoaded => this == PLRunnerState.loaded;

  /// `true` when in [PLRunnerState.failure].
  bool get isFailure => this == PLRunnerState.failure;
}
