import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_manager.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/websocket_enums.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data.dart';

/// Bet Detail State
///
/// Contains all state for the bet detail screen
class BetDetailState {
  /// Event data with markets
  final LeagueEventData? eventData;

  /// League data for header
  final LeagueData? leagueData;

  /// Current filter selection
  final MarketFilter currentFilter;

  /// Built market drawers
  final List<MarketDrawerData> drawers;

  /// Whether all drawers are expanded
  final bool allExpanded;

  /// Loading state
  final bool isLoading;

  /// Error message
  final String? error;

  /// Map to track odds changes: selectionId -> OddsChangeInfo
  final Map<String, OddsChangeInfo> oddsChanges;

  const BetDetailState({
    this.eventData,
    this.leagueData,
    this.currentFilter = MarketFilter.all,
    this.drawers = const [],
    this.allExpanded = true,
    this.isLoading = false,
    this.error,
    this.oddsChanges = const {},
  });

  /// Get filtered drawers based on current filter
  List<MarketDrawerData> get filteredDrawers {
    if (currentFilter == MarketFilter.all) {
      return drawers.where((d) => !d.isEmpty).toList();
    }
    return drawers
        .where((d) => d.filter == currentFilter && !d.isEmpty)
        .toList();
  }

  /// Check if filter has any markets
  bool hasMarketsForFilter(MarketFilter filter) {
    if (filter == MarketFilter.all) return drawers.any((d) => !d.isEmpty);
    return drawers.any((d) => d.filter == filter && !d.isEmpty);
  }

  /// Copy with new values
  BetDetailState copyWith({
    LeagueEventData? eventData,
    LeagueData? leagueData,
    MarketFilter? currentFilter,
    List<MarketDrawerData>? drawers,
    bool? allExpanded,
    bool? isLoading,
    String? error,
    Map<String, OddsChangeInfo>? oddsChanges,
  }) {
    return BetDetailState(
      eventData: eventData ?? this.eventData,
      leagueData: leagueData ?? this.leagueData,
      currentFilter: currentFilter ?? this.currentFilter,
      drawers: drawers ?? this.drawers,
      allExpanded: allExpanded ?? this.allExpanded,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      oddsChanges: oddsChanges ?? this.oddsChanges,
    );
  }
}

/// Odds Change Direction
enum OddsChangeDirection { none, up, down }

/// Odds Change Info
///
/// Tracks odds changes for showing indicators
class OddsChangeInfo {
  final double previousValue;
  final double currentValue;
  final OddsChangeDirection direction;
  final DateTime changeTime;

  const OddsChangeInfo({
    required this.previousValue,
    required this.currentValue,
    required this.direction,
    required this.changeTime,
  });

  /// Check if change indicator should still be visible (5 seconds)
  bool get isVisible {
    return DateTime.now().difference(changeTime).inSeconds < 5;
  }
}

/// Bet Detail Notifier
///
/// Manages bet detail screen state and WebSocket updates
class BetDetailNotifier extends StateNotifier<BetDetailState> {
  // ignore: unused_field
  final Ref _ref; // Kept for future provider access
  StreamSubscription<OddsUpdateData>? _oddsSubscription;
  StreamSubscription<WsMessage>? _eventUpdateSubscription;
  Timer? _cleanupTimer;

  BetDetailNotifier(this._ref) : super(const BetDetailState());

