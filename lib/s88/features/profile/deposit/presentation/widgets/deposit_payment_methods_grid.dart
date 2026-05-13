import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/deposit_payment_method_card.dart';

/// Mobile deposit payment-methods grid.
///
/// Renders the available payment methods in a 3-column grid that automatically
/// reflows: when optional tabs (Bank, e-Wallet) are hidden, the remaining
/// items shift up so the first row is never left looking sparse.
class DepositPaymentMethodsGrid extends ConsumerWidget {
  const DepositPaymentMethodsGrid({super.key});

  static const double _spacing = 12;
  static const int _columns = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;
    final showBankTab = ref.watch(hasBankAccountsProvider);
    final showEWalletTab = ref.watch(hasEWalletsProvider);

    // Visible methods in display order. Optional tabs are conditionally
    // included; everything else always shows.
    final methods = <({PaymentMethod method, String label})>[
      (method: PaymentMethod.codepay, label: 'Codepay'),
      if (showBankTab) (method: PaymentMethod.bank, label: 'Ngân hàng'),
      if (showEWalletTab)
        (method: PaymentMethod.eWallet, label: 'Ví điện tử'),
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
