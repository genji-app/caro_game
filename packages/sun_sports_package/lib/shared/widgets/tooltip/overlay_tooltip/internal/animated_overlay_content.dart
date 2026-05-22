import 'package:flutter/material.dart';

/// Internal widget that renders animated overlay tooltip content.
///
/// Provides smooth fade and scale animations when the tooltip appears.
/// This widget is used internally by [OverlayTooltipHelper] when
/// `enableAnimation: true`.
///
/// ## Animation Details
/// - **Duration**: 200ms
/// - **Curve**: Curves.easeOut
/// - **Fade**: 0.0 → 1.0 opacity
/// - **Scale**: 0.95 → 1.0 size
/// - **Origin**: Based on tooltip alignment
///
/// ## Internal Use Only
/// This class should not be instantiated directly. Use [OverlayTooltipHelper]
/// instead.
class AnimatedOverlayTooltipContent extends StatefulWidget {
  const AnimatedOverlayTooltipContent({
    required this.child,
    required this.onClose,
    required this.alignment,
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.allowBackgroundInteraction = false,
  });

  final Widget child;
  final VoidCallback onClose;
  final Alignment alignment;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  /// If true, allows interaction with elements behind the tooltip
  /// If false, tapping outside closes the tooltip (default behavior)
  final bool allowBackgroundInteraction;

  @override
  State<AnimatedOverlayTooltipContent> createState() =>
      _AnimatedOverlayTooltipContentState();
}

class _AnimatedOverlayTooltipContentState
    extends State<AnimatedOverlayTooltipContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop to close tooltip when tapping outside
        // Or allow interaction through if enabled
        Positioned.fill(
          child: widget.allowBackgroundInteraction
              ? IgnorePointer(child: Container(color: Colors.transparent))
              : GestureDetector(
                  onTap: widget.onClose,
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
        ),

        // Tooltip content with animations
        Positioned(
          top: widget.top,
          left: widget.left,
          right: widget.right,
          bottom: widget.bottom,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: widget.alignment,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping on tooltip
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
