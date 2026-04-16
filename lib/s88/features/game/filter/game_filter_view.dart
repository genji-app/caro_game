import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/border_radius_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

/// Game View - Main orchestrator for the game feature
///
/// ## Initialization Flow:
/// 1. Initialize `gameFilterProvider` (auto-initialized by Riverpod)
/// 2. Initialize `GameCategorySelector` (manages its own internal selection state)
/// 3. Initialize `gameFeedProvider` and fetch game data
///
/// ## Display Logic:
/// - **Default State**: Shows Feed View (games grouped by categories)
/// - **Search/Filter Mode**: Shows Grid View (filtered results)
///   - Triggered when: search query is entered OR category is selected
///   - Shows: Paginated grid of matching games
///
/// ## Components:
/// - `GameIntroBanner`: Welcome banner
/// - `GameFilterBar`: Search input (triggers search mode)
/// - `GameCategorySelector`: Category filter (triggers filter mode via callback)
/// - `_GameContentSwitcher`: Switches between Feed/Grid based on mode (private)
class GameFilterView extends ConsumerStatefulWidget {
  const GameFilterView({super.key, this.shrinkWrap = false, this.physics});

  /// Whether the scroll view should shrink-wrap its contents
  final bool shrinkWrap;

  /// The scroll physics to use
  final ScrollPhysics? physics;

  @override
  ConsumerState<GameFilterView> createState() => _GameFilterViewState();
}

class _GameFilterViewState extends ConsumerState<GameFilterView> {
  /// Load game URL and navigate to player screen
  ///
  /// Injected into: _GameContentSwitcher -> GameFeedView/GameGridView
  /// Flow:
  /// 1. Show loading dialog
  /// 2. Fetch game URL from API
  /// 3. Handle errors or navigate to player
  /// Open game detail screen
  void _handleGamePress(GameBlock game) {
    GamePlayerScreen.push(context, ref, game: game);
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Keeps the autoDispose provider alive exactly as long as GameFilterView is alive
    ref.watch(gameFilterProvider);

    final isMobile = ResponsiveBuilder.isMobile(context);
    final horizontalPadding = !isMobile
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: AppSpacingStyles.space300);

    return Material(
      color: Colors.transparent,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadiusStyles.borderRadius400,
          ),
          child: CustomScrollView(
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            slivers: [
              // Header Section
              // const SliverToBoxAdapter(child: GameIntroBanner()),
              // const SliverToBoxAdapter(child: Gap(24)),

              // Search & Filter Controls
              SliverPadding(
                padding: horizontalPadding,
                sliver: SliverToBoxAdapter(
                  child: GameFilterInput(
                    onChanged: ref
                        .read(gameFilterProvider.notifier)
                        .setSearchQuery,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(AppSpacingStyles.space400)),

              SliverToBoxAdapter(
                child: GameCategorySelector(
                  padding: horizontalPadding,
                  onSelectionChanged: ref
                      .read(gameFilterProvider.notifier)
                      .setCategorySelection,
                ),
              ),

              const SliverToBoxAdapter(child: Gap(AppSpacingStyles.space400)),

              // Content Section
              // Logic: Feed View (default) OR Grid View (search/filter mode)
              _GameContentSwitcher(onGamePressed: _handleGamePress),
            ],
          ),
        ),
      ),
    );
  }
}

/// Private widget that switches between feed view and grid view
///
/// **Decision Logic:**
/// - Show Feed: When no search query AND no category selected
/// - Show Grid: When search query exists OR category selected
///
/// **Note:** This is private to GameFilterView since it's only used here.
class _GameContentSwitcher extends ConsumerWidget {
  const _GameContentSwitcher({required this.onGamePressed});

  final void Function(GameBlock game) onGamePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(gameFilterProvider);

    final isShowingFeed =
        filterState.categorySelection.isEmpty &&
        filterState.searchQuery.isEmpty;

    if (isShowingFeed) {
      return GameFeedView.sliver(onGamePressed: onGamePressed);
    }

    return _GameFilterResult(
      filterState: filterState,
      onGamePressed: onGamePressed,
    );
  }
}

/// Displays the result of a search/filter operation.
///
/// Shows a paginated [GameGridView] when results exist,
/// or an empty-state message when there are no matches.
class _GameFilterResult extends ConsumerWidget {
  const _GameFilterResult({
    required this.filterState,
    required this.onGamePressed,
  });

  final GameFilterState filterState;
  final void Function(GameBlock) onGamePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filterState.status.isLoading) {
      return const SliverToBoxAdapter(
        child: GameGridShimmer(), // shimmer for game filter
      );
    }

    if (filterState.results.isEmpty) {
      return const SliverToBoxAdapter(
        child: GameFilterEmptyState(), // empty state for game filter
      );
    }

    return GameGridView.sliver(
      games: filterState.results,
      onGameTap: onGamePressed,
    );
  }
}
