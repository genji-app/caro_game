import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/adapters/league_adapter.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_api_service_impl.dart';
import 'package:co_caro_flame/s88/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/websocket/betslip_subscription_manager.dart';
import 'package:co_caro_flame/s88/core/services/websocket/subscription_manager.dart';
import 'package:co_caro_flame/s88/features/sport/domain/repositories/sport_repository.dart';

/// Main adapter facade for Sport Socket integration.
///
/// This adapter bridges the sport_socket library with the app's
/// Freezed models and state management layer.
///
/// Usage with API integration (recommended):
/// ```dart
/// final adapter = SportSocketAdapter.liveMode(
///   url: httpManager.urlHomeWebsocket,
/// );
///
/// // Initialize with API service - connects WebSocket + loads API data
/// await adapter.initialize(
///   repository: sportRepository,
///   sportId: 1,
/// );
///
/// // Listen to data changes
/// adapter.onLeaguesChanged.listen((leagues) {
///   // Update UI state
/// });
/// ```
///
/// Legacy usage (WebSocket only):
/// ```dart
/// final adapter = SportSocketAdapter.liveMode(url: 'wss://...');
/// await adapter.connect();
/// adapter.subscribeSport(1);
/// ```
class SportSocketAdapter {
  final socket.SportSocketClient _client;
  final StreamController<List<LeagueData>> _leaguesController =
      StreamController<List<LeagueData>>.broadcast();
  final StreamController<SportSocketUpdate> _updateController =
      StreamController<SportSocketUpdate>.broadcast();

  StreamSubscription<socket.DataChangeEvent>? _dataSubscription;
  StreamSubscription<socket.ConnectionStateEvent>? _connectionSubscription;

  /// API service for REST API calls (set during initialize)
  socket.ISportApiService? _apiService;

  /// Whether adapter has been initialized with API service
  bool _initialized = false;

  /// Subscription manager for multi-sport subscriptions (BetSlip support)
  late final SubscriptionManager _subscriptionManager;

  /// Betslip subscription manager for event-level subscriptions
  late final BetslipSubscriptionManager _betslipSubscriptionManager;

  static const _tag = '[SportSocketAdapter]';

  // ===== Cache Configuration =====

  /// Maximum number of leagues to cache
  static const int _maxLeagueCacheSize = 100;

  /// Maximum number of events to cache
  static const int _maxEventCacheSize = 500;

  // ===== Internal Caches =====

  /// Cache for converted leagues (keyed by leagueId)
  final Map<int, LeagueData> _leagueCache = {};

  /// Cache for converted events (keyed by eventId)
  final Map<int, LeagueEventData> _eventCache = {};

  /// Create adapter with socket configuration
  SportSocketAdapter({required socket.SocketConfig config})
    : _client = socket.SportSocketClient(config: config) {
    _subscriptionManager = SubscriptionManager(
      client: _client,
      useV2Protocol: config.useV2Protocol,
      language: config.v2Language,
    );
    _betslipSubscriptionManager = BetslipSubscriptionManager(
      subscriptionManager: _subscriptionManager,
      language: config.v2Language,
    );
    _setupListeners();
    _setupSubscriptionManager();
  }

  /// Create adapter for live betting
  factory SportSocketAdapter.liveMode({
    required String url,
    socket.Logger? logger,
    socket.AutoRefreshConfig? autoRefreshConfig,
    bool useV2Protocol = false,
    String v2Language = 'vi',
  }) {
    return SportSocketAdapter(
      config: socket.SocketConfig.liveMode(
        url: url,
        logger: logger,
        autoRefreshConfig: autoRefreshConfig ?? socket.AutoRefreshConfig.live(),
        useV2Protocol: useV2Protocol,
        v2Language: v2Language,
      ),
    );
  }

  /// Create adapter for pre-match betting
  factory SportSocketAdapter.preMatchMode({
    required String url,
    socket.Logger? logger,
    socket.AutoRefreshConfig? autoRefreshConfig,
    bool useV2Protocol = false,
    String v2Language = 'vi',
  }) {
    return SportSocketAdapter(
      config: socket.SocketConfig.preMatchMode(
        url: url,
        logger: logger,
        autoRefreshConfig:
            autoRefreshConfig ?? socket.AutoRefreshConfig.preMatch(),
        useV2Protocol: useV2Protocol,
        v2Language: v2Language,
      ),
    );
  }

  // ===== API Integration =====

