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
export 'platform_ui_controller_stub.dart'
    if (dart.library.io) 'platform_ui_controller_native.dart'
    if (dart.library.js_interop) 'platform_ui_controller_web.dart' show createPlatformUiController;
