import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/datasources/event_detail_v2_remote_datasource.dart';
import 'package:co_caro_flame/s88/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data_v2.dart';

/// Dynamic tab data for bet detail screen
class BetTabData {
  final String label;
  final MarketFilter filter;

  const BetTabData({required this.label, required this.filter});
}

/// Bet Detail Mobile V2 State
///
/// State for the new design where each market is a separate expandable card.
class BetDetailMobileV2State {
  final bool isLoading;
  final String? error;
  final LeagueEventData? eventData;
  final LeagueData? leagueData;
  final List<MarketDrawerDataV2> drawers;
  final MarketFilter currentFilter;
  final bool allExpanded;
  final Map<String, OddsChangeInfoV2> oddsChanges;

  /// Loading state for full markets (API v2)
  final bool isLoadingFullMarkets;

  /// Whether full markets have been loaded from API v2
  final bool hasFullMarkets;

  /// Error message when loading full markets fails
  final String? fullMarketsError;

  /// Sport ID for sport-aware market filtering
  final int sportId;

  const BetDetailMobileV2State({
    this.isLoading = true,
    this.error,
    this.eventData,
    this.leagueData,
    this.drawers = const [],
    this.currentFilter = MarketFilter.main,
    this.allExpanded = true,
    this.oddsChanges = const {},
    this.isLoadingFullMarkets = false,
    this.hasFullMarkets = false,
    this.fullMarketsError,
    this.sportId = 1,
  });

  /// Main market IDs per sport (for "Chính" tab)
  Set<int> get _mainMarketIds {
    switch (sportId) {
      case 2:
        return const {200, 201, 202, 203, 204, 205};
      case 3:
        return const {300, 301, 304, 305, 306, 307, 308, 309, 310};
      case 4:
        return const {400, 401, 402, 403};
      case 5:
        return const {500, 509, 510};
      case 6:
        return const {600, 609, 610};
      case 7:
        return const {700, 701, 702, 704, 705, 709, 710, 711, 712};
      default:
        return const {1, 2, 3, 4, 5, 6, 80, 85, 89, 23, 24, 25, 26, 27, 28};
    }
  }

  /// Sport-specific tab labels for Set/Quarter filters
  Map<MarketFilter, String> get _setTabLabels {
    switch (sportId) {
      case 2:
        return const {
          MarketFilter.set1: 'Q1',
          MarketFilter.set2: 'Q2',
          MarketFilter.set3: 'Q3',
          MarketFilter.set4: 'Q4',
        };
      case 4:
        return const {
          MarketFilter.set1: 'Set 1',
          MarketFilter.set2: 'Set 2',
          MarketFilter.set3: 'Set 3',
          MarketFilter.set4: 'Set 4',
        };
      case 5:
        return const {
          MarketFilter.set1: 'Set 1',
          MarketFilter.set2: 'Set 2',
          MarketFilter.set3: 'Set 3',
          MarketFilter.set4: 'Set 4',
          MarketFilter.set5: 'Set 5',
        };
      case 6:
        return const {
          MarketFilter.set1: 'Ván 1',
          MarketFilter.set2: 'Ván 2',
          MarketFilter.set3: 'Ván 3',
          MarketFilter.set4: 'Ván 4',
          MarketFilter.set5: 'Ván 5',
        };
      case 7:
        return const {};
      default:
        return const {};
    }
  }

