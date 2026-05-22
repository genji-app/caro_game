import 'dart:async';
import 'dart:typed_data';

import 'socket_config.dart';
import 'connection_handler.dart';
import 'reconciliation_service.dart';
import '../api/i_sport_api_service.dart';
import '../api/auto_refresh_manager.dart';
import '../processor/message_processor.dart';
import '../processor/light_batch_processor.dart';
import '../processor/payload_router.dart';
import '../parser/proto_parser.dart';
import '../data/sport_data_store.dart';
import '../data/data_updater.dart';
import '../data/models/league_data.dart';
import '../data/models/score_update_data.dart';
import '../data/models/event_status_data.dart';
import '../data/models/balance_update_data.dart';
import '../data/models/market_status_data.dart';
import '../data/models/odds_change_data.dart';
import '../data/models/odds_update_data.dart';
import '../events/connection_state.dart';
import '../events/data_change_event.dart';
import '../events/processor_metrics.dart';
import '../utils/logger.dart';

/// Main entry point for the Sport Socket library.
///
/// Usage:
/// ```dart
/// final client = SportSocketClient(
///   config: SocketConfig.liveMode(url: 'wss://api.example.com/ws'),
/// );
///
/// // Listen to data changes
/// client.onDataChanged.listen((event) {
///   print('Updated events: ${event.updatedEventIds}');
/// });
///
/// // Connect
/// await client.connect();
///
/// // Subscribe to sport
/// client.subscribeSport(1); // Soccer
///
/// // Access data
/// final leagues = client.dataStore.getLeaguesBySport(1);
/// ```
class SportSocketClient {
  final SocketConfig _config;
  final Logger _logger;

  /// Connection handler
  late final ConnectionHandler _connectionHandler;

  /// Message processor (V1)
  late final MessageProcessor _messageProcessor;

  /// Data store
  late final SportDataStore _dataStore;

  /// Data updater (V1)
  late final DataUpdater _dataUpdater;

  /// Reconciliation service
  late final ReconciliationService _reconciliationService;

  // ===== V2 Protocol Components =====

  /// Proto parser (V2) - parses binary Protobuf messages
  ProtoParser? _protoParser;

  /// Light batch processor (V2) - batches payloads for efficient processing
  LightBatchProcessor? _batchProcessor;

  /// Payload router (V2) - routes payloads to appropriate handlers
  PayloadRouter? _payloadRouter;

  /// Subscription for V2 binary messages
  StreamSubscription<Uint8List>? _binaryMessageSubscription;

  /// Subscription for V2 reconnect events
  StreamSubscription<void>? _v2ReconnectedSubscription;

  /// API service (injected via initialize)
  ISportApiService? _apiService;

  /// Auto refresh manager
  AutoRefreshManager? _autoRefreshManager;

  /// Current sport ID (also used as primary sport for message routing)
  int _currentSportId = 1;

  /// Primary sport ID for message routing (messages from other sports are skipped)
  /// This is separate from _currentSportId to support multi-sport subscriptions
  int _primarySportId = 1;

  /// Whether we were connected before (for reconnection detection)
  bool _wasConnectedBefore = false;

  /// Subscription for connection messages
  StreamSubscription<String>? _messageSubscription;

  /// Subscription for connection state changes
  StreamSubscription<ConnectionStateEvent>? _connectionStateSubscription;

  /// Whether client has been disposed
  bool _disposed = false;

  // ===== Stream controllers for real-time updates =====

  /// Stream controller for score updates
  final StreamController<ScoreUpdateData> _scoreController =
      StreamController<ScoreUpdateData>.broadcast();

  /// Stream controller for event status updates
  final StreamController<EventStatusData> _eventStatusController =
      StreamController<EventStatusData>.broadcast();

  /// Stream controller for balance updates
  final StreamController<BalanceUpdateData> _balanceController =
      StreamController<BalanceUpdateData>.broadcast();

  /// Stream controller for market status changes
  final StreamController<MarketStatusData> _marketStatusController =
      StreamController<MarketStatusData>.broadcast();

  /// Stream controller for odds changes
  final StreamController<OddsChangeData> _oddsChangeController =
      StreamController<OddsChangeData>.broadcast();

