import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

/// Widget for displaying games in a responsive grid layout with pagination
///
/// This widget displays games in a grid with "Load More" functionality.
/// The grid is responsive: 3 columns on mobile, 5 columns on larger screens.
///
/// Features:
/// - Responsive grid layout
/// - Load more pagination
/// - Game tap callbacks
/// - Customizable scroll physics
class GameGridView extends StatefulWidget {
  const GameGridView({
    required this.games,
    this.onGameTap,
    this.padding,
    super.key,
  }) : _isSliver = false;

  const GameGridView.sliver({
    required this.games,
    this.onGameTap,
    this.padding,
    super.key,
  }) : _isSliver = true;

  /// List of ALL games to display in the grid
  final List<GameBlock> games;

  /// Callback when a game card is tapped
  final void Function(GameBlock gameBlock)? onGameTap;

  /// Optional padding around the grid
  final EdgeInsetsGeometry? padding;

  final bool _isSliver;

  @override
  State<GameGridView> createState() => _GameGridViewState();
}

class _GameGridViewState extends State<GameGridView> {
  static const int _itemsPerPage = 20;
  int _displayedItemsCount = _itemsPerPage;

  @override
  void didUpdateWidget(covariant GameGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.games != widget.games) {
      _displayedItemsCount = _itemsPerPage;
    }
  }

  void _loadMore() {
    setState(() {
      _displayedItemsCount += _itemsPerPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginatedGames = widget.games.take(_displayedItemsCount).toList();
    final hasMoreGames = widget.games.length > _displayedItemsCount;

    if (widget._isSliver) {
      return SliverPadding(
        padding: widget.padding ?? EdgeInsets.zero,
        sliver: SliverMainAxisGroup(
          slivers: [
            // Games grid
            _buildGamesGridSliver(paginatedGames),

            // Load More button (only shown if there are more games)
            if (hasMoreGames) SliverToBoxAdapter(child: _buildLoadMoreButton()),
          ],
        ),
      );
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGamesGridNormal(paginatedGames),
          if (hasMoreGames) _buildLoadMoreButton(),
        ],
      ),
    );
  }

  /// Build the games grid for sliver context
  Widget _buildGamesGridSliver(List<GameBlock> paginatedGames) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisExtent = constraints.crossAxisExtent;
        final crossAxisCount = GameCardLayout.getColumns(crossAxisExtent);

        // Calculate available width for cards (total width - padding)
        final availableWidth =
            crossAxisExtent - (2 * GameCardLayout.horizontalPadding);

        final aspectRatio = GameCardLayout.calculateChildAspectRatio(
          availableWidth,
          crossAxisCount,
        );

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: GameCardLayout.horizontalPadding,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              mainAxisSpacing: GameCardLayout.spacing,
              crossAxisSpacing: GameCardLayout.spacing,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final gameData = paginatedGames[index];
              return _buildGameCard(gameData);
            }, childCount: paginatedGames.length),
          ),
        );
      },
    );
  }

  /// Build the games grid for normal context
  Widget _buildGamesGridNormal(List<GameBlock> paginatedGames) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisExtent = constraints.maxWidth;
        final crossAxisCount = GameCardLayout.getColumns(crossAxisExtent);

        final availableWidth =
            crossAxisExtent - (2 * GameCardLayout.horizontalPadding);

        final aspectRatio = GameCardLayout.calculateChildAspectRatio(
          availableWidth,
          crossAxisCount,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GameCardLayout.horizontalPadding,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              mainAxisSpacing: GameCardLayout.spacing,
              crossAxisSpacing: GameCardLayout.spacing,
            ),
            itemCount: paginatedGames.length,
            itemBuilder: (context, index) {
              return _buildGameCard(paginatedGames[index]);
            },
          ),
        );
      },
    );
  }

  /// Build a single game card
  Widget _buildGameCard(GameBlock gameData) {
    return GameCard(
      key: gameData.buildWidgetKey('GameGridView'),
      gameBlock: gameData,
      onPressed: widget.onGameTap != null
          ? () => widget.onGameTap?.call(gameData)
          : null,
    );
  }

  /// Build the "Load More" button content
  Widget _buildLoadMoreButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Center(
        child: SecondaryButton.gray(
          onPressed: _loadMore,
          size: SecondaryButtonSize.sm,
          label: const Text(I18n.txtShowMore),
        ),
      ),
    );
  }
}
