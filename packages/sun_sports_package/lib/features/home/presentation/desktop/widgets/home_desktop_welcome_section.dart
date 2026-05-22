import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/providers/main_content_provider.dart';
import 'package:sun_sports/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:sun_sports/core/services/providers/league_detail_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/cards/welcome_banner_card.dart';

class HomeDesktopWelcomeSection extends ConsumerWidget {
  const HomeDesktopWelcomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    height: 180,
    padding: const EdgeInsets.only(top: 15),
    child: Row(
      children: [
        Expanded(
          child: WelcomeBannerCard(
            buttonText: 'Cược ngay',
            color: const Color(0xFF111010),
            colorOverlay: AppColors.yellow300.withValues(alpha: 0.45),
            onTap: () {
              ref.read(mainContentProvider.notifier).goToSport();
            },
            childTextContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sun88',
                  style: AppTextStyles.headingMedium(
                    color: AppColors.yellow500,
                  ).copyWith(fontWeight: FontWeight.w600, height: 28 / 24),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 167),
                  child: Text(
                    'Thương hiệu cá cược thể thao của SunWin',
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              ],
            ),
            overlayImageBuilder: (isHovered) => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: isHovered ? -20 : -10,
              right: isHovered ? 10 : 20,
              width: isHovered ? 210 : 190,
              child: ImageHelper.load(
                path: AppImages.imageBannerSun88,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: WelcomeBannerCard(
            buttonText: 'Cược ngay',
            color: const Color(0xFF111010),
            colorOverlay: AppColors.yellow300.withValues(alpha: 0.45),
            onTap: () {
              ref.read(mainContentProvider.notifier).goToSport();
            },
            childTextContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sergio Ramos',
                  style: AppTextStyles.headingMedium(
                    color: AppColors.yellow500,
                  ).copyWith(fontWeight: FontWeight.w600, height: 28 / 24),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 167),
                  child: Text(
                    'Đại sứ thương hiệu độc quyền của SunWin',
                    style: AppTextStyles.labelSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              ],
            ),
            overlayImageBuilder: (isHovered) => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: isHovered ? -20 : -10,
              right: isHovered ? 10 : 20,
              width: isHovered ? 185 : 175,
              child: ImageHelper.load(
                path: AppImages.imageBannerRamos,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
