import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_card_deposit_usecase.dart';

/// Card submit notifier - manages scratch card deposit submission
/// Uses UseCase to separate business logic from state management
class CardSubmitNotifier extends StateNotifier<CardSubmitState> {
  final SubmitCardDepositUseCase _submitCardDepositUseCase;
  DepositResponse? _cardDepositResponse;

  CardSubmitNotifier(this._submitCardDepositUseCase)
    : super(const CardSubmitState.idle());

  /// Get last deposit response from the last successful submit call
  DepositResponse? get cardDepositResponse => _cardDepositResponse;

  /// Submit scratch card deposit
  Future<void> submit(CardDepositRequest request) async {
    state = const CardSubmitState.submitting();

    // Use UseCase for business logic
    final result = await _submitCardDepositUseCase(request);

    result.fold((failure) => state = CardSubmitState.error(failure.message), (
      response,
    ) {
      _cardDepositResponse = response;
      state = const CardSubmitState.success();
    });
  }

  /// Reset submit state
  void reset() {
    state = const CardSubmitState.idle();
    _cardDepositResponse = null;
  }
}
