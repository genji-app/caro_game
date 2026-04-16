import 'dart:async';
import 'package:logger/logger.dart';
import 'package:co_caro_flame/s88/core/services/websocket/base_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/sb_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/sb_main_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/sb_chat_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/core/services/websocket/message_queue/ws_batch_update.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';

/// WebSocket Manager
///
/// Manages all WebSocket connections:
/// - SbWebSocket: Sportbook real-time (odds, balance, scores)
/// - SbMainWebSocket: Main game server (notifications, session)
/// - SbChatWebSocket: Chat functionality
///
/// Singleton pattern ensures single instance across the app.
class WebSocketManager {
  static WebSocketManager? _instance;
  static WebSocketManager get instance => _instance ??= WebSocketManager._();

  WebSocketManager._();

  final AppLogger _logger = AppLogger();

  /// Sportbook WebSocket
  final SbWebSocket sportbook = SbWebSocket();

  /// Main game server WebSocket
  final SbMainWebSocket main = SbMainWebSocket();

  /// Chat WebSocket
  final SbChatWebSocket chat = SbChatWebSocket();

  /// Connection state stream controller
  final StreamController<WebSocketManagerState> _stateController =
      StreamController<WebSocketManagerState>.broadcast();

  /// Current state
  WebSocketManagerState _state = const WebSocketManagerState();

  /// Stream subscriptions (to prevent listener leaks)
  StreamSubscription<WsConnectionState>? _sportbookStateSubscription;
  StreamSubscription<WsConnectionState>? _mainStateSubscription;
  StreamSubscription<WsConnectionState>? _chatStateSubscription;
  StreamSubscription<String>? _kickSubscription;

  /// Whether initialize() has been called
  bool _initialized = false;

  // ===== GETTERS =====

  /// Current state
  WebSocketManagerState get state => _state;

  /// State stream
  Stream<WebSocketManagerState> get stateStream => _stateController.stream;

  /// Is any WebSocket connected
  bool get isAnyConnected =>
      sportbook.isConnected || main.isConnected || chat.isConnected;

  /// Are all WebSockets connected
  bool get isAllConnected =>
      sportbook.isConnected && main.isConnected && chat.isConnected;

  // ===== PUBLIC METHODS =====

  /// Initialize manager and set up listeners
  void initialize() {
    // Prevent duplicate listeners if initialize() is called multiple times
    if (_initialized) {
      _logger.w('WebSocketManager: Already initialized, skipping...');
      return;
    }
    _initialized = true;

    _logger.i('WebSocketManager: Initializing...');

    // Listen to sportbook state changes
    _sportbookStateSubscription = sportbook.stateStream.listen((state) {
      _updateState(sportbookState: state);
    });

    // Listen to main state changes
    _mainStateSubscription = main.stateStream.listen((state) {
      _updateState(mainState: state);
    });

    // Listen to chat state changes
    _chatStateSubscription = chat.stateStream.listen((state) {
      _updateState(chatState: state);
    });

    // Listen for kick events from main server
    _kickSubscription = main.kickStream.listen((reason) {
      _logger.w('WebSocketManager: Kicked from server: $reason');
      disconnectAll();
    });
  }

  /// Connect all WebSockets
  Future<void> connectAll({
    required String sportbookUrl,
    required String mainUrl,
    required String chatUrl,
    required String token,
    required String userId,
    required String userName,
    required String wsToken,
    String? custLogin,
  }) async {
    _logger.i('WebSocketManager: Connecting all WebSockets...');

    // Connect in parallel
    await Future.wait([
      _connectSportbook(sportbookUrl, custLogin),
      _connectMain(mainUrl, token, userId),
      _connectChat(chatUrl, token, wsToken, userName),
    ]);
  }

  /// Connect only sportbook WebSocket
  Future<bool> connectSportbook(String url, {String? custLogin}) async {
    return _connectSportbook(url, custLogin);
  }