  /// Initialize adapter with API service.
  ///
  /// This is the recommended way to use the adapter. It will:
  /// 1. Connect to WebSocket
  /// 2. Fetch initial data from REST API (parallel Early + Live)
  /// 3. Subscribe to sport on WebSocket
  /// 4. Start auto refresh manager
  ///
  /// [repository] - SportRepository for REST API calls (legacy, used for Hot/Detail)
  /// [v2DataSource] - EventsV2RemoteDataSource for V2 API calls (LIVE/TODAY/EARLY)
  /// [sportId] - Initial sport ID (default: 1 = Soccer)
  /// [fetchHot] - Whether to also fetch hot leagues
  Future<void> initialize({
    required SportRepository repository,
    required EventsV2RemoteDataSource v2DataSource,
    int sportId = 1,
    bool fetchHot = false,
  }) async {
    debugPrint('$_tag 🚀 Initializing with V2 API integration...');

    _apiService = SportApiServiceImpl(
      repository: repository,
      v2DataSource: v2DataSource,
    );

    await _client.initialize(
      apiService: _apiService!,
      sportId: sportId,
      fetchHot: fetchHot,
    );

    _initialized = true;
    debugPrint('$_tag ✅ Initialization complete - sportId: $sportId');
  }

  /// Change to a different sport.
  ///
  /// This will:
  /// 1. Update SubscriptionManager (UNSUBSCRIBE old sport, SUBSCRIBE new sport)
  /// 2. Clear current sport data and caches
  /// 3. Fetch new sport data from API
  /// 4. Subscribe to new sport on WebSocket (V1 legacy)
  Future<void> changeSport(int sportId) async {
    if (!_initialized) {
      throw StateError('Adapter not initialized. Call initialize() first.');
    }

    // 1. Update SubscriptionManager FIRST (V2 protocol: unsub old / sub new channels)
    _subscriptionManager.setActiveSport(sportId);

    // Clear caches before changing sport
    _clearCaches();

    debugPrint('$_tag 🔄 Changing sport to $sportId...');
    await _client.changeSport(sportId);
    debugPrint('$_tag ✅ Changed to sport $sportId');
  }

  /// Current sport ID
  int get currentSportId => _client.currentSportId;

  /// Whether adapter has been initialized with API service
  bool get isInitialized => _initialized;

  /// Subscription manager for multi-sport subscriptions (BetSlip support)
  SubscriptionManager get subscriptionManager => _subscriptionManager;

  /// Auto refresh manager (for external access/control)
  socket.AutoRefreshManager? get autoRefreshManager =>
      _client.autoRefreshManager;

  /// Trigger manual refresh from API
  Future<socket.AutoRefreshResult?> triggerManualRefresh() async {
    return await _client.autoRefreshManager?.triggerRefresh(
      socket.AutoRefreshTrigger.manual,
    );
  }

  /// Update time range for auto refresh timer and socket subscription.
  ///
  /// Call this when user switches tabs (LIVE/TODAY/EARLY).
  /// This will:
  /// 1. Update AutoRefreshManager timer interval (LIVE: 30s, TODAY: 60s, EARLY: 120s)
  /// 2. Update SubscriptionManager (UNSUBSCRIBE old channel, SUBSCRIBE new channel)
  void updateTimeRange(String timeRange) {
    debugPrint('$_tag updateTimeRange: $timeRange');

    // 1. Update AutoRefreshManager (timer interval)
    _client.updateTimeRange(timeRange);

    // 2. Update SubscriptionManager (unsub old / sub new channel)
    _subscriptionManager.setTimeRangeFromString(timeRange);
  }

  /// Get current time range being refreshed
  String get currentTimeRange => _client.currentTimeRange;

  // ===== Tab Switch - Populate Store =====

  /// Fetch LIVE data and populate store.
  ///
  /// Call this when switching to LIVE tab to sync Store with LIVE data.
  /// ⭐ IMPORTANT: Clears store first to prevent data from different timeRanges mixing!
  /// Store is Single Source of Truth.
  Future<void> fetchLiveAndPopulate() async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchLiveAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint(
      '$_tag 📡 fetchLiveAndPopulate - sportId: $sportId (clearing store first)',
    );

    // ⭐ FIX: Clear store before populating to prevent data mixing
    // Without this, TODAY/EARLY data would persist when switching to LIVE
    _client.dataStore.clearSport(sportId);

