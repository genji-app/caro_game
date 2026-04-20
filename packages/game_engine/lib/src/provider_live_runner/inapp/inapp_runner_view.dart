import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../pl_runner_ctrl.dart';
import '../pl_runner_platform_interface.dart';
import 'inapp_runner_ctrl.dart';

/// {@template pl_inapp_runner_view}
/// [InAppWebView] implementation of [PLRunnerPlatform].
///
/// Used on Mobile (iOS / Android) and optionally on Web when
/// `useInAppWebViewOnWeb` is `true`.
///
/// This widget manages its own [PLInAppRunnerCtrl] unless an external
/// controller is provided via [PLRunnerPlatform.controller].
/// {@endtemplate}
class PLInAppRunnerView extends PLRunnerPlatform {
  /// Creates a [PLInAppRunnerView].
  const PLInAppRunnerView({
    required super.gameUrl,
    super.logger,
    super.controller,
    super.key,
    super.onLoadStart,
    super.onLoadStop,
    super.onError,
    super.forceLandscapeViewport,
    super.scaleContent,
    super.enableDimensionLock,
    super.blockFullscreen,
    super.loadStopDebounce,
    super.viewId = 'pl-runner',
    this.useInAppWebViewOnWeb = true,
  });

  /// Whether to use InAppWebView on Web instead of the `<iframe>` fallback.
  ///
  /// This param is read by [PLRunnerWebImpl] when routing. It has no effect
  /// when this widget is used directly on Mobile.
  final bool useInAppWebViewOnWeb;

  @override
  State<PLInAppRunnerView> createState() => _PLInAppRunnerState();
}

class _PLInAppRunnerState extends State<PLInAppRunnerView> {
  // Nullable controller tracks ownership: non-null = we own it, null = external.
  PLInAppRunnerCtrl? _ownedController;

  late final PLInAppRunnerCtrl _ctrl;

  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    _checkPlatformWarnings();
    _initController();
    _setupSubscriptions();
  }

  // ---------------------------------------------------------------------------
  // Init Helpers
  // ---------------------------------------------------------------------------

  void _checkPlatformWarnings() {
    if (widget.enableDimensionLock) {
      widget.logger(
        'warning',
        '[PLRunner] enableDimensionLock is a Web-only feature; ignored on Mobile.',
      );
    }
  }

  void _initController() {
    final external = widget.controller;
    if (external != null) {
      if (external is! PLInAppRunnerCtrl) {
        throw ArgumentError(
          'PLInAppRunnerView requires a PLInAppRunnerCtrl. '
          'Received: ${external.runtimeType}',
        );
      }
      _ctrl = external;
      // _ownedController stays null — we do NOT dispose external controllers.
    } else {
      _ownedController = PLInAppRunnerCtrl(
        logger: widget.logger,
        blockFullscreen: widget.blockFullscreen,
        forceLandscapeViewport: widget.forceLandscapeViewport,
        loadStopDebounce: widget.loadStopDebounce ?? Duration.zero,
      );
      _ctrl = _ownedController!;
    }
  }

  void _setupSubscriptions() {
    _subs.addAll([
      _ctrl.onLoadStart.listen((_) {
        if (mounted) widget.onLoadStart?.call();
      }),
      _ctrl.onLoadStop.listen((_) {
        if (mounted) widget.onLoadStop?.call();
      }),
      _ctrl.onError.listen((error) {
        if (mounted) widget.onError?.call(error);
      }),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _ownedController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.gameUrl)),
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: false,
        javaScriptEnabled: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
        allowsBackForwardNavigationGestures: false,
        isInspectable: kDebugMode,
        layoutAlgorithm: LayoutAlgorithm.NORMAL,
        supportZoom: false,
        builtInZoomControls: false,
        displayZoomControls: false,
      ),
      initialUserScripts: _ctrl.initialUserScripts,
      onWebViewCreated: _ctrl.onWebViewCreated,
      onLoadStart: (controller, url) {
        _ctrl.updateState(PLRunnerState.loading, url: url?.toString());
      },
      onLoadStop: (controller, url) {
        _ctrl.updateState(PLRunnerState.loaded, url: url?.toString());
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame ?? false) {
          _ctrl.updateState(
            PLRunnerState.failure,
            message: '[${error.type}] ${error.description} for ${request.url}',
          );
        }
      },
      onConsoleMessage: (controller, message) {
        _ctrl.onConsoleMessage(message);
      },
    );
  }
}

/// Platform alias used by [PLRunner] via conditional imports.
///
/// On Mobile, this resolves to [PLInAppRunnerView].
/// On Web, `web/pl_runner_web.dart` provides its own typedef that resolves
/// to [PLRunnerWebImpl].
typedef PLRunnerImpl = PLInAppRunnerView;
