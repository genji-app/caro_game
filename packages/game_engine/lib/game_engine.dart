/// The Game Engine WebView package for Flutter.
///
/// Current supported features:
/// - [IHRunner]: Specialized WebView for In-house (proprietary) games with Host Bridge messaging.
/// - [PLRunner]: Specialized WebView for 3rd-party live provider games.
/// - [GameHostEvent]: Data model for cross-context bridge communication.
/// - InAppWebView integration for unified Mobile/Web support.
/// - [GameEngineLogger]: Flexible logging implementation.
library;

export 'src/ih_runner/ih_runner.dart';
export 'src/logger.dart';
export 'src/provider_live_runner/pl_runner.dart';
