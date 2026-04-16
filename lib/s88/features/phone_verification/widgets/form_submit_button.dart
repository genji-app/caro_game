// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
// import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

// // =============================================================================
// // BUTTON STATE ENUM
// // =============================================================================

// /// {@template form_submit_button_state}
// /// Represents the current state of the form submit button.
// ///
// /// - [idle]: Initial state, button is ready to be pressed
// /// - [disabled]: Button is disabled (form is invalid or conditions not met)
// /// - [processing]: Button is processing the submission
// /// - [success]: Submission was successful (optional state)
// /// - [error]: Submission failed (optional state)
// /// {@endtemplate}
// enum FormControlState {
//   /// Button is ready to be pressed.
//   idle,

//   /// Button is disabled (form invalid or conditions not met).
//   disabled,

//   /// Button is processing the submission.
//   processing,

//   /// Submission was successful.
//   success,

//   /// Submission failed.
//   error,
// }

// // =============================================================================
// // BUTTON CONTROLLER
// // =============================================================================

// /// {@template form_submit_button_controller}
// /// Controller for [FormSubmitButton] to programmatically control button state
// /// and trigger submission.
// ///
// /// Allows external control of the button without relying on state management.
// ///
// /// Example:
// /// ```dart
// /// final controller = FormControlController();
// ///
// /// // Trigger submission programmatically
// /// controller.submit();
// ///
// /// // Change state programmatically
// /// controller.setState(FormControlState.processing);
// ///
// /// // Reset to idle
// /// controller.reset();
// ///
// /// // Dispose when done
// /// controller.dispose();
// /// ```
// /// {@endtemplate}
// class FormControlController extends ChangeNotifier {
//   /// {@macro form_submit_button_controller}
//   FormControlController({FormControlState initialState = FormControlState.idle}) : _state = initialState;

//   FormControlState _state;
//   VoidCallback? _submitCallback;

//   /// Current state of the button.
//   FormControlState get state => _state;

//   /// Sets the button state.
//   ///
//   /// This will trigger a rebuild of the button with the new state.
//   void setState(FormControlState newState) {
//     if (_state != newState) {
//       _state = newState;
//       notifyListeners();
//     }
//   }

//   /// Resets the button to idle state.
//   void reset() {
//     setState(FormControlState.idle);
//   }

//   /// Triggers the button submission programmatically.
//   ///
//   /// This will call the onPressed callback if the button is in idle state.
//   void submit() {
//     if (_state == FormControlState.idle && _submitCallback != null) {
//       _submitCallback!();
//     }
//   }

//   /// Internal method to register the submit callback.
//   void _registerSubmitCallback(VoidCallback callback) {
//     _submitCallback = callback;
//   }

//   /// Internal method to unregister the submit callback.
//   void _unregisterSubmitCallback() {
//     _submitCallback = null;
//   }
// }

// // =============================================================================
// // BUTTON STYLE ENUM
// // =============================================================================

// /// {@template form_submit_button_style}
// /// Visual style variants for [FormSubmitButton].
// ///
// /// - [primaryYellow]: Yellow shine button style (default)
// /// - [primaryGray]: Gray shine button style
// /// - [secondary]: Secondary button style - uses [SecondaryButton.yellow] for all states
// ///   with built-in disabled styling and loading indicator
// /// {@endtemplate}
// enum FormSubmitButtonStyle {
//   /// Primary yellow style with shine effect.
//   primaryYellow,

//   /// Primary gray style with shine effect.
//   primaryGray,

//   /// Secondary button style (yellow variant).
//   ///
//   /// Uses [SecondaryButton.yellow] for all states:
//   /// - Idle: Enabled secondary button
//   /// - Disabled: Disabled secondary button
//   /// - Processing: Disabled secondary button with loading indicator
//   /// - Success: Disabled secondary button with check icon
//   /// - Error: Disabled secondary button with error icon
//   secondary,
// }

// // =============================================================================
// // MAIN WIDGET
// // =============================================================================

