import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for creating Codepay QR code
class CreateCodePayQrUseCase {
  final DepositRepository _repository;

  CreateCodePayQrUseCase(this._repository);

  Future<Either<Failure, CodepayCreateQrResponse>> call(
    CodepayCreateQrRequest request,
  ) async {
    return await _repository.createCodePay(request);
  }
}
