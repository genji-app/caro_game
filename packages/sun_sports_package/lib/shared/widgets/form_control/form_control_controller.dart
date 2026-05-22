import 'package:flutter/foundation.dart';
import 'form_control_state.dart';

/// {@template form_control_controller}
/// A controller to programmatically manage the state and submission of a
/// [FormControlBase].
///
/// This controller allows parent widgets or external logic to:
/// - Change the visual state (e.g., [FormControlController.disable]).
/// - Manually trigger the submit callback.
/// - Observe state changes via [addListener].
///
/// Example:
/// ```dart
/// final controller = FormControlController();
///
/// // Initializing state
/// controller.disable();
///
/// // Later...
/// controller.enable();
///
/// // Programmatically submit
/// controller.submit();
/// ```
/// {@endtemplate}
class FormControlController extends ChangeNotifier {
  /// {@macro form_control_controller}
  FormControlController({FormControlState initialState = FormControlState.idle})
    : _state = initialState;

  FormControlState _state;
  VoidCallback? _submitCallback;

  /// Current state of the control.
  FormControlState get state => _state;

  /// Whether the control is currently in idle state.
  bool get isIdle => _state == FormControlState.idle;

  /// Whether the control is currently in disabled state.
  bool get isDisabled => _state == FormControlState.disabled;

  /// Whether the control is currently in processing state.
  bool get isProcessing => _state == FormControlState.processing;

  /// Sets the control state.
  ///
  /// This will trigger a rebuild of the control with the new state.
  void setState(FormControlState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Disables the control.
  void disable() {
    setState(FormControlState.disabled);
  }

  /// Enables the control (sets it to idle).
  void enable() {
    setState(FormControlState.idle);
  }

  /// Resets the control to idle state.
  void reset() {
    enable();
  }

  /// Triggers the control submission programmatically.
  ///
  /// This will call the submission callback if the control is in idle state.
  void submit() {
    if (_state == FormControlState.idle && _submitCallback != null) {
      _submitCallback!();
    }
  }

  /// Internal method to register the submission callback.
  void registerSubmitCallback(VoidCallback callback) {
    _submitCallback = callback;
  }

  /// Internal method to unregister the submission callback.
  void unregisterSubmitCallback() {
    _submitCallback = null;
  }
}
