import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_control_builder.dart';
import 'form_control_controller.dart';
import 'form_control_state.dart';

/// {@template form_control_base}
/// An abstract base widget that provides a robust foundation for building
/// state-aware form controls.
///
/// It encapsulates common logic including:
/// - **State Lifecycle**: Transitions between [FormControlState] values.
/// - **Controller Integration**: Syncing with [FormControlController].
/// - **Submission Logic**: Handling [onSubmit] with error catching and auto-reset.
/// - **Animations**: Smoothly switching between states using [AnimatedSwitcher].
///
/// Implementers should:
/// 1. Define a data model [T] for UI properties.
/// 2. Provide a [FormControlBuilder] via [getBuilder].
/// 3. Provide the current [data] instance.
///
/// [T] is the data type used by the builder to render the UI.
/// {@endtemplate}
abstract class FormControlBase<T> extends ConsumerStatefulWidget {
  /// {@macro form_control_base}
  const FormControlBase({
    super.key,
    this.controller,
    this.state = FormControlState.idle,
    this.onSubmit,
    this.animationDuration = const Duration(milliseconds: 200),
    this.successDuration = const Duration(seconds: 1),
    this.errorDuration = const Duration(seconds: 2),
    this.resetOnSuccess = false,
    this.resetOnError = true,
    this.onInit,
    this.onStateChange,
  });

  /// The controller to programmatically control the state and action.
  final FormControlController? controller;

  /// Callback for optional initialization logic.
  final void Function(FormControlController controller)? onInit;

  /// The initial state of the control.
  final FormControlState state;

  /// Callback triggered when the submission is initiated (e.g. button pressed).
  ///
  /// **Contract:**
  /// - Must return `true` for success, `false` for error/failure.
  /// - Should handle its own exceptions and return `false` on error.
  /// - If an exception is thrown, the control will remain in processing state.
  ///
  /// **Example:**
  /// ```dart
  /// onSubmit: () async {
  ///   try {
  ///     await apiService.submit();
  ///     return true;
  ///   } catch (e) {
  ///     // Handle error (log, show toast, etc.)
  ///     return false;
  ///   }
  /// }
  /// ```
  final Future<bool> Function()? onSubmit;

  /// Duration of the state transition animation.
  final Duration animationDuration;

  /// Duration to show the success state before resetting (if [resetOnSuccess] is true).
  final Duration successDuration;

  /// Duration to show the error state before resetting (if [resetOnError] is true).
  final Duration errorDuration;

  /// Whether to automatically reset to [FormControlState.idle] after success.
  final bool resetOnSuccess;

  /// Whether to automatically reset to [FormControlState.idle] after error.
  final bool resetOnError;

  /// Callback triggered whenever the state changes.
  final void Function(FormControlState state)? onStateChange;

  /// Returns the builder used to render the control.
  FormControlBuilder<T> getBuilder();

  /// Returns the data required by the builder to render the UI.
  T get data;

  @override
  FormControlBaseState<T> createState();
}

/// State class for [FormControlBase].
abstract class FormControlBaseState<T>
    extends ConsumerState<FormControlBase<T>> {
  late FormControlController _localController;
  late FormControlState _internalState;
  FormControlController? _previousController;

  FormControlController get _effectiveController =>
      widget.controller ?? _localController;

  @override
  void initState() {
    super.initState();
    _localController = FormControlController(initialState: widget.state);
    _internalState = widget.state;

    // Setup controller listener
    _setupControllerListener(_effectiveController);

    // Register submit callback
    _effectiveController.registerSubmitCallback(_handleSubmit);

    // Call onInit callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInit?.call(_effectiveController);
    });
  }

  @override
  void didUpdateWidget(covariant FormControlBase<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller change
    final newEffectiveController = widget.controller ?? _localController;
    if (_previousController != newEffectiveController) {
      _previousController?.removeListener(_onControllerStateChanged);
      _setupControllerListener(newEffectiveController);
      newEffectiveController.registerSubmitCallback(_handleSubmit);
    }

    // Sync with prop state change
    if (oldWidget.state != widget.state && _internalState != widget.state) {
      _updateState(widget.state);
    }

    // Re-register submit callback if onSubmit changed
    if (oldWidget.onSubmit != widget.onSubmit) {
      _effectiveController.registerSubmitCallback(_handleSubmit);
    }
  }

  void _setupControllerListener(FormControlController controller) {
    _previousController?.removeListener(_onControllerStateChanged);
    controller.addListener(_onControllerStateChanged);
    _previousController = controller;

    // Initial sync
    if (_internalState != controller.state) {
      _internalState = controller.state;
    }
  }

  void _onControllerStateChanged() {
    if (_internalState != _effectiveController.state) {
      setState(() {
        _internalState = _effectiveController.state;
      });
      widget.onStateChange?.call(_internalState);
    }
  }

  void _updateState(FormControlState newState) {
    if (!mounted) return;
    setState(() {
      _internalState = newState;
    });
    _effectiveController.setState(newState);
    widget.onStateChange?.call(newState);
  }

  Future<void> _handleSubmit() async {
    if (widget.onSubmit == null) return;
    if (_internalState != FormControlState.idle) return;

    _updateState(FormControlState.processing);

    final success = await widget.onSubmit!();
    if (success) {
      _updateState(FormControlState.success);
      if (widget.resetOnSuccess) {
        await Future<void>.delayed(widget.successDuration);
        _updateState(FormControlState.idle);
      }
    } else {
      _updateState(FormControlState.error);
      if (widget.resetOnError) {
        await Future<void>.delayed(widget.errorDuration);
        _updateState(FormControlState.idle);
      }
    }
  }

  @override
  void dispose() {
    _previousController?.removeListener(_onControllerStateChanged);
    _effectiveController.unregisterSubmitCallback();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _internalState;
    final builder = widget.getBuilder();
    final uiData = widget.data;

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey<FormControlState>(currentState),
        child: _buildChild(
          context,
          currentState,
          builder,
          uiData,
          _effectiveController,
        ),
      ),
    );
  }

  Widget _buildChild(
    BuildContext context,
    FormControlState currentState,
    FormControlBuilder<T> builder,
    T data,
    FormControlController controller,
  ) {
    switch (currentState) {
      case FormControlState.idle:
        return builder.buildIdle(context, data, controller);
      case FormControlState.disabled:
        return builder.buildDisabled(context, data, controller);
      case FormControlState.processing:
        return builder.buildProcessing(context, data, controller);
      case FormControlState.success:
        return builder.buildSuccess(context, data, controller);
      case FormControlState.error:
        return builder.buildError(context, data, controller);
    }
  }
}
