import 'dart:async';
import 'dart:convert';
import 'package:co_caro_flame/s88/core/services/websocket/base_websocket.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/auth/token_error_handler.dart';
import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';

/// Chat WebSocket Commands
class ChatWsCommand {
  static const String login = 'login';
  static const String fetchChatBox = 'fetchChatBox';
  static const String chat = 'chat';
  static const String error = 'error';
}

/// Chat Message Data Model
///
/// Represents a chat message with display properties
class ChatMessageData {
  final String? displayName;
  final String message;
  final int top;
  final bool isNoti;
  final bool isError;
  final DateTime timestamp;

  const ChatMessageData({
    required this.message,
    required this.timestamp,
    this.displayName,
    this.top = 0,
    this.isNoti = false,
    this.isError = false,
  });

  /// Is this a highlighted/VIP message
  bool get isHighlighted => top > 0;

  /// Is this a system message (no sender)
  bool get isSystemMessage => displayName == null || displayName!.isEmpty;

  /// Create from server message
  factory ChatMessageData.fromServerMessage({
    required String? fromUser,
    required String messageJson,
    int top = 0,
    String? type,
  }) {
    String content = messageJson;

    // Parse JSON message content if it's JSON format
    try {
      if (messageJson.startsWith('{')) {
        final parsed = jsonDecode(messageJson) as Map<String, dynamic>;
        content = parsed['chatContent'] as String? ?? messageJson;
      }
    } catch (_) {
      // Use raw message if parsing fails
    }

    return ChatMessageData(
      displayName: fromUser,
      message: content,
      top: top,
      isNoti: type == 'TIP',
      timestamp: DateTime.now(),
    );
  }

  /// Create error message
  factory ChatMessageData.error(String message) => ChatMessageData(
    message: message,
    isError: true,
    timestamp: DateTime.now(),
  );