  /// Stream controller for ALL odds updates (regardless of direction)
  final StreamController<OddsUpdateData> _oddsUpdateController =
      StreamController<OddsUpdateData>.broadcast();

  SportSocketClient({
    required SocketConfig config,
  })  : _config = config,
        _logger = config.logger {
    _dataStore = SportDataStore();

    _messageProcessor = MessageProcessor(
      sampleInterval: config.sampleInterval,
      maxParsePerSample: config.maxParsePerSample,
      maxPendingQueueSize: config.maxPendingQueueSize,
      pendingExpiration: config.pendingExpiration,
      logger: config.logger,
    );

    _dataUpdater = DataUpdater(
      store: _dataStore,
      pendingQueue: _messageProcessor.pendingQueue,
      logger: config.logger,
      onScoreUpdate: (data) => _scoreController.add(data),
      onEventStatusUpdate: (data) => _eventStatusController.add(data),
      onBalanceUpdate: (data) => _balanceController.add(data),
      onMarketStatusChange: (data) => _marketStatusController.add(data),
      onOddsChange: (data) => _oddsChangeController.add(data),
      onOddsUpdate: (data) => _oddsUpdateController.add(data),
    );

    _connectionHandler = ConnectionHandler(config: config);

    _reconciliationService = ReconciliationService(
      store: _dataStore,
      logger: config.logger,
    );

    // Wire up message processor to data updater (V1)
    _messageProcessor.onBatchProcessed = (messages) {
      _dataUpdater.applyBatch(messages);
    };

    // Initialize V2 components if enabled
    if (config.useV2Protocol) {
      _initializeV2Components();
    }
  }

  /// Initialize V2 protocol components
  void _initializeV2Components() {
    _logger.info('[SportSocket] 🆕 Initializing V2 Protocol components...');

    // Proto parser for binary messages
    _protoParser = ProtoParser();

    // Light batch processor (50ms default for fast UI updates)
    _batchProcessor = LightBatchProcessor(
      batchInterval: _config.v2BatchInterval,
      maxBatchSize: _config.v2MaxBatchSize,
    );

    // Payload router
    _payloadRouter = PayloadRouter(logger: _logger);

    // Wire up V2 pipeline: Batch → Route → Store
    _batchProcessor!.onBatch = (payloads) {
      _payloadRouter!.routeBatch(payloads, _dataStore);
    };

    // Setup score callback from PayloadRouter
    // Note: ScoreResponse is a union type with sport-specific scores
    _payloadRouter!.onScoreUpdate = (eventId, sportId, score) {
      // Extract scores from sport-specific response
      int homeScore = 0;
      int awayScore = 0;

      if (score.hasSoccer()) {
        homeScore = score.soccer.homeScore;
        awayScore = score.soccer.awayScore;
      } else if (score.hasBasketball()) {
        // Basketball uses FT (Full Time) scores
        homeScore = score.basketball.homeScoreFT;
        awayScore = score.basketball.awayScoreFT;
      }
      // Add more sports as needed in Phase 5

      _scoreController.add(ScoreUpdateData(
        eventId: eventId,
        sportId: sportId,
        homeScore: homeScore,
        awayScore: awayScore,
        timestamp: DateTime.now(),
      ));
    };

    // Setup event status callback from PayloadRouter
    // Map ALL fields from EventResponse to EventStatusData for V2
    _payloadRouter!.onEventStatusUpdate = (eventId, event) {
      // Extract scores from sport-specific liveScore
      int? homeScore;
      int? awayScore;
      int? cornersHome;
      int? cornersAway;
      int? yellowCardsHome;
      int? yellowCardsAway;
      int? redCardsHome;
      int? redCardsAway;

      if (event.hasLiveScore()) {
        final score = event.liveScore;
        if (score.hasSoccer()) {
          homeScore = score.soccer.homeScore;
          awayScore = score.soccer.awayScore;
          cornersHome = score.soccer.homeCorner;
          cornersAway = score.soccer.awayCorner;
          yellowCardsHome = score.soccer.yellowCardsHome;
          yellowCardsAway = score.soccer.yellowCardsAway;
          redCardsHome = score.soccer.redCardsHome;
          redCardsAway = score.soccer.redCardsAway;
        } else if (score.hasBasketball()) {
          homeScore = score.basketball.homeScoreFT;
          awayScore = score.basketball.awayScoreFT;
        } else if (score.hasTennis()) {
          homeScore = score.tennis.homeSetScore;
          awayScore = score.tennis.awaySetScore;
        } else if (score.hasVolleyball()) {
          homeScore = score.volleyball.homeSetScore;
          awayScore = score.volleyball.awaySetScore;
        }
      }

      _eventStatusController.add(EventStatusData(
        eventId: eventId,
        sportId: event.sportId,
        isLive: event.isLive,
        isSuspended: event.isSuspended,
        gameTime: event.gameTime,
        gamePart: event.gamePart,
        stoppageTime: event.stoppageTime,
        homeScore: homeScore,
        awayScore: awayScore,
        cornersHome: cornersHome,
        cornersAway: cornersAway,
        yellowCardsHome: yellowCardsHome,
        yellowCardsAway: yellowCardsAway,
        redCardsHome: redCardsHome,
        redCardsAway: redCardsAway,
        timestamp: DateTime.now(),
      ));
    };

    // Setup odds change callback from PayloadRouter
    // Emit to stream for UI animation indicators (up/down arrows)
    _payloadRouter!.onOddsChange = (data) {
      _oddsChangeController.add(data);
    };

    _logger.info('[SportSocket] ✅ V2 Protocol components initialized');
  }

