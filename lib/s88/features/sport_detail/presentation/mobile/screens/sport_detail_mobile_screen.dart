import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/models/sport_enums.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
// V2 imports - using V2 models directly without legacy conversion
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/scroll_aware_controller.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/widgets/sport_detail_special.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/widgets/sport_detail_filter_tabs.dart';
import 'package:co_caro_flame/s88/shared/widgets/authenticated_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/rive_vibrating/rive_vibrating.dart';

/// Sport Detail Mobile Screen - V2 Version
///
/// Uses EventsV2Provider and LeagueModelV2 directly without legacy conversion.
///
/// Uses TRUE VIRTUALIZATION with LeagueEventsSliverV2:
/// - Only visible items are built (+ cache extent)
/// - Supports 100+ events with smooth 60fps scrolling
class SportDetailMobileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const SportDetailMobileScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<SportDetailMobileScreen> createState() =>
      _SportDetailMobileScreenState();
}

class _SportDetailMobileScreenState
    extends ConsumerState<SportDetailMobileScreen> {
  // Live chat heights - must match SportLiveChat
  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

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
      // Favorites (getFavorites) are fetched by leaguesV2Provider when favoriteData is null – avoid duplicate call from here

      // Pre-fetch favorites when sport changes (moved from build to avoid rebuild)
      ref.listenManual(selectedSportV2Provider, (previous, next) {
        if (previous?.id != next.id) {
          final favoriteState = ref.read(favoriteProvider);
          if (favoriteState.getFavoriteData(next.id) == null) {
            ref.read(favoriteProvider.notifier).fetchFavorites(next.id);
          }
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
        return 'TODAY'; // Default to TODAY for combined
    }
  }

  @override
  Widget build(BuildContext context) {
    // All provider watches moved to Consumer widgets for isolated rebuilds
    return Container(
      color: AppColorStyles.backgroundPrimary,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: NotificationListener<ScrollNotification>(
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
            slivers: [
              const SliverToBoxAdapter(child: Gap(12)),

              // Live Chat - sticky when scrolling (isolated rebuild)
              Consumer(
                builder: (context, ref, _) {
                  final isAuthenticated = ref.watch(isAuthenticatedProvider);
                  if (!isAuthenticated) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  final isExpanded = ref.watch(liveChatExpandedProvider);
                  final liveChatHeight = isExpanded
                      ? _expandedHeight
                      : _collapsedHeight;
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyLiveChatDelegate(
                      minHeight: liveChatHeight,
                      maxHeight: liveChatHeight,
                    ),
                  );
                },
              ),

              // Sport name header (only rebuilds when sportId changes)
              Consumer(
                builder: (context, ref, _) {
                  final currentSportId = ref.watch(
                    selectedSportV2Provider.select((s) => s.id),
                  );
                  return SliverToBoxAdapter(
                    child: _buildSportNameSelected(currentSportId),
                  );
                },
              ),

              // Filter tabs
              SliverToBoxAdapter(
                child: SportDetailFilterTabs(
                  isDesktop: false,
                  onFilterChanged: _onFilterChanged,
                ),
              ),

              // Content area with padding (isolated rebuild for data changes)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                sliver: Consumer(
                  builder: (context, ref, _) {
                    final selectedFilter = ref.watch(sportDetailTabProvider);
                    final currentSportId = ref.watch(
                      selectedSportV2Provider.select((s) => s.id),
                    );

                    // Auto-switch from "Đặc biệt" tab to "Trực tiếp" if sportId != 1
                    if (selectedFilter == SportDetailFilterType.special &&
                        currentSportId != 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ref.read(sportDetailTabProvider.notifier).state =
                              SportDetailFilterType.live;
                        }
                      });
                    }

                    // Show special widget when "Đặc biệt" tab is selected
                    // Returns SliverList for virtualized scroll (smooth performance)
                    if (selectedFilter == SportDetailFilterType.special) {
                      return const SportDetailMobileSpecial();
                    }

                    // ═══════════════════════════════════════════════════════════════════════════
                    // Favorites tab: uses GET /api/app/favorite/events
                    // ═══════════════════════════════════════════════════════════════════════════
                    if (selectedFilter == SportDetailFilterType.favorites) {
                      // Use select to only watch specific parts of favorite state
                      final isLoading = ref.watch(
                        favoriteProvider.select(
                          (s) => s.isFavoriteEventsLoading(currentSportId),
                        ),
                      );
                      final favoriteLeagues =
                          ref.watch(
                            favoriteProvider.select(
                              (s) => s.getFavoriteEventsLeagues(currentSportId),
                            ),
                          ) ??
                          [];

                      // Fallback: fetch if not loaded yet
                      if (!isLoading && favoriteLeagues.isEmpty) {
                        Future.microtask(() {
                          ref
                              .read(favoriteProvider.notifier)
                              .fetchFavoriteEvents(currentSportId);
                        });
                      }

                      if (isLoading) {
                        return const SliverToBoxAdapter(
                          child: SportShimmerLoading(isDesktop: false),
                        );
                      }

                      final nonEmptyLeagues = favoriteLeagues
                          .where((l) => l.events.isNotEmpty)
                          .toList();

                      if (nonEmptyLeagues.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SportEmptyPage(),
                        );
                      }

                      return LeagueEventsSliverV2(
                        leagues: nonEmptyLeagues,
                        isDesktop: false,
                      );
                    }

                    // ═══════════════════════════════════════════════════════════════════════════
                    // Regular tabs (Live, Today, Early): uses leaguesV2Provider
                    // ═══════════════════════════════════════════════════════════════════════════
                    // Watch loading state using select
                    final isLoading = ref.watch(
                      eventsV2Provider.select((s) => s.isLoading),
                    );

                    if (isLoading) {
                      return const SliverToBoxAdapter(
                        child: SportShimmerLoading(isDesktop: false),
                      );
                    }

                    // Watch leagues and time range for filtering
                    final leagues = ref.watch(leaguesV2Provider);
                    final currentTimeRange = ref.watch(
                      selectedTimeRangeV2Provider,
                    );

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

                    final nonEmptyLeagues = filteredLeagues
                        .where((l) => l.events.isNotEmpty)
                        .toList();

                    if (nonEmptyLeagues.isEmpty) {
                      return const SliverToBoxAdapter(child: SportEmptyPage());
                    }

                    return LeagueEventsSliverV2(
                      leagues: nonEmptyLeagues,
                      isDesktop: false,
                    );
                  },
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: Gap(AppSpacingStyles.space2400)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportNameSelected(int currentSportId) {
    final sport = SportType.fromId(currentSportId);
    final name = _getSportName(sport ?? SportType.soccer);
    final icon = _getSportIcon(sport ?? SportType.soccer);

    return Container(
      color: const Color(0xFF1B1A19),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        children: [
          ImageHelper.load(path: icon, width: 24, height: 24),
          const SizedBox(width: 6),
          Text(
            name,
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

  String _getSportName(SportType sport) {
    switch (sport) {
      case SportType.soccer:
        return 'Bóng đá';
      case SportType.tennis:
        return 'Tennis';
      case SportType.basketball:
        return 'Bóng rổ';
      case SportType.volleyball:
        return 'Bóng chuyền';
      case SportType.tableTennis:
        return 'Bóng bàn';
      case SportType.badminton:
        return 'Cầu lông';
      default:
        return 'Bóng đá';
    }
  }

  String _getSportIcon(SportType sport) {
    switch (sport) {
      case SportType.soccer:
        return AppIcons.iconFootballSelected;
      case SportType.tennis:
        return AppIcons.iconTennisSelected;
      case SportType.basketball:
        return AppIcons.iconBasketballSelected;
      case SportType.volleyball:
        return AppIcons.iconVolleyballSelected;
      case SportType.tableTennis:
        return AppIcons.iconTableTennisSelected;
      case SportType.badminton:
        return AppIcons.iconBadmintonSelected;
      default:
        return AppIcons.iconFootballSelected;
    }
  }
}

/// Delegate for sticky live chat header
class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _StickyLiveChatDelegate({required this.minHeight, required this.maxHeight});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: const Color(0xFF141414),
    height: maxHeight,
    child: RepaintBoundary(
      child: AuthenticatedWidget(child: SportLiveChat(isMobile: true)),
    ),
  );

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) =>
      minHeight != oldDelegate.minHeight || maxHeight != oldDelegate.maxHeight;
}
