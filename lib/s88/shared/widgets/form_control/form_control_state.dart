/// {@template form_control_state}
/// Represents the current state of a form control.
///
/// This enum defines the lifecycle stages of a form control, such as a button
/// or a complex input group, allowing the UI to react to different
/// asynchronous operations.
/// {@endtemplate}
enum FormControlState {
  /// The control is ready for interaction.
  ///
  /// This is typically the default state where the main action is available.
  idle,

  /// The control is disabled and interaction is ignored.
  ///
  /// Usually set when form validation requirements are not yet met.
  disabled,

  /// The control is currently performing an asynchronous operation.
  ///
  /// Often displays a loading indicator or a indeterminate progress state.
  processing,

  /// The initiated action completed successfully.
  ///
  /// Can be used to show a checkmark or a success message before resetting.
  success,

  /// The initiated action encountered an error.
  ///
  /// Useful for displaying error feedback or allowing a retry.
  error,
}
