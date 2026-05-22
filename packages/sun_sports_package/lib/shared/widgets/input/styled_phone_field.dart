import 'package:flutter/material.dart';

import 'styled_text_field.dart';

/// {@template styled_phone_field}
/// A traditional text input field with styling matching [StyledPinput].
///
/// Used for non-PIN inputs like phone numbers, passwords, or general text.
/// Provides the same visual consistency as [StyledPinput] while supporting
/// standard [TextFormField] features.
///
/// Example:
/// ```dart
/// StyledPhoneField(
///   controller: _phoneController,
///   label: const Text('Phone Number'),
///   hintText: '+84 xxx xxx xxx',
///   errorText: _phoneError,
///   validator: (value) => _validatePhone(value),
/// )
/// ```
/// {@endtemplate}
class StyledPhoneField extends StatelessWidget {
  /// {@macro styled_phone_field}
  const StyledPhoneField({
    super.key,
    this.isEnabled = true,
    this.controller,
    this.label,
    this.errorText,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Whether the field is enabled. Defaults to true.
  final bool isEnabled;

  /// Optional label widget displayed above the input.
  final Widget? label;

  /// Error text to display below the input.
  final String? errorText;

  /// Called when the text value changes.
  final ValueChanged<String>? onChanged;

  /// Validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// Initial value for the text field.
  final String? initialValue;

  /// Hint text displayed when the field is empty.
  final String? hintText;

  /// Whether to obscure the text (for passwords). Defaults to false.
  final bool obscureText;

  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return StyledTextField(
      controller: controller,
      initialValue: initialValue,
      label: label,
      hintText: hintText,
      errorText: errorText,
      obscureText: obscureText,
      enabled: isEnabled,
      onChanged: onChanged,
      onSubmitted: onFieldSubmitted,
      validator: validator,
      prefix: const SizedBox.square(dimension: 14),
    );
  }
}
