import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for submitting codepay deposit
class SubmitCodepayDepositUseCase {
  final DepositRepository _repository;

  SubmitCodepayDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    CodepayDepositRequest request,
  ) async {
    return await _repository.submitCodepayDeposit(request);
  }
}
