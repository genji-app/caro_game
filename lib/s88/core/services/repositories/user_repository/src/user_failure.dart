import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';

/// {@template user_failure}
/// A base failure for the user repository failures.
/// {@endtemplate}
sealed class UserFailure implements Exception {
  /// {@macro user_failure}
  const UserFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => 'UserFailure(error: $error)';
}

/// {@template get_user_info_failure}
/// Thrown when fetching user info fails.
/// {@endtemplate}
class GetUserInfoFailure extends UserFailure {
  /// {@macro get_user_info_failure}
  const GetUserInfoFailure(super.error);
}

/// {@template get_balance_failure}
/// Thrown when refreshing user balance fails.
/// {@endtemplate}
class GetBalanceFailure extends UserFailure {
  /// {@macro get_balance_failure}
  const GetBalanceFailure(super.error);
}

/// {@template verify_phone_failure}
/// Thrown when verifying OTP fails.
/// {@endtemplate}
class VerifyPhoneFailure extends UserFailure {
  /// {@macro verify_phone_failure}
  const VerifyPhoneFailure(super.error);
}

/// Thrown when changing password fails
class ChangePasswordFailure extends UserFailure {
  /// {@macro change_password_failure}
  const ChangePasswordFailure(super.error);
}

class GetNotificationsFailure extends UserFailure {
  const GetNotificationsFailure(super.error);
}

/// Extension to helpers for [UserFailure]
extension UserFailureX on UserFailure {
  /// Get user friendly error message
  String? get errorMessage {
    final err = error;

    if (err is SunApiException) {
      return err.userFriendlyMessage;
    }

    // Handle generic Exception
    if (err is Exception) {
      return err.toString().replaceFirst('Exception: ', '');
    }

    // Default message
    return null;
  }
}
