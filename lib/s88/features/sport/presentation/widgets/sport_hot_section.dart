import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/legacy_to_v2_adapter.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/providers/hot_match_provider.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/hot_match/hot_match_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/hot_match/hot_match_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class SportHotSection extends ConsumerStatefulWidget {
  final double height;
  final String? backgroundImage;
  final bool isRightSidebar;
  const SportHotSection({
    super.key,
    this.height = 152,
    this.backgroundImage,
    this.isRightSidebar = false,
  });

  @override
  ConsumerState<SportHotSection> createState() => _SportHotSectionState();
}

class _SportHotSectionState extends ConsumerState<SportHotSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sportId = ref.read(leagueProvider).currentSportId;
      ref.read(hotMatchProvider.notifier).fetchHotMatches(sportId: sportId);
    });
  }

  void _goToPrevious(List<HotMatchEventV2> hotMatches, int currentIndex) {
    if (hotMatches.isEmpty) return;
    final newIndex = (currentIndex - 1 + hotMatches.length) % hotMatches.length;
    final notifier = ref.read(hotMatchProvider.notifier);
    if (widget.isRightSidebar) {
      notifier.setRightSidebarPageIndex(newIndex);
    } else {
      notifier.setPageIndex(newIndex);
    }
  }

  void _goToNext(List<HotMatchEventV2> hotMatches, int currentIndex) {
    if (hotMatches.isEmpty) return;
    final newIndex = (currentIndex + 1) % hotMatches.length;
    final notifier = ref.read(hotMatchProvider.notifier);
    if (widget.isRightSidebar) {
      notifier.setRightSidebarPageIndex(newIndex);
    } else {
      notifier.setPageIndex(newIndex);
    }
  }

  void _onMatchTap(HotMatchEventV2 match) {
    ref.read(selectedEventV2Provider.notifier).state = match.event;
    ref.read(selectedLeagueV2Provider.notifier).state = LeagueModelV2(
      events: const [],
      sportId: match.event.sportId > 0
          ? match.event.sportId
          : ref.read(leagueProvider).currentSportId,
      leagueId: match.leagueId,
      leagueName: match.leagueName,
      leagueNameEn: match.leagueName,
      leagueLogo: match.leagueLogo,
    );
    ref.read(mainContentProvider.notifier).goToBetDetail();
  }

  void _onOddsTap(
    BuildContext context,
    HotMatchEventV2 match,
    LeagueOddsData odds,
    bool isHome,
    int marketId,
  ) {
    if (!ref.read(isAuthenticatedProvider)) {
      AppToast.showError(
        context,
        message: 'Vui lòng đăng nhập để thực hiện cược',
      );
      return;
    }
    final sportId = ref.read(leagueProvider).currentSportId;
    final handicapMarket = match.getHandicapMarket(sportId);
    if (handicapMarket == null) return;

    final oddsV2 = odds.toOddsModelV2();
    final leagueData = LeagueModelV2(
      events: const [],
      sportId: match.event.sportId > 0 ? match.event.sportId : sportId,
      leagueId: match.leagueId,
      leagueName: match.leagueName,
      leagueNameEn: match.leagueName,
      leagueLogo: match.leagueLogo,
    );
    final popupData = BettingPopupDataV2(
      sportId: sportId,
      oddsData: oddsV2,
      marketData: handicapMarket,
      eventData: match.event,
      oddsType: isHome ? OddsType.home : OddsType.away,
      leagueData: leagueData,
    );
    BetDetailsBottomSheetV2.show(context, data: popupData);
  }

  @override
  Widget build(BuildContext context) {
    // Use select to only rebuild when isLoading changes
    final isLoading = ref.watch(
      hotMatchProvider.select((state) => state.isLoading),
    );
    // Use select to check if matches list is empty (for loading state)
    final hasNoMatches = ref.watch(
      hotMatchProvider.select((state) => state.leagues.isEmpty),
    );

    // Show loading state
    if (isLoading && hasNoMatches) {
      return HotMatchShimmerLoading(isRightSidebar: widget.isRightSidebar);
    }

    // Use Consumer to isolate rebuilds for the main content
    return Consumer(
      builder: (context, ref, child) {
        final hotMatches = ref.watch(hotMatchesProvider);
        final currentIndex = ref.watch(
          hotMatchProvider.select(
            (state) => widget.isRightSidebar
                ? state.rightSidebarPageIndex
                : state.currentPageIndex,
          ),
        );
        final sportId = ref.watch(
          leagueProvider.select((s) => s.currentSportId),
        );

        // Ensure index is valid
        final safeIndex = hotMatches.isEmpty
            ? 0
            : currentIndex.clamp(0, hotMatches.length - 1);

        // Reset index if out of bounds
        if (hotMatches.isNotEmpty && currentIndex >= hotMatches.length) {
          Future.microtask(() {
            final n = ref.read(hotMatchProvider.notifier);
            if (widget.isRightSidebar) {
              n.setRightSidebarPageIndex(0);
            } else {
              n.setPageIndex(0);
            }
          });
        }

        // Get current match data
        final currentMatch = hotMatches.isNotEmpty
            ? hotMatches[safeIndex]
            : null;

        // Use mockup data if no real data available
        final displayMatch = currentMatch;

        if (displayMatch == null) return const SizedBox.shrink();
        // Calculate time until match
        final timeUntilMatch = _calculateTimeUntilMatch(displayMatch);

        final handicapMarket = displayMatch.getHandicapMarket(sportId);
        final handicapOdds = handicapMarket?.mainLineOdds != null;

        final matchesList = hotMatches.isNotEmpty ? hotMatches : [displayMatch];
        final showNavigation = hotMatches.length > 1;

        return HotMatchContainer(
          match: displayMatch,
          matches: matchesList,
          currentIndex: safeIndex,
          onPrevious: showNavigation
              ? () => _goToPrevious(hotMatches, safeIndex)
              : null,
          onNext: showNavigation
              ? () => _goToNext(hotMatches, safeIndex)
              : null,
          onTap: () => _onMatchTap(displayMatch),
          onOddsTap: handicapOdds
              ? (odds, isHome, mid) =>
                    _onOddsTap(context, displayMatch, odds, isHome, mid)
              : null,
          timeUntilMatch: timeUntilMatch,
          viewCount: null,
          bettingPercentage: null,
          favoredTeam: null,
          isFirstItem: hotMatches.isEmpty || safeIndex == 0,
          isLastItem: hotMatches.isEmpty || safeIndex == hotMatches.length - 1,
          isRightSidebar: widget.isRightSidebar,
        );
      },
    );
  }

  String? _calculateTimeUntilMatch(HotMatchEventV2 match) {
    try {
      final dateTime = match.event.startDateTime;

      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.isNegative) {
        // Match already started or finished
        return null;
      }

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút';
      } else {
        return 'Sắp diễn ra';
      }
    } catch (e) {
      return null;
    }
  }
}
