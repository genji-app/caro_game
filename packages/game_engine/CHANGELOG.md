# Changelog

All notable changes to the `game_engine` package will be documented here.

## [1.4.0] - 2026-04-02

### Refactored
- **IHRunner Bridge & Listener Architecture**: Simplified the internal bridge logic by merging `BaseBridgeMixin` and `IHRunnerBridgeMixin` into a single `GameBridgeMixin`.
- **Standalone Event Model**: Extracted `GameHostEvent` into its own file (`lib/src/ih_runner/game_host_event.dart`) for better isolation and testability.
- **Unified JS Scripts**: Centralized all JavaScript shims and fixes into `IHRunnerScripts` located in `lib/src/ih_runner/scripts/ih_runner_scripts.dart`.
- **Logic Decoupling**: Moved bridge injection and platform-specific fixes from `IHInAppRunnerView` to `IHInAppRunnerCtrl`.
- **Automated Web Listener**: Integrated `WebMessageListenerMixin` directly into the IHRunner pipeline, automating message parsing for Web platforms.

### Added
- **Diagnostic Logging**: Added direct logging for `onReceivedError` in `IHInAppRunnerView` to improve troubleshooting for failed page loads.
- **Bridge Configuration**: Added `enableHostMessage` flag to `IHRunnerCtrl` to allow fine-grained control over bridge injection.

### Fixed
- **JS Interop Type Safety**: Updated Web Message Listener to use `isA<web.MessageEvent>()` for compliant runtime type checks on Web.

## [1.3.0] - 2026-03-30
<truncated 112 lines>
