import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket.dart';

/// WebSocket Connection State for Provider
class WebSocketProviderState {
  final WsConnectionState sportbookState;
  final WsConnectionState mainState;
  final WsConnectionState chatState;
  final bool isInitialized;
  final String? error;

  /// Chat messages - persisted across widget rebuilds
  final List<ChatMessageData> chatMessages;

  /// Chat login status
  final bool isChatLoggedIn;

  const WebSocketProviderState({
    this.sportbookState = WsConnectionState.disconnected,
    this.mainState = WsConnectionState.disconnected,
    this.chatState = WsConnectionState.disconnected,
    this.isInitialized = false,
    this.error,
    this.chatMessages = const [],
    this.isChatLoggedIn = false,
  });

  WebSocketProviderState copyWith({
    WsConnectionState? sportbookState,
    WsConnectionState? mainState,
    WsConnectionState? chatState,
    bool? isInitialized,
    String? error,
    List<ChatMessageData>? chatMessages,
    bool? isChatLoggedIn,
  }) => WebSocketProviderState(
    sportbookState: sportbookState ?? this.sportbookState,
    mainState: mainState ?? this.mainState,
    chatState: chatState ?? this.chatState,
    isInitialized: isInitialized ?? this.isInitialized,
    error: error,
    chatMessages: chatMessages ?? this.chatMessages,
    isChatLoggedIn: isChatLoggedIn ?? this.isChatLoggedIn,
  );

  bool get isAnyConnected =>
      sportbookState == WsConnectionState.connected ||
      mainState == WsConnectionState.connected ||
      chatState == WsConnectionState.connected;

  bool get isAllConnected =>
      sportbookState == WsConnectionState.connected &&
      mainState == WsConnectionState.connected &&
      chatState == WsConnectionState.connected;

  bool get isSportbookConnected =>
      sportbookState == WsConnectionState.connected;

  bool get isMainConnected => mainState == WsConnectionState.connected;

  bool get isChatConnected => chatState == WsConnectionState.connected;
}

/// WebSocket Notifier
class WebSocketNotifier extends StateNotifier<WebSocketProviderState> {
  final WebSocketManager _manager = WebSocketManager.instance;

  StreamSubscription<WebSocketManagerState>? _stateSubscription;
  StreamSubscription<BalanceUpdateData>? _balanceSubscription;
  StreamSubscription<OddsUpdateData>? _oddsSubscription;
  StreamSubscription<String>? _kickSubscription;
  StreamSubscription<ChatMessageData>? _chatMessageSubscription;
  StreamSubscription<List<ChatMessageData>>? _chatHistorySubscription;
  StreamSubscription<bool>? _chatLoginSubscription;

  WebSocketNotifier() : super(const WebSocketProviderState()) {
    _initialize();
  }

