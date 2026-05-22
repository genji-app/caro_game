import 'sport_data_store.dart';
import 'models/score_update_data.dart';
import 'models/event_status_data.dart';
import 'models/balance_update_data.dart';
import 'models/market_status_data.dart';
import 'models/market_data.dart';
import 'models/odds_data.dart';
import 'models/odds_change_data.dart';
import 'models/odds_update_data.dart';
import '../processor/message_key.dart';
import '../processor/pending_queue.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// Callback for score updates
typedef ScoreUpdateCallback = void Function(ScoreUpdateData data);

/// Callback for event status updates
typedef EventStatusUpdateCallback = void Function(EventStatusData data);

/// Callback for balance updates
typedef BalanceUpdateCallback = void Function(BalanceUpdateData data);

/// Callback for market status changes
typedef MarketStatusCallback = void Function(MarketStatusData data);

/// Callback for odds changes (direction up/down)
typedef OddsChangeCallback = void Function(OddsChangeData data);

/// Callback for ALL odds updates (regardless of direction change)
typedef OddsUpdateCallback = void Function(OddsUpdateData data);

/// Applies parsed messages to the data store.
///
/// Handles:
/// - Message routing by type
/// - Parent dependency checking (pending queue)
/// - Flushing pending messages when parent arrives
class DataUpdater {
  final SportDataStore _store;
  final PendingQueue _pendingQueue;
  final Logger _logger;

  /// Callback for score updates
  final ScoreUpdateCallback? onScoreUpdate;

  /// Callback for event status updates
  final EventStatusUpdateCallback? onEventStatusUpdate;

  /// Callback for balance updates
  final BalanceUpdateCallback? onBalanceUpdate;

  /// Callback for market status changes
  final MarketStatusCallback? onMarketStatusChange;

  /// Callback for odds changes (direction up/down)
  final OddsChangeCallback? onOddsChange;

  /// Callback for ALL odds updates (regardless of direction change)
  final OddsUpdateCallback? onOddsUpdate;

  DataUpdater({
    required SportDataStore store,
    required PendingQueue pendingQueue,
    Logger? logger,
    this.onScoreUpdate,
    this.onEventStatusUpdate,
    this.onBalanceUpdate,
    this.onMarketStatusChange,
    this.onOddsChange,
    this.onOddsUpdate,
  })  : _store = store,
        _pendingQueue = pendingQueue,
        _logger = logger ?? const NoOpLogger();

  /// Apply a batch of parsed messages to the store
  void applyBatch(List<ParsedMessage> messages) {
    // DEBUG: Track what types are being applied
    final appliedTypes = <String, List<String>>{};

    for (final message in messages) {
      // Track before applying
      final ids = <String>[];
      final leagueId = message.getInt('leagueId') ?? message.getInt('li');
      final eventId = message.getInt('eventId') ?? message.getInt('ei');
      final marketId = message.getInt('marketId') ?? message.getInt('mi');

      if (leagueId != null) ids.add('L:$leagueId');
      if (eventId != null) ids.add('E:$eventId');
      if (marketId != null) ids.add('M:$marketId');

      appliedTypes.putIfAbsent(message.type, () => []).add(ids.join(','));

      applyMessage(message);
    }

    // DEBUG: Print what was applied to store
    _debugPrintAppliedMessages(appliedTypes);

    // DEBUG: Print pending queue status after applying
    _debugPrintPendingQueueDetails();

    // Emit changes after batch
    _store.emitBatchChanges();
  }

