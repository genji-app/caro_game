import 'package:flutter/material.dart';

import 'adaptive_overlay.dart';

/// {@template adaptive_overlay_close}
/// A generic close button designed for use within an [AdaptiveOverlay].
///
/// It uses [AdaptiveOverlay.of] to find and close the nearest
/// overlay when pressed.
/// {@endtemplate}
class AdaptiveOverlayClose extends StatelessWidget {
  /// {@macro adaptive_overlay_close}
  const AdaptiveOverlayClose({
    super.key,
    this.child,
    this.onPressed,
    this.padding,
  });

  /// The widget to display as the icon (defaults to a white close icon).
  final Widget? child;

  /// An optional callback to run when the button is pressed.
  ///
  /// If provided, this callback is responsible for closing the overlay
  /// if that behavior is desired.
  final VoidCallback? onPressed;

  /// The padding around the close button.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final controller = AdaptiveOverlay.of(context);

    return IconButton(
      padding: padding,
      icon: child ?? const Icon(Icons.close, color: Colors.white),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          controller.close();
        }
      },
    );
  }
}
