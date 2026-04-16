import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';

/// Codepay form notifier - manages codepay deposit form state
/// Simpler than Bank: only bank + amount (no accountNumber, accountName)
class CodepayFormNotifier extends StateNotifier<CodepayFormState> {
  CodepayFormNotifier() : super(const CodepayFormState());

  /// Update selected bank (by ID)
  void updateBank(String? bankId) {
    state = state.copyWith(
      selectedBank: bankId,
      bankError: bankId == null || bankId.isEmpty
          ? 'Vui lòng chọn ngân hàng'
          : null,
    );
  }

  /// Update amount
  void updateAmount(String amount) {
    final cleanedAmount = amount.replaceAll(',', '').replaceAll('.', '');
    final amountValue = int.tryParse(cleanedAmount);

    String? error;
    if (cleanedAmount.isEmpty) {
      error = 'Vui lòng nhập số tiền';
    } else if (amountValue == null || amountValue <= 0) {
      error = 'Số tiền không hợp lệ';
    } else if (amountValue < 10000) {
      error = 'Số tiền tối thiểu là \$10,000';
    } else if (amountValue > 100000000) {
      error = 'Số tiền tối đa là \$100,000,000';
    }

    state = state.copyWith(amount: amount, amountError: error);
  }

  /// Validate entire form
  bool validate() {
    String? bankError;
    String? amountError;

    if (state.selectedBank == null || state.selectedBank!.isEmpty) {
      bankError = 'Vui lòng chọn ngân hàng';
    }

    final cleanedAmount = state.amount.replaceAll(',', '').replaceAll('.', '');
    final amountValue = int.tryParse(cleanedAmount);
    if (cleanedAmount.isEmpty) {
      amountError = 'Vui lòng nhập số tiền';
    } else if (amountValue == null || amountValue <= 0) {
      amountError = 'Số tiền không hợp lệ';
    } else if (amountValue < 10000) {
      amountError = 'Số tiền tối thiểu là \$10,000';
    } else if (amountValue > 100000000) {
      amountError = 'Số tiền tối đa là \$100,000,000';
    }

    state = state.copyWith(bankError: bankError, amountError: amountError);

    return bankError == null && amountError == null;
  }

  /// Reset form
  void reset() {
    state = const CodepayFormState();
  }
}
