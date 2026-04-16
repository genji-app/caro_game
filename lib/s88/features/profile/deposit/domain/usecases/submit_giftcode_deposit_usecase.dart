import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for submitting giftcode deposit
class SubmitGiftcodeDepositUseCase {
  final DepositRepository _repository;

  SubmitGiftcodeDepositUseCase(this._repository);

  Future<Either<Failure, DepositResponse>> call(
    GiftcodeDepositRequest request,
  ) async {
    return await _repository.submitGiftcodeDeposit(request);
  }
}
