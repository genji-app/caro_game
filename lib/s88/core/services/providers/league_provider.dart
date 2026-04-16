import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' show TimeRange;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/providers/reconnect_aware.dart';
import 'package:co_caro_flame/s88/core/services/providers/reconnect_coordinator.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_manager.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';

/// League State - SINGLE SOURCE OF TRUTH
///
/// Holds the current state of leagues data for the ACTIVE TAB ONLY.
/// Follows the "Active Tab Only" pattern - clear and reload when switching tabs.
///
/// Uses indexed lookups for O(1) access:
/// - allEvents: eventId -> Event (primary store)
/// - eventToLeagueIndex: eventId -> index in leagues list
///
/// KEY CONCEPTS:
/// - [leagues]: Single source - contains data for current tab only
/// - [currentTimeRange]: Current tab being viewed (LIVE/TODAY/EARLY)
/// - Data is CLEARED when switching tabs (memory efficient)
/// - Bet Slip (ParlayState) is SEPARATE and never cleared
class LeagueState {
  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLE SOURCE - Only data for active tab
  // ═══════════════════════════════════════════════════════════════════════════

  /// All leagues for current tab - SINGLE SOURCE OF TRUTH
  /// Cleared and reloaded when switching tabs
  final List<LeagueData> leagues;

  /// Current time range tab being viewed (LIVE/TODAY/EARLY)
  final SportDetailFilterType currentTimeRange;

  /// Current selected sport ID
  final int currentSportId;

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING STATES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main loading state for initial load and tab switching
  final bool isLoading;

  /// Is currently switching tab (show skeleton/shimmer)
  final bool isSwitchingTab;

  /// Is refreshing current data (silent, no UI blocker)
  final bool isRefreshing;

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL SECTIONS (separate from main leagues)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Hot/Featured leagues
  final List<LeagueData> hotLeagues;

  /// Outright leagues (championship bets)
  final List<LeagueData> outrightLeagues;

  final bool isLoadingHot;
  final bool isLoadingOutright;

  // ═══════════════════════════════════════════════════════════════════════════
  // METADATA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Current odds style
  final OddsStyle oddsStyle;

  /// Error message
  final String? error;

  /// Last update time
  final DateTime? lastUpdated;

  // ═══════════════════════════════════════════════════════════════════════════
  // INDEXED LOOKUPS FOR O(1) ACCESS
  // ═══════════════════════════════════════════════════════════════════════════

  /// League cache by ID for quick lookup
  final Map<int, LeagueData> leagueCache;

  /// All events indexed by eventId for O(1) lookup
  final Map<int, LeagueEventData> allEvents;

  /// Maps eventId -> league index in leagues list
  final Map<int, int> eventToLeagueIndex;

  const LeagueState({
    this.leagues = const [],
    this.currentTimeRange = SportDetailFilterType.live,
    this.currentSportId = 1, // Default: Football
    this.isLoading = true,
    this.isSwitchingTab = false,
    this.isRefreshing = false,
    this.hotLeagues = const [],
    this.outrightLeagues = const [],
    this.isLoadingHot = false,
    this.isLoadingOutright = false,
    this.oddsStyle =
        OddsStyle.decimal, // Default: Decimal (matches SportStorage)
    this.error,
    this.lastUpdated,
    this.leagueCache = const {},
    this.allEvents = const {},
    this.eventToLeagueIndex = const {},
  });

  /// Get current sport as enum
  SportType? get currentSport => SportType.fromId(currentSportId);

  /// Check if event exists in current leagues - O(1)
  bool hasEvent(int eventId) => allEvents.containsKey(eventId);

  /// Get event by ID - O(1)
  LeagueEventData? getEvent(int eventId) => allEvents[eventId];

  /// Get league by ID - O(1)
  LeagueData? getLeague(int leagueId) => leagueCache[leagueId];

  LeagueState copyWith({
    List<LeagueData>? leagues,
    SportDetailFilterType? currentTimeRange,
    int? currentSportId,
    bool? isLoading,
    bool? isSwitchingTab,
    bool? isRefreshing,
    List<LeagueData>? hotLeagues,
    List<LeagueData>? outrightLeagues,
    bool? isLoadingHot,
    bool? isLoadingOutright,
    OddsStyle? oddsStyle,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
    Map<int, LeagueData>? leagueCache,
    Map<int, LeagueEventData>? allEvents,
    Map<int, int>? eventToLeagueIndex,
  }) {
    return LeagueState(
      leagues: leagues ?? this.leagues,
      currentTimeRange: currentTimeRange ?? this.currentTimeRange,
      currentSportId: currentSportId ?? this.currentSportId,
      isLoading: isLoading ?? this.isLoading,
      isSwitchingTab: isSwitchingTab ?? this.isSwitchingTab,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hotLeagues: hotLeagues ?? this.hotLeagues,
      outrightLeagues: outrightLeagues ?? this.outrightLeagues,
      isLoadingHot: isLoadingHot ?? this.isLoadingHot,
      isLoadingOutright: isLoadingOutright ?? this.isLoadingOutright,
      oddsStyle: oddsStyle ?? this.oddsStyle,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      leagueCache: leagueCache ?? this.leagueCache,
      allEvents: allEvents ?? this.allEvents,
      eventToLeagueIndex: eventToLeagueIndex ?? this.eventToLeagueIndex,
    );
  }

