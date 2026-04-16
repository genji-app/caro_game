import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
import 'package:co_caro_flame/s88/core/services/auth/token_manager.dart';
import 'package:co_caro_flame/s88/core/utils/auth_validator.dart';
import 'package:co_caro_flame/s88/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/auth/data/models/auth_model.dart';
import 'package:co_caro_flame/s88/features/auth/domain/state/auth_state.dart';

/// Notifier for authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AuthState.initial());

  Future<void> login(String username, String password) async {
    state = const AuthState.loading();

    try {
      final request = LoginRequestModel(username: username, password: password);

      final response = await _dataSource.login(request);

      if (response.isSuccess) {
        final auth = response.toEntity();
        if (auth != null) {
          // Save tokens
          await TokenManager.saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            wsToken: auth.wsToken,
          );

          // Save credentials for auto-login
          await UserManager.saveCredentials(username, password);

          // Connect to sportbook server (load config, refresh token, get wsToken, connect websockets)
          // isReconnect: false to reload config from scratch after logout
          await SbLogin.connect(isReconnect: false);

          state = AuthState.authenticated(auth);
        } else {
          state = const AuthState.error('Đăng nhập thất bại');
        }
      } else if (response.isOtpRequired) {
        // OTP required
        state = AuthState.otpRequired(
          sessionId: response.data?.sessionId ?? '',
          message: response.data?.message ?? 'Vui lòng nhập mã OTP',
          username: username,
          password: password,
        );
      } else {
        // Handle all errors - pass showPopup flag
        state = AuthState.error(
          response.errorMessage,
          showPopup: response.shouldShowPopup,
        );
      }
    } catch (e) {
      state = AuthState.error('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String displayName,
    String? affId,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmContent,
    String? utmTerm,
  }) async {
    state = const AuthState.loading();

    try {
      final request = RegisterRequestModel(
        username: username,
        password: password,
        displayName: displayName,
        affId: affId,
        utmSource: utmSource,
        utmMedium: utmMedium,
        utmCampaign: utmCampaign,
        utmContent: utmContent,
        utmTerm: utmTerm,
      );

      final response = await _dataSource.register(request);

      if (response.isSuccess) {
        final auth = response.toEntity();
        if (auth != null) {
          // Save tokens
          await TokenManager.saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            wsToken: auth.wsToken,
          );

          // Save credentials for auto-login
          await UserManager.saveCredentials(username, password);

          // Connect to sportbook server (load config, refresh token, get wsToken, connect websockets)
          // isReconnect: false to reload config from scratch after logout
          await SbLogin.connect(isReconnect: false);

          state = AuthState.authenticated(auth);
        } else {
          state = const AuthState.error('Đăng ký thất bại');
        }
      } else {
        // Handle all errors - pass showPopup flag
        state = AuthState.error(
          response.errorMessage,
          showPopup: response.shouldShowPopup,
        );
      }
    } catch (e) {
      state = AuthState.error('Đăng ký thất bại: ${e.toString()}');
    }
  }

  Future<void> submitOtp({
    required String sessionId,
    required String otp,
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final request = OtpRequestModel(
        sessionId: sessionId,
        otp: otp,
        username: username,
        password: password,
      );

      final response = await _dataSource.submitOtp(request);

      if (response.isSuccess) {
        final auth = response.toEntity();
        if (auth != null) {
          // Save tokens
          await TokenManager.saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            wsToken: auth.wsToken,
          );

          // Save credentials for auto-login
          await UserManager.saveCredentials(username, password);

          // Connect to sportbook server (load config, refresh token, get wsToken, connect websockets)
          // isReconnect: false to reload config from scratch after logout
          await SbLogin.connect(isReconnect: false);

          state = AuthState.authenticated(auth);
        } else {
          state = const AuthState.error('Xác thực OTP thất bại');
        }
      } else {
        state = AuthState.error(response.errorMessage);
      }
    } catch (e) {
      state = AuthState.error('Xác thực OTP thất bại: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      // 1. Call API logout (optional, may fail if token expired)
      await _dataSource.logout();
    } catch (e) {
      // Ignore API errors - we still want to clean up locally
    }

    try {
      // 2. Disconnect WebSockets and reset SbConfig/SbHttpManager
      await SbLogin.logout();

      // 3. Clear local tokens
      await TokenManager.clearTokens();
      await UserManager.clearCredentials();

      state = const AuthState.unauthenticated();
    } catch (e) {
      // Even if cleanup fails, mark as unauthenticated
      await TokenManager.clearTokens();
      await UserManager.clearCredentials();
      state = const AuthState.unauthenticated();
    }
  }

  /// Check if user has saved tokens and try to restore session
  Future<void> checkAuthStatus() async {
    final hasTokens = await TokenManager.hasTokens();
    if (hasTokens) {
      // TODO: Validate token with server
      // For now, just mark as unauthenticated and let user login
      state = const AuthState.unauthenticated();
    } else {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Notifier for login form state
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void updateUsername(String username) {
    state = state.copyWith(
      username: username,
      usernameError: null,
      generalError: null,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: null,
      generalError: null,
    );
  }

  bool validate() {
    final usernameError = AuthValidator.validateLoginUsername(state.username);
    final passwordError = AuthValidator.validatePassword(state.password);

    state = state.copyWith(
      usernameError: usernameError,
      passwordError: passwordError,
    );

    return usernameError == null && passwordError == null;
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  void reset() {
    state = const LoginFormState();
  }
}

/// Notifier for register form state
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final AuthRemoteDataSource? _dataSource;

  RegisterFormNotifier([this._dataSource]) : super(const RegisterFormState());

  void updateUsername(String username) {
    state = state.copyWith(
      username: username,
      usernameError: null,
      generalError: null,
      usernameAvailability: UsernameAvailability.unknown,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: null,
      generalError: null,
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: null,
      generalError: null,
    );
  }

  void updateDisplayName(String displayName) {
    state = state.copyWith(
      displayName: displayName,
      displayNameError: null,
      generalError: null,
    );
  }

  /// Check username availability when user leaves the field
  Future<void> checkUsernameAvailability() async {
    if (_dataSource == null) return;
    if (state.username.isEmpty || state.username.length < 6) return;

    state = state.copyWith(usernameAvailability: UsernameAvailability.checking);

    try {
      final result = await _dataSource!.checkUsernameAvailable(state.username);

      UsernameAvailability availability;
      switch (result) {
        case UsernameCheckResult.available:
          availability = UsernameAvailability.available;
          break;
        case UsernameCheckResult.existsOnOtherBrand:
          availability = UsernameAvailability.existsOnOtherBrand;
          break;
        case UsernameCheckResult.taken:
          availability = UsernameAvailability.taken;
          break;
      }

      state = state.copyWith(usernameAvailability: availability);
    } catch (e) {
      state = state.copyWith(
        usernameAvailability: UsernameAvailability.unknown,
      );
    }
  }

  bool validate() {
    final usernameError = AuthValidator.validateRegisterUsername(
      state.username,
    );
    final passwordError = AuthValidator.validatePassword(state.password);
    final confirmPasswordError = AuthValidator.validateConfirmPassword(
      state.confirmPassword,
      state.password,
    );
    final displayNameError = AuthValidator.validateDisplayName(
      state.displayName,
      state.username,
    );

    state = state.copyWith(
      usernameError: usernameError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      displayNameError: displayNameError,
    );

    return usernameError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        displayNameError == null;
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  void reset() {
    state = const RegisterFormState();
  }
}

/// Notifier for OTP form state
class OtpFormNotifier extends StateNotifier<OtpFormState> {
  OtpFormNotifier() : super(const OtpFormState());

  void updateOtp(String otp) {
    state = state.copyWith(otp: otp, otpError: null, generalError: null);
  }

  bool validate() {
    final otpError = AuthValidator.validateOtp(state.otp);

    state = state.copyWith(otpError: otpError);

    return otpError == null;
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setGeneralError(String? error) {
    state = state.copyWith(generalError: error);
  }

  void reset() {
    state = const OtpFormState();
  }
}
