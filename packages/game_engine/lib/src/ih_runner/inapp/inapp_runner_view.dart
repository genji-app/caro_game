import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../logger.dart';
import '../ih_runner_ctrl.dart';
import '../web_listener/web_message_listener_mixin.dart';
import 'inapp_runner_ctrl.dart';

/// {@template ih_inapp_runner_view}
/// Implementation of [IHRunner] using `flutter_inappwebview`.
/// This view is unified for both Mobile and Web platforms.
/// {@endtemplate}
class IHInAppRunnerView extends StatefulWidget {
  /// Initializes [IHInAppRunnerView].
  const IHInAppRunnerView({
    required this.gameUrl,
    required this.controller,
    required this.logger,
    super.key,
    this.enableHostMessage = true,
  });

  /// The entry point URL of the IHRunner game.
  final String gameUrl;

  /// The controller to manage communication between Flutter and IHRunner.
  final IHInAppRunnerCtrl controller;

  /// Logger to track events within the WebView.
  final GameEngineLogger logger;

  /// Whether to allow injecting the Host Bridge. Defaults to `true`.
  final bool enableHostMessage;

  @override
  State<IHInAppRunnerView> createState() => _IHInAppRunnerViewState();
}

class _IHInAppRunnerViewState extends State<IHInAppRunnerView> with WebMessageListenerMixin {
  /// A [GlobalKey] to uniquely identify the [InAppWebView] widget.
  final GlobalKey _webViewKey = GlobalKey();

  @override
  void onMessageReceive(dynamic data) {
    if (data == null) return;
    try {
      // In Web context, data might be a JSString or Map.
      // The bridge handles parsing.
      widget.controller.processHostMessage(data);
    } catch (e) {
      widget.logger('error', 'Web message parse error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.enableHostMessage) {
      registerWebMessageListener();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      unregisterWebMessageListener();
    }
    widget.controller.stopAllMedia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(
        url: WebUri(widget.gameUrl),
      ),
      initialSettings: kIsWeb
          ? InAppWebViewSettings(
              useShouldOverrideUrlLoading: false,
              javaScriptEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              isInspectable: kDebugMode,
              // transparentBackground: false,

              // ✅ WEB: Full Iframe & Permissions (No Sandbox for maximum compatibility)
              iframeAllow:
                  'autoplay *; fullscreen *; accelerometer *; gyroscope *; camera *; microphone *; geolocation *; clipboard-read *; clipboard-write *; payment *; midi *',
              // iframeAllowFullscreen: true,
              // iframeSandbox: {
              //   // Core Cocos
              //   Sandbox.ALLOW_SCRIPTS,
              //   Sandbox.ALLOW_SAME_ORIGIN,

              //   // Game features
              //   Sandbox.ALLOW_POPUPS,
              //   Sandbox.ALLOW_DOWNLOADS,
              //   Sandbox.ALLOW_MODALS,
              //   Sandbox.ALLOW_ORIENTATION_LOCK,
              //   Sandbox.ALLOW_FORMS,
              //   Sandbox.ALLOW_POINTER_LOCK,

              //   // ✅ Auth redirect & Storage
              //   Sandbox.ALLOW_TOP_NAVIGATION_BY_USER_ACTIVATION,
              // },

              // ✅ APP: Viewport & Native backup
              // minimumViewportInset: EdgeInsets.zero,
              // maximumViewportInset: EdgeInsets.zero,
              // ignoresViewportScaleLimits: true,

              // ✅ WEB: Desktop hints backup
              // userAgent:
              //     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            )
          : InAppWebViewSettings(
              useShouldOverrideUrlLoading: false,
              javaScriptEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              verticalScrollBarEnabled: false,
              horizontalScrollBarEnabled: false,
              allowsBackForwardNavigationGestures: false,
              isInspectable: kDebugMode,
            ),
      onWebViewCreated: (controller) {
        widget.controller.onWebViewCreated(controller);
      },
      onLoadStart: (controller, url) {
        widget.logger('info', 'Started: $url');
        widget.controller.updateState(
          IHRunnerState.loading,
          url: url?.toString(),
        );
      },
      onLoadStop: (controller, url) async {
        widget.logger('info', 'Finished: $url');
        widget.controller.updateState(
          IHRunnerState.loaded,
          url: url?.toString(),
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        widget.logger('info', 'Console: ${consoleMessage.message}');
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame ?? false) {
          widget.logger('error', 'ReceivedError: $error');
          widget.controller.updateState(
            IHRunnerState.error,
            url: request.url.toString(),
          );
        }
      },
    );
  }
}
