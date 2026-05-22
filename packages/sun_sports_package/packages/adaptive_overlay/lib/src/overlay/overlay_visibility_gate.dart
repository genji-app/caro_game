import 'package:flutter/material.dart';

/// A widget that controls the mounting of its child based on an [AnimationController].
///
/// It mounts the [child] when the animation starts or when [isVisible] is true,
/// and unmounts it only when the animation completes the dismissal process.
///
/// This helps in freeing up resources (like a Navigator or large widget trees)
/// when the overlay is not active.
class OverlayVisibilityGate extends StatefulWidget {
  const OverlayVisibilityGate({
    required this.animation,
    required this.isVisible,
    required this.child,
    this.onDismissed,
    super.key,
  });

  /// The animation controller to listen to.
  final AnimationController animation;

  /// Whether the overlay should be visible according to the business logic.
  final bool isVisible;

  /// The content to show/mount.
  final Widget child;

  /// Callback when the dismiss animation completes.
  final VoidCallback? onDismissed;

  @override
  State<OverlayVisibilityGate> createState() => _OverlayVisibilityGateState();
}

class _OverlayVisibilityGateState extends State<OverlayVisibilityGate> {
  bool _isChildMounted = false;

  @override
  void initState() {
    super.initState();
    // Initially mount if visible or animation is already running/completed
    _isChildMounted = widget.isVisible || !widget.animation.isDismissed;
    widget.animation.addStatusListener(_onAnimationStatus);
  }

  @override
  void didUpdateWidget(covariant OverlayVisibilityGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_onAnimationStatus);
      widget.animation.addStatusListener(_onAnimationStatus);
    }

    // If it should become visible, mount immediately so the animation can start
    if (widget.isVisible && !_isChildMounted) {
      setState(() => _isChildMounted = true);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _isChildMounted) {
      setState(() => _isChildMounted = false);
      widget.onDismissed?.call();
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onAnimationStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChildMounted) return const SizedBox.shrink();
    return widget.child;
  }
}
