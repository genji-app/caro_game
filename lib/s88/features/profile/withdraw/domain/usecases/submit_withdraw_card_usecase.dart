import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_response.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/repositories/withdraw_repository.dart';

/// Use case for submitting card withdraw
class SubmitWithdrawCardUseCase {
  final WithdrawRepository _repository;

  SubmitWithdrawCardUseCase(this._repository);

  Future<Either<Failure, WithdrawResponse>> call(
    WithdrawCardRequest request,
  ) async {
    return await _repository.submitCardWithdraw(request);
  }
}
