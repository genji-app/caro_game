import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/deposit_payment_method_card.dart';

/// Payment methods grid widget for web/tablet - single row with 6 items
/// Matches Figma design: 1 row horizontal layout
class DepositPaymentMethodsGridWeb extends ConsumerWidget {
  const DepositPaymentMethodsGridWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;

    return Row(
      children: [
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.codepay,
            label: 'Codepay',
            isSelected: selectedMethod == PaymentMethod.codepay,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.codepay);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.crypto,
            label: 'Tiền điện tử',
            isSelected: selectedMethod == PaymentMethod.crypto,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.crypto);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.scratchCard,
            label: 'Thẻ cào',
            isSelected: selectedMethod == PaymentMethod.scratchCard,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.scratchCard);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.giftcode,
            label: 'Giftcode',
            isSelected: selectedMethod == PaymentMethod.giftcode,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.giftcode);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.bank,
            label: 'Ngân hàng',
            isSelected: selectedMethod == PaymentMethod.bank,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.bank);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: DepositPaymentMethodCard(
            method: PaymentMethod.eWallet,
            label: 'Ví điện tử',
            isSelected: selectedMethod == PaymentMethod.eWallet,
            onTap: () {
              ref
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.eWallet);
            },
          ),
        ),
      ],
    );
  }
}
