import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Unified shimmer loading for sport lists
///
/// Works for both mobile and desktop with configurable parameters.
class SportShimmerLoading extends StatelessWidget {
  final bool isDesktop;
  final int leagueCount;
  final int matchesPerLeague;

  const SportShimmerLoading({
    super.key,
    this.isDesktop = false,
    this.leagueCount = 3,
    this.matchesPerLeague = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          leagueCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? 8 : 4),
            child: _ShimmerLeagueCard(
              isDesktop: isDesktop,
              matchCount: matchesPerLeague,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerLeagueCard extends StatelessWidget {
  final bool isDesktop;
  final int matchCount;

  const _ShimmerLeagueCard({required this.isDesktop, required this.matchCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header shimmer
          _ShimmerLeagueHeader(isDesktop: isDesktop),

          // Match rows shimmer
          ...List.generate(
            matchCount,
            (index) => _ShimmerMatchRow(isDesktop: isDesktop),
          ),
        ],
      ),
    );
  }
}

class _ShimmerLeagueHeader extends StatelessWidget {
  final bool isDesktop;

  const _ShimmerLeagueHeader({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDesktop ? 48 : 40,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          // Logo shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1500),
            color: Colors.white24,
            child: Container(
              width: isDesktop ? 28 : 26,
              height: isDesktop ? 28 : 26,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Name shimmer
          Expanded(
            child: Shimmer(
              duration: const Duration(milliseconds: 1500),
              color: Colors.white24,
              child: Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Chevron shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1500),
            color: Colors.white24,
            child: Container(
              width: isDesktop ? 24 : 20,
              height: isDesktop ? 24 : 20,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerMatchRow extends StatelessWidget {
  final bool isDesktop;

  const _ShimmerMatchRow({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    // Desktop needed more vertical room; smaller height was causing RenderFlex overflow
    final rowHeight = isDesktop ? 180.0 : 220.0;

    return Container(
      height: rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          // Header bar shimmer
          Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                // Time shimmer
                Expanded(
                  flex: 1,
                  child: Shimmer(
                    duration: const Duration(milliseconds: 1500),
                    color: Colors.white24,
                    child: Container(
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Column titles shimmer
                Expanded(
                  flex: 2,
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Shimmer(
                          duration: const Duration(milliseconds: 1500),
                          color: Colors.white24,
                          child: Container(
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Teams and odds section
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teams column
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Home team shimmer
                      _ShimmerTeamRow(),
                      const SizedBox(height: 4),
                      // Away team shimmer
                      _ShimmerTeamRow(),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Odds columns
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          child: _ShimmerOddsColumn(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer shimmer
          const SizedBox(height: 8),
          Row(
            children: [
              // Icons shimmer
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Shimmer(
                    duration: const Duration(milliseconds: 1500),
                    color: Colors.white24,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // More markets shimmer
              Shimmer(
                duration: const Duration(milliseconds: 1500),
                color: Colors.white24,
                child: Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerTeamRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Team logo shimmer
          Shimmer(
            duration: const Duration(milliseconds: 1500),
            color: Colors.white24,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Team name shimmer
          Expanded(
            child: Shimmer(
              duration: const Duration(milliseconds: 1500),
              color: Colors.white24,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerOddsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: i < 1 ? 4 : 0),
            child: Shimmer(
              duration: const Duration(milliseconds: 1500),
              color: Colors.white24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
