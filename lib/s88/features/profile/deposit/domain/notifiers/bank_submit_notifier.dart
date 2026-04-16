import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_bank_deposit_usecase.dart';

/// Bank submit notifier - manages bank deposit submission
/// Uses UseCases to separate business logic from state management
/// Note: Transaction slip creation is handled by BankTransactionSlipNotifier
class BankSubmitNotifier extends StateNotifier<BankSubmitState> {
  final SubmitBankDepositUseCase _submitBankDepositUseCase;
  String? _lastTransactionId;

  BankSubmitNotifier(this._submitBankDepositUseCase)
    : super(const BankSubmitState.idle());

  /// Get last transaction ID from the last successful submission
  String? get lastTransactionId => _lastTransactionId;

  /// Submit bank deposit
  Future<void> submit(BankDepositRequest request) async {
    state = const BankSubmitState.submitting();

    // Use UseCase for business logic
    final result = await _submitBankDepositUseCase(request);

    result.fold((failure) => state = BankSubmitState.error(failure.message), (
      response,
    ) {
      _lastTransactionId = response.transactionId;
      state = const BankSubmitState.success();
    });
  }

  /// Reset submit state
  void reset() {
    state = const BankSubmitState.idle();
    _lastTransactionId = null;
  }
}