  /// Get available tabs dynamically based on markets and sport
  List<BetTabData> get availableTabs {
    final tabs = <BetTabData>[];

    // "Chính" tab always first
    tabs.add(const BetTabData(label: 'Chính', filter: MarketFilter.main));

    // Period tabs (shared across sports)
    if (hasMarketsForFilter(MarketFilter.fullTime)) {
      tabs.add(
        const BetTabData(label: 'Toàn trận', filter: MarketFilter.fullTime),
      );
    }
    if (hasMarketsForFilter(MarketFilter.firstHalf)) {
      tabs.add(
        const BetTabData(label: 'Hiệp 1', filter: MarketFilter.firstHalf),
      );
    }

    // Soccer-only tabs
    if (sportId == 1) {
      if (hasMarketsForFilter(MarketFilter.secondHalf)) {
        tabs.add(
          const BetTabData(label: 'Hiệp 2', filter: MarketFilter.secondHalf),
        );
      }
      if (hasMarketsForFilter(MarketFilter.extraTime)) {
        tabs.add(
          const BetTabData(label: 'Hiệp phụ', filter: MarketFilter.extraTime),
        );
      }
      if (hasMarketsForFilter(MarketFilter.corner)) {
        tabs.add(
          const BetTabData(label: 'Phạt góc', filter: MarketFilter.corner),
        );
      }
      if (hasMarketsForFilter(MarketFilter.score)) {
        tabs.add(
          const BetTabData(label: 'Tỷ số', filter: MarketFilter.score),
        );
      }
      if (hasMarketsForFilter(MarketFilter.booking)) {
        tabs.add(
          const BetTabData(label: 'Thẻ phạt', filter: MarketFilter.booking),
        );
      }
    }

    // Set/Quarter tabs with sport-specific labels
    final tabLabels = _setTabLabels;
    for (final entry in tabLabels.entries) {
      if (hasMarketsForFilter(entry.key)) {
        tabs.add(BetTabData(label: entry.value, filter: entry.key));
      }
    }

    return tabs;
  }

  /// Set/Quarter filters for inclusion in "Chính" tab (non-soccer sports)
  static const Set<MarketFilter> _setFilters = {
    MarketFilter.set1,
    MarketFilter.set2,
    MarketFilter.set3,
    MarketFilter.set4,
    MarketFilter.set5,
  };

  /// Get drawers filtered by current filter
  ///
  /// Special handling for "Chính" (main) tab:
  /// - Shows all main markets (Handicap, O/U, 1X2) from all periods
  /// - For non-soccer sports, also includes Set/Quarter markets
  List<MarketDrawerDataV2> get filteredDrawers {
    if (currentFilter == MarketFilter.all) {
      return drawers;
    }

    // "Chính" tab: Show all main markets (Handicap, O/U, 1X2) from all periods
    // For non-soccer sports, also include Set/Quarter/Game markets
    if (currentFilter == MarketFilter.main) {
      return drawers.where((d) {
        final marketId = d.marketId;
        // Include Handicap, O/U, 1X2 from all periods
        if (_mainMarketIds.contains(marketId) ||
            (d.market != null &&
                _mainMarketIds.contains(d.market!.marketId))) {
          return true;
        }
        // For non-soccer sports, include Set/Quarter markets
        if (sportId != 1 && _setFilters.contains(d.filter)) {
          return true;
        }
        return false;
      }).toList();
    }

    return drawers.where((d) => d.filter == currentFilter).toList();
  }

  /// Check if filter has any markets
  bool hasMarketsForFilter(MarketFilter filter) {
    if (filter == MarketFilter.all) {
      return drawers.isNotEmpty;
    }

    // "Chính" tab: Check if any main markets exist
    if (filter == MarketFilter.main) {
      return drawers.any((d) {
        if (_mainMarketIds.contains(d.marketId) ||
            (d.market != null &&
                _mainMarketIds.contains(d.market!.marketId))) {
          return true;
        }
        if (sportId != 1 && _setFilters.contains(d.filter)) {
          return true;
        }
        return false;
      });
    }

    return drawers.any((d) => d.filter == filter && !d.isEmpty);
  }

