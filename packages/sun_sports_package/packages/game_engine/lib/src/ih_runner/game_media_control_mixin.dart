import 'ih_runner_ctrl.dart';

/// {@template game_media_control_mixin}
/// A common mixin providing Javascript-based utilities for game media control.
/// {@endtemplate}
mixin GameMediaControlMixin on IHRunnerCtrl {
  /// Stops all media (video/audio) elements in the webview.
  ///
  /// [clearPage] determines if the WebView should navigate to `about:blank`
  /// after stopping media to release resources.
  @override
  Future<void> stopAllMedia({bool clearPage = false}) async {
    try {
      await evaluateJavascript(
        "document.querySelectorAll('video, audio').forEach(el => { el.pause(); el.src = ''; el.load(); });",
      );

      if (clearPage) {
        // Platform specific logic if needed, but evaluateJavascript is enough for cleanup.
        // We could also call reload or navigate if really needed.
      }
    } catch (e) {
      logger('warning', 'stopAllMedia failed: $e');
    }
  }
}