  /// Create system notification
  factory ChatMessageData.system(String message) => ChatMessageData(
    message: message,
    isNoti: true,
    timestamp: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'message': message,
    'top': top,
    'isNoti': isNoti,
    'isError': isError,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Chat WebSocket
///
/// Handles real-time chat functionality according to the protocol:
/// - Login with accessToken and wsToken
/// - Fetch chat history
/// - Send/receive messages
/// - Ping/pong heartbeat with custom format
class SbChatWebSocket extends BaseWebSocket {
  final AppLogger _logger = AppLogger();

  /// Access token (from main login or sportbook)
  String? _accessToken;

  /// WebSocket token
  String? _wsToken;

  /// Current user name for display
  String? _currentUserName;

  /// Is logged in to chat server
  bool _isLoggedIn = false;

  /// Ping ID counter
  int _pingId = 0;

  /// Ping timer (5 seconds interval)
  Timer? _pingTimer;

  /// Command queue (for commands sent before login)
  final List<String> _commandQueue = [];

  /// Stream controller for chat messages
  final StreamController<ChatMessageData> _messageController =
      StreamController<ChatMessageData>.broadcast();

  /// Stream controller for chat history
  final StreamController<List<ChatMessageData>> _historyController =
      StreamController<List<ChatMessageData>>.broadcast();

  /// Stream controller for errors
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  /// Stream controller for login status
  final StreamController<bool> _loginStatusController =
      StreamController<bool>.broadcast();

  @override
  String get name => 'SbChatWebSocket';

  // ===== GETTERS =====

  /// Is logged in to chat server
  bool get isLoggedIn => _isLoggedIn;

  /// Current user name
  String? get currentUserName => _currentUserName;

  // ===== STREAMS =====

  /// Chat message stream (new messages)
  Stream<ChatMessageData> get chatMessageStream => _messageController.stream;

  /// Chat history stream (initial load)
  Stream<List<ChatMessageData>> get historyStream => _historyController.stream;

  /// Error stream
  Stream<String> get errorStream => _errorController.stream;

  /// Login status stream
  Stream<bool> get loginStatusStream => _loginStatusController.stream;

  // ===== PUBLIC METHODS =====

  /// Connect with authentication
  ///
  /// [url] WebSocket URL (ws_sport_domain?token=wsToken)
  /// [accessToken] Access token for login command
  /// [wsToken] WebSocket token for URL and login command
  /// [userName] Current user name for display
  Future<bool> connectWithAuth(
    String url,
    String accessToken,
    String wsToken,
    String userName,
  ) async {
    _accessToken = accessToken;
    _wsToken = wsToken;
    _currentUserName = userName;
    _isLoggedIn = false;
    _pingId = 0;

    return connect(url);
  }

  /// Fetch chat history
  void fetchChatBox() {
    if (!_isLoggedIn) {
      // Queue the command if not logged in yet
      final command = jsonEncode({
        'command': ChatWsCommand.fetchChatBox,
        'roomName': SbConfig.chatRoom,
      });
      _commandQueue.add(command);
      return;
    }

    final command = jsonEncode({
      'command': ChatWsCommand.fetchChatBox,
      'roomName': SbConfig.chatRoom,
    });
    send(command);
    // _logger.d('$name: Fetching chat history');
  }

  /// Send a chat message
  ///
  /// [content] Message content to send
  void sendChatMessage(String content) {
    if (!isConnected) {
      _logger.w('$name: Cannot send message - not connected');
      return;
    }

    if (!_isLoggedIn) {
      _logger.w('$name: Cannot send message - not logged in');
      return;
    }

    // Message content must be JSON string
    final messageContent = jsonEncode({'chatContent': content});

    final command = jsonEncode({
      'command': ChatWsCommand.chat,
      'roomName': SbConfig.chatRoom,
      'message': messageContent,
    });
    send(command);
    _logger.d('$name: Sending message: $content');
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _messageController.close();
    _historyController.close();
    _errorController.close();
    _loginStatusController.close();
    super.dispose();
  }

  // ===== PROTECTED OVERRIDES =====

  @override
  void onConnected() {
    _logger.i('$name: Connected, sending login...');
    _sendLogin();
  }

  @override
  void onMessage(String message) {
    _handleMessage(message);
  }

  @override
  void onDisconnected() {
    _logger.w('$name: Disconnected');
    _isLoggedIn = false;
    _pingTimer?.cancel();
    _loginStatusController.add(false);
  }

  @override
  void onError(dynamic error) {
    _logger.e('$name: Error: $error');
    _errorController.add(error.toString());
  }

  // ===== PRIVATE METHODS =====

  /// Send login command
  void _sendLogin() {
    if (_accessToken == null || _wsToken == null) {
      _logger.e('$name: Cannot login - missing tokens');
      return;
    }

    final command = jsonEncode({
      'command': ChatWsCommand.login,
      'accessToken': _accessToken,
      'wsToken': _wsToken,
    });
    send(command);
    _logger.d('$name: Login command sent');
  }

  /// Handle incoming messages
  void _handleMessage(String rawMessage) {
    try {
      // Check for pong response (array format: [6, pongId])
      if (rawMessage.startsWith('[')) {
        final data = jsonDecode(rawMessage) as List<dynamic>;
        if (data.isNotEmpty && data[0] == 6) {
          _onPong(data.length > 1 ? data[1] as int : 0);
          return;
        }
      }

      // Parse as JSON object
      final data = jsonDecode(rawMessage) as Map<String, dynamic>;

      // Check for pong in object format
      if (data.containsKey('pong')) {
        _onPong(data['pong'] as int? ?? 0);
        return;
      }

      final String? command = data['command'] as String?;

      switch (command) {
        case ChatWsCommand.login:
          _onLoginSuccess();
          break;

        case ChatWsCommand.fetchChatBox:
          _onFetchChatBox(data);
          break;

        case ChatWsCommand.chat:
          _onReceivedChat(data);
          break;

        case ChatWsCommand.error:
          _onChatError(data['message'] as String? ?? 'Unknown error');
          break;

        default:
          _logger.d('$name: Unknown command: $command');
      }
    } catch (e) {
      _logger.e('$name: Parse message error: $e, raw: $rawMessage');
    }
  }

  /// Handle login success
  void _onLoginSuccess() {
    _logger.i('$name: Login successful');
    _isLoggedIn = true;
    _loginStatusController.add(true);

    // Start ping timer
    _startPingTimer();

    // Process queued commands
    _processQueue();

    // Fetch chat history
    fetchChatBox();
  }

  /// Handle fetch chat box response
  void _onFetchChatBox(Map<String, dynamic> data) {
    final String roomName = data['roomName'] as String? ?? '';
    if (roomName != SbConfig.chatRoom) return;

    final List<dynamic> messages = data['messages'] as List<dynamic>? ?? [];
    final List<ChatMessageData> chatMessages = [];

    for (final msg in messages) {
      if (msg is! Map<String, dynamic>) continue;

      final String? fromUser = msg['fromUser'] as String?;
      final String? messageJson = msg['message'] as String?;
      final int top = msg['top'] as int? ?? 0;
      final String? type = msg['t'] as String?;

      // Skip TIP messages or invalid messages
      if (messageJson == null || type == 'TIP') continue;

      final chatMessage = ChatMessageData.fromServerMessage(
        fromUser: fromUser,
        messageJson: messageJson,
        top: top,
        type: type,
      );
      chatMessages.add(chatMessage);
    }

    _historyController.add(chatMessages);
    // _logger.i('$name: Received ${chatMessages.length} history messages');
  }

  /// Handle received chat message
  void _onReceivedChat(Map<String, dynamic> data) {
    final String roomName = data['roomName'] as String? ?? '';
    if (roomName != SbConfig.chatRoom) return;

    final String? fromUser = data['fromUser'] as String?;
    final String? messageJson = data['message'] as String?;
    final int top = data['top'] as int? ?? 0;
    final String? type = data['t'] as String?;

    if (messageJson == null) return;

    final chatMessage = ChatMessageData.fromServerMessage(
      fromUser: fromUser,
      messageJson: messageJson,
      top: top,
      type: type,
    );

    _messageController.add(chatMessage);
    // _logger.d('$name: New message from $fromUser');
  }

  /// Handle chat error
  void _onChatError(String errorMessage) {
    _logger.e('$name: Chat error: $errorMessage');
    _errorController.add(errorMessage);

    // Kiểm tra lỗi token → trigger reconnect (sẽ refresh token)
    if (TokenErrorHandler.instance.isTokenError(errorMessage)) {
      _logger.w('$name: Token expired detected, triggering reconnect...');
      markTokenExpired(); // Prevent auto-reconnect with stale token
      kill();
      SbLogin.reconnect();
      return;
    }

    // Lỗi khác - hiển thị cho user
    _messageController.add(ChatMessageData.error(errorMessage));
  }

  /// Start ping timer (5 second interval)
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _sendPing());
  }

  /// Send ping message
  /// Format: [7, "Simms", pingId, 0]
  void _sendPing() {
    if (!isConnected) return;

    _pingId++;
    final pingMessage = jsonEncode([7, SbConfig.chatZone, _pingId, 0]);
    send(pingMessage);
    // _logger.d('$name: Ping sent: $_pingId');
  }

  /// Handle pong response
  void _onPong(int pongId) {
    // _logger.d('$name: Pong received: $pongId');
    // Connection is alive
  }

  /// Process queued commands after login
  void _processQueue() {
    if (!_isLoggedIn) return;

    for (final cmd in _commandQueue) {
      send(cmd);
    }
    _commandQueue.clear();
    // _logger.d('$name: Processed ${_commandQueue.length} queued commands');
  }
}
