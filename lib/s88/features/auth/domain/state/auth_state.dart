import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/features/auth/domain/entities/auth_entity.dart';

part 'auth_state.freezed.dart';

/// Authentication state for the application
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthEntity auth) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(
    String message, {
    @Default(false) bool showPopup,
  }) = _Error;

  /// OTP required state - user needs to enter OTP code
  const factory AuthState.otpRequired({
    required String sessionId,
    required String message,
    required String username,
    required String password,
  }) = _OtpRequired;
}

/// Login form state
@freezed
sealed class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String username,
    @Default('') String password,
    String? usernameError,
    String? passwordError,
    @Default(false) bool isSubmitting,
    String? generalError,
  }) = _LoginFormState;
}

/// Register form state
@freezed
sealed class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default('') String username,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String displayName,
    String? usernameError,
    String? passwordError,
    String? confirmPasswordError,
    String? displayNameError,
    @Default(false) bool isSubmitting,
    String? generalError,

    /// Username availability check result
    @Default(UsernameAvailability.unknown)
    UsernameAvailability usernameAvailability,
  }) = _RegisterFormState;
}

/// OTP form state
@freezed
sealed class OtpFormState with _$OtpFormState {
  const factory OtpFormState({
    @Default('') String otp,
    String? otpError,
    @Default(false) bool isSubmitting,
    String? generalError,
  }) = _OtpFormState;
}

/// Username availability status
enum UsernameAvailability {
  /// Not checked yet
  unknown,

  /// Checking in progress
  checking,

  /// Username is available
  available,

  /// Username is already taken
  taken,

  /// Username exists on another brand
  existsOnOtherBrand,
}
