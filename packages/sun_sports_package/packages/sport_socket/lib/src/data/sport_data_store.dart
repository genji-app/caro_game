import 'dart:async';

import 'models/league_data.dart';
import 'models/event_data.dart';
import 'models/market_data.dart';
import 'models/odds_data.dart';
// import 'models/outright_event_data.dart';
import '../events/data_change_event.dart';
import '../proto/proto.dart';

/// Sort mode for events
enum SortMode {
  /// Default: Group by league → sort leagues → sort events by start time
  defaultMode,

  /// Start time: Sort by time → same time group by league
  startTimeMode,
}

/// Central data store for sports data.
///
/// Provides O(1) lookups via indexed Maps and maintains
/// relationship indexes for efficient queries.
class SportDataStore {
  // ===== Primary data storage =====

  /// Leagues by ID - O(1) lookup
  final Map<int, LeagueData> _leagues = {};

  /// Events by ID - O(1) lookup
  final Map<int, EventData> _events = {};

  /// Markets by key "{eventId}_{marketId}" - O(1) lookup
  final Map<String, MarketData> _markets = {};

  /// Odds by key "{eventId}_{marketId}_{offerId}" - O(1) lookup
  final Map<String, OddsData> _odds = {};

  // ===== Relationship indexes =====

  /// Sport ID -> Set of League IDs
  final Map<int, Set<int>> _sportToLeagues = {};

  /// League ID -> Set of Event IDs
  final Map<int, Set<int>> _leagueToEvents = {};

  /// Event ID -> Set of Market Keys
  final Map<int, Set<String>> _eventToMarkets = {};

  /// Market Key -> Set of Odds Keys
  final Map<String, Set<String>> _marketToOdds = {};

  // ===== Change notification =====

  final StreamController<DataChangeEvent> _changeController =
      StreamController<DataChangeEvent>.broadcast();

  /// Stream of data change events
  Stream<DataChangeEvent> get onChanged => _changeController.stream;

  // ===== Current batch tracking =====

  final Set<int> _batchUpdatedLeagueIds = {};
  final Set<int> _batchUpdatedEventIds = {};
  final Set<String> _batchUpdatedMarketKeys = {};
  final Set<String> _batchUpdatedOddsKeys = {};
  final List<int> _batchAddedLeagueIds = [];
  final List<int> _batchAddedEventIds = [];
  final List<String> _batchAddedMarketKeys = [];
  final List<String> _batchAddedOddsKeys = [];
  final List<int> _batchRemovedLeagueIds = [];
  final List<int> _batchRemovedEventIds = [];

  // ===== READ OPERATIONS =====

  /// Get league by ID - O(1)
  LeagueData? getLeague(int leagueId) => _leagues[leagueId];

  /// Get event by ID - O(1)
  EventData? getEvent(int eventId) => _events[eventId];

  /// Get market by eventId and marketId - O(1)
  MarketData? getMarket(int eventId, int marketId) =>
      _markets['${eventId}_$marketId'];

  /// Get odds by full key - O(1)
  OddsData? getOdds(int eventId, int marketId, String offerId) =>
      _odds['${eventId}_${marketId}_$offerId'];

  /// Get all leagues for a sport - O(n) where n = leagues in sport
  List<LeagueData> getLeaguesBySport(int sportId) {
    final leagueIds = _sportToLeagues[sportId];
    if (leagueIds == null) return const [];

    return leagueIds.map((id) => _leagues[id]).whereType<LeagueData>().toList();
  }

  /// Get all events for a league - O(n) where n = events in league
  List<EventData> getEventsByLeague(int leagueId) {
    final eventIds = _leagueToEvents[leagueId];
    if (eventIds == null) return const [];

    return eventIds.map((id) => _events[id]).whereType<EventData>().toList();
  }

