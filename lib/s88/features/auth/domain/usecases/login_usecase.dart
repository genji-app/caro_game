import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/auth/domain/entities/auth_entity.dart';
import 'package:co_caro_flame/s88/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(LoginRequest request) async {
    return await repository.login(request);
  }
}
