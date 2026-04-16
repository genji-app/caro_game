import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/repositories/auth_repository.dart';
import 'package:co_caro_flame/s88/core/services/models/user_model.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/auth_enums.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/auth_enums.dart';

/// Auth State
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    token: token ?? this.token,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

/// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  /// Connect to sportbook server
  Future<void> connect() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final success = await _repository.connect();

      if (success) {
        final user = _repository.getCurrentUser();
        final token = _repository.currentToken;

        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            token: token,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Không thể lấy thông tin user',
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Kết nối thất bại',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi: ${e.toString()}',
      );
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final user = _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Silently fail on refresh
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _repository.logout();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Check if initialized
  bool get isInitialized => _repository.isInitialized;

  /// Get current balance
  double get currentBalance => state.user?.balance ?? 0.0;

  /// Sync auth state from SbLogin after successful connection
  /// Called after SbLogin.connect() completes successfully
  void syncFromSbLogin() {
    // Directly access singleton since we know SbLogin.connect() just succeeded
    final http = SbHttpManager.instance;
    final userData = http.user;

    debugPrint('syncFromSbLogin: userData = $userData'); // Debug

    final custLogin = userData['cust_login'] as String? ?? '';

    if (custLogin.isNotEmpty) {
      final user = UserModel(
        uid: userData['uid'] as String? ?? '',
        displayName: userData['displayName'] as String? ?? '',
        custLogin: custLogin,
        custId: http.custId,
        balance: (userData['balance'] as num?)?.toDouble() ?? 0.0,
        currency: userData['currency'] as String? ?? 'VND',
        status: userData['status'] as String? ?? 'Active',
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: http.userTokenSb,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }
}

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience providers
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authProvider).user,
);

final userBalanceProvider = Provider<double>(
  (ref) => ref.watch(authProvider).user?.balance ?? 0.0,
);
