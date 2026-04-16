import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// Shimmer loading for a horizontal game section
///
/// Shows a shimmer loading state for a horizontal carousel section,
/// including the section title and a horizontal list of game cards.
class GameHorizontalSectionShimmer extends StatelessWidget {
  const GameHorizontalSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title
        const ShimmerBox(width: 140, height: 24, borderRadius: 6),
        const SizedBox(height: 16),
        // Horizontal list of cards
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) =>
                const GameCardShimmer(width: GameCardLayout.minWidth),
          ),
        ),
      ],
    );
  }
}
