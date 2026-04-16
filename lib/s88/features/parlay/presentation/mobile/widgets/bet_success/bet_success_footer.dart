import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Footer widget for bet success view
/// Shows "Xem cược của tôi" button with orange/brown color
class BetSuccessFooter extends StatelessWidget {
  final VoidCallback onViewMyBets;

  const BetSuccessFooter({super.key, required this.onViewMyBets});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.4),
          blurRadius: 20,
          offset: Offset(0, -8),
        ),
      ],
    ),
    child: _ViewMyBetsButton(onPressed: onViewMyBets),
  );
}

/// Custom button styled like the Figma design (yellow700 background with shine effect)
class _ViewMyBetsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ViewMyBetsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.yellow700,
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.24),
            Color.fromRGBO(255, 255, 255, 0.0),
          ],
          stops: [0.0, 0.5523],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 0,
            offset: Offset(0, -1.5),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background color
          Container(
            decoration: BoxDecoration(
              color: AppColors.yellow700,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          // Shine gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.24),
                  Color.fromRGBO(255, 255, 255, 0.0),
                ],
                stops: [0.0, 0.5523],
              ),
            ),
          ),
          // Border effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.12),
                width: 1,
              ),
            ),
          ),
          // Text content
          Center(
            child: Text(
              'Xem cược của tôi',
              style: AppTextStyles.labelMedium(
                color: Colors.white,
              ).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    ),
  );
}