  /// Get all markets for an event - O(n) where n = markets in event
  List<MarketData> getMarketsByEvent(int eventId) {
    final marketKeys = _eventToMarkets[eventId];
    if (marketKeys == null) return const [];

    return marketKeys
        .map((key) => _markets[key])
        .whereType<MarketData>()
        .toList();
  }

  /// Get all odds for a market - O(n) where n = odds in market
  List<OddsData> getOddsByMarket(int eventId, int marketId) {
    final marketKey = '${eventId}_$marketId';
    final oddsKeys = _marketToOdds[marketKey];
    if (oddsKeys == null) return const [];

    return oddsKeys.map((key) => _odds[key]).whereType<OddsData>().toList();
  }

  // ===== EXISTENCE CHECKS =====

  /// Check if league exists - O(1)
  bool hasLeague(int leagueId) => _leagues.containsKey(leagueId);

  /// Check if event exists - O(1)
  bool hasEvent(int eventId) => _events.containsKey(eventId);

  /// Check if market exists - O(1)
  bool hasMarket(int eventId, int marketId) =>
      _markets.containsKey('${eventId}_$marketId');

  /// Check if odds exists - O(1)
  bool hasOdds(int eventId, int marketId, String offerId) =>
      _odds.containsKey('${eventId}_${marketId}_$offerId');

  // ===== COUNTS =====

  /// Total league count
  int get leagueCount => _leagues.length;

  /// Total event count
  int get eventCount => _events.length;

  /// Total market count
  int get marketCount => _markets.length;

  /// Total odds count
  int get oddsCount => _odds.length;

  /// Get all event IDs
  Iterable<int> get allEventIds => _events.keys;

  /// Get all league IDs
  Iterable<int> get allLeagueIds => _leagues.keys;

  // ===== WRITE OPERATIONS =====

  /// Insert a new league
  void insertLeague(LeagueData league) {
    _leagues[league.leagueId] = league;

    // Update index
    _sportToLeagues.putIfAbsent(league.sportId, () => {}).add(league.leagueId);

    // Initialize event set
    _leagueToEvents.putIfAbsent(league.leagueId, () => {});

    _batchAddedLeagueIds.add(league.leagueId);
  }

  /// Update an existing league
  void updateLeague(LeagueData league) {
    final existing = _leagues[league.leagueId];
    if (existing != null) {
      existing.updateFrom({
        'leagueName': league.name,
        'lpo': league.priorityOrder,
        'lg': league.logoUrl,
        'cashout': league.cashout,
      });
      _batchUpdatedLeagueIds.add(league.leagueId);
    } else {
      insertLeague(league);
    }
  }

  /// Insert or update league from JSON data
  void upsertLeagueFromJson(Map<String, dynamic> data) {
    final leagueId = _parseInt(data['leagueId'] ?? data['li']);
    if (leagueId == null) return;

    final existing = _leagues[leagueId];
    if (existing != null) {
      existing.updateFrom(data);
      _batchUpdatedLeagueIds.add(leagueId);
    } else {
      final league = LeagueData.fromJson(data);
      insertLeague(league);
    }
  }

  /// Insert a new event
  void insertEvent(EventData event) {
    _events[event.eventId] = event;

    // Update index
    _leagueToEvents.putIfAbsent(event.leagueId, () => {}).add(event.eventId);

    // Initialize market set
    _eventToMarkets.putIfAbsent(event.eventId, () => {});

    _batchAddedEventIds.add(event.eventId);
  }

  /// Update an existing event
  void updateEventFromJson(int eventId, Map<String, dynamic> data) {
    final existing = _events[eventId];
    if (existing != null) {
      existing.updateFrom(data);
      _batchUpdatedEventIds.add(eventId);
    }
  }

  /// Insert or update event from JSON data
  void upsertEventFromJson(Map<String, dynamic> data) {
    final eventId = _parseInt(data['eventId'] ?? data['ei']);
    if (eventId == null) return;

    final existing = _events[eventId];
    if (existing != null) {
      existing.updateFrom(data);
      _batchUpdatedEventIds.add(eventId);
    } else {
      final event = EventData.fromJson(data);
      insertEvent(event);
    }
  }