  // ===== Connection =====

  /// Connect to WebSocket server
  Future<void> connect() async {
    _ensureNotDisposed();

    _logger.info('SportSocketClient connecting...');

    if (_config.useV2Protocol) {
      // V2: Start batch processor and wire up binary message pipeline
      _batchProcessor?.start();

      // Listen to binary messages → parse → batch
      _binaryMessageSubscription =
          _connectionHandler.onBinaryMessage.listen((bytes) {
        final payload = _protoParser?.parse(bytes);
        if (payload != null) {
          _batchProcessor?.add(payload);
        }
      });

      // Listen for reconnect events to resubscribe channels
      _v2ReconnectedSubscription = _connectionHandler.onReconnected.listen((_) {
        _logger.info(
            '[SportSocket] 🔄 V2 Reconnected - channels will be resubscribed by SubscriptionManager');
      });

      _logger.info(
          '[SportSocket] V2 Protocol: Binary message pipeline configured');
    } else {
      // V1: Start message processor and wire up text message pipeline
      _messageProcessor.start();

      // Subscribe to incoming text messages
      _messageSubscription = _connectionHandler.onMessage.listen((raw) {
        _messageProcessor.onMessage(raw);
      });
    }

    // Connect
    await _connectionHandler.connect();
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _ensureNotDisposed();

    _logger.info('[SportSocket] 🔌 DISCONNECTING...');

    // Stop auto refresh manager first (before closing anything)
    if (_autoRefreshManager != null) {
      _logger.info('[SportSocket] Stopping AutoRefreshManager...');
      _autoRefreshManager!.stop();
    }

    if (_config.useV2Protocol) {
      // V2: Stop batch processor and cancel subscriptions
      _batchProcessor?.stop();
      await _binaryMessageSubscription?.cancel();
      _binaryMessageSubscription = null;
      await _v2ReconnectedSubscription?.cancel();
      _v2ReconnectedSubscription = null;
    } else {
      // V1: Stop message processor
      _messageProcessor.stop();
    }

    // Cancel message subscription (V1)
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // Disconnect
    await _connectionHandler.disconnect();

    _logger.info('[SportSocket] ✅ DISCONNECTED');
  }

  /// Whether currently connected
  bool get isConnected => _connectionHandler.isConnected;

  /// Current connection state
  ConnectionState get connectionState => _connectionHandler.state;

  // ===== Subscriptions =====

  /// Subscribe to a sport
  void subscribeSport(int sportId) {
    _ensureNotDisposed();
    _messageProcessor.subscribeSport(sportId);
    _logger.info('Subscribed to sport: $sportId');

    // Send subscribe message to server if connected
    if (isConnected) {
      _sendSubscribe(sportId);
    }
  }

