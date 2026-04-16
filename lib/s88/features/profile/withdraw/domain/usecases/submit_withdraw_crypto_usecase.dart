import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

/// Use case for submitting crypto withdraw
class SubmitWithdrawCryptoUseCase {
  final WithdrawRepository _repository;

  SubmitWithdrawCryptoUseCase(this._repository);

  Future<Either<Failure, WithdrawResponse>> call(
    WithdrawCryptoRequest request,
  ) async {
    return await _repository.submitCryptoWithdraw(request);
  }
}
