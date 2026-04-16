import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

class GameFilterEmptyState extends StatelessWidget {
  const GameFilterEmptyState({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // Determine the effective padding, optionally using responsive defaults.
    final effectivePadding =
        padding ??
        EdgeInsets.all(
          ResponsiveBuilder.isMobile(context)
              ? AppSpacingStyles.space600
              : AppSpacingStyles.space1600,
        );

    return Padding(
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 186),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacingStyles.space400,
            children: [
              // Illustration Section
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(height: 178),
                child: ImageHelper.load(
                  path: AppImages.imgGameNotFound,
                  fit: BoxFit.contain,
                ),
              ),

              // Message Section
              Text(
                I18n.msgNoResultFound,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
