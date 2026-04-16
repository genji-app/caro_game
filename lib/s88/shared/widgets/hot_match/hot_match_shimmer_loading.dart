import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

/// Shimmer loading for Hot Match section.
/// Item count: 1 (mobile), 2 (tablet), 3 (desktop). Horizontal layout, width auto-calculated.
class HotMatchShimmerLoading extends StatelessWidget {
  const HotMatchShimmerLoading({super.key, this.isRightSidebar = false});
  final bool isRightSidebar;

  static const double _horizontalGap = 8;
  static const double _horizontalPadding = 12;

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  static Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: _shimmerHighlightColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final isTablet = ResponsiveBuilder.isTablet(context);
    final itemsToShow = isMobile || isRightSidebar ? 1 : (isTablet ? 2 : 3);
    final totalGaps = itemsToShow > 1
        ? (itemsToShow - 1) * _horizontalGap
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final contentWidth = maxWidth - _horizontalPadding * 2;
          final itemWidth = itemsToShow > 0
              ? (contentWidth - totalGaps) / itemsToShow
              : contentWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderShimmer(),
              Padding(
                padding: const EdgeInsets.only(
                  left: _horizontalPadding,
                  right: _horizontalPadding,
                  bottom: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < itemsToShow; i++) ...[
                      if (i > 0) const Gap(_horizontalGap),
                      SizedBox(width: itemWidth, child: _HotMatchShimmerCard()),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(child: _shimmerBox(width: 100, height: 16, borderRadius: 4)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _shimmerBox(width: 32, height: 32, borderRadius: 12),
              const Gap(2),
              _shimmerBox(width: 32, height: 32, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _HotMatchShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MatchInfoBarShimmer(),
          _TeamsSectionShimmer(),
          _SentimentShimmer(),
          _OddsShimmer(),
        ],
      ),
    );
  }
}

class _MatchInfoBarShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              HotMatchShimmerLoading._shimmerBox(
                width: 70,
                height: 20,
                borderRadius: 4,
              ),
              const Gap(12),
              HotMatchShimmerLoading._shimmerBox(
                width: 16,
                height: 16,
                borderRadius: 4,
              ),
              const Gap(12),
              HotMatchShimmerLoading._shimmerBox(
                width: 16,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
          Row(
            children: [
              HotMatchShimmerLoading._shimmerBox(
                width: 16,
                height: 16,
                borderRadius: 4,
              ),
              const Gap(4),
              HotMatchShimmerLoading._shimmerBox(
                width: 36,
                height: 14,
                borderRadius: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamsSectionShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          HotMatchShimmerLoading._shimmerBox(
            width: 32,
            height: 32,
            borderRadius: 16,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HotMatchShimmerLoading._shimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
                const Gap(4),
                HotMatchShimmerLoading._shimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          const Gap(16),
          HotMatchShimmerLoading._shimmerBox(
            width: 32,
            height: 32,
            borderRadius: 16,
          ),
        ],
      ),
    );
  }
}

class _SentimentShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: AppColorStyles.borderPrimary),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              HotMatchShimmerLoading._shimmerBox(
                width: 12,
                height: 12,
                borderRadius: 4,
              ),
              const Gap(4),
              HotMatchShimmerLoading._shimmerBox(
                width: 40,
                height: 12,
                borderRadius: 4,
              ),
              const Gap(4),
              HotMatchShimmerLoading._shimmerBox(
                width: 60,
                height: 12,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OddsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: HotMatchShimmerLoading._shimmerBox(
              width: double.infinity,
              height: 36,
              borderRadius: 6,
            ),
          ),
          const Gap(16),
          Expanded(
            child: HotMatchShimmerLoading._shimmerBox(
              width: double.infinity,
              height: 36,
              borderRadius: 6,
            ),
          ),
        ],
      ),
    );
  }
}