    await _apiService!.fetchLiveAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
    );

    // Emit changes to notify listeners
    _client.dataStore.emitBatchChanges();
  }

  /// Fetch TODAY data and populate store.
  ///
  /// Call this when switching to TODAY tab to sync Store with TODAY data.
  /// ⭐ IMPORTANT: Clears store first to prevent data from different timeRanges mixing!
  /// Store is Single Source of Truth.
  Future<void> fetchTodayAndPopulate() async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchTodayAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint(
      '$_tag 📡 fetchTodayAndPopulate - sportId: $sportId (clearing store first)',
    );

    // ⭐ FIX: Clear store before populating to prevent data mixing
    // Without this, LIVE/EARLY data would persist when switching to TODAY
    _client.dataStore.clearSport(sportId);

    await _apiService!.fetchTodayAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
    );

    // Emit changes to notify listeners
    _client.dataStore.emitBatchChanges();
  }

  /// Fetch EARLY data and populate store.
  ///
  /// Call this when switching to EARLY tab to sync Store with EARLY data.
  /// ⭐ IMPORTANT: Clears store first to prevent data from different timeRanges mixing!
  /// Store is Single Source of Truth.
  Future<void> fetchEarlyAndPopulate() async {
    if (_apiService == null) {
      debugPrint('$_tag ⚠️ fetchEarlyAndPopulate: No API service');
      return;
    }

    final sportId = _client.currentSportId;
    debugPrint(
      '$_tag 📡 fetchEarlyAndPopulate - sportId: $sportId (clearing store first)',
    );

    // ⭐ FIX: Clear store before populating to prevent data mixing
    // Without this, LIVE/TODAY data would persist when switching to EARLY
    _client.dataStore.clearSport(sportId);

    await _apiService!.fetchEarlyAndPopulate(
      sportId: sportId,
      store: _client.dataStore,
    );

    // Emit changes to notify listeners
    _client.dataStore.emitBatchChanges();
  }

  // ===== Public API =====

  /// Connect to WebSocket server
  Future<void> connect() async {
    await _client.connect();
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    await _client.disconnect();
  }

  /// Subscribe to a sport
  void subscribeSport(int sportId) {
    _client.subscribeSport(sportId);
  }

  /// Unsubscribe from a sport
  void unsubscribeSport(int sportId) {
    _client.unsubscribeSport(sportId);
  }

  /// Get subscribed sports
  Set<int> get subscribedSports => _client.subscribedSports;

  /// Whether currently connected
  bool get isConnected => _client.isConnected;

  /// Current connection state
  socket.ConnectionState get connectionState => _client.connectionState;

  // ===== Streams =====

  /// Stream of Freezed LeagueData when data changes
  Stream<List<LeagueData>> get onLeaguesChanged => _leaguesController.stream;

  /// Stream of granular update events
  Stream<SportSocketUpdate> get onUpdate => _updateController.stream;

  /// Stream of connection state changes
  Stream<socket.ConnectionStateEvent> get onConnectionChanged =>
      _client.onConnectionChanged;

  /// Stream of processor metrics
  Stream<socket.ProcessorMetrics> get onMetrics => _client.onMetrics;

  /// Stream of score updates (from score_up and event_up messages)
  Stream<socket.ScoreUpdateData> get onScoreUpdate => _client.onScoreUpdate;

  /// Stream of event status updates (from event_up messages)
  Stream<socket.EventStatusData> get onEventStatusUpdate =>
      _client.onEventStatusUpdate;

  /// Stream of balance updates (from balance_up and user_bal messages)
  Stream<socket.BalanceUpdateData> get onBalanceUpdate =>
      _client.onBalanceUpdate;

  /// Stream of market status changes (from market_up messages)
  Stream<socket.MarketStatusData> get onMarketStatusChange =>
      _client.onMarketStatusChange;

  /// Stream of odds changes (from odds_up messages)
  Stream<socket.OddsChangeData> get onOddsChange => _client.onOddsChange;

  /// Stream of ALL odds updates (for UI updates regardless of direction)
  /// Use this for updating drawers in bet detail screens
  Stream<socket.OddsUpdateData> get onOddsUpdate => _client.onOddsUpdate;

  // ===== Balance Request =====

  /// Request balance update from server
  void requestBalance(String custLogin) => _client.requestBalance(custLogin);

  // ===== Data Access =====

  /// Get all leagues for a sport as Freezed models (sorted by V2 criteria)
  ///
  /// Sorting order:
  /// 1. priorityOrder (ascending)
  /// 2. leagueOrder (ascending)
  /// 3. name (alphabetical)
  ///
  /// Events within each league are sorted by start time.
  List<LeagueData> getLeaguesBySport(int sportId) {
    final store = _client.dataStore;
    // Use sorted method for V2 compliance
    final leagues = store.getSortedLeaguesBySport(sportId);

    return leagues.map((league) {
      // Get events for this league, sorted by store's current sort mode
      final allEvents = store.getSortedEventsBySport(sportId);
      final events = allEvents
          .where((e) => e.leagueId == league.leagueId)
          .toList();

      final marketsPerEvent = <int, List<socket.MarketData>>{};
      final oddsPerMarket = <String, List<socket.OddsData>>{};

      for (final event in events) {
        final markets = store.getMarketsByEvent(event.eventId);
        marketsPerEvent[event.eventId] = markets;

        for (final market in markets) {
          final marketKey = '${event.eventId}_${market.marketId}';
          oddsPerMarket[marketKey] = store.getOddsByMarket(
            event.eventId,
            market.marketId,
          );
        }
      }

      return LeagueAdapter.toFreezedWithEvents(
        league,
        events,
        marketsPerEvent,
        oddsPerMarket,
      );
    }).toList();
  }

  /// Set the sort mode for events
  ///
  /// [mode] - SortMode.defaultMode: group by league, sort by start time
  ///          SortMode.startTimeMode: sort all events by start time
  void setSortMode(socket.SortMode mode) {
    _client.dataStore.sortMode = mode;
    // Clear event cache since sort order changed
    _eventCache.clear();
  }

  /// Get current sort mode
  socket.SortMode get sortMode => _client.dataStore.sortMode;

  /// Get a single league as Freezed model (with caching)
  LeagueData? getLeague(int leagueId) {
    // Check cache first
    final cached = _leagueCache[leagueId];
    if (cached != null) return cached;

    final store = _client.dataStore;
    final league = store.getLeague(leagueId);
    if (league == null) return null;

    // Get events sorted by start time within this league
    final allEvents = store.getEventsByLeague(leagueId);
    final events = allEvents.toList()
      ..sort(
        (a, b) => (a.startDate?.millisecondsSinceEpoch ?? 0).compareTo(
          b.startDate?.millisecondsSinceEpoch ?? 0,
        ),
      );

    final marketsPerEvent = <int, List<socket.MarketData>>{};
    final oddsPerMarket = <String, List<socket.OddsData>>{};

    for (final event in events) {
      final markets = store.getMarketsByEvent(event.eventId);
      marketsPerEvent[event.eventId] = markets;

      for (final market in markets) {
        final marketKey = '${event.eventId}_${market.marketId}';
        oddsPerMarket[marketKey] = store.getOddsByMarket(
          event.eventId,
          market.marketId,
        );
      }
    }

    final result = LeagueAdapter.toFreezedWithEvents(
      league,
      events,
      marketsPerEvent,
      oddsPerMarket,
    );

    // Store in cache before returning
    _addToLeagueCache(leagueId, result);
    return result;
  }

  /// Get raw event data from socket store.
  ///
  /// This returns the socket library's EventData which contains:
  /// - sportId (not available in LeagueEventData)
  /// - isLive flag
  /// - Other raw event data
  ///
  /// Use this when you need sportId or isLive for the event.
  socket.EventData? getEventData(int eventId) {
    return _client.dataStore.getEvent(eventId);
  }

  /// Get odds data from socket store.
  ///
  /// Returns OddsData which contains:
  /// - points (handicap/line value)
  /// - isSuspended flag
  /// - All odds values (decimal, malay, indo, hk)
  socket.OddsData? getOdds(int eventId, int marketId, String offerId) {
    return _client.dataStore.getOdds(eventId, marketId, offerId);
  }

  /// Get a single event as Freezed model (with caching)
  LeagueEventData? getEvent(int eventId) {
    // Check cache first
    final cached = _eventCache[eventId];
    if (cached != null) return cached;

    final store = _client.dataStore;
    final event = store.getEvent(eventId);
    if (event == null) return null;

    final markets = store.getMarketsByEvent(eventId);
    final oddsPerMarket = <String, List<socket.OddsData>>{};

    for (final market in markets) {
      final marketKey = '${eventId}_${market.marketId}';
      oddsPerMarket[marketKey] = store.getOddsByMarket(
        eventId,
        market.marketId,
      );
    }

    final result = EventAdapter.toFreezedWithMarkets(
      event,
      markets,
      oddsPerMarket,
    );

    // Store in cache before returning
    _addToEventCache(eventId, result);
    return result;
  }

  // ===== Reconciliation =====

  /// Reconcile with API data after reconnection
  socket.ReconciliationResult reconcile(List<socket.LeagueData> apiData) {
    return _client.reconcile(apiData);
  }

  /// Reconcile specific sport
  socket.ReconciliationResult reconcileSport({
    required int sportId,
    required List<socket.LeagueData> apiLeagues,
  }) {
    return _client.reconcileSport(sportId: sportId, apiLeagues: apiLeagues);
  }

  /// Full sync for a sport
  socket.ReconciliationResult fullSync({
    required int sportId,
    required List<socket.LeagueData> apiLeagues,
  }) {
    return _client.fullSync(sportId: sportId, apiLeagues: apiLeagues);
  }

  // ===== Metrics =====

  /// Get current processor metrics
  socket.ProcessorMetrics getMetrics() => _client.getMetrics();

  /// Reset processor statistics
  void resetStats() => _client.resetStats();

  // ===== Internal =====

  void _setupListeners() {
    _dataSubscription = _client.onDataChanged.listen(_handleDataChange);
    _connectionSubscription = _client.onConnectionChanged.listen(
      _handleConnectionChange,
    );
  }

  /// Setup subscription manager connection listener
  void _setupSubscriptionManager() {
    _client.onConnectionChanged.listen((event) {
      switch (event.currentState) {
        case socket.ConnectionState.connected:
          if (!_subscriptionManager.isInitialized) {
            // First connect
            _subscriptionManager.init();
          } else {
            // Reconnect
            _subscriptionManager.onReconnected();
            _betslipSubscriptionManager.onReconnected();
          }
          break;
        case socket.ConnectionState.disconnected:
          _subscriptionManager.onDisconnected();
          break;
        default:
          break;
      }
    });
  }

  void _handleDataChange(socket.DataChangeEvent event) {
    if (event.isEmpty) return;

    // Invalidate affected caches FIRST
    _invalidateCaches(event);

    // Emit granular update (always - for widgets that need fine-grained updates)
    _updateController.add(
      SportSocketUpdate(
        updatedLeagueIds: event.updatedLeagueIds,
        updatedEventIds: event.updatedEventIds,
        updatedMarketKeys: event.updatedMarketKeys,
        updatedOddsKeys: event.updatedOddsKeys,
        addedLeagueIds: event.addedLeagueIds,
        addedEventIds: event.addedEventIds,
        removedLeagueIds: event.removedLeagueIds,
        removedEventIds: event.removedEventIds,
        timestamp: event.timestamp,
      ),
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // PERFORMANCE FIX: Only emit full leagues list for STRUCTURAL changes
    // - Structural = leagues/events added or removed
    // - Data-only = odds, scores, market status updates (no list rebuild needed)
    // ═══════════════════════════════════════════════════════════════════════════
    final hasStructuralChanges =
        event.addedLeagueIds.isNotEmpty ||
        event.addedEventIds.isNotEmpty ||
        event.removedLeagueIds.isNotEmpty ||
        event.removedEventIds.isNotEmpty;

    if (hasStructuralChanges) {
      // Structural changes: Need to rebuild UI structure
      if (kDebugMode) {
        debugPrint(
          '$_tag Structural changes - '
          'added: ${event.addedLeagueIds.length} leagues, ${event.addedEventIds.length} events | '
          'removed: ${event.removedLeagueIds.length} leagues, ${event.removedEventIds.length} events',
        );
      }

      // ⭐ FIX: Only emit for PRIMARY sport (the one user is viewing)
      // BetSlip may subscribe to other sports, but LeagueNotifier only cares about active sport
      // Emitting for all subscribedSports causes data from other sports to overwrite current view
      final primarySportId = currentSportId;
      final leagues = getLeaguesBySport(primarySportId);
      _leaguesController.add(leagues);
    }
    // Data-only changes: Skip full list emit, UI uses granular updates via onUpdate stream
  }

  void _handleConnectionChange(socket.ConnectionStateEvent event) {
    // Clear cache when disconnected to avoid stale data
    if (event.currentState == socket.ConnectionState.disconnected) {
      _clearCaches();
    }
  }

  // ===== Cache Management =====

  /// Add league to cache with size limit (FIFO eviction)
  // TODO: Consider LRU eviction for better cache efficiency if needed
  void _addToLeagueCache(int leagueId, LeagueData league) {
    if (_leagueCache.length >= _maxLeagueCacheSize) {
      // Simple FIFO for now
      _leagueCache.remove(_leagueCache.keys.first);
    }
    _leagueCache[leagueId] = league;
  }

  /// Add event to cache with size limit (FIFO eviction)
  void _addToEventCache(int eventId, LeagueEventData event) {
    if (_eventCache.length >= _maxEventCacheSize) {
      // Simple FIFO for now
      _eventCache.remove(_eventCache.keys.first);
    }
    _eventCache[eventId] = event;
  }

  /// Invalidate cache entries affected by data change event
  void _invalidateCaches(socket.DataChangeEvent event) {
    // Remove entries for updated leagues
    for (final leagueId in event.updatedLeagueIds) {
      _leagueCache.remove(leagueId);
    }
    // Remove entries for updated events
    for (final eventId in event.updatedEventIds) {
      _eventCache.remove(eventId);
    }
    // Remove entries for events with updated markets
    for (final marketKey in event.updatedMarketKeys) {
      final eventId = int.tryParse(marketKey.split('_').first);
      if (eventId != null) _eventCache.remove(eventId);
    }
    // Remove entries for events with updated odds
    for (final oddsKey in event.updatedOddsKeys) {
      // oddsKey format: "eventId_marketId_offerId"
      final parts = oddsKey.split('_');
      if (parts.isNotEmpty) {
        final eventId = int.tryParse(parts.first);
        if (eventId != null) _eventCache.remove(eventId);
      }
    }
    // Handle removals
    for (final leagueId in event.removedLeagueIds) {
      _leagueCache.remove(leagueId);
    }
    for (final eventId in event.removedEventIds) {
      _eventCache.remove(eventId);
    }
  }

  /// Clear all caches
  void _clearCaches() {
    _leagueCache.clear();
    _eventCache.clear();
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await _dataSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _leaguesController.close();
    await _updateController.close();
    _betslipSubscriptionManager.dispose();
    _subscriptionManager.dispose();
    await _client.dispose();
  }
}