  BetDetailMobileV2State copyWith({
    bool? isLoading,
    String? error,
    LeagueEventData? eventData,
    LeagueData? leagueData,
    List<MarketDrawerDataV2>? drawers,
    MarketFilter? currentFilter,
    bool? allExpanded,
    Map<String, OddsChangeInfoV2>? oddsChanges,
    bool? isLoadingFullMarkets,
    bool? hasFullMarkets,
    String? fullMarketsError,
    int? sportId,
  }) {
    return BetDetailMobileV2State(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      eventData: eventData ?? this.eventData,
      leagueData: leagueData ?? this.leagueData,
      drawers: drawers ?? this.drawers,
      currentFilter: currentFilter ?? this.currentFilter,
      allExpanded: allExpanded ?? this.allExpanded,
      oddsChanges: oddsChanges ?? this.oddsChanges,
      isLoadingFullMarkets: isLoadingFullMarkets ?? this.isLoadingFullMarkets,
      hasFullMarkets: hasFullMarkets ?? this.hasFullMarkets,
      fullMarketsError: fullMarketsError,
      sportId: sportId ?? this.sportId,
    );
  }
}

/// Odds Change Info V2
class OddsChangeInfoV2 {
  final double previousValue;
  final double currentValue;
  final OddsChangeDirectionV2 direction;
  final DateTime changeTime;

  const OddsChangeInfoV2({
    required this.previousValue,
    required this.currentValue,
    required this.direction,
    required this.changeTime,
  });
}

/// Odds Change Direction V2
enum OddsChangeDirectionV2 { up, down, none }

/// Bet Detail Mobile V2 Notifier
///
/// Manages bet detail screen state for mobile with new V2 design.
/// Each market type is a separate expandable card.
class BetDetailMobileV2Notifier extends StateNotifier<BetDetailMobileV2State> {
  final Ref _ref;
  StreamSubscription<socket.OddsUpdateData>? _oddsSubscription;
  StreamSubscription<socket.EventStatusData>? _eventUpdateSubscription;
  Timer? _cleanupTimer;
  int? _currentEventId;
  int _currentSet = 1;
  CancelToken? _fullMarketsCancelToken;

  BetDetailMobileV2Notifier(this._ref) : super(const BetDetailMobileV2State());

  /// Initialize with event and league data
  ///
  /// Step 1: Show partial data immediately (main markets from league API)
  /// Step 2: Subscribe to WebSocket for live updates
  /// Step 3: Fetch full markets from API v2 in background
  void init({
    required LeagueEventData eventData,
    required LeagueData leagueData,
    int sportId = 1,
    int currentSet = 1,
  }) {
    // Guard: Skip if already initialized for this event
    if (_currentEventId == eventData.eventId && state.eventData != null) {
      // ignore: avoid_print
      print(
        '[BetDetailMobileV2Provider] Already initialized for event ${eventData.eventId}, skipping',
      );
      return;
    }

    // ignore: avoid_print
    print(
      '[BetDetailMobileV2Provider] init() called for event ${eventData.eventId}',
    );
    // ignore: avoid_print
    print(
      '[BetDetailMobileV2Provider] Partial markets count: ${eventData.markets.length}',
    );

    // Step 1: Build drawers with partial data (main markets)
    final drawers = MarketDrawerV2Builder.buildDrawers(
      eventData.markets,
      sportId: sportId,
      currentSet: currentSet,
    );
    _currentEventId = eventData.eventId;
    _currentSet = currentSet;

    state = state.copyWith(
      eventData: eventData,
      leagueData: leagueData,
      drawers: drawers,
      isLoading: false,
      isLoadingFullMarkets: true,
      hasFullMarkets: false,
      error: null,
      sportId: sportId,
      currentFilter: MarketFilter.main,
    );

    // Step 2: Subscribe to WebSocket updates
    _subscribeToOddsUpdates(eventData.eventId);
    _subscribeToEventUpdates(eventData.eventId);
    _startCleanupTimer();

    // Step 3: Fetch full markets from API v2
    // ignore: avoid_print
    print(
      '[BetDetailMobileV2Provider] Starting _loadFullMarkets for event ${eventData.eventId}',
    );
    _loadFullMarkets(eventData.eventId);
  }

