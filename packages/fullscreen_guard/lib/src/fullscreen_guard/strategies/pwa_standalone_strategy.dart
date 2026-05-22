import 'package:flutter/foundation.dart';

import 'fullscreen_strategy.dart';

/// {@template pwa_standalone_strategy}
/// Strategy for Web apps running in installed PWA standalone mode.
///
/// In this mode, the browser chrome (address bar, toolbars) is already hidden
/// by the OS. The app is effectively always in fullscreen, so no gate or
/// DOM Fullscreen API calls are needed.
/// {@endtemplate}
class PwaStandaloneStrategy implements FullscreenStrategy {
  /// {@macro pwa_standalone_strategy}
  PwaStandaloneStrategy();

  final _notifier = ValueNotifier<bool>(true); // Always fullscreen

  @override
  String get name => 'PwaStandalone';

  @override
  ValueListenable<bool> get isFullscreen => _notifier;

  @override
  bool get needsUserGesture => false;

  @override
  Future<bool> enter() async => true;

  @override
  Future<void> exit() async {
    _notifier.value = false;
  }

  @override
  void dispose() {
    _notifier.dispose();
  }

  @override
  GateSetup? setupGate({
    required VoidCallback onSatisfied,
    VoidCallback? onCancel,
  }) =>
      null;

  @override
  void teardownGate() {}
}
