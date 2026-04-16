import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for getting deposit configuration
class GetConfigDepositUseCase {
  final DepositRepository _repository;

  GetConfigDepositUseCase(this._repository);

  Future<Either<Failure, FetchBankAccountsData>> call() async {
    return await _repository.getConfigDeposit();
  }
}
