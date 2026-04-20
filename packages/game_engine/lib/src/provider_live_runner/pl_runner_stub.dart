import 'package:flutter/material.dart';

import 'pl_runner_platform_interface.dart';

/// {@template pl_inapp_runner_view_stub}
/// Stub implementation of [PLRunnerPlatform] for unsupported platforms.
///
/// This file is compiled when neither `dart:io` nor `dart:js_interop` is
/// available. In practice this should never be used in production.
/// {@endtemplate}
class PLInAppRunnerView extends PLRunnerPlatform {
  /// Default stub constructor.
  const PLInAppRunnerView({
    required super.gameUrl,
    super.logger,
    super.controller,
    super.key,
    super.onLoadStart,
    super.onLoadStop,
    super.onError,
    super.forceLandscapeViewport,
    super.enableDimensionLock,
    super.blockFullscreen,
    super.loadStopDebounce,
    super.viewId = 'pl-runner',
    this.useInAppWebViewOnWeb = true,
  });

  /// No-op on unsupported platforms.
  final bool useInAppWebViewOnWeb;

  @override
  State<PLInAppRunnerView> createState() => _PLInAppRunnerStubState();
}

class _PLInAppRunnerStubState extends State<PLInAppRunnerView> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Unsupported Platform'));
  }
}

/// Platform alias resolved by [PLRunner] at compile-time.
///
/// On unsupported platforms, resolves to [PLInAppRunnerView] (this stub).
typedef PLRunnerImpl = PLInAppRunnerView;
