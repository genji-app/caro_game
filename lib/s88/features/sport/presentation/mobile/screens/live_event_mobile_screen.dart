import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/live_events_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';
import 'package:co_caro_flame/s88/shared/widgets/tab_layout/s88_tab.dart'
    show S88Tab, S88TabItem, sportTabItems, sportIds;

/// Màn Đang diễn ra trên mobile – cấu trúc giống TopLeagueMobileScreen:
/// ShellMobileHeader, _StickyLiveChatDelegate, title, list trận đấu đang diễn ra.
class LiveEventMobileScreen extends ConsumerWidget {
  const LiveEventMobileScreen({super.key, this.onBackPressed});

  /// Khi set (mở từ drawer): back quay lại content trước. Khi null: không hiện nút back.
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: _LiveEventMobileContent(onBackPressed: onBackPressed),
    );
  }
}

class _LiveEventMobileContent extends ConsumerStatefulWidget {
  const _LiveEventMobileContent({this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  ConsumerState<_LiveEventMobileContent> createState() =>
      _LiveEventMobileContentState();
}

class _LiveEventMobileContentState
    extends ConsumerState<_LiveEventMobileContent> {
  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(mainScrollControllerProvider);
    final isExpanded = ref.watch(liveChatExpandedProvider);
    final liveChatHeight = isExpanded ? _expandedHeight : _collapsedHeight;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final sportId = ref.watch(selectedSportV2Provider).id;
    final onBackPressed = widget.onBackPressed;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (isExpanded) {
              FocusScope.of(context).unfocus();
              ref.read(liveChatExpandedProvider.notifier).state = false;
            }
          },
          behavior: HitTestBehavior.translucent,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                if (isAuthenticated)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyLiveChatDelegate(
                      minHeight: liveChatHeight,
                      maxHeight: liveChatHeight,
                      onStickyChanged: (isSticky) {
                        ref.read(liveChatStickyProvider.notifier).state =
                            isSticky;
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: Gap(16)),
                SliverToBoxAdapter(
                    child: _buildTitleRow(context, onBackPressed)),
                SliverToBoxAdapter(child: _buildSportTabs(ref)),
                const SliverToBoxAdapter(child: Gap(12)),
                ..._buildLeagueSlivers(ref, sportId),
                SliverToBoxAdapter(
                  child: Gap(80 + MediaQuery.of(context).padding.bottom),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: BackToTopFloatingButton.margin,
          bottom: BackToTopFloatingButton.bottomForContext(context),
          child: BackToTopFloatingButton(controller: scrollController),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, VoidCallback? onBackPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ImageHelper.load(
            path: AppIcons.liveDot,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            'Đang diễn ra',
            style: AppTextStyles.headingXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportTabs(WidgetRef ref) {
    final currentSport = ref.watch(selectedSportV2Provider);
    final currentId = currentSport.id;
    final selectedIndex = sportIds.indexOf(currentId);
    final clampedIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return Container(
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
    );
  }

  List<Widget> _buildLeagueSlivers(WidgetRef ref, int sportId) {
    final asyncLeagues = ref.watch(liveLeagueEventsProvider(sportId));

    return asyncLeagues.when(
      data: (leagues) {
        if (leagues.isEmpty) {
          return [const SliverToBoxAdapter(child: SportEmptyPage())];
        }
        return [
          LeagueEventsSliverV2(
            leagues: leagues,
            isDesktop: false,
            includeEmptyLeagues: false,
          ),
        ];
      },
      loading: () => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SportShimmerLoading(isDesktop: false),
          ),
        ),
      ],
      error: (err, _) => [
        SliverToBoxAdapter(
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
      ],
    );
  }
}

/// Delegate cho sticky live chat header (giống TopLeagueMobileScreen).
class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final ValueChanged<bool>? onStickyChanged;
  bool _lastStickyState = false;

  _StickyLiveChatDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.onStickyChanged,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isSticky = overlapsContent || shrinkOffset > 0;

    if (isSticky != _lastStickyState) {
      _lastStickyState = isSticky;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onStickyChanged?.call(isSticky);
      });
    }

    return SizedBox(
      height: maxHeight,
      child: Stack(
        children: [
          const RepaintBoundary(child: SportLiveChat(isMobile: true)),
          if (isSticky)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        onStickyChanged != oldDelegate.onStickyChanged;
  }
}
