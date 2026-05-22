import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web implementation of the postMessage listener.
mixin WebMessageListenerMixin {
  /// A JavaScript exported Dart function to listen for messages from the WebView.
  JSExportedDartFunction? _messageListener;

  /// Override this method to customize how messages are handled.
  /// [data] is the dartified version of the JS `MessageEvent.data`.
  void onMessageReceive(dynamic data) {}

  /// Registers a message listener to receive messages from the global `window`.
  void registerWebMessageListener() {
    if (_messageListener != null) return;

    _messageListener = (web.Event event) {
      // Fix: Use isA<web.MessageEvent>() for JS interop types
      if (!event.isA<web.MessageEvent>()) return;

      final messageEvent = event as web.MessageEvent;
      onMessageReceive(messageEvent.data?.dartify());
    }.toJS;

    web.window.addEventListener('message', _messageListener);
  }

  /// Unregisters the previously registered message listener.
  void unregisterWebMessageListener() {
    if (_messageListener == null) return;
    web.window.removeEventListener('message', _messageListener);
    _messageListener = null;
  }
}
