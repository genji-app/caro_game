import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/get_crypto_address_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_crypto_deposit_usecase.dart';

/// Crypto submit notifier - manages crypto deposit submission
/// Uses UseCases to separate business logic from state management
class CryptoSubmitNotifier extends StateNotifier<CryptoSubmitState> {
  final SubmitCryptoDepositUseCase _submitCryptoDepositUseCase;
  final GetCryptoAddressUseCase _getCryptoAddressUseCase;
  CryptoAddressResponse? _cryptoAddressResponse;

  CryptoSubmitNotifier(
    this._submitCryptoDepositUseCase,
    this._getCryptoAddressUseCase,
  ) : super(const CryptoSubmitState.idle());

  /// Get last crypto address response from the last successful getCryptoAddress call
  CryptoAddressResponse? get cryptoAddressResponse => _cryptoAddressResponse;

  /// Get crypto address
  Future<void> getCryptoAddress(CryptoAddressRequest request) async {
    state = const CryptoSubmitState.submitting();

    // Use UseCase for business logic
    final result = await _getCryptoAddressUseCase(request);

    result.fold((failure) => state = CryptoSubmitState.error(failure.message), (
      response,
    ) {
      _cryptoAddressResponse = response;
      state = const CryptoSubmitState.success();
    });
  }

  /// Submit crypto deposit
  Future<void> submit(CryptoDepositRequest request) async {
    state = const CryptoSubmitState.submitting();

    // Use UseCase for business logic
    final result = await _submitCryptoDepositUseCase(request);

    result.fold(
      (failure) => state = CryptoSubmitState.error(failure.message),
      (response) => state = const CryptoSubmitState.success(),
    );
  }

  /// Reset submit state
  void reset() {
    state = const CryptoSubmitState.idle();
    _cryptoAddressResponse = null;
  }
}
