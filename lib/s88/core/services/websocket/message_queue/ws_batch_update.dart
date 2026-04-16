/// WebSocket Batch Update Data
///
/// Collects all state changes from a single batch of messages
/// to be applied as a single state update, reducing UI rebuilds.
///
/// Instead of: 10 msgs → 10 state updates → 10 UI rebuilds
/// Now:        10 msgs → 1 WsBatchUpdate → 1 state update → 1 UI rebuild

import '../websocket_messages.dart';

/// Collected updates from a batch of WebSocket messages
class WsBatchUpdate {
  /// Odds full list updates (for FULL LIST behavior)
  final List<OddsFullListData> oddsFullListUpdates;

  /// Event inserts (event_ins)
  final List<EventInsertData> eventInserts;

  /// Event removes (event_rm)
  final List<EventRemoveData> eventRemoves;

  /// League inserts (league_ins)
  final List<LeagueInsertData> leagueInserts;

  /// Market status updates (market_up)
  final List<MarketStatusData> marketStatusUpdates;

  const WsBatchUpdate({
    this.oddsFullListUpdates = const [],
    this.eventInserts = const [],
    this.eventRemoves = const [],
    this.leagueInserts = const [],
    this.marketStatusUpdates = const [],
  });

  /// Check if there are any updates
  bool get isEmpty =>
      oddsFullListUpdates.isEmpty &&
      eventInserts.isEmpty &&
      eventRemoves.isEmpty &&
      leagueInserts.isEmpty &&
      marketStatusUpdates.isEmpty;

  /// Check if there are updates
  bool get isNotEmpty => !isEmpty;

  /// Total number of updates
  int get totalUpdates =>
      oddsFullListUpdates.length +
      eventInserts.length +
      eventRemoves.length +
      leagueInserts.length +
      marketStatusUpdates.length;

  @override
  String toString() {
    return 'WsBatchUpdate('
        'oddsFullList: ${oddsFullListUpdates.length}, '
        'eventIns: ${eventInserts.length}, '
        'eventRm: ${eventRemoves.length}, '
        'leagueIns: ${leagueInserts.length}, '
        'marketUp: ${marketStatusUpdates.length})';
  }
}

/// Builder for collecting updates into a WsBatchUpdate
class WsBatchUpdateBuilder {
  final List<OddsFullListData> _oddsFullListUpdates = [];
  final List<EventInsertData> _eventInserts = [];
  final List<EventRemoveData> _eventRemoves = [];
  final List<LeagueInsertData> _leagueInserts = [];
  final List<MarketStatusData> _marketStatusUpdates = [];

  /// Add odds full list update
  void addOddsFullList(OddsFullListData data) {
    _oddsFullListUpdates.add(data);
  }

  /// Add event insert
  void addEventInsert(EventInsertData data) {
    _eventInserts.add(data);
  }

  /// Add event remove
  void addEventRemove(EventRemoveData data) {
    _eventRemoves.add(data);
  }

  /// Add league insert
  void addLeagueInsert(LeagueInsertData data) {
    _leagueInserts.add(data);
  }

  /// Add market status update
  void addMarketStatus(MarketStatusData data) {
    _marketStatusUpdates.add(data);
  }

  /// Build the batch update
  WsBatchUpdate build() {
    return WsBatchUpdate(
      oddsFullListUpdates: List.unmodifiable(_oddsFullListUpdates),
      eventInserts: List.unmodifiable(_eventInserts),
      eventRemoves: List.unmodifiable(_eventRemoves),
      leagueInserts: List.unmodifiable(_leagueInserts),
      marketStatusUpdates: List.unmodifiable(_marketStatusUpdates),
    );
  }

  /// Check if there are any updates
  bool get isEmpty =>
      _oddsFullListUpdates.isEmpty &&
      _eventInserts.isEmpty &&
      _eventRemoves.isEmpty &&
      _leagueInserts.isEmpty &&
      _marketStatusUpdates.isEmpty;

  /// Check if there are updates
  bool get isNotEmpty => !isEmpty;

  /// Clear all collected updates
  void clear() {
    _oddsFullListUpdates.clear();
    _eventInserts.clear();
    _eventRemoves.clear();
    _leagueInserts.clear();
    _marketStatusUpdates.clear();
  }
}
