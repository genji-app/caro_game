import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

// =============================================================================
// ENUMS
// =============================================================================

/// Button size variants for [SecondaryButton]
enum SecondaryButtonSize {
  xs(
    minimumSize: Size(28, 28),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  sm(
    minimumSize: Size(36, 36),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  md(
    minimumSize: Size(40, 40),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  ),
  lg(
    minimumSize: Size(44, 44),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  ),
  xl(
    minimumSize: Size(48, 48),
    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
  );

  const SecondaryButtonSize({required this.minimumSize, required this.padding});

  final Size minimumSize;
  final EdgeInsetsGeometry padding;

  TextStyle get textStyle => switch (this) {
    xs || sm => AppTextStyles.buttonSmall(),
    md || lg || xl => AppTextStyles.buttonMedium(),
  }.copyWith(height: 1.2);

  static BorderRadius borderRadius = BorderRadius.circular(100.0);
  static OutlinedBorder shape = RoundedRectangleBorder(
    borderRadius: borderRadius,
  );
}

// =============================================================================
// PRIVATE COLOR SPECIFICATIONS
// =============================================================================

/// Button theme variants for [SecondaryButton]
enum SecondaryButtonTheme {
  yellow,
  gray;

  static const Color _disabledBackground = AppColorStyles.backgroundQuaternary;
  static const Color _disabledForeground = AppColorStyles.contentQuaternary;
  static const Color _focusBorderColor = AppColors.yellow500;

  WidgetStateProperty<Color?> get backgroundColorStates => switch (this) {
    yellow => WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledBackground,
      WidgetState.pressed: AppColors.yellow300.withValues(alpha: 0.04),
      WidgetState.hovered: AppColors.yellow300.withValues(alpha: 0.12),
      WidgetState.focused: AppColors.yellow300.withValues(alpha: 0.12),
      WidgetState.any: AppColors.yellow300.withValues(alpha: 0.08),
    }),
    gray => const WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledBackground,
      WidgetState.pressed: AppColors.gray600,
      WidgetState.hovered: AppColors.gray500,
      WidgetState.focused: AppColors.gray600,
      WidgetState.any: AppColors.gray600,
    }),
  };

  WidgetStateProperty<Color?> get foregroundColorStates => switch (this) {
    yellow => const WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledForeground,
      WidgetState.any: AppColors.yellow200,
    }),
    gray => const WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: _disabledForeground,
      WidgetState.any: AppColorStyles.contentPrimary,
    }),
  };

  WidgetStateProperty<BorderSide?> get borderSideStates =>
      const WidgetStateProperty<BorderSide?>.fromMap({
        WidgetState.focused: BorderSide(color: _focusBorderColor),
        WidgetState.any: BorderSide.none,
      });
}

// =============================================================================
// MAIN WIDGET
// =============================================================================

/// Secondary button with yellow or gray styling.
///
/// ## Usage:
/// ```dart
/// // Yellow variant (default)
/// SecondaryButton.yellow(
///   size: SecondaryButtonSize.md,
///   onPressed: () {},
///   label: Text('Click'),
/// )
///
/// // Gray variant
/// SecondaryButton.gray(
///   size: SecondaryButtonSize.lg,
///   onPressed: () {},
///   label: Text('Click'),
/// )
///
/// // Custom style with full width
/// SecondaryButton.yellow(
///   size: SecondaryButtonSize.lg,
///   onPressed: () {},
///   label: Text('Click'),
///   style: SecondaryButton.styleFrom(
///     minimumSize: Size(double.infinity, SecondaryButton.heightFor(SecondaryButtonSize.lg)),
///   ),
/// )
/// ```
///
/// ## Merge behavior:
/// When you pass a custom [style], it will be merged with the default style.
/// The custom style takes precedence for non-null properties.
///
/// **Important**: If you override `backgroundColor` or `foregroundColor`,
/// you will lose the state-aware colors (hover, pressed, focused, disabled).
/// To maintain state-awareness with custom colors, use the widget parameters
/// or create your own [WidgetStateProperty] in [ButtonStyle.copyWith].
///
/// ## Getting default sizes:
/// ```dart
/// final height = SecondaryButton.heightFor(SecondaryButtonSize.lg); // 44.0
/// final padding = SecondaryButton.paddingFor(SecondaryButtonSize.md);
/// ```
class SecondaryButton extends StatelessWidget {
  // ========================================
  // Constructors
  // ========================================

  const SecondaryButton.yellow({
    super.key,
    this.size = SecondaryButtonSize.md,
    this.onPressed,
    this.label,
    this.focusNode,
    this.autofocus = false,
    this.style,
  }) : theme = SecondaryButtonTheme.yellow;

  const SecondaryButton.gray({
    super.key,
    this.size = SecondaryButtonSize.md,
    this.onPressed,
    this.label,
    this.focusNode,
    this.autofocus = false,
    this.style,
  }) : theme = SecondaryButtonTheme.gray;

  // ========================================
  // Properties
  // ========================================

  /// Button size (xs, sm, md, lg, xl). Default is [SecondaryButtonSize.md].
  final SecondaryButtonSize size;

  final VoidCallback? onPressed;
  final Widget? label;
  final FocusNode? focusNode;
  final bool autofocus;
  final SecondaryButtonTheme theme;

  /// Custom button style that will be merged with the default style.
  ///
  /// Use [SecondaryButton.styleFrom] to create a style that matches
  /// the button's default styling conventions.
  ///
  /// **Merge behavior:**
  /// - Non-null properties from [style] override the defaults
  /// - Null properties fall back to the default style
  /// - Colors from [styleFrom] will override state-aware colors
  final ButtonStyle? style;

  // ========================================
  // Static helpers - Public API for size specs
  // ========================================

