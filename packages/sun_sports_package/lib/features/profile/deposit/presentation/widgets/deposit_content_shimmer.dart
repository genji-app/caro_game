import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

/// Shimmer skeleton for the deposit container area shown below the payment
/// methods grid while the deposit config is still loading.
///
/// Renders generic form-shaped placeholders (label + selection field +
/// label + amount input + label + amount input + action button) so the
/// loading state stays consistent across every payment method, regardless
/// of which container would eventually be rendered.
///
/// The widget expects to be placed inside a parent that provides a bounded
/// height (e.g. `Expanded`) so the action-button placeholder can be pinned
/// to the bottom, mirroring the real form layout.
class DepositContentShimmer extends StatelessWidget {
  const DepositContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Shimmer(
        duration: const Duration(milliseconds: 1500),
        color: AppColors.gray700,
        colorOpacity: 0.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _ShimmerLine(width: 120, height: 12),
            SizedBox(height: 8),
            _ShimmerBlock(height: 48),
            SizedBox(height: 20),
            _ShimmerLine(width: 100, height: 12),
            SizedBox(height: 8),
            _ShimmerBlock(height: 48),
            SizedBox(height: 20),
            _ShimmerLine(width: 140, height: 12),
            SizedBox(height: 8),
            _ShimmerBlock(height: 48),
            Spacer(),
            _ShimmerBlock(height: 52, borderRadius: 12),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.height, this.borderRadius = 8});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
