/// {@template form_submit_button_style}
/// Defines the visual style variants available for [FormSubmitButton].
///
/// These variants determine which concrete [FormControlBuilder] implementation
/// will be used by the [FormSubmitButtonBuilderFactory].
/// {@endtemplate}
enum FormSubmitButtonStyle {
  /// Primary yellow style with shine effect.
  primaryYellow,

  /// Secondary button style (yellow variant).
  ///
  /// Uses SecondaryButton.yellow for all states:
  /// - Idle: Enabled secondary button
  /// - Disabled: Disabled secondary button
  /// - Processing: Disabled secondary button with loading indicator
  /// - Success: Disabled secondary button with check icon
  /// - Error: Disabled secondary button with error icon
  secondary,
}
