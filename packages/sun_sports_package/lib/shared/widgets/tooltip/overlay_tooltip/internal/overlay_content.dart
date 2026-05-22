import 'package:flutter/material.dart';

/// Internal widget that renders static overlay tooltip content without animation.
///
/// This widget is used internally by [OverlayTooltipHelper] when
/// `enableAnimation: false`.
///
/// ## Features
/// - No animations (instant display)
/// - Backdrop for dismissal on outside tap
/// - Prevents dismissal when tapping tooltip content
/// - Allows interaction with elements behind the backdrop
///
/// ## Internal Use Only
/// This class should not be instantiated directly. Use [OverlayTooltipHelper]
/// instead.
class OverlayTooltipContent extends StatelessWidget {
  const OverlayTooltipContent({
    required this.child,
    required this.onClose,
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.allowBackgroundInteraction = false,
  });

  final Widget child;
  final VoidCallback onClose;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  /// If true, allows interaction with elements behind the tooltip
  /// If false, tapping outside closes the tooltip (default behavior)
  final bool allowBackgroundInteraction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop to close tooltip when tapping outside
        // Or allow interaction through if enabled
        Positioned.fill(
          child: allowBackgroundInteraction
              ? IgnorePointer(child: Container(color: Colors.transparent))
              : GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
        ),

        // Tooltip content
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on tooltip
            child: child,
          ),
        ),
      ],
    );
  }
}