  /// Apply a single parsed message
  void applyMessage(ParsedMessage message) {
    switch (message.type) {
      case MessageType.leagueInsert:
        _handleLeagueInsert(message);
        break;

      case MessageType.eventInsert:
        _handleEventInsert(message);
        break;

      case MessageType.eventUpdate:
      case MessageType.scoreUpdate:
        _handleEventUpdate(message);
        break;

      case MessageType.eventRemove:
        _handleEventRemove(message);
        break;

      case MessageType.marketUpdate:
        _handleMarketUpdate(message);
        break;

      case MessageType.oddsUpdate:
      case MessageType.oddsInsert:
        _handleOddsUpdate(message);
        break;

      case MessageType.oddsRemove:
        _handleOddsRemove(message);
        break;

      case MessageType.balanceUpdate:
      case MessageType.userBalance:
        _handleBalanceUpdate(message);
        break;

      default:
        _logger.debug('Unhandled message type: ${message.type}');
    }
  }

  /// Handle league_ins message
  void _handleLeagueInsert(ParsedMessage message) {
    _store.upsertLeagueFromJson(message.data);

    // Flush pending events for this league
    final leagueId = message.getInt('leagueId') ?? message.getInt('li');
    if (leagueId != null) {
      _flushPendingForParent(leagueId);
    }
  }

  /// Handle event_ins message
  void _handleEventInsert(ParsedMessage message) {
    final leagueId = message.getInt('leagueId') ?? message.getInt('li');

    // Check if league exists
    if (leagueId != null && !_store.hasLeague(leagueId)) {
      // League doesn't exist yet - add to pending queue
      _pendingQueue.addPendingParsed(
        type: message.type,
        data: message.data,
        parentId: leagueId,
      );
      _logger.debug(
        'Event pending for league $leagueId: ${message.getInt("eventId")}',
      );
      return;
    }

    _store.upsertEventFromJson(message.data);

    // Flush pending odds/markets for this event
    final eventId = message.getInt('eventId') ?? message.getInt('ei');
    if (eventId != null) {
      _flushPendingForParent(eventId);
    }
  }

