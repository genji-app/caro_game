// Conditional-import dispatcher for PlatformUiController.
//
// Re-exports `createPlatformUiController` from the platform-
// appropriate file, selected at compile time:
//
// - dart.library.io        → PlatformUiControllerNative
// - dart.library.js_interop → PlatformUiControllerWeb
// - fallback               → PlatformUiControllerStub
//
// Consumers should call createPlatformUiController() instead
// of constructing implementations directly.
export 'platform_ui_controller_factory.dart';
export 'platform_ui_controller.dart';
export 'platform_ui_config.dart';
export 'platform_ui_guard.dart';
