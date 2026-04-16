import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// DISABLED: Not using hooks anymore since sport API logic moved to SportScreen
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
// DISABLED: Not calling league API from here anymore
// import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/screens/bet_detail_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/screens/bet_detail_mobile_v2_screen.dart';
import 'package:co_caro_flame/s88/features/casino/casino_screen.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_banner_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_hot_bets_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_sports_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/desktop/widgets/home_desktop_welcome_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/mobile/screens/home_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/home/presentation/tablet/screens/home_tablet_screen.dart';
import 'package:co_caro_flame/s88/features/live_bet/live_bet.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/screens/league_detail_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/screens/live_event_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/screens/sport_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/screens/top_league_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/screens/upcoming_event_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/screens/league_detail_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/screens/live_event_mobile_screen.dart';
// Import mobile content
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/screens/top_league_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/screens/upcoming_event_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/sport_mobile_main_content.dart';
// Import tablet content
import 'package:co_caro_flame/s88/features/sport_detail/presentation/desktop/screens/sport_detail_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/mobile/screens/sport_detail_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/sun_247/presentation/desktop/sun_247_desktop.dart';

/// Widget switch content ở giữa dựa trên mainContentProvider
class ShellContentSwitcher extends ConsumerWidget {
  final bool isTablet;
  final bool isMobile;

  const ShellContentSwitcher({
    super.key,
    this.isTablet = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);

    // ========== DISABLED: Sport API calls are now handled by SportScreen ==========
    // Luồng mới:
    // - SportScreen.initState() sẽ gọi initialize() và fetchLeagues()
    // - Không cần duplicate logic ở đây
    // ==============================================================================

    // OLD CODE - Commented out to prevent duplicate API calls
    // useEffect(() {
    //   if (contentType == MainContentType.sport) {
    //     final leagueNotifier = ref.read(leagueProvider.notifier);
    //     final hasData = ref.read(leagueProvider).leagues.isNotEmpty;
    //
    //     if (hasData) {
    //       // Data exists (returning from bet detail) → defer silent refresh
    //       // This allows UI to switch immediately without blocking
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         leagueNotifier.fetchLeaguesSilent();
    //       });
    //     } else {
    //       // First load → initialize normally
    //       leagueNotifier.initialize();
    //     }
    //   }
    //   return null;
    // }, [contentType]);

    // Mobile layout
    if (isMobile || isTablet) {
      return _buildMobileContent(contentType, ref);
    }

    // Tablet layout
    // if (isTablet) {
    //   return _buildMobileContent(contentType, ref);
    // }

    // Desktop layout
    return _buildDesktopContent(contentType);
  }

  /// Build content cho desktop
  Widget _buildDesktopContent(MainContentType contentType) {
    switch (contentType) {
      case MainContentType.sport:
        return const SportDesktopScreen();
      case MainContentType.casino:
        return const CasinoScreen(backgroundColor: Colors.transparent);
      case MainContentType.home:
        return const _HomeDesktopContent();
      case MainContentType.betDetail:
        return const BetDetailDesktopScreen();
      case MainContentType.sportDetail:
        return const SportDetailDesktopScreen();
      case MainContentType.sun247:
        return const Sun247Desktop();
      case MainContentType.tournaments:
        return const TopLeagueDesktopScreen();
      case MainContentType.live:
        return const LiveEventDesktopScreen();
      case MainContentType.upcoming:
        return const UpcomingEventDesktopScreen();
      case MainContentType.leagueDetail:
        return const LeagueDetailDesktopScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Build content cho tablet
  Widget _buildTabletContent(MainContentType contentType, WidgetRef ref) {
    switch (contentType) {
      case MainContentType.sport:
        return const SportMobileMainContent();
      case MainContentType.casino:
        return const CasinoScreen();
      case MainContentType.home:
        return const _HomeMobileContent();
      case MainContentType.betDetail:
        return const BetDetailMobileV2Screen();
      case MainContentType.sportDetail:
        return const _SportDetailMobileContent();
      case MainContentType.sun247:
        return const Sun247Desktop();
      case MainContentType.tournaments:
        return TopLeagueMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      case MainContentType.live:
        return LiveEventMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      case MainContentType.upcoming:
        return UpcomingEventMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      case MainContentType.leagueDetail:
        return LeagueDetailMobileScreen(
          onBackPressed: () {
            final prev = ref.read(previousContentProvider);
            if (prev != null) {
              ref.read(mainContentProvider.notifier).switchTo(prev);
              ref.read(previousContentProvider.notifier).state = null;
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Build content cho mobile
Widget _buildMobileContent(MainContentType contentType, WidgetRef ref) {
  switch (contentType) {
    case MainContentType.sport:
      return const SportMobileMainContent();
    case MainContentType.casino:
      return const CasinoScreen(showLiveChat: true);
    case MainContentType.home:
      return const _HomeMobileContent();
    case MainContentType.betDetail:
      return const BetDetailMobileV2Screen();
    case MainContentType.sportDetail:
      return const _SportDetailMobileContent();
    case MainContentType.sun247:
      return const Sun247Desktop();
    case MainContentType.tournaments:
      return TopLeagueMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    case MainContentType.live:
      return LiveEventMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    case MainContentType.upcoming:
      return UpcomingEventMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    case MainContentType.leagueDetail:
      return LeagueDetailMobileScreen(
        onBackPressed: () {
          final prev = ref.read(previousContentProvider);
          if (prev != null) {
            ref.read(mainContentProvider.notifier).switchTo(prev);
            ref.read(previousContentProvider.notifier).state = null;
          }
        },
      );
    default:
      return const SizedBox.shrink();
  }
}

/// Sport detail content cho mobile
class _SportDetailMobileContent extends ConsumerWidget {
  const _SportDetailMobileContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) => SportDetailMobileScreen(
    onBackPressed: () {
      // Navigate back to the previous screen (home or sport)
      final previousContent = ref.read(previousContentProvider);
      if (previousContent == MainContentType.home) {
        ref.read(mainContentProvider.notifier).goToHome();
      } else {
        ref.read(mainContentProvider.notifier).goToSport();
      }
      // Clear the previous content
      ref.read(previousContentProvider.notifier).state = null;
    },
  );
}

/// Home content cho desktop
class _HomeDesktopContent extends StatelessWidget {
  const _HomeDesktopContent();

  @override
  Widget build(BuildContext context) {
    // Shimmer đã được xử lý ở mức shell (_DesktopLayout)
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: AppSpacingStyles.space300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingStyles.space800,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140, minWidth: 960),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false),
          child: const SingleChildScrollView(
            child: Column(
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
                LiveBetView(),
                Gap(12),
                HomeDesktopBannerSection(),
                Gap(12),
                GameGroupView.liveCasino(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home content cho tablet
class _HomeTabletContent extends StatelessWidget {
  const _HomeTabletContent();

  @override
  Widget build(BuildContext context) {
    // Shimmer đã được xử lý ở mức shell (_TabletLayout)
    return const HomeTabletContent();
  }
}

/// Home content cho mobile
class _HomeMobileContent extends StatelessWidget {
  const _HomeMobileContent();

  @override
  Widget build(BuildContext context) {
    // Shimmer đã được xử lý ở mức shell (_MobileLayout)
    return const HomeMobileContent();
  }
}