  /// Remove an event and cascade delete markets/odds
  void removeEvent(int eventId) {
    final event = _events.remove(eventId);
    if (event == null) return;

    // Remove from league index
    _leagueToEvents[event.leagueId]?.remove(eventId);

    // Cascade delete markets
    final marketKeys = _eventToMarkets.remove(eventId);
    if (marketKeys != null) {
      for (final marketKey in marketKeys) {
        _markets.remove(marketKey);

        // Cascade delete odds
        final oddsKeys = _marketToOdds.remove(marketKey);
        if (oddsKeys != null) {
          for (final oddsKey in oddsKeys) {
            _odds.remove(oddsKey);
          }
        }
      }
    }

    _batchRemovedEventIds.add(eventId);

    // If league is now empty, consider removing it
    final remainingEvents = _leagueToEvents[event.leagueId];
    if (remainingEvents != null && remainingEvents.isEmpty) {
      removeLeague(event.leagueId);
    }
  }

  /// Remove a league
  void removeLeague(int leagueId) {
    final league = _leagues.remove(leagueId);
    if (league == null) return;

    // Remove from sport index
    _sportToLeagues[league.sportId]?.remove(leagueId);

    // Remove event index (events should already be removed)
    _leagueToEvents.remove(leagueId);

    _batchRemovedLeagueIds.add(leagueId);
  }

  /// Update or insert market from JSON
  void upsertMarketFromJson(int eventId, Map<String, dynamic> data) {
    final marketId =
        _parseInt(data['marketId'] ?? data['domainMarketId'] ?? data['mi']);
    if (marketId == null) return;

    final marketKey = '${eventId}_$marketId';
    var market = _markets[marketKey];

    if (market != null) {
      market.updateFrom(data);
      _batchUpdatedMarketKeys.add(marketKey);
    } else {
      market = MarketData.fromJson(data, eventId: eventId);
      _markets[marketKey] = market;

      // Update index
      _eventToMarkets.putIfAbsent(eventId, () => {}).add(marketKey);
      _marketToOdds.putIfAbsent(marketKey, () => {});

      _batchAddedMarketKeys.add(marketKey);
    }
  }

  /// Update or insert odds from JSON
  void upsertOddsFromJson(
    int eventId,
    int marketId,
    Map<String, dynamic> data, {
    String timeRange = 'LIVE',
  }) {
    final offerId = data['strOfferId']?.toString() ??
        data['offerId']?.toString() ??
        '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

    final oddsKey = '${eventId}_${marketId}_$offerId';
    final marketKey = '${eventId}_$marketId';

    var odds = _odds[oddsKey];

    if (odds != null) {
      odds.updateFrom(data);
      _batchUpdatedOddsKeys.add(oddsKey);
    } else {
      odds = OddsData.fromJson(
        data,
        eventId: eventId,
        marketId: marketId,
        timeRange: timeRange,
      );
      _odds[oddsKey] = odds;

      // Update index
      _marketToOdds.putIfAbsent(marketKey, () => {}).add(oddsKey);

      _batchAddedOddsKeys.add(oddsKey);
    }
  }

  // ===== OUTRIGHT EVENTS =====

  // /// Outright events by ID - O(1) lookup
  // final Map<int, OutrightEventData> _outrightEvents = {};

  // /// Get outright event by ID
  // OutrightEventData? getOutrightEvent(int eventId) => _outrightEvents[eventId];

  // /// Get all outright events for a sport
  // List<OutrightEventData> getOutrightEventsBySport(int sportId) {
  //   return _outrightEvents.values
  //       .where((e) => e.sportId == sportId)
  //       .toList();
  // }

  // /// Remove outright event
  // void removeOutrightEvent(int eventId) {
  //   _outrightEvents.remove(eventId);
  // }

  // ===== PROTO WRITE OPERATIONS (V2) =====

