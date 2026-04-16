import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';

/// Giftcode form notifier - manages giftcode deposit form state
class GiftcodeFormNotifier extends StateNotifier<GiftcodeFormState> {
  GiftcodeFormNotifier() : super(const GiftcodeFormState());

  /// Update giftcode
  void updateGiftcode(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập mã giftcode';
    }

    state = state.copyWith(giftCode: value, giftCodeError: error);
  }

  /// Validate form
  bool validate() {
    String? giftCodeError;

    if (state.giftCode.isEmpty) {
      giftCodeError = 'Vui lòng nhập mã giftcode';
    }
    state = state.copyWith(giftCodeError: giftCodeError);

    return giftCodeError == null;
  }

  /// Reset form
  void reset() {
    state = const GiftcodeFormState();
  }
}
