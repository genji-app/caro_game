import '../data/models/league_data.dart';
import '../data/sport_data_store.dart';

/// Interface for API service to fetch sport data.
///
/// This interface is implemented in the app layer and injected into
/// SportSocketClient for API integration.
///
/// Usage:
/// ```dart
/// class SportApiServiceImpl implements ISportApiService {
///   final SportRepository _repository;
///
///   @override
///   Future<List<LeagueData>> fetchEarlyLeagues({required int sportId}) async {
///     // Fetch from repository and convert to LeagueData
///   }
/// }
/// ```
abstract class ISportApiService {
  /// Fetch early/pre-match leagues for a sport.
  ///
  /// Returns leagues with events that haven't started yet.
  /// [sportId] - Sport ID (1=Football, 2=Basketball, etc.)
  /// [days] - Number of days ahead to fetch (optional)
  Future<List<LeagueData>> fetchEarlyLeagues({
    required int sportId,
    int? days,
  });

  /// Fetch live leagues for a sport.
  ///
  /// Returns leagues with events currently in play.
  /// [sportId] - Sport ID
  Future<List<LeagueData>> fetchLiveLeagues({
    required int sportId,
  });

  /// Fetch hot/featured leagues for a sport.
  ///
  /// Returns popular or featured leagues.
  /// [sportId] - Sport ID
  Future<List<LeagueData>> fetchHotLeagues({
    required int sportId,
  });

  /// Fetch detailed data for a specific league.
  ///
  /// Returns full league data with events, markets, and odds.
  /// Useful when user navigates to league detail view.
  /// [sportId] - Sport ID
  /// [leagueId] - League ID to fetch
  Future<LeagueData?> fetchLeagueDetail({
    required int sportId,
    required int leagueId,
  });

  /// Fetch LIVE leagues and populate store directly.
  ///
  /// This method fetches raw JSON with full hierarchy (leagues + events +
  /// markets + odds) and upserts directly into the store.
  ///
  /// Used for AutoRefresh - API is source of truth.
  /// Does NOT throw on failure - keeps existing data.
  ///
  /// [sportId] - Sport ID to fetch
  /// [store] - SportDataStore to populate
  Future<void> fetchLiveAndPopulate({
    required int sportId,
    required SportDataStore store,
  });

  /// Fetch TODAY leagues and populate store directly.
  ///
  /// This method fetches leagues for today (next 24 hours) with full hierarchy
  /// (leagues + events + markets + odds) and upserts directly into the store.
  ///
  /// Used for AutoRefresh when user is on TODAY tab.
  /// Does NOT throw on failure - keeps existing data.
  ///
  /// [sportId] - Sport ID to fetch
  /// [store] - SportDataStore to populate
  Future<void> fetchTodayAndPopulate({
    required int sportId,
    required SportDataStore store,
  });

  /// Fetch EARLY leagues and populate store directly.
  ///
  /// This method fetches leagues for early/future matches (2+ days) with full
  /// hierarchy (leagues + events + markets + odds) and upserts directly into the store.
  ///
  /// Used for AutoRefresh when user is on EARLY tab.
  /// Does NOT throw on failure - keeps existing data.
  ///
  /// [sportId] - Sport ID to fetch
  /// [store] - SportDataStore to populate
  Future<void> fetchEarlyAndPopulate({
    required int sportId,
    required SportDataStore store,
  });
}
