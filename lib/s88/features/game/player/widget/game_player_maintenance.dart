import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

/// A widget that displays a maintenance state for games.
class GamePlayerMaintenance extends StatelessWidget {
  const GamePlayerMaintenance({required this.onGoHomePressed, super.key});

  final VoidCallback onGoHomePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacingStyles.space400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Game đang bảo trì.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(AppSpacingStyles.space200),
          Text(
            'Xin quay lại sau!',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const Gap(AppSpacingStyles.space800),
          ShineButton(
            onPressed: onGoHomePressed,
            text: I18n.txtBackToHome,
            size: ShineButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
