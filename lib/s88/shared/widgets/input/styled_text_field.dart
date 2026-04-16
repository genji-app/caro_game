import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// {@template styled_text_field}
/// A styled text input field with consistent theming.
///
/// Provides a reusable text input component with styling matching [StyledPinput].
/// Supports various use cases:
/// - Search inputs
/// - Phone number inputs
/// - Password inputs
/// - General text inputs
///
/// Example:
/// ```dart
/// StyledTextField(
///   controller: _searchController,
///   hintText: 'Search games...',
///   prefixIcon: Icon(Icons.search),
///   onChanged: (value) => _handleSearch(value),
/// )
/// ```
/// {@endtemplate}
class StyledTextField extends StatelessWidget {
  /// {@macro styled_text_field}
  const StyledTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.textStyle,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    this.filled = false,
    this.fillColor,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
    this.hoverColor,
    this.borderRadius,
  });

  // ==========================================================================
  // PROPERTIES
  // ==========================================================================

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Initial value for the text field.
  final String? initialValue;

  /// Optional label widget displayed above the input.
  final Widget? label;

  /// Hint text displayed when the field is empty.
  final String? hintText;

  /// Error text to display below the input.
  final String? errorText;

  /// Icon displayed at the start of the input.
  final Widget? prefixIcon;

  /// Icon displayed at the end of the input.
  final Widget? suffixIcon;

  /// Widget displayed before the input text (inside border).
  final Widget? prefix;

  /// Widget displayed after the input text (inside border).
  final Widget? suffix;

  /// Whether to obscure the text (for passwords). Defaults to false.
  final bool obscureText;

  /// Whether the field is enabled. Defaults to true.
  final bool enabled;

  /// Whether the field is read-only. Defaults to false.
  final bool readOnly;

  /// Maximum number of lines. Defaults to 1.
  final int? maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Text style for input content.
  final TextStyle? textStyle;

  /// Padding inside the input field.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to fill the background. Defaults to false.
  final bool filled;

  /// Background fill color.
  final Color? fillColor;

  /// Called when the text value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// Keyboard type for the input.
  final TextInputType? keyboardType;

  /// Text input action button.
  final TextInputAction? textInputAction;

  /// Whether to autofocus the field. Defaults to false.
  final bool autofocus;

  /// Focus node for the field.
  final FocusNode? focusNode;

  /// Color used when the field is hovered.
  final Color? hoverColor;

  /// Border radius for the field.
  final BorderRadius? borderRadius;

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // Create error widget if needed
    Widget? errorWidget;
    if (errorText != null && errorText!.isNotEmpty) {
      errorWidget = Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(errorText!, style: _StyledTextFieldTheme.errorTextStyle),
      );
    }

    // Create input decoration
    final decoration = _StyledTextFieldTheme.createTextFieldDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefix: prefix,
      suffix: suffix,
      contentPadding: contentPadding,
      filled: filled,
      fillColor: fillColor,
      hoverColor: hoverColor,
      borderRadius: borderRadius,
    ).copyWith(error: errorWidget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (label != null)
          DefaultTextStyle(
            style: _StyledTextFieldTheme.labelStyle,
            child: label!,
          ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          obscuringCharacter: '●',
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          cursorColor: _StyledTextFieldTheme.surfaceColor,
          style: textStyle ?? _StyledTextFieldTheme.inputTextStyle,
          decoration: decoration,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
        ),
        if (errorWidget != null) errorWidget,
      ],
    );
  }
}

/// Private theme configuration for [StyledTextField].
class _StyledTextFieldTheme {
  _StyledTextFieldTheme._();

  /// Border radius for input fields.
  static final borderRadius = BorderRadius.circular(12);

  /// Default border color for input fields.
  static const borderColor = AppColorStyles.borderPrimary;

  /// Border color for error state.
  static const errorColor = AppColors.red500;

  /// Border color for focused state.
  static const focusColor = AppColors.yellow300;

  /// Surface color for content.
  static const surfaceColor = AppColorStyles.contentPrimary;

  /// Background color for input fields.
  static const backgroundColor = Colors.transparent;

  /// Text style for input field labels.
  static TextStyle get labelStyle =>
      AppTextStyles.headingXXXSmall(color: surfaceColor);

  /// Default text style for input content.
  static TextStyle get inputTextStyle =>
      AppTextStyles.paragraphMedium(color: surfaceColor);

  /// Text style for error messages.
  static TextStyle get errorTextStyle =>
      AppTextStyles.paragraphMedium(color: errorColor);

  /// Text style for hint text.
  static TextStyle get hintTextStyle =>
      AppTextStyles.paragraphMedium(color: AppColorStyles.contentTertiary);

  /// Creates a base [InputDecoration] for TextField/TextFormField.
  static InputDecoration createTextFieldDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? prefix,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
    bool filled = false,
    Color? fillColor,
    Color? hoverColor,
    BorderRadius? borderRadius,
  }) {
    const borderSide = BorderSide(color: borderColor);
    final border = OutlineInputBorder(
      borderSide: borderSide,
      borderRadius: borderRadius ?? _StyledTextFieldTheme.borderRadius,
    );

    final errorSide = borderSide.copyWith(color: errorColor, width: 2);
    final focusedSide = borderSide.copyWith(color: focusColor, width: 2);

    final errorBorder = border.copyWith(borderSide: errorSide);
    final focusedBorder = border.copyWith(borderSide: focusedSide);

    return InputDecoration(
      contentPadding: contentPadding,
      fillColor: fillColor ?? backgroundColor,
      filled: filled,
      errorStyle: errorTextStyle,
      hoverColor: hoverColor ?? (filled ? fillColor : focusColor),
      focusColor: focusColor,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      hintText: hintText,
      hintStyle: hintTextStyle,
      iconColor: surfaceColor,
      prefixIconColor: surfaceColor,
      suffixIconColor: surfaceColor,
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: prefixIcon,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8, right: 14),
              child: suffixIcon,
            )
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefix: prefix ?? (prefixIcon == null ? const SizedBox(width: 14) : null),
      suffix: suffix ?? (suffixIcon == null ? const SizedBox(width: 14) : null),
    );
  }
}
