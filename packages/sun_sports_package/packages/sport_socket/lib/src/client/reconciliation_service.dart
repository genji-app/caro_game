import '../data/sport_data_store.dart';
import '../data/models/league_data.dart';
import '../data/models/event_data.dart';
import '../utils/logger.dart';

/// Result of reconciliation operation.
class ReconciliationResult {
  /// League IDs that were added
  final List<int> addedLeagues = [];

  /// League IDs that were updated
  final List<int> updatedLeagues = [];

  /// League IDs that were removed
  final List<int> removedLeagues = [];

  /// Event IDs that were added
  final List<int> addedEvents = [];

  /// Event IDs that were updated
  final List<int> updatedEvents = [];

  /// Event IDs that were removed
  final List<int> removedEvents = [];

  /// Total changes
  int get totalChanges =>
      addedLeagues.length +
      updatedLeagues.length +
      removedLeagues.length +
      addedEvents.length +
      updatedEvents.length +
      removedEvents.length;

  /// Whether any changes were made
  bool get hasChanges => totalChanges > 0;

  @override
  String toString() {
    return 'ReconciliationResult('
        'leagues: +${addedLeagues.length}/~${updatedLeagues.length}/-${removedLeagues.length}, '
        'events: +${addedEvents.length}/~${updatedEvents.length}/-${removedEvents.length})';
  }
}

/// Service for reconciling store data with API data.
///
/// Used to sync data after reconnection or periodically
/// to ensure store matches server state.
class ReconciliationService {
  final SportDataStore _store;
  final Logger _logger;

  ReconciliationService({
    required SportDataStore store,
    Logger? logger,
  })  : _store = store,
        _logger = logger ?? const NoOpLogger();

  /// Access to data store (for cleanup operations)
  SportDataStore get store => _store;

  /// Reconcile store with fresh API data.
  ///
  /// This will:
  /// 1. Add/update leagues and events from API data
  /// 2. Remove stale data not present in API response
  ReconciliationResult reconcile(List<LeagueData> apiLeagues) {
    final result = ReconciliationResult();
    final startTime = DateTime.now();

    _logger.info('Starting reconciliation with ${apiLeagues.length} leagues');

    // Build sets of valid IDs from API
    final validLeagueIds = <int>{};

    for (final league in apiLeagues) {
      validLeagueIds.add(league.leagueId);
      _processLeague(league, result);
    }

    // Remove stale leagues
    final staleLeagueIds = _store.allLeagueIds
        .where((id) => !validLeagueIds.contains(id))
        .toList();

    for (final leagueId in staleLeagueIds) {
      _store.removeLeague(leagueId);
      result.removedLeagues.add(leagueId);
    }

    // Emit changes
    _store.emitBatchChanges();

    final duration = DateTime.now().difference(startTime);
    _logger.info(
      'Reconciliation complete: $result (${duration.inMilliseconds}ms)',
    );

    return result;
  }

  /// Reconcile only events for specific leagues.
  ///
  /// Useful when you only need to sync specific leagues.
  ReconciliationResult reconcileEvents({
    required int leagueId,
    required List<EventData> apiEvents,
  }) {
    final result = ReconciliationResult();

    if (!_store.hasLeague(leagueId)) {
      _logger.warning('Cannot reconcile events: league $leagueId not found');
      return result;
    }

    // Build set of valid event IDs
    final validEventIds = <int>{};

    for (final event in apiEvents) {
      validEventIds.add(event.eventId);
      _processEvent(event, result);
    }

    // Remove stale events in this league
    final currentEvents = _store.getEventsByLeague(leagueId);
    for (final event in currentEvents) {
      if (!validEventIds.contains(event.eventId)) {
        _store.removeEvent(event.eventId);
        result.removedEvents.add(event.eventId);
      }
    }

    _store.emitBatchChanges();

    return result;
  }

  /// Reconcile for a specific sport.
  ReconciliationResult reconcileSport({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    final result = ReconciliationResult();

    // Build set of valid league IDs for this sport
    final validLeagueIds = <int>{};

    for (final league in apiLeagues) {
      if (league.sportId == sportId) {
        validLeagueIds.add(league.leagueId);
        _processLeague(league, result);
      }
    }

    // Remove stale leagues for this sport
    final currentLeagues = _store.getLeaguesBySport(sportId);
    for (final league in currentLeagues) {
      if (!validLeagueIds.contains(league.leagueId)) {
        // Remove all events in this league first
        final events = _store.getEventsByLeague(league.leagueId);
        for (final event in events) {
          _store.removeEvent(event.eventId);
          result.removedEvents.add(event.eventId);
        }

        _store.removeLeague(league.leagueId);
        result.removedLeagues.add(league.leagueId);
      }
    }

    _store.emitBatchChanges();

    return result;
  }

  void _processLeague(LeagueData league, ReconciliationResult result) {
    if (_store.hasLeague(league.leagueId)) {
      _store.updateLeague(league);
      result.updatedLeagues.add(league.leagueId);
    } else {
      _store.insertLeague(league);
      result.addedLeagues.add(league.leagueId);
    }
  }

  void _processEvent(EventData event, ReconciliationResult result) {
    if (_store.hasEvent(event.eventId)) {
      _store.updateEventFromJson(event.eventId, {
        'homeName': event.homeName,
        'awayName': event.awayName,
        'homeScore': event.homeScore,
        'awayScore': event.awayScore,
        'isLive': event.isLive,
        'gameTime': event.gameTime,
        'gamePart': event.gamePart,
        'status': event.status,
      });
      result.updatedEvents.add(event.eventId);
    } else {
      _store.insertEvent(event);
      result.addedEvents.add(event.eventId);
    }
  }

  /// Full sync for a sport with atomic reconciliation.
  ///
  /// Unlike simple clear + populate, this uses upsert logic
  /// to avoid UI flicker. Leagues/events are updated in place
  /// when possible, only removing truly stale data.
  ReconciliationResult fullSync({
    required int sportId,
    required List<LeagueData> apiLeagues,
  }) {
    _logger
        .info('Full sync for sport $sportId with ${apiLeagues.length} leagues');
    final startTime = DateTime.now();
    final result = ReconciliationResult();

    // Filter leagues for this sport
    final sportLeagues = apiLeagues.where((l) => l.sportId == sportId).toList();

    // Build set of valid league IDs from API
    final validLeagueIds = <int>{};

    // Upsert all leagues from API
    for (final league in sportLeagues) {
      validLeagueIds.add(league.leagueId);
      _processLeague(league, result);
    }

    // Remove stale leagues for this sport
    final currentLeagues = _store.getLeaguesBySport(sportId);
    for (final league in currentLeagues) {
      if (!validLeagueIds.contains(league.leagueId)) {
        // Remove all events in this league first
        final events = _store.getEventsByLeague(league.leagueId);
        for (final event in events) {
          _store.removeEvent(event.eventId);
          result.removedEvents.add(event.eventId);
        }

        _store.removeLeague(league.leagueId);
        result.removedLeagues.add(league.leagueId);
      }
    }

    _store.emitBatchChanges();

    final duration = DateTime.now().difference(startTime);
    _logger.info('Full sync complete: $result (${duration.inMilliseconds}ms)');

    return result;
  }
}