  /// Unsubscribe from a sport
  void unsubscribeSport(int sportId) {
    _ensureNotDisposed();
    _messageProcessor.unsubscribeSport(sportId);
    _logger.info('Unsubscribed from sport: $sportId');

    // Send unsubscribe message to server if connected
    if (isConnected) {
      _sendUnsubscribe(sportId);
    }

    // Optionally clear data for this sport
    _dataStore.clearSport(sportId);
  }

  /// Get subscribed sports
  Set<int> get subscribedSports => _messageProcessor.subscribedSports;

  // ===== Primary Sport (for message routing) =====

  /// Set primary sport for message routing.
  /// Only messages from primary sport will be processed to DataStore.
  /// Other subscribed sports' messages are received but skipped (Phase 1).
  void setPrimarySport(int sportId) {
    _ensureNotDisposed();
    _primarySportId = sportId;
    _messageProcessor.setPrimarySport(sportId);

    // Also update current sport for API refresh (reconnection uses this)
    // This ensures that when user switches sport via LeagueProvider, the
    // AutoRefreshManager will also use the correct sportId on reconnect.
    _currentSportId = sportId;
    _autoRefreshManager?.updateSportId(sportId);

    _logger.info(
        '[SportSocket] 🎯 PRIMARY SPORT set to: $sportId (currentSportId synced)');

    // Ensure subscribed to primary sport
    if (!_messageProcessor.subscribedSports.contains(sportId)) {
      subscribeSport(sportId);
    }
  }

  /// Get current primary sport ID
  int get primarySportId => _primarySportId;

  /// Check if a sport is the primary sport
  bool isPrimarySport(int sportId) => sportId == _primarySportId;

  void _sendSubscribe(int sportId) {
    // Format: SUB:s:{sportId} (e.g., SUB:s:1)
    final message = 'SUB:s:$sportId';
    _logger.info('[SportSocket] 📤 SEND SUBSCRIBE: $message');
    _connectionHandler.send(message);
  }

  void _sendUnsubscribe(int sportId) {
    // Format: UNSUB:s:{sportId} (e.g., UNSUB:s:1)
    final message = 'UNSUB:s:$sportId';
    _logger.info('[SportSocket] 📤 SEND UNSUBSCRIBE: $message');
    _connectionHandler.send(message);
  }

  // ===== V2 Raw Send =====

  /// Send a raw message to the WebSocket server.
  ///
  /// Send raw message through WebSocket.
  ///
  /// For V1: Accepts String (sent as TEXT frame)
  /// For V2: Accepts Uint8List (sent as BINARY frame)
  ///
  /// Example:
  /// ```dart
  /// // V2: Subscribe to a channel (binary)
  /// final bytes = V2SubscriptionHelper.subscribeMessage('ln:vi:s:1:l');
  /// client.sendRaw(bytes);
  /// ```
  void sendRaw(dynamic message) {
    _ensureNotDisposed();
    if (isConnected) {
      final size =
          message is List ? message.length : (message as String).length;
      _logger.debug(
          '[SportSocket] 📤 SEND RAW: $size ${message is List ? 'bytes' : 'chars'}');
      _connectionHandler.send(message);
    } else {
      _logger.warning('[SportSocket] ⚠️ Cannot send - not connected');
    }
  }

  // ===== Data Access =====

  /// Read-only access to data store
  SportDataStore get dataStore => _dataStore;

  // ===== Streams =====

  /// Stream of data change events
  Stream<DataChangeEvent> get onDataChanged => _dataStore.onChanged;

  /// Stream of connection state changes
  Stream<ConnectionStateEvent> get onConnectionChanged =>
      _connectionHandler.onStateChanged;

  /// Stream of processor metrics
  Stream<ProcessorMetrics> get onMetrics => _messageProcessor.metricsStream;

  /// Stream of score updates (from score_up and event_up messages)
  Stream<ScoreUpdateData> get onScoreUpdate => _scoreController.stream;

  /// Stream of event status updates (from event_up messages)
  Stream<EventStatusData> get onEventStatusUpdate =>
      _eventStatusController.stream;

  /// Stream of balance updates (from balance_up and user_bal messages)
  Stream<BalanceUpdateData> get onBalanceUpdate => _balanceController.stream;

  /// Stream of market status changes (from market_up messages)
  Stream<MarketStatusData> get onMarketStatusChange =>
      _marketStatusController.stream;

