import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'socket_config.dart';
import '../events/connection_state.dart';
import '../utils/logger.dart';

/// Handles WebSocket connection lifecycle.
///
/// Features:
/// - Connection/disconnection
/// - Auto-reconnect with exponential backoff
/// - Ping/pong heartbeat
/// - Connection state management
class ConnectionHandler {
  final SocketConfig _config;
  final Logger _logger;

  /// Current URL (may be updated with new token during reconnect)
  String _currentUrl;

  /// Current WebSocket channel
  WebSocketChannel? _channel;

  /// Current connection state
  ConnectionState _state = ConnectionState.disconnected;

  /// Reconnection attempt counter
  int _reconnectAttempts = 0;

  /// Reconnection timer
  Timer? _reconnectTimer;

  /// Ping timer
  Timer? _pingTimer;

  /// Pong timeout timer
  Timer? _pongTimeoutTimer;

  /// Ping counter for ping/pong matching
  int _pingCounter = 0;

  /// Currently awaiting pong number
  int? _awaitingPongNumber;

  /// Stream subscription for incoming messages
  StreamSubscription<dynamic>? _messageSubscription;

  /// Stream controller for connection state changes
  final StreamController<ConnectionStateEvent> _stateController =
      StreamController<ConnectionStateEvent>.broadcast();

  /// Stream controller for incoming text messages (legacy, kept for compatibility)
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  /// Stream controller for incoming binary messages (V2 Protobuf)
  final StreamController<Uint8List> _binaryController =
      StreamController<Uint8List>.broadcast();

  /// Stream controller for reconnection events
  final StreamController<void> _reconnectedController =
      StreamController<void>.broadcast();

  /// Stream of connection state events
  Stream<ConnectionStateEvent> get onStateChanged => _stateController.stream;

  /// Stream of incoming text messages (legacy)
  Stream<String> get onMessage => _messageController.stream;

  /// Stream of incoming binary messages (V2 Protobuf)
  Stream<Uint8List> get onBinaryMessage => _binaryController.stream;

  /// Stream that emits when reconnection is successful
  Stream<void> get onReconnected => _reconnectedController.stream;

  /// Current connection state
  ConnectionState get state => _state;

  /// Whether currently connected
  bool get isConnected => _state == ConnectionState.connected;

