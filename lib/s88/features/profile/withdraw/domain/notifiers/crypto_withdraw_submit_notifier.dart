import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/usecases/submit_withdraw_crypto_usecase.dart';

/// Crypto withdraw submit notifier - manages crypto withdraw submission
/// Uses UseCases to separate business logic from state management
class CryptoWithdrawSubmitNotifier
    extends StateNotifier<CryptoWithdrawSubmitState> {
  final SubmitWithdrawCryptoUseCase _submitCryptoWithdrawUseCase;

  CryptoWithdrawSubmitNotifier(this._submitCryptoWithdrawUseCase)
    : super(const CryptoWithdrawSubmitState.idle());

  /// Submit crypto withdraw
  Future<void> submit(WithdrawCryptoRequest request) async {
    state = const CryptoWithdrawSubmitState.submitting();

    // Use UseCase for business logic
    final result = await _submitCryptoWithdrawUseCase(request);

    result.fold(
      (failure) => state = CryptoWithdrawSubmitState.error(failure.message),
      (response) => state = const CryptoWithdrawSubmitState.success(),
    );
  }

  /// Reset submit state
  void reset() {
    state = const CryptoWithdrawSubmitState.idle();
  }
}
