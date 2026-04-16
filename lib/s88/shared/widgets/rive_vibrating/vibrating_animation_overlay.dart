import 'package:flutter/material.dart';

/// Lightweight Flutter animation overlay for vibrating odds (Kèo Rung).
///
/// This replaces the heavy Rive-based animation with a simple Flutter
/// animation that's much more performant when multiple instances are needed.
///
/// Benefits over Rive:
/// - No separate render context per instance
/// - Shares Flutter's animation system
/// - Minimal memory overhead
/// - Can handle 100+ instances without performance issues
class VibratingAnimationOverlay extends StatefulWidget {
  const VibratingAnimationOverlay({super.key});

  @override
  State<VibratingAnimationOverlay> createState() =>
      _VibratingAnimationOverlayState();
}

class _VibratingAnimationOverlayState extends State<VibratingAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Pulsing opacity: 0.3 → 0.7 → 0.3
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Subtle scale pulse: 0.98 → 1.02 → 0.98
    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(
                  0xFFFFD700,
                ).withOpacity(_opacityAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFFFD700,
                  ).withOpacity(_opacityAnimation.value * 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Positioned overlay for BetCard - Flutter animation version.
///
/// Drop-in replacement for PositionedRiveVibratingOverlay.
/// Much lighter weight - can handle many instances without performance issues.
class PositionedVibratingOverlay extends StatelessWidget {
  final bool isVisible;

  const PositionedVibratingOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return const Positioned.fill(child: VibratingAnimationOverlay());
  }
}
