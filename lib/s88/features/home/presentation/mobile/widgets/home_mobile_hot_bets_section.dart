import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/home/presentation/widgets/hot_match/hot_match_carousel.dart';

/// Home Mobile Hot Bets Section
///
/// Displays hot matches carousel in the home screen.
/// Uses HotMatchCarousel widget with real API data.
class HomeMobileHotBetsSection extends ConsumerWidget {
  const HomeMobileHotBetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 0),
    child: HotMatchCarousel(
      height: 200,
      viewportFraction: 0.9,
      autoScrollInterval: 7,
    ),
  );
}
