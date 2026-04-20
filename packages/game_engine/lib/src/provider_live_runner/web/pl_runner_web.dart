import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../iframe_crash_detection_mixin.dart';
import '../../iframe_dimension_lock_mixin.dart';
import '../inapp/inapp_runner_view.dart';
import '../pl_runner_ctrl.dart';
import '../pl_runner_platform_interface.dart';
import 'pl_runner_controller_web.dart';

/// {@template pl_runner_web_impl}
/// Web implementation of [PLRunnerPlatform] using a native `<iframe>` element.
///
/// This is the **backup / fallback** implementation kept alongside
/// [PLInAppRunnerView]. Use it when the game's CSP blocks the
/// `flutter_inappwebview` shim, or when you need raw iframe control.
///
/// The rendering mode is controlled by [useInAppWebViewOnWeb]:
/// - `true`  — delegates to [PLInAppRunnerView] (InAppWebView inside browser).
/// - `false` — renders a native `<iframe>` directly.
/// {@endtemplate}
class PLRunnerWebImpl extends PLRunnerPlatform {
  /// Creates a [PLRunnerWebImpl].
  const PLRunnerWebImpl({
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

  /// Whether to use `flutter_inappwebview` instead of a native `<iframe>`.
  ///
  /// Defaults to `true`. Set to `false` when the game's CSP blocks
  /// the InAppWebView shim script or when iframe is explicitly preferred.
  final bool useInAppWebViewOnWeb;

  @override
  State<PLRunnerWebImpl> createState() => _PLRunnerWebState();
}

class _PLRunnerWebState extends State<PLRunnerWebImpl>
    with IFrameDimensionLockMixin, IFrameCrashDetectionMixin {
  late final PLRunnerControllerWeb _controller;
  StreamSubscription? _onLoadStateSub;
  StreamSubscription? _onErrorSub;

  @override
  void onTopLevelJsError(web.Event event) {
    widget.logger('error', '[PLRunner] TOP-LEVEL JS ERROR detected');
  }

  @override
  void onUnhandledPromiseRejection(web.Event event) {
    widget.logger('error', '[PLRunner] UNHANDLED PROMISE REJECTION detected');
  }

  @override
  void onPageHide(web.Event event) {
    widget.logger('warning', '[PLRunner] PAGE HIDE detected');
  }

  @override
  void onVisibilityChange(String visibilityState) {
    widget.logger('info', '[PLRunner] Visibility changed: $visibilityState');
  }

  @override
  void initState() {
    super.initState();
    _setupController();
    installCrashDetection();
  }

  void _setupController() {
    if (widget.controller != null) {
      if (widget.controller is PLRunnerControllerWeb) {
        _controller = widget.controller! as PLRunnerControllerWeb;
      } else {
        throw ArgumentError('PLRunner on Web requires PLRunnerControllerWeb');
      }
    } else {
      _controller = PLRunnerControllerWeb(logger: widget.logger);
    }

    _onLoadStateSub = _controller.onStateChanged.listen((state) {
      if (state == PLRunnerState.loading) {
        if (mounted) widget.onLoadStart?.call();
      } else if (state == PLRunnerState.loaded) {
        if (mounted) widget.onLoadStop?.call();
      } else if (state == PLRunnerState.failure) {
        if (mounted) widget.onError?.call('WebView Error');
      }
    });

    _onErrorSub = _controller.onError.listen((error) {
      if (mounted) widget.onError?.call(error);
    });
  }

  @override
  void dispose() {
    removeDimensionLockTimers();
    removeCrashDetection();

    _onLoadStateSub?.cancel();
    _onErrorSub?.cancel();

    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useInAppWebViewOnWeb) {
      return PLInAppRunnerView(
        gameUrl: widget.gameUrl,
        logger: widget.logger,
        controller: widget.controller,
        onLoadStart: widget.onLoadStart,
        onLoadStop: widget.onLoadStop,
        onError: widget.onError,
        forceLandscapeViewport: widget.forceLandscapeViewport,
        enableDimensionLock: widget.enableDimensionLock,
        blockFullscreen: widget.blockFullscreen,
        viewId: widget.viewId,
        loadStopDebounce: widget.loadStopDebounce,
      );
    }
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final iframe = element as web.HTMLIFrameElement;
        iframe.src = widget.gameUrl;
        iframe.style.border = 'none';
        iframe.style.width = '100vw';
        iframe.style.height = '100vh';

        _controller.attach(iframe);
        _controller.handleLoadStart();

        iframe.onLoad.listen((_) {
          _controller.handleLoadStop();
        });

        iframe.onError.listen((_) {
          _controller.handleLoadError('Failed to load iframe');
        });
      },
    );
  }
}

/// Platform alias used by [PLRunner] via conditional imports.
///
/// On Web, this resolves to [PLRunnerWebImpl], which internally selects
/// between `<iframe>` and InAppWebView based on [PLRunnerWebImpl.useInAppWebViewOnWeb].
typedef PLRunnerImpl = PLRunnerWebImpl;
