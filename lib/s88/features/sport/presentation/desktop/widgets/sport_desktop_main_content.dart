import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/scroll_aware_controller.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart';
import 'sport_desktop_banner_section.dart';
import 'sport_desktop_live_matches_section.dart';
import 'sport_desktop_section_tabs.dart';

class SportDesktopMainContent extends StatelessWidget {
  const SportDesktopMainContent({super.key});

  static const _sections = [
    'Cúp C1 Châu Âu',
    'Ngoại hạng anh',
    'Laliga',
    'Seria A',
    'Bundesliga',
    'Ligue 1',
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            // Dùng CustomScrollView với Slivers để có virtualization
            child: BackToTopWrapper(
            builder: (scrollController) => NotificationListener<
                ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification ||
                    notification is ScrollUpdateNotification) {
                  ScrollAwareController.instance.onScrollStart();
                } else if (notification is ScrollEndNotification) {
                  ScrollAwareController.instance.onScrollEnd();
                }
                return false; // Don't stop propagation
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Header sections (không cần virtualize vì số lượng ít)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SportDesktopSectionTabs(
                        //   sections: _sections,
                        //   selectedIndex: 0,
                        // ),
                        // const SizedBox(height: 12),
                        const SportDesktopBannerSection(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // Live matches section (Sảnh / Sắp diễn ra / Yêu thích)
                  SliverToBoxAdapter(
                    child: const SportDesktopLiveMatchesSection(),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
