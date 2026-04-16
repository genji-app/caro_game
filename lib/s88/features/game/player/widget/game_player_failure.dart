import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

/// A widget that displays an error state for games.
class GamePlayerFailure extends StatelessWidget {
  const GamePlayerFailure({
    required this.onRetry,
    required this.message,
    this.secondaryMessage,
    super.key,
  });

  final Widget message;
  final Widget? secondaryMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingStyles.space400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 32,
            ),
          ),

          const Gap(AppSpacingStyles.space400),
          DefaultTextStyle(
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
            child: message,
          ),

          if (secondaryMessage != null) ...[
            const Gap(AppSpacingStyles.space200),
            DefaultTextStyle(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
              child: secondaryMessage!,
            ),
          ],

          const Gap(AppSpacingStyles.space800),
          ShineButton(onPressed: onRetry, text: I18n.txtRetry),
        ],
      ),
    );
  }
}
