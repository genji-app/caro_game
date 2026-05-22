import 'package:flutter/material.dart';

/// {@template platform_system_ui_mode}
/// Controls the visibility of system bars (status bar and navigation bar).
///
/// This is a platform-agnostic abstraction over Flutter's `SystemUiMode`.
/// {@endtemplate}
enum PlatformSystemUiMode {
  /// System bars are visible, and the app is rendered behind them.
  ///
  /// Maps to `SystemUiMode.edgeToEdge` on native platforms.
  edgeToEdge,

  /// System bars are hidden, and the app occupies the full screen.
  ///
  /// Maps to `SystemUiMode.immersive` on native platforms.
  immersive,

  /// Manual control over bar visibility.
  ///
  /// Maps to `SystemUiMode.manual` on native platforms.
  manual,
}

/// {@template platform_ui_config}
/// Immutable configuration for platform UI state.
///
/// Describes the desired system UI chrome: bar visibility (via [systemUiMode])
/// and optional color/brightness theming for native status and navigation bars.
///
/// ## Preset constructors
///
/// - [PlatformUiConfig.systemDefault] — resets to OS-provided defaults.
/// - [PlatformUiConfig.immersive] — hides all bars.
/// - [PlatformUiConfig.branded] — transparent bars with light icons.
/// - [PlatformUiConfig.splash] — hides bars using manual mode (no immersive).
///
/// ## Composition
///
/// Configs can be merged using the [merge] method. Fields in the [other] config
/// will override fields in this config if they are non-null.
/// {@endtemplate}
@immutable
class PlatformUiConfig {
  /// {@macro platform_ui_config}
  const PlatformUiConfig({
    this.systemUiMode,
    this.statusBarColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
    this.navigationBarColor,
    this.navigationBarIconBrightness,
    this.debugLabel = 'Default',
  });

  /// Resets the system UI to the closest approximation of OS defaults.
  ///
  /// - Mode: [PlatformSystemUiMode.edgeToEdge]
  /// - Status bar: Transparent (let OS manage)
  /// - Navigation bar: Black (Flutter default)
  ///
  /// The [brightness] parameter adjusts icon colors for readability.
  const PlatformUiConfig.systemDefault({
    Brightness brightness = Brightness.dark,
    String debugLabel = 'SystemDefault',
  })  : systemUiMode = PlatformSystemUiMode.edgeToEdge,
        statusBarColor = null,
        statusBarIconBrightness =
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness = brightness,
        navigationBarColor = const Color(0xFF000000),
        navigationBarIconBrightness =
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        debugLabel = debugLabel;

  /// Hides all system bars.
  const PlatformUiConfig.immersive({String debugLabel = 'Immersive'})
      : systemUiMode = PlatformSystemUiMode.immersive,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  /// Shows system bars with the app rendered behind them.
  const PlatformUiConfig.edgeToEdge({String debugLabel = 'EdgeToEdge'})
      : systemUiMode = PlatformSystemUiMode.edgeToEdge,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  /// Application-branded style: transparent bars with light icons.
  const PlatformUiConfig.branded({String debugLabel = 'Branded'})
      : systemUiMode = PlatformSystemUiMode.edgeToEdge,
        statusBarColor = const Color(0x00000000),
        statusBarIconBrightness = Brightness.light,
        statusBarBrightness = Brightness.dark,
        navigationBarColor = const Color(0x00000000),
        navigationBarIconBrightness = Brightness.light,
        debugLabel = debugLabel;

  /// Hides bars using manual mode (useful for splash screens).
  const PlatformUiConfig.splash({String debugLabel = 'Splash'})
      : systemUiMode = PlatformSystemUiMode.manual,
        statusBarColor = null,
        statusBarIconBrightness = null,
        statusBarBrightness = null,
        navigationBarColor = null,
        navigationBarIconBrightness = null,
        debugLabel = debugLabel;

