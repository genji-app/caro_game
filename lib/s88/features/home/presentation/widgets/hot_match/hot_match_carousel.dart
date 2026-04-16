import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/providers/hot_match_provider.dart';
import 'package:co_caro_flame/s88/features/home/presentation/widgets/hot_match/hot_match_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';

/// Hot Match Carousel Widget
///
/// Displays hot matches in a horizontal carousel with:
/// - Auto scroll every 7 seconds
/// - Page indicators
/// - Manual scroll support
/// - Stop auto scroll when user interacts
class HotMatchCarousel extends ConsumerStatefulWidget {
  /// Callback when user taps on a match card
  final void Function(HotMatchEventV2 match)? onMatchTap;

  /// Callback when user taps on odds
  final void Function(
    HotMatchEventV2 match,
    LeagueOddsData odds,
    bool isHome,
    int marketId,
  )?
  onOddsTap;

  /// Height of the carousel
  final double height;

  /// View port fraction for page view
  final double viewportFraction;

  /// Auto scroll interval in seconds
  final int autoScrollInterval;

  const HotMatchCarousel({
    super.key,
    this.onMatchTap,
    this.onOddsTap,
    this.height = 200,
    this.viewportFraction = 0.85,
    this.autoScrollInterval = 7,
  });

  @override
  ConsumerState<HotMatchCarousel> createState() => _HotMatchCarouselState();
}

class _HotMatchCarouselState extends ConsumerState<HotMatchCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  bool _isUserScrolling = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  /// Start auto scroll timer
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      Duration(seconds: widget.autoScrollInterval),
      (_) => _scrollToNextPage(),
    );
  }

  /// Stop auto scroll timer
  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  /// Scroll to next page
  void _scrollToNextPage() {
    if (!_pageController.hasClients || _isUserScrolling) return;

    final hotMatches = ref.read(hotMatchesProvider);
    if (hotMatches.isEmpty) return;

    int nextPage = _currentPage + 1;
    if (nextPage >= hotMatches.length) {
      nextPage = 0;
    }

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Handle page changed
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    ref.read(hotMatchProvider.notifier).setPageIndex(page);
  }

  /// Handle scroll notification
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isUserScrolling = true;
      _stopAutoScroll();
    } else if (notification is ScrollEndNotification) {
      _isUserScrolling = false;
      // Restart auto scroll after user stops scrolling
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isUserScrolling) {
          _startAutoScroll();
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hotMatchState = ref.watch(hotMatchProvider);
    final hotMatches = ref.watch(hotMatchesProvider);

    // Don't show if no hot matches
    if (hotMatches.isEmpty && !hotMatchState.isLoading) {
      return const SportEmptyPage();
    }

    // Show loading skeleton
    if (hotMatchState.isLoading && hotMatches.isEmpty) {
      return _buildLoadingSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(8),
              Text(
                'Hot Match',
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
              const Spacer(),
              // Refresh indicator
              if (hotMatchState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFB800),
                  ),
                ),
            ],
          ),
        ),
        const Gap(12),

        // Carousel
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: PageView.builder(
              controller: _pageController,
              itemCount: hotMatches.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final match = hotMatches[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: HotMatchCard(
                    match: match,
                    onTap: () => widget.onMatchTap?.call(match),
                    onOddsTap: (odds, isHome, marketId) {
                      widget.onOddsTap?.call(match, odds, isHome, marketId);
                    },
                  ),
                );
              },
            ),
          ),
        ),

        const Gap(12),

        // Page indicators
        if (hotMatches.length > 1) _buildPageIndicators(hotMatches.length),
      ],
    );
  }

  /// Build page indicators
  Widget _buildPageIndicators(int count) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(count, (index) {
      final isActive = index == _currentPage;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: isActive ? 20 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFFB800)
              : AppColorStyles.contentQuaternary,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }),
  );

  /// Build loading skeleton
  Widget _buildLoadingSkeleton() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Title skeleton
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(8),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
      const Gap(12),

      // Card skeleton
      SizedBox(
        height: widget.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 2,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (_, __) => _buildCardSkeleton(),
        ),
      ),
    ],
  );

  /// Build single card skeleton
  Widget _buildCardSkeleton() => Container(
    width: 280,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),

        // Content skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamSkeleton(),
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColorStyles.backgroundQuaternary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(4),
                  Container(
                    width: 30,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColorStyles.backgroundQuaternary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              _buildTeamSkeleton(),
            ],
          ),
        ),

        const Spacer(),

        // Odds skeleton
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );

  /// Build team skeleton
  Widget _buildTeamSkeleton() => Column(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          shape: BoxShape.circle,
        ),
      ),
      const Gap(4),
      Container(
        width: 60,
        height: 12,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ],
  );
}
