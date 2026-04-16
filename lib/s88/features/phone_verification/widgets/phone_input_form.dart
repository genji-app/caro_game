import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import 'package:co_caro_flame/s88/shared/widgets/form_submit_button/form_submit_button_lib.dart';
import 'package:co_caro_flame/s88/shared/widgets/input/input.dart';

/// Logger helper for PhoneInputForm
class _PhoneInputFormLogger with LoggerMixin {}

/// {@template phone_input_form}
/// Form for phone number input with validation and submission.
///
/// Handles phone number input, validation, and submission with proper
/// state management and user feedback.
/// {@endtemplate}
class PhoneInputForm extends ConsumerStatefulWidget {
  /// {@macro phone_input_form}
  const PhoneInputForm({super.key, this.onSubmit, this.validator});

  /// Optional validator for the phone number field.
  final FormFieldValidator<String>? validator;

  /// Callback when form is submitted with valid phone number.
  ///
  /// Should return a [Future<bool>] indicating success (true) or failure (false).
  final Future<bool> Function(String phoneNumber)? onSubmit;

  @override
  ConsumerState<PhoneInputForm> createState() => _PhoneInputFormState();
}

class _PhoneInputFormState extends ConsumerState<PhoneInputForm> {
  final _logger = _PhoneInputFormLogger();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final FormControlController _submitController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _submitController = FormControlController(
      initialState: FormControlState.disabled,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _submitController.dispose();
    super.dispose();
  }

  Future<bool> _handleSubmit() async {
    _logger.logInfo('Phone submission started');

    if (_formKey.currentState?.validate() != true) {
      _logger.logWarning('Phone validation failed');
      return false;
    }

    final phone = _phoneController.text.trim();
    _logger.logInfo(
      'Phone validated successfully: ${phone.substring(0, 3)}***',
    );

    if (widget.validator != null) {
      final error = widget.validator!(phone);
      if (error != null) {
        _logger.logWarning('Phone final validation failed: $error');
        return false;
      }
    }

    if (widget.onSubmit != null) {
      final result = await widget.onSubmit!(phone);
      _logger.logInfo('Phone submission result: $result');
      return result;
    }

    return true;
  }

  void _onPhoneChanged(String value) {
    if (value.isNotEmpty) {
      _submitController.enable();
    } else {
      _submitController.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          StyledPhoneField(
            controller: _phoneController,
            validator: widget.validator,
            hintText: '0932 xxx xxx',
            onChanged: _onPhoneChanged,
          ),
          FormSubmitButton(
            controller: _submitController,
            size: const Size.fromHeight(44),
            text: I18n.txtContinue,
            resetOnError: true,
            resetOnSuccess: true,
            successDuration: Duration.zero,
            errorDuration: Duration.zero,
            onSubmit: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
