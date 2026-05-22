/// Defines how the system should identify the current platform.
enum OrientationSystemType {
  /// Automatically detect based on the current platform.
  auto,

  /// Treat the system as a mobile device.
  mobile,

  /// Treat the system as a tablet.
  tablet,

  /// Treat the system as a desktop.
  desktop;

  /// Whether this system type is a mobile or tablet (handheld).
  bool get isHandheld => this == mobile || this == tablet;

  /// Whether this system type is desktop.
  bool get isDesktop => this == desktop;
}

/// Global configuration for orientation guard behavior.
///
/// Pass to [OrientationScope.root] to customize enforcement rules across the app.
class OrientationGuardConfig {
  /// Creates an [OrientationGuardConfig].
  const OrientationGuardConfig({
    this.forceEnforcementOnDesktopWeb = false,
    this.systemType = OrientationSystemType.auto,
  });

  /// When `true`, desktop web browsers are treated like mobile browsers
  /// for orientation mismatch enforcement.
  ///
  /// This is particularly useful during development to test rotation overlays
  /// using Chrome DevTools device emulation.
  ///
  /// In production, this should typically be `false` so that desktop users
  /// are never blocked by orientation overlays even when resizing their windows.
  ///
  /// Defaults to `false`.
  final bool forceEnforcementOnDesktopWeb;

  /// Allows overriding the detected system type.
  ///
  /// This is useful for testing mobile/tablet layouts and behavior on desktop
  /// or for forcing a specific experience regardless of the actual platform.
  ///
  /// Defaults to [OrientationSystemType.auto].
  final OrientationSystemType systemType;

  /// Default production configuration.
  /// Desktop web users will never see orientation overlays.
  static const production = OrientationGuardConfig();

  /// Development/testing configuration.
  /// Enables orientation enforcement on desktop web browsers.
  static const devTesting = OrientationGuardConfig(
    forceEnforcementOnDesktopWeb: true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationGuardConfig &&
          forceEnforcementOnDesktopWeb == other.forceEnforcementOnDesktopWeb &&
          systemType == other.systemType;

  @override
  int get hashCode => Object.hash(forceEnforcementOnDesktopWeb, systemType);

  @override
  String toString() =>
      'OrientationGuardConfig(forceEnforcementOnDesktopWeb: $forceEnforcementOnDesktopWeb, systemType: $systemType)';
}
