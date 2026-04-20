import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';

/// The web implementation of [OrientationController].
/// Web browsers (especially mobile) cannot easily force physical rotation
/// due to various browser security restrictions and lack of standard API support.
/// This controller focuses on providing feedback about the current viewport.
class WebOrientationController implements OrientationController {
  /// Creates a new [WebOrientationController].
  const WebOrientationController();

  @override
  Future<OrientationViewState> apply(OrientationPolicy policy) async {
    debugPrint('Web applies policy: ${policy.targets.map((t) => t.name).join(', ')}');

    return OrientationViewState(
      policy: policy,
      status: OrientationStatus.idle,
      matched: true, // Default to true, handled by Guard.
      canControlPlatform: false,
    );
  }

  @override
  Future<void> restore() async {
    debugPrint('Web restoring default policy');
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
