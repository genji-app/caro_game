import 'dart:async';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/websocket_enums.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/websocket_enums.dart'
    show WsConnectionState;

/// Base WebSocket Class
///
/// Provides common functionality for all WebSocket connections:
/// - Connect/disconnect
/// - Auto-reconnect with exponential backoff
/// - Ping/pong heartbeat
/// - Message streaming
abstract class BaseWebSocket {
  final AppLogger _logger = AppLogger();

  /// WebSocket channel
  WebSocketChannel? _channel;

  /// Connection state
  WsConnectionState _state = WsConnectionState.disconnected;

  /// Current URL
  String _url = '';

  /// Stream controller for messages
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  /// Stream controller for connection state
  final StreamController<WsConnectionState> _stateController =
      StreamController<WsConnectionState>.broadcast();

  /// Reconnect timer
  Timer? _reconnectTimer;

  /// Heartbeat timer
  Timer? _heartbeatTimer;

  /// Channel stream subscription (to prevent listener leaks on reconnect)
  StreamSubscription<dynamic>? _channelSubscription;

  /// Reconnect attempt count
  int _reconnectAttempts = 0;

  /// Guard against concurrent _doConnect() calls (timer race condition)
  bool _isConnecting = false;

  /// Flag: token expired detected by subclass — skip auto-reconnect
  bool _needsTokenRefresh = false;

  /// Max reconnect attempts
  static const int maxReconnectAttempts = 5;

  /// Heartbeat interval in seconds
  static const int heartbeatInterval = 30;

  /// Base reconnect delay in seconds
  static const int baseReconnectDelay = 2;

  // ===== GETTERS =====

  /// Current connection state
  WsConnectionState get state => _state;

  /// Is connected
  bool get isConnected => _state == WsConnectionState.connected;

  /// Message stream
  Stream<String> get messageStream => _messageController.stream;

  /// State stream
  Stream<WsConnectionState> get stateStream => _stateController.stream;

  /// WebSocket name (for logging)
  String get name;

  // ===== PUBLIC METHODS =====

  /// Connect to WebSocket server
  Future<bool> connect(String url) async {
    if (_state == WsConnectionState.connecting) {
      _logger.w('$name: Already connecting...');
      return false;
    }

    if (_state == WsConnectionState.connected && _url == url) {
      _logger.w('$name: Already connected to $url');
      return true;
    }

    // Cancel auto-reconnect timer + close old channel BEFORE creating new
    _cancelTimers();
    _killCurrentChannel();
    _needsTokenRefresh = false; // Clean state for new connection cycle

    _url = url;
    _setState(WsConnectionState.connecting);
    _reconnectAttempts = 0;

    return _doConnect();
  }

  /// Disconnect from WebSocket server (graceful — with 5s timeout)
  Future<void> disconnect() async {
    _logger.i('$name: Disconnecting...');

    _cancelTimers();
    _reconnectAttempts = maxReconnectAttempts; // Prevent auto-reconnect

    await _closeCurrentChannel();

    _setState(WsConnectionState.disconnected);
  }

  /// Send message
  void send(String message) {
    if (!isConnected) {
      _logger.w('$name: Cannot send - not connected');
      return;
    }

    try {
      _channel?.sink.add(message);
      // _logger.d('$name: Sent: $message');
    } catch (e) {
      _logger.e('$name: Send error: $e');
    }
  }

  /// Send ping
  void ping() {
    send('PING');
  }

  /// Kill connection (force close without reconnect — fire-and-forget)
  void kill() {
    _cancelTimers();
    _reconnectAttempts = maxReconnectAttempts;
    _isConnecting = false;

    _killCurrentChannel();

    _setState(WsConnectionState.disconnected);
    _logger.i('$name: Killed');
  }

  /// Dispose resources
  void dispose() {
    kill();
    _messageController.close();
    _stateController.close();
  }

  // ===== PROTECTED METHODS =====

  /// Call from subclass when token error detected.
  /// Prevents auto-reconnect with stale token in _handleDone().
  void markTokenExpired() {
    _needsTokenRefresh = true;
  }

  /// Called when connected
  void onConnected() {
    // Override in subclass
  }

  /// Called when message received
  void onMessage(String message) {
    // Override in subclass
  }

  /// Called when disconnected
  void onDisconnected() {
    // Override in subclass
  }

  /// Called when error
  void onError(dynamic error) {
    // Override in subclass
  }

  // ===== PRIVATE METHODS =====

  /// Fire-and-forget close. Used in connect(), kill(), and _scheduleReconnect()
  /// to avoid blocking when server is unreachable.
  void _killCurrentChannel() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close(); // Not awaited — OS cleans up after TCP timeout
    _channel = null;
  }

  /// Graceful close with 5s timeout. Used in disconnect() only
  /// (when we have time to wait, e.g. logout flow).
  Future<void> _closeCurrentChannel() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;

    if (_channel != null) {
      try {
        await _channel!.sink.close().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _logger.w('$name: sink.close() timed out after 5s');
          },
        );
      } catch (e) {
        _logger.w('$name: sink.close() error (ignored): $e');
      }
      _channel = null;
    }
  }

  Future<bool> _doConnect() async {
    // Guard: prevent concurrent _doConnect() calls (timer race condition)
    if (_isConnecting) return false;
    _isConnecting = true;

    try {
      // _logger.i('$name: Connecting to $_url');

      final uri = Uri.parse(_url);
      _channel = WebSocketChannel.connect(uri);

      // Wait for connection
      await _channel!.ready;

      _setState(WsConnectionState.connected);
      _logger.i('$name: Connected');

      // Start heartbeat
      _startHeartbeat();

      // Defensive cancel — redundant after fix but kept from original code
      await _channelSubscription?.cancel();

      // Listen to messages
      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      // Notify subclass
      onConnected();

      return true;
    } catch (e) {
      _logger.e('$name: Connection failed: $e');
      _setState(WsConnectionState.error);
      onError(e);

      // Try to reconnect
      _scheduleReconnect();

      return false;
    } finally {
      _isConnecting = false;
    }
  }

  void _handleMessage(dynamic message) {
    final messageStr = message.toString();
    // _logger.d('$name: Received: $messageStr');

    // Handle pong
    if (messageStr.toUpperCase() == 'PONG') {
      return;
    }

    // Emit to stream
    _messageController.add(messageStr);

    // Notify subclass
    onMessage(messageStr);
  }

  void _handleError(dynamic error) {
    _logger.e('$name: Error: $error');
    _setState(WsConnectionState.error);
    onError(error);

    // Try to reconnect
    _scheduleReconnect();
  }

  void _handleDone() {
    _logger.w('$name: Connection closed');

    if (_state != WsConnectionState.disconnected) {
      _setState(WsConnectionState.disconnected);
      onDisconnected();

      // Skip auto-reconnect if token expired — subclass handles recovery
      if (!_needsTokenRefresh) {
        _scheduleReconnect();
      }
      _needsTokenRefresh = false;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _logger.e('$name: Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    _setState(WsConnectionState.reconnecting);

    // Exponential backoff with max cap at 60s
    final delay =
        (baseReconnectDelay * (1 << (_reconnectAttempts - 1))).clamp(0, 60);
    _logger.i('$name: Reconnecting in ${delay}s (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (_state == WsConnectionState.reconnecting && !_isConnecting) {
        _killCurrentChannel();
        _doConnect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: heartbeatInterval),
      (_) {
        if (isConnected) {
          ping();
        }
      },
    );
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _setState(WsConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }
}
