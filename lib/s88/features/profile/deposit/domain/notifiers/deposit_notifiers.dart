import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';

/// Deposit selection notifier - manages payment method selection
class DepositSelectionNotifier extends StateNotifier<DepositSelectionState> {
  DepositSelectionNotifier() : super(const DepositSelectionState());

  /// Select payment method
  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method, isContainerVisible: true);
  }

  /// Reset selection
  void reset() {
    state = const DepositSelectionState();
  }

  /// Show/hide container
  void setContainerVisible(bool visible) {
    state = state.copyWith(isContainerVisible: visible);
  }
}
