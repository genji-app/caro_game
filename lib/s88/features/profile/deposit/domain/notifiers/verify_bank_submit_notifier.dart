import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/verify_bank_account_usecase.dart';

/// Submit notifier for verify bank API
class VerifyBankSubmitNotifier extends StateNotifier<VerifyBankSubmitState> {
  final Ref _ref;
  final VerifyBankAccountUseCase _useCase;

  VerifyBankSubmitNotifier(this._ref, this._useCase)
    : super(const VerifyBankSubmitState.idle());

  /// Returns true on success, false on failure
  Future<bool> submit({
    required String bankId,
    required String accountHolder,
    required String accountNo,
  }) async {
    state = const VerifyBankSubmitState.submitting();

    final result = await _useCase(
      bankId: bankId,
      accountHolder: accountHolder,
      accountNo: accountNo,
    );

    return result.fold(
      (failure) {
        state = VerifyBankSubmitState.error(failure.message);
        return false;
      },
      (message) {
        // Success: update needVerifyBankAccount override to false
        // This prevents re-verification even if API hasn't refreshed yet
        _ref.read(needVerifyBankAccountOverrideProvider.notifier).state = false;
        state = const VerifyBankSubmitState.success();
        return true;
      },
    );
  }

  void reset() {
    state = const VerifyBankSubmitState.idle();
  }
}
