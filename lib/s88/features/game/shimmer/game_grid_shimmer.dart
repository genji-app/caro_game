import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// Shimmer loading for game grid
///
/// Shows a grid of game card shimmers, representing the loading state
/// for search results or category-filtered games.
class GameGridShimmer extends StatelessWidget {
  const GameGridShimmer({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = GameCardLayout.getColumns(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: GameCardLayout.calculateChildAspectRatio(
          screenWidth - (2 * GameCardLayout.horizontalPadding),
          columns,
        ),
        crossAxisSpacing: GameCardLayout.spacing,
        mainAxisSpacing: GameCardLayout.spacing,
      ),
      itemCount: columns * rows,
      itemBuilder: (_, __) => const GameCardShimmer(),
    );
  }
}