  /// Connect only main WebSocket
  ///
  /// After connection, you need to call sendMainLogin() to authenticate
  Future<bool> connectMain(String url, String token, String userId) async {
    return _connectMain(url, token, userId);
  }

  /// Send login to Main WebSocket
  ///
  /// Call this after connectMain() succeeds
  void sendMainLogin({
    String? username,
    String? password,
    required String? info,
    required String? signature,
  }) {
    main.sendLogin(
      username: username,
      password: password,
      info: info,
      signature: signature,
    );
  }

  /// Connect only chat WebSocket
  ///
  /// Uses SbConfig and SbHttpManager to get the required tokens
  /// Returns false if tokens are not available (user not authenticated)
  Future<bool> connectChat() async {
    final config = SbConfig.instance;
    final http = SbHttpManager.instance;

    final chatWsUrl = config.chatWs;
    if (chatWsUrl.isEmpty || !chatWsUrl.startsWith('ws')) {
      _logger.e(
        'WebSocketManager: Chat WebSocket URL is invalid: "$chatWsUrl". '
        'Make sure SbLogin.connect() has been called first.',
      );
      return false;
    }

    // accessToken should be main userToken, not sportbook token
    if (http.userToken.isEmpty) {
      _logger.e(
        'WebSocketManager: userToken is empty. '
        'Make sure SbLogin.connect() has been called first.',
      );
      return false;
    }

    if (config.wsToken.isEmpty) {
      _logger.e(
        'WebSocketManager: wsToken is empty. '
        'Make sure SbLogin.connect() has been called first.',
      );
      return false;
    }

    // _logger.i('WebSocketManager: Connecting chat to $chatWsUrl');

    return _connectChat(
      chatWsUrl,
      http.userToken, // Use main access token, not sportbook token
      config.wsToken,
      http.displayName,
    );
  }

  /// Disconnect all WebSockets
  Future<void> disconnectAll() async {
    _logger.i('WebSocketManager: Disconnecting all WebSockets...');

    await Future.wait([
      sportbook.disconnect(),
      main.disconnect(),
      chat.disconnect(),
    ]);
  }

  /// Kill all connections immediately
  void killAll() {
    _logger.i('WebSocketManager: Killing all WebSockets...');
    sportbook.kill();
    main.kill();
    chat.kill();
  }

  /// Dispose all resources
  void dispose() {
    _logger.i('WebSocketManager: Disposing...');

    // Cancel all stream subscriptions to prevent listener leaks
    _sportbookStateSubscription?.cancel();
    _mainStateSubscription?.cancel();
    _chatStateSubscription?.cancel();
    _kickSubscription?.cancel();

    sportbook.dispose();
    main.dispose();
    chat.dispose();
    _stateController.close();

    // Reset state for potential re-initialization
    _initialized = false;
    _instance = null;
  }

  // ===== CONVENIENCE METHODS =====

  /// Subscribe to sport updates (delegates to sportbook)
  void subscribeSport(int sportId) => sportbook.subscribeSport(sportId);

  /// Subscribe to event updates (delegates to sportbook)
  void subscribeEvent(int eventId) => sportbook.subscribeEvent(eventId);

  /// Unsubscribe from event (delegates to sportbook)
  void unsubscribeEvent(int eventId) => sportbook.unsubscribeEvent(eventId);

  /// Get odds update stream
  Stream<OddsUpdateData> get oddsStream => sportbook.oddsStream;

  /// Get odds remove stream
  Stream<OddsRemoveData> get oddsRemoveStream => sportbook.oddsRemoveStream;

  /// Get odds full list stream (FULL LIST behavior)
  Stream<OddsFullListData> get oddsFullListStream =>
      sportbook.oddsFullListStream;

  /// Get balance update stream (from sportbook)
  Stream<BalanceUpdateData> get balanceStream => sportbook.balanceStream;