  /// Stream of odds changes (from odds_up messages)
  Stream<OddsChangeData> get onOddsChange => _oddsChangeController.stream;

  /// Stream of ALL odds updates (for UI updates regardless of direction)
  Stream<OddsUpdateData> get onOddsUpdate => _oddsUpdateController.stream;

  // ===== Balance Request =====

  /// Request balance update from server
  void requestBalance(String custLogin) {
    _ensureNotDisposed();
    if (isConnected) {
      _connectionHandler.send('userbal:$custLogin');
      _logger.info('[SportSocket] 💰 Requested balance for: $custLogin');
    }
  }

  // ===== API Integration =====

  /// Initialize client with API service for single sport.
  ///
  /// This method:
  /// 1. Connects to WebSocket (to not miss real-time updates)
  /// 2. Fetches initial data from API (parallel Early + Live)
  /// 3. Subscribes to sport on WebSocket
  /// 4. Starts auto refresh manager
  ///
  /// [apiService] - Implementation of ISportApiService
  /// [sportId] - Sport ID to initialize (default: 1 = Soccer)
  /// [fetchHot] - Whether to also fetch hot leagues
  Future<void> initialize({
    required ISportApiService apiService,
    int sportId = 1,
    bool fetchHot = false,
  }) async {
    _ensureNotDisposed();

    _apiService = apiService;
    _currentSportId = sportId;

    _logger.info(
        '[SportSocket] 🚀 INITIALIZING - sportId: $sportId, fetchHot: $fetchHot');

    // 1. Connect WebSocket first (to not miss updates)
    _logger.info('[SportSocket] Step 1/5: Connecting WebSocket...');
    await connect();
    await _waitForConnection();
    _logger.info('[SportSocket] Step 1/5: ✅ WebSocket connected');

    // 2. Fetch initial data from API (parallel)
    _logger.info(
        '[SportSocket] Step 2/5: Fetching initial API data (🚀 INITIAL)...');
    await _fetchInitialData(sportId: sportId, fetchHot: fetchHot);
    _logger.info('[SportSocket] Step 2/5: ✅ Initial API data loaded');

    // 3. Subscribe to sport on WebSocket
    _logger.info(
        '[SportSocket] Step 3/5: Subscribing to sport $sportId on WebSocket...');
    subscribeSport(sportId);
    _logger.info('[SportSocket] Step 3/5: ✅ Subscribed to sport $sportId');

    // 4. Start auto refresh if enabled
    if (_config.autoRefreshConfig.enabled) {
      _logger.info('[SportSocket] Step 4/5: Starting AutoRefreshManager...');
      _startAutoRefresh();
      _logger.info(
          '[SportSocket] Step 4/5: ✅ AutoRefreshManager started (interval: ${_config.autoRefreshConfig.refreshInterval.inSeconds}s)');
    } else {
      _logger.info('[SportSocket] Step 4/5: ⏭️ AutoRefresh disabled');
    }

    // 5. Setup monitors
    _logger.info('[SportSocket] Step 5/5: Setting up monitors...');
    _setupPendingQueueMonitor();
    _setupReconnectionListener();
    _logger.info('[SportSocket] Step 5/5: ✅ Monitors setup complete');

    _logger.info('[SportSocket] ✅ INITIALIZATION COMPLETE - sportId: $sportId');
  }