  /// Load full markets from API v2
  ///
  /// Fetches complete markets including child events (Corner, Extra Time, Penalty).
  /// Merges with existing data while preserving live stats from WebSocket.
  Future<void> _loadFullMarkets(int eventId) async {
    // ignore: avoid_print
    print(
      '[BetDetailMobileV2Provider] _loadFullMarkets() START for event $eventId',
    );

    try {
      // Cancel any previous request
      _fullMarketsCancelToken?.cancel();
      _fullMarketsCancelToken = CancelToken();

      // ignore: avoid_print
      print(
        '[BetDetailMobileV2Provider] Calling API getEventDetailWithCancel...',
      );

      final dataSource = _ref.read(eventDetailV2RemoteDataSourceProvider);
      final response = await dataSource.getEventDetailWithCancel(
        eventId,
        _fullMarketsCancelToken!,
      );

      // ignore: avoid_print
      print(
        '[BetDetailMobileV2Provider] API response received: ${response.markets.length} markets, ${response.children.length} children',
      );

      // Convert to legacy format for compatibility with existing widgets
      final fullEventData = response.toLeagueEventData();

      // Merge: keep live stats from socket, use markets from API
      // DO NOT overwrite gamePart, gameTime, score - keep from socket updates
      // DO update eventStatsId from detail response (list API may not include it)
      final currentEventData = state.eventData;
      final mergedEventData =
          currentEventData?.copyWith(
            markets: fullEventData.markets,
            totalMarketsCount: fullEventData.totalMarketsCount,
            // Update eventStatsId from detail response if current is 0
            eventStatsId: currentEventData.eventStatsId > 0
                ? currentEventData.eventStatsId
                : fullEventData.eventStatsId,
          ) ??
          fullEventData;

      // Rebuild drawers with full markets
      final fullDrawers = MarketDrawerV2Builder.buildDrawers(
        mergedEventData.markets,
        sportId: state.sportId,
        currentSet: _currentSet,
      );

      state = state.copyWith(
        eventData: mergedEventData,
        drawers: fullDrawers,
        isLoadingFullMarkets: false,
        hasFullMarkets: true,
        fullMarketsError: null,
      );

      // ignore: avoid_print
      print(
        '[BetDetailMobileV2Provider] Full markets loaded: ${fullEventData.markets.length} markets',
      );
    } on CancelledException {
      // Ignore cancelled requests
      // ignore: avoid_print
      print('[BetDetailMobileV2Provider] Full markets request cancelled');
      return;
    } on ApiException catch (e) {
      // Handle API errors (timeout, network, server errors)
      state = state.copyWith(
        isLoadingFullMarkets: false,
        fullMarketsError: e.message,
      );

      // ignore: avoid_print
      print('[BetDetailMobileV2Provider] API error loading full markets: $e');
    } on DioException catch (e) {
      // Handle raw Dio errors (shouldn't happen normally, datasource converts these)
      if (e.type == DioExceptionType.cancel) {
        // ignore: avoid_print
        print(
          '[BetDetailMobileV2Provider] Full markets request cancelled (DioException)',
        );
        return;
      }

      state = state.copyWith(
        isLoadingFullMarkets: false,
        fullMarketsError: e.message ?? 'Failed to load full markets',
      );

      // ignore: avoid_print
      print(
        '[BetDetailMobileV2Provider] DioException loading full markets: $e',
      );
    } catch (e) {
      // Handle parsing or other errors
      state = state.copyWith(
        isLoadingFullMarkets: false,
        fullMarketsError: 'Failed to load full markets: $e',
      );

      // ignore: avoid_print
      print(
        '[BetDetailMobileV2Provider] Unknown error loading full markets: $e',
      );
    }
  }

  /// Change current filter
  void changeFilter(MarketFilter filter) {
    if (state.currentFilter != filter) {
      state = state.copyWith(currentFilter: filter);
    }
  }