  /// Insert or update league from Proto LeagueResponse
  void upsertLeagueFromProto(LeagueResponse proto, {int? timeRange}) {
    final leagueId = proto.leagueId;
    final existing = _leagues[leagueId];

    if (existing != null) {
      // Update existing league
      existing.updateFrom({
        'leagueName': proto.leagueName,
        'leagueNameEn': proto.leagueNameEn,
        'leagueLogo': proto.leagueLogo,
        'leagueOrder': proto.leagueOrder,
        'lpo': proto.leaguePriorityOrder,
        'cashout': proto.isCashOut,
        'isParlay': proto.isParlay,
        'isPin': proto.isPin,
      });
      _batchUpdatedLeagueIds.add(leagueId);
    } else {
      // Insert new league
      final league = LeagueData.fromJson({
        'leagueId': leagueId,
        'sportId': proto.sportId,
        'leagueName': proto.leagueName,
        'leagueNameEn': proto.leagueNameEn,
        'leagueLogo': proto.leagueLogo,
        'leagueOrder': proto.leagueOrder,
        'lpo': proto.leaguePriorityOrder,
        'cashout': proto.isCashOut,
        'isParlay': proto.isParlay,
        'type': proto.type,
        'sportType': proto.sportType,
        'sportTypeId': proto.sportTypeId,
      });
      insertLeague(league);
    }
  }

  /// Update league from Proto (only updates, doesn't insert)
  void updateLeagueFromProto(LeagueResponse proto) {
    final existing = _leagues[proto.leagueId];
    if (existing != null) {
      existing.updateFrom({
        'leagueName': proto.leagueName,
        'leagueNameEn': proto.leagueNameEn,
        'leagueLogo': proto.leagueLogo,
        'leagueOrder': proto.leagueOrder,
        'lpo': proto.leaguePriorityOrder,
        'cashout': proto.isCashOut,
      });
      _batchUpdatedLeagueIds.add(proto.leagueId);
    }
  }

  /// Ensure league exists (for hot events that include league info)
  void ensureLeague({
    required int leagueId,
    required String leagueName,
    required int leagueOrder,
    required int leaguePriorityOrder,
    required String leagueLogo,
    int sportId = 0,
  }) {
    if (!_leagues.containsKey(leagueId)) {
      final league = LeagueData.fromJson({
        'leagueId': leagueId,
        'sportId': sportId,
        'leagueName': leagueName,
        'leagueLogo': leagueLogo,
        'leagueOrder': leagueOrder,
        'lpo': leaguePriorityOrder,
      });
      insertLeague(league);
    }
  }

  /// Insert or update event from Proto EventResponse
  void upsertEventFromProto(EventResponse proto) {
    final eventId = proto.eventId.toInt();
    final existing = _events[eventId];

    if (existing != null) {
      // Track previous scores for animation
      final previousHomeScore = existing.homeScore;
      final previousAwayScore = existing.awayScore;

      // Update existing event
      _updateEventFromProto(existing, proto);

      // Store previous scores
      existing.previousHomeScore = previousHomeScore;
      existing.previousAwayScore = previousAwayScore;

      _batchUpdatedEventIds.add(eventId);
    } else {
      // Insert new event
      final event = _createEventFromProto(proto);
      insertEvent(event);
    }
  }

  /// Create EventData from Proto
  EventData _createEventFromProto(EventResponse proto) {
    return EventData.fromJson({
      'eventId': proto.eventId.toInt(),
      'leagueId': proto.leagueId,
      'sportId': proto.sportId,
      'homeName': proto.homeName,
      'awayName': proto.awayName,
      'homeId': proto.homeId,
      'awayId': proto.awayId,
      'homeLogo': proto.homeLogo,
      'awayLogo': proto.awayLogo,
      'startDate': proto.startDate,
      'startTime': proto.startTime.toInt(),
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
      'isParlay': proto.isParlay,
      'isCashOut': proto.isCashOut,
      'isLive': proto.isLive,
      'isGoingLive': proto.isGoingLive,
      'isHot': proto.isHot,
      'isLiveStream': proto.isLiveStream,
      'type': proto.type,
      'pinType': proto.pinType,
      'gamePart': proto.gamePart,
      'gameTime': proto.gameTime,
      'stoppageTime': proto.stoppageTime,
      'marketCount': proto.marketCount,
      'eventStatsId': proto.eventStatsId.toInt(),
      'sportTypeId': proto.sportTypeId,
      'sportTypeName': proto.sportTypeName,
      'specialSituation': proto.specialSituation,
    });
  }

