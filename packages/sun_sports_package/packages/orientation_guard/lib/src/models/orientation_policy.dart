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

/// A complete policy for how a screen should behave regarding its orientation.
///
/// Note: Immersive/Fullscreen rules are now handled by `fullscreen_guard` package.
class OrientationPolicy {
  /// Common policy for portrait-only screens.
  static const portrait = OrientationPolicy(
    targets: DeviceOrientations.portrait,
    debugLabel: 'portrait',
  );

  /// Common policy for landscape-only screens.
  static const landscape = OrientationPolicy(
    targets: DeviceOrientations.landscape,
    debugLabel: 'landscape',
  );

  /// Common policy for adaptive screens (both).
  static const adaptive = OrientationPolicy(
    targets: DeviceOrientations.both,
    blockOnMismatch: false,
    debugLabel: 'adaptive',
  );

  /// Creates a new [OrientationPolicy].
  const OrientationPolicy({
    required this.targets,
    this.blockOnMismatch = true,
    this.ignoreMismatchOnDesktop = true,
    this.debugLabel,
  });

  /// The list of requested orientation targets.
  final List<DeviceOrientation> targets;

  /// If the current actual orientation mismatched with [targets],
  /// should the UI be blocked/covered with a rotate prompt?
  ///
  /// Usually `true` for fixed-orientation games/videos.
  final bool blockOnMismatch;

  /// Whether to ignore mismatch checks on Desktop platforms (Native or Web-Desktop).
  ///
  /// On Desktop, orientation is determined by window resizing rather than
  /// device rotation. Showing a rotate prompt is usually confusing for
  /// Desktop users.
  ///
  /// Defaults to `true`.
  final bool ignoreMismatchOnDesktop;

  /// A label to help identify this policy in logs.
  final String? debugLabel;

  /// Whether any allowed target is landscape.
  bool get allowsLandscape => targets.any((t) => t.isLandscape);

  /// Whether any allowed target is portrait.
  bool get allowsPortrait => targets.any((t) => t.isPortrait);

  /// Whether it supports both portrait and landscape.
  bool get isAdaptive => allowsLandscape && allowsPortrait;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationPolicy &&
          runtimeType == other.runtimeType &&
          _listEquals(targets, other.targets) &&
          blockOnMismatch == other.blockOnMismatch &&
          ignoreMismatchOnDesktop == other.ignoreMismatchOnDesktop &&
          debugLabel == other.debugLabel;

  @override
  int get hashCode =>
      Object.hashAll(targets) ^
      blockOnMismatch.hashCode ^
      ignoreMismatchOnDesktop.hashCode ^
      debugLabel.hashCode;

  bool _listEquals(List<Object?>? a, List<Object?>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'OrientationPolicy(targets: $targets, blockOnMismatch: $blockOnMismatch, ignoreMismatchOnDesktop: $ignoreMismatchOnDesktop, label: $debugLabel)';
}
