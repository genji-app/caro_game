import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/withdraw_payment_method_card.dart';

/// Payment methods grid widget for withdraw (1 row x 3 columns)
class WithdrawPaymentMethodsGrid extends ConsumerWidget {
  const WithdrawPaymentMethodsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(withdrawSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? WithdrawPaymentMethod.bank;

    return Row(
      children: [
        Expanded(
          child: WithdrawPaymentMethodCard(
            method: WithdrawPaymentMethod.bank,
            label: 'Ngân hàng',
            isSelected: selectedMethod == WithdrawPaymentMethod.bank,
            onTap: () {
              ref
                  .read(withdrawSelectionProvider.notifier)
                  .selectPaymentMethod(WithdrawPaymentMethod.bank);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: WithdrawPaymentMethodCard(
            method: WithdrawPaymentMethod.scratchCard,
            label: 'Thẻ cào',
            isSelected: selectedMethod == WithdrawPaymentMethod.scratchCard,
            onTap: () {
              ref
                  .read(withdrawSelectionProvider.notifier)
                  .selectPaymentMethod(WithdrawPaymentMethod.scratchCard);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: WithdrawPaymentMethodCard(
            method: WithdrawPaymentMethod.crypto,
            label: 'Tiền điện tử',
            isSelected: selectedMethod == WithdrawPaymentMethod.crypto,
            onTap: () {
              ref
                  .read(withdrawSelectionProvider.notifier)
                  .selectPaymentMethod(WithdrawPaymentMethod.crypto);
            },
          ),
        ),
      ],
    );
  }
}
