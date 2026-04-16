import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/home/presentation/widgets/hot_match/hot_match_carousel.dart';

/// Home Tablet Hot Bets Section
///
/// Displays hot matches carousel in the tablet home screen.
/// Uses HotMatchCarousel widget with real API data.
class HomeTabletHotBetsSection extends ConsumerWidget {
  const HomeTabletHotBetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 0),
    child: HotMatchCarousel(
      height: 210,
      viewportFraction: 0.6,
      autoScrollInterval: 7,
    ),
  );
}
