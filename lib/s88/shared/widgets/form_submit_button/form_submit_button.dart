import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/widgets/form_control/form_control.dart';
import 'builders/form_submit_button_builder_factory.dart';
import 'form_submit_button_data.dart';
import 'form_submit_button_style.dart';

/// Callback for custom builder functions.
typedef FormSubmitButtonBuilderCallback =
    Widget Function(
      BuildContext context,
      FormSubmitButtonData data,
      FormControlController controller,
    );

/// {@template form_submit_button}
/// A specialized submit button that implements the [FormControlBase] pattern.
///
/// It provides high-level configurations for common form submission needs:
/// - **Style Factory**: Integrated with [FormSubmitButtonStyle] for quick themes.
/// - **Custom Overrides**: Allows granular builder overrides for any specific
/// [FormControlState].
/// - **Life-cycle Hooks**: Provides [onInit] for early setup and [onSubmit] for
/// the async action.
///
/// Example:
/// ```dart
/// FormSubmitButton(
///   text: 'Sign In',
///   onInit: (controller) => controller.disable(),
///   onSubmit: () async {
///     final success = await authService.login();
///     return success;
///   },
/// )
/// ```
/// {@endtemplate}
class FormSubmitButton extends FormControlBase<FormSubmitButtonData> {
  /// {@macro form_submit_button}
  const FormSubmitButton({
    required this.text,
    super.key,
    super.controller,
    super.state,
    super.onSubmit,
    this.style = FormSubmitButtonStyle.primaryYellow,
    this.loadingIndicatorSize = 18.0,
    this.loadingIndicatorStroke = 2.0,
    super.animationDuration,
    super.resetOnSuccess,
    super.successDuration,
    super.resetOnError,
    super.errorDuration,
    super.onInit,
    super.onStateChange,
    this.size,
    this.customBuildIdle,
    this.customBuildDisabled,
    this.customBuildProcessing,
    this.customBuildSuccess,
    this.customBuildError,
  });

  /// Button style. Defaults to [FormSubmitButtonStyle.primaryYellow].
  final FormSubmitButtonStyle style;

  /// Text displayed on the button.
  final String text;

  /// Size of the loading indicator.
  final double loadingIndicatorSize;

  /// Stroke width of the loading indicator.
  final double loadingIndicatorStroke;

  /// Optional explicit size for the button.
  final Size? size;

  /// Custom builder for Idle state.
  final FormSubmitButtonBuilderCallback? customBuildIdle;

  /// Custom builder for Disabled state.
  final FormSubmitButtonBuilderCallback? customBuildDisabled;

  /// Custom builder for Processing state.
  final FormSubmitButtonBuilderCallback? customBuildProcessing;

  /// Custom builder for Success state.
  final FormSubmitButtonBuilderCallback? customBuildSuccess;

  /// Custom builder for Error state.
  final FormSubmitButtonBuilderCallback? customBuildError;

  @override
  FormSubmitButtonData get data => FormSubmitButtonData(
    text: text,
    loadingIndicatorSize: loadingIndicatorSize,
    loadingIndicatorStroke: loadingIndicatorStroke,
    size: size,
  );

  @override
  FormControlBuilder<FormSubmitButtonData> getBuilder() {
    final defaultBuilder = FormSubmitButtonBuilderFactory.getBuilder(style);

    // Wrap default builder with custom overrides
    return _CustomizableBuilder(
      defaultBuilder: defaultBuilder,
      customBuildIdle: customBuildIdle,
      customBuildDisabled: customBuildDisabled,
      customBuildProcessing: customBuildProcessing,
      customBuildSuccess: customBuildSuccess,
      customBuildError: customBuildError,
    );
  }

  @override
  FormControlBaseState<FormSubmitButtonData> createState() =>
      _FormSubmitButtonState();
}

class _FormSubmitButtonState
    extends FormControlBaseState<FormSubmitButtonData> {
  @override
  Widget build(BuildContext context) {
    final Widget child = super.build(context);
    final size = (widget as FormSubmitButton).size;
    if (size != null) {
      return SizedBox.fromSize(size: size, child: child);
    }
    return child;
  }
}

/// A proxy builder that executes custom callbacks if provided,
/// otherwise delegates to the default builder.
class _CustomizableBuilder implements FormControlBuilder<FormSubmitButtonData> {
  const _CustomizableBuilder({
    required this.defaultBuilder,
    this.customBuildIdle,
    this.customBuildDisabled,
    this.customBuildProcessing,
    this.customBuildSuccess,
    this.customBuildError,
  });

  final FormControlBuilder<FormSubmitButtonData> defaultBuilder;
  final FormSubmitButtonBuilderCallback? customBuildIdle;
  final FormSubmitButtonBuilderCallback? customBuildDisabled;
  final FormSubmitButtonBuilderCallback? customBuildProcessing;
  final FormSubmitButtonBuilderCallback? customBuildSuccess;
  final FormSubmitButtonBuilderCallback? customBuildError;

  @override
  Widget buildIdle(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    if (customBuildIdle != null) {
      return customBuildIdle!(context, data, controller);
    }
    return defaultBuilder.buildIdle(context, data, controller);
  }

  @override
  Widget buildDisabled(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    if (customBuildDisabled != null) {
      return customBuildDisabled!(context, data, controller);
    }
    return defaultBuilder.buildDisabled(context, data, controller);
  }

  @override
  Widget buildProcessing(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    if (customBuildProcessing != null) {
      return customBuildProcessing!(context, data, controller);
    }
    return defaultBuilder.buildProcessing(context, data, controller);
  }

  @override
  Widget buildSuccess(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    if (customBuildSuccess != null) {
      return customBuildSuccess!(context, data, controller);
    }
    return defaultBuilder.buildSuccess(context, data, controller);
  }

  @override
  Widget buildError(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    if (customBuildError != null) {
      return customBuildError!(context, data, controller);
    }
    return defaultBuilder.buildError(context, data, controller);
  }
}
