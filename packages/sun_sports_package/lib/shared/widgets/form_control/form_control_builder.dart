import 'package:flutter/material.dart';
import 'form_control_controller.dart';

/// {@template form_control_builder}
/// An abstract interface using the **Strategy Pattern** to define how a
/// form control should be rendered for each state in [FormControlState].
///
/// Decoupling the visual representation from the state management logic allows
/// the same logic to support multiple visual styles.
///
/// [T] represents the data model required by the builder to render the UI.
/// {@endtemplate}
abstract class FormControlBuilder<T> {
  /// {@macro form_control_builder}
  const FormControlBuilder();

  /// Builds the idle state control.
  ///
  /// This is the default state when the control is ready for action.
  Widget buildIdle(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  /// Builds the disabled state control.
  ///
  /// This state is shown when conditions are not met for the action.
  Widget buildDisabled(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  /// Builds the processing state control.
  ///
  /// This state is shown while the action is being performed.
  Widget buildProcessing(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  /// Builds the success state control.
  ///
  /// This state is shown when the action completed successfully.
  Widget buildSuccess(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  /// Builds the error state control.
  ///
  /// This state is shown when the action failed.
  Widget buildError(
    BuildContext context,
    T data,
    FormControlController controller,
  );
}
