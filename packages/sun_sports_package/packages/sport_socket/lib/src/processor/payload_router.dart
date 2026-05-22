import '../proto/proto.dart';
import '../data/sport_data_store.dart';
import '../data/models/odds_data.dart';
import '../data/models/odds_change_data.dart';
import '../utils/logger.dart';

/// Callback for score updates
typedef ProtoScoreCallback = void Function(
    int eventId, int sportId, ScoreResponse score);

/// Callback for event status updates
typedef ProtoEventStatusCallback = void Function(
    int eventId, EventResponse event);

/// Callback for odds changes (direction up/down)
typedef ProtoOddsChangeCallback = void Function(OddsChangeData data);

/// Routes Payload messages to appropriate handlers based on channel and type.
///
/// V2 Routing Logic:
/// - Channel pattern determines the data type (league, match, hot, outright)
/// - Message type determines the action (i=insert, u=update, r=remove)
///
/// Channel Patterns:
/// - `ln:{lang}:s:{sportId}:l` → League channel
/// - `ln:{lang}:s:{sportId}:tr:{timeRange}:e` → Match channel
/// - `ln:{lang}:s:{sportId}:e:hot` → Hot matches channel
/// - `ln:{lang}:s:{sportId}:e:ort` → Outright channel
/// - `ln:{lang}:e:{eventId}` → Match detail channel
class PayloadRouter {
  final Logger _logger;

  /// Subscribed time ranges (for filtering league inserts)
  final Set<int> _subscribedTimeRanges = {};

  /// Callbacks
  ProtoScoreCallback? onScoreUpdate;
  ProtoEventStatusCallback? onEventStatusUpdate;
  ProtoOddsChangeCallback? onOddsChange;

  PayloadRouter({
    Logger? logger,
  }) : _logger = logger ?? const NoOpLogger();

  /// Subscribe to a time range
  void subscribeTimeRange(int timeRange) {
    _subscribedTimeRanges.add(timeRange);
    _logger.debug('Subscribed to timeRange: $timeRange');
  }

  /// Unsubscribe from a time range
  void unsubscribeTimeRange(int timeRange) {
    _subscribedTimeRanges.remove(timeRange);
    _logger.debug('Unsubscribed from timeRange: $timeRange');
  }

  /// Clear all time range subscriptions
  void clearTimeRangeSubscriptions() {
    _subscribedTimeRanges.clear();
  }

  /// Route a single payload to the appropriate handler
  void route(Payload payload, SportDataStore store) {
    final channel = payload.channel;
    final type = payload.type;

    // ═══════════════════════════════════════════════════════════════════════════
    // DEBUG: Print decoded protobuf message
    // ═══════════════════════════════════════════════════════════════════════════
    _debugPrintDecodedPayload(payload);

    try {
      if (_isLeagueChannel(channel)) {
        _handleLeaguePayload(payload, type, store);
      } else if (_isHotChannel(channel)) {
        _handleHotPayload(payload, type, store);
      } else if (_isOutrightChannel(channel)) {
        _handleOutrightPayload(payload, type, store);
      } else if (_isMatchChannel(channel) || _isMatchDetailChannel(channel)) {
        _handleMatchPayload(payload, type, store);
      } else {
        _logger.debug('Unknown channel pattern: $channel');
      }
    } catch (e, stackTrace) {
      _logger.error('PayloadRouter error for channel $channel', e, stackTrace);
    }
  }

  /// Route a batch of payloads
  void routeBatch(List<Payload> payloads, SportDataStore store) {
    for (final payload in payloads) {
      route(payload, store);
    }
    // Emit batch changes after all payloads processed
    store.emitBatchChanges();
  }

  // ===== CHANNEL PATTERN DETECTION =====

  /// Check if channel is a league channel: ln:{lang}:s:{sportId}:l
  bool _isLeagueChannel(String channel) {
    // Pattern: ends with :l and contains :s:
    return channel.endsWith(':l') && channel.contains(':s:');
  }

