import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

/// Shimmer placeholder for a payment-method card.
///
/// Visual footprint mirrors [DepositPaymentMethodCard] so the grid layout
/// does not shift when the real cards replace the placeholders after the
/// deposit config finishes loading.
class DepositPaymentMethodCardShimmer extends StatelessWidget {
  const DepositPaymentMethodCardShimmer({super.key});

  static const double _iconSize = 36;
  static const double _labelHeight = 12;
  static const double _gap = 6;
  static const double _verticalPadding = 12;
  static const double _horizontalPadding = 8;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: AppColors.gray700,
      colorOpacity: 0.3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: AppColors.gray800,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: _gap),
            Container(
              width: double.infinity,
              height: _labelHeight,
              decoration: BoxDecoration(
                color: AppColors.gray800,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