  /// Update EventData from Proto
  void _updateEventFromProto(EventData event, EventResponse proto) {
    event.updateFrom({
      'homeName': proto.homeName,
      'awayName': proto.awayName,
      'homeLogo': proto.homeLogo,
      'awayLogo': proto.awayLogo,
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
      'isLive': proto.isLive,
      'isGoingLive': proto.isGoingLive,
      'isHot': proto.isHot,
      'isLiveStream': proto.isLiveStream,
      'gamePart': proto.gamePart,
      'gameTime': proto.gameTime,
      'stoppageTime': proto.stoppageTime,
      'marketCount': proto.marketCount,
    });

    // Update live score if present
    if (proto.hasLiveScore()) {
      _updateEventScoreFromProto(event, proto.liveScore);
    }
  }

  /// Update event score from Proto ScoreResponse
  void _updateEventScoreFromProto(EventData event, ScoreResponse score) {
    if (score.hasSoccer()) {
      final s = score.soccer;
      event.homeScore = s.homeScore;
      event.awayScore = s.awayScore;
      event.cornersHome = s.homeCorner;
      event.cornersAway = s.awayCorner;
      event.yellowCardsHome = s.yellowCardsHome;
      event.yellowCardsAway = s.yellowCardsAway;
      event.redCardsHome = s.redCardsHome;
      event.redCardsAway = s.redCardsAway;
    } else if (score.hasBasketball()) {
      final s = score.basketball;
      event.homeScore = s.homeScoreFT;
      event.awayScore = s.awayScoreFT;
    } else if (score.hasVolleyball()) {
      final s = score.volleyball;
      event.homeScore = s.homeSetScore;
      event.awayScore = s.awaySetScore;
    } else if (score.hasTennis()) {
      final s = score.tennis;
      event.homeScore = s.homeSetScore;
      event.awayScore = s.awaySetScore;
    } else if (score.hasTableTennis()) {
      final s = score.tableTennis;
      event.homeScore = s.homeSetScore;
      event.awayScore = s.awaySetScore;
    } else if (score.hasBadminton()) {
      final s = score.badminton;
      event.homeScore = s.homeSetScore;
      event.awayScore = s.awaySetScore;
    }
  }

  /// Insert or update market from Proto MarketResponse
  void upsertMarketFromProto(int eventId, MarketResponse proto) {
    final marketId = proto.marketId;
    final marketKey = '${eventId}_$marketId';
    var market = _markets[marketKey];

    if (market != null) {
      market.updateFrom({
        'isSuspended': proto.isSuspended,
        'isParlay': proto.isParlay,
        'isCashOut': proto.isCashOut,
        'promotionType': proto.promotionType,
        'groupId': proto.groupId,
      });
      _batchUpdatedMarketKeys.add(marketKey);
    } else {
      market = MarketData.fromJson({
        'marketId': marketId,
        'eventId': eventId,
        'sportId': proto.sportId,
        'leagueId': proto.leagueId,
        'isSuspended': proto.isSuspended,
        'isParlay': proto.isParlay,
        'isCashOut': proto.isCashOut,
        'promotionType': proto.promotionType,
        'groupId': proto.groupId,
      }, eventId: eventId);
      _markets[marketKey] = market;

      _eventToMarkets.putIfAbsent(eventId, () => {}).add(marketKey);
      _marketToOdds.putIfAbsent(marketKey, () => {});

      _batchAddedMarketKeys.add(marketKey);
    }
  }

