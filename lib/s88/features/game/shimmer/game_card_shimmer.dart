import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/game/shimmer/shimmer_box.dart';

/// Shimmer loading for a single game card
///
/// Reusable component that shows a shimmer placeholder for a game card.
/// Can be used in both feed (horizontal) and grid (vertical) layouts.
class GameCardShimmer extends StatelessWidget {
  const GameCardShimmer({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main cover image area
          Expanded(
            child: ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          SizedBox(height: 8),
          // Game title & Provider line
          ShimmerBox(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
