import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Deposit/Withdraw action button with gradient shine effect
/// Fixed at bottom of bottom sheet with enable/disable states
class DepositActionButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Whether the button is enabled
  final bool isEnabled;

  /// Callback when button is tapped (only called when enabled)
  final VoidCallback? onTap;

  /// Button height (default: 44)
  final double height;

  /// Padding around button (default: EdgeInsets.fromLTRB(16, 16, 16, 40))
  final EdgeInsets padding;

  const DepositActionButton({
    super.key,
    required this.text,
    required this.isEnabled,
    this.onTap,
    this.height = 44,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 40),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              // Background container
              Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  color: isEnabled ? AppColors.yellow700 : AppColors.gray700,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              // Gradient shine effect (only when enabled)
              if (isEnabled)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55232],
                          colors: [
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Text on top
              Center(
                child: Text(
                  text,
                  style: AppTextStyles.textStyle(
                    fontSize: 16,
                    fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w600,
                    color: isEnabled ? Colors.white : AppColors.gray500,
                    height: 1.5, // 24px line height for 16px font
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
