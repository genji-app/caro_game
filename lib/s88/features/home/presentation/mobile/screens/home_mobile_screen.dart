import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
// V2 imports - using V2 models directly without legacy conversion
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/providers/app_init_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/home/presentation/mobile/widgets/home_mobile_banner_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/mobile/widgets/home_mobile_sports_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/mobile/widgets/home_mobile_welcome_section.dart';
import 'package:co_caro_flame/s88/features/home/presentation/widgets/home_shimmer_loading.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_matches_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_card_v2.dart';

class HomeMobileScreen extends StatelessWidget {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Kiểm tra trạng thái khởi tạo app
        final isInitializing = ref.watch(isAppInitializingProvider);

        // Hiển thị shimmer loading khi đang khởi tạo
        if (isInitializing) {
          return const HomeShimmerLoading(isMobile: true);
        }

        return const Scaffold(
          backgroundColor: Color(0xFF141414),
          body: HomeMobileContent(),
        );
      },
    );
  }
}

class HomeMobileContent extends ConsumerWidget {
  const HomeMobileContent({super.key});

  // Chiều cao của live chat - phải khớp với SportLiveChat
  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ watch scrollController ở đây vì nó ít khi thay đổi
    final scrollController = ref.watch(mainScrollControllerProvider);

    return GestureDetector(
      onTap: () {
        // Dùng ref.read thay vì capture biến từ watch
        final isExpanded = ref.read(liveChatExpandedProvider);
        if (isExpanded) {
          FocusScope.of(context).unfocus();
          ref.read(liveChatExpandedProvider.notifier).state = false;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: AppColorStyles.backgroundPrimary,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Live Chat - tách riêng Consumer để chỉ rebuild khi auth/expanded thay đổi
              Consumer(
                builder: (context, ref, child) {
                  final isAuthenticated = ref.watch(isAuthenticatedProvider);
                  if (!isAuthenticated) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  // Chỉ watch liveChatExpandedProvider ở đây
                  final isExpanded = ref.watch(liveChatExpandedProvider);
                  final liveChatHeight = isExpanded
                      ? _expandedHeight
                      : _collapsedHeight;

                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyLiveChatDelegate(
                      minHeight: liveChatHeight,
                      maxHeight: liveChatHeight,
                      onStickyChanged: (isSticky) {
                        ref.read(liveChatStickyProvider.notifier).state =
                            isSticky;
                      },
                    ),
                  );
                },
              ),
              // Phần content - dùng SliverList để lazy loading (chỉ build widget khi visible)
              // Các widget này là const nên không bị rebuild khi Consumer ở trên rebuild
              SliverList.list(
                children: const [
                  Gap(8),
                  // Welcome section - nhẹ, không cần RepaintBoundary
                  HomeMobileWelcomeSection(),
                  Gap(8),
                  // Hot Bets - có Timer + provider updates, cần RepaintBoundary
                  // RepaintBoundary(child: HomeMobileHotBetsSection()),
                  Gap(8),
                  // Sports section - có scroll + images, cần RepaintBoundary
                  RepaintBoundary(child: HomeMobileSportsSection()),
                  Gap(8),
                  // Betting section - static content
                  // LiveBetView(),
                  // Gap(4),
                  // Banner section - static images
                  HomeMobileBannerSection(),
                  Gap(8),

                  // Casino section - có scroll + images, cần RepaintBoundary
                  RepaintBoundary(child: GameGroupView.outstanding()),
                  Gap(8),
                  // Live Casino section - static content
                  RepaintBoundary(child: GameGroupView.liveCasino()),
                  Gap(80),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget hiển thị live matches section với inner shadow container
class _HomeMobileLiveMatchesSection extends StatelessWidget {
  final List<LeagueModelV2> leagues;
  final bool isLoading;

  /// Maximum number of live events to show
  static const int _maxLiveEvents = 8;

  /// Fixed height for each LeagueCard
  /// This includes header (40) + events height (varies by events count)
  static const double _leagueCardBaseHeight = 40.0;
  static const double _matchRowHeight = 220.0;

  const _HomeMobileLiveMatchesSection({
    required this.leagues,
    required this.isLoading,
  });

  /// Filter leagues to show max 8 live events total
  /// Logic:
  /// - Iterate through leagues, accumulate event count
  /// - Once we reach or exceed 8 events, include that last league and stop
  /// - If we haven't reached 8, show all leagues
  List<LeagueModelV2> _filterLeaguesToMaxEvents(List<LeagueModelV2> leagues) {
    final filteredLeagues = <LeagueModelV2>[];
    int totalEvents = 0;

    for (final league in leagues) {
      if (league.events.isEmpty) continue;

      filteredLeagues.add(league);
      totalEvents += league.events.length;

      // If we've reached or exceeded max events, stop adding more leagues
      if (totalEvents >= _maxLiveEvents) break;
    }

    return filteredLeagues;
  }

  /// Calculate total height for all league cards
  double _calculateTotalHeight(List<LeagueModelV2> leagues) {
    double totalHeight = 0;
    for (final league in leagues) {
      // Each league has base height + (events count * match row height)
      totalHeight +=
          _leagueCardBaseHeight +
          (league.events.length * (_matchRowHeight + 5));
    }
    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _ShimmerLoadingListMobile();
    }

    if (leagues.isEmpty) {
      return const SportEmptyPage();
    }

    // Filter leagues to max 8 events
    final filteredLeagues = _filterLeaguesToMaxEvents(leagues);
    if (filteredLeagues.isEmpty) {
      return const SportEmptyPage();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InnerShadowCard(
        borderRadius: 16,
        child: Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with "Đang diễn ra" title
              _buildSectionHeader(),
              // League cards list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SizedBox(
                  height: _calculateTotalHeight(filteredLeagues),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLeagues.length,
                    itemBuilder: (context, index) {
                      return LeagueCardV2(league: filteredLeagues[index]);
                    },
                  ),
                ),
              ),
              // Footer with "Xem thêm trận đấu" button
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build section header with live indicator and title
  Widget _buildSectionHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ).copyWith(bottom: 0),
      child: Row(
        children: [
          // Live indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5172),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đang diễn ra',
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build footer with "Xem thêm trận đấu" button
  Widget _buildFooter() {
    return Consumer(
      builder: (context, ref, child) {
        return GestureDetector(
          onTap: () {
            // Navigate to sport detail with Live tab selected
            ref.read(previousContentProvider.notifier).state =
                MainContentType.home;
            ref.read(sportDetailTabProvider.notifier).state =
                SportDetailFilterType.live;
            ref.read(mainContentProvider.notifier).goToSportDetail();
          },
          child: Container(
            height: 48,
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF393836), width: 1),
            ),
            child: Center(
              child: Text(
                'Xem thêm trận đấu',
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFEF5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Delegate cho sticky live chat header
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
    // overlapsContent = true khi header đã sticky (pinned) và đang overlap với content
    // shrinkOffset > 0 khi header đã bắt đầu bị shrink (scroll đã vượt qua header)
    final isSticky = overlapsContent || shrinkOffset > 0;

    // Notify sticky state change only when it actually changes
    if (isSticky != _lastStickyState) {
      _lastStickyState = isSticky;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onStickyChanged?.call(isSticky);
      });
    }

    return Container(
      height: maxHeight,
      child: Stack(
        children: [
          RepaintBoundary(child: SportLiveChat(isMobile: true)),
          // Gradient overlay on top when sticky
          if (isSticky)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40, // Height of gradient overlay
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0x00000000), // #00000000 (transparent)
                      // #000000 (black)
                    ],
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

class _ShimmerLoadingListMobile extends StatelessWidget {
  const _ShimmerLoadingListMobile();

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shimmer cho 2 league cards
        for (int i = 0; i < 2; i++) _buildShimmerLeagueCard(),
      ],
    );
  }

  Widget _buildShimmerLeagueCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x0AFFF6E4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League header shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
                const SizedBox(width: 8),
                _buildShimmerBox(width: 100, height: 12, borderRadius: 4),
              ],
            ),
          ),
          // Match rows shimmer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: [for (int i = 0; i < 3; i++) _buildShimmerMatchRow()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerMatchRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time row
          _buildShimmerBox(width: 50, height: 10, borderRadius: 4),
          const SizedBox(height: 10),
          // Home team row
          Row(
            children: [
              _buildShimmerBox(width: 20, height: 20, borderRadius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 12),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
              const SizedBox(width: 6),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 8),
          // Away team row
          Row(
            children: [
              _buildShimmerBox(width: 20, height: 20, borderRadius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 12),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
              const SizedBox(width: 6),
              _buildShimmerBox(width: 40, height: 24, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: _shimmerHighlightColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
