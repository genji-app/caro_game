import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/list/game_card.dart';

/// Danh sách kết quả tìm kiếm casino (grid với khoảng cách giữa các ô).
/// Chỉ render list; không xử lý empty state (do [SearchCasinoResults] đảm nhiệm).
class SearchCasinoResultList extends StatelessWidget {
  const SearchCasinoResultList({
    super.key,
    required this.games,
    this.onGameTap,
  });

  final List<GameBlock> games;
  final void Function(GameBlock game)? onGameTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = GameCardLayout.getColumns(width);
        final availableWidth = width - (2 * GameCardLayout.horizontalPadding);
        final totalGapWidth = (columns - 1) * GameCardLayout.spacing;
        final cellWidth = (availableWidth - totalGapWidth) / columns;
        final cellHeight = GameCardLayout.getCardHeight(cellWidth);
        final rowCount = (games.length + columns - 1) ~/ columns;

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: 8,
            left: GameCardLayout.horizontalPadding,
            right: GameCardLayout.horizontalPadding,
          ),
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            final startIndex = rowIndex * columns;
            final rowItems = <Widget>[];
            for (int col = 0; col < columns; col++) {
              if (col > 0) {
                rowItems.add(const SizedBox(width: GameCardLayout.spacing));
              }
              final index = startIndex + col;
              if (index < games.length) {
                final block = games[index];
                rowItems.add(
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: GameCard(
                      gameBlock: block,
                      onPressed: onGameTap != null
                          ? () => onGameTap!(block)
                          : null,
                    ),
                  ),
                );
              } else {
                rowItems.add(SizedBox(width: cellWidth, height: cellHeight));
              }
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rowItems,
                ),
                if (rowIndex < rowCount - 1)
                  const SizedBox(height: GameCardLayout.spacing),
              ],
            );
          },
        );
      },
    );
  }
}
