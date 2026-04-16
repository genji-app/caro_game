import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';

/// State for live football matches on homepage
///
/// Displays top 5 matches with highest odds, grouped by league.
/// Only fetches data once when first accessed.
class LiveFootballHomeState {
  /// Leagues containing only the top 5 highest odds matches
  final List<LeagueData> leagues;

  /// Loading state
  final bool isLoading;

  /// Error message
  final String? error;

  /// Whether data has been fetched
  final bool hasFetched;

  const LiveFootballHomeState({
    this.leagues = const [],
    this.isLoading = false,
    this.error,
    this.hasFetched = false,
  });

  LiveFootballHomeState copyWith({
    List<LeagueData>? leagues,
    bool? isLoading,
    String? error,
    bool? hasFetched,
  }) {
    return LiveFootballHomeState(
      leagues: leagues ?? this.leagues,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasFetched: hasFetched ?? this.hasFetched,
    );
  }

  /// Total number of matches displayed
  int get totalMatches => leagues.fold(0, (sum, l) => sum + l.events.length);
}

/// Provider for live football matches on homepage
///
/// Features:
/// - Only fetches football (sportId=1) live matches
/// - Calls API only once when first accessed
/// - Filters top 5 matches by highest decimal odds
/// - Groups results by league
class LiveFootballHomeNotifier extends StateNotifier<LiveFootballHomeState> {
  final SbHttpManager _httpManager;

  /// Maximum number of matches to display
  static const int maxMatches = 5;

  LiveFootballHomeNotifier(this._httpManager)
    : super(const LiveFootballHomeState());

