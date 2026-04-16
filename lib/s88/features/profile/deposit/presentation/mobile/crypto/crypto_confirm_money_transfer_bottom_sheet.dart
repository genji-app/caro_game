import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/crypto_confirm_money_transfer_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Mobile crypto confirm money transfer bottom sheet with QR code and wallet address
class CryptoConfirmMoneyTransferBottomSheet extends ConsumerStatefulWidget {
  final CryptoAddressResponse cryptoAddressResponse;
  final CryptoOption cryptoOption;
  final PaymentMethod paymentMethod;

  const CryptoConfirmMoneyTransferBottomSheet({
    super.key,
    required this.cryptoAddressResponse,
    required this.cryptoOption,
    required this.paymentMethod,
  });

  /// Show the crypto confirm money transfer bottom sheet
  static Future<void> show(
    BuildContext context, {
    required CryptoAddressResponse cryptoAddressResponse,
    required CryptoOption cryptoOption,
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
        CryptoConfirmMoneyTransferBottomSheet(
          cryptoAddressResponse: cryptoAddressResponse,
          cryptoOption: cryptoOption,
          paymentMethod: paymentMethod,
        ),
  );

  @override
  ConsumerState<CryptoConfirmMoneyTransferBottomSheet> createState() =>
      _CryptoConfirmMoneyTransferBottomSheetState();
}

class _CryptoConfirmMoneyTransferBottomSheetState
    extends ConsumerState<CryptoConfirmMoneyTransferBottomSheet> {
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
          child: CryptoConfirmMoneyTransferContainer(
            cryptoAddressResponse: widget.cryptoAddressResponse,
            cryptoOption: widget.cryptoOption,
            paymentMethod: widget.paymentMethod,
          ),
        ),
      ),
    );
  }
}