  /// Insert or update odds from Proto OddsResponse
  void upsertOddsFromProto(int eventId, int marketId, OddsResponse proto) {
    final offerId = proto.strOfferId.isNotEmpty
        ? proto.strOfferId
        : '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

    final oddsKey = '${eventId}_${marketId}_$offerId';
    final marketKey = '${eventId}_$marketId';

    var odds = _odds[oddsKey];

    if (odds != null) {
      // Track previous values for direction indicators
      final previousHome = odds.oddsHome;
      final previousAway = odds.oddsAway;
      final previousDraw = odds.oddsDraw;

      _updateOddsFromProto(odds, proto);

      odds.previousHome = previousHome;
      odds.previousAway = previousAway;
      odds.previousDraw = previousDraw;

      _batchUpdatedOddsKeys.add(oddsKey);
    } else {
      odds = _createOddsFromProto(eventId, marketId, proto, offerId);
      _odds[oddsKey] = odds;

      _marketToOdds.putIfAbsent(marketKey, () => {}).add(oddsKey);

      _batchAddedOddsKeys.add(oddsKey);
    }
  }

  /// Create OddsData from Proto
  OddsData _createOddsFromProto(
    int eventId,
    int marketId,
    OddsResponse proto,
    String offerId,
  ) {
    return OddsData.fromJson({
      'eventId': eventId,
      'marketId': marketId,
      'strOfferId': offerId,
      'selectionIdHome': proto.selectionHomeId,
      'selectionIdAway': proto.selectionAwayId,
      'selectionIdDraw': proto.selectionDrawId,
      'points': proto.points,
      'oddsHome': _parseOddsDecimal(proto.oddsHome),
      'oddsAway': _parseOddsDecimal(proto.oddsAway),
      'oddsDraw': _parseOddsDecimal(proto.oddsDraw),
      'malayHome': proto.oddsHome.malay,
      'malayAway': proto.oddsAway.malay,
      'indoHome': proto.oddsHome.indo,
      'indoAway': proto.oddsAway.indo,
      'hkHome': proto.oddsHome.hk,
      'hkAway': proto.oddsAway.hk,
      'isMainLine': proto.isMainLine,
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
    }, eventId: eventId, marketId: marketId, timeRange: 'LIVE');
  }

  /// Update OddsData from Proto
  void _updateOddsFromProto(OddsData odds, OddsResponse proto) {
    odds.updateFrom({
      'points': proto.points,
      'oddsHome': _parseOddsDecimal(proto.oddsHome),
      'oddsAway': _parseOddsDecimal(proto.oddsAway),
      'oddsDraw': _parseOddsDecimal(proto.oddsDraw),
      'malayHome': proto.oddsHome.malay,
      'malayAway': proto.oddsAway.malay,
      'indoHome': proto.oddsHome.indo,
      'indoAway': proto.oddsAway.indo,
      'hkHome': proto.oddsHome.hk,
      'hkAway': proto.oddsAway.hk,
      'isSuspended': proto.isSuspended,
      'isHidden': proto.isHidden,
    });
  }

  /// Parse decimal odds from OddsStyleResponse
  double? _parseOddsDecimal(OddsStyleResponse style) {
    if (style.decimal.isEmpty) return null;
    return double.tryParse(style.decimal);
  }

  /// Insert or update outright event from Proto
  // void upsertOutrightEventFromProto(OutrightEventResponse proto) {
  //   final eventId = proto.eventId.toInt();
  //   final existing = _outrightEvents[eventId];

  //   if (existing != null) {
  //     existing.updateFromProto(proto);
  //   } else {
  //     _outrightEvents[eventId] = OutrightEventData.fromProto(proto);
  //   }
  // }

  // ===== SORTING OPERATIONS (V2 - Client-side sorting) =====

