import 'package:flutter/foundation.dart';

import 'fullscreen_strategy.dart';

/// {@template web_mobile_bypass_strategy}
/// Temporary bypass strategy for Web Mobile (iOS/Android browsers).
///
/// Due to ongoing UI/UX stability issues on mobile browsers, this strategy
/// automatically satisfies the gate to avoid blocking users, while still
/// allowing the app to track a simulated fullscreen state.
/// {@endtemplate}
class WebMobileBypassStrategy implements FullscreenStrategy {
  /// {@macro web_mobile_bypass_strategy}
  WebMobileBypassStrategy();

  final _notifier = ValueNotifier<bool>(true);

  @override
  String get name => 'WebMobileBypass';

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
