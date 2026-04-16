import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/game/shimmer/game_horizontal_section_shimmer.dart';

/// Shimmer loading for the game feed
///
/// Shows multiple horizontal section shimmers stacked vertically,
/// representing the loading state of the entire game feed.
class GameFeedShimmer extends StatelessWidget {
  const GameFeedShimmer({super.key, this.sectionCount = 3});

  final int sectionCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sectionCount,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (_, __) => const GameHorizontalSectionShimmer(),
    );
  }
}
