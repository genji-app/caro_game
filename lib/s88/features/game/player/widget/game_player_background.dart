import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';

/// Full-screen background used by loading and error overlays.
///
/// Renders the game's thumbnail as a blurred/gradient background so the
/// overlay feels visually connected to the game even before it loads.
class GamePlayerBackground extends StatelessWidget {
  const GamePlayerBackground({required this.child, super.key});

  const GamePlayerBackground.splash({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColorStyles.backgroundPrimary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background layer: Image with Gradient OR Solid Splash color
          SizedBox.square(
            dimension: 200,
            child: ImageHelper.getNetworkImage(
              imageUrl: AppImages.logoS88Home,
              fit: BoxFit.contain,
            ),
          ),

          // Gradient overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: const [0.0, 0.5, 0.9],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColorStyles.backgroundPrimary.withValues(alpha: 0.6),
                    AppColorStyles.backgroundPrimary.withValues(alpha: 0.92),
                    AppColorStyles.backgroundPrimary,
                  ],
                ),
              ),
            ),
          ),

          // Actual content (loading indicator / error message)
          child,
        ],
      ),
    );
  }
}