  /// Current sort mode
  SortMode _currentSortMode = SortMode.defaultMode;

  /// Get current sort mode
  SortMode get sortMode => _currentSortMode;

  /// Set sort mode
  set sortMode(SortMode mode) {
    if (_currentSortMode != mode) {
      _currentSortMode = mode;
    }
  }

  /// Compare two leagues for sorting
  /// Sort order: priorityOrder > leagueOrder > nameEn
  int _compareLeagues(LeagueData a, LeagueData b) {
    // 1. Priority order (highest precedence)
    final priorityCmp = a.priorityOrder.compareTo(b.priorityOrder);
    if (priorityCmp != 0) return priorityCmp;

    // 2. League order
    final orderCmp = a.leagueOrder.compareTo(b.leagueOrder);
    if (orderCmp != 0) return orderCmp;

    // 3. League name English (lowest precedence)
    return (a.nameEn ?? a.name).toLowerCase().compareTo(
          (b.nameEn ?? b.name).toLowerCase(),
        );
  }

  /// Get sorted leagues for a sport
  List<LeagueData> getSortedLeaguesBySport(int sportId) {
    // Create mutable copy before sorting (getLeaguesBySport may return unmodifiable list)
    final leagues = getLeaguesBySport(sportId).toList();
    leagues.sort(_compareLeagues);
    return leagues;
  }

  /// Get sorted events for a sport based on current sort mode
  List<EventData> getSortedEventsBySport(int sportId) {
    switch (_currentSortMode) {
      case SortMode.defaultMode:
        return _getEventsSortedDefault(sportId);
      case SortMode.startTimeMode:
        return _getEventsSortedByStartTime(sportId);
    }
  }

  /// Default sort: Group by league → sort leagues → sort events by start time within league
  List<EventData> _getEventsSortedDefault(int sportId) {
    final sortedLeagues = getSortedLeaguesBySport(sportId);
    final result = <EventData>[];

    for (final league in sortedLeagues) {
      // Create mutable copy before sorting (getEventsByLeague may return unmodifiable list)
      final events = getEventsByLeague(league.leagueId).toList();
      // Sort events by start time within each league
      events.sort((a, b) {
        final aTime = a.startDate?.millisecondsSinceEpoch ?? 0;
        final bTime = b.startDate?.millisecondsSinceEpoch ?? 0;
        return aTime.compareTo(bTime);
      });
      result.addAll(events);
    }
    return result;
  }

  /// Start time sort: Sort all by time → same time group by league
  List<EventData> _getEventsSortedByStartTime(int sportId) {
    final allEvents = <EventData>[];

    // Collect all events for this sport
    final leagueIds = _sportToLeagues[sportId];
    if (leagueIds == null) return allEvents;

    for (final leagueId in leagueIds) {
      allEvents.addAll(getEventsByLeague(leagueId));
    }

    // Group by start time
    final Map<int, List<EventData>> byStartTime = {};
    for (final event in allEvents) {
      final time = event.startDate?.millisecondsSinceEpoch ?? 0;
      byStartTime.putIfAbsent(time, () => []).add(event);
    }

    // Sort times
    final sortedTimes = byStartTime.keys.toList()..sort();
    final result = <EventData>[];

    for (final time in sortedTimes) {
      final eventsAtTime = byStartTime[time]!;
      // Same time → sort by league criteria
      eventsAtTime.sort((a, b) {
        final leagueA = _leagues[a.leagueId];
        final leagueB = _leagues[b.leagueId];
        if (leagueA == null || leagueB == null) return 0;
        return _compareLeagues(leagueA, leagueB);
      });
      result.addAll(eventsAtTime);
    }
    return result;
  }

  /// Get sorted outright events for a sport
  /// Sort by: league criteria → event name
  // List<OutrightEventData> getSortedOutrightEventsBySport(int sportId) {
  //   final events = getOutrightEventsBySport(sportId);

