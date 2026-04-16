import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

class GameGroupView extends ConsumerWidget {
  const GameGroupView({
    required this.filter,
    super.key,
    this.onGamePressed,
    this.title,
    this.spacing,
    this.horizontalPadding,
  });

  const GameGroupView.outstanding({
    this.filter = const GameFilter.byPopularity(minPlayCount: 100),
    super.key,
    this.onGamePressed,
    this.title = const Text('Casino nổi bật'),
    this.spacing = 8,
    this.horizontalPadding = 4,
  });

  const GameGroupView.liveCasino({
    this.filter = const GameFilter.byGameTypes(gameTypes: [GameType.live]),
    super.key,
    this.onGamePressed,
    this.title = const Text('Live Casino'),
    this.spacing = 8,
    this.horizontalPadding = 4,
  });

  /// The filter to apply for fetching games
  final GameFilter filter;

  /// Callback when a game in this group is pressed
  final void Function(GameBlock gameBlock)? onGamePressed;

  /// The display title for the group
  final Widget? title;

  final double? spacing;

  final double? horizontalPadding;

  void _defaultOnGamePressed(
    BuildContext context,
    WidgetRef ref,
    GameBlock game,
  ) => GamePlayerScreen.push(context, ref, game: game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroup = ref.watch(gameGroupProvider(filter));

    return asyncGroup.when(
      loading: () => const GameHorizontalSectionShimmer(),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(error.toString()),
        ),
      ),
      data: (games) {
        if (games.isEmpty) {
          return const SizedBox.shrink();
        }

        return GameHorizontalSection(
          title: title,
          games: games,
          horizontalPadding: horizontalPadding,
          spacing: spacing,
          onGamePressed:
              onGamePressed ??
              (game) => _defaultOnGamePressed(context, ref, game),
        );
      },
    );
  }
}
