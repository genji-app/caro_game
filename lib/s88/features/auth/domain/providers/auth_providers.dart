import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/auth/domain/notifiers/auth_notifiers.dart';
import 'package:co_caro_flame/s88/features/auth/domain/state/auth_state.dart';

// ========== Data Layer Providers ==========

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// ========== Presentation Layer Providers (State Notifiers) ==========

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthNotifier(dataSource);
});

/// Provider for LoginFormNotifier
final loginFormNotifierProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier();
    });

/// Provider for RegisterFormNotifier
final registerFormNotifierProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
      final dataSource = ref.watch(authRemoteDataSourceProvider);
      return RegisterFormNotifier(dataSource);
    });

/// Provider for OtpFormNotifier
final otpFormNotifierProvider =
    StateNotifierProvider<OtpFormNotifier, OtpFormState>((ref) {
      return OtpFormNotifier();
    });
