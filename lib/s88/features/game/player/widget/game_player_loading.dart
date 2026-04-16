import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';

/// A widget that displays a loading state for games.
class GamePlayerLoading extends StatelessWidget {
  const GamePlayerLoading({this.progress, super.key});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorStyles.backgroundPrimary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: ImageHelper.getNetworkImage(
                imageUrl: AppImages.logoS88Home,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorWidget: const Icon(
                  Icons.image,
                  size: 200,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColorStyles.backgroundTertiary,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.yellow300,
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
