import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/bank/bank_container.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/codepay/codepay_container.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/ewallet_container.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/crypto_container.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/card_container.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/giftcode_container.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/deposit_payment_methods_grid.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Mobile deposit bottom sheet that slides up from bottom
class DepositMobileBottomSheet extends ConsumerStatefulWidget {
  const DepositMobileBottomSheet({super.key});

  /// Show the deposit bottom sheet
  static Future<void> show(BuildContext context) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Slide up animation
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1), // Start from bottom
        end: Offset.zero, // End at position
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        const DepositMobileBottomSheet(),
  );

  @override
  ConsumerState<DepositMobileBottomSheet> createState() =>
      _DepositMobileBottomSheetState();
}

class _DepositMobileBottomSheetState
    extends ConsumerState<DepositMobileBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Initialize with codepay selected only if no selection exists (first time)
    // Use a delay to allow other code to set selection first (e.g., from showPreviousDialog in DepositNavigator)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        final currentSelection = ref
            .read(depositSelectionProvider)
            .selectedMethod;
        // Only reset to codepay if no selection exists (first time opening, not from navigation back)
        if (currentSelection == null) {
          ref
              .read(depositSelectionProvider.notifier)
              .selectPaymentMethod(PaymentMethod.codepay);
        }
      });
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
          color: AppColorStyles.backgroundSecondary, // #111010
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
              // Header
              _buildHeader(),
              // Payment method specific container (handles its own scrolling and bottom button)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Payment methods grid (reused widget)
                      const DepositPaymentMethodsGrid(),
                      // Payment method specific container
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

  /// Header with back button, title, and close button
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Nạp tiền',
              style: AppTextStyles.headingXSmall(color: AppColors.gray25),
            ),
          ),
        ),
        InkWell(
          onTap: () => DepositNavigator().closeAll<void>(context),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );

  /// Build payment method specific container
  Widget _buildPaymentMethodContainer() {
    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;

    switch (selectedMethod) {
      case PaymentMethod.codepay:
        return const CodepayContainer();
      case PaymentMethod.bank:
        return const BankContainer();
      case PaymentMethod.eWallet:
        return const EWalletContainer();
      case PaymentMethod.crypto:
        return const CryptoContainer();
      case PaymentMethod.scratchCard:
        return const CardContainer();
      case PaymentMethod.giftcode:
        return const GiftCodeContainer();
    }
  }
}
