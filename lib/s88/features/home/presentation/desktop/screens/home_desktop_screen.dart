import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_banner_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_casino_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_hot_bets_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_sports_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/mobile/widgets/home_mobile_welcome_section.dart';

class HomeDesktopScreen extends ConsumerStatefulWidget {
  const HomeDesktopScreen({super.key});

  @override
  ConsumerState<HomeDesktopScreen> createState() => _HomeDesktopScreenState();
}

class _HomeDesktopScreenState extends ConsumerState<HomeDesktopScreen> {
  @override
  void initState() {
    super.initState();
    SportStorage.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF141414),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeMobileWelcomeSection(),
            Gap(12),
            HomeDesktopHotBetsSection(),
            Gap(12),
            HomeDesktopSportsSection(),
            Gap(12),
            RepaintBoundary(child: GameGroupView.outstanding()),
            HomeDesktopCasinoSection(),
            Gap(12),
            // LiveBetView(),
            // Gap(12),
            HomeDesktopBannerSection(),
            Gap(12),
            RepaintBoundary(child: GameGroupView.liveCasino()),
          ],
        ),
      ),
    );
  }
}
