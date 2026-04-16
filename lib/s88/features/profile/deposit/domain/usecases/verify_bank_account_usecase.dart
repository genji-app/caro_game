import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

class VerifyBankAccountUseCase {
  final DepositRepository _repository;

  VerifyBankAccountUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String bankId,
    required String accountHolder,
    required String accountNo,
  }) => _repository.verifyBankAccount(
    bankId: bankId,
    accountHolder: accountHolder,
    accountNo: accountNo,
  );
}
