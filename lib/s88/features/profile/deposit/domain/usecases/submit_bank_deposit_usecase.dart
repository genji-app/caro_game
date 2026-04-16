import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for submitting bank deposit
class SubmitBankDepositUseCase {
  final DepositRepository _repository;

  SubmitBankDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    BankDepositRequest request,
  ) async {
    return await _repository.submitBankDeposit(request);
  }
}