// /// {@template form_submit_button}
// /// A flexible, stateful submit button for forms with multiple states.
// ///
// /// Handles common form submission UI states including idle, disabled,
// /// processing, success, and error. Provides visual feedback for each state
// /// and prevents double-submission.
// ///
// /// ## Features:
// /// - Automatic state management
// /// - Loading indicator during processing
// /// - Success/error visual feedback (optional)
// /// - Prevents double-submission
// /// - Customizable appearance
// /// - Easy to test and maintain
// ///
// /// ## Example:
// /// ```dart
// /// FormSubmitButton(
// ///   text: 'Submit',
// ///   state: _isFormValid ? FormControlState.idle : FormControlState.disabled,
// ///   onPressed: () async {
// ///     final success = await _submitForm();
// ///     return success;
// ///   },
// /// )
// /// ```
// /// {@endtemplate}
// class FormSubmitButton extends HookWidget {
//   /// {@macro form_submit_button}
//   const FormSubmitButton({
//     required this.text,
//     super.key,
//     this.controller,
//     this.state = FormControlState.idle,
//     this.onPressed,
//     this.size = const Size(double.infinity, 44.0),
//     this.style = FormSubmitButtonStyle.primaryYellow,
//     this.loadingIndicatorSize = 18.0,
//     this.loadingIndicatorStroke = 2.0,
//     this.animationDuration = const Duration(milliseconds: 200),
//     this.successDuration = const Duration(seconds: 1),
//     this.errorDuration = const Duration(seconds: 2),
//     this.resetOnSuccess = false,
//     this.resetOnError = true,
//     this.idleBuilder,
//     this.disabledBuilder,
//     this.processingBuilder,
//     this.successBuilder,
//     this.errorBuilder,
//   });

//   /// Text displayed on the button.
//   final String text;

//   /// Optional controller to programmatically control the button.
//   ///
//   /// If provided, the controller's state will override the [state] parameter.
//   final FormControlController? controller;

//   /// Current state of the button.
//   final FormControlState state;

//   /// Callback when button is pressed.
//   ///
//   /// Should return a [Future<bool>] indicating success (true) or failure (false).
//   /// If null, button will be disabled.
//   final Future<bool> Function()? onPressed;

//   /// Button size (width, height). Defaults to Size(double.infinity, 44.0).
//   final Size size;

//   /// Button style. Defaults to [FormSubmitButtonStyle.primaryYellow].
//   final FormSubmitButtonStyle style;

//   /// Size of the loading indicator. Defaults to 18.
//   final double loadingIndicatorSize;

//   /// Stroke width of the loading indicator. Defaults to 2.
//   final double loadingIndicatorStroke;

//   /// Animation duration for state transitions. Defaults to 200ms.
//   final Duration animationDuration;

//   /// Duration to show success state before resetting. Defaults to 1 second.
//   final Duration successDuration;

//   /// Duration to show error state before resetting. Defaults to 2 seconds.
//   final Duration errorDuration;

//   /// Whether to reset to idle state after success. Defaults to false.
//   final bool resetOnSuccess;

//   /// Whether to reset to idle state after error. Defaults to true.
//   final bool resetOnError;

//   /// Custom builder for idle state button.
//   ///
//   /// If provided, this will be used instead of the default idle button.
//   /// The [VoidCallback] parameter is the onPressed handler.
//   final Widget Function(VoidCallback onPressed)? idleBuilder;

//   /// Custom builder for disabled state button.
//   ///
//   /// If provided, this will be used instead of the default disabled button.
//   final Widget Function()? disabledBuilder;

//   /// Custom builder for processing state button.
//   ///
//   /// If provided, this will be used instead of the default processing button.
//   final Widget Function()? processingBuilder;

//   /// Custom builder for success state button.
//   ///
//   /// If provided, this will be used instead of the default success button.
//   final Widget Function()? successBuilder;

//   /// Custom builder for error state button.
//   ///
//   /// If provided, this will be used instead of the default error button.
//   final Widget Function()? errorBuilder;

//   @override
//   Widget build(BuildContext context) {
//     final internalState = useState(state);
//     final isProcessing = useState(false);

//     // Sync controller state with internal state
//     useEffect(() {
//       if (controller != null) {
//         void listener() {
//           if (!isProcessing.value) {
//             internalState.value = controller!.state;
//           }
//         }

//         controller!.addListener(listener);
//         // Initialize with controller's state
//         internalState.value = controller!.state;

//         return () => controller!.removeListener(listener);
//       }
//       return null;
//     }, [controller]);

//     // Sync external state with internal state when not processing (and no controller)
//     useEffect(() {
//       if (controller == null && !isProcessing.value) {
//         internalState.value = state;
//       }
//       return null;
//     }, [state]);

