import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/welcome_banner_card.dart';

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
            color: AppColorStyles.backgroundSecondary,
            onTap: () {
              ref
                  .read(selectedLeagueInfoProvider.notifier)
                  .state = SelectedLeagueInfo(
                sportId: v2.SportType.soccer.id,
                leagueId: 1216,
                leagueName: 'FIFA World Cup 2026',
                leagueLogo: '',
              );
              ref.read(mainContentProvider.notifier).goToLeagueDetail();
              ref.read(previousContentProvider.notifier).state = null;
            },
            childTextContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Worldcup',
                  style: AppTextStyles.headingMedium(
                    color: AppColors.yellow500,
                  ).copyWith(fontWeight: FontWeight.w600, height: 28 / 24),
                ),
                Text(
                  '2026',
                  style: AppTextStyles.headingMedium(
                    color: AppColorStyles.contentPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, height: 28 / 24),
                ),
              ],
            ),
            overlayImageBuilder: (isHovered) => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: isHovered ? -20 : 0,
              right: isHovered ? 10 : 20,
              width: isHovered ? 173 : 153,
              child: ImageHelper.load(
                path: AppImages.imageWorldCup,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