  //   events.sort((a, b) {
  //     // 1. League priority order
  //     final priorityCmp = a.leaguePriorityOrder.compareTo(b.leaguePriorityOrder);
  //     if (priorityCmp != 0) return priorityCmp;

  //     // 2. League order
  //     final orderCmp = a.leagueOrder.compareTo(b.leagueOrder);
  //     if (orderCmp != 0) return orderCmp;

  //     // 3. Event name
  //     return a.eventName.compareTo(b.eventName);
  //   });

  //   return events;
  // }

  // ===== BATCH OPERATIONS =====

  /// Emit change event for current batch and reset tracking
  void emitBatchChanges() {
    if (_batchUpdatedLeagueIds.isEmpty &&
        _batchUpdatedEventIds.isEmpty &&
        _batchUpdatedMarketKeys.isEmpty &&
        _batchUpdatedOddsKeys.isEmpty &&
        _batchAddedLeagueIds.isEmpty &&
        _batchAddedEventIds.isEmpty &&
        _batchAddedMarketKeys.isEmpty &&
        _batchAddedOddsKeys.isEmpty &&
        _batchRemovedLeagueIds.isEmpty &&
        _batchRemovedEventIds.isEmpty) {
      return;
    }

    final event = DataChangeEvent(
      updatedLeagueIds: Set.from(_batchUpdatedLeagueIds),
      updatedEventIds: Set.from(_batchUpdatedEventIds),
      updatedMarketKeys: Set.from(_batchUpdatedMarketKeys),
      updatedOddsKeys: Set.from(_batchUpdatedOddsKeys),
      addedLeagueIds: List.from(_batchAddedLeagueIds),
      addedEventIds: List.from(_batchAddedEventIds),
      addedMarketKeys: List.from(_batchAddedMarketKeys),
      addedOddsKeys: List.from(_batchAddedOddsKeys),
      removedLeagueIds: List.from(_batchRemovedLeagueIds),
      removedEventIds: List.from(_batchRemovedEventIds),
      timestamp: DateTime.now(),
      batchSize: _batchUpdatedEventIds.length +
          _batchAddedEventIds.length +
          _batchRemovedEventIds.length,
    );

    // Reset batch tracking
    _batchUpdatedLeagueIds.clear();
    _batchUpdatedEventIds.clear();
    _batchUpdatedMarketKeys.clear();
    _batchUpdatedOddsKeys.clear();
    _batchAddedLeagueIds.clear();
    _batchAddedEventIds.clear();
    _batchAddedMarketKeys.clear();
    _batchAddedOddsKeys.clear();
    _batchRemovedLeagueIds.clear();
    _batchRemovedEventIds.clear();

    _changeController.add(event);
  }

  /// Clear all data for a sport
  void clearSport(int sportId) {
    final leagueIds = _sportToLeagues[sportId]?.toList() ?? [];
    for (final leagueId in leagueIds) {
      final eventIds = _leagueToEvents[leagueId]?.toList() ?? [];
      for (final eventId in eventIds) {
        removeEvent(eventId);
      }
      removeLeague(leagueId);
    }
    _sportToLeagues.remove(sportId);
  }

  /// Clear all data
  void clear() {
    _leagues.clear();
    _events.clear();
    _markets.clear();
    _odds.clear();
    _sportToLeagues.clear();
    _leagueToEvents.clear();
    _eventToMarkets.clear();
    _marketToOdds.clear();

    // Clear batch tracking
    _batchUpdatedLeagueIds.clear();
    _batchUpdatedEventIds.clear();
    _batchUpdatedMarketKeys.clear();
    _batchUpdatedOddsKeys.clear();
    _batchAddedLeagueIds.clear();
    _batchAddedEventIds.clear();
    _batchAddedMarketKeys.clear();
    _batchAddedOddsKeys.clear();
    _batchRemovedLeagueIds.clear();
    _batchRemovedEventIds.clear();
  }

  /// Dispose resources
  void dispose() {
    _changeController.close();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}
