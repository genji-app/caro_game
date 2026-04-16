import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/auth/domain/entities/auth_entity.dart';

/// Abstract repository interface for authentication
/// Domain layer only knows about this contract, not the implementation
abstract class AuthRepository {
  /// Login with username and password
  Future<Either<Failure, AuthEntity>> login(LoginRequest request);

  /// Register a new user
  Future<Either<Failure, AuthEntity>> register(RegisterRequest request);

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Forgot password
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Reset password
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
}