  /// Check if channel is a match channel: ln:{lang}:s:{sportId}:tr:{timeRange}:e
  bool _isMatchChannel(String channel) {
    // Pattern: ends with :e and contains :tr:
    return channel.endsWith(':e') && channel.contains(':tr:');
  }

  /// Check if channel is a match detail channel: ln:{lang}:e:{eventId}
  bool _isMatchDetailChannel(String channel) {
    // Pattern: contains :e: followed by digits only
    final parts = channel.split(':');
    if (parts.length < 3) return false;
    final eIndex = parts.indexOf('e');
    if (eIndex < 0 || eIndex >= parts.length - 1) return false;
    return int.tryParse(parts[eIndex + 1]) != null;
  }

  /// Check if channel is a hot matches channel: ln:{lang}:s:{sportId}:e:hot
  bool _isHotChannel(String channel) {
    return channel.endsWith(':e:hot');
  }

  /// Check if channel is an outright channel: ln:{lang}:s:{sportId}:e:ort
  bool _isOutrightChannel(String channel) {
    return channel.endsWith(':e:ort');
  }

  // ===== PAYLOAD HANDLERS =====

  /// Handle league channel payload
  void _handleLeaguePayload(Payload p, String type, SportDataStore store) {
    if (!p.hasLeague()) {
      _logger.debug('League payload missing league data');
      return;
    }

    final league = p.league;

    switch (type) {
      case 'i': // New league (before event insert)
        // IMPORTANT: Filter by subscribed timeRange
        if (_subscribedTimeRanges.isNotEmpty &&
            !_subscribedTimeRanges.contains(p.timeRange)) {
          _logger.debug(
            'Ignoring league insert for timeRange ${p.timeRange} '
            '(subscribed: $_subscribedTimeRanges)',
          );
          return;
        }
        store.upsertLeagueFromProto(league, timeRange: p.timeRange);
        _logger.debug('League inserted: ${league.leagueId}');

      case 'u': // League update (name, logo, etc.)
        store.updateLeagueFromProto(league);
        _logger.debug('League updated: ${league.leagueId}');

      case 'r': // League remove
        store.removeLeague(league.leagueId);
        _logger.debug('League removed: ${league.leagueId}');
    }
  }

  /// Handle match channel payload
  void _handleMatchPayload(Payload p, String type, SportDataStore store) {
    if (!p.hasEvent()) {
      _logger.debug('Match payload missing event data');
      return;
    }

    final event = p.event;
    final eventId = event.eventId.toInt();

    switch (type) {
      case 'i': // Event insert (V2 may use 'i' for insert)
      case 'u': // Event insert or update
        final isNew = !store.hasEvent(eventId);
        store.upsertEventFromProto(event);

        // Parse nested markets and odds
        _parseMarketsAndOdds(event, store);

        if (isNew) {
          _logger.debug('Event inserted: $eventId');
        }

        // Emit event status callback
        onEventStatusUpdate?.call(eventId, event);

        // Emit score update if live score present
        if (event.hasLiveScore()) {
          final sportId = event.sportId;
          onScoreUpdate?.call(eventId, sportId, event.liveScore);
        }

      case 'r': // Event remove
        store.removeEvent(eventId);
        _logger.debug('Event removed: $eventId');
    }
  }

  /// Handle hot matches channel payload
  void _handleHotPayload(Payload p, String type, SportDataStore store) {
    if (!p.hasHotEvent()) {
      _logger.debug('Hot payload missing hotEvent data');
      return;
    }

    final hotEvents = p.hotEvent;

    // HotEventsResponse contains a list of HotEventResponse
    for (final hotEvent in hotEvents.events) {
      // Ensure league exists (HotEventResponse includes league info)
      store.ensureLeague(
        leagueId: hotEvent.leagueId,
        leagueName: hotEvent.leagueName,
        leagueOrder: hotEvent.leagueOrder,
        leaguePriorityOrder: hotEvent.leaguePriorityOrder,
        leagueLogo: hotEvent.leagueLogo,
      );

      // Upsert the event
      if (hotEvent.hasEvent()) {
        store.upsertEventFromProto(hotEvent.event);
        _parseMarketsAndOdds(hotEvent.event, store);
      }
    }

    _logger.debug('Hot events processed: ${hotEvents.events.length}');
  }

