/// Connection state for WebSocket
///
/// State transitions:
/// ```
/// ┌─────────────┐
/// │ disconnected│ ──connect()──► connecting ──success──► connected
/// └─────────────┘                    │                      │
///       ▲                          fail                   error/
///       │                            │                   disconnect
///       │                            ▼                      │
///       └────────────────────────  error  ◄─────────────────┘
///                                    │
///                                    │ (if autoReconnect)
///                                    ▼
///                              reconnecting ──success──► connected
///                                    │
///                                  fail (max retries)
///                                    │
///                                    ▼
///                              disconnected
/// ```
enum ConnectionState {
  /// Initial state, not connected to server
  disconnected,

  /// Attempting to establish connection
  connecting,

  /// Successfully connected and receiving messages
  connected,

  /// Connection lost, attempting to reconnect
  reconnecting,

  /// Connection error occurred
  error,
}

/// Extension methods for ConnectionState
extension ConnectionStateX on ConnectionState {
  /// Returns true if currently connected
  bool get isConnected => this == ConnectionState.connected;

  /// Returns true if attempting to connect
  bool get isConnecting =>
      this == ConnectionState.connecting ||
      this == ConnectionState.reconnecting;

  /// Returns true if disconnected or in error state
  bool get isDisconnected =>
      this == ConnectionState.disconnected || this == ConnectionState.error;

  /// Returns true if can attempt connection
  bool get canConnect =>
      this == ConnectionState.disconnected || this == ConnectionState.error;

  /// Returns a human-readable description
  String get description {
    switch (this) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.connecting:
        return 'Connecting...';
      case ConnectionState.connected:
        return 'Connected';
      case ConnectionState.reconnecting:
        return 'Reconnecting...';
      case ConnectionState.error:
        return 'Connection Error';
    }
  }
}

/// Event emitted when connection state changes
class ConnectionStateEvent {
  final ConnectionState previousState;
  final ConnectionState currentState;
  final String? errorMessage;
  final int? reconnectAttempt;
  final DateTime timestamp;

  const ConnectionStateEvent({
    required this.previousState,
    required this.currentState,
    this.errorMessage,
    this.reconnectAttempt,
    required this.timestamp,
  });

  /// Creates event for successful connection
  factory ConnectionStateEvent.connected({
    required ConnectionState previousState,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.connected,
      timestamp: DateTime.now(),
    );
  }

  /// Creates event for disconnection
  factory ConnectionStateEvent.disconnected({
    required ConnectionState previousState,
    String? reason,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.disconnected,
      errorMessage: reason,
      timestamp: DateTime.now(),
    );
  }

  /// Creates event for reconnection attempt
  factory ConnectionStateEvent.reconnecting({
    required ConnectionState previousState,
    required int attempt,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.reconnecting,
      reconnectAttempt: attempt,
      timestamp: DateTime.now(),
    );
  }

  /// Creates event for error
  factory ConnectionStateEvent.error({
    required ConnectionState previousState,
    required String message,
  }) {
    return ConnectionStateEvent(
      previousState: previousState,
      currentState: ConnectionState.error,
      errorMessage: message,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('ConnectionStateEvent(')
      ..write('$previousState → $currentState');
    if (errorMessage != null) {
      buffer.write(', error: $errorMessage');
    }
    if (reconnectAttempt != null) {
      buffer.write(', attempt: $reconnectAttempt');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
