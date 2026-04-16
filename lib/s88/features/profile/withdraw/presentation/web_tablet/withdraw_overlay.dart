import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/withdraw_header.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/withdraw_payment_methods_grid.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/bank_container.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/crypto_container.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/card_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Withdraw overlay widget for web/tablet
class WithdrawOverlay extends ConsumerWidget {
  const WithdrawOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(withdrawOverlayVisibleProvider);
    final confirmationData = ref.watch(withdrawConfirmationDataProvider);
    final selectedMethod = ref.watch(
      withdrawSelectionProvider.select((state) => state.selectedMethod),
    );

    // Show confirmation overlay if data exists
    if (confirmationData != null) {
      return const WithdrawWaitingPaymentConfirmOverlayWeb();
    }

    if (isVisible && selectedMethod == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(withdrawSelectionProvider.notifier)
            .selectPaymentMethod(WithdrawPaymentMethod.bank);
      });
    }

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(withdrawOverlayVisibleProvider.notifier).state = false;
            },
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: Container(
              width: 640,
              height: 823,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray950,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.75),
                    offset: const Offset(-20, 4),
                    blurRadius: 200,
                  ),
                  BoxShadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ],
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WithdrawHeader(
                    onClose: () {
                      ref.read(withdrawOverlayVisibleProvider.notifier).state =
                          false;
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const WithdrawPaymentMethodsGrid(),
                          const SizedBox(height: 40),
                          Expanded(
                            child: _buildPaymentMethodContainer(
                              selectedMethod ?? WithdrawPaymentMethod.bank,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodContainer(WithdrawPaymentMethod method) {
    switch (method) {
      case WithdrawPaymentMethod.bank:
        return const WithdrawBankContainer();
      case WithdrawPaymentMethod.crypto:
        return const WithdrawCryptoContainer();
      case WithdrawPaymentMethod.scratchCard:
        return const WithdrawCardContainer();
    }
  }
}
