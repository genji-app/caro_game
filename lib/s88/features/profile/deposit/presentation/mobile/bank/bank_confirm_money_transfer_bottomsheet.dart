import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/bank_confirm_money_transfer_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Mobile bank confirm money transfer bottom sheet
class BankConfirmMoneyTransferBottomSheet extends StatelessWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;

  const BankConfirmMoneyTransferBottomSheet({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
    required this.parentContext,
  });

  /// Show the bank confirm money transfer bottom sheet
  static Future<void> show(
    BuildContext context, {
    required BankAccountItem bankAccountItem,
    required PaymentMethod paymentMethod,
  }) => showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
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
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        BankConfirmMoneyTransferBottomSheet(
          bankAccountItem: bankAccountItem,
          paymentMethod: paymentMethod,
          parentContext: context, // Store the original context
        ),
  );

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
          child: BankConfirmMoneyTransferContainer(
            bankAccountItem: bankAccountItem,
            paymentMethod: paymentMethod,
            parentContext: parentContext,
          ),
        ),
      ),
    );
  }
}
