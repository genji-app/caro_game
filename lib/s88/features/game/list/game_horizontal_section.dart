import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/widgets/carousels/horizontal_paginated_carousel.dart';

/// Section widget for a single game type with horizontal carousel navigation
class GameHorizontalSection extends StatelessWidget {
  const GameHorizontalSection({
    required this.games,
    super.key,
    this.onGamePressed,
    this.title,
    double? spacing,
    double? horizontalPadding,
  }) : _spacing = spacing ?? GameCardLayout.spacing,
       _horizontalPadding =
           horizontalPadding ?? GameCardLayout.horizontalPadding;

  final List<GameBlock> games;
  final void Function(GameBlock gameBlock)? onGamePressed;
  final Widget? title;
  final double _spacing;
  final double _horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return HorizontalPaginatedCarousel(
      title: title,
      itemCount: games.length,
      columnsBuilder: GameCardLayout.getColumns,
      heightBuilder: GameCardLayout.calculateHeightFromWidth,
      horizontalPadding: _horizontalPadding,
      itemSpacing: _spacing,
      itemBuilder: (context, index) {
        final gameData = games[index];
        return GameCard(
          gameBlock: gameData,
          onPressed: onGamePressed != null
              ? () => onGamePressed?.call(gameData)
              : null,
        );
      },
    );
  }
}
