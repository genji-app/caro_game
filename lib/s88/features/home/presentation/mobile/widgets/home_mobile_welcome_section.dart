import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_welcome_section.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/welcome_banner_card.dart';

class HomeMobileWelcomeSection extends StatelessWidget {
  const HomeMobileWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveBuilder.isTablet(context);
    return isTablet
        ? HomeDesktopWelcomeSection()
        : ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 355,
                    height: 160,
                    child: WelcomeBannerCard(
                      buttonText: 'Cược ngay',
                      color: const Color(0xFF111010),
                      colorOverlay: AppColors.yellow300.withValues(alpha: 0.45),
                      childTextContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sun88',
                            style:
                                AppTextStyles.headingMedium(
                                  color: AppColors.yellow500,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 28 / 24,
                                ),
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
                      overlayImageBuilder: (_) => Positioned(
                        top: 0,
                        right: -10,
                        width: 190,
                        child: ImageHelper.load(
                          path: AppImages.imageBannerSun88,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    width: 355,
                    height: 160,
                    child: WelcomeBannerCard(
                      buttonText: 'Cược ngay',
                      color: AppColorStyles.backgroundSecondary,
                      childTextContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worldcup',
                            style:
                                AppTextStyles.headingMedium(
                                  color: AppColors.yellow500,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 28 / 24,
                                ),
                          ),
                          Text(
                            '2026',
                            style:
                                AppTextStyles.headingMedium(
                                  color: AppColorStyles.contentPrimary,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 28 / 24,
                                ),
                          ),
                        ],
                      ),
                      overlayImageBuilder: (_) => Positioned(
                        top: 0,
                        right: 20,
                        width: 153,
                        child: ImageHelper.load(
                          path: AppImages.imageWorldCup,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
