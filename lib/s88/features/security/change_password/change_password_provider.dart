import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/repositories/user_repository/user_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

part 'change_password_provider.freezed.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

/// Password validation constraints
class _PasswordConstraints {
  static const int minLength = 6;
  static const int maxLength = 30;
}

/// Error messages
class _ErrorMessages {
  // Validation errors
  static const String emptyCurrentPassword = 'Vui lòng nhập mật khẩu hiện tại.';
  static const String emptyNewPassword = 'Vui lòng nhập mật khẩu mới.';
  static const String emptyConfirmPassword = 'Vui lòng xác nhận mật khẩu mới.';
  static const String passwordTooShort =
      'Mật khẩu phải có ít nhất ${_PasswordConstraints.minLength} ký tự.';
  static const String passwordTooLong =
      'Mật khẩu không được quá ${_PasswordConstraints.maxLength} ký tự.';
  static const String passwordMismatch = 'Mật khẩu xác nhận không khớp.';
}

// ============================================================================
// STATE
// ============================================================================

enum ChangePasswordStatus { initial, loading, success, failure, invalid }

@freezed
sealed class ChangePasswordState with _$ChangePasswordState {
  const ChangePasswordState._();

  const factory ChangePasswordState({
    @Default(ChangePasswordStatus.initial) ChangePasswordStatus status,
    String? errorMessage,
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
  }) = _ChangePasswordState;

  bool get isLoading => status == ChangePasswordStatus.loading;

  bool get isFormValid =>
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      currentPasswordError == null &&
      newPasswordError == null &&
      confirmPasswordError == null;

  bool get canSubmit => !isLoading && isFormValid;
}

// ============================================================================
// NOTIFIER
// ============================================================================

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState>
    with LoggerMixin {
  ChangePasswordNotifier({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const ChangePasswordState());

  final UserRepository _userRepository;

  // --------------------------------------------------------------------------
  // Public Methods - Field Updates
  // --------------------------------------------------------------------------

  void setCurrentPassword(String value) {
    _updateFieldAndClearErrors(
      (state) => state.copyWith(currentPassword: value),
    );
    _validateCurrentPassword();
  }

  void setNewPassword(String value) {
    _updateFieldAndClearErrors((state) => state.copyWith(newPassword: value));
    _validateNewPassword();

    // Re-validate confirm password if already entered
    if (state.confirmPassword.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void setConfirmPassword(String value) {
    _updateFieldAndClearErrors(
      (state) => state.copyWith(confirmPassword: value),
    );
    _validateConfirmPassword();
  }

  void resetState() => state = const ChangePasswordState();

  // --------------------------------------------------------------------------
  // Public Methods - Form Submission
  // --------------------------------------------------------------------------

  Future<void> submit() async {
    if (state.status == ChangePasswordStatus.loading) return;

    if (!_validateAll()) {
      state = state.copyWith(status: ChangePasswordStatus.invalid);
      return;
    }

    await _performPasswordChange();
  }

  // --------------------------------------------------------------------------
  // Private Helpers - Field Updates
  // --------------------------------------------------------------------------

  /// Clear server error and reset status when user starts typing
  void _updateFieldAndClearErrors(
    ChangePasswordState Function(ChangePasswordState) update,
  ) {
    state = update(
      state,
    ).copyWith(errorMessage: null, status: ChangePasswordStatus.initial);
  }

  // --------------------------------------------------------------------------
  // Private Helpers - Validation (Real-time)
  // --------------------------------------------------------------------------

  void _validateCurrentPassword() {
    // Clear error during typing, full validation happens on submit
    state = state.copyWith(currentPasswordError: null);
  }

  void _validateNewPassword() {
    final error = _getNewPasswordError(state.newPassword);
    state = state.copyWith(newPasswordError: error);
  }

  void _validateConfirmPassword() {
    final error = _getConfirmPasswordError(
      state.confirmPassword,
      state.newPassword,
    );
    state = state.copyWith(confirmPasswordError: error);
  }

  // --------------------------------------------------------------------------
  // Private Helpers - Validation (Submit)
  // --------------------------------------------------------------------------

  /// Validate all fields before submit
  bool _validateAll() {
    final currentError = _getCurrentPasswordError(state.currentPassword);
    final newError = _getNewPasswordError(state.newPassword);
    final confirmError = _getConfirmPasswordError(
      state.confirmPassword,
      state.newPassword,
    );

    state = state.copyWith(
      currentPasswordError: currentError,
      newPasswordError: newError,
      confirmPasswordError: confirmError,
    );

    return currentError == null && newError == null && confirmError == null;
  }

  String? _getCurrentPasswordError(String value) {
    if (value.isEmpty) return _ErrorMessages.emptyCurrentPassword;
    return null;
  }

  String? _getNewPasswordError(String value) {
    if (value.isEmpty) return _ErrorMessages.emptyNewPassword;
    if (value.length < _PasswordConstraints.minLength) {
      return _ErrorMessages.passwordTooShort;
    }
    if (value.length > _PasswordConstraints.maxLength) {
      return _ErrorMessages.passwordTooLong;
    }
    return null;
  }

  String? _getConfirmPasswordError(String confirmValue, String newValue) {
    if (confirmValue.isEmpty) return _ErrorMessages.emptyConfirmPassword;
    if (confirmValue != newValue) return _ErrorMessages.passwordMismatch;
    return null;
  }

  // --------------------------------------------------------------------------
  // Private Helpers - API Calls
  // --------------------------------------------------------------------------

  Future<void> _performPasswordChange() async {
    state = state.copyWith(status: ChangePasswordStatus.loading);
    _logSubmit();

    try {
      await _userRepository.changePassword(
        state.currentPassword,
        state.newPassword,
      );

      logInfo('Password changed successfully');
      _handleSuccess();
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      _handleError(e);
    }
  }

  void _handleSuccess() {
    state = state.copyWith(
      status: ChangePasswordStatus.success,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    );
  }

  void _handleError(Object error) {
    String errorMsg;
    if (error is UserFailure) {
      errorMsg = error.errorMessage ?? error.toString();
    } else {
      errorMsg = error.toString().replaceAll('Exception: ', '');
    }

    state = state.copyWith(
      status: ChangePasswordStatus.failure,
      errorMessage: errorMsg,
    );
  }

  // --------------------------------------------------------------------------
  // Private Helpers - Logging
  // --------------------------------------------------------------------------

  void _logSubmit() {
    logInfo('Submitting...');
    logDebug('Current password length: ${state.currentPassword.length}');
    logDebug('New password length: ${state.newPassword.length}');
  }

  void _logError(Object error, StackTrace? stackTrace) {
    logError('Password change failed', error, stackTrace);
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

final changePasswordProvider =
    StateNotifierProvider.autoDispose<
      ChangePasswordNotifier,
      ChangePasswordState
    >((ref) {
      return ChangePasswordNotifier(
        userRepository: ref.read(userRepositoryProvider),
      );
    });
