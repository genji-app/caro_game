import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/tab_layout/s88_tab.dart'
    show S88Tab, S88TabItem, sportTabItems, sportIds;

/// Match filter type for the live matches section (Sảnh / Sắp diễn ra / Yêu thích)
enum MatchFilterType { live, upcoming, favorites }

/// Selected sport ID in S88 tab (when showing Upcoming or Favorites container)
final _s88TabSportIdProvider = StateProvider.autoDispose<int>((ref) => 1);

/// Shared container for tab "Sắp diễn ra" or "Yêu thích":
/// - S88 tab (Bóng đá, Bóng rổ, Bóng chuyền, Quần vợt)
/// - League list below
///
/// [maxHeight] when set (e.g. desktop/tablet in scroll) gives the container a
/// fixed height instead of using [Expanded]; pass null on mobile when inside [Expanded].
class SportListEventContainer extends ConsumerStatefulWidget {
  final MatchFilterType filter;

  /// If set, container uses SizedBox(height: maxHeight) for content area instead of Expanded.
  final double? maxHeight;

  const SportListEventContainer({
    super.key,
    required this.filter,
    this.maxHeight,
  });

  @override
  ConsumerState<SportListEventContainer> createState() =>
      _SportListEventContainerState();
}

class _SportListEventContainerState
    extends ConsumerState<SportListEventContainer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncFilterAndSport(ref),
    );
  }

  @override
  void didUpdateWidget(SportListEventContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncFilterAndSport(ref);
      });
    }
  }

  void _applySportAndFilter(WidgetRef ref, int sportId) {
    ref.read(selectedSportV2Provider.notifier).state =
        v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
    if (widget.filter == MatchFilterType.upcoming) {
      ref.read(selectedTimeRangeV2Provider.notifier).state =
          v2.EventTimeRange.early;
      final sub = ref.read(sportSocketAdapterProvider).subscriptionManager;
      sub.setActiveSport(sportId);
      sub.setTimeRangeFromString('EARLY');
    } else if (widget.filter == MatchFilterType.favorites) {
      ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId);
    }
  }

  void _syncFilterAndSport(WidgetRef ref) {
    _applySportAndFilter(ref, ref.read(_s88TabSportIdProvider));
  }

  void _onS88TabChanged(WidgetRef ref, int index) {
    final sportId = sportIds[index];
    ref.read(_s88TabSportIdProvider.notifier).state = sportId;
    _applySportAndFilter(ref, sportId);
  }

  @override
  Widget build(BuildContext context) {
    final selectedSportId = ref.watch(_s88TabSportIdProvider);
    final selectedIndex = sportIds.indexOf(selectedSportId);
    final clampedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        // RepaintBoundary: tab bar không repaint khi list bên dưới scroll/cập nhật
        RepaintBoundary(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
              ),
            ),
            padding: const EdgeInsets.only(top: 8),
            child: S88Tab(
              tabs: sportTabItems,
              selectedIndex: clampedIndex,
              onTabChanged: (index) => _onS88TabChanged(ref, index),
              backgroundColor: Colors.transparent,
              defaultColor: AppColorStyles.contentPrimary,
              selectedColor: AppColors.yellow300,
              isScrollable: true,
              scrollableTabWidth: 100,
            ),
          ),
        ),
        const Gap(8),
        if (widget.maxHeight != null)
          BackToTopWrapper(
            builder: (scrollController) => SizedBox(
              height: widget.maxHeight!,
              child: RepaintBoundary(
                child: SportLeagueEventsContent(
                  filter: widget.filter,
                  sportId: selectedSportId,
                  scrollController: scrollController,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RepaintBoundary(
              child: SportLeagueEventsContent(
                filter: widget.filter,
                sportId: selectedSportId,
              ),
            ),
          ),
      ],
    );
  }
}

/// Content below S88 tab: league list (upcoming or favorites data).
/// Public để dùng trong TopLeagueDesktopScreen (Expanded + RepaintBoundary + SportLeagueEventsContent).
/// When [scrollController] is set (e.g. desktop with BackToTopWrapper), it is
/// attached to the CustomScrollView for back-to-top.
class SportLeagueEventsContent extends ConsumerWidget {
  final MatchFilterType filter;
  final int sportId;
  final ScrollController? scrollController;

  const SportLeagueEventsContent({
    super.key,
    required this.filter,
    required this.sportId,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter == MatchFilterType.favorites) {
      final (isLoading, leagues) = ref.watch(
        favoriteProvider.select(
          (s) => (
            s.isFavoriteEventsLoading(sportId),
            s.getFavoriteEventsLeagues(sportId),
          ),
        ),
      );

      if (!isLoading && leagues == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId);
        });
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: SportShimmerLoading(isDesktop: false),
          ),
        );
      }

      if (isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(0),
            child: SportShimmerLoading(isDesktop: false),
          ),
        );
      }
      final nonEmpty =
          leagues?.where((l) => l.events.isNotEmpty).toList() ?? [];
      if (nonEmpty.isEmpty) {
        return const SportEmptyPage();
      }
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          LeagueEventsSliverV2(leagues: nonEmpty, isDesktop: false),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: 80 + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      );
    }

    // Upcoming: isLoading isolated so list only rebuilds when leagues/timeRange change
    final isLoading = ref.watch(eventsV2Provider.select((s) => s.isLoading));
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(0),
          child: SportShimmerLoading(isDesktop: false),
        ),
      );
    }
    return Consumer(
      builder: (context, ref, _) {
        final leagues = ref.watch(leaguesV2Provider);
        final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);
        final filteredLeagues =
            (currentTimeRange == v2.EventTimeRange.today ||
                currentTimeRange == v2.EventTimeRange.early)
            ? leagues
                  .map(
                    (l) => l.copyWith(
                      events: l.events
                          .where((e) => e.isLive != true)
                          .toList(),
                    ),
                  )
                  .where((l) => l.events.isNotEmpty)
                  .toList()
            : leagues.where((l) => l.events.isNotEmpty).toList();

        if (filteredLeagues.isEmpty) {
          return const SportEmptyPage();
        }
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            LeagueEventsSliverV2(leagues: filteredLeagues, isDesktop: false),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        );
      },
    );
  }
}
