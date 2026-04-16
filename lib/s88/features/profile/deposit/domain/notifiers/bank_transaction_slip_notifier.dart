import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank_transaction_slip_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/create_transaction_slip_usecase.dart';

/// Bank transaction slip notifier - manages transaction slip creation
/// Separate from BankSubmitNotifier to avoid confusion between submit and createTransactionSlip
class BankTransactionSlipNotifier
    extends StateNotifier<BankTransactionSlipState> {
  final CreateTransactionSlipUseCase _createTransactionSlipUseCase;
  String? _lastTransactionId;

  BankTransactionSlipNotifier(this._createTransactionSlipUseCase)
    : super(const BankTransactionSlipState.idle());

  /// Get last transaction ID from the last successful creation
  String? get lastTransactionId => _lastTransactionId;

  /// Create transaction slip
  Future<void> createTransactionSlip(BankTransactionSlipRequest request) async {
    state = const BankTransactionSlipState.submitting();

    // Use UseCase for business logic
    final result = await _createTransactionSlipUseCase(request);

    result.fold(
      (failure) => state = BankTransactionSlipState.error(failure.message),
      (response) {
        _lastTransactionId = response.transactionId;
        state = const BankTransactionSlipState.success();
      },
    );
  }

  /// Reset transaction slip state
  void reset() {
    state = const BankTransactionSlipState.idle();
    _lastTransactionId = null;
  }
}