  /// Updates only the colors and brightness without changing the visibility mode.
  const PlatformUiConfig.styleOnly({
    this.statusBarColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
    this.navigationBarColor,
    this.navigationBarIconBrightness,
    String debugLabel = 'StyleOnly',
  })  : systemUiMode = null,
        debugLabel = debugLabel;

  /// Desired bar visibility mode.
  final PlatformSystemUiMode? systemUiMode;

  /// Status bar background color (native only).
  final Color? statusBarColor;

  /// Status bar icon brightness (Android only).
  final Brightness? statusBarIconBrightness;

  /// Status bar background brightness (iOS only).
  ///
  /// Set to [Brightness.dark] for light icons (white text),
  /// or [Brightness.light] for dark icons (black text).
  final Brightness? statusBarBrightness;

  /// Navigation bar background color (native only).
  final Color? navigationBarColor;

  /// Navigation bar icon brightness (native only).
  final Brightness? navigationBarIconBrightness;

  /// Label for debugging and logging.
  final String debugLabel;

  /// Whether this config specifies any overlay color or brightness settings.
  bool get hasOverlayStyle =>
      statusBarColor != null ||
      statusBarIconBrightness != null ||
      statusBarBrightness != null ||
      navigationBarColor != null ||
      navigationBarIconBrightness != null;

  /// Merges this configuration with another.
  ///
  /// Non-null fields in [other] will override fields in this configuration.
  PlatformUiConfig merge(PlatformUiConfig other) {
    return PlatformUiConfig(
      systemUiMode: other.systemUiMode ?? systemUiMode,
      statusBarColor: other.statusBarColor ?? statusBarColor,
      statusBarIconBrightness: other.statusBarIconBrightness ?? statusBarIconBrightness,
      statusBarBrightness: other.statusBarBrightness ?? statusBarBrightness,
      navigationBarColor: other.navigationBarColor ?? navigationBarColor,
      navigationBarIconBrightness: other.navigationBarIconBrightness ?? navigationBarIconBrightness,
      debugLabel: '${debugLabel}+${other.debugLabel}',
    );
  }

  /// Creates a copy with optional field overrides.
  PlatformUiConfig copyWith({
    PlatformSystemUiMode? systemUiMode,
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? statusBarBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
    String? debugLabel,
  }) {
    return PlatformUiConfig(
      systemUiMode: systemUiMode ?? this.systemUiMode,
      statusBarColor: statusBarColor ?? this.statusBarColor,
      statusBarIconBrightness: statusBarIconBrightness ?? this.statusBarIconBrightness,
      statusBarBrightness: statusBarBrightness ?? this.statusBarBrightness,
      navigationBarColor: navigationBarColor ?? this.navigationBarColor,
      navigationBarIconBrightness: navigationBarIconBrightness ?? this.navigationBarIconBrightness,
      debugLabel: debugLabel ?? this.debugLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformUiConfig &&
          runtimeType == other.runtimeType &&
          systemUiMode == other.systemUiMode &&
          statusBarColor == other.statusBarColor &&
          statusBarIconBrightness == other.statusBarIconBrightness &&
          statusBarBrightness == other.statusBarBrightness &&
          navigationBarColor == other.navigationBarColor &&
          navigationBarIconBrightness == other.navigationBarIconBrightness &&
          debugLabel == other.debugLabel;

  @override
  int get hashCode =>
      systemUiMode.hashCode ^
      statusBarColor.hashCode ^
      statusBarIconBrightness.hashCode ^
      statusBarBrightness.hashCode ^
      navigationBarColor.hashCode ^
      navigationBarIconBrightness.hashCode ^
      debugLabel.hashCode;

  @override
  String toString() => 'PlatformUiConfig('
      'systemUiMode: $systemUiMode, '
      'statusBarColor: $statusBarColor, '
      'statusBarIconBrightness: $statusBarIconBrightness, '
      'statusBarBrightness: $statusBarBrightness, '
      'navigationBarColor: $navigationBarColor, '
      'navigationBarIconBrightness: $navigationBarIconBrightness, '
      'debugLabel: $debugLabel)';
}
