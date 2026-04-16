import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/models/sport_enums.dart';
// V2 imports - using V2 models directly without legacy conversion
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_card_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';

// Re-export for backward compatibility
export 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';

/// Simple data class for sport info display
class _SportData {
  final String name;
  final String icon;
  final int sportId;

  const _SportData({
    required this.name,
    required this.icon,
    required this.sportId,
  });
}

/// Sport detail matches section for mobile - V2 Version
///
/// Uses EventsV2Provider for data fetching.
/// Uses Column to render leagues - parent handles scrolling via CustomScrollView
class SportDetailMobileMatchesSection extends ConsumerStatefulWidget {
  final ValueNotifier<ScrollNotification?>? scrollNotifier;

  const SportDetailMobileMatchesSection({super.key, this.scrollNotifier});

  @override
  ConsumerState<SportDetailMobileMatchesSection> createState() =>
      _SportDetailMobileMatchesSectionState();
}

class _SportDetailMobileMatchesSectionState
    extends ConsumerState<SportDetailMobileMatchesSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sync tab provider with current time range in V2 filter
      final timeRange = ref.read(selectedTimeRangeV2Provider);
      final currentTab = _v2TimeRangeToFilterType(timeRange);

      // If tab is "Đặc biệt" but sportId != 1, switch to "Trực tiếp"
      final sportId = ref.read(selectedSportV2Provider).id;
      final finalTab =
          (currentTab == SportDetailFilterType.special && sportId != 1)
          ? SportDetailFilterType.live
          : currentTab;

      ref.read(sportDetailTabProvider.notifier).state = finalTab;
    });
  }

  /// Convert V2 EventTimeRange to SportDetailFilterType
  SportDetailFilterType _v2TimeRangeToFilterType(v2.EventTimeRange timeRange) {
    switch (timeRange) {
      case v2.EventTimeRange.live:
        return SportDetailFilterType.live;
      case v2.EventTimeRange.today:
        return SportDetailFilterType.today;
      case v2.EventTimeRange.early:
        return SportDetailFilterType.early;
      case v2.EventTimeRange.todayAndEarly:
        return SportDetailFilterType.today;
    }
  }

  /// Convert SportDetailFilterType to V2 EventTimeRange
  v2.EventTimeRange _filterTypeToV2TimeRange(SportDetailFilterType filter) {
    switch (filter) {
      case SportDetailFilterType.live:
        return v2.EventTimeRange.live;
      case SportDetailFilterType.today:
        return v2.EventTimeRange.today;
      case SportDetailFilterType.early:
        return v2.EventTimeRange.early;
      case SportDetailFilterType.special:
      case SportDetailFilterType.favorites:
        return v2.EventTimeRange.live;
    }
  }

  /// Handle tab selection change
  void _onFilterChanged(SportDetailFilterType filter) {
    final currentTimeRange = ref.read(selectedTimeRangeV2Provider);
    final newTimeRange = _filterTypeToV2TimeRange(filter);

    // Update UI tab provider
    ref.read(sportDetailTabProvider.notifier).state = filter;

    // Update V2 filter provider (this will trigger data refetch)
    if (currentTimeRange != newTimeRange &&
        filter != SportDetailFilterType.special) {
      ref.read(selectedTimeRangeV2Provider.notifier).state = newTimeRange;

      // Update socket subscription (V2 protocol: unsub old timeRange / sub new timeRange)
      final timeRangeStr = _timeRangeToString(newTimeRange);
      ref
          .read(sportSocketAdapterProvider)
          .subscriptionManager
          .setTimeRangeFromString(timeRangeStr);
    }
  }

  String _timeRangeToString(v2.EventTimeRange timeRange) {
    switch (timeRange) {
      case v2.EventTimeRange.live:
        return 'LIVE';
      case v2.EventTimeRange.today:
        return 'TODAY';
      case v2.EventTimeRange.early:
        return 'EARLY';
      case v2.EventTimeRange.todayAndEarly:
        return 'TODAY';
    }
  }

  _SportData _getSportName(int sportId) {
    final sport = SportType.fromId(sportId);
    switch (sport) {
      case SportType.soccer:
        return _SportData(
          name: 'Bóng đá',
          icon: AppIcons.iconFootballSelected,
          sportId: SportType.soccer.id,
        );
      case SportType.tennis:
        return _SportData(
          name: 'Tennis',
          icon: AppIcons.iconTennisSelected,
          sportId: SportType.tennis.id,
        );
      case SportType.basketball:
        return _SportData(
          name: 'Bóng rổ',
          icon: AppIcons.iconBasketballSelected,
          sportId: SportType.basketball.id,
        );
      case SportType.volleyball:
        return _SportData(
          name: 'Bóng chuyền',
          icon: AppIcons.iconVolleyballSelected,
          sportId: SportType.volleyball.id,
        );
      case SportType.tableTennis:
        return _SportData(
          name: 'Bóng bàn',
          icon: AppIcons.iconTableTennisSelected,
          sportId: SportType.tableTennis.id,
        );
      case SportType.badminton:
        return _SportData(
          name: 'Cầu lông',
          icon: AppIcons.iconBadmintonSelected,
          sportId: SportType.badminton.id,
        );
      default:
        return _SportData(
          name: 'Bóng đá',
          icon: AppIcons.iconFootballSelected,
          sportId: SportType.soccer.id,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ═══════════════════════════════════════════════════════════════════════
    // PERFORMANCE: Use ref.listen for side effects, Consumer for isolated rebuilds
    // ═══════════════════════════════════════════════════════════════════════

    // Listen for tab/sport changes to auto-switch from "Đặc biệt" tab
    ref.listen(sportDetailTabProvider, (previous, currentTab) {
      if (currentTab == SportDetailFilterType.special) {
        final sportId = ref.read(selectedSportV2Provider).id;
        if (sportId != 1) {
          ref.read(sportDetailTabProvider.notifier).state =
              SportDetailFilterType.live;
        }
      }
    });

    ref.listen(selectedSportV2Provider.select((s) => s.id), (
      previous,
      currentSportId,
    ) {
      final currentTab = ref.read(sportDetailTabProvider);
      if (currentTab == SportDetailFilterType.special && currentSportId != 1) {
        ref.read(sportDetailTabProvider.notifier).state =
            SportDetailFilterType.live;
      }
    });

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1B1A19)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sport name - only rebuilds when sportId changes
          Consumer(
            builder: (context, ref, _) {
              final currentSportId = ref.watch(
                selectedSportV2Provider.select((s) => s.id),
              );
              return _buildSportNameSelected(currentSportId);
            },
          ),
          // Filter tabs - only rebuilds when tab or sportId changes
          Consumer(
            builder: (context, ref, _) {
              final selectedFilter = ref.watch(sportDetailTabProvider);
              final currentSportId = ref.watch(
                selectedSportV2Provider.select((s) => s.id),
              );
              return _buildFilterTabs(selectedFilter, currentSportId);
            },
          ),
          // Content area - only rebuilds when loading/leagues/timeRange changes
          Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(
                eventsV2Provider.select((s) => s.isLoading),
              );
              final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);
              final leagues = ref.watch(leaguesV2Provider);

              // Filter out live events for TODAY and EARLY tabs
              final List<LeagueModelV2> filteredLeagues;
              if (currentTimeRange == v2.EventTimeRange.today ||
                  currentTimeRange == v2.EventTimeRange.early) {
                filteredLeagues = leagues
                    .map(
                      (l) => l.copyWith(
                        events: l.events
                            .where((e) => e.isLive != true)
                            .toList(),
                      ),
                    )
                    .where((l) => l.events.isNotEmpty)
                    .toList();
              } else {
                filteredLeagues = leagues;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: isLoading
                    ? const SportShimmerLoading(isDesktop: false)
                    : filteredLeagues.isEmpty
                    ? const SportEmptyPage()
                    : _buildLeaguesList(filteredLeagues),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSportNameSelected(int currentSportId) {
    final currentSport = _getSportName(currentSportId);
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        children: [
          ImageHelper.load(path: currentSport.icon, width: 24, height: 24),
          const SizedBox(width: 6),
          Text(
            currentSport.name,
            style: AppTextStyles.textStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build leagues list - simple Column, parent handles scrolling
  Widget _buildLeaguesList(List<LeagueModelV2> leagues) {
    final nonEmptyLeagues = leagues.where((l) => l.events.isNotEmpty).toList();
    if (nonEmptyLeagues.isEmpty) return const SportEmptyPage();

    return Column(
      children: nonEmptyLeagues.map((league) {
        return RepaintBoundary(
          key: ValueKey('repaint_league_${league.leagueId}'),
          child: LeagueCardV2(
            key: ValueKey('league_${league.leagueId}'),
            league: league,
          ),
        );
      }).toList(),
    );
  }

  /// Build filter tabs
  Widget _buildFilterTabs(
    SportDetailFilterType selectedFilter,
    int currentSportId,
  ) {
    // Filter: only show "Đặc biệt" tab when sportId == 1 (bóng đá)
    final filters = SportDetailFilterType.values
        .where(
          (filter) =>
              filter != SportDetailFilterType.special || currentSportId == 1,
        )
        .toList();

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;

            return GestureDetector(
              onTap: () => _onFilterChanged(filter),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    child: Center(
                      child: Text(
                        filter.label,
                        style: AppTextStyles.textStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.yellow300
                              : const Color(0xFF9C9B95),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