  /// Handle outright channel payload
  void _handleOutrightPayload(Payload p, String type, SportDataStore store) {
    // if (!p.hasOutright()) {
    //   _logger.debug('Outright payload missing outright data');
    //   return;
    // }

    // final outright = p.outright;

    // switch (type) {
    //   case 'i':
    //   case 'u':
    //     store.upsertOutrightEventFromProto(outright);
    //     _logger.debug('Outright event upserted: ${outright.eventId}');

    //   case 'r':
    //     store.removeOutrightEvent(outright.eventId.toInt());
    //     _logger.debug('Outright event removed: ${outright.eventId}');
    // }
  }

  /// Parse nested markets and odds from EventResponse
  void _parseMarketsAndOdds(EventResponse event, SportDataStore store) {
    final eventId = event.eventId.toInt();

    for (final market in event.markets) {
      final marketId = market.marketId;
      store.upsertMarketFromProto(eventId, market);

      for (final oddsProto in market.oddsList) {
        final offerId = oddsProto.strOfferId.isNotEmpty
            ? oddsProto.strOfferId
            : '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

        // Capture previous values BEFORE update
        final existingOdds = store.getOdds(eventId, marketId, offerId);
        final previousHome = existingOdds?.oddsHome;
        final previousAway = existingOdds?.oddsAway;
        final previousDraw = existingOdds?.oddsDraw;

        // Update store
        store.upsertOddsFromProto(eventId, marketId, oddsProto);

        // Emit change events if callback is set and odds existed before
        if (onOddsChange != null && existingOdds != null) {
          final updatedOdds = store.getOdds(eventId, marketId, offerId);
          if (updatedOdds != null) {
            _emitOddsChanges(
              eventId: eventId,
              marketId: marketId,
              offerId: offerId,
              previousHome: previousHome,
              previousAway: previousAway,
              previousDraw: previousDraw,
              currentOdds: updatedOdds,
              oddsProto: oddsProto,
            );
          }
        }
      }
    }

    // Handle child events (for special event types)
    for (final child in event.children) {
      store.upsertEventFromProto(child);
      _parseMarketsAndOdds(child, store);
    }
  }

