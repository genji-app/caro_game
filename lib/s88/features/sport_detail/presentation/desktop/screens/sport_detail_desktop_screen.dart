import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// V2 imports - using V2 models directly without legacy conversion
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/scroll_aware_controller.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/desktop/widgets/sport_detail_desktop_header.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/widgets/sport_detail_filter_tabs.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/widgets/sport_detail_special.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/rive_vibrating/rive_vibrating.dart';

/// Sport Detail Desktop Screen - V2 Version
///
/// Uses EventsV2Provider and LeagueModelV2 directly without legacy conversion.
///
/// Uses TRUE VIRTUALIZATION with LeagueEventsSliverV2:
/// - Only visible items are built (+ cache extent)
/// - Supports 100+ events with smooth 60fps scrolling
class SportDetailDesktopScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const SportDetailDesktopScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<SportDetailDesktopScreen> createState() =>
      _SportDetailDesktopScreenState();
}

class _SportDetailDesktopScreenState
    extends ConsumerState<SportDetailDesktopScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-load Rive animation for vibrating odds (Kèo Rung)
      // Chỉ trigger một lần, không gây rebuild
      ref.read(riveVibratingInitProvider);

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

      // Listen for sport changes to auto-switch from "Đặc biệt" tab
      ref.listenManual(selectedSportV2Provider.select((s) => s.id), (
        previous,
        next,
      ) {
        final tab = ref.read(sportDetailTabProvider);
        if (tab == SportDetailFilterType.special && next != 1) {
          ref.read(sportDetailTabProvider.notifier).state =
              SportDetailFilterType.live;
        }
      });
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
        return v2
            .EventTimeRange
            .live; // Default, special/favorites handled separately
    }
  }

  void _onFilterChanged(SportDetailFilterType filter) {
    final currentTimeRange = ref.read(selectedTimeRangeV2Provider);
    final newTimeRange = _filterTypeToV2TimeRange(filter);

    // Update UI tab provider
    ref.read(sportDetailTabProvider.notifier).state = filter;

    // Mỗi khi chọn tab Yêu thích thì gọi API fetchFavoriteEvents
    if (filter == SportDetailFilterType.favorites) {
      final sportId = ref.read(selectedSportV2Provider).id;
      ref
          .read(favoriteProvider.notifier)
          .fetchFavoriteEvents(sportId, forceRefresh: true);
    }

    // Don't change time range for Special/Favorites – they use their own data source
    // (Special: special API; Favorites: GET /api/app/favorite/events)
    if (currentTimeRange != newTimeRange &&
        filter != SportDetailFilterType.special &&
        filter != SportDetailFilterType.favorites) {
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
    // ═══════════════════════════════════════════════════════════════════════════
    // Side effects via ref.listen - không gây rebuild toàn bộ widget
    // ═══════════════════════════════════════════════════════════════════════════

    // Pre-fetch favorites when sport changes
    ref.listen(selectedSportV2Provider.select((s) => s.id), (previous, next) {
      if (previous != next) {
        final favState = ref.read(favoriteProvider);
        if (favState.getFavoriteData(next) == null) {
          ref.read(favoriteProvider.notifier).fetchFavorites(next);
        }
      }
    });

    // Auto-fetch favorite events when switching to Favorites tab
    ref.listen(sportDetailTabProvider, (previous, next) {
      if (next == SportDetailFilterType.favorites) {
        final sportId = ref.read(selectedSportV2Provider).id;
        final favState = ref.read(favoriteProvider);
        if (favState.getFavoriteEventsLeagues(sportId) == null &&
            !favState.isFavoriteEventsLoading(sportId)) {
          ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId);
        }
      }
    });

    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: BackToTopWrapper(
              builder: (scrollController) =>
                  NotificationListener<ScrollNotification>(
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
                  // Header with back button
                  SliverToBoxAdapter(
                    child: RepaintBoundary(
                      child: SportDetailDesktopHeader(
                        onBackPressed: widget.onBackPressed,
                      ),
                    ),
                  ),

                  // Main content container
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1A19),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filter tabs
                          SportDetailFilterTabs(
                            isDesktop: true,
                            onFilterChanged: _onFilterChanged,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content area - Consumer isolates rebuilds to this section only
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 0,
                    ),
                    sliver: Consumer(
                      builder: (context, ref, _) {
                        final selectedFilter = ref.watch(
                          sportDetailTabProvider,
                        );
                        final currentSportId = ref.watch(
                          selectedSportV2Provider.select((s) => s.id),
                        );

                        // Auto-switch from "Đặc biệt" to "Trực tiếp" if sportId != 1
                        if (selectedFilter == SportDetailFilterType.special &&
                            currentSportId != 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(sportDetailTabProvider.notifier).state =
                                SportDetailFilterType.live;
                          });
                          // Return loading while switching
                          return const SliverToBoxAdapter(
                            child: SportShimmerLoading(isDesktop: true),
                          );
                        }

                        // Show special widget when "Đặc biệt" tab is selected
                        // Returns SliverList for virtualized scroll (smooth performance)
                        if (selectedFilter == SportDetailFilterType.special) {
                          return const SportDetailMobileSpecial();
                        }

                        // ═══════════════════════════════════════════════════════════
                        // Favorites tab - uses separate data source
                        // ═══════════════════════════════════════════════════════════
                        if (selectedFilter == SportDetailFilterType.favorites) {
                          return _FavoritesContent(
                            sportId: currentSportId,
                            buildEmptyState: _buildEmptyState,
                          );
                        }

                        // ═══════════════════════════════════════════════════════════
                        // Regular tabs (Live/Today/Early) - uses eventsV2Provider
                        // ═══════════════════════════════════════════════════════════
                        return _EventsContent(
                          buildEmptyState: _buildEmptyState,
                        );
                      },
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildEmptyState() => const SportEmptyPage();
}