//     // Handle auto-reset for success/error states
//     useEffect(() {
//       if (internalState.value == FormControlState.success && resetOnSuccess) {
//         Future<void>.delayed(successDuration, () {
//           if (context.mounted) {
//             if (controller != null) {
//               controller!.reset();
//             } else {
//               internalState.value = FormControlState.idle;
//             }
//           }
//         });
//       } else if (internalState.value == FormControlState.error && resetOnError) {
//         Future<void>.delayed(errorDuration, () {
//           if (context.mounted) {
//             if (controller != null) {
//               controller!.reset();
//             } else {
//               internalState.value = FormControlState.idle;
//             }
//           }
//         });
//       }
//       return null;
//     }, [internalState.value]);

//     Future<void> handlePress() async {
//       if (internalState.value == FormControlState.disabled ||
//           internalState.value == FormControlState.processing ||
//           onPressed == null) {
//         return;
//       }

//       isProcessing.value = true;
//       if (controller != null) {
//         controller!.setState(FormControlState.processing);
//       } else {
//         internalState.value = FormControlState.processing;
//       }

//       try {
//         final success = await onPressed!();

//         if (context.mounted) {
//           final newState = success ? FormControlState.success : FormControlState.error;
//           if (controller != null) {
//             controller!.setState(newState);
//           } else {
//             internalState.value = newState;
//           }
//         }
//       } catch (e) {
//         if (context.mounted) {
//           if (controller != null) {
//             controller!.setState(FormControlState.error);
//           } else {
//             internalState.value = FormControlState.error;
//           }
//         }
//       } finally {
//         isProcessing.value = false;
//       }
//     }

//     // Register submit callback with controller
//     useEffect(() {
//       if (controller != null) {
//         controller!._registerSubmitCallback(handlePress);
//         return () => controller!._unregisterSubmitCallback();
//       }
//       return null;
//     }, [controller, onPressed]);

//     return SizedBox.fromSize(
//       size: size,
//       child: AnimatedSwitcher(
//         duration: animationDuration,
//         child: _buildButtonForState(internalState.value, handlePress),
//       ),
//     );
//   }

//   Widget _buildButtonForState(FormControlState currentState, VoidCallback onTap) {
//     return switch (currentState) {
//       FormControlState.idle =>
//         idleBuilder != null
//             ? KeyedSubtree(key: const ValueKey('submit_idle'), child: idleBuilder!(onTap))
//             : _IdleButton(key: const ValueKey('submit_idle'), text: text, style: style, onPressed: onTap),
//       FormControlState.disabled =>
//         disabledBuilder != null
//             ? KeyedSubtree(key: const ValueKey('submit_disabled'), child: disabledBuilder!())
//             : _DisabledButton(key: const ValueKey('submit_disabled'), text: text, style: style),
//       FormControlState.processing =>
//         processingBuilder != null
//             ? KeyedSubtree(key: const ValueKey('submit_processing'), child: processingBuilder!())
//             : _ProcessingButton(
//                 key: const ValueKey('submit_processing'),
//                 style: style,
//                 indicatorSize: loadingIndicatorSize,
//                 indicatorStroke: loadingIndicatorStroke,
//               ),
//       FormControlState.success =>
//         successBuilder != null
//             ? KeyedSubtree(key: const ValueKey('submit_success'), child: successBuilder!())
//             : _SuccessButton(key: const ValueKey('submit_success'), text: text, style: style),
//       FormControlState.error =>
//         errorBuilder != null
//             ? KeyedSubtree(key: const ValueKey('submit_error'), child: errorBuilder!())
//             : _ErrorButton(key: const ValueKey('submit_error'), text: text, style: style),
//     };
//   }
// }

// // =============================================================================
// // BUTTON VARIANTS
// // =============================================================================

// class _IdleButton extends StatelessWidget {
//   const _IdleButton({required this.text, required this.style, required this.onPressed, super.key});

//   final String text;
//   final FormSubmitButtonStyle style;
//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     // For secondary style, use SecondaryButton
//     if (style == FormSubmitButtonStyle.secondary) {
//       return SizedBox.expand(
//         child: SecondaryButton.yellow(size: SecondaryButtonSize.lg, onPressed: onPressed, label: Text(text)),
//       );
//     }