  /// Gets the default height for a specific button size.
  ///
  /// Usage:
  /// ```dart
  /// final height = SecondaryButton.heightFor(SecondaryButtonSize.lg); // 44.0
  /// ```
  static double heightFor(SecondaryButtonSize size) => size.minimumSize.height;

  /// Gets the default minimum size for a specific button size.
  ///
  /// Usage:
  /// ```dart
  /// final minSize = SecondaryButton.minimumSizeFor(SecondaryButtonSize.lg); // Size(44, 44)
  /// ```
  static Size minimumSizeFor(SecondaryButtonSize size) => size.minimumSize;

  /// Gets the default padding for a specific button size.
  ///
  /// Usage:
  /// ```dart
  /// final padding = SecondaryButton.paddingFor(SecondaryButtonSize.md);
  /// ```
  static EdgeInsetsGeometry paddingFor(SecondaryButtonSize size) =>
      size.padding;

  /// Gets the default text style for a specific button size.
  static TextStyle textStyleFor(SecondaryButtonSize size) => size.textStyle;

  /// Border radius for all SecondaryButton instances.
  static BorderRadius borderRadius = SecondaryButtonSize.borderRadius;

  // ========================================
  // Static style builder
  // ========================================

  /// Creates a [ButtonStyle] for overriding specific properties.
  ///
  /// This method creates a sparse ButtonStyle containing only the properties
  /// you specify. Properties you don't specify remain null, allowing them
  /// to inherit from the widget's default style during merge.
  ///
  /// **Note**: When you override `backgroundColor` or `foregroundColor`,
  /// you will lose state-aware color changes (hover, pressed effects).
  /// If you only need to change size/padding, leave colors null.
  ///
  /// Usage:
  /// ```dart
  /// // Override only minimumSize, keep default colors
  /// SecondaryButton.yellow(
  ///   style: SecondaryButton.styleFrom(
  ///     minimumSize: Size(double.infinity, 44),
  ///   ),
  /// )
  ///
  /// // Override colors (loses state-awareness)
  /// SecondaryButton.yellow(
  ///   style: SecondaryButton.styleFrom(
  ///     backgroundColor: Colors.red,
  ///     foregroundColor: Colors.white,
  ///   ),
  /// )
  /// ```
  static ButtonStyle styleFrom({
    // Size - these are commonly overridden
    Size? minimumSize,
    Size? maximumSize,
    Size? fixedSize,
    EdgeInsetsGeometry? padding,

    // Colors - WARNING: overriding these loses state-awareness
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    Color? overlayColor,
    Color? shadowColor,
    Color? surfaceTintColor,

    // Border
    BorderSide? side,

    // Shape
    OutlinedBorder? shape,
    double? elevation,

    // Text
    TextStyle? textStyle,

    // Other
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    // Create a sparse ButtonStyle with only the specified properties.
    // Null properties will inherit from the default style during merge.
    return ButtonStyle(
      minimumSize: minimumSize != null
          ? WidgetStatePropertyAll<Size?>(minimumSize)
          : null,
      maximumSize: maximumSize != null
          ? WidgetStatePropertyAll<Size?>(maximumSize)
          : null,
      fixedSize: fixedSize != null
          ? WidgetStatePropertyAll<Size?>(fixedSize)
          : null,
      padding: padding != null
          ? WidgetStatePropertyAll<EdgeInsetsGeometry?>(padding)
          : null,
      backgroundColor: backgroundColor != null
          ? WidgetStatePropertyAll<Color?>(backgroundColor)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStatePropertyAll<Color?>(foregroundColor)
          : null,
      overlayColor: overlayColor != null
          ? WidgetStatePropertyAll<Color?>(overlayColor)
          : null,
      shadowColor: shadowColor != null
          ? WidgetStatePropertyAll<Color?>(shadowColor)
          : null,
      surfaceTintColor: surfaceTintColor != null
          ? WidgetStatePropertyAll<Color?>(surfaceTintColor)
          : null,
      side: side != null ? WidgetStatePropertyAll<BorderSide?>(side) : null,
      shape: shape != null
          ? WidgetStatePropertyAll<OutlinedBorder?>(shape)
          : null,
      elevation: elevation != null
          ? WidgetStatePropertyAll<double?>(elevation)
          : null,
      textStyle: textStyle != null
          ? WidgetStatePropertyAll<TextStyle?>(textStyle)
          : null,
      mouseCursor: enabledMouseCursor != null || disabledMouseCursor != null
          ? WidgetStateProperty<MouseCursor?>.fromMap({
              WidgetState.disabled: disabledMouseCursor,
              WidgetState.any: enabledMouseCursor,
            })
          : null,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

  // ========================================
  // Build
  // ========================================

  @override
  Widget build(BuildContext context) {
    // Create default style with all properties set
    final defaultStyle = ButtonStyle(
      // Size properties
      minimumSize: WidgetStatePropertyAll<Size?>(size.minimumSize),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry?>(size.padding),

      // Appearance
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: const WidgetStatePropertyAll<Color?>(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll<Color?>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double?>(0),
      shape: WidgetStatePropertyAll<OutlinedBorder?>(SecondaryButtonSize.shape),
      textStyle: WidgetStatePropertyAll<TextStyle?>(size.textStyle),

      // State-aware colors (these are the key properties)
      backgroundColor: theme.backgroundColorStates,
      foregroundColor: theme.foregroundColorStates,
      side: theme.borderSideStates,
    );

    // Merge: custom style properties override default style properties
    // Only non-null properties from [style] will override
    final mergedStyle = defaultStyle.merge(style);

    return ElevatedButton(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      style: mergedStyle,
      child: label ?? const SizedBox.shrink(),
    );
  }
}
