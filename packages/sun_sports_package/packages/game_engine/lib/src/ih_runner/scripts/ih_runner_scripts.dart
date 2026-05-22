/// {@template ih_runner_scripts}
/// Centralized repository of JavaScript scripts injected by IHRunner.
///
/// All scripts are idempotent (guarded by existence checks) so they can be
/// safely re-injected across WebView lifecycle events without side effects.
/// {@endtemplate}
abstract final class IHRunnerScripts {
  IHRunnerScripts._();

  // ---------------------------------------------------------------------------
  // Host Bridge Shim
  // ---------------------------------------------------------------------------

  /// Injects the `window.GameHost` bridge object into the game WebView.
  ///
  /// The shim exposes a unified `postMessage(data)` API for the game to call.
  /// It tries the following channels in order:
  ///
  /// 1. `flutter_inappwebview.callHandler` (InAppWebView — primary on Mobile/Web)
  /// 2. `FlutterChannel.postMessage` (legacy webview_flutter — fallback)
  /// 3. `window.parent.postMessage` (iframe origin — last resort on Web)
  ///
  /// Also sets up a legacy `window.FlutterChannel` shim for games that still
  /// use the old API.
  static const String bridgeShim = '''
    (function() {
      if (window.GameHost) return;

      window.GameHost = {
        postMessage: function(message) {
          var data = typeof message === 'string' ? message : JSON.stringify(message);
          var delivered = false;

          // 1. InAppWebView handler (primary)
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('flutterChannel', data);
            delivered = true;
          }

          // 2. Legacy webview_flutter channel (fallback)
          if (!delivered && window.FlutterChannel &&
              window.FlutterChannel.postMessage && !window.FlutterChannel._isShim) {
            window.FlutterChannel.postMessage(data);
            delivered = true;
          }

          // 3. Iframe postMessage (web last resort)
          if (!delivered && window.parent && window.parent !== window) {
            window.parent.postMessage(data, '*');
          }
        }
      };

      // Legacy FlutterChannel shim for older games
      if (typeof window.FlutterChannel === 'undefined') {
        window.FlutterChannel = {
          _isShim: true,
          postMessage: function(message) {
            window.GameHost.postMessage(message);
          }
        };
      }

      console.log('[IHRunner] GameHost Bridge initialized');
    })();
  ''';

  // ---------------------------------------------------------------------------
  // Web Compatibility Fixes
  // ---------------------------------------------------------------------------

  /// Patches `screen.orientation` if it is missing on some Web browsers.
  ///
  /// Some Cocos-engine games read `screen.orientation.type` on startup and
  /// crash if the property is `undefined`. This script is applied at
  /// `onWebViewCreated` (before any page JS runs).
  static const String earlyWebFix = '''
    (function() {
      if (typeof screen.orientation !== 'undefined') return;
      Object.defineProperty(screen, 'orientation', {
        get: function() { return { type: 'landscape-primary', angle: 0 }; }
      });
      console.log('[IHRunner] screen.orientation polyfill applied');
    })();
  ''';

  /// Fixes Cocos orientation state bugs and triggers a layout recalculation.
  ///
  /// Applied at `onLoadStop` after the page finishes loading. Resets the
  /// Cocos `_orientationChanging` flag and dispatches a synthetic `resize`
  /// event so the engine re-evaluates viewport dimensions.
  static const String postLoadWebFix = '''
    (function() {
      if (window.cc && cc.view) {
        cc.view._orientationChanging = false;
      }
      window.dispatchEvent(new Event('resize'));
      console.log('[IHRunner] Post-load web fix applied');
    })();
  ''';
}
