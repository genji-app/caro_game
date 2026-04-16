import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/upcoming_events_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/tab_layout/s88_tab.dart'
    show S88Tab, S88TabItem, sportTabItems, sportIds;

/// Upcoming Event desktop screen – hiển thị các trận đấu sắp diễn ra.
/// Cùng cấp với TopLeagueDesktopScreen, cùng folder.
class UpcomingEventDesktopScreen extends ConsumerWidget {
  const UpcomingEventDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Container(
        color: AppColorStyles.backgroundSecondary,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSportTabs(ref),
              const Gap(12),
              Expanded(
                child: RepaintBoundary(
                  child: _UpcomingEventsContent(
                    sportId: ref.watch(selectedSportV2Provider).id,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// S88Tab sport tabs.
  Widget _buildSportTabs(WidgetRef ref) {
    final currentSport = ref.watch(selectedSportV2Provider);
    final currentId = currentSport.id;
    final selectedIndex = sportIds.indexOf(currentId);
    final clampedIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return RepaintBoundary(
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
          onTabChanged: (index) {
            final sportId = sportIds[index];
            ref.read(selectedSportV2Provider.notifier).state =
                v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
            ref
                .read(sportSocketAdapterProvider)
                .subscriptionManager
                .setActiveSport(sportId);
          },
          backgroundColor: Colors.transparent,
          defaultColor: AppColorStyles.contentPrimary,
          selectedColor: AppColors.yellow300,
          isScrollable: true,
          scrollableTabWidth: 100,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        children: [
          ImageHelper.load(
            path: AppIcons.iconComingSport,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: AppColors.yellow300,
          ),
          const SizedBox(width: 8),
          Text(
            'Sắp diễn ra',
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content for upcoming events: fetch today+early events by sportId.
/// Rebuilds only when [sportId] or async result for that sportId changes.
class _UpcomingEventsContent extends ConsumerWidget {
  final int sportId;

  const _UpcomingEventsContent({required this.sportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeagues = ref.watch(upcomingLeagueEventsProvider(sportId));

    return asyncLeagues.when(
      data: (leagues) {
        if (leagues.isEmpty) {
          return const SportEmptyPage();
        }
        return BackToTopWrapper(
          builder: (scrollController) => ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
              LeagueEventsSliverV2(
                leagues: leagues,
                isDesktop: true,
                includeEmptyLeagues: false,
                showBackToTop: false,
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: 80 + MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SportShimmerLoading(isDesktop: true),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            err.toString(),
            style: AppTextStyles.textStyle(
              fontSize: 14,
              color: AppColorStyles.contentTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
