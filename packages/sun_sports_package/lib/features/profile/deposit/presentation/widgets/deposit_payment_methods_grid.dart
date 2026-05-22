import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card_shimmer.dart';

/// Mobile deposit payment-methods grid.
///
/// Renders the available payment methods in a 3-column grid that automatically
/// reflows: when optional tabs (Bank, e-Wallet) are hidden, the remaining
/// items shift up so the first row is never left looking sparse.
///
/// While the deposit config is still loading, a shimmer placeholder grid is
/// rendered instead of the real cards. This avoids a 6 → 4 card flicker that
/// happened previously when the optional Bank/e-Wallet tabs defaulted to
/// visible during the loading state and then disappeared once the API
/// returned empty lists.
class DepositPaymentMethodsGrid extends ConsumerWidget {
  const DepositPaymentMethodsGrid({super.key});

  static const double _spacing = 12;
  static const int _columns = 3;
  static const int _placeholderCount = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isDepositConfigLoadingProvider);

    if (isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;

          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: List<Widget>.generate(
              _placeholderCount,
              (_) => SizedBox(
                width: cardWidth,
                child: const DepositPaymentMethodCardShimmer(),
              ),
            ),
          );
        },
      );
    }

    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;
    final showBankTab = ref.watch(hasBankAccountsProvider);
    final showEWalletTab = ref.watch(hasEWalletsProvider);
    final showCryptoTab = ref.watch(hasCryptoOptionsProvider);

    // Visible methods in display order. Optional tabs are conditionally
    // included; everything else always shows.
    final methods = <({PaymentMethod method, String label})>[
      (method: PaymentMethod.codepay, label: 'Codepay'),
      if (showBankTab) (method: PaymentMethod.bank, label: 'Ngân hàng'),
      if (showEWalletTab)
        (method: PaymentMethod.eWallet, label: 'Ví điện tử'),
      if (showCryptoTab)
        (method: PaymentMethod.crypto, label: 'Tiền điện tử'),
      (method: PaymentMethod.scratchCard, label: 'Thẻ cào'),
      (method: PaymentMethod.giftcode, label: 'Giftcode'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: methods.map((entry) {
            return SizedBox(
              width: cardWidth,
              child: DepositPaymentMethodCard(
                method: entry.method,
                label: entry.label,
                isSelected: selectedMethod == entry.method,
                onTap: () {
                  ref
                      .read(depositSelectionProvider.notifier)
                      .selectPaymentMethod(entry.method);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
