import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_response.dart';

/// Abstract repository interface for withdraw
/// Domain layer only knows about this contract, not the implementation
abstract class WithdrawRepository {
  /// Submit bank withdraw
  Future<Either<Failure, WithdrawResponse>> submitBankWithdraw(
    WithdrawBankRequest request,
  );

  /// Submit card withdraw
  Future<Either<Failure, WithdrawResponse>> submitCardWithdraw(
    WithdrawCardRequest request,
  );

  /// Submit crypto withdraw
  Future<Either<Failure, WithdrawResponse>> submitCryptoWithdraw(
    WithdrawCryptoRequest request,
  );
}
