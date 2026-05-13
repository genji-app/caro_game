import 'orientation_controller.dart';
import 'orientation_controller_stub.dart'
    if (dart.library.io) 'native_orientation_controller.dart'
    if (dart.library.js_interop) 'web_orientation_controller.dart';

/// Returns the correct platform-specific implementation of [OrientationController].
/// This function is safe to compile on all platforms.
OrientationController createOrientationController() {
  // Over web/native specialized files should define a top-level create() or getInstance()
  // Or since classes are exported, we can just instantiate them if matched.
  // BUT the common way is to let the platform file override a global factory or function.

  // Here we use a simpler approach: return the platform version.
  return getPlatformController();
}
