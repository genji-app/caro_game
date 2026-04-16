import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

/// Use case for submitting bank withdraw
class SubmitWithdrawBankUseCase {
  final WithdrawRepository _repository;

  SubmitWithdrawBankUseCase(this._repository);

  Future<Either<Failure, WithdrawResponse>> call(
    WithdrawBankRequest request,
  ) async {
    return await _repository.submitBankWithdraw(request);
  }
}
