import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_manager.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/websocket_enums.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_provider.dart';

/// Bet Detail Mobile Notifier
///
/// Manages bet detail screen state for mobile with 3-column layouts
/// Uses same state structure as desktop but builds drawers with isDesktop: false
class BetDetailMobileNotifier extends StateNotifier<BetDetailState> {
  // ignore: unused_field
  final Ref _ref;
  StreamSubscription<OddsUpdateData>? _oddsSubscription;
  StreamSubscription<WsMessage>? _eventUpdateSubscription;
  Timer? _cleanupTimer;

  BetDetailMobileNotifier(this._ref) : super(const BetDetailState());

  /// Initialize with event and league data
  void init({
    required LeagueEventData eventData,
    required LeagueData leagueData,
  }) {
    // Build drawers for mobile (3-column layouts, FT/HT separated)
    final drawers = MarketDrawerBuilder.buildDrawers(
      eventData.markets,
      isDesktop: false, // Mobile uses 3-column layouts
    );

    state = state.copyWith(
      eventData: eventData,
      leagueData: leagueData,
      drawers: drawers,
      isLoading: false,
      error: null,
    );

    // Subscribe to WebSocket updates
    _subscribeToOddsUpdates(eventData.eventId);
    _subscribeToEventUpdates(eventData.eventId);
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
      sbWebSocket.subscribeEvent(eventId);

      _oddsSubscription = sbWebSocket.oddsStream.listen((
        OddsUpdateData oddsUpdate,
      ) {
        _handleOddsUpdate(oddsUpdate);
      });

      if (kDebugMode) {
        // debugPrint('[BetDetailMobileProvider] Subscribed to event $eventId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileProvider] Error subscribing to WebSocket: $e',
        );
      }
    }
  }

  /// Subscribe to WebSocket event updates
  void _subscribeToEventUpdates(int eventId) {
    _eventUpdateSubscription?.cancel();

    try {
      final sbWebSocket = WebSocketManager.instance.sportbook;

      _eventUpdateSubscription = sbWebSocket.typedMessageStream.listen((
        WsMessage message,
      ) {
        if (message.type == WsMessageType.eventStatus) {
          _handleEventUpdate(message, eventId);
        }
      });

      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileProvider] Subscribed to event updates for event $eventId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[BetDetailMobileProvider] Error subscribing to event updates: $e',
        );
      }
    }
  }

  /// Handle event_up message from WebSocket
  void _handleEventUpdate(WsMessage message, int currentEventId) {
    final eventData = state.eventData;
    if (eventData == null) return;

    final data = message.data;
    final eventDataPayload = data['d'] as Map<String, dynamic>?;

    if (eventDataPayload == null) return;

    final eventId = (eventDataPayload['ei'] as num?)?.toInt() ?? 0;

    if (eventId == 0 ||
        eventId != currentEventId ||
        eventId != eventData.eventId)
      return;

    if (kDebugMode) {
      debugPrint(
        '[BetDetailMobileProvider] Event update received for event $eventId',
      );
    }

    final updatedEventData = eventData.copyWith(
      gameTime: (eventDataPayload['gt'] as num?)?.toInt() ?? eventData.gameTime,
      gamePart: (eventDataPayload['gp'] as num?)?.toInt() ?? eventData.gamePart,
      stoppageTime:
          (eventDataPayload['stm'] as num?)?.toInt() ?? eventData.stoppageTime,
      homeScore:
          (eventDataPayload['hs'] as num?)?.toInt() ?? eventData.homeScore,
      awayScore:
          (eventDataPayload['as'] as num?)?.toInt() ?? eventData.awayScore,
      isLive: eventDataPayload['l'] as bool? ?? eventData.isLive,
      yellowCardsHome:
          (eventDataPayload['ych'] as num?)?.toInt() ??
          eventData.yellowCardsHome,
      yellowCardsAway:
          (eventDataPayload['yca'] as num?)?.toInt() ??
          eventData.yellowCardsAway,
      redCardsHome:
          (eventDataPayload['rch'] as num?)?.toInt() ?? eventData.redCardsHome,
      redCardsAway:
          (eventDataPayload['rca'] as num?)?.toInt() ?? eventData.redCardsAway,
      cornersHome:
          (eventDataPayload['hc'] as num?)?.toInt() ?? eventData.cornersHome,
      cornersAway:
          (eventDataPayload['ac'] as num?)?.toInt() ?? eventData.cornersAway,
      isSuspended: eventDataPayload['s'] as bool? ?? eventData.isSuspended,
      isLivestream: eventDataPayload['ls'] as bool? ?? eventData.isLivestream,
      eventStatus: eventDataPayload['es'] as String? ?? eventData.eventStatus,
    );

    state = state.copyWith(eventData: updatedEventData);
  }

  /// Handle odds update from WebSocket
  void _handleOddsUpdate(OddsUpdateData oddsUpdate) {
    final eventData = state.eventData;
    if (eventData == null) return;

    if (oddsUpdate.eventId != eventData.eventId) return;

    if (kDebugMode) {
      debugPrint(
        '[BetDetailMobileProvider] Odds update: '
        'marketId=${oddsUpdate.marketId}, '
        'selectionId=${oddsUpdate.selectionId}, '
        'odds=${oddsUpdate.odds}',
      );
    }

    final updatedDrawers = _updateOddsInDrawers(state.drawers, oddsUpdate);

    if (updatedDrawers != null) {
      final newOddsChanges = Map<String, OddsChangeInfo>.from(
        state.oddsChanges,
      );
      final newValue = double.tryParse(oddsUpdate.odds) ?? 0;

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

  /// Update odds in drawers
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
          if (odds.selectionHomeId == oddsUpdate.selectionId) {
            updated = true;
            return _updateOddsData(odds, oddsUpdate, 'home');
          }
          if (odds.selectionAwayId == oddsUpdate.selectionId) {
            updated = true;
            return _updateOddsData(odds, oddsUpdate, 'away');
          }
          if (odds.selectionDrawId == oddsUpdate.selectionId) {
            updated = true;
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

    final oldAbs = oldValue >= 0 ? oldValue : 1 / -oldValue;
    final newAbs = newValue >= 0 ? newValue : 1 / -newValue;

    if (newAbs > oldAbs) return OddsChangeDirection.up;
    if (newAbs < oldAbs) return OddsChangeDirection.down;
    return OddsChangeDirection.none;
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

/// Bet Detail Mobile Provider
final betDetailMobileProvider =
    StateNotifierProvider<BetDetailMobileNotifier, BetDetailState>((ref) {
      return BetDetailMobileNotifier(ref);
    });
