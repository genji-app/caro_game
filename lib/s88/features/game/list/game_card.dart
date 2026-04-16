import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/game/game_extensions.dart';

/// Centralized layout constants and calculations for game cards.
/// Used by both [GameGridView] and [GameHorizontalSection].
class GameCardLayout {
  // ============================================================================
  // CARD DIMENSIONS (SSOT)
  // ============================================================================

  /// Minimum and maximum dimensions for game cards
  static const double minWidth = 108;
  static const double minHeight = 144;
  static const double maxWidth = 108;
  static const double maxHeight = 144;

  static const double spacing = 10;
  static const double horizontalPadding = 6;
  static const double cardAspectRatio = 108 / 144;

  /// Calculate viewport columns based on screen width
  static int getColumns(double screenWidth) {
    return screenWidth >= 600 ? 5 : 3;
  }

  /// Calculate viewport fraction for carousel
  static double getCarouselViewportFraction(double screenWidth) {
    return 1.0 / getColumns(screenWidth);
  }

  /// Calculate dynamic card height from width
  static double calculateHeightFromWidth(double width) =>
      width / cardAspectRatio;

  /// Get the height of a card given its width.
  static double getCardHeight(double width) => calculateHeightFromWidth(width);

  /// Calculate child aspect ratio. Fixed to 100 / 140 as requested.
  static double calculateChildAspectRatio(double availableWidth, int columns) {
    return cardAspectRatio;
  }
}

/// Modern game card widget with badges and gradient overlay
/// Optimized for performance by isolating rebuilds and using const components.
class GameCard extends StatelessWidget {
  const GameCard({required this.gameBlock, this.onPressed, super.key});

  final GameBlock gameBlock;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AspectRatio(
        aspectRatio: GameCardLayout.cardAspectRatio,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _GameCover(
                imagePath: gameBlock.imagePath,
                gameName: gameBlock.gameName,
                providerName: gameBlock.providerName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Handles the image, hover animation, and text overlays.
/// Isolates hover rebuilds to only this section.
class _GameCover extends StatefulWidget {
  const _GameCover({
    required this.imagePath,
    required this.gameName,
    required this.providerName,
  });

  final String imagePath;
  final String gameName;
  final String providerName;

  @override
  State<_GameCover> createState() => _GameCoverState();
}

class _GameCoverState extends State<_GameCover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColorStyles.backgroundQuaternary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated background image
            _AnimatedImage(
              imagePath: widget.imagePath,
              isHovered: _isHovered,
              gameName: widget.gameName,
              providerName: widget.providerName,
            ),
          ],
        ),
      ),
    );
  }
}

/// Isolated animated image for better performance using RepaintBoundary.
/// On error, shows gradient overlay + game info instead of error icon.
class _AnimatedImage extends StatelessWidget {
  const _AnimatedImage({
    required this.imagePath,
    required this.gameName,
    required this.providerName,
    required this.isHovered,
  });

  final String imagePath;
  final String gameName;
  final String providerName;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedScale(
        scale: isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: ImageHelper.load(
          path: imagePath,
          fit: BoxFit.cover,
          // Fallback: Show gradient + game info on error
          errorWidget: Stack(
            fit: StackFit.expand,
            children: [
              // Solid background color
              Container(color: AppColorStyles.backgroundQuaternary),
              // Gradient overlay
              const _GradientOverlay(),

              const Icon(Icons.error_outline_rounded, color: Colors.grey),
              // Game info
              // _GameOverlayContent(title: imagePath, subtitle: providerName),
              _GameOverlayContent(title: gameName, subtitle: providerName),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static gradient overlay.
class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 0.85, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content floating over the image.
class _GameOverlayContent extends StatelessWidget {
  const _GameOverlayContent({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 8,
      right: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge(
              context: context,
              color: AppColorStyles.contentPrimary,
            ).copyWith(height: 1.1, fontWeight: FontWeight.w800),
          ),
          const Gap(4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelXSmall(
              context: context,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
