import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card_shimmer.dart';

/// Payment methods grid widget for web/tablet - single row with 6 items.
/// Matches Figma design: 1 row horizontal layout.
///
/// While the deposit config is still loading, a shimmer placeholder row is
/// rendered instead of the real cards. This avoids a 6 → 4 card flicker that
/// happened previously when the optional Bank/e-Wallet tabs defaulted to
/// visible during the loading state and then disappeared once the API
/// returned empty lists.
class DepositPaymentMethodsGridWeb extends ConsumerWidget {
  const DepositPaymentMethodsGridWeb({super.key});

  static const int _placeholderCount = 6;
  static const double _spacing = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isDepositConfigLoadingProvider);

    if (isLoading) {
      return Row(
        children: List<Widget>.generate(_placeholderCount, (index) {
          final isLast = index == _placeholderCount - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : _spacing),
              child: const DepositPaymentMethodCardShimmer(),
            ),
          );
        }),
      );
    }

    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;
    final showBankTab = ref.watch(hasBankAccountsProvider);
    final showEWalletTab = ref.watch(hasEWalletsProvider);
    final showCryptoTab = ref.watch(hasCryptoOptionsProvider);

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
        if (showCryptoTab) ...[
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
        ],
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
        if (showBankTab) ...[
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
        ],
        if (showEWalletTab) ...[
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
      ],
    );
  }
}
