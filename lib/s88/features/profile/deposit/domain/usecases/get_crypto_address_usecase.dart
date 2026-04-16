import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';

/// Use case for getting crypto address
class GetCryptoAddressUseCase {
  final DepositRepository _repository;

  GetCryptoAddressUseCase(this._repository);

  Future<Either<Failure, CryptoAddressResponse>> call(
    CryptoAddressRequest request,
  ) async {
    return await _repository.getCryptoAddress(request);
  }
}
