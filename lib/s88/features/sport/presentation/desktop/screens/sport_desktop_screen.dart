import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_live_matches_section.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart';
import 'package:co_caro_flame/s88/shared/widgets/rive_vibrating/rive_vibrating.dart';

class SportDesktopScreen extends ConsumerWidget {
  const SportDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-load Rive animation for vibrating odds (Kèo Rung)
    // Dùng ref.read để trigger provider mà không gây rebuild
    ref.read(riveVibratingInitProvider);

    return Expanded(
      child: Container(
        color: AppColorStyles.backgroundSecondary,
        alignment: Alignment.topCenter,
        // margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
            ),
            child: BackToTopWrapper(
              builder: (scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SportDesktopSectionTabs(sections: _sections, selectedIndex: 0),
                    // const SportDesktopBannerSection(),
                    const SizedBox(height: 12),
                    const SportDesktopLiveMatchesSection(),
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
