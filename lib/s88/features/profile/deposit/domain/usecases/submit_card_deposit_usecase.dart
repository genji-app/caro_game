import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for submitting scratch card deposit
class SubmitCardDepositUseCase {
  final DepositRepository _repository;

  SubmitCardDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    CardDepositRequest request,
  ) async {
    return await _repository.submitCardDeposit(request);
  }
}
