import 'package:flutter/material.dart';

/// A pure presentation widget that handles the slide and fade transitions for an overlay.
///
/// It does not manage its own state or visibility; it simply animates the [child]
/// based on the provided animations.
class OverlaySlideTransition extends StatelessWidget {
  const OverlaySlideTransition({
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.alignment,
    required this.child,
    this.backdropColor = Colors.black54,
    this.onBackdropTap,
    super.key,
  });

  /// The animation for the sliding motion.
  final Animation<Offset> slideAnimation;

  /// The animation for the backdrop opacity.
  final Animation<double> fadeAnimation;

  /// How to align the content within the stack.
  final AlignmentGeometry alignment;

  /// The content to animate.
  final Widget child;

  /// The color of the backdrop.
  final Color backdropColor;

  /// Callback when the backdrop is tapped.
  final VoidCallback? onBackdropTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        if (backdropColor != Colors.transparent)
          FadeTransition(
            opacity: fadeAnimation,
            child: GestureDetector(
              onTap: onBackdropTap,
              behavior: HitTestBehavior.opaque,
              child: Container(color: backdropColor),
            ),
          )
        else if (onBackdropTap != null)
          GestureDetector(
            onTap: onBackdropTap,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),

        // Content
        Align(
          alignment: alignment,
          child: SlideTransition(position: slideAnimation, child: child),
        ),
      ],
    );
  }
}
