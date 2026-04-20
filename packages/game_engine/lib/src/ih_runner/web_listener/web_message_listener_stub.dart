/// Stub implementation of the postMessage listener.
mixin WebMessageListenerMixin {
  /// Called when a message is received from `window.postMessage`.
  void onMessageReceive(dynamic data) {}

  /// Stub for registering the global 'message' event listener.
  void registerWebMessageListener() {}

  /// Stub for removing the global 'message' event listener.
  void unregisterWebMessageListener() {}
}
