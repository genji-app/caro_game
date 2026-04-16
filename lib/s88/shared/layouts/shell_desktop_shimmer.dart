import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Shimmer loading cho left sidebar trên Desktop
class ShellDesktopSidebarShimmer extends StatelessWidget {
  const ShellDesktopSidebarShimmer({super.key});

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs shimmer (Thể thao / Casino)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildShimmerBox(
                      width: double.infinity,
                      height: 69,
                      borderRadius: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildShimmerBox(
                      width: double.infinity,
                      height: 69,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu items shimmer
            for (int i = 0; i < 6; i++) ...[
              _buildMenuItemShimmer(),
              const SizedBox(height: 4),
            ],
            // Divider shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildShimmerBox(
                width: double.infinity,
                height: 2,
                borderRadius: 1,
              ),
            ),
            // Section title shimmer
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
            ),
            // Sport items shimmer
            for (int i = 0; i < 4; i++) ...[
              _buildMenuItemShimmer(),
              const SizedBox(height: 4),
            ],
            // Divider shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildShimmerBox(
                width: double.infinity,
                height: 2,
                borderRadius: 1,
              ),
            ),
            // Another section
            for (int i = 0; i < 3; i++) ...[
              _buildMenuItemShimmer(),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildShimmerBox(width: 20, height: 20, borderRadius: 4),
          const SizedBox(width: 8),
          Expanded(
            child: _buildShimmerBox(
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
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
}

/// Shimmer loading cho right sidebar trên Desktop
class ShellDesktopRightSidebarShimmer extends StatelessWidget {
  const ShellDesktopRightSidebarShimmer({super.key});

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 402,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Hot section shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildHotSectionShimmer(),
          ),
          const SizedBox(height: 12),
          // Live chat shimmer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildLiveChatShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotSectionShimmer() {
    return Container(
      height: 225,
      decoration: BoxDecoration(
        color: const Color(0x0AFFF6E4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
              const SizedBox(width: 8),
              _buildShimmerBox(width: 100, height: 16, borderRadius: 4),
              const Spacer(),
              _buildShimmerBox(width: 60, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // Match info shimmer
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    _buildShimmerBox(width: 32, height: 32, borderRadius: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildShimmerBox(
                        width: double.infinity,
                        height: 14,
                        borderRadius: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 30, height: 20, borderRadius: 4),
                  ],
                ),
                Row(
                  children: [
                    _buildShimmerBox(width: 32, height: 32, borderRadius: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildShimmerBox(
                        width: double.infinity,
                        height: 14,
                        borderRadius: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 30, height: 20, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Odds buttons
          Row(
            children: [
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 36,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShimmerBox(
                  width: double.infinity,
                  height: 36,
                  borderRadius: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveChatShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x0AFFF6E4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
              const SizedBox(width: 8),
              _buildShimmerBox(width: 80, height: 16, borderRadius: 4),
              const Spacer(),
              _buildShimmerBox(width: 24, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          // Chat messages shimmer
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildChatMessageShimmer(isRight: index % 3 == 0),
            ),
          ),
          const SizedBox(height: 12),
          // Input field shimmer
          _buildShimmerBox(
            width: double.infinity,
            height: 44,
            borderRadius: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessageShimmer({bool isRight = false}) {
    return Row(
      mainAxisAlignment: isRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isRight) ...[
          _buildShimmerBox(width: 28, height: 28, borderRadius: 14),
          const SizedBox(width: 8),
        ],
        _buildShimmerBox(
          width: 150 + (isRight ? 20 : 0),
          height: 36,
          borderRadius: 12,
        ),
        if (isRight) ...[
          const SizedBox(width: 8),
          _buildShimmerBox(width: 28, height: 28, borderRadius: 14),
        ],
      ],
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
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
}
