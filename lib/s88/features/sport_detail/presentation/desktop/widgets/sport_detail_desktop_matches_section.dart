import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// V2 imports - using V2 models directly without legacy conversion
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_card_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';

/// Sport detail matches section for desktop - V2 Version
///
/// Uses EventsV2Provider for data fetching.
/// Uses Column to render leagues - parent handles scrolling via CustomScrollView
class SportDetailDesktopMatchesSection extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const SportDetailDesktopMatchesSection({
    super.key,
    required this.scrollController,
  });

  @override
  ConsumerState<SportDetailDesktopMatchesSection> createState() =>
      _SportDetailDesktopMatchesSectionState();
}

class _SportDetailDesktopMatchesSectionState
    extends ConsumerState<SportDetailDesktopMatchesSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sync tab provider with current time range in V2 filter
      final timeRange = ref.read(selectedTimeRangeV2Provider);
      ref.read(sportDetailTabProvider.notifier).state =
          _v2TimeRangeToFilterType(timeRange);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tabs - isolated rebuild
          Consumer(
            builder: (context, ref, _) {
              final selectedFilter = ref.watch(sportDetailTabProvider);
              // Chỉ watch sportId thay vì toàn bộ object
              final currentSportId = ref.watch(
                selectedSportV2Provider.select((sport) => sport.id),
              );
              return _buildFilterTabs(selectedFilter, currentSportId);
            },
          ),
          // Content area - isolated rebuild
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, _) {
                // Chỉ watch isLoading thay vì toàn bộ eventsState
                final isLoading = ref.watch(
                  eventsV2Provider.select((state) => state.isLoading),
                );

                if (isLoading) {
                  return const SportShimmerLoading(isDesktop: true);
                }

                return _buildLeaguesContent(ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build leagues content - tách riêng để chỉ rebuild khi leagues thay đổi
  Widget _buildLeaguesContent(WidgetRef ref) {
    final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);
    final List<LeagueModelV2> leagues = ref.watch(leaguesV2Provider);

    // Filter out live events for TODAY and EARLY tabs
    final List<LeagueModelV2> filteredLeagues;
    if (currentTimeRange == v2.EventTimeRange.today ||
        currentTimeRange == v2.EventTimeRange.early) {
      filteredLeagues = leagues
          .map(
            (l) => l.copyWith(
              events: l.events.where((e) => e.isLive != true).toList(),
            ),
          )
          .where((l) => l.events.isNotEmpty)
          .toList();
    } else {
      filteredLeagues = leagues;
    }

    if (filteredLeagues.isEmpty) {
      return const SportEmptyPage();
    }

    return _buildLeaguesList(filteredLeagues);
  }

  /// Build leagues list - simple Column, parent handles scrolling
  Widget _buildLeaguesList(List<LeagueModelV2> leagues) {
    final nonEmptyLeagues = leagues.where((l) => l.events.isNotEmpty).toList();
    if (nonEmptyLeagues.isEmpty) return const SportEmptyPage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: nonEmptyLeagues.map((league) {
        return RepaintBoundary(
          key: ValueKey('repaint_league_${league.leagueId}'),
          child: LeagueCardV2(
            key: ValueKey('league_${league.leagueId}'),
            league: league,
            isDesktop: true,
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
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(filter),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ImageHelper.load(
                        path: AppIcons.sportStatusSelected,
                        fit: BoxFit.fill,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    child: Center(
                      child: Text(
                        filter.label,
                        style: AppTextStyles.textStyle(
                          fontSize: 14,
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
