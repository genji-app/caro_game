import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/giftcode_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_giftcode_deposit_usecase.dart';

/// Giftcode submit notifier - manages giftcode deposit submission
/// Uses UseCases to separate business logic from state management
class GiftcodeSubmitNotifier extends StateNotifier<GiftcodeSubmitState> {
  final SubmitGiftcodeDepositUseCase _submitGiftcodeDepositUseCase;

  GiftcodeSubmitNotifier(this._submitGiftcodeDepositUseCase)
    : super(const GiftcodeSubmitState.idle());

  /// Submit giftcode deposit
  Future<void> submit(GiftcodeDepositRequest request) async {
    state = const GiftcodeSubmitState.submitting();

    // Use UseCase for business logic
    final result = await _submitGiftcodeDepositUseCase(request);

    result.fold(
      (failure) => state = GiftcodeSubmitState.error(failure.message),
      (response) => state = const GiftcodeSubmitState.success(),
    );
  }

  /// Reset submit state
  void reset() {
    state = const GiftcodeSubmitState.idle();
  }
}