  /// Initialize with event and league data
  void init({
    required LeagueEventData eventData,
    required LeagueData leagueData,
  }) {
    // Build drawers from event markets
    // Desktop uses 6-column layouts and merged drawers
    final drawers = MarketDrawerBuilder.buildDrawers(
      eventData.markets,
      isDesktop: true,
    );

    state = state.copyWith(
      eventData: eventData,
      leagueData: leagueData,
      drawers: drawers,
      isLoading: false,
      error: null,
    );

    // Subscribe to WebSocket odds updates
    _subscribeToOddsUpdates(eventData.eventId);

    // Subscribe to WebSocket event updates (for live match stats)
    _subscribeToEventUpdates(eventData.eventId);

    // Start cleanup timer for odds change indicators
    _startCleanupTimer();
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

  /// Toggle single drawer expand/collapse
  void toggleDrawer(int index) {
    if (index < 0 || index >= state.drawers.length) return;

    final updatedDrawers = List<MarketDrawerData>.from(state.drawers);
    updatedDrawers[index] = updatedDrawers[index].copyWith(
      isExpanded: !updatedDrawers[index].isExpanded,
    );
    state = state.copyWith(drawers: updatedDrawers);
  }

  /// Subscribe to WebSocket odds updates
  void _subscribeToOddsUpdates(int eventId) {
    _oddsSubscription?.cancel();

    try {
      final sbWebSocket = WebSocketManager.instance.sportbook;

      // Subscribe to event
      sbWebSocket.subscribeEvent(eventId);

      // Listen for odds updates
      _oddsSubscription = sbWebSocket.oddsStream.listen((
        OddsUpdateData oddsUpdate,
      ) {
        _handleOddsUpdate(oddsUpdate);
      });

      if (kDebugMode) {
        debugPrint('[BetDetailProvider] Subscribed to event $eventId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BetDetailProvider] Error subscribing to WebSocket: $e');
      }
    }
  }

  /// Subscribe to WebSocket event updates (event_up messages)
  ///
  /// According to FLUTTER_LIVE_MATCH_STATS_GUIDE.md:
  /// - event_up messages contain live match stats updates
  /// - Format: {"t":"event_up","d":{ei,gt,gp,hs,as,ych,yca,rch,rca,hc,ac,...}}
  void _subscribeToEventUpdates(int eventId) {
    _eventUpdateSubscription?.cancel();

    try {
      final sbWebSocket = WebSocketManager.instance.sportbook;

      // Listen for typed messages (including event_up)
      _eventUpdateSubscription = sbWebSocket.typedMessageStream.listen((
        WsMessage message,
      ) {
        // Only process event_up messages
        if (message.type == WsMessageType.eventStatus) {
          _handleEventUpdate(message, eventId);
        }
      });

      if (kDebugMode) {
        debugPrint(
          '[BetDetailProvider] Subscribed to event updates for event $eventId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailProvider] Error subscribing to event updates: $e',
        );
      }
    }
  }

  /// Handle event_up message from WebSocket
  ///
  /// Updates live match stats: gameTime, gamePart, scores, cards, corners
  void _handleEventUpdate(WsMessage message, int currentEventId) {
    final eventData = state.eventData;
    if (eventData == null) return;

    // Parse data from message
    // Format: {"t":"event_up","d":{ei,gt,gp,hs,as,ych,yca,rch,rca,hc,ac,...}}
    final data = message.data;
    final eventDataPayload = data['d'] as Map<String, dynamic>?;

    if (eventDataPayload == null) return;

    // Extract eventId from payload
    final eventId = (eventDataPayload['ei'] as num?)?.toInt() ?? 0;

    // Only process updates for current event
    if (eventId == 0 ||
        eventId != currentEventId ||
        eventId != eventData.eventId)
      return;

    if (kDebugMode) {
      debugPrint(
        '[BetDetailProvider] Event update received for event $eventId',
      );
    }

    // Parse and update event data with new stats
    // Only update fields that are present in the message
    final updatedEventData = eventData.copyWith(
      // Game time (milliseconds) and period
      gameTime: (eventDataPayload['gt'] as num?)?.toInt() ?? eventData.gameTime,
      gamePart: (eventDataPayload['gp'] as num?)?.toInt() ?? eventData.gamePart,
      // Stoppage time (milliseconds) - bù giờ
      stoppageTime:
          (eventDataPayload['stm'] as num?)?.toInt() ?? eventData.stoppageTime,

      // Scores
      homeScore:
          (eventDataPayload['hs'] as num?)?.toInt() ?? eventData.homeScore,
      awayScore:
          (eventDataPayload['as'] as num?)?.toInt() ?? eventData.awayScore,

      // Live status
      isLive: eventDataPayload['l'] as bool? ?? eventData.isLive,

      // Yellow cards
      yellowCardsHome:
          (eventDataPayload['ych'] as num?)?.toInt() ??
          eventData.yellowCardsHome,
      yellowCardsAway:
          (eventDataPayload['yca'] as num?)?.toInt() ??
          eventData.yellowCardsAway,

      // Red cards
      redCardsHome:
          (eventDataPayload['rch'] as num?)?.toInt() ?? eventData.redCardsHome,
      redCardsAway:
          (eventDataPayload['rca'] as num?)?.toInt() ?? eventData.redCardsAway,

      // Corners
      cornersHome:
          (eventDataPayload['hc'] as num?)?.toInt() ?? eventData.cornersHome,
      cornersAway:
          (eventDataPayload['ac'] as num?)?.toInt() ?? eventData.cornersAway,

      // Other fields that might be updated
      isSuspended: eventDataPayload['s'] as bool? ?? eventData.isSuspended,
      isLivestream: eventDataPayload['ls'] as bool? ?? eventData.isLivestream,
      eventStatus: eventDataPayload['es'] as String? ?? eventData.eventStatus,
    );

    // Update state with new event data
    state = state.copyWith(eventData: updatedEventData);

    if (kDebugMode) {
      debugPrint(
        '[BetDetailProvider] Event data updated: '
        'time=${updatedEventData.gameTime}, '
        'part=${updatedEventData.gamePart}, '
        'score=${updatedEventData.homeScore}-${updatedEventData.awayScore}, '
        'corners=${updatedEventData.cornersHome}-${updatedEventData.cornersAway}',
      );
    }
  }

  /// Handle odds update from WebSocket
  void _handleOddsUpdate(OddsUpdateData oddsUpdate) {
    final eventData = state.eventData;
    if (eventData == null) return;

    // Only process updates for current event
    if (oddsUpdate.eventId != eventData.eventId) return;

    if (kDebugMode) {
      debugPrint(
        '[BetDetailProvider] Odds update: '
        'marketId=${oddsUpdate.marketId}, '
        'selectionId=${oddsUpdate.selectionId}, '
        'odds=${oddsUpdate.odds}',
      );
    }

    // Find and update the odds in drawers
    final updatedDrawers = _updateOddsInDrawers(state.drawers, oddsUpdate);

    if (updatedDrawers != null) {
      // Track change direction
      final newOddsChanges = Map<String, OddsChangeInfo>.from(
        state.oddsChanges,
      );
      final newValue = double.tryParse(oddsUpdate.odds) ?? 0;

      // Calculate direction
      final existingChange = newOddsChanges[oddsUpdate.selectionId];
      final previousValue = existingChange?.currentValue ?? newValue;
      final direction = _calculateDirection(previousValue, newValue);

      if (direction != OddsChangeDirection.none) {
        newOddsChanges[oddsUpdate.selectionId] = OddsChangeInfo(
          previousValue: previousValue,
          currentValue: newValue,
          direction: direction,
          changeTime: DateTime.now(),
        );
      }

      state = state.copyWith(
        drawers: updatedDrawers,
        oddsChanges: newOddsChanges,
      );
    }
  }

  /// Update odds in drawers, returns null if no update made
  List<MarketDrawerData>? _updateOddsInDrawers(
    List<MarketDrawerData> drawers,
    OddsUpdateData oddsUpdate,
  ) {
    final marketIdInt = int.tryParse(oddsUpdate.marketId) ?? 0;
    bool updated = false;

    final updatedDrawers = drawers.map((drawer) {
      final updatedMarkets = drawer.markets.map((market) {
        if (market.marketId != marketIdInt) return market;

        final updatedOdds = market.odds.map((odds) {
          // Match by selection ID
          if (odds.selectionHomeId == oddsUpdate.selectionId) {
            updated = true;
            // Update home odds
            return _updateOddsData(odds, oddsUpdate, 'home');
          }
          if (odds.selectionAwayId == oddsUpdate.selectionId) {
            updated = true;
            // Update away odds
            return _updateOddsData(odds, oddsUpdate, 'away');
          }
          if (odds.selectionDrawId == oddsUpdate.selectionId) {
            updated = true;
            // Update draw odds
            return _updateOddsData(odds, oddsUpdate, 'draw');
          }
          return odds;
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
    }).toList();

    return updated ? updatedDrawers : null;
  }

  /// Update odds data with new values
  LeagueOddsData _updateOddsData(
    LeagueOddsData odds,
    OddsUpdateData update,
    String type,
  ) {
    final oddsValues = update.oddsValues;

    OddsValue newOddsValue(OddsStyleValues values) {
      return OddsValue(
        malay: values.malay,
        indo: values.indo,
        decimal: values.decimal,
        hongKong: values.hk,
      );
    }

    switch (type) {
      case 'home':
        return LeagueOddsData(
          points: odds.points,
          isMainLine: odds.isMainLine,
          selectionHomeId: odds.selectionHomeId,
          selectionAwayId: odds.selectionAwayId,
          selectionDrawId: odds.selectionDrawId,
          offerId: odds.offerId,
          oddsHome: newOddsValue(oddsValues),
          oddsAway: odds.oddsAway,
          oddsDraw: odds.oddsDraw,
        );
      case 'away':
        return LeagueOddsData(
          points: odds.points,
          isMainLine: odds.isMainLine,
          selectionHomeId: odds.selectionHomeId,
          selectionAwayId: odds.selectionAwayId,
          selectionDrawId: odds.selectionDrawId,
          offerId: odds.offerId,
          oddsHome: odds.oddsHome,
          oddsAway: newOddsValue(oddsValues),
          oddsDraw: odds.oddsDraw,
        );
      case 'draw':
        return LeagueOddsData(
          points: odds.points,
          isMainLine: odds.isMainLine,
          selectionHomeId: odds.selectionHomeId,
          selectionAwayId: odds.selectionAwayId,
          selectionDrawId: odds.selectionDrawId,
          offerId: odds.offerId,
          oddsHome: odds.oddsHome,
          oddsAway: odds.oddsAway,
          oddsDraw: newOddsValue(oddsValues),
        );
      default:
        return odds;
    }
  }

  /// Calculate change direction
  OddsChangeDirection _calculateDirection(double oldValue, double newValue) {
    if (oldValue <= 0 || newValue <= 0) return OddsChangeDirection.none;

    // Use absolute value for comparison (handle negative odds)
    final oldAbs = oldValue >= 0 ? oldValue : 1 / -oldValue;
    final newAbs = newValue >= 0 ? newValue : 1 / -newValue;

    if (newAbs > oldAbs) return OddsChangeDirection.up;
    if (newAbs < oldAbs) return OddsChangeDirection.down;
    return OddsChangeDirection.none;
  }

  /// Start timer to cleanup expired odds changes
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final expiredKeys = state.oddsChanges.entries
          .where((e) => now.difference(e.value.changeTime).inSeconds >= 5)
          .map((e) => e.key)
          .toList();

      if (expiredKeys.isNotEmpty) {
        final newChanges = Map<String, OddsChangeInfo>.from(state.oddsChanges);
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

    // Unsubscribe from event
    if (state.eventData != null) {
      try {
        WebSocketManager.instance.sportbook.unsubscribeEvent(
          state.eventData!.eventId,
        );
      } catch (_) {}
    }

    state = const BetDetailState();
  }

  @override
  void dispose() {
    _oddsSubscription?.cancel();
    _eventUpdateSubscription?.cancel();
    _cleanupTimer?.cancel();
    super.dispose();
  }
}

/// Bet Detail Provider
final betDetailProvider =
    StateNotifierProvider<BetDetailNotifier, BetDetailState>((ref) {
      return BetDetailNotifier(ref);
    });

/// Selected event provider - stores the event to show in detail
final selectedEventProvider = StateProvider<LeagueEventData?>((ref) => null);

/// Selected league provider - stores the league for the selected event
final selectedLeagueProvider = StateProvider<LeagueData?>((ref) => null);
