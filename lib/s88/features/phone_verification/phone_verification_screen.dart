import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/features/phone_verification/phone_verification.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class PhoneVerificationScreen extends ConsumerWidget {
  const PhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(phoneVerificationProvider);
    final notifier = ref.read(phoneVerificationProvider.notifier);
    final currentStep = _deriveStepFromStatus(state.status);

    // Setup toast listener
    _setupToastListener(ref, context);

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtActivateAccount),
      bodyPadding: ProfileNavigationScaffold.kBodyHorizontalPadding,
      body: SingleChildScrollView(
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildContent(context, currentStep, state, notifier)],
        ),
      ),
    );
  }

  /// Setup toast listener for state changes
  void _setupToastListener(WidgetRef ref, BuildContext context) {
    ref.listen(phoneVerificationProvider, (previous, next) {
      VerificationToastHandler.handleStatusChange(context, next.status);
    });
  }

  /// Build main content based on current step
  Widget _buildContent(
    BuildContext context,
    VerificationStep currentStep,
    PhoneVerificationState state,
    PhoneVerificationNotifier notifier,
  ) {
    return switch (currentStep) {
      VerificationStep.success => _buildSuccessView(state),
      VerificationStep.phone => _buildPhoneInputView(notifier),
      VerificationStep.otp => _buildOtpInputView(state, notifier),
    };
  }

  /// Build success view
  Widget _buildSuccessView(PhoneVerificationState state) {
    return VerifySuccessBanner(phoneNumber: state.phoneNumber);
  }

  /// Build phone input view
  Widget _buildPhoneInputView(PhoneVerificationNotifier notifier) {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VerificationDescription(),
        VerificationCard(
          title: I18n.txtVerifyByPhone,
          subtitle: I18n.msgEnterPhoneToReceiveOTP,
          form: PhoneInputForm(
            onSubmit: notifier.requestOtp,
            validator: notifier.validatePhone,
          ),
        ),
      ],
    );
  }

  /// Build OTP input view
  Widget _buildOtpInputView(
    PhoneVerificationState state,
    PhoneVerificationNotifier notifier,
  ) {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VerificationDescription(),
        VerificationCard(
          title: I18n.txtVerifyByPhone,
          subtitle:
              '${I18n.msgEnterOTPSentTo} ${formatPhoneForPrivacy(state.phoneNumber)}',
          form: OtpInputForm(
            validator: notifier.validateOtp,
            onResend: notifier.resendOtp,
            onSubmit: notifier.verifyOtp,
          ),
        ),
      ],
    );
  }
}

/// Steps in the account verification UI flow.
///
/// This enum represents the visual states of the verification screen,
/// not the business logic states.
enum VerificationStep {
  /// Initial step: Enter phone number.
  phone,

  /// Second step: Enter OTP verified code.
  otp,

  /// Final step: Success confirmation.
  success,
}

/// Derives the UI step from business logic status.
///
/// This function maps business logic states to presentation states,
/// keeping the concerns properly separated.
///
/// **State Machine Logic:**
/// - `initial`, `requestingOtp`, `requestOtpFailed` → Show phone input
/// - `otpSent`, `resendSuccess`, `resendOtpFailed`, `verifyingOtp`, `verifyOtpFailed` → Show OTP input
/// - `verified` → Show success banner
VerificationStep _deriveStepFromStatus(PhoneVerificationStatus status) {
  return switch (status) {
    // Phone input step: Initial state, requesting OTP, or request failed
    Initial() ||
    RequestingOtp() ||
    RequestOtpFailed() => VerificationStep.phone,

    // OTP input step: OTP sent, resending, verifying, or any OTP-related failures
    OtpSent() ||
    ResendSuccess() ||
    ResendOtpFailed() ||
    VerifyingOtp() ||
    VerifyOtpFailed() => VerificationStep.otp,

    // Success step: OTP verified
    Verified() => VerificationStep.success,
  };
}

/// Handler for verification status changes and toast notifications.
///
/// This class encapsulates the logic for showing appropriate toasts
/// based on the verification status changes.
class VerificationToastHandler {
  /// Handle status changes and show appropriate toasts.
  ///
  /// This method uses pattern matching to extract messages from status
  /// and displays success or error toasts accordingly.
  static void handleStatusChange(
    BuildContext context,
    PhoneVerificationStatus status,
  ) {
    switch (status) {
      // Error states - show error toast
      case RequestOtpFailed(:final message):
      case ResendOtpFailed(:final message):
      case VerifyOtpFailed(:final message):
        AppToast.showError(context, message: message);

      // OTP sent - show success toast with fallback
      case OtpSent(:final message):
        _showSuccessToast(context, message, I18n.msgOTPSent);

      // OTP resent - show success toast with fallback
      case ResendSuccess(:final message):
        _showSuccessToast(context, message, I18n.msgOTPResent);

      // No toast for these states
      case Initial():
      case RequestingOtp():
      case VerifyingOtp():
      case Verified():
        break;
    }
  }

  /// Show success toast with fallback message.
  ///
  /// If the API didn't provide a message (null), uses the fallback message from I18n.
  static void _showSuccessToast(
    BuildContext context,
    String? message,
    String fallback,
  ) {
    AppToast.showSuccess(context, message: message ?? fallback);
  }
}