  ConnectionHandler({
    required SocketConfig config,
  })  : _config = config,
        _logger = config.logger,
        _currentUrl = config.url;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_state == ConnectionState.connecting ||
        _state == ConnectionState.connected) {
      _logger.debug('Already connecting or connected');
      return;
    }

    _updateState(ConnectionState.connecting);

    try {
      _logger.info('Connecting to $_currentUrl');

      _channel = WebSocketChannel.connect(Uri.parse(_currentUrl));

      // Wait for connection to be ready
      await _channel!.ready;

      final wasReconnecting =
          _state == ConnectionState.reconnecting || _reconnectAttempts > 0;

      _state = ConnectionState.connected;
      final previousAttempts = _reconnectAttempts;
      _reconnectAttempts = 0;

      _emitStateEvent(ConnectionStateEvent.connected(
        previousState: ConnectionState.connecting,
      ));

      _logger.info('Connected to WebSocket');

      // Emit reconnected event if this was a reconnection
      if (wasReconnecting || previousAttempts > 0) {
        _logger.info('Reconnection successful, notifying subscribers...');
        _reconnectedController.add(null);
      }

      // Start listening for messages
      _startListening();

      // Start ping timer
      _startPingTimer();
    } catch (e, stackTrace) {
      _logger.error('Connection failed', e, stackTrace);

      _updateState(ConnectionState.error);
      _emitStateEvent(ConnectionStateEvent.error(
        previousState: ConnectionState.connecting,
        message: e.toString(),
      ));

      // Schedule reconnect if enabled
      if (_config.autoReconnect) {
        _scheduleReconnect();
      }
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _logger.info('Disconnecting...');

    // Cancel timers
    _cancelReconnectTimer();
    _cancelPingTimer();
    _cancelPongTimeoutTimer();

    // Reset ping state
    _awaitingPongNumber = null;

    // Cancel message subscription
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // Close channel
    await _channel?.sink.close();
    _channel = null;

    final previousState = _state;
    _updateState(ConnectionState.disconnected);

    _emitStateEvent(ConnectionStateEvent.disconnected(
      previousState: previousState,
      reason: 'Manual disconnect',
    ));

    _logger.info('Disconnected');
  }

  /// Send a message through the WebSocket
  void send(dynamic message) {
    if (_channel == null || !isConnected) {
      _logger.warning('Cannot send: not connected');
      return;
    }

    try {
      _channel!.sink.add(message);
    } catch (e) {
      _logger.error('Send error', e);
    }
  }

  /// Send ping to keep connection alive
  ///
  /// V1: Sends Base64 encoded "ping_<number>" as TEXT frame
  /// V2: Sends raw "ping_<number>" as BINARY frame (no Base64 encoding)
  void ping() {
    if (!isConnected) return;

    final pingNum = _pingCounter++;
    _awaitingPongNumber = pingNum;

    // Format: ping_<number>
    final message = 'ping_$pingNum';

    if (_config.useV2Protocol) {
      // V2: Send as BINARY frame - raw UTF-8 bytes (NOT Base64 encoded)
      final bytes = Uint8List.fromList(utf8.encode(message));
      send(bytes);
      _logger.debug('Sent $message as binary (${bytes.length} bytes)');
    } else {
      // V1: Send as TEXT frame (Base64 encoded)
      final base64Encoded = base64Encode(utf8.encode(message));
      send(base64Encoded);
      _logger.debug('Sent ping_$pingNum (V1 Base64)');
    }

    // Start pong timeout - reconnect if no pong received
    _cancelPongTimeoutTimer();
    _pongTimeoutTimer = Timer(_config.pongTimeout, () {
      _logger.warning(
          'Pong timeout - no response for ping_$pingNum, reconnecting...');
      _awaitingPongNumber = null;
      _handlePongTimeout();
    });
  }

  /// Handle pong timeout - force reconnect
  void _handlePongTimeout() {
    // Close current connection and trigger reconnect
    _messageSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;

    final previousState = _state;
    _updateState(ConnectionState.disconnected);

    _emitStateEvent(ConnectionStateEvent.disconnected(
      previousState: previousState,
      reason: 'Pong timeout',
    ));

    if (_config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle pong message response
  void _handlePongMessage(String pongMessage) {
    // Format: pong_<number>
    final number = int.tryParse(pongMessage.replaceFirst('pong_', ''));
    if (number == _awaitingPongNumber) {
      _logger.debug('Received pong_$number');
      _cancelPongTimeoutTimer();
      _awaitingPongNumber = null;
    }
  }

  void _cancelPongTimeoutTimer() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  void _startListening() {
    _messageSubscription = _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );
  }

  void _handleMessage(dynamic message) {
    // Handle binary messages (V2 Protobuf or encoded pong)
    if (message is List<int>) {
      final bytes = Uint8List.fromList(message);

      // V2: Check if this is a pong response (Base64 encoded binary)
      // Server may send pong as binary: UTF-8 bytes of Base64 string "cG9uZ18x" (pong_1)
      if (_config.useV2Protocol && bytes.length < 100) {
        // Pong messages are small, try to decode
        try {
          final textContent = utf8.decode(bytes);
          // Check if it's Base64 encoded pong
          if (textContent.startsWith('pong_')) {
            _handlePongMessage(textContent);
            return;
          }
          // Try Base64 decode
          try {
            final decoded = utf8.decode(base64Decode(textContent));
            if (decoded.startsWith('pong_')) {
              _handlePongMessage(decoded);
              return;
            }
          } catch (_) {
            // Not Base64 encoded pong, continue as protobuf
          }
        } catch (_) {
          // Not UTF-8 text, it's raw protobuf binary
        }
      }

      // Not a pong, route to binary controller for protobuf processing
      _binaryController.add(bytes);
      return;
    }

    // Handle string messages
    if (message is String) {
      // Check for pong (plain text format)
      if (message.startsWith('pong_')) {
        _handlePongMessage(message);
        return;
      }

      // Legacy pong format
      if (message == 'pong') {
        _cancelPongTimeoutTimer();
        _awaitingPongNumber = null;
        return;
      }

      // Try Base64 decode to check for encoded pong
      try {
        final decoded = utf8.decode(base64Decode(message));
        if (decoded.startsWith('pong_')) {
          _handlePongMessage(decoded);
          return;
        }
        // If decoded successfully but not pong, it might be other text data
        _messageController.add(message);
      } catch (_) {
        // Not Base64 encoded, treat as regular text message
        _messageController.add(message);
      }
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _logger.error('WebSocket error', error, stackTrace);

    final previousState = _state;
    _updateState(ConnectionState.error);

    _emitStateEvent(ConnectionStateEvent.error(
      previousState: previousState,
      message: error.toString(),
    ));

    // Schedule reconnect
    if (_config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    _logger.info('WebSocket connection closed');

    if (_state == ConnectionState.disconnected) {
      // Manual disconnect, don't reconnect
      return;
    }

    final previousState = _state;
    _updateState(ConnectionState.disconnected);

    _emitStateEvent(ConnectionStateEvent.disconnected(
      previousState: previousState,
      reason: 'Connection closed',
    ));

    // Schedule reconnect
    if (_config.autoReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    // Check max attempts
    if (_config.maxReconnectAttempts > 0 &&
        _reconnectAttempts >= _config.maxReconnectAttempts) {
      _logger.warning(
        'Max reconnect attempts reached ($_reconnectAttempts)',
      );
      return;
    }

    _reconnectAttempts++;

    // Exponential backoff
    final delay = Duration(
      milliseconds: _config.reconnectDelay.inMilliseconds *
          (1 << (_reconnectAttempts - 1).clamp(0, 5)),
    );

    _logger.info(
      'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _updateState(ConnectionState.reconnecting);

    _emitStateEvent(ConnectionStateEvent.reconnecting(
      previousState: _state,
      attempt: _reconnectAttempts,
    ));

    _reconnectTimer = Timer(delay, () async {
      // Refresh token trước khi reconnect (nếu có callback)
      if (_config.onTokenRefresh != null) {
        try {
          _logger.info(
            'Refreshing token before reconnect (attempt $_reconnectAttempts)...',
          );
          final newToken = await _config.onTokenRefresh!();
          if (newToken != null) {
            _logger.info('Token refreshed successfully');
            _updateUrlToken(newToken);
          }
        } catch (e) {
          _logger.error('Token refresh before reconnect failed', e);
          // Tiếp tục reconnect với token cũ, có thể fail
        }
      }

      await connect();
    });
  }

  /// Cập nhật token trong URL
  void _updateUrlToken(String newToken) {
    final uri = Uri.parse(_currentUrl);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams['token'] = newToken;
    _currentUrl = uri.replace(queryParameters: newParams).toString();
    _logger.debug('URL updated with new token');
  }

  void _startPingTimer() {
    _cancelPingTimer();

    _pingTimer = Timer.periodic(_config.pingInterval, (_) {
      if (isConnected) {
        ping();
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cancelPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _updateState(ConnectionState newState) {
    _state = newState;
  }

  void _emitStateEvent(ConnectionStateEvent event) {
    _stateController.add(event);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _messageController.close();
    await _binaryController.close();
    await _reconnectedController.close();
  }
}
