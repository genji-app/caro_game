import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/exceptions.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/auth/data/models/auth_model.dart';
import 'package:co_caro_flame/s88/features/auth/domain/entities/auth_entity.dart';
import 'package:co_caro_flame/s88/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthEntity>> login(LoginRequest request) async {
    try {
      final requestModel = LoginRequestModel.fromEntity(request);
      final result = await remoteDataSource.login(requestModel);
      final entity = result.toEntity();
      if (entity == null) {
        return Left(Failure.server(message: result.errorMessage));
      }
      return Right(entity);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register(RegisterRequest request) async {
    try {
      final requestModel = RegisterRequestModel.fromEntity(request);
      final result = await remoteDataSource.register(requestModel);
      final entity = result.toEntity();
      if (entity == null) {
        return Left(Failure.server(message: result.errorMessage));
      }
      return Right(entity);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    // TODO: Implement forgotPassword when API is available
    return Left(Failure.server(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  ) async {
    // TODO: Implement resetPassword when API is available
    return Left(Failure.server(message: 'Not implemented'));
  }
}
