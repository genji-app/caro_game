import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';

/// Card (Scratch Card) form notifier - manages card deposit form state
class CardFormNotifier extends StateNotifier<CardFormState> {
  CardFormNotifier() : super(const CardFormState());

  /// Update selected card type
  void updateCardType(String? cardType) {
    state = state.copyWith(
      selectedCardType: cardType,
      cardTypeError: cardType == null || cardType.isEmpty
          ? 'Vui lòng chọn thẻ'
          : null,
    );
  }

  /// Update selected denomination
  void updateDenomination(String? denomination) {
    state = state.copyWith(
      selectedDenomination: denomination,
      denominationError: denomination == null || denomination.isEmpty
          ? 'Vui lòng chọn mệnh giá'
          : null,
    );
  }

  /// Update serial number
  void updateSerialNumber(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập số seri';
    }

    state = state.copyWith(serialNumber: value, serialNumberError: error);
  }

  /// Update card code
  void updateCardCode(String value) {
    String? error;
    if (value.isEmpty) {
      error = 'Vui lòng nhập mã thẻ';
    }

    state = state.copyWith(cardCode: value, cardCodeError: error);
  }

  /// Validate entire form
  bool validate() {
    String? cardTypeError;
    String? denominationError;
    String? serialNumberError;
    String? cardCodeError;

    if (state.selectedCardType == null || state.selectedCardType!.isEmpty) {
      cardTypeError = 'Vui lòng chọn thẻ';
    }

    if (state.selectedDenomination == null ||
        state.selectedDenomination!.isEmpty) {
      denominationError = 'Vui lòng chọn mệnh giá';
    }

    if (state.serialNumber.isEmpty) {
      serialNumberError = 'Vui lòng nhập số seri';
    }

    if (state.cardCode.isEmpty) {
      cardCodeError = 'Vui lòng nhập mã thẻ';
    }

    state = state.copyWith(
      cardTypeError: cardTypeError,
      denominationError: denominationError,
      serialNumberError: serialNumberError,
      cardCodeError: cardCodeError,
    );

    return cardTypeError == null &&
        denominationError == null &&
        serialNumberError == null &&
        cardCodeError == null;
  }

  /// Reset form
  void reset() {
    state = const CardFormState();
  }
}
