import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/check_codepay_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for checking if a Codepay QR code was previously created
class CheckCodePayUseCase {
  final DepositRepository _repository;

  CheckCodePayUseCase(this._repository);

  /// Check if Codepay QR code exists
  /// Returns CodepayCreateQrResponse if found, or Failure if not found or error
  Future<Either<Failure, CodepayCreateQrResponse>> call(
    CheckCodePayRequest request,
  ) async {
    return await _repository.checkCodePay(request);
  }
}
