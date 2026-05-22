import 'package:flutter/material.dart';

/// A premium cinematic transition for launching immersive games.
///
/// Replaces the default sliding transition with a smooth fade
/// and a subtle scale (zoom) effect, mimicking a mode switch
/// rather than hierarchical navigation.
class GamePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  GamePageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        // Slightly longer duration for a cinematic feel
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Premium fast-out, slow-in curve
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          );

          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              // Cinematic zoom from 0.9 to 1.0
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      );
}