  /// Get score update stream
  Stream<ScoreUpdateData> get scoreStream => sportbook.scoreStream;

  /// Get event insert stream (event_ins) - new events added
  Stream<EventInsertData> get eventInsertStream => sportbook.eventInsertStream;

  /// Get event remove stream (event_rm) - events removed/finished
  Stream<EventRemoveData> get eventRemoveStream => sportbook.eventRemoveStream;

  /// Get league insert stream (league_ins) - new leagues added
  Stream<LeagueInsertData> get leagueInsertStream =>
      sportbook.leagueInsertStream;

  /// Get market status stream (market_up) - market suspended/active changes
  Stream<MarketStatusData> get marketStatusStream =>
      sportbook.marketStatusStream;

  /// Get batch update stream (optimized - all state changes per tick combined)
  Stream<WsBatchUpdate> get batchUpdateStream => sportbook.batchUpdateStream;

  /// Get notification stream (from main server)
  Stream<String> get notificationStream => main.notificationStream;

  /// Send chat message
  void sendChatMessage(String content) => chat.sendChatMessage(content);

  /// Fetch chat history
  void fetchChatHistory() => chat.fetchChatBox();

  /// Get chat message stream (new messages)
  Stream<ChatMessageData> get chatMessageStream => chat.chatMessageStream;

  /// Get chat history stream (initial load)
  Stream<List<ChatMessageData>> get chatHistoryStream => chat.historyStream;

  /// Get chat login status stream
  Stream<bool> get chatLoginStatusStream => chat.loginStatusStream;

  /// Is chat logged in
  bool get isChatLoggedIn => chat.isLoggedIn;

  // ===== PRIVATE METHODS =====

  Future<bool> _connectSportbook(String url, String? custLogin) async {
    if (custLogin != null) {
      return sportbook.connectWithAuth(url, custLogin);
    }
    return sportbook.connect(url);
  }

  Future<bool> _connectMain(String url, String token, String userId) async {
    return main.connectWithAuth(url, token, userId);
  }

  Future<bool> _connectChat(
    String url,
    String accessToken,
    String wsToken,
    String userName,
  ) async {
    return chat.connectWithAuth(url, accessToken, wsToken, userName);
  }

  void _updateState({
    WsConnectionState? sportbookState,
    WsConnectionState? mainState,
    WsConnectionState? chatState,
  }) {
    _state = _state.copyWith(
      sportbookState: sportbookState,
      mainState: mainState,
      chatState: chatState,
    );
    _stateController.add(_state);
  }
}

/// WebSocket Manager State
class WebSocketManagerState {
  final WsConnectionState sportbookState;
  final WsConnectionState mainState;
  final WsConnectionState chatState;

  const WebSocketManagerState({
    this.sportbookState = WsConnectionState.disconnected,
    this.mainState = WsConnectionState.disconnected,
    this.chatState = WsConnectionState.disconnected,
  });

  WebSocketManagerState copyWith({
    WsConnectionState? sportbookState,
    WsConnectionState? mainState,
    WsConnectionState? chatState,
  }) => WebSocketManagerState(
    sportbookState: sportbookState ?? this.sportbookState,
    mainState: mainState ?? this.mainState,
    chatState: chatState ?? this.chatState,
  );

  bool get isAnyConnected =>
      sportbookState == WsConnectionState.connected ||
      mainState == WsConnectionState.connected ||
      chatState == WsConnectionState.connected;

  bool get isAllConnected =>
      sportbookState == WsConnectionState.connected &&
      mainState == WsConnectionState.connected &&
      chatState == WsConnectionState.connected;

  bool get isAnyReconnecting =>
      sportbookState == WsConnectionState.reconnecting ||
      mainState == WsConnectionState.reconnecting ||
      chatState == WsConnectionState.reconnecting;

  bool get hasError =>
      sportbookState == WsConnectionState.error ||
      mainState == WsConnectionState.error ||
      chatState == WsConnectionState.error;
}
