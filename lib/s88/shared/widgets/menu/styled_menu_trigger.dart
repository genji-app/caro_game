import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

class StyledMenuTrigger extends StatelessWidget {
  const StyledMenuTrigger({
    required this.label,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.isOpen = false,
    this.minWidth = 160.0,
  });

  final String label;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final bool isOpen;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Row(
                key: ValueKey<String>(label),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[leadingIcon!, const Gap(8)],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null) ...[const Gap(8), trailingIcon!],
            const Gap(8),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(
                Icons.expand_more_rounded,
                size: 27,
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
