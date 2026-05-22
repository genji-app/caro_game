import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

/// Payment method card widget for deposit overlay (reusable for mobile and web/tablet)
class DepositPaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DepositPaymentMethodCard({
    super.key,
    required this.method,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double cardRadius = 12;
    final borderRadius = BorderRadius.circular(cardRadius);

    // The outer [ClipRRect] forces every layer below it — border, fill,
    // background overlay, glow image, InkWell ripple — to be painted only
    // inside the card's rounded outline. This is the most reliable way to
    // avoid the activated-state overlays from showing square corners that
    // don't match the rounded border, because Flutter's Container/Stack
    // clipping doesn't always produce a pixel-perfect rounded clip on
    // every backend.
    return ClipRRect(
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColorStyles.backgroundTertiary, // #1b1a19
                  // Vertical gradient border: fully-opaque #FFD791 at the
                  // bottom fading to fully-transparent at the top, so the
                  // highlighted card looks like it catches light from below.
                  border: const GradientBoxBorder(
                    width: 0.7,
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFFFFD791), // start (bottom) — opaque
                        Color(0x00FFD791), // end (top) — transparent
                      ],
                    ),
                  ),
                  borderRadius: borderRadius,
                )
              : BoxDecoration(
                  color: AppColorStyles.backgroundTertiary,
                  borderRadius: borderRadius,
                ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect for the highlighted state. Pinned to all
              // four sides so the underlying asset can't stretch to its
              // intrinsic size and leak past the card.
              if (isSelected)
                Positioned.fill(
                  child: ImageHelper.load(
                    path: AppImages.activatedglow,
                    fit: BoxFit.cover,
                  ),
                ),
              // Content (icon and label).
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: _getPaymentMethodIcon(),
                    ),
                    const SizedBox(height: 6),
                    // Label
                    Text(
                      label,
                      style: AppTextStyles.paragraphXSmall(
                        color: isSelected
                            ? const Color(0xFFF9DBAF) // #F9DBAF
                            : AppColors.gray25, // #fffef5
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get payment method icon path
  String _getPaymentMethodIconPath() {
    switch (method) {
      case PaymentMethod.codepay:
        return AppIcons.icPaymentCodepay;
      case PaymentMethod.bank:
        return AppIcons.icPaymentBank;
      case PaymentMethod.eWallet:
        return AppIcons.icPaymentMomo;
      case PaymentMethod.crypto:
        return AppIcons.icPaymentCrypto;
      case PaymentMethod.scratchCard:
        return AppIcons.icPaymentScratchCard;
      case PaymentMethod.giftcode:
        return AppImages.icPaymentGiftcode;
    }
  }

  /// Get SVG/Image icon for payment method
  Widget _getPaymentMethodIcon() {
    const iconSize = 36.0;

    // Giftcode uses image, others use SVG
    if (method == PaymentMethod.giftcode) {
      return ImageHelper.load(
        path: _getPaymentMethodIconPath(),
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }

    return ImageHelper.getSVG(
      path: _getPaymentMethodIconPath(),
      width: iconSize,
      height: iconSize,
    );
  }
}
