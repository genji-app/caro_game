import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_payment_method_card_shimmer.dart';
import 'package:sun_sports/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:sun_sports/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/widgets/withdraw_payment_method_card.dart';

/// Payment methods grid widget for withdraw (1 row x 3 columns)
///
/// The "Tiền điện tử" tab is conditionally hidden when the paygate config
/// returns no crypto options — withdraw shares the same crypto source as
/// deposit (`hasCryptoOptionsProvider`).
///
/// While the paygate config is still loading for the first time, a shimmer
/// placeholder row is rendered instead of the real cards. This mirrors the
/// deposit grid behavior and avoids a 3 → 2 card flicker that would happen
/// otherwise when the optional "Tiền điện tử" tab defaults to visible during
/// loading and then disappears once the API returns no crypto options.
class WithdrawPaymentMethodsGrid extends ConsumerWidget {
  const WithdrawPaymentMethodsGrid({super.key});

  /// Max number of cards rendered (bank + scratchCard + crypto).
  /// Drives the shimmer placeholder count so the row width matches the
  /// fully-loaded state.
  static const int _placeholderCount = 3;
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

    final selectionState = ref.watch(withdrawSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? WithdrawPaymentMethod.bank;
    final showCryptoTab = ref.watch(hasCryptoOptionsProvider);

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
        if (showCryptoTab) ...[
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
      ],
    );
  }
}