//     // For primary styles, use ShineButton
//     final shineStyle = switch (style) {
//       FormSubmitButtonStyle.primaryYellow => ShineButtonStyle.primaryYellow,
//       FormSubmitButtonStyle.primaryGray => ShineButtonStyle.primaryGray,
//       FormSubmitButtonStyle.secondary => ShineButtonStyle.primaryYellow, // Fallback (won't be reached)
//     };

//     return SizedBox.expand(
//       child: ShineButton(text: text, style: shineStyle, width: double.infinity, onPressed: onPressed),
//     );
//   }
// }

// class _DisabledButton extends StatelessWidget {
//   const _DisabledButton({required this.text, required this.style, super.key});

//   final String text;
//   final FormSubmitButtonStyle style;

//   @override
//   Widget build(BuildContext context) {
//     // Disabled state uses SecondaryButton, style parameter not needed
//     return SizedBox.expand(
//       child: SecondaryButton.yellow(
//         size: SecondaryButtonSize.lg,
//         onPressed: null, // Disabled state
//         label: Text(text),
//       ),
//     );
//   }
// }

// class _ProcessingButton extends StatelessWidget {
//   const _ProcessingButton({required this.style, required this.indicatorSize, required this.indicatorStroke, super.key});

//   final FormSubmitButtonStyle style;
//   final double indicatorSize;
//   final double indicatorStroke;

//   @override
//   Widget build(BuildContext context) {
//     // Processing state uses SecondaryButton, style parameter not needed
//     return SizedBox.expand(
//       child: SecondaryButton.yellow(
//         size: SecondaryButtonSize.lg,
//         onPressed: null, // Disabled during processing
//         label: SizedBox.square(
//           dimension: indicatorSize,
//           child: CircularProgressIndicator(strokeWidth: indicatorStroke, color: AppColorStyles.contentTertiary),
//         ),
//       ),
//     );
//   }
// }

// class _SuccessButton extends StatelessWidget {
//   const _SuccessButton({required this.text, required this.style, super.key});

//   final String text;
//   final FormSubmitButtonStyle style;

//   @override
//   Widget build(BuildContext context) {
//     // For secondary style, use SecondaryButton
//     if (style == FormSubmitButtonStyle.secondary) {
//       return SizedBox.expand(
//         child: SecondaryButton.yellow(
//           size: SecondaryButtonSize.lg,
//           onPressed: null,
//           label: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [const Icon(Icons.check_circle, size: 20), const SizedBox(width: 8), Text(text)],
//           ),
//         ),
//       );
//     }

//     // For primary styles, use ShineButton
//     final shineStyle = switch (style) {
//       FormSubmitButtonStyle.primaryYellow => ShineButtonStyle.primaryYellow,
//       FormSubmitButtonStyle.primaryGray => ShineButtonStyle.primaryGray,
//       FormSubmitButtonStyle.secondary => ShineButtonStyle.primaryYellow, // Fallback
//     };

//     return SizedBox.expand(
//       child: ShineButton(
//         text: text,
//         style: shineStyle,
//         width: double.infinity,
//         onPressed: null,
//         leadingIcon: const Icon(Icons.check_circle, size: 20),
//       ),
//     );
//   }
// }

// class _ErrorButton extends StatelessWidget {
//   const _ErrorButton({required this.text, required this.style, super.key});

//   final String text;
//   final FormSubmitButtonStyle style;

//   @override
//   Widget build(BuildContext context) {
//     // For secondary style, use SecondaryButton
//     if (style == FormSubmitButtonStyle.secondary) {
//       return SizedBox.expand(
//         child: SecondaryButton.yellow(
//           size: SecondaryButtonSize.lg,
//           onPressed: null,
//           label: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [const Icon(Icons.error_outline, size: 20), const SizedBox(width: 8), Text(text)],
//           ),
//         ),
//       );
//     }

//     // For primary styles, use ShineButton
//     final shineStyle = switch (style) {
//       FormSubmitButtonStyle.primaryYellow => ShineButtonStyle.primaryYellow,
//       FormSubmitButtonStyle.primaryGray => ShineButtonStyle.primaryGray,
//       FormSubmitButtonStyle.secondary => ShineButtonStyle.primaryYellow, // Fallback
//     };

//     return SizedBox.expand(
//       child: ShineButton(
//         text: text,
//         style: shineStyle,
//         width: double.infinity,
//         onPressed: null,
//         leadingIcon: const Icon(Icons.error_outline, size: 20),
//       ),
//     );
//   }
// }
