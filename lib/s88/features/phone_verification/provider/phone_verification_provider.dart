import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart'
    show authRepositoryProvider;
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

import 'phone_verification_validators.dart';

/// Status of the verification process with associated data.
///
/// Using sealed class for type-safe pattern matching.
/// Each status can carry its own data (e.g., messages).
sealed class PhoneVerificationStatus {
  const PhoneVerificationStatus();
}

/// Initial state, no action taken yet.
final class Initial extends PhoneVerificationStatus {
  const Initial();
}

/// Requesting OTP from server.
final class RequestingOtp extends PhoneVerificationStatus {
  const RequestingOtp();
}

/// Verifying OTP code.
final class VerifyingOtp extends PhoneVerificationStatus {
  const VerifyingOtp();
}

/// OTP has been sent successfully with server message.
final class OtpSent extends PhoneVerificationStatus {
  final String? message; // Nullable - null if API didn't provide message
  const OtpSent(this.message);
}

/// OTP has been verified successfully.
final class Verified extends PhoneVerificationStatus {
  const Verified();
}

/// Resend OTP was successful with server message.
final class ResendSuccess extends PhoneVerificationStatus {
  final String? message; // Nullable - null if API didn't provide message
  const ResendSuccess(this.message);
}

/// An error occurred during request OTP.
final class RequestOtpFailed extends PhoneVerificationStatus {
  final String message;
  const RequestOtpFailed(this.message);
}

/// An error occurred during resend OTP.
final class ResendOtpFailed extends PhoneVerificationStatus {
  final String message;
  const ResendOtpFailed(this.message);
}

/// An error occurred during OTP verification.
final class VerifyOtpFailed extends PhoneVerificationStatus {
  final String message;
  const VerifyOtpFailed(this.message);
}

/// State for the Account Verification business logic.
///
/// This state focuses on business data and status, not UI presentation.
class PhoneVerificationState {
  final String phoneNumber;
  final PhoneVerificationStatus status;

  const PhoneVerificationState({
    this.phoneNumber = '',
    this.status = const Initial(),
  });

  bool get isProcessing => status is RequestingOtp || status is VerifyingOtp;
  bool get isOtpSent => status is OtpSent;
  bool get isVerified => status is Verified;
  bool get hasError =>
      status is RequestOtpFailed ||
      status is ResendOtpFailed ||
      status is VerifyOtpFailed;

  PhoneVerificationState copyWith({
    String? phoneNumber,
    PhoneVerificationStatus? status,
  }) {
    return PhoneVerificationState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
    );
  }
}

/// Notifier to manage Account Verification logic and state.
class PhoneVerificationNotifier extends StateNotifier<PhoneVerificationState>
    with LoggerMixin {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  PhoneVerificationNotifier({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       super(const PhoneVerificationState());

  /// Validates a phone number using the utility function.
  ///
  /// This is a convenience wrapper that delegates to [validatePhoneNumber].
  String? validatePhone(String? value) => validatePhoneNumber(value);

  /// Validates an OTP code using the utility function.
  ///
  /// This is a convenience wrapper that delegates to [validateOtpCode].
  String? validateOtp(String? value) => validateOtpCode(value);

  /// Sets the current phone number.
  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  /// Handles requesting an OTP for the given phone number.
  Future<bool> requestOtp(String phone) async {
    logInfo('Requesting OTP for $phone');
    state = state.copyWith(status: const RequestingOtp());

    try {
      final msg = await _authRepository.requestOtp(phone);
      state = state.copyWith(
        phoneNumber: phone,
        status: OtpSent(msg), // Pass null if API didn't provide message
      );
      logInfo('OTP sent successfully: $msg');
      return true;
    } catch (e, stackTrace) {
      logError('Error requesting OTP', e, stackTrace);
      final errorMsg =
          (e is AuthFailure ? e.errorMessage : null) ?? e.toString();
      state = state.copyWith(status: RequestOtpFailed(errorMsg));
      return false;
    }
  }

  /// Handles verifying the OTP code.
  Future<bool> verifyOtp(String otp) async {
    logInfo('Verifying OTP');
    state = state.copyWith(status: const VerifyingOtp());

    try {
      await _userRepository.verifyPhone(
        phoneNumber: state.phoneNumber,
        otp: otp,
      );
      state = state.copyWith(status: const Verified());
      logInfo('Account activated successfully for ${state.phoneNumber}');
      return true;
    } catch (e, stackTrace) {
      logError('Error verifying OTP', e, stackTrace);
      final errorMsg =
          (e is UserFailure ? e.errorMessage : null) ?? e.toString();
      state = state.copyWith(status: VerifyOtpFailed(errorMsg));
      return false;
    }
  }

  /// Handles resending the OTP.
  Future<bool> resendOtp() async {
    logInfo('Resending OTP to ${state.phoneNumber}');

    try {
      final msg = await _authRepository.requestOtp(state.phoneNumber);
      state = state.copyWith(
        status: ResendSuccess(msg),
      ); // Pass null if API didn't provide message
      logInfo('OTP resent successfully: $msg');
      return true;
    } catch (e, stackTrace) {
      logError('Error resending OTP', e, stackTrace);
      final errorMsg =
          (e is AuthFailure ? e.errorMessage : null) ?? e.toString();
      state = state.copyWith(status: ResendOtpFailed(errorMsg));
      return false;
    }
  }

  /// Clears the current status.
  void clearStatus() {
    state = state.copyWith(status: const Initial());
  }

  /// Resets the verification flow to the beginning.
  void reset() {
    state = const PhoneVerificationState();
  }
}

/// Provider for the Account Verification state and logic.
final phoneVerificationProvider =
    StateNotifierProvider.autoDispose<
      PhoneVerificationNotifier,
      PhoneVerificationState
    >((ref) {
      return PhoneVerificationNotifier(
        authRepository: ref.watch(authRepositoryProvider),
        userRepository: ref.watch(userRepositoryProvider),
      );
    });
