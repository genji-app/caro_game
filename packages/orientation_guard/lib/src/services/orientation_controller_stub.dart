import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';

/// A stub implementation that throws error on unknown platforms.
class StubOrientationController implements OrientationController {
  const StubOrientationController();

  @override
  Future<OrientationViewState> apply(OrientationPolicy policy) =>
      throw UnsupportedError('OrientationController is not supported on this platform.');

  @override
  Future<void> restore() =>
      throw UnsupportedError('OrientationController is not supported on this platform.');

  @override
  bool isMatched({required OrientationPolicy policy, required Orientation currentOrientation}) =>
      false;
}

/// Provides a platform-agnostic way to get the correct controller.
OrientationController getPlatformController() => const StubOrientationController();
