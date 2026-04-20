import 'package:flutter/widgets.dart';

import 'adaptive_overlay.dart';
import 'adaptive_overlay_controller.dart';

/// Extension on [BuildContext] to provide convenient access to
/// the nearest adaptive overlay components.
extension AdaptiveOverlayContextX on BuildContext {
  /// Retrieves the [AdaptiveOverlayController] from the nearest ancestor.
  ///
  /// This will return null if no [AdaptiveOverlay] is found.
  AdaptiveOverlayController? get adaptiveOverlayController =>
      AdaptiveOverlay.maybeOf(this);

  /// Opens the nearest adaptive overlay.
  void openAdaptiveOverlay() => adaptiveOverlayController?.open();

  /// Closes the nearest adaptive overlay.
  void closeAdaptiveOverlay() => adaptiveOverlayController?.close();

  /// Toggles the visibility of the nearest adaptive overlay.
  void toggleAdaptiveOverlay() => adaptiveOverlayController?.toggle();
}
