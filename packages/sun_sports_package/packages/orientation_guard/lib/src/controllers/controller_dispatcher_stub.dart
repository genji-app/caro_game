import '../models/orientation_guard_config.dart';
import 'orientation_controller.dart';

/// Creates a platform-specific [OrientationController].
OrientationController createOrientationControllerV1({
  OrientationGuardConfig config = const OrientationGuardConfig(),
}) =>
    throw UnsupportedError(
      'Cannot create OrientationController without dart:html or dart:io',
    );