/// Granular update event from sport socket.
///
/// Contains IDs of entities that were added/updated/removed.
/// Use this for fine-grained UI updates instead of rebuilding everything.
class SportSocketUpdate {
  /// League IDs that were updated
  final Set<int> updatedLeagueIds;

  /// Event IDs that were updated
  final Set<int> updatedEventIds;

  /// Market keys that were updated ("{eventId}_{marketId}")
  final Set<String> updatedMarketKeys;

  /// Odds keys that were updated ("{eventId}_{marketId}_{offerId}")
  final Set<String> updatedOddsKeys;

  /// League IDs that were added
  final List<int> addedLeagueIds;

  /// Event IDs that were added
  final List<int> addedEventIds;

  /// League IDs that were removed
  final List<int> removedLeagueIds;

  /// Event IDs that were removed
  final List<int> removedEventIds;

  /// Timestamp of this update
  final DateTime timestamp;

  const SportSocketUpdate({
    required this.updatedLeagueIds,
    required this.updatedEventIds,
    required this.updatedMarketKeys,
    required this.updatedOddsKeys,
    required this.addedLeagueIds,
    required this.addedEventIds,
    required this.removedLeagueIds,
    required this.removedEventIds,
    required this.timestamp,
  });

  /// Check if a specific event is affected
  bool affectsEvent(int eventId) =>
      updatedEventIds.contains(eventId) ||
      addedEventIds.contains(eventId) ||
      removedEventIds.contains(eventId);

  /// Check if a specific league is affected
  bool affectsLeague(int leagueId) =>
      updatedLeagueIds.contains(leagueId) ||
      addedLeagueIds.contains(leagueId) ||
      removedLeagueIds.contains(leagueId);

  /// Check if a specific market is affected
  bool affectsMarket(int eventId, int marketId) {
    final key = '${eventId}_$marketId';
    return updatedMarketKeys.contains(key);
  }

  /// Check if this is an odds-only update
  bool get isOddsOnlyUpdate =>
      updatedOddsKeys.isNotEmpty &&
      addedLeagueIds.isEmpty &&
      addedEventIds.isEmpty &&
      removedLeagueIds.isEmpty &&
      removedEventIds.isEmpty &&
      updatedLeagueIds.isEmpty;

  /// Check if there are structural changes
  bool get hasStructuralChanges =>
      addedLeagueIds.isNotEmpty ||
      addedEventIds.isNotEmpty ||
      removedLeagueIds.isNotEmpty ||
      removedEventIds.isNotEmpty;
}
