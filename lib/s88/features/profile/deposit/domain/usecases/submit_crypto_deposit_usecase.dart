import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for submitting crypto deposit
class SubmitCryptoDepositUseCase {
  final DepositRepository _repository;

  SubmitCryptoDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    CryptoDepositRequest request,
  ) async {
    return await _repository.submitCryptoDeposit(request);
  }
}