  /// Toggle all drawers expand/collapse
  void toggleAllExpanded() {
    final newExpanded = !state.allExpanded;
    final updatedDrawers = state.drawers
        .map((d) => d.copyWith(isExpanded: newExpanded))
        .toList();
    state = state.copyWith(allExpanded: newExpanded, drawers: updatedDrawers);
  }

  /// Toggle single drawer expand/collapse by filtered index
  ///
  /// [filteredIndex] is the index in the current `filteredDrawers` list.
  /// This method maps it back to the correct index in the full `drawers` list.
  void toggleDrawer(int filteredIndex) {
    final filtered = state.filteredDrawers;
    if (filteredIndex < 0 || filteredIndex >= filtered.length) return;

    final targetDrawer = filtered[filteredIndex];
    final actualIndex = state.drawers.indexOf(targetDrawer);
    if (actualIndex == -1) return;

    final updatedDrawers = List<MarketDrawerDataV2>.from(state.drawers);
    updatedDrawers[actualIndex] = updatedDrawers[actualIndex].copyWith(
      isExpanded: !updatedDrawers[actualIndex].isExpanded,
    );
    state = state.copyWith(drawers: updatedDrawers);
  }

  /// Subscribe to library odds updates stream
  void _subscribeToOddsUpdates(int eventId) {
    _oddsSubscription?.cancel();
    _currentEventId = eventId;

    try {
      final adapter = _ref.read(sportSocketAdapterProvider);

      // Subscribe to ALL odds updates (not just direction changes)
      _oddsSubscription = adapter.onOddsUpdate.listen((data) {
        if (data.eventId == eventId) {
          _handleOddsUpdate(data);
        }
      });

      // if (kDebugMode) {
      //   debugPrint('[BetDetailMobileV2Provider] Subscribed to odds updates for event $eventId');
      // }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileV2Provider] Error subscribing to odds updates: $e',
        );
      }
    }
  }

  /// Subscribe to library event status updates stream
  void _subscribeToEventUpdates(int eventId) {
    _eventUpdateSubscription?.cancel();

    try {
      final adapter = _ref.read(sportSocketAdapterProvider);

      _eventUpdateSubscription = adapter.onEventStatusUpdate.listen((data) {
        if (data.eventId == eventId) {
          _handleEventStatusUpdate(data);
        }
      });

      // if (kDebugMode) {
      //   debugPrint('[BetDetailMobileV2Provider] Subscribed to event updates for event $eventId');
      // }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileV2Provider] Error subscribing to event updates: $e',
        );
      }
    }
  }

  /// Handle event status update from library stream
  void _handleEventStatusUpdate(socket.EventStatusData data) {
    final eventData = state.eventData;
    if (eventData == null) return;
    if (data.eventId != eventData.eventId) return;

    // Convert gameTime from milliseconds to the format used by LeagueEventData
    final gameTimeMinutes = data.gameTime != null
        ? (data.gameTime! ~/ 60000)
        : eventData.gameTime;

    final updatedEventData = eventData.copyWith(
      gameTime: gameTimeMinutes,
      gamePart: data.gamePart ?? eventData.gamePart,
      stoppageTime: data.stoppageTime ?? eventData.stoppageTime,
      homeScore: data.homeScore ?? eventData.homeScore,
      awayScore: data.awayScore ?? eventData.awayScore,
      isLive: data.isLive ?? eventData.isLive,
      yellowCardsHome: data.yellowCardsHome ?? eventData.yellowCardsHome,
      yellowCardsAway: data.yellowCardsAway ?? eventData.yellowCardsAway,
      redCardsHome: data.redCardsHome ?? eventData.redCardsHome,
      redCardsAway: data.redCardsAway ?? eventData.redCardsAway,
      cornersHome: data.cornersHome ?? eventData.cornersHome,
      cornersAway: data.cornersAway ?? eventData.cornersAway,
      isSuspended: data.isSuspended,
      isLivestream: data.isLivestream ?? eventData.isLivestream,
      eventStatus: data.eventStatus ?? eventData.eventStatus,
    );

    state = state.copyWith(eventData: updatedEventData);

    // Badminton: gamePart thay đổi → market list thay đổi (704 biến mất, labels đổi)
    // Cần reload full markets từ API để có market list mới
    if (state.sportId == 7 &&
        data.gamePart != null &&
        data.gamePart != eventData.gamePart) {
      _loadFullMarkets(eventData.eventId);
    }
  }

  /// Handle odds update from library stream
  void _handleOddsUpdate(socket.OddsUpdateData update) {
    final eventData = state.eventData;
    if (eventData == null) return;
    if (update.eventId != eventData.eventId) return;

    final updatedDrawers = _updateOddsInDrawers(state.drawers, update);

    if (updatedDrawers != null) {
      final newOddsChanges = Map<String, OddsChangeInfoV2>.from(
        state.oddsChanges,
      );
      final odds = update.odds;

      // Track direction changes for home selection
      if (odds.selectionIdHome != null &&
          odds.homeDirection != socket.OddsDirection.none &&
          odds.oddsHome != null &&
          odds.previousHome != null) {
        newOddsChanges[odds.selectionIdHome!] = OddsChangeInfoV2(
          previousValue: odds.previousHome!,
          currentValue: odds.oddsHome!,
          direction: _mapDirection(odds.homeDirection),
          changeTime: DateTime.now(),
        );
      }

      // Track direction changes for away selection
      if (odds.selectionIdAway != null &&
          odds.awayDirection != socket.OddsDirection.none &&
          odds.oddsAway != null &&
          odds.previousAway != null) {
        newOddsChanges[odds.selectionIdAway!] = OddsChangeInfoV2(
          previousValue: odds.previousAway!,
          currentValue: odds.oddsAway!,
          direction: _mapDirection(odds.awayDirection),
          changeTime: DateTime.now(),
        );
      }

      // Track direction changes for draw selection
      if (odds.selectionIdDraw != null &&
          odds.drawDirection != socket.OddsDirection.none &&
          odds.oddsDraw != null &&
          odds.previousDraw != null) {
        newOddsChanges[odds.selectionIdDraw!] = OddsChangeInfoV2(
          previousValue: odds.previousDraw!,
          currentValue: odds.oddsDraw!,
          direction: _mapDirection(odds.drawDirection),
          changeTime: DateTime.now(),
        );
      }

      state = state.copyWith(
        drawers: updatedDrawers,
        oddsChanges: newOddsChanges,
      );
    }
  }

  /// Map library OddsDirection to local OddsChangeDirectionV2
  OddsChangeDirectionV2 _mapDirection(socket.OddsDirection direction) {
    switch (direction) {
      case socket.OddsDirection.up:
        return OddsChangeDirectionV2.up;
      case socket.OddsDirection.down:
        return OddsChangeDirectionV2.down;
      case socket.OddsDirection.none:
        return OddsChangeDirectionV2.none;
    }
  }

  /// Update odds in drawers from library OddsUpdateData
  List<MarketDrawerDataV2>? _updateOddsInDrawers(
    List<MarketDrawerDataV2> drawers,
    socket.OddsUpdateData update,
  ) {
    final marketId = update.marketId;
    final odds = update.odds;
    bool updated = false;

    final updatedDrawers = drawers.map((drawer) {
      // Update single market
      if (drawer.market != null && drawer.market!.marketId == marketId) {
        final updatedOdds = drawer.market!.odds.map((drawerOdds) {
          if (drawerOdds.offerId == update.offerId) {
            updated = true;
            return _updateOddsDataFromLibrary(drawerOdds, odds);
          }
          return drawerOdds;
        }).toList();

        return drawer.copyWith(
          market: LeagueMarketData(
            marketId: drawer.market!.marketId,
            marketName: drawer.market!.marketName,
            marketType: drawer.market!.marketType,
            isParlay: drawer.market!.isParlay,
            odds: updatedOdds,
          ),
        );
      }

      // Update multiple markets (for Clean Sheet, etc.)
      if (drawer.markets.isNotEmpty) {
        final updatedMarkets = drawer.markets.map((market) {
          if (market.marketId != marketId) return market;

          final updatedOdds = market.odds.map((drawerOdds) {
            if (drawerOdds.offerId == update.offerId) {
              updated = true;
              return _updateOddsDataFromLibrary(drawerOdds, odds);
            }
            return drawerOdds;
          }).toList();

          return LeagueMarketData(
            marketId: market.marketId,
            marketName: market.marketName,
            marketType: market.marketType,
            isParlay: market.isParlay,
            odds: updatedOdds,
          );
        }).toList();

        return drawer.copyWith(markets: updatedMarkets);
      }

      return drawer;
    }).toList();

    return updated ? updatedDrawers : null;
  }

  /// Update LeagueOddsData with values from library OddsData
  LeagueOddsData _updateOddsDataFromLibrary(
    LeagueOddsData drawerOdds,
    socket.OddsData libraryOdds,
  ) {
    // Convert library odds to OddsValue (parse String? to double)
    OddsValue? createOddsValue(
      double? decimal,
      String? malay,
      String? indo,
      String? hk,
    ) {
      if (decimal == null) return null;
      return OddsValue(
        decimal: decimal,
        malay: double.tryParse(malay ?? '') ?? 0,
        indo: double.tryParse(indo ?? '') ?? 0,
        hongKong: double.tryParse(hk ?? '') ?? 0,
      );
    }

    return LeagueOddsData(
      points: drawerOdds.points,
      isMainLine: drawerOdds.isMainLine,
      selectionHomeId: drawerOdds.selectionHomeId,
      selectionAwayId: drawerOdds.selectionAwayId,
      selectionDrawId: drawerOdds.selectionDrawId,
      offerId: drawerOdds.offerId,
      oddsHome:
          createOddsValue(
            libraryOdds.oddsHome,
            libraryOdds.malayHome,
            libraryOdds.indoHome,
            libraryOdds.hkHome,
          ) ??
          drawerOdds.oddsHome,
      oddsAway:
          createOddsValue(
            libraryOdds.oddsAway,
            libraryOdds.malayAway,
            libraryOdds.indoAway,
            libraryOdds.hkAway,
          ) ??
          drawerOdds.oddsAway,
      oddsDraw: libraryOdds.oddsDraw != null
          ? OddsValue(
              decimal: libraryOdds.oddsDraw!,
              malay: 0,
              indo: 0,
              hongKong: 0,
            )
          : drawerOdds.oddsDraw,
    );
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final expiredKeys = state.oddsChanges.entries
          .where((e) => now.difference(e.value.changeTime).inSeconds >= 5)
          .map((e) => e.key)
          .toList();

      if (expiredKeys.isNotEmpty) {
        final newChanges = Map<String, OddsChangeInfoV2>.from(
          state.oddsChanges,
        );
        for (final key in expiredKeys) {
          newChanges.remove(key);
        }
        state = state.copyWith(oddsChanges: newChanges);
      }
    });
  }

  /// Clear state when leaving screen
  void clear() {
    _oddsSubscription?.cancel();
    _eventUpdateSubscription?.cancel();
    _cleanupTimer?.cancel();
    _fullMarketsCancelToken?.cancel();
    _currentEventId = null;

    // Note: Library manages subscriptions per sport, not per event
    // No need to unsubscribe individual events

    state = const BetDetailMobileV2State();
  }

  @override
  void dispose() {
    _oddsSubscription?.cancel();
    _eventUpdateSubscription?.cancel();
    _cleanupTimer?.cancel();
    _fullMarketsCancelToken?.cancel();
    super.dispose();
  }
}

/// Bet Detail Mobile V2 Provider
final betDetailMobileV2Provider =
    StateNotifierProvider<BetDetailMobileV2Notifier, BetDetailMobileV2State>((
      ref,
    ) {
      return BetDetailMobileV2Notifier(ref);
    });
