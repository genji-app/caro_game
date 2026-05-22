import 'package:flutter/foundation.dart';

/// External controller for SmartTooltip
///
/// Allows programmatic control of tooltip visibility
///
/// ## Usage:
/// ```dart
/// final controller = SmartTooltipController();
///
/// SmartTooltip(
///   controller: controller,
///   contentBuilder: (onClose) => Text('Tooltip'),
/// )
///
/// // Show programmatically
/// controller.show();
///
/// // Hide programmatically
/// controller.hide();
///
/// // Toggle
/// controller.toggle();
/// ```
class SmartTooltipController extends ChangeNotifier {
  bool _isShowing = false;

  VoidCallback? _showCallback;
  VoidCallback? _hideCallback;

  /// Whether tooltip is currently showing
  bool get isShowing => _isShowing;

  /// Internal: Attach callbacks from SmartTooltip
  void attach({required VoidCallback onShow, required VoidCallback onHide}) {
    _showCallback = onShow;
    _hideCallback = onHide;
  }

  /// Internal: Detach callbacks
  void detach() {
    _showCallback = null;
    _hideCallback = null;
  }

  /// Internal: Update showing state
  void updateState(bool showing) {
    if (_isShowing != showing) {
      _isShowing = showing;
      notifyListeners();
    }
  }

  /// Show tooltip programmatically
  void show() {
    _showCallback?.call();
  }

  /// Hide tooltip programmatically
  void hide() {
    _hideCallback?.call();
  }

  /// Toggle tooltip visibility
  void toggle() {
    if (_isShowing) {
      hide();
    } else {
      show();
    }
  }

  @override
  void dispose() {
    _showCallback = null;
    _hideCallback = null;
    super.dispose();
  }
}
