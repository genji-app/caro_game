import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

/// A widget that displays an error state for games.
///
/// Pass [onRetry] to show a retry button. Pass [onGoBack] to show a back
/// button instead. If both are provided, retry takes precedence.
class GamePlayerFailure extends StatelessWidget {
  const GamePlayerFailure({
    required this.message,
    this.secondaryMessage,
    this.onRetry,
    this.onGoBack,
    super.key,
  });

  final Widget message;
  final Widget? secondaryMessage;

  /// If provided, shows a "Thử lại" button.
  final VoidCallback? onRetry;

  /// If provided and [onRetry] is null, shows a "Quay lại" button.
  final VoidCallback? onGoBack;

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
          if (onRetry != null)
            ShineButton(onPressed: onRetry, text: I18n.txtRetry)
          else if (onGoBack != null)
            ShineButton(
              onPressed: onGoBack,
              text: I18n.txtGoBack,
              size: ShineButtonSize.medium,
            ),
        ],
      ),
    );
  }
}