  /// Change to a different sport.
  ///
  /// This will:
  /// 1. Unsubscribe from current sport
  /// 2. Clear current sport data
  /// 3. Fetch new sport data from API
  /// 4. Subscribe to new sport on WebSocket
  Future<void> changeSport(int sportId) async {
    _ensureNotDisposed();

    if (_currentSportId == sportId) {
      _logger.debug(
          '[SportSocket] Already on sport $sportId, skipping changeSport');
      return;
    }

    if (_apiService == null) {
      throw StateError('Client not initialized. Call initialize() first.');
    }

    final oldSportId = _currentSportId;
    _logger.info(
        '[SportSocket] 🔄 CHANGE SPORT - from: $oldSportId → to: $sportId');

    // 1. Unsubscribe from current sport
    _logger.info(
        '[SportSocket] Step 1/4: Unsubscribing from sport $oldSportId...');
    unsubscribeSport(oldSportId);

    // 2. Clear current sport data
    _logger
        .info('[SportSocket] Step 2/4: Clearing data for sport $oldSportId...');
    _dataStore.clearSport(oldSportId);

    // 3. Update current sport ID
    _currentSportId = sportId;

    // 4. Update auto refresh manager
    _autoRefreshManager?.updateSportId(sportId);

    // 5. Fetch new sport data
    _logger.info(
        '[SportSocket] Step 3/4: Fetching API data for sport $sportId (🚀 CHANGE_SPORT)...');
    await _fetchInitialData(sportId: sportId);

    // 6. Subscribe to new sport
    _logger.info('[SportSocket] Step 4/4: Subscribing to sport $sportId...');
    subscribeSport(sportId);

    _logger
        .info('[SportSocket] ✅ CHANGE SPORT COMPLETE - now on sport $sportId');
  }

  /// Current sport ID
  int get currentSportId => _currentSportId;

  /// Auto refresh manager (for external access)
  AutoRefreshManager? get autoRefreshManager => _autoRefreshManager;

  /// Update current time range for auto refresh.
  ///
  /// This changes which API endpoint the auto-refresh timer will call:
  /// - LIVE: fetchLiveAndPopulate (30s interval)
  /// - TODAY: fetchTodayAndPopulate (60s interval)
  /// - EARLY: fetchEarlyAndPopulate (120s interval)
  ///
  /// Call this when user switches tabs.
  void updateTimeRange(String timeRange) {
    _logger.info('[SportSocketClient] updateTimeRange: $timeRange');
    _autoRefreshManager?.updateTimeRange(timeRange);
  }

  /// Get current time range
  String get currentTimeRange =>
      _autoRefreshManager?.currentTimeRange ?? 'LIVE';

