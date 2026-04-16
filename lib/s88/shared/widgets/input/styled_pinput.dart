import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// {@template styled_pinput}
/// A flexible, styled Pinput wrapper for PIN/OTP inputs.
///
/// Provides a consistent, customizable PIN input field with automatic
/// theme application.
///
/// Example:
/// ```dart
/// StyledPinput(
///   controller: _controller,
///   length: 6,
///   label: const Text('Enter OTP'),
///   errorText: _errorText,
///   validator: (value) => value?.length == 6 ? null : 'Invalid OTP',
///   onCompleted: (pin) => _handleOtpComplete(pin),
/// )
/// ```
/// {@endtemplate}
class StyledPinput extends StatelessWidget {
  /// {@macro styled_pinput}
  const StyledPinput({
    super.key,
    this.controller,
    this.length = 6,
    this.label,
    this.errorText,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.pinWidth,
    this.pinHeight,
    this.textStyle,
    this.backgroundColor,
    this.showCursor = true,
    this.enabled = true,
  });

  /// Controller for the PIN input field.
  final TextEditingController? controller;

  /// Number of PIN digits. Defaults to 6.
  final int length;

  /// Optional label widget displayed above the input.
  final Widget? label;

  /// Error text to display below the input.
  final String? errorText;

  /// Called when the PIN value changes.
  final ValueChanged<String>? onChanged;

  /// Called when all PIN digits are entered.
  final ValueChanged<String>? onCompleted;

  /// Validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// Width of each PIN box. Defaults to 56.
  final double? pinWidth;

  /// Height of each PIN box. Defaults to 56.
  final double? pinHeight;

  /// Text style for PIN digits.
  final TextStyle? textStyle;

  /// Background color for PIN boxes.
  final Color? backgroundColor;

  /// Whether to show the cursor. Defaults to true.
  final bool showCursor;

  /// Whether the input is enabled. Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Create base theme
    final defaultPinTheme = _StyledPinputTheme.createPinTheme(
      width: pinWidth,
      height: pinHeight,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
    );

    // Create focused theme
    final focusedPinTheme = _StyledPinputTheme.createFocusedPinTheme(
      defaultPinTheme,
    );

    // Create submitted theme (same as default)
    final submittedPinTheme = defaultPinTheme;

    // Create error theme
    final errorPinTheme = _StyledPinputTheme.createErrorPinTheme(
      defaultPinTheme,
    );

    // Error widget
    Widget? errorWidget;
    if (errorText != null && errorText!.isNotEmpty) {
      errorWidget = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(errorText!, style: _StyledPinputTheme.errorTextStyle),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (label != null)
          DefaultTextStyle(style: _StyledPinputTheme.labelStyle, child: label!),
        Pinput(
          controller: controller,
          length: length,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          validator: validator,
          onCompleted: onCompleted,
          onChanged: onChanged,
          showCursor: showCursor,
          enabled: enabled,
          errorText: errorText,
          errorTextStyle: _StyledPinputTheme.errorTextStyle,
          cursor: showCursor ? _StyledPinputTheme.createCursor() : null,
        ),
        if (errorWidget != null) errorWidget,
      ],
    );
  }
}

/// Private theme configuration for [StyledPinput].
class _StyledPinputTheme {
  _StyledPinputTheme._();

  /// Border radius for PIN boxes.
  static final borderRadius = BorderRadius.circular(12);

  /// Default border color for PIN boxes.
  static const borderColor = AppColorStyles.borderPrimary;

  /// Border color for error state.
  static const errorColor = AppColors.red500;

  /// Border color for focused state.
  static const focusColor = AppColors.yellow300;

  /// Surface color for content.
  static const surfaceColor = AppColorStyles.contentPrimary;

  /// Background color for PIN boxes.
  static const backgroundColor = Colors.transparent;

  /// Text style for input labels.
  static TextStyle get labelStyle =>
      AppTextStyles.headingXXXSmall(color: surfaceColor);

  /// Default text style for PIN digits.
  static TextStyle get inputTextStyle =>
      AppTextStyles.headingSmall(color: surfaceColor);

  /// Text style for error messages.
  static TextStyle get errorTextStyle =>
      AppTextStyles.paragraphMedium(color: errorColor);

  /// Creates a base [PinTheme] for Pinput widget.
  static PinTheme createPinTheme({
    double? width,
    double? height,
    TextStyle? textStyle,
    Color? backgroundColor,
  }) {
    return PinTheme(
      width: width ?? 56,
      height: height ?? 56,
      textStyle: textStyle ?? inputTextStyle,
      decoration: BoxDecoration(
        color: backgroundColor ?? _StyledPinputTheme.backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
      ),
    );
  }

  /// Creates a focused state [PinTheme] from a base theme.
  static PinTheme createFocusedPinTheme(PinTheme baseTheme) {
    return baseTheme.copyWith(
      decoration: baseTheme.decoration?.copyWith(
        border: Border.all(color: focusColor, width: 2),
      ),
    );
  }

  /// Creates an error state [PinTheme] from a base theme.
  static PinTheme createErrorPinTheme(PinTheme baseTheme) {
    return baseTheme.copyWith(
      decoration: baseTheme.decoration?.copyWith(
        border: Border.all(color: errorColor, width: 2),
      ),
    );
  }

  /// Creates a cursor widget for Pinput.
  static Widget createCursor({double? width, double? height, Color? color}) {
    return Container(
      width: width ?? 2,
      height: height ?? 24,
      decoration: BoxDecoration(
        color: color ?? focusColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