  /// Initialize and listen to manager state
  void _initialize() {
    _manager.initialize();

    _stateSubscription = _manager.stateStream.listen((managerState) {
      state = state.copyWith(
        sportbookState: managerState.sportbookState,
        mainState: managerState.mainState,
        chatState: managerState.chatState,
        isInitialized: true,
      );
    });

    // Listen for kick events
    _kickSubscription = _manager.main.kickStream.listen((reason) {
      state = state.copyWith(error: 'Kicked: $reason');
    });

    // Listen for chat messages and persist in state
    _chatMessageSubscription = _manager.chatMessageStream.listen((message) {
      state = state.copyWith(chatMessages: [...state.chatMessages, message]);
    });

    // Listen for chat history
    _chatHistorySubscription = _manager.chatHistoryStream.listen((history) {
      state = state.copyWith(chatMessages: history);
    });

    // Listen for chat login status
    _chatLoginSubscription = _manager.chatLoginStatusStream.listen((
      isLoggedIn,
    ) {
      state = state.copyWith(isChatLoggedIn: isLoggedIn);
    });

    // Sync current state immediately (in case websockets already connected
    // before this provider was initialized - fixes race condition where
    // SbLogin.connect() runs before websocketProvider is first accessed)
    state = state.copyWith(
      sportbookState: _manager.sportbook.state,
      mainState: _manager.main.state,
      chatState: _manager.chat.state,
      isInitialized: true,
    );
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
    state = state.copyWith(error: null);

    try {
      await _manager.connectAll(
        sportbookUrl: sportbookUrl,
        mainUrl: mainUrl,
        chatUrl: chatUrl,
        token: token,
        userId: userId,
        userName: userName,
        wsToken: wsToken,
        custLogin: custLogin,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Connect only sportbook WebSocket
  Future<void> connectSportbook(String url, {String? custLogin}) async {
    state = state.copyWith(error: null);

    try {
      await _manager.connectSportbook(url, custLogin: custLogin);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Disconnect all WebSockets
  Future<void> disconnectAll() async {
    await _manager.disconnectAll();
  }

  /// Subscribe to sport updates
  void subscribeSport(int sportId) => _manager.subscribeSport(sportId);

  /// Subscribe to event updates
  void subscribeEvent(int eventId) => _manager.subscribeEvent(eventId);

  /// Unsubscribe from event
  void unsubscribeEvent(int eventId) => _manager.unsubscribeEvent(eventId);

  /// Connect only chat WebSocket
  Future<void> connectChat() async {
    state = state.copyWith(error: null);

    try {
      await _manager.connectChat();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send chat message
  void sendChatMessage(String content) => _manager.sendChatMessage(content);

  /// Fetch chat history
  void fetchChatHistory() => _manager.fetchChatHistory();

  /// Get WebSocket manager instance
  WebSocketManager get manager => _manager;

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _balanceSubscription?.cancel();
    _oddsSubscription?.cancel();
    _kickSubscription?.cancel();
    _chatMessageSubscription?.cancel();
    _chatHistorySubscription?.cancel();
    _chatLoginSubscription?.cancel();
    super.dispose();
  }
}

/// WebSocket Provider
final websocketProvider =
    StateNotifierProvider<WebSocketNotifier, WebSocketProviderState>((ref) {
      return WebSocketNotifier();
    });

/// Derived providers

/// Sportbook connection state
final sportbookConnectionProvider = Provider<WsConnectionState>(
  (ref) => ref.watch(websocketProvider).sportbookState,
);

/// Main server connection state
final mainConnectionProvider = Provider<WsConnectionState>(
  (ref) => ref.watch(websocketProvider).mainState,
);

/// Chat connection state
final chatConnectionProvider = Provider<WsConnectionState>(
  (ref) => ref.watch(websocketProvider).chatState,
);

/// Is any WebSocket connected
final isAnyWsConnectedProvider = Provider<bool>(
  (ref) => ref.watch(websocketProvider).isAnyConnected,
);

/// Is all WebSockets connected
final isAllWsConnectedProvider = Provider<bool>(
  (ref) => ref.watch(websocketProvider).isAllConnected,
);

/// Odds update stream provider
final oddsStreamProvider = StreamProvider<OddsUpdateData>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.oddsStream;
});

/// Balance update stream provider (from WebSocket)
final wsBalanceStreamProvider = StreamProvider<BalanceUpdateData>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.balanceStream;
});

/// Score update stream provider
final scoreStreamProvider = StreamProvider<ScoreUpdateData>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.scoreStream;
});

/// Chat message stream provider (new messages)
final chatMessageStreamProvider = StreamProvider<ChatMessageData>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.chatMessageStream;
});

/// Chat history stream provider (initial load)
final chatHistoryStreamProvider = StreamProvider<List<ChatMessageData>>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.chatHistoryStream;
});

/// Chat login status stream provider
final chatLoginStatusProvider = StreamProvider<bool>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.chatLoginStatusStream;
});

/// Is chat logged in
final isChatLoggedInProvider = Provider<bool>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton for one-time value access
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.isChatLoggedIn;
});

/// Notification stream provider
final notificationStreamProvider = StreamProvider<String>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.notificationStream;
});

/// Chat messages from state (persisted across widget rebuilds)
final chatMessagesProvider = Provider<List<ChatMessageData>>(
  (ref) => ref.watch(websocketProvider).chatMessages,
);

/// Chat login status from state
final chatLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(websocketProvider).isChatLoggedIn,
);

/// Kick event stream provider (LOGIN_ANOTHER_DEVICE)
/// Emits when user is kicked due to logging in from another device
final kickEventStreamProvider = StreamProvider<String>((ref) {
  // ✅ FIX: Use ref.read() - notifier is singleton, stream handles updates
  final notifier = ref.read(websocketProvider.notifier);
  return notifier.manager.main.kickStream;
});

// ===== WEBSOCKET MESSAGE PROCESSOR SYNC =====

/// Sport Filter Sync Provider
///
/// Syncs the current sport ID from LeagueProvider with WebSocket message processor.
/// This ensures only messages for the currently viewed sport are processed.
///
/// Usage: Watch this provider in a widget that's always mounted (like SportScreen)
/// to keep the filter in sync.
final wsSportFilterSyncProvider = Provider<void>((ref) {
  final sportId = ref.watch(currentSportIdProvider);
  WebSocketManager.instance.sportbook.currentSportId = sportId;
});