/// Separate ConsumerWidget for Favorites content - isolates rebuilds
class _FavoritesContent extends ConsumerWidget {
  final int sportId;
  final Widget Function() buildEmptyState;

  const _FavoritesContent({
    required this.sportId,
    required this.buildEmptyState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ watch những gì cần thiết cho Favorites
    final isLoading = ref.watch(
      favoriteProvider.select((s) => s.isFavoriteEventsLoading(sportId)),
    );

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: true),
      );
    }

    final favoriteLeagues = ref.watch(
      favoriteProvider.select((s) => s.getFavoriteEventsLeagues(sportId)),
    );

    final nonEmptyLeagues = (favoriteLeagues ?? [])
        .where((l) => l.events.isNotEmpty)
        .toList();

    if (nonEmptyLeagues.isEmpty) {
      return SliverToBoxAdapter(child: buildEmptyState());
    }

    return LeagueEventsSliverV2(
      leagues: nonEmptyLeagues,
      isDesktop: true,
      showBackToTop: false,
    );
  }
}

/// Separate ConsumerWidget for Events content (Live/Today/Early) - isolates rebuilds
class _EventsContent extends ConsumerWidget {
  final Widget Function() buildEmptyState;

  const _EventsContent({required this.buildEmptyState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ watch isLoading - không rebuild khi data thay đổi nếu vẫn loading
    final isLoading = ref.watch(
      eventsV2Provider.select((state) => state.isLoading),
    );

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SportShimmerLoading(isDesktop: true),
      );
    }

    // Watch leagues và timeRange cho content
    final leagues = ref.watch(leaguesV2Provider);
    final currentTimeRange = ref.watch(selectedTimeRangeV2Provider);

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

    final nonEmptyLeagues = filteredLeagues
        .where((l) => l.events.isNotEmpty)
        .toList();

    if (nonEmptyLeagues.isEmpty) {
      return SliverToBoxAdapter(child: buildEmptyState());
    }

    return LeagueEventsSliverV2(
      leagues: nonEmptyLeagues,
      isDesktop: true,
      showBackToTop: false,
    );
  }
}
