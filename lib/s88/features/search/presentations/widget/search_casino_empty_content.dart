import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// Nội dung tab Casino khi chưa search: Chơi gần đây (nếu có) + Phổ biến.
class SearchCasinoEmptyContent extends StatelessWidget {
  const SearchCasinoEmptyContent({
    required this.recentBlocks,
    required this.popularBlocks,
    super.key,
    this.onGameTap,
  });

  final List<GameBlock> recentBlocks;
  final List<GameBlock> popularBlocks;
  final void Function(GameBlock game)? onGameTap;

  static const String _sectionRecent = 'Chơi gần đây';
  static const String _sectionPopular = 'Phổ biến';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recentBlocks.isNotEmpty) ...[
            const _SectionTitle(title: _sectionRecent),
            const SizedBox(height: 12),
            _HorizontalGameList(games: recentBlocks, onGameTap: onGameTap),
            const SizedBox(height: 24),
          ],
          const _SectionTitle(title: _sectionPopular),
          const SizedBox(height: 12),
          _GameGrid3Columns(games: popularBlocks, onGameTap: onGameTap),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelLarge(color: AppColorStyles.contentPrimary),
    );
  }
}

class _HorizontalGameList extends StatelessWidget {
  const _HorizontalGameList({required this.games, this.onGameTap});

  final List<GameBlock> games;
  final void Function(GameBlock)? onGameTap;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardWidth = GameCardLayout.minWidth;
    final cardHeight = GameCardLayout.getCardHeight(cardWidth);

    return SizedBox(
      height: cardHeight + 8 + 20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: GameCardLayout.spacing),
        itemBuilder: (context, index) {
          final block = games[index];
          return SizedBox(
            width: cardWidth,
            height: cardHeight + 8 + 20,
            child: GameCard(
              gameBlock: block,
              onPressed: onGameTap != null ? () => onGameTap!(block) : null,
            ),
          );
        },
      ),
    );
  }
}

/// Grid 3 cột cho mục Phổ biến.
const int _popularGridColumns = 3;

class _GameGrid3Columns extends StatelessWidget {
  const _GameGrid3Columns({required this.games, this.onGameTap});

  final List<GameBlock> games;
  final void Function(GameBlock game)? onGameTap;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = _popularGridColumns;
        final totalGapWidth = (columns - 1) * GameCardLayout.spacing;
        final cellWidth = (width - totalGapWidth) / columns;
        final cellHeight = cellWidth * 1.34722222;
        final rowCount = (games.length + columns - 1) ~/ columns;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildRow(
                  rowIndex: rowIndex,
                  columns: columns,
                  cellWidth: cellWidth,
                  cellHeight: cellHeight,
                ),
              ),
              if (rowIndex < rowCount - 1)
                const SizedBox(height: GameCardLayout.spacing),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildRow({
    required int rowIndex,
    required int columns,
    required double cellWidth,
    required double cellHeight,
  }) {
    final startIndex = rowIndex * columns;
    final rowItems = <Widget>[];

    for (int col = 0; col < columns; col++) {
      if (col > 0) {
        rowItems.add(SizedBox(width: GameCardLayout.spacing));
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
              onPressed: onGameTap != null ? () => onGameTap!(block) : null,
            ),
          ),
        );
      } else {
        rowItems.add(SizedBox(width: cellWidth, height: cellHeight));
      }
    }
    return rowItems;
  }
}
