import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_banner_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_live_matches_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_section_tabs.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_hot_section.dart';

class SportTabletMainContent extends StatelessWidget {
  const SportTabletMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      'Cúp C1 Châu Âu',
      'Ngoại hạng anh',
      'Laliga',
      'Seria A',
      'Bundesliga',
      'Ligue 1',
    ];

    //1140, 860
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ), // space-800 = 32px according to Figma
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SportDesktopSectionTabs(sections: sections, selectedIndex: 0),
                  // const Gap(AppSpacingStyles.space300),
                  // Banner section
                  const SportDesktopBannerSection(),
                  const Gap(AppSpacingStyles.space300),
                  // Hot section
                  // SportHotSection(height: 125),
                  const Gap(AppSpacingStyles.space300),
                  // Live matches section with header and match cards
                  const SportDesktopLiveMatchesSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
