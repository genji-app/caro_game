import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/notifiers/withdraw_bank_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';

/// Provider for controlling withdraw overlay visibility on web/tablet
final withdrawOverlayVisibleProvider = StateProvider<bool>((ref) => false);

/// Provider for selected withdraw payment method
final withdrawSelectionProvider =
    StateNotifierProvider<WithdrawSelectionNotifier, WithdrawSelectionState>((
      ref,
    ) {
      return WithdrawSelectionNotifier();
    });

/// Provider for withdrawal confirmation data
final withdrawConfirmationDataProvider =
    StateProvider<WithdrawConfirmationData?>((ref) => null);

/// Withdraw bank form provider
final withdrawBankFormProvider =
    StateNotifierProvider<WithdrawBankFormNotifier, WithdrawBankFormState>(
      (ref) => WithdrawBankFormNotifier(),
    );

/// State for withdraw payment method selection
class WithdrawSelectionState {
  final WithdrawPaymentMethod? selectedMethod;

  const WithdrawSelectionState({this.selectedMethod});

  WithdrawSelectionState copyWith({WithdrawPaymentMethod? selectedMethod}) {
    return WithdrawSelectionState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }
}

/// Notifier for withdraw payment method selection
class WithdrawSelectionNotifier extends StateNotifier<WithdrawSelectionState> {
  WithdrawSelectionNotifier() : super(const WithdrawSelectionState());

  void selectPaymentMethod(WithdrawPaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void clearSelection() {
    state = const WithdrawSelectionState();
  }
}