  /// Get total events count across all leagues
  int get totalEvents =>
      leagues.fold(0, (sum, league) => sum + league.events.length);

  /// Get all live events across all leagues
  List<LeagueEventData> get allLiveEvents => leagues
      .expand((league) => league.events)
      .where((event) => event.isLive)
      .toList();

  /// Get all upcoming events across all leagues
  List<LeagueEventData> get allUpcomingEvents => leagues
      .expand((league) => league.events)
      .where((event) => !event.isLive)
      .toList();
}

/// League Notifier
///
/// Manages league data following the flow:
/// 1. Load sportId from storage
/// 2. Set sportId to HttpManager
/// 3. Fetch leagues from API
/// 4. Parse response to LeagueData models
class LeagueNotifier extends StateNotifier<LeagueState>
    implements ReconnectAware {
  final Ref _ref;
  final SbHttpManager _httpManager;
  final SportStorage _storage;
  final SportSocketAdapter? _sportSocketAdapter;
  final AppLogger _logger = AppLogger();

  // ═══════════════════════════════════════════════════════════════════════════
  // PERFORMANCE FIX: Throttle mechanism for setLeaguesFromAdapter
  // Prevents excessive UI rebuilds from high-frequency WebSocket updates
  // ═══════════════════════════════════════════════════════════════════════════
  Timer? _leaguesThrottleTimer;
  List<LeagueData>? _pendingLeagues;
  int? _pendingSportId;

  /// Throttle duration - maximum 2 updates per second
  static const _throttleDuration = Duration(milliseconds: 500);

  /// Track last update time for debugging
  DateTime? _lastLeaguesUpdateTime;

  LeagueNotifier(
    this._ref,
    this._httpManager,
    this._storage, {
    SportSocketAdapter? sportSocketAdapter,
    OddsStyle initialOddsStyle = OddsStyle.decimal,
  }) : _sportSocketAdapter = sportSocketAdapter,
       super(LeagueState(oddsStyle: initialOddsStyle)) {
    // debugPrint('🏗️ LeagueNotifier constructor called');
  }

  @override
  void refreshOnReconnect() {
    fetchLeaguesSilent();
  }

  /// Dispose throttle timer - call from provider's onDispose
  void disposeThrottleTimer() {
    _leaguesThrottleTimer?.cancel();
    _leaguesThrottleTimer = null;
    _pendingLeagues = null;
    _pendingSportId = null;
  }

  @override
  set state(LeagueState value) {
    // debugPrint('🔔 LeagueNotifier.setState called: old leagues=${state.leagues.length}, new leagues=${value.leagues.length}');
    // debugPrint('🔔 LeagueNotifier.setState: old isLoading=${state.isLoading}, new isLoading=${value.isLoading}');
    super.state = value;
    // debugPrint('🔔 LeagueNotifier.setState completed');
  }

  /// Initialize - call when entering Sport tab
  ///
  /// Flow:
  /// 1. Load sportId from SharedPreferences
  /// 2. Load oddsStyle from SharedPreferences
  /// 3. Set sportId to SbHttpManager
  /// 4. Does NOT auto-fetch leagues - caller should call fetchLeagues() or fetchLiveLeagues() after
  ///
  /// This allows:
  /// - Home screen: Can call initialize() without triggering API calls
  /// - Sport screen: Call initialize() then fetchLiveLeagues()
  /// - Sport detail: Call fetchLeagues() with specific params based on selected tab
  Future<void> initialize() async {
    // debugPrint('🚀 LeagueNotifier: initialize() called - loading config only');

    // Load saved sportId
    final sportId = await _storage.getSportId();
    // debugPrint('💾 LeagueNotifier: Loaded sportId from storage: $sportId');

    // Load saved oddsStyle
    final savedOddsStyleStr = await _storage.getOddsStyle();
    final oddsStyle = OddsStyle.fromShortName(savedOddsStyleStr);
    // debugPrint('💾 LeagueNotifier: Loaded oddsStyle from storage: $savedOddsStyleStr -> $oddsStyle');

    // Update state and http manager
    state = state.copyWith(currentSportId: sportId, oddsStyle: oddsStyle);
    _httpManager.sportTypeId = sportId;
    // debugPrint('📡 LeagueNotifier: Updated httpManager sportTypeId to: $sportId');

    // ========== DISABLED: Don't auto-fetch leagues ==========
    // Luồng mới:
    // - initialize() chỉ load config (sportId, oddsStyle)
    // - Caller tự quyết định khi nào call fetchLeagues()
    // ========================================================

    // OLD CODE - Commented out to prevent auto API calls
    // if (state.leagues.isEmpty) {
    //   debugPrint('📊 LeagueNotifier: First load, fetching with loading state');
    //   await fetchLeagues();
    // } else {
    //   debugPrint('📊 LeagueNotifier: Data exists, refreshing silently');
    //   await fetchLeaguesSilent();
    // }
  }

  /// Build indexed lookups from leagues list
  ///
  /// Creates:
  /// - leagueCache: leagueId -> LeagueData
  /// - allEvents: eventId -> LeagueEventData
  /// - eventToLeagueIndex: eventId -> league index in list
  ///
  /// Complexity: O(n) where n = total events across all leagues
  /// After building, lookups are O(1)
  ({
    Map<int, LeagueData> leagueCache,
    Map<int, LeagueEventData> allEvents,
    Map<int, int> eventToLeagueIndex,
  })
  _buildIndexes(List<LeagueData> leagues) {
    final leagueCache = <int, LeagueData>{};
    final allEvents = <int, LeagueEventData>{};
    final eventToLeagueIndex = <int, int>{};

    for (var i = 0; i < leagues.length; i++) {
      final league = leagues[i];
      leagueCache[league.leagueId] = league;

      for (final event in league.events) {
        allEvents[event.eventId] = event;
        eventToLeagueIndex[event.eventId] = i;
      }
    }

    return (
      leagueCache: leagueCache,
      allEvents: allEvents,
      eventToLeagueIndex: eventToLeagueIndex,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME RANGE SWITCHING - Core method for "Active Tab Only" pattern
  // ═══════════════════════════════════════════════════════════════════════════

  /// Switch to a different time range tab (LIVE/TODAY/EARLY)
  ///
  /// This implements the "Single Source of Truth" pattern:
  /// 1. Notify AutoRefreshManager about tab change FIRST
  /// 2. Fetch data through Adapter → populates STORE
  /// 3. Read data from STORE (Single Source of Truth)
  /// 4. Update UI state
  ///
  /// Flow: UI → Adapter → Store → UI
  /// Store is always the Single Source of Truth!
  ///
  /// Note: Bet Slip (ParlayState) is NOT affected by this switch
  Future<void> switchTimeRange(SportDetailFilterType newTimeRange) async {
    // Skip if already on this tab and has data
    if (state.currentTimeRange == newTimeRange && state.leagues.isNotEmpty) {
      debugPrint(
        '[LeagueNotifier] Already on $newTimeRange with data, skipping',
      );
      return;
    }

    debugPrint(
      '[LeagueNotifier] Switching tab: ${state.currentTimeRange} → $newTimeRange',
    );

    // Clear vibrating odds state when switching away from Live
    // (Kèo Rung only applies to Live matches)
    if (newTimeRange != SportDetailFilterType.live) {
      _ref.read(vibratingOddsProvider.notifier).clearAll();
    }

    // ⭐ FIX: Clear MarketStatusProvider to reset stale suspended markets
    // This prevents accumulated autoSuspended status from locking all odds
    _ref.read(marketStatusProvider.notifier).clear();
    debugPrint('[LeagueNotifier] Cleared MarketStatusProvider');

    // 1. Show switching state, clear current data
    state = state.copyWith(
      isSwitchingTab: true,
      isLoading: true,
      leagues: [],
      leagueCache: {},
      allEvents: {},
      eventToLeagueIndex: {},
      currentTimeRange: newTimeRange,
      clearError: true,
    );

    try {
      // ⭐ 2. IMPORTANT: Notify AutoRefreshManager FIRST
      // This ensures timer fetches correct data type
      _sportSocketAdapter?.updateTimeRange(_toTimeRangeString(newTimeRange));

      // ⭐ 3. FIX: Fetch through Adapter to SYNC STORE
      // Instead of direct API call, go through adapter so Store is populated
      await _fetchAndPopulateForTimeRange(newTimeRange);

      // 4. Read data from STORE (Single Source of Truth)
      final leagues =
          _sportSocketAdapter?.getLeaguesBySport(state.currentSportId) ?? [];

      // 5. Build indexes for O(1) lookup
      final indexes = _buildIndexes(leagues);

      // 6. Update UI state with data from Store
      state = state.copyWith(
        leagues: leagues,
        leagueCache: indexes.leagueCache,
        allEvents: indexes.allEvents,
        eventToLeagueIndex: indexes.eventToLeagueIndex,
        isLoading: false,
        isSwitchingTab: false,
        lastUpdated: DateTime.now(),
      );

      debugPrint(
        '[LeagueNotifier] Tab switch complete: ${leagues.length} leagues, ${indexes.allEvents.length} events',
      );
    } catch (e) {
      debugPrint('[LeagueNotifier] Tab switch error: $e');
      state = state.copyWith(
        isLoading: false,
        isSwitchingTab: false,
        error: 'Không thể tải dữ liệu. Vui lòng thử lại!',
      );
    }
  }

  /// ⭐ NEW: Fetch and populate Store based on timeRange
  ///
  /// This ensures Store is always synced with the current tab.
  /// Store is Single Source of Truth - UI reads from Store.
  Future<void> _fetchAndPopulateForTimeRange(
    SportDetailFilterType timeRange,
  ) async {
    if (_sportSocketAdapter == null) {
      // Fallback if adapter not available - use direct API
      debugPrint('[LeagueNotifier] No adapter, using direct API call');
      final leagues = await _fetchLeaguesForTimeRange(timeRange);
      final indexes = _buildIndexes(leagues);
      state = state.copyWith(
        leagues: leagues,
        leagueCache: indexes.leagueCache,
        allEvents: indexes.allEvents,
        eventToLeagueIndex: indexes.eventToLeagueIndex,
      );
      return;
    }

    // Fetch through adapter - this populates the STORE
    // _sportSocketAdapter is guaranteed non-null here (early return above)
    final adapter = _sportSocketAdapter;
    switch (timeRange) {
      case SportDetailFilterType.live:
        await adapter.fetchLiveAndPopulate();
        break;
      case SportDetailFilterType.today:
        await adapter.fetchTodayAndPopulate();
        break;
      case SportDetailFilterType.early:
        await adapter.fetchEarlyAndPopulate();
        break;
      default:
        // Special/Favorites - use direct API for now
        break;
    }
  }

  /// Convert SportDetailFilterType to TimeRange string
  String _toTimeRangeString(SportDetailFilterType filter) {
    switch (filter) {
      case SportDetailFilterType.live:
        return TimeRange.live; // 'LIVE'
      case SportDetailFilterType.today:
        return TimeRange.today; // 'TODAY'
      case SportDetailFilterType.early:
        return TimeRange.early; // 'EARLY'
      default:
        return TimeRange.live;
    }
  }

  /// Fetch leagues from API based on time range (legacy - for fallback only)
  Future<List<LeagueData>> _fetchLeaguesForTimeRange(
    SportDetailFilterType timeRange,
  ) async {
    switch (timeRange) {
      case SportDetailFilterType.live:
        return _httpManager.getLeagues(days: 1, isLive: true);
      case SportDetailFilterType.today:
        return _httpManager.getLeagues(days: 1, isLive: false);
      case SportDetailFilterType.early:
        return _httpManager.getLeagues(days: 2, isLive: false);
      case SportDetailFilterType.special:
      case SportDetailFilterType.favorites:
        // Not implemented yet - return empty
        return [];
    }
  }

  /// Fetch leagues from API for current time range
  ///
  /// Parameters:
  /// - [days]: Filter by day (0=today, 1=tomorrow)
  /// - [isLive]: Filter live matches only
  /// - [cancelToken]: Optional CancelToken to cancel the request
  Future<void> fetchLeagues({
    int? days,
    bool? isLive,
    CancelToken? cancelToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final leagues = await _httpManager.getLeagues(
        days: days,
        isLive: isLive,
        cancelToken: cancelToken,
      );

      // Build all indexes in one pass - O(n)
      final indexes = _buildIndexes(leagues);

      state = state.copyWith(
        leagues: leagues,
        isLoading: false,
        lastUpdated: DateTime.now(),
        leagueCache: indexes.leagueCache,
        allEvents: indexes.allEvents,
        eventToLeagueIndex: indexes.eventToLeagueIndex,
      );

      debugPrint(
        '[LeagueNotifier] fetchLeagues done - ${leagues.length} leagues, ${indexes.allEvents.length} events indexed',
      );
    } on DioException catch (e) {
      // Rethrow cancel exceptions for caller to handle
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      _logger.e('❌ LeagueNotifier: DioException fetching leagues: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Network error',
      );
    } catch (e) {
      _logger.e('❌ LeagueNotifier: Error fetching leagues: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fetch leagues silently - keep old data visible, only update if changed
  ///
  /// - Does NOT set isLoading = true → UI stays responsive
  /// - Keeps old list visible while fetching
  /// - Only triggers rebuild if data actually changed
  /// - Uses indexed lookups for O(1) event comparison
  ///
  /// Use this for background refresh while user is viewing data
  Future<void> fetchLeaguesSilent({int? days, bool? isLive}) async {
    try {
      final newLeagues = await _httpManager.getLeagues(
        days: days,
        isLive: isLive,
      );

      // If old list is empty → update immediately (first load)
      if (state.leagues.isEmpty) {
        final indexes = _buildIndexes(newLeagues);
        state = state.copyWith(
          leagues: newLeagues,
          lastUpdated: DateTime.now(),
          leagueCache: indexes.leagueCache,
          allEvents: indexes.allEvents,
          eventToLeagueIndex: indexes.eventToLeagueIndex,
        );
        return;
      }

      // Use existing allEvents index for O(1) lookup
      final oldEventsMap = state.allEvents;

      // Yield to let UI render
      await Future<void>.delayed(Duration.zero);

      // Check if there are any changes
      bool hasChanges = false;
      int newEventCount = 0;

      for (final league in newLeagues) {
        for (final event in league.events) {
          newEventCount++;
          final oldEvent = oldEventsMap[event.eventId]; // O(1) lookup!
          if (oldEvent == null) {
            hasChanges = true;
          } else if (_isEventChanged(oldEvent, event)) {
            hasChanges = true;
          }
        }
      }

      // Also check if events were removed
      if (!hasChanges && oldEventsMap.length != newEventCount) {
        hasChanges = true;
      }

      // Only update state if there are changes
      if (hasChanges) {
        final indexes = _buildIndexes(newLeagues);
        state = state.copyWith(
          leagues: newLeagues,
          lastUpdated: DateTime.now(),
          leagueCache: indexes.leagueCache,
          allEvents: indexes.allEvents,
          eventToLeagueIndex: indexes.eventToLeagueIndex,
        );
        debugPrint('✅ [LeagueNotifier] Silent fetch updated state');
      }
    } catch (e) {
      // Silent fail - keep old data, don't show error
      _logger.e('❌ [LeagueNotifier] Silent fetch failed: $e');
    }
  }

  /// Quick comparison of important fields only (not deep equality)
  /// This is fast because we only check fields that typically change
  bool _isEventChanged(LeagueEventData oldEvent, LeagueEventData newEvent) {
    // Score changed
    if (oldEvent.homeScore != newEvent.homeScore) return true;
    if (oldEvent.awayScore != newEvent.awayScore) return true;

    // Live status changed
    if (oldEvent.isLive != newEvent.isLive) return true;
    if (oldEvent.isSuspended != newEvent.isSuspended) return true;

    // Game time changed (for live matches)
    if (oldEvent.gameTime != newEvent.gameTime) return true;
    if (oldEvent.gamePart != newEvent.gamePart) return true;

    // Markets count changed (odds might have changed)
    if (oldEvent.markets.length != newEvent.markets.length) return true;

    // Check main line odds changed (quick check)
    if (oldEvent.markets.isNotEmpty && newEvent.markets.isNotEmpty) {
      final oldFirstMarket = oldEvent.markets.first;
      final newFirstMarket = newEvent.markets.first;
      if (oldFirstMarket.odds.length != newFirstMarket.odds.length) return true;

      // Check first odds line
      if (oldFirstMarket.odds.isNotEmpty && newFirstMarket.odds.isNotEmpty) {
        final oldOdds = oldFirstMarket.odds.first;
        final newOdds = newFirstMarket.odds.first;
        if (oldOdds.points != newOdds.points) return true;
      }
    }

    return false;
  }

  /// Fetch live events only - convenience method
  Future<void> fetchLiveLeagues() async {
    await switchTimeRange(SportDetailFilterType.live);
  }

  /// Refresh current tab data
  Future<void> refreshCurrentTab() async {
    await switchTimeRange(state.currentTimeRange);
  }

  /// Fetch hot/featured leagues
  Future<void> fetchHotLeagues() async {
    state = state.copyWith(isLoadingHot: true, error: null);

    try {
      final hotLeaguesV2 = await _httpManager.getHotLeagues();
      final hotLeagues = hotLeaguesV2.toLegacy();

      state = state.copyWith(hotLeagues: hotLeagues, isLoadingHot: false);
    } catch (e) {
      state = state.copyWith(isLoadingHot: false, error: e.toString());
    }
  }

  /// Fetch outright leagues
  Future<void> fetchOutrightLeagues() async {
    state = state.copyWith(isLoadingOutright: true, error: null);

    try {
      final outrightLeagues = await _httpManager.getOutrightLeagues();

      state = state.copyWith(
        outrightLeagues: outrightLeagues,
        isLoadingOutright: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingOutright: false, error: e.toString());
    }
  }

  /// Change sport
  ///
  /// Flow:
  /// 1. Clear pending throttled updates (prevent stale data)
  /// 2. Update state immediately (no blocking)
  /// 3. Update SbHttpManager
  /// 4. Save to SharedPreferences (fire-and-forget)
  /// 5. Fetch new data for LIVE tab through Adapter (populates Store)
  /// 6. Read data from Store (Single Source of Truth)
  ///
  /// ⭐ IMPORTANT: Must fetch through Adapter to populate Store!
  /// Otherwise adapter emits 0 leagues and overwrites state.
  ///
  /// Returns Future so caller can await and know when data is loaded.
  /// Pass [cancelToken] to cancel the fetch if user switches again.
  Future<void> changeSport(int sportId, {CancelToken? cancelToken}) async {
    if (state.currentSportId == sportId) return;

    debugPrint(
      '[LeagueNotifier] Changing sport: ${state.currentSportId} → $sportId',
    );

    // Clear vibrating odds state when changing sport
    _ref.read(vibratingOddsProvider.notifier).clearAll();

    // ⭐ FIX: Clear MarketStatusProvider to reset stale suspended markets
    _ref.read(marketStatusProvider.notifier).clear();
    debugPrint('[LeagueNotifier] Cleared MarketStatusProvider');

    // Notify SubscriptionManager FIRST (instant routing change) - NEW library
    _sportSocketAdapter?.subscriptionManager.setActiveSport(sportId);

    // Also subscribe on OLD WebSocket (for score/odds streams used by UI widgets)
    // TODO: Remove this when UI migrates to use NEW library streams
    WebSocketManager.instance.subscribeSport(sportId);

    // Clear pending throttled updates for old sport
    onSportChanging(sportId);

    // Update http manager immediately
    _httpManager.sportTypeId = sportId;

    // Clear old data and indexes, update sportId, reset to LIVE tab
    state = state.copyWith(
      currentSportId: sportId,
      currentTimeRange: SportDetailFilterType.live, // Reset to LIVE tab
      leagues: [],
      hotLeagues: [],
      outrightLeagues: [],
      leagueCache: {},
      allEvents: {},
      eventToLeagueIndex: {},
      isLoading: true,
      isSwitchingTab: false,
      clearError: true,
    );

    // Save to storage async (fire-and-forget, don't block UI)
    _storage.saveSportId(sportId);

    // ⭐ FIX: Fetch through Adapter to populate Store (Single Source of Truth)
    // This prevents adapter from emitting 0 leagues and overwriting state
    try {
      if (_sportSocketAdapter != null) {
        // 1. Notify AutoRefreshManager about tab (LIVE is default for sport change)
        _sportSocketAdapter.updateTimeRange(
          _toTimeRangeString(SportDetailFilterType.live),
        );

        // 2. Fetch through adapter - this populates the STORE
        await _sportSocketAdapter.fetchLiveAndPopulate();

        // 3. Read data from STORE (Single Source of Truth)
        final leagues = _sportSocketAdapter.getLeaguesBySport(sportId);

        // 4. Build indexes for O(1) lookup
        final indexes = _buildIndexes(leagues);

        // 5. Update UI state with data from Store
        state = state.copyWith(
          leagues: leagues,
          leagueCache: indexes.leagueCache,
          allEvents: indexes.allEvents,
          eventToLeagueIndex: indexes.eventToLeagueIndex,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );

        debugPrint(
          '[LeagueNotifier] Sport change complete: ${leagues.length} leagues',
        );
      } else {
        // Fallback: No adapter available, use direct API call
        debugPrint('[LeagueNotifier] No adapter, using direct API call');
        final leagues = await _httpManager.getLeagues(
          days: 1,
          isLive: true,
          cancelToken: cancelToken,
        );

        final indexes = _buildIndexes(leagues);

        state = state.copyWith(
          leagues: leagues,
          leagueCache: indexes.leagueCache,
          allEvents: indexes.allEvents,
          eventToLeagueIndex: indexes.eventToLeagueIndex,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );

        debugPrint(
          '[LeagueNotifier] Sport change complete (fallback): ${leagues.length} leagues',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Network error',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);

    try {
      await Future.wait([fetchLeagues(), fetchHotLeagues()]);
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Get league by ID (from cache)
  LeagueData? getLeagueById(int leagueId) => state.leagueCache[leagueId];

  /// Get event by ID - O(1) lookup from indexed map
  LeagueEventData? getEventById(int eventId) => state.allEvents[eventId];

  /// Change odds display style
  ///
  /// Updates the odds style used for display.
  /// No need to refetch data as odds contain all formats.
  Future<void> changeOddsStyle(OddsStyle style) async {
    if (state.oddsStyle == style) return;

    // Save to storage
    await _storage.saveOddsStyle(style.shortName);

    // Update state
    state = state.copyWith(oddsStyle: style);
  }

  /// Get current odds style
  OddsStyle get currentOddsStyle => state.oddsStyle;

  // =============================================================================
  // NEW METHODS FOR SPORT SOCKET ADAPTER INTEGRATION
  // =============================================================================

  /// Set leagues from adapter WITH THROTTLING
  ///
  /// This method is called frequently by the adapter (potentially every 300ms).
  /// Throttling ensures we don't trigger expensive UI rebuilds too often.
  ///
  /// Behavior:
  /// - First call: Schedules update after [_throttleDuration]
  /// - Subsequent calls within throttle window: Updates pending data (latest wins)
  /// - After throttle window: Applies the latest pending data
  /// - Validates sport ID to discard stale data after sport switching
  void setLeaguesFromAdapter(List<LeagueData> leagues, {int? sportId}) {
    // Always store the latest data
    _pendingLeagues = leagues;
    _pendingSportId = sportId ?? state.currentSportId;

    // If timer is already running, just queue the data (latest wins)
    if (_leaguesThrottleTimer?.isActive == true) {
      if (kDebugMode) {
        debugPrint(
          '📥 [LeagueNotifier] Queued ${leagues.length} leagues (throttled)',
        );
      }
      return;
    }

    // Start throttle timer
    _leaguesThrottleTimer = Timer(_throttleDuration, _flushPendingLeagues);

    if (kDebugMode) {
      debugPrint(
        '📥 [LeagueNotifier] Scheduled ${leagues.length} leagues update',
      );
    }
  }

  /// Flush pending leagues to state
  void _flushPendingLeagues() {
    _leaguesThrottleTimer = null;

    final leagues = _pendingLeagues;
    final pendingSportId = _pendingSportId;

    // Clear pending
    _pendingLeagues = null;
    _pendingSportId = null;

    if (leagues == null) return;

    // ═══════════════════════════════════════════════════════════════════════
    // VALIDATE: Discard stale data if sport has changed
    // ═══════════════════════════════════════════════════════════════════════
    if (pendingSportId != null && pendingSportId != state.currentSportId) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [LeagueNotifier] Discarding stale data: '
          'pending sport=$pendingSportId, current sport=${state.currentSportId}',
        );
      }
      return; // Discard stale data
    }

    // ⭐ FIX: Clear MarketStatusProvider on EVERY API refresh (before equality check)
    // API data is the source of truth - accumulated WebSocket statuses are stale
    // This must run even when data unchanged to reset stale suspended statuses
    _ref.read(marketStatusProvider.notifier).clear();
    debugPrint(
      '[LeagueNotifier] 🧹 Cleared MarketStatusProvider (API refresh)',
    );

    // ═══════════════════════════════════════════════════════════════════════
    // OPTIMIZATION: Check if data actually changed before updating state
    // ═══════════════════════════════════════════════════════════════════════
    if (_isLeaguesDataEqual(state.leagues, leagues)) {
      if (kDebugMode) {
        debugPrint('⚡ [LeagueNotifier] Data unchanged, skipping state update');
      }
      return; // No change, skip expensive state update
    }

    // Calculate time since last update for debugging
    final now = DateTime.now();
    final timeSinceLastUpdate = _lastLeaguesUpdateTime != null
        ? now.difference(_lastLeaguesUpdateTime!).inMilliseconds
        : 0;
    _lastLeaguesUpdateTime = now;

    if (kDebugMode) {
      debugPrint(
        '📥 [LeagueNotifier] Flushing ${leagues.length} leagues '
        '(${timeSinceLastUpdate}ms since last update)',
      );
    }

    // Build indexes and update state (Single Source pattern - just update leagues)
    final indexes = _buildIndexes(leagues);

    state = state.copyWith(
      leagues: leagues,
      isLoading: false,
      isRefreshing: false,
      clearError: true,
      lastUpdated: now,
      leagueCache: indexes.leagueCache,
      allEvents: indexes.allEvents,
      eventToLeagueIndex: indexes.eventToLeagueIndex,
    );
  }

  /// Quick check if leagues data actually changed
  ///
  /// Performs lightweight comparison to avoid expensive state updates when
  /// data hasn't meaningfully changed. This is critical for memory optimization
  /// as it prevents unnecessary Map allocations and widget rebuilds.
  ///
  /// Comparison strategy:
  /// 1. Fast path: Reference equality (identical objects)
  /// 2. Length check (different number of leagues)
  /// 3. League count check (different number of events)
  ///
  /// Note: This is intentionally a shallow comparison - we don't compare every
  /// odds value because that would be expensive. If counts match, we assume
  /// it's just odds updates which should still trigger a rebuild.
  bool _isLeaguesDataEqual(List<LeagueData> old, List<LeagueData> newData) {
    // Fast path: Same reference
    if (identical(old, newData)) return true;

    // Different number of leagues
    if (old.length != newData.length) return false;

    // Check total event counts across all leagues
    int oldEventCount = 0;
    int newEventCount = 0;

    for (final league in old) {
      oldEventCount += league.events.length;
    }

    for (final league in newData) {
      newEventCount += league.events.length;
    }

    // Different number of events = structural change
    if (oldEventCount != newEventCount) return false;

    // If counts match, assume it's just odds updates (still need to update)
    // We don't do deep comparison as it would be too expensive
    return false; // Let the update through for odds changes
  }

  /// Force immediate flush (for testing or critical updates)
  void flushPendingLeaguesNow() {
    _leaguesThrottleTimer?.cancel();
    _flushPendingLeagues();
  }

  /// Called when user changes sport - clear pending data immediately
  ///
  /// This prevents stale data from old sport being applied after switch
  void onSportChanging(int newSportId) {
    // Cancel pending updates for old sport
    _leaguesThrottleTimer?.cancel();
    _leaguesThrottleTimer = null;
    _pendingLeagues = null;
    _pendingSportId = null;

    if (kDebugMode) {
      debugPrint(
        '🔄 [LeagueNotifier] Sport changing to $newSportId, cleared pending',
      );
    }
  }

  /// Handle connection state changes from adapter
  ///
  /// Used to update UI when WebSocket connects/disconnects.
  void handleConnectionStateChange({required bool isConnected}) {
    if (!isConnected) {
      if (kDebugMode) {
        debugPrint('⚠️ [LeagueNotifier] WebSocket disconnected');
      }
    } else {
      if (kDebugMode) {
        debugPrint('✅ [LeagueNotifier] WebSocket connected');
      }
    }
  }

  /// Clear all data
  void clear() {
    state = const LeagueState();
  }
}

// ===== PROVIDERS =====

/// Sport Storage Provider
final sportStorageProvider = Provider<SportStorage>(
  (ref) => SportStorage.instance,
);

/// Http Manager Provider
final sbHttpManagerProvider = Provider<SbHttpManager>(
  (ref) => SbHttpManager.instance,
);

/// League Provider
/// Note: Not using autoDispose to keep state alive across navigation.
/// Type explicit to break self-reference in reconnect callback.
final StateNotifierProvider<LeagueNotifier, LeagueState>
leagueProvider = StateNotifierProvider<LeagueNotifier, LeagueState>((ref) {
  // debugPrint('🏗️ Creating new LeagueNotifier instance');
  final httpManager = ref.read(
    sbHttpManagerProvider,
  ); // Changed from watch to read
  final storage = ref.read(sportStorageProvider); // Changed from watch to read

  // Try to get SportSocketAdapter if available
  // Using try-catch because adapter might not be registered yet during app startup
  SportSocketAdapter? sportSocketAdapter;
  try {
    sportSocketAdapter = ref.read(sportSocketAdapterProvider);
  } catch (_) {
    // Adapter not available yet, will be null
    debugPrint('[LeagueProvider] SportSocketAdapter not available yet');
  }

  final notifier = LeagueNotifier(
    ref,
    httpManager,
    storage,
    sportSocketAdapter: sportSocketAdapter,
    initialOddsStyle: OddsStyle.fromShortName(storage.getOddsStyleSync()),
  );

  final coordinator = ref.read(reconnectCoordinatorProvider);
  final reconnectCb = () =>
      ref.read(leagueProvider.notifier).refreshOnReconnect();
  coordinator.register(reconnectCb);

  ref.onDispose(() {
    coordinator.unregister(reconnectCb);
    notifier.disposeThrottleTimer();
    debugPrint('🗑️ LeagueNotifier disposed');
  });

  return notifier;
});

// ===== DERIVED PROVIDERS =====

/// Current sport ID provider
final currentSportIdProvider = Provider<int>(
  (ref) => ref.watch(leagueProvider).currentSportId,
);

/// All leagues provider
final leaguesProvider = Provider<List<LeagueData>>(
  (ref) => ref.watch(leagueProvider).leagues,
);

/// Hot leagues provider
final hotLeaguesProvider = Provider<List<LeagueData>>(
  (ref) => ref.watch(leagueProvider).hotLeagues,
);

/// Outright leagues provider
final outrightLeaguesProvider = Provider<List<LeagueData>>(
  (ref) => ref.watch(leagueProvider).outrightLeagues,
);

/// Loading state provider
final leagueLoadingProvider = Provider<bool>(
  (ref) => ref.watch(leagueProvider).isLoading,
);

/// Error state provider
final leagueErrorProvider = Provider<String?>(
  (ref) => ref.watch(leagueProvider).error,
);

/// League by ID provider (from cache)
final leagueByIdProvider = Provider.family<LeagueData?, int>(
  (ref, leagueId) => ref.watch(leagueProvider).leagueCache[leagueId],
);

/// All live events provider
final allLiveEventsProvider = Provider<List<LeagueEventData>>(
  (ref) => ref.watch(leagueProvider).allLiveEvents,
);

/// All upcoming events provider
final allUpcomingEventsProvider = Provider<List<LeagueEventData>>(
  (ref) => ref.watch(leagueProvider).allUpcomingEvents,
);

/// Total events count provider
final totalEventsCountProvider = Provider<int>(
  (ref) => ref.watch(leagueProvider).totalEvents,
);

/// Current odds style provider
final oddsStyleProvider = Provider<OddsStyle>(
  (ref) => ref.watch(leagueProvider).oddsStyle,
);

/// Current sport enum provider
final currentSportProvider = Provider<SportType?>(
  (ref) => ref.watch(leagueProvider).currentSport,
);
