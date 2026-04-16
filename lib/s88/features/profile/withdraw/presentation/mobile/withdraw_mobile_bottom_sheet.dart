import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/withdraw_header.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/withdraw_payment_methods_grid.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/bank_container.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/crypto_container.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/card_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Mobile withdraw bottom sheet that slides up from bottom
class WithdrawMobileBottomSheet extends ConsumerStatefulWidget {
  const WithdrawMobileBottomSheet({super.key});

  /// Show the withdraw bottom sheet
  static Future<void> show(BuildContext context) => showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        const WithdrawMobileBottomSheet(),
  );

  @override
  ConsumerState<WithdrawMobileBottomSheet> createState() =>
      _WithdrawMobileBottomSheetState();
}

class _WithdrawMobileBottomSheetState
    extends ConsumerState<WithdrawMobileBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(withdrawSelectionProvider.notifier)
          .selectPaymentMethod(WithdrawPaymentMethod.bank);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final maxHeight = screenSize.height;

    return Dialog(
      backgroundColor: AppColorStyles.backgroundSecondary,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        width: screenSize.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              WithdrawHeader(onClose: () => Navigator.of(context).pop()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const WithdrawPaymentMethodsGrid(),
                      const SizedBox(height: 40),
                      Expanded(child: _buildPaymentMethodContainer()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodContainer() {
    final selectionState = ref.watch(withdrawSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? WithdrawPaymentMethod.bank;

    switch (selectedMethod) {
      case WithdrawPaymentMethod.bank:
        return const WithdrawBankContainer();
      case WithdrawPaymentMethod.crypto:
        return const WithdrawCryptoContainer();
      case WithdrawPaymentMethod.scratchCard:
        return const WithdrawCardContainer();
    }
  }
}
