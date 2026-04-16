import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
// V2 imports - using V2 models directly
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/top_league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_list_event_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart'
    show BackToTopWrapper;
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_card_v2.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/sport_mobile_popular_league_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/desktop/widgets/sport_desktop_type_filter_tabs.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Provider for selected filter - scoped to this widget
final _selectedFilterProvider = StateProvider.autoDispose<MatchFilterType>(
  (ref) => MatchFilterType.live,
);

class SportMobileLiveMatchesSection extends StatelessWidget {
  const SportMobileLiveMatchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Consumer(
        builder: (context, ref, _) {
          final selectedFilter = ref.watch(_selectedFilterProvider);
          final showUpcomingFavoritesContainer =
              selectedFilter == MatchFilterType.upcoming ||
              selectedFilter == MatchFilterType.favorites;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _MatchFilterTabs(selectedFilter: selectedFilter),
              if (!showUpcomingFavoritesContainer) ...[
                Expanded(
                  child: BackToTopWrapper(
                    builder: (scrollController) => SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(AppSpacingStyles.space300),
                          const RepaintBoundary(
                            child: SportHotSection(height: 125),
                          ),
                          const SportTypeFilterTabs(),
                          const SizedBox(height: 16),
                          const _LiveContent(),
                          const SizedBox(height: 16),
                          const SportMobilePopularLeagueSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (showUpcomingFavoritesContainer)
                Expanded(
                  child: SportListEventContainer(filter: selectedFilter),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Match filter tabs - receives filter from parent to avoid duplicate watch
class _MatchFilterTabs extends StatelessWidget {
  final MatchFilterType selectedFilter;

  const _MatchFilterTabs({required this.selectedFilter});

  static final _filters = [
    (MatchFilterType.live, 'Sảnh', AppIcons.iconHomeSport),
    (MatchFilterType.upcoming, 'Sắp diễn ra', AppIcons.iconComingSport),
    (MatchFilterType.favorites, 'Yêu thích', AppIcons.iconFavoriteSport),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x001B1A19), Color(0xFF1B1A19)],
              ),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
            ),
          ),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = selectedFilter == filter.$1;
              final iconColor = isSelected
                  ? const Color(0xFFFDE272)
                  : const Color(0xFF9C9B95);

              return Expanded(
                child: Consumer(
                  builder: (context, ref, child) => GestureDetector(
                    onTap: () =>
                        ref.read(_selectedFilterProvider.notifier).state =
                            filter.$1,
                    behavior: HitTestBehavior.opaque,
                    child: child,
                  ),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageHelper.load(
                                path: filter.$3,
                                width: 16,
                                height: 16,
                                color: iconColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                filter.$2,
                                style: AppTextStyles.textStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Sport type filter tabs (mobile) – mỗi sport tab đi kèm sub-league tabs.
/// Tap sport → goToSportDetail, tap league → goToLeagueDetail.
class SportTypeFilterTabs extends StatelessWidget {
  const SportTypeFilterTabs();

  @override
  Widget build(BuildContext context) {
    final sports = sportDesktopTypeFilterItems;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (int i = 0; i < sports.length; i++)
              _MobileSportWithLeagues(
                sport: sports[i],
                isLast: i == sports.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

/// Mỗi sport tab + sub-league tabs của nó (mobile).
/// Watch [topLeagueEventsProvider] riêng cho từng sportId.
class _MobileSportWithLeagues extends StatelessWidget {
  final SportDesktopTypeFilterItem sport;
  final bool isLast;

  const _MobileSportWithLeagues({required this.sport, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final leagues =
            ref.watch(topLeagueEventsProvider(sport.sportId)).valueOrNull ?? [];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(
                right: leagues.isNotEmpty || !isLast ? 8 : 0,
              ),
              child: _MobileSportTabItem(sport: sport),
            ),
            for (int i = 0; i < leagues.length; i++)
              Container(
                margin: EdgeInsets.only(
                  right: (i < leagues.length - 1 || !isLast) ? 8 : 0,
                ),
                child: _MobileLeagueTabItem(
                  name: leagues[i].displayName,
                  logo: leagues[i].leagueLogo,
                  sportId: leagues[i].sportId,
                  leagueId: leagues[i].leagueId,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MobileSportTabItem extends StatelessWidget {
  final SportDesktopTypeFilterItem sport;

  const _MobileSportTabItem({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () {
          ref.read(previousContentProvider.notifier).state =
              MainContentType.sport;
          final sportType =
              v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
          ref.read(selectedSportV2Provider.notifier).state = sportType;
          ref
              .read(sportSocketAdapterProvider)
              .subscriptionManager
              .setActiveSport(sport.sportId);
          ref.read(mainContentProvider.notifier).goToSportDetail();
        },
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF252423),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 28,
              height: 28,
              child: ImageHelper.load(path: sport.icon, width: 28, height: 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sport.name,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MobileLeagueTabItem extends StatelessWidget {
  final String name;
  final String logo;
  final int sportId;
  final int leagueId;

  const _MobileLeagueTabItem({
    required this.name,
    required this.logo,
    required this.sportId,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () {
          ref
              .read(selectedLeagueInfoProvider.notifier)
              .state = SelectedLeagueInfo(
            sportId: sportId,
            leagueId: leagueId,
            leagueName: name,
            leagueLogo: logo,
          );
          ref.read(mainContentProvider.notifier).goToLeagueDetail();
        },
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF252423),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: logo.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: Colors.white,
                      width: 28,
                      height: 28,
                      child: ImageHelper.load(
                        path: logo,
                        width: 28,
                        height: 28,
                        fit: BoxFit.fill,
                        errorWidget: const SizedBox(width: 28, height: 28),
                      ),
                    ),
                  )
                : const SizedBox(width: 28, height: 28),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              name,
              style: AppTextStyles.paragraphXXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live content section — only shown in "Sảnh" tab.
/// Includes header, sport filter tabs, and dynamic content.
/// StatelessWidget: _LiveHeader và _SportFilterTabs không rebuild khi events thay đổi.
class _LiveContent extends StatelessWidget {
  const _LiveContent();

  @override
  Widget build(BuildContext context) {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_LiveHeader(), _SportFilterTabs(), _LiveMatchesList()],
      ),
    );
  }
}

/// Dynamic live matches list — isolate rebuild scope từ _LiveContent.
/// Dùng Consumer + select để chỉ rebuild khi isLoading hoặc leagues thay đổi.
class _LiveMatchesList extends StatelessWidget {
  const _LiveMatchesList();

  static const int _maxLiveEvents = 5;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isLoading = ref.watch(
          eventsV2Provider.select((state) => state.isLoading),
        );

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: SportShimmerLoading(isDesktop: false),
          );
        }

        final leagues = ref.watch(leaguesV2Provider);
        final nonEmpty = leagues.where((l) => l.events.isNotEmpty).toList();

        if (nonEmpty.isEmpty) return const SportEmptyPage();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._buildLeagueWidgets(nonEmpty), const _ViewAllButton()],
        );
      },
    );
  }

  static List<Widget> _buildLeagueWidgets(List<LeagueModelV2> leagues) {
    final result = <Widget>[];
    var remaining = _maxLiveEvents;

    for (final league in leagues) {
      if (remaining <= 0) break;

      final events = league.events;
      if (events.isEmpty) continue;

      final displayLeague = events.length <= remaining
          ? league
          : league.copyWith(events: events.sublist(0, remaining));

      result.add(LeagueCardV2(league: displayLeague));
      remaining -= displayLeague.events.length;
    }

    return result;
  }
}

/// Sport filter tabs inside the live content section.
/// StatelessWidget: Container/ScrollView không rebuild khi đổi sport.
class _SportFilterTabs extends StatelessWidget {
  const _SportFilterTabs();

  @override
  Widget build(BuildContext context) {
    final sports = sportDesktopTypeFilterItems;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sports
              .map((sport) => _SportFilterTabItem(sport: sport))
              .toList(),
        ),
      ),
    );
  }
}

/// Mỗi tab item dùng Consumer + select để chỉ rebuild khi isSelected thay đổi.
class _SportFilterTabItem extends StatelessWidget {
  final SportDesktopTypeFilterItem sport;

  const _SportFilterTabItem({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSelected = ref.watch(
          selectedSportV2Provider.select((s) => s.id == sport.sportId),
        );

        return GestureDetector(
          onTap: () {
            final sportType =
                v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
            ref.read(selectedSportV2Provider.notifier).state = sportType;
            ref
                .read(sportSocketAdapterProvider)
                .subscriptionManager
                .setActiveSport(sport.sportId);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageHelper.load(
                        path: isSelected
                            ? sport.iconSelected
                            : sport.iconDisabled,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sport.name,
                        style: AppTextStyles.paragraphXSmall(
                          color: isSelected
                              ? AppColors.yellow300
                              : const Color(0xFF9C9B95),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }
}

/// Live header widget - static
class _LiveHeader extends StatelessWidget {
  const _LiveHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Row(
        children: [
          const _LiveIcon(),
          const SizedBox(width: 6),
          Text(
            'Đang diễn ra',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFEF5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live icon widget - static
class _LiveIcon extends StatelessWidget {
  const _LiveIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 16, height: 16),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1FF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 11, height: 11),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF04438),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 6, height: 6),
          ),
        ],
      ),
    );
  }
}

/// View all button widget - uses Consumer for tap handler only
class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Consumer(
        builder: (context, ref, child) => GestureDetector(
          onTap: () {
            ref.read(previousContentProvider.notifier).state =
                MainContentType.sport;
            ref.read(selectedSportV2Provider.notifier).state = ref.read(
              selectedSportV2Provider,
            );
            ref.read(mainContentProvider.notifier).goToSportDetail();
          },
          child: child,
        ),
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
}
