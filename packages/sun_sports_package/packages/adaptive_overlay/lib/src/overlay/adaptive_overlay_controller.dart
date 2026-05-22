import 'package:flutter/widgets.dart';

/// {@template adaptive_overlay_builder}
/// A builder function that provides the [BuildContext] and the
/// [AdaptiveOverlayController] to build a widget.
/// {@endtemplate}
typedef AdaptiveOverlayBuilder =
    Widget Function(BuildContext context, AdaptiveOverlayController controller);

/// {@template adaptive_overlay_controller}
/// A controller that manages the visibility state of an adaptive feature overlay.
///
/// This controller provides methods to [open], [close], and [toggle] the visibility
/// of the overlay, and notifies its listeners whenever the state changes.
/// {@endtemplate}
class AdaptiveOverlayController extends ChangeNotifier {
  /// {@macro adaptive_overlay_controller}
  AdaptiveOverlayController();

  bool _isVisible = false;

  /// Whether the overlay is currently visible.
  bool get isVisible => _isVisible;

  /// Opens the overlay.
  ///
  /// Does nothing if the overlay is already visible.
  void open() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  /// Closes the overlay.
  ///
  /// Does nothing if the overlay is already hidden.
  void close() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  /// Toggles the visibility state of the overlay.
  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}
