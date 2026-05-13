import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';
import 'package:web/web.dart' as web; // Fullscreen API for Web

/// The web implementation of [OrientationController].
/// Web browsers (especially mobile) cannot easily force physical rotation
/// due to various browser security restrictions and lack of standard API support.
/// This controller focuses on providing feedback about the current viewport
/// and handling immersive mode using the Fullscreen API.
class WebOrientationController implements OrientationController {
  /// Creates a new [WebOrientationController].
  const WebOrientationController();

  @override
  Future<OrientationViewState> apply(OrientationPolicy policy) async {
    debugPrint('Web applies policy: ${policy.targets.map((t) => t.name).join(', ')}');

    // Handle Immersive Mode (Fullscreen API)
    if (policy.screenUi.immersive) {
      _enterFullscreen();
    } else {
      _exitFullscreen();
    }

    return OrientationViewState(
      policy: policy,
      status: OrientationStatus.idle,
      matched: true, // Default to true, handled by Guard.
      canControlPlatform: true, // Now we can control Fullscreen!
    );
  }

  @override
  Future<void> restore() async {
    debugPrint('Web restoring default policy (exiting fullscreen if any)');
    _exitFullscreen();
  }

  void _enterFullscreen() {
    try {
      final doc = web.document;
      final element = doc.documentElement;
      if (element != null) {
        // Only request if not already in fullscreen
        if (doc.fullscreenElement == null) {
          element.requestFullscreen();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [WebOrientation] Failed to enter fullscreen: $e');
    }
  }

  void _exitFullscreen() {
    try {
      final doc = web.document;
      if (doc.fullscreenElement != null) {
        doc.exitFullscreen();
      }
    } catch (e) {
      debugPrint('⚠️ [WebOrientation] Failed to exit fullscreen: $e');
    }
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    return policy.targets.any((target) {
      if (target.isPortrait) {
        return currentOrientation == Orientation.portrait;
      }
      if (target.isLandscape) {
        return currentOrientation == Orientation.landscape;
      }
      return false;
    });
  }
}

/// Provides the web implementation of [OrientationController].
OrientationController getPlatformController() => const WebOrientationController();
