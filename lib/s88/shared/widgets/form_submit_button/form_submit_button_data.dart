import 'package:flutter/material.dart';

/// {@template form_submit_button_data}
/// Data model used for rendering [FormSubmitButton] across different states.
///
/// This model bundles all UI properties into a single object, allowing
/// the [FormControlBuilder] to remain decoupled from the widget itself.
/// {@endtemplate}
class FormSubmitButtonData {
  /// Creates a form submit button data object.
  const FormSubmitButtonData({
    required this.text,
    this.loadingIndicatorSize = 18.0,
    this.loadingIndicatorStroke = 2.0,
    this.size,
  });

  /// Text displayed on the button.
  final String text;

  /// Size of the loading indicator.
  final double loadingIndicatorSize;

  /// Stroke width of the loading indicator.
  final double loadingIndicatorStroke;

  /// Optional explicit size for the button.
  final Size? size;
}
