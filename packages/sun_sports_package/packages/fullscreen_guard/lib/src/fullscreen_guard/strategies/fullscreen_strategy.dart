import 'package:flutter/foundation.dart';

/// {@template gate_setup}
/// Describes how the gate overlay should behave for a specific strategy.
/// {@endtemplate}
@immutable
class GateSetup {
  /// {@macro gate_setup}
  const GateSetup({
    this.requiresNativeSwipe = false,
  });

  /// Whether the strategy requires disabling Flutter's pointer events and
  /// using a native HTML overlay to capture vertical touch gestures.
  ///
  /// Currently only true for iOS Safari Minimal UI trick.
  final bool requiresNativeSwipe;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GateSetup &&
          runtimeType == other.runtimeType &&
          requiresNativeSwipe == other.requiresNativeSwipe;

  @override
  int get hashCode => requiresNativeSwipe.hashCode;
}

/// {@template fullscreen_strategy}
/// Abstraction for a specific method of achieving fullscreen on a platform.
///
/// Each strategy encapsulates the platform-specific APIs and quirks required
/// to enter and exit fullscreen mode.
///
/// Lifecycle:
/// 1. Created by a factory.
/// 2. [setupGate] called when the gate is active (optional).
/// 3. [enter] called when the user proceeds past the gate.
/// 4. [exit] / [teardownGate] called when clearing the gate.
/// 5. [dispose] called when the controller is destroyed.
/// {@endtemplate}
abstract class FullscreenStrategy {
  /// Strategy name for logging.
  String get name;

  /// Reactive fullscreen state.
  ///
  /// Strategies are responsible for listening to platform events (e.g., DOM
  /// `fullscreenchange`) and updating this value.
  ValueListenable<bool> get isFullscreen;

  /// Whether this strategy requires a user gesture to activate.
  ///
  /// - `true`: The gate overlay must be shown.
  /// - `false`: The gate is auto-satisfied, entering fullscreen immediately.
  bool get needsUserGesture;

  /// Requests to enter fullscreen mode.
  ///
  /// Returns `true` if the request was successful, `false` otherwise.
  Future<bool> enter();

  /// Exits fullscreen mode and restores original state.
  Future<void> exit();

  /// Configures strategy-specific gate behavior (e.g. native HTML overlays).
  ///
  /// [onSatisfied] should be called when the gate is dismissed by the user.
  /// [onCancel] should be called if the user cancels via an HTML-side UI.
  ///
  /// Returns a [GateSetup] if custom behavior is needed, or `null` for a
  /// pure-Flutter gate.
  GateSetup? setupGate({
    required VoidCallback onSatisfied,
    VoidCallback? onCancel,
  }) {
    return null;
  }

  /// Cleans up any resources created in [setupGate].
  void teardownGate() {}

  /// Releases event listeners and internal state.
  void dispose();
}
