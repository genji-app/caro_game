import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/ewallet_confirm_money_transfer_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Mobile e-wallet confirm money transfer bottom sheet with QR code and wallet details
class EWalletConfirmMoneyTransferBottomSheet extends StatefulWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;
  final bool hideButtons; // Hide buttons when loaded from saved state

  const EWalletConfirmMoneyTransferBottomSheet({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    required this.parentContext,
    this.hideButtons = false,
  });

  /// Show the e-wallet confirm money transfer bottom sheet
  static Future<void> show(
    BuildContext context, {
    required CodepayCreateQrResponse qrResponse,
    required PaymentMethod paymentMethod,
    bool hideButtons = false,
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
        EWalletConfirmMoneyTransferBottomSheet(
          qrResponse: qrResponse,
          paymentMethod: paymentMethod,
          parentContext: context, // Store the original context
          hideButtons: hideButtons,
        ),
  );

  @override
  State<EWalletConfirmMoneyTransferBottomSheet> createState() =>
      _EWalletConfirmMoneyTransferBottomSheetState();
}

class _EWalletConfirmMoneyTransferBottomSheetState
    extends State<EWalletConfirmMoneyTransferBottomSheet> {
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
          child: EWalletConfirmMoneyTransferContainer(
            qrResponse: widget.qrResponse,
            paymentMethod: widget.paymentMethod,
            hideButtons: widget.hideButtons,
          ),
        ),
      ),
    );
  }
}
