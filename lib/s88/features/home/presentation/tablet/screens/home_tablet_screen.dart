import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_banner_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_hot_bets_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_sports_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_welcome_section.dart';

class HomeTabletScreen extends ConsumerWidget {
  const HomeTabletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bỏ shimmer loading - hiển thị trực tiếp nội dung
    return const Scaffold(
      backgroundColor: Color(0xFF141414),
      body: HomeTabletContent(),
    );
  }
}

class HomeTabletContent extends ConsumerWidget {
  const HomeTabletContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ref.watch(mainScrollControllerProvider);

    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeDesktopWelcomeSection(),
                Gap(12),
                HomeDesktopHotBetsSection(),
                Gap(12),
                HomeDesktopSportsSection(),
                Gap(12),
                RepaintBoundary(child: GameGroupView.outstanding()),
                Gap(12),
                // LiveBetView(),
                // Gap(12),
                HomeDesktopBannerSection(),
                Gap(12),
                RepaintBoundary(child: GameGroupView.liveCasino()),
                Gap(80), // Extra padding for bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }
}