  /// Handle event_up message
  void _handleEventUpdate(ParsedMessage message) {
    final eventId = message.getInt('eventId') ?? message.getInt('ei');
    if (eventId == null) return;

    if (!_store.hasEvent(eventId)) {
      // Event doesn't exist - might be pending or missed event_ins
      _logger.debug('Event update for unknown event: $eventId');
      return;
    }

    // Get old event for score comparison
    final oldEvent = _store.getEvent(eventId);
    final oldHomeScore = oldEvent?.homeScore;
    final oldAwayScore = oldEvent?.awayScore;

    // Update store
    _store.updateEventFromJson(eventId, message.data);

    // Get updated scores
    final homeScore = message.getInt('homeScore') ?? message.getInt('hs');
    final awayScore = message.getInt('awayScore') ?? message.getInt('as');

    // Emit score update ONLY if score actually changed
    if (homeScore != null || awayScore != null) {
      final newHomeScore = homeScore ?? oldEvent?.homeScore ?? 0;
      final newAwayScore = awayScore ?? oldEvent?.awayScore ?? 0;

      if (newHomeScore != oldHomeScore || newAwayScore != oldAwayScore) {
        onScoreUpdate?.call(
          ScoreUpdateData(
            eventId: eventId,
            sportId: message.sportId,
            homeScore: newHomeScore,
            awayScore: newAwayScore,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Parse nullable bools directly from data
    final isLive =
        message.data['isLive'] as bool? ?? message.data['l'] as bool?;
    final isLivestream =
        message.data['isLivestream'] as bool? ?? message.data['ls'] as bool?;
    final isSuspendedRaw =
        message.data['isSuspended'] as bool? ?? message.data['s'] as bool?;
    final isSuspended = isSuspendedRaw ??
        (message.getString('status') ?? message.getString('es'))
                ?.toUpperCase() ==
            'SUSPENDED';

    // Emit event status update
    onEventStatusUpdate?.call(
      EventStatusData(
        eventId: eventId,
        sportId: message.sportId,
        status: message.getString('status') ?? message.getString('es'),
        isSuspended: isSuspended,
        isLive: isLive,
        isLivestream: isLivestream,
        eventStatus:
            message.getString('eventStatus') ?? message.getString('es'),
        gameTime: message.getInt('gameTime') ?? message.getInt('gt'),
        gamePart: message.getInt('gamePart') ?? message.getInt('gp'),
        stoppageTime: message.getInt('stoppageTime') ?? message.getInt('stm'),
        cornersHome: message.getInt('cornersHome') ?? message.getInt('hc'),
        cornersAway: message.getInt('cornersAway') ?? message.getInt('ac'),
        yellowCardsHome:
            message.getInt('yellowCardsHome') ?? message.getInt('ych'),
        yellowCardsAway:
            message.getInt('yellowCardsAway') ?? message.getInt('yca'),
        redCardsHome: message.getInt('redCardsHome') ?? message.getInt('rch'),
        redCardsAway: message.getInt('redCardsAway') ?? message.getInt('rca'),
        homeScore: homeScore,
        awayScore: awayScore,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Handle event_rm message
  ///
  /// When server sends REMOVE message, the event has ended or is no longer available.
  /// We emit AUTOHIDDEN status before removing so betslip items show "Hủy" state.
  void _handleEventRemove(ParsedMessage message) {
    final eventId = message.getInt('eventId') ?? message.getInt('ei');
    if (eventId == null) return;

    // Emit AUTOHIDDEN status so betslip items can show "Hủy" state
    // This is important because after removal, the event won't receive any more updates
    onEventStatusUpdate?.call(
      EventStatusData(
        eventId: eventId,
        sportId: message.sportId,
        status: 'AUTOHIDDEN',
        timestamp: DateTime.now(),
      ),
    );

    _store.removeEvent(eventId);
  }

  /// Handle market_up message
  void _handleMarketUpdate(ParsedMessage message) {
    final eventId = message.getInt('eventId') ??
        message.getInt('domainEventId') ??
        message.getInt('ei');
    final marketId = message.getInt('marketId') ??
        message.getInt('domainMarketId') ??
        message.getInt('mi');

    if (eventId == null) return;

    if (!_store.hasEvent(eventId)) {
      // Event doesn't exist yet - add to pending
      _pendingQueue.addPendingParsed(
        type: message.type,
        data: message.data,
        parentId: eventId,
      );
      return;
    }

    _store.upsertMarketFromJson(eventId, message.data);

    // Emit market status change
    if (marketId != null) {
      final statusCode = message.getInt('status') ?? 0;
      final status = MarketStatus.fromCode(statusCode);
      onMarketStatusChange?.call(
        MarketStatusData(
          eventId: eventId,
          marketId: marketId,
          sportId: message.sportId,
          status: status,
          isSuspended: status.isSuspended,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Handle odds_up message
  void _handleOddsUpdate(ParsedMessage message) {
    final eventId = message.getInt('eventId') ?? message.getInt('ei');
    final marketId = message.getInt('marketId') ?? message.getInt('mi');

    if (eventId == null) return;

    if (!_store.hasEvent(eventId)) {
      // Event doesn't exist yet - add to pending
      _pendingQueue.addPendingParsed(
        type: message.type,
        data: message.data,
        parentId: eventId,
      );
      return;
    }

    final timeRange = message.getString('timeRange') ?? TimeRange.live;

    // Get offerId for looking up odds after update
    final oddsMap = message.getMap('odds');
    final dataForOdds = oddsMap != null
        ? (Map<String, dynamic>.from(message.data)..addAll(oddsMap))
        : message.data;

    final offerId = dataForOdds['strOfferId']?.toString() ??
        dataForOdds['offerId']?.toString();

    // Check if odds has nested structure
    if (oddsMap != null) {
      // Odds with nested structure
      _store.upsertOddsFromJson(
        eventId,
        marketId ?? 0,
        dataForOdds,
        timeRange: timeRange,
      );
    } else {
      // Odds at root level
      _store.upsertOddsFromJson(
        eventId,
        marketId ?? 0,
        message.data,
        timeRange: timeRange,
      );
    }

    // Get updated odds from store
    if (offerId != null && marketId != null) {
      final odds = _store.getOdds(eventId, marketId, offerId);
      if (odds != null) {
        // Emit ALL odds updates (for drawers update in bet detail)
        onOddsUpdate?.call(OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          offerId: offerId,
          odds: odds,
          timestamp: DateTime.now(),
        ));

        // Emit direction change events (for indicators)
        if (onOddsChange != null) {
          _emitOddsChangeEvents(odds);
        }
      }
    }
  }

  /// Emit OddsChangeData for each selection that changed direction
  void _emitOddsChangeEvents(OddsData odds) {
    final timestamp = DateTime.now();

    // Check home odds change
    if (odds.homeDirection != OddsDirection.none &&
        odds.selectionIdHome != null &&
        odds.selectionIdHome!.isNotEmpty &&
        odds.previousHome != null &&
        odds.oddsHome != null) {
      onOddsChange?.call(
        OddsChangeData(
          eventId: odds.eventId,
          marketId: odds.marketId,
          offerId: odds.offerId,
          selectionId: odds.selectionIdHome!,
          selectionType: 'home',
          previousValue: odds.previousHome!,
          currentValue: odds.oddsHome!,
          direction: odds.homeDirection,
          styleValues: OddsStyleValues(
            decimal: odds.oddsHome!,
            malay: odds.malayHome,
            indo: odds.indoHome,
            hk: odds.hkHome,
          ),
          timestamp: timestamp,
        ),
      );
    }

    // Check away odds change
    if (odds.awayDirection != OddsDirection.none &&
        odds.selectionIdAway != null &&
        odds.selectionIdAway!.isNotEmpty &&
        odds.previousAway != null &&
        odds.oddsAway != null) {
      onOddsChange?.call(
        OddsChangeData(
          eventId: odds.eventId,
          marketId: odds.marketId,
          offerId: odds.offerId,
          selectionId: odds.selectionIdAway!,
          selectionType: 'away',
          previousValue: odds.previousAway!,
          currentValue: odds.oddsAway!,
          direction: odds.awayDirection,
          styleValues: OddsStyleValues(
            decimal: odds.oddsAway!,
            malay: odds.malayAway,
            indo: odds.indoAway,
            hk: odds.hkAway,
          ),
          timestamp: timestamp,
        ),
      );
    }

    // Check draw odds change
    if (odds.drawDirection != OddsDirection.none &&
        odds.selectionIdDraw != null &&
        odds.selectionIdDraw!.isNotEmpty &&
        odds.previousDraw != null &&
        odds.oddsDraw != null) {
      onOddsChange?.call(
        OddsChangeData(
          eventId: odds.eventId,
          marketId: odds.marketId,
          offerId: odds.offerId,
          selectionId: odds.selectionIdDraw!,
          selectionType: 'draw',
          previousValue: odds.previousDraw!,
          currentValue: odds.oddsDraw!,
          direction: odds.drawDirection,
          styleValues: OddsStyleValues(
            decimal: odds.oddsDraw!,
            malay: null, // Draw doesn't have malay format
            indo: null,
            hk: null,
          ),
          timestamp: timestamp,
        ),
      );
    }
  }

  /// Handle odds_rmv message
  void _handleOddsRemove(ParsedMessage message) {
    // For now, we don't remove individual odds
    // This could be implemented if needed
    _logger.debug('Odds remove: ${message.data}');
  }

  /// Handle balance_up or user_bal message
  void _handleBalanceUpdate(ParsedMessage message) {
    // Try multiple field names for balance value
    final rawBalance = message.getString('balance') ??
        message.getString('b') ??
        message.getString('bal') ??
        message.data['balance']?.toString() ??
        message.data['b']?.toString() ??
        '0';

    // Parse balance robustly
    final balance = double.tryParse(rawBalance) ?? 0.0;

    // Get currency if available
    final currency = message.getString('currency') ?? message.getString('c');

    _logger.debug('Balance update: $balance (raw: $rawBalance)');

    // Emit balance update
    onBalanceUpdate?.call(
      BalanceUpdateData(
        balance: balance,
        currency: currency,
        raw: rawBalance,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Flush pending messages for a parent that just arrived
  void _flushPendingForParent(int parentId) {
    final pending = _pendingQueue.flushForParent(parentId);
    if (pending.isEmpty) return;

    _logger.debug('Flushing ${pending.length} pending messages for $parentId');

    for (final msg in pending) {
      // Re-process the pending message
      final parsed = ParsedMessage(
        type: msg.type,
        sportId: 0, // Not used for pending messages
        data: msg.data,
        raw: '',
        timestamp: msg.timestamp,
      );
      applyMessage(parsed);
    }
  }

  /// Get access to pending queue for monitoring
  PendingQueue get pendingQueue => _pendingQueue;

  // ============ DEBUG METHODS ============

  /// Debug print applied messages summary
  void _debugPrintAppliedMessages(Map<String, List<String>> appliedTypes) {
    if (appliedTypes.isEmpty) return;

    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln('╔══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ 🔄 DATA UPDATER - Applied to Store');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');

    // var totalApplied = 0;
    // for (final entry in appliedTypes.entries) {
    //   totalApplied += entry.value.length;
    //   buffer.writeln('║ 📝 ${entry.key}: ${entry.value.length} items');
    //   // Show first 5 IDs
    //   final displayIds = entry.value.take(5).join(', ');
    //   buffer.writeln('║    IDs: [$displayIds${entry.value.length > 5 ? ", ... +${entry.value.length - 5} more" : ""}]');
    // }

    // buffer.writeln('╠══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ Total applied: $totalApplied messages');
    // buffer.writeln('╚══════════════════════════════════════════════════════════════');
    // // ignore: avoid_print
    // print(buffer.toString());
  }

  /// Debug print detailed pending queue status
  void _debugPrintPendingQueueDetails() {
    if (_pendingQueue.isEmpty) return;

    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln('╔══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ ⏳ PENDING QUEUE STATUS (after apply)');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');
    // buffer.writeln('║ Total pending: ${_pendingQueue.length} items');
    // buffer.writeln('║ Unique parents: ${_pendingQueue.parentCount}');
    // buffer.writeln('║ Dropped: ${_pendingQueue.droppedCount} | Expired: ${_pendingQueue.expiredCount}');
    // buffer.writeln('╠══════════════════════════════════════════════════════════════');

    // // Show details for each parent
    // var parentShown = 0;
    // for (final parentId in _pendingQueue.pendingParentIds) {
    //   if (parentShown >= 10) {
    //     buffer.writeln('║ ... +${_pendingQueue.parentCount - 10} more parents');
    //     break;
    //   }

    //   final items = _pendingQueue.peekForParent(parentId);
    //   final typeCount = <String, int>{};
    //   final typeIds = <String, List<String>>{};

    //   for (final item in items) {
    //     typeCount[item.type] = (typeCount[item.type] ?? 0) + 1;

    //     // Extract IDs from pending message data
    //     final eventId = item.data['eventId'] ?? item.data['ei'];
    //     final marketId = item.data['marketId'] ?? item.data['mi'];
    //     final ids = <String>[];
    //     if (eventId != null) ids.add('E:$eventId');
    //     if (marketId != null) ids.add('M:$marketId');
    //     typeIds.putIfAbsent(item.type, () => []).add(ids.join(','));
    //   }

    //   buffer.writeln('║ 🔑 Waiting for ParentID: $parentId (${items.length} items)');
    //   for (final tc in typeCount.entries) {
    //     final idsForType = typeIds[tc.key] ?? [];
    //     final displayIds = idsForType.take(3).join(', ');
    //     buffer.writeln('║    - ${tc.key}: ${tc.value} [$displayIds${idsForType.length > 3 ? "..." : ""}]');
    //   }
    //   parentShown++;
    // }

    // buffer.writeln('╚══════════════════════════════════════════════════════════════');
    // // ignore: avoid_print
    // print(buffer.toString());
  }
}
