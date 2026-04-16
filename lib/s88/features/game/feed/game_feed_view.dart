import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

/// Widget for displaying games grouped by game type in horizontal scrollable rows
///
/// **Self-contained component:**
/// - Handles its own loading, error, and empty states
/// - No external state management needed
/// - Clean separation of concerns
///
/// This widget shows ALL games without pagination. Each game type section
/// displays all its games in a horizontal scrollable list.
class GameFeedView extends ConsumerWidget {
  const GameFeedView({super.key, this.onGamePressed}) : _isSliver = false;

  const GameFeedView.sliver({super.key, this.onGamePressed}) : _isSliver = true;

  final void Function(GameBlock gameBlock)? onGamePressed;
  final bool _isSliver;

  Widget _wrapSliver(Widget child) {
    return _isSliver ? SliverToBoxAdapter(child: child) : child;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(gameFeedProvider);

    // Loading state
    if (feedState.isLoading) {
      return _wrapSliver(const GameFeedShimmer());
    }

    // Error state
    if (feedState.isFailure) {
      return _wrapSliver(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${feedState.error ?? I18n.msgSomethingWentWrong}',
                  style: AppTextStyles.paragraphMedium(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SecondaryButton.yellow(
                  onPressed: () =>
                      ref.read(gameFeedProvider.notifier).refresh(),
                  label: const Text(I18n.txtRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (feedState.feedItems.isEmpty) {
      return _wrapSliver(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(I18n.txtNoGamesAvailable),
          ),
        ),
      );
    }

    // Success state - display feed items
    final itemCount = feedState.feedItems.length * 2 - 1;

    Widget itemBuilder(BuildContext context, int index) {
      // If odd, it's a separator
      if (index.isOdd) {
        return const SizedBox(height: 24);
      }

      // If even, it's a feed item
      final itemIndex = index ~/ 2;
      final item = feedState.feedItems[itemIndex];

      return switch (item) {
        GameBannerBlock(image: final _) => const GameBannerProviders(),
        GameGroupBlock(label: final label, games: final games) =>
          GameHorizontalSection(
            title: Text(label),
            games: games,
            onGamePressed: onGamePressed,
          ),
      };
    }

    if (_isSliver) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
