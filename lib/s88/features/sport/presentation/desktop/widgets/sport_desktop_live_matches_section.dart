import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/legacy_to_v2_adapter.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:co_caro_flame/s88/features/home/domain/providers/hot_match_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/match_filter_tabs.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/match_filter_tab_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_list_event_container.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/hot_match/hot_match_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/hot_match/hot_match_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/sport_widgets.dart';
// V2 imports - using V2 models directly
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_card_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_type_filter_tabs.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_popular_league_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';

// Selectors: chỉ subscribe phần state cần dùng, rebuild khi giá trị chọn thay đổi
// final _selectedFilterSelector = matchFilterSelectedProvider.select((s) => s);
final _hotMatchesSelector = hotMatchesProvider;
final _hotMatchLoadingSelector = hotMatchProvider.select((s) => s.isLoading);
final _currentSportIdSelector = leagueProvider.select((s) => s.currentSportId);

class SportDesktopLiveMatchesSection extends ConsumerStatefulWidget {
  const SportDesktopLiveMatchesSection({super.key});

  @override
  ConsumerState<SportDesktopLiveMatchesSection> createState() =>
      _SportDesktopLiveMatchesSectionState();
}

class _SportDesktopLiveMatchesSectionState
    extends ConsumerState<SportDesktopLiveMatchesSection> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sportId = ref.read(_currentSportIdSelector);
      ref.read(hotMatchProvider.notifier).fetchHotMatches(sportId: sportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(matchFilterSelectedProvider);
    final showUpcomingFavorites =
        selectedFilter == MatchFilterType.upcoming ||
        selectedFilter == MatchFilterType.favorites;

    ref.listen(isCurrentMatchFilterDataLoadingProvider, (prev, next) {
      if (prev == true && next == false) {
        if (ref.read(matchFilterSelectedProvider) == MatchFilterType.live) {
          final leagues = ref.read(leaguesV2Provider);
          ref.read(lastLiveLeaguesCacheProvider.notifier).state =
              leagues.isNotEmpty ? leagues : null;
        }
        ref.read(matchFilterProvider.notifier).clearContentLoading();
      }
    });

    final hotMatches = ref.watch(_hotMatchesSelector);
    final isHotMatchLoading = ref.watch(_hotMatchLoadingSelector);

    final isMobile = ResponsiveBuilder.isMobile(context);
    final isTablet = ResponsiveBuilder.isTablet(context);
    final itemsToShow = isMobile ? 1 : (isTablet ? 2 : 3);
    final maxStart = (hotMatches.length - itemsToShow).clamp(
      0,
      hotMatches.length,
    );

    if (hotMatches.isNotEmpty && _currentIndex > maxStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = maxStart);
      });
    }

    final currentMatch = hotMatches.isNotEmpty
        ? hotMatches[_currentIndex]
        : null;

    void goToPrevious() {
      if (hotMatches.isEmpty) return;
      final newIndex = (_currentIndex - 1).clamp(0, maxStart);
      setState(() => _currentIndex = newIndex);
      ref.read(hotMatchProvider.notifier).setPageIndex(newIndex);
    }

    void goToNext() {
      if (hotMatches.isEmpty) return;
      final newIndex = (_currentIndex + 1).clamp(0, maxStart);
      setState(() => _currentIndex = newIndex);
      ref.read(hotMatchProvider.notifier).setPageIndex(newIndex);
    }

    final showNavigation = hotMatches.length > itemsToShow;
    final isFirstItem = _currentIndex == 0;
    final isLastItem = _currentIndex >= maxStart;

    void onMatchTap(HotMatchEventV2 match) {
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

    void onOddsTap(
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
      final sportId = ref.read(_currentSportIdSelector);
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

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MatchFilterTabs(),
          if (!showUpcomingFavorites) ...[
            if (hotMatches.isNotEmpty)
              // RepaintBoundary: tách HotMatch khỏi list bên dưới (scroll, odds flash)
              RepaintBoundary(
                child: Consumer(
                  builder: (context, ref, _) {
                    final sportId = ref.watch(_currentSportIdSelector);
                    final handicapMarket = currentMatch?.getHandicapMarket(
                      sportId,
                    );
                    final handicapOdds = handicapMarket?.mainLineOdds;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                      child: HotMatchContainer(
                        match: currentMatch!,
                        matches: hotMatches,
                        currentIndex: _currentIndex,
                        onPrevious: showNavigation ? goToPrevious : null,
                        onNext: showNavigation ? goToNext : null,
                        onTap: () => onMatchTap(currentMatch),
                        onOddsTap: handicapOdds != null
                            ? (odds, isHome, mid) => onOddsTap(
                                context,
                                currentMatch,
                                odds,
                                isHome,
                                mid,
                              )
                            : null,
                        favoredTeam: currentMatch.awayName,
                        isFirstItem: isFirstItem,
                        isLastItem: isLastItem,
                        isRightSidebar: false,
                      ),
                    );
                  },
                ),
              )
            else if (isHotMatchLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                child: HotMatchShimmerLoading(isRightSidebar: false),
              ),
            const SportDesktopTypeFilterTabs(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _buildLiveContent(ref),
            ),
            const SizedBox(height: 16),
            const SportDesktopPopularLeagueSection(),
          ],
          if (showUpcomingFavorites)
            SportListEventContainer(
              filter: selectedFilter,
              maxHeight: MediaQuery.sizeOf(context).height,
            ),
        ],
      ),
    );
  }

  static const int _maxLiveEvents = 5;

  /// Sảnh tab: container with header, sport filter tabs, and content
  /// The container + header + filter tabs are always visible.
  /// Content below tabs changes: leagues / empty state / shimmer loading.
  Widget _buildLiveContent(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FFFFFFF),
            offset: Offset(0, 0.5),
            blurRadius: 0.5,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "Đang diễn ra"
          _buildLiveHeader(),
          // Sport filter tabs (always visible)
          _buildSportFilterTabs(),
          // Content: shimmer / empty / leagues — isolated via Consumer
          // isLoading is true when: (1) initial fetch, (2) filter change (sport/timeRange),
          // (3) refresh() e.g. switching to Live tab, (4) reconnect.
          Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(
                eventsV2Provider.select((s) => s.isLoading),
              );
              final cachedLive = ref.watch(lastLiveLeaguesCacheProvider);

              if (isLoading && cachedLive != null && cachedLive.isNotEmpty) {
                final nonEmpty = cachedLive
                    .where((l) => l.events.isNotEmpty)
                    .toList();
                if (nonEmpty.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildLeagueWidgets(nonEmpty),
                      _buildViewAllButton(ref),
                    ],
                  );
                }
              }

              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SportShimmerLoading(isDesktop: true),
                  ),
                );
              }

              final leagues = ref.watch(leaguesV2Provider);
              final nonEmpty = leagues
                  .where((l) => l.events.isNotEmpty)
                  .toList();

              if (nonEmpty.isEmpty) return const SportEmptyPage();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildLeagueWidgets(nonEmpty),
                  _buildViewAllButton(ref),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build "Xem tất cả" button to navigate to sport detail
  Widget _buildViewAllButton(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () {
          ref.read(previousContentProvider.notifier).state =
              MainContentType.sport;
          ref.read(selectedSportV2Provider.notifier).state = ref.read(
            selectedSportV2Provider,
          );
          ref.read(mainContentProvider.notifier).goToSportDetail();
        },
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF393836),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem tất cả',
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFEF5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build league card widgets, capped at [_maxLiveEvents] total events.
  /// Single-pass: iterate leagues in order, take events until the cap is reached.
  List<Widget> _buildLeagueWidgets(List<LeagueModelV2> leagues) {
    final result = <Widget>[];
    var remaining = _maxLiveEvents;

    for (final league in leagues) {
      if (remaining <= 0) break;

      final events = league.events;
      if (events.isEmpty) continue;

      final displayLeague = events.length <= remaining
          ? league
          : league.copyWith(events: events.sublist(0, remaining));

      result.add(LeagueCardV2(league: displayLeague, isDesktop: true));
      remaining -= displayLeague.events.length;
    }

    return result;
  }

  /// Build sport filter tabs (similar design to SportDetailFilterTabs)
  /// Filters leagues by sport type: Bóng đá, Tennis, Bóng rổ, Bóng chuyền
  Widget _buildSportFilterTabs() {
    final sports = sportDesktopTypeFilterItems;
    final selectedSportId = ref.watch(
      selectedSportV2Provider.select((s) => s.id),
    );

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: Row(
        children: sports.map((sport) {
          final isSelected = sport.sportId == selectedSportId;
          return Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _onSportFilterTap(sport),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageHelper.load(
                            path: isSelected
                                ? sport.iconSelected
                                : sport.iconDisabled,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sport.name,
                            style: AppTextStyles.paragraphXSmall(
                              color: isSelected
                                  ? AppColors.yellow300
                                  : const Color(0xFF9C9B95),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        left: -20,
                        right: -20,
                        child: ImageHelper.load(
                          path: AppIcons.sportStatusSelected,
                          fit: BoxFit.fill,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onSportFilterTap(SportDesktopTypeFilterItem sport) {
    final sportType = v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
    ref.read(selectedSportV2Provider.notifier).state = sportType;
    ref
        .read(sportSocketAdapterProvider)
        .subscriptionManager
        .setActiveSport(sport.sportId);
  }

  /// Build header "Đang diễn ra" with live icon
  Widget _buildLiveHeader() {
    return Container(
      // height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
      ).copyWith(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Row(
        children: [
          // Live icon (red pulse dot)
          _buildLiveIcon(),
          const SizedBox(width: 6),
          // Title
          Text(
            'Đang diễn ra',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFEF5), // content/primary
            ),
          ),
        ],
      ),
    );
  }

  /// Build live icon with pulse effect (red dot with opacity rings)
  Widget _buildLiveIcon() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (opacity 0.12)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438), // red/500 with 12% opacity
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 16, height: 16),
          ),
          // Middle ring (opacity 0.12)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438), // red/500 with 12% opacity
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 11, height: 11),
          ),
          // Inner dot (solid)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF04438), // red/500
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 6, height: 6),
          ),
        ],
      ),
    );
  }
}