  /// Fetch live football matches
  ///
  /// Only fetches once. Subsequent calls are no-op unless [force] is true.
  Future<void> fetchLiveFootball({bool force = false}) async {
    // Don't refetch if already fetched (unless forced)
    if (state.hasFetched && !force) return;

    // Don't fetch if already loading
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch live football matches (sportId=1)
      final allLeagues = await _httpManager.getLeagues(
        sportId: 1, // Football
        isLive: true,
      );

      // Process and filter top 5 matches by highest odds
      final filteredLeagues = _filterTop5ByHighestOdds(allLeagues);

      state = state.copyWith(
        leagues: filteredLeagues,
        isLoading: false,
        hasFetched: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasFetched: true,
      );
    }
  }

  /// Fetch live football matches silently (no loading state)
  ///
  /// Use this when returning to sport page to refresh data in background.
  /// Always fetches fresh data from API with sportId=1 (Football).
  Future<void> fetchLiveFootballSilent() async {
    // Don't fetch if already loading
    if (state.isLoading) return;

    // debugPrint('🏠 [LiveFootballHome] Silent refresh with sportId=1 (Football)');

    try {
      // Fetch live football matches (sportId=1)
      final allLeagues = await _httpManager.getLeagues(
        sportId: 1, // Football - always hardcoded
        isLive: true,
      );
      // debugPrint('🏠 [LiveFootballHome] Silent refresh: API returned ${allLeagues.length} leagues');

      // Process and filter top 5 matches by highest odds
      final filteredLeagues = _filterTop5ByHighestOdds(allLeagues);

      state = state.copyWith(
        leagues: filteredLeagues,
        isLoading: false,
        hasFetched: true,
        error: null,
      );
    } catch (e) {
      // Silent fail - keep old data
      debugPrint('🏠 [LiveFootballHome] Silent refresh failed: $e');
    }
  }

  /// Filter leagues to contain only top 5 matches with highest odds
  ///
  /// Algorithm:
  /// 1. Collect all live events with their max odds
  /// 2. Sort by max odds descending
  /// 3. Take top 5
  /// 4. Group back by league
  List<LeagueData> _filterTop5ByHighestOdds(List<LeagueData> allLeagues) {
    // Collect all events with their max odds and league info
    final eventsWithOdds = <_EventWithMaxOdds>[];

    for (final league in allLeagues) {
      for (final event in league.events) {
        // Only include live events
        if (!event.isLive) continue;

        final maxOdds = _getMaxOddsForEvent(event);
        eventsWithOdds.add(
          _EventWithMaxOdds(event: event, league: league, maxOdds: maxOdds),
        );
      }
    }

    // Sort by max odds descending
    eventsWithOdds.sort((a, b) => b.maxOdds.compareTo(a.maxOdds));

    // Take top 5
    final top5Events = eventsWithOdds.take(maxMatches).toList();

    // Group by league while preserving order
    final leagueMap = <int, List<LeagueEventData>>{};
    final leagueDataMap = <int, LeagueData>{};
    final leagueOrder = <int>[]; // To preserve order

    for (final item in top5Events) {
      final leagueId = item.league.leagueId;
      if (!leagueMap.containsKey(leagueId)) {
        leagueMap[leagueId] = [];
        leagueDataMap[leagueId] = item.league;
        leagueOrder.add(leagueId);
      }
      leagueMap[leagueId]!.add(item.event);
    }

    // Build result leagues in order
    final result = <LeagueData>[];
    for (final leagueId in leagueOrder) {
      final originalLeague = leagueDataMap[leagueId]!;
      final events = leagueMap[leagueId]!;
      result.add(originalLeague.copyWith(events: events));
    }

    return result;
  }

  /// Get maximum decimal odds from all markets of an event
  double _getMaxOddsForEvent(LeagueEventData event) {
    double maxOdds = 0;

    for (final market in event.markets) {
      for (final odds in market.odds) {
        // Check home odds
        if (odds.oddsHome.decimal > maxOdds && odds.oddsHome.decimal != -100) {
          maxOdds = odds.oddsHome.decimal;
        }
        // Check away odds
        if (odds.oddsAway.decimal > maxOdds && odds.oddsAway.decimal != -100) {
          maxOdds = odds.oddsAway.decimal;
        }
        // Check draw odds (for 1X2 markets)
        if (odds.oddsDraw.decimal > maxOdds && odds.oddsDraw.decimal != -100) {
          maxOdds = odds.oddsDraw.decimal;
        }

        // Also check legacy fields
        if (odds.homeOddsLegacy != null && odds.homeOddsLegacy! > maxOdds) {
          maxOdds = odds.homeOddsLegacy!;
        }
        if (odds.awayOddsLegacy != null && odds.awayOddsLegacy! > maxOdds) {
          maxOdds = odds.awayOddsLegacy!;
        }
        if (odds.drawOddsLegacy != null && odds.drawOddsLegacy! > maxOdds) {
          maxOdds = odds.drawOddsLegacy!;
        }
      }
    }

    return maxOdds;
  }

  /// Reset state to allow refetching
  void reset() {
    state = const LiveFootballHomeState();
  }
}

/// Helper class to hold event with its max odds for sorting
class _EventWithMaxOdds {
  final LeagueEventData event;
  final LeagueData league;
  final double maxOdds;

  _EventWithMaxOdds({
    required this.event,
    required this.league,
    required this.maxOdds,
  });
}

// ===== PROVIDERS =====

/// Provider for live football home state
final liveFootballHomeProvider =
    StateNotifierProvider<LiveFootballHomeNotifier, LiveFootballHomeState>((
      ref,
    ) {
      final httpManager = SbHttpManager.instance;
      return LiveFootballHomeNotifier(httpManager);
    });

/// Provider for leagues with top 5 highest odds matches
final liveFootballLeaguesProvider = Provider<List<LeagueData>>((ref) {
  return ref.watch(liveFootballHomeProvider).leagues;
});

/// Provider for loading state
final liveFootballLoadingProvider = Provider<bool>((ref) {
  return ref.watch(liveFootballHomeProvider).isLoading;
});

/// Provider for error state
final liveFootballErrorProvider = Provider<String?>((ref) {
  return ref.watch(liveFootballHomeProvider).error;
});