  /// Emit OddsChangeData for selections that changed
  void _emitOddsChanges({
    required int eventId,
    required int marketId,
    required String offerId,
    double? previousHome,
    double? previousAway,
    double? previousDraw,
    required OddsData currentOdds,
    required OddsResponse oddsProto,
  }) {
    final timestamp = DateTime.now();

    // Check home odds change
    if (previousHome != null &&
        currentOdds.oddsHome != null &&
        previousHome != currentOdds.oddsHome &&
        currentOdds.selectionIdHome != null &&
        currentOdds.selectionIdHome!.isNotEmpty) {
      final direction = currentOdds.oddsHome! > previousHome
          ? OddsDirection.up
          : OddsDirection.down;

      onOddsChange?.call(OddsChangeData(
        eventId: eventId,
        marketId: marketId,
        offerId: offerId,
        selectionId: currentOdds.selectionIdHome!,
        selectionType: 'home',
        previousValue: previousHome,
        currentValue: currentOdds.oddsHome!,
        direction: direction,
        styleValues: OddsStyleValues(
          decimal: currentOdds.oddsHome!,
          malay: oddsProto.oddsHome.malay,
          indo: oddsProto.oddsHome.indo,
          hk: oddsProto.oddsHome.hk,
        ),
        timestamp: timestamp,
      ));
    }

    // Check away odds change
    if (previousAway != null &&
        currentOdds.oddsAway != null &&
        previousAway != currentOdds.oddsAway &&
        currentOdds.selectionIdAway != null &&
        currentOdds.selectionIdAway!.isNotEmpty) {
      final direction = currentOdds.oddsAway! > previousAway
          ? OddsDirection.up
          : OddsDirection.down;

      onOddsChange?.call(OddsChangeData(
        eventId: eventId,
        marketId: marketId,
        offerId: offerId,
        selectionId: currentOdds.selectionIdAway!,
        selectionType: 'away',
        previousValue: previousAway,
        currentValue: currentOdds.oddsAway!,
        direction: direction,
        styleValues: OddsStyleValues(
          decimal: currentOdds.oddsAway!,
          malay: oddsProto.oddsAway.malay,
          indo: oddsProto.oddsAway.indo,
          hk: oddsProto.oddsAway.hk,
        ),
        timestamp: timestamp,
      ));
    }

    // Check draw odds change
    if (previousDraw != null &&
        currentOdds.oddsDraw != null &&
        previousDraw != currentOdds.oddsDraw &&
        currentOdds.selectionIdDraw != null &&
        currentOdds.selectionIdDraw!.isNotEmpty) {
      final direction = currentOdds.oddsDraw! > previousDraw
          ? OddsDirection.up
          : OddsDirection.down;

      onOddsChange?.call(OddsChangeData(
        eventId: eventId,
        marketId: marketId,
        offerId: offerId,
        selectionId: currentOdds.selectionIdDraw!,
        selectionType: 'draw',
        previousValue: previousDraw,
        currentValue: currentOdds.oddsDraw!,
        direction: direction,
        styleValues: OddsStyleValues(
          decimal: currentOdds.oddsDraw!,
          malay: null,
          indo: null,
          hk: null,
        ),
        timestamp: timestamp,
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBUG: Print decoded protobuf message for visualization
  // ═══════════════════════════════════════════════════════════════════════════
  void _debugPrintDecodedPayload(Payload payload) {
    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln('╔══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ 🔓 DECODED PROTOBUF MESSAGE');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ Channel: ${payload.channel}');
    // buffer.writeln('║ Type: ${payload.type} (${_typeDescription(payload.type)})');
    // buffer.writeln('║ TimeRange: ${payload.timeRange}');

    // if (payload.hasLeague()) {
    //   final l = payload.league;
    //   buffer.writeln('╠══════════════════════════════════════════════════════════════');
    //   buffer.writeln('║ 📋 LEAGUE DATA:');
    //   buffer.writeln('║   leagueId: ${l.leagueId}');
    //   buffer.writeln('║   leagueName: ${l.leagueName}');
    //   buffer.writeln('║   sportId: ${l.sportId}');
    //   buffer.writeln('║   leagueOrder: ${l.leagueOrder}');
    //   buffer.writeln('║   leaguePriorityOrder: ${l.leaguePriorityOrder}');
    //   buffer.writeln('║   leagueLogo: ${l.leagueLogo}');
    //   buffer.writeln('║   eventsCount: ${l.events.length}');
    // }

    // if (payload.hasEvent()) {
    //   final e = payload.event;
    //   buffer.writeln('╠══════════════════════════════════════════════════════════════');
    //   buffer.writeln('║ ⚽ EVENT DATA:');
    //   buffer.writeln('║   eventId: ${e.eventId}');
    //   buffer.writeln('║   leagueId: ${e.leagueId}');
    //   buffer.writeln('║   sportId: ${e.sportId}');
    //   buffer.writeln('║   homeName: ${e.homeName}');
    //   buffer.writeln('║   awayName: ${e.awayName}');
    //   buffer.writeln('║   isLive: ${e.isLive}');
    //   buffer.writeln('║   isSuspended: ${e.isSuspended}');
    //   buffer.writeln('║   startTime: ${e.startTime}');
    //   buffer.writeln('║   gamePart: ${e.gamePart}');
    //   buffer.writeln('║   gameTime: ${e.gameTime}');
    //   buffer.writeln('║   marketCount: ${e.marketCount}');

    //   if (e.hasLiveScore()) {
    //     final s = e.liveScore;
    //     buffer.writeln('║   📊 LiveScore:');
    //     // ScoreResponse is a union type (soccer/basketball/tennis/etc)
    //     if (s.hasSoccer()) {
    //       buffer.writeln('║      [Soccer] ${s.soccer.homeScore} - ${s.soccer.awayScore}');
    //       buffer.writeln('║      corners: ${s.soccer.homeCorner} - ${s.soccer.awayCorner}');
    //     } else if (s.hasBasketball()) {
    //       buffer.writeln('║      [Basketball] FT: ${s.basketball.homeScoreFT} - ${s.basketball.awayScoreFT}');
    //     } else if (s.hasTennis()) {
    //       buffer.writeln('║      [Tennis] sets: ${s.tennis.homeSetScore} - ${s.tennis.awaySetScore}');
    //     } else if (s.hasVolleyball()) {
    //       buffer.writeln('║      [Volleyball] sets: ${s.volleyball.homeSetScore} - ${s.volleyball.awaySetScore}');
    //     }
    //   }

    //   if (e.markets.isNotEmpty) {
    //     buffer.writeln('║   📈 Markets (${e.markets.length}):');
    //     for (final m in e.markets.take(3)) {
    //       buffer.writeln('║      - marketId: ${m.marketId}, groupId: ${m.groupId}, odds: ${m.oddsList.length}');
    //       for (final o in m.oddsList.take(3)) {
    //         buffer.writeln('║        └ strOfferId: ${o.strOfferId}, points: ${o.points}, suspended: ${o.isSuspended}');
    //         if (o.hasOddsHome()) {
    //           buffer.writeln('║          home: decimal=${o.oddsHome.decimal}, malay=${o.oddsHome.malay}');
    //         }
    //         if (o.hasOddsAway()) {
    //           buffer.writeln('║          away: decimal=${o.oddsAway.decimal}, malay=${o.oddsAway.malay}');
    //         }
    //         if (o.hasOddsDraw()) {
    //           buffer.writeln('║          draw: decimal=${o.oddsDraw.decimal}, malay=${o.oddsDraw.malay}');
    //         }
    //       }
    //       if (m.oddsList.length > 3) {
    //         buffer.writeln('║        └ ... +${m.oddsList.length - 3} more odds');
    //       }
    //     }
    //     if (e.markets.length > 3) {
    //       buffer.writeln('║      ... +${e.markets.length - 3} more markets');
    //     }
    //   }
    // }

    // if (payload.hasHotEvent()) {
    //   final h = payload.hotEvent;
    //   buffer.writeln('╠══════════════════════════════════════════════════════════════');
    //   buffer.writeln('║ 🔥 HOT EVENTS (${h.events.length}):');
    //   for (final he in h.events.take(3)) {
    //     buffer.writeln('║   - leagueId: ${he.leagueId}, leagueName: ${he.leagueName}');
    //     if (he.hasEvent()) {
    //       buffer.writeln('║     eventId: ${he.event.eventId}, ${he.event.homeName} vs ${he.event.awayName}');
    //     }
    //   }
    //   if (h.events.length > 3) {
    //     buffer.writeln('║   ... +${h.events.length - 3} more hot events');
    //   }
    // }

    // buffer.writeln('╚══════════════════════════════════════════════════════════════');
    // // ignore: avoid_print
    // print(buffer.toString());
  }

  String _typeDescription(String type) {
    switch (type) {
      case 'i':
        return 'INSERT';
      case 'u':
        return 'UPDATE';
      case 'r':
        return 'REMOVE';
      default:
        return 'UNKNOWN';
    }
  }
}
