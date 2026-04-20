import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Extension to provide helpers for [DeviceOrientation].
extension DeviceOrientationX on DeviceOrientation {
  /// Whether this orientation is a portrait variant.
  bool get isPortrait =>
      this == DeviceOrientation.portraitUp || this == DeviceOrientation.portraitDown;

  /// Whether this orientation is a landscape variant.
  bool get isLandscape =>
      this == DeviceOrientation.landscapeLeft || this == DeviceOrientation.landscapeRight;
}

/// Constant groupings for [DeviceOrientation].
class DeviceOrientations {
  /// Common grouping for both portrait orientations.
  static const portrait = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  /// Common grouping for both landscape orientations.
  static const landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// Common grouping for all 4 orientations.
  static const both = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
}

/// Defines presentation-level UI behavior when the screen is active.
class ScreenUiPolicy {
  /// Creates a new [ScreenUiPolicy].
  const ScreenUiPolicy({
    this.immersive = false,
  });

  /// Hide status and bottom navigation bars (fullscreen).
  final bool immersive;
}

/// A complete policy for how a screen should behave regarding its orientation.
class OrientationPolicy {
  /// Creates a new [OrientationPolicy].
  const OrientationPolicy({
    required this.targets,
    this.screenUi = const ScreenUiPolicy(),
    this.blockOnWebMismatch = true,
    this.customMismatchViewBuilder,
    this.debugLabel,
  });

  /// The list of requested orientation targets.
  final List<DeviceOrientation> targets;

  /// Presentation rules (e.g. immersive mode).
  final ScreenUiPolicy screenUi;

  /// If the current actual orientation mismatched with [targets],
  /// Should we block it on Web?
  final bool blockOnWebMismatch;

  /// Optional customizable mismatch view
  /// If provided, this builder will be used instead of the default mismatch view.
  final WidgetBuilder? customMismatchViewBuilder;

  /// A label to help identify this policy in logs.
  final String? debugLabel;

  /// Whether any allowed target is landscape.
  bool get allowsLandscape => targets.any((t) => t.isLandscape);

  /// Whether any allowed target is portrait.
  bool get allowsPortrait => targets.any((t) => t.isPortrait);

  /// Whether it supports both portrait and landscape.
  bool get isAdaptive => allowsLandscape && allowsPortrait;
}

/// Status of the application process.
enum OrientationStatus {
  /// No action is being taken.
  idle,

  /// Currently applying the policy to the platform.
  applying,

  /// Current layout orientation matches the policy target.
  matched,

  /// Current layout orientation does NOT match the policy target.
  mismatched,

  /// The screen is blocked due to orientation mismatch.
  blocked,
}

/// Result returned from applying a policy.
class OrientationViewState {
  /// Creates a new [OrientationViewState].
  const OrientationViewState({
    required this.policy,
    required this.status,
    required this.matched,
    required this.canControlPlatform,
    this.message,
  });

  /// The policy that was applied.
  final OrientationPolicy policy;

  /// Current status of the controller.
  final OrientationStatus status;

  /// Whether the target orientation is currently matched by the UI.
  final bool matched;

  /// Whether the current platform supports programmatic orientation control.
  final bool canControlPlatform;

  /// Optional message for debugging.
  final String? message;
}