  /// Wait for WebSocket connection to be established
  Future<void> _waitForConnection(
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (isConnected) return;

    final completer = Completer<void>();
    StreamSubscription<ConnectionStateEvent>? subscription;

    final timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Connection timeout after ${timeout.inSeconds}s'),
        );
      }
    });

    subscription = onConnectionChanged.listen((event) {
      if (event.currentState == ConnectionState.connected) {
        timer.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      } else if (event.currentState == ConnectionState.error) {
        timer.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('Connection failed: ${event.errorMessage}'),
          );
        }
      }
    });

    return completer.future;
  }

  /// Fetch initial data from API
  ///
  /// Uses fetchLiveAndPopulate() pattern to ensure full hierarchy is loaded:
  /// League → Events → Markets → Odds
  ///
  /// Previously used fetchLiveLeagues() + fullSync() which only synced league
  /// metadata without nested events - causing 0 events on initial load.
  Future<void> _fetchInitialData({
    required int sportId,
    bool fetchHot = false,
  }) async {
    if (_apiService == null) return;

    final stopwatch = Stopwatch()..start();
    _logger
        .info('[SportSocket] 📡 Fetching initial data with FULL HIERARCHY...');

    try {
      // Use fetchLiveAndPopulate which processes full hierarchy from raw JSON
      // This ensures events/markets/odds are properly populated
      await _apiService!.fetchLiveAndPopulate(
        sportId: sportId,
        store: _dataStore,
      );

      // Emit changes to notify listeners
      _dataStore.emitBatchChanges();

      stopwatch.stop();

      // Log stats
      final leagues = _dataStore.getLeaguesBySport(sportId);
      int totalEvents = 0;
      for (final league in leagues) {
        totalEvents += _dataStore.getEventsByLeague(league.leagueId).length;
      }

      _logger.info(
        '[SportSocket] ✅ INITIAL DATA LOADED\n'
        '   └─ leagues: ${leagues.length}\n'
        '   └─ events: $totalEvents\n'
        '   └─ duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      stopwatch.stop();
      _logger.error(
          '[SportSocket] ❌ FETCH FAILED after ${stopwatch.elapsedMilliseconds}ms: $e');
      _logger.debug('Stack trace: $stack');
      rethrow;
    }
  }

  /// Start auto refresh manager
  void _startAutoRefresh() {
    if (_apiService == null) return;

    final config = _config.autoRefreshConfig;

    _logger.info('');
    _logger
        .info('╔═══════════════════════════════════════════════════════════');
    _logger.info('║ 🔃 AUTO REFRESH MANAGER - Starting');
    _logger
        .info('╠═══════════════════════════════════════════════════════════');
    _logger.info('║ Config:');
    _logger.info('║    Interval: ${config.refreshInterval.inSeconds}s');
    _logger.info('║    Pending Threshold: ${config.pendingQueueThreshold}');
    _logger.info('║    Max Retries: ${config.maxRetries}');
    _logger.info('║    Min Gap: ${config.minRefreshGap.inSeconds}s');
    _logger.info('║    Sport ID: $_currentSportId');

    _autoRefreshManager = AutoRefreshManager(
      apiService: _apiService!,
      reconciliationService: _reconciliationService,
      messageProcessor: _messageProcessor,
      config: config,
      initialSportId: _currentSportId,
      logger: _logger,
    );

    _autoRefreshManager!.start();

    _logger.info('║ ✅ AutoRefreshManager started');
    _logger
        .info('╚═══════════════════════════════════════════════════════════');
  }

  /// Setup pending queue monitor to trigger refresh on threshold
  void _setupPendingQueueMonitor() {
    _messageProcessor.pendingQueue.onThresholdExceeded = (size, threshold) {
      _logger.warning(
        '[SportSocket] ⚠️ PENDING THRESHOLD EXCEEDED\n'
        '   └─ current: $size messages\n'
        '   └─ threshold: $threshold\n'
        '   └─ action: Triggering FULL refresh...',
      );
      _autoRefreshManager?.triggerRefresh(AutoRefreshTrigger.pendingThreshold);
    };
  }

  /// Setup reconnection listener to trigger full refresh
  void _setupReconnectionListener() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = onConnectionChanged.listen((event) {
      if (event.currentState == ConnectionState.connected) {
        if (_wasConnectedBefore) {
          _logger.info(
            '[SportSocket] 🔄 RECONNECTED - WebSocket connection restored\n'
            '   └─ action: Triggering FULL refresh to sync data...',
          );
          _autoRefreshManager?.triggerRefresh(AutoRefreshTrigger.reconnection);
        } else {
          _logger.info('[SportSocket] 🔌 FIRST CONNECTION established');
        }
        _wasConnectedBefore = true;
      } else if (event.currentState == ConnectionState.disconnected) {
        _logger.warning(
            '[SportSocket] 🔌 DISCONNECTED - WebSocket connection lost');
      }
    });
  }

  // ===== Reconciliation =====

  /// Reconcile store with API data
  ReconciliationResult reconcile(List<LeagueData> apiData) {
    _ensureNotDisposed();
    return _reconciliationService.reconcile(apiData);
  }

  /// Reconcile specific sport
  ReconciliationResult reconcileSport({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    _ensureNotDisposed();
    return _reconciliationService.reconcileSport(
      sportId: sportId,
      apiLeagues: apiLeagues,
    );
  }

  /// Full sync for a sport (clear and reload)
  ReconciliationResult fullSync({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    _ensureNotDisposed();
    return _reconciliationService.fullSync(
      sportId: sportId,
      apiLeagues: apiLeagues,
    );
  }

  // ===== Metrics =====

  /// Get current processor metrics
  ProcessorMetrics getMetrics() => _messageProcessor.getMetrics();

  /// Reset processor statistics
  void resetStats() => _messageProcessor.resetStats();

  // ===== Cleanup =====

  /// Dispose all resources
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    _logger.info('Disposing SportSocketClient');

    // Stop auto refresh
    _autoRefreshManager?.dispose();
    _autoRefreshManager = null;

    // Cancel subscriptions
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    await disconnect();

    // Dispose V1 components
    _messageProcessor.dispose();

    // Dispose V2 components
    _batchProcessor?.dispose();
    _protoParser = null;
    _payloadRouter = null;

    _dataStore.dispose();
    await _connectionHandler.dispose();

    // Close stream controllers
    await _scoreController.close();
    await _eventStatusController.close();
    await _balanceController.close();
    await _marketStatusController.close();
    await _oddsChangeController.close();
    await _oddsUpdateController.close();
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SportSocketClient has been disposed');
    }
  }
}
