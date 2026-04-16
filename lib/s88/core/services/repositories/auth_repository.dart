import 'package:co_caro_flame/s88/core/services/auth/token_manager.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';

/// {@template auth_service_failure}
/// A base failure for the auth repository failures in core.
/// {@endtemplate}
sealed class AuthFailure implements Exception {
  /// {@macro auth_service_failure}
  const AuthFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => 'AuthFailure(error: $error)';
}

/// Thrown when requesting OTP fails
class RequestOtpFailure extends AuthFailure {
  /// {@macro request_otp_failure}
  const RequestOtpFailure(super.error);
}

/// Extension to helpers for [AuthFailure]
extension AuthFailureX on AuthFailure {
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

/// Auth Repository Interface
abstract class AuthRepository {
  Future<bool> connect();
  Future<void> reconnect();
  Future<void> logout();
  bool get isInitialized;
  UserModel? getCurrentUser();
  String? get currentToken;

  /// Request OTP for phone number verification
  ///
  /// Sends an OTP code to the provided phone number.
  ///
  /// Returns the message from the server if the request is successful.
  /// Throws [RequestOtpFailure] if the request fails.
  Future<String?> requestOtp(String phoneNumber);
}

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final SbHttpManager _http;

  AuthRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  @override
  Future<bool> connect() async {
    return await SbLogin.connect();
  }

  @override
  Future<void> reconnect() async {
    await SbLogin.reconnect();
  }

  @override
  Future<void> logout() async {
    // 1. Disconnect WebSockets and reset SbConfig/SbHttpManager
    await SbLogin.logout();

    // 2. Clear tokens from SharedPreferences
    await TokenManager.clearTokens();
    await UserManager.clearCredentials();
  }

  @override
  bool get isInitialized => SbLogin.isInitialized;

  @override
  UserModel? getCurrentUser() {
    if (!isInitialized) return null;

    final userData = _http.user;
    if (userData['cust_id'] == null ||
        (userData['cust_id'] as String).isEmpty) {
      return null;
    }

    return UserModel(
      uid: userData['uid'] as String? ?? '',
      displayName: userData['displayName'] as String? ?? '',
      custLogin: userData['cust_login'] as String? ?? '',
      custId: userData['cust_id'] as String? ?? '',
      balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
      currency: userData['currency'] as String? ?? 'VND',
      status: userData['status'] as String? ?? 'Active',
    );
  }

  @override
  String? get currentToken =>
      _http.userTokenSb.isNotEmpty ? _http.userTokenSb : null;

  @override
  Future<String?> requestOtp(String phoneNumber) async {
    try {
      final response = await _http.getOTPCode(phoneNumber);

      final data = response.dataOrThrow as Map<String, dynamic>;

      return data['message'] as String?;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(RequestOtpFailure(error), stackTrace);
    }
  }
}
