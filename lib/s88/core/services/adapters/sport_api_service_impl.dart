import 'package:flutter/foundation.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart' as freezed;
import 'package:co_caro_flame/s88/features/sport/domain/repositories/sport_repository.dart';

/// Implementation of ISportApiService using V2 API.
///
/// This adapter bridges the sport_socket library's API service interface
/// with the app's EventsV2RemoteDataSource (new V2 API).
///
/// The conversion flow:
/// 1. EventsV2RemoteDataSource fetches data from V2 API (/api/app/events)
/// 2. Returns LeagueModelV2 (Freezed)
/// 3. Convert to legacy LeagueData using .toLegacy()
/// 4. Convert to JSON for ModelConverter
/// 5. ModelConverter populates SportDataStore
///
/// Note: SportRepository is kept for backward compatibility with methods
/// that don't have V2 equivalents yet (fetchHotLeagues, fetchLeagueDetail).
class SportApiServiceImpl implements socket.ISportApiService {
  final SportRepository _repository;
  final EventsV2RemoteDataSource _v2DataSource;

  /// Tag for debug logging
  static const _tag = '[SportApiServiceV2]';

  SportApiServiceImpl({
    required SportRepository repository,
    required EventsV2RemoteDataSource v2DataSource,
  }) : _repository = repository,
       _v2DataSource = v2DataSource;

  @override
  Future<List<socket.LeagueData>> fetchEarlyLeagues({
    required int sportId,
    int? days,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      '$_tag 📡 FETCH EARLY/TODAY - sportId: $sportId, days: ${days ?? 0}',
    );

    final result = await _repository.getLeagues(
      sportId: sportId,
      days: days ?? 0,
      isLive: false,
    );

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ EARLY/TODAY FAILED - sportId: $sportId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        return <socket.LeagueData>[];
      },
      (freezedLeagues) {
        final leagues = _convertLeagues(freezedLeagues, sportId);
        final totalEvents = freezedLeagues.fold<int>(
          0,
          (sum, l) => sum + (l.events.length),
        );
        debugPrint(
          '$_tag ✅ EARLY/TODAY SUCCESS - sportId: $sportId, leagues: ${leagues.length}, events: $totalEvents (${stopwatch.elapsedMilliseconds}ms)',
        );
        return leagues;
      },
    );
  }

  @override
  Future<List<socket.LeagueData>> fetchLiveLeagues({
    required int sportId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH LIVE - sportId: $sportId');

    // Temporarily change sport if needed
    if (_repository.currentSportId != sportId) {
      await _repository.changeSport(sportId);
    }

    final result = await _repository.getLiveLeagues();

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ LIVE FAILED - sportId: $sportId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        return <socket.LeagueData>[];
      },
      (freezedLeagues) {
        final leagues = _convertLeagues(freezedLeagues, sportId);
        final totalEvents = freezedLeagues.fold<int>(
          0,
          (sum, l) => sum + (l.events.length),
        );
        debugPrint(
          '$_tag ✅ LIVE SUCCESS - sportId: $sportId, leagues: ${leagues.length}, events: $totalEvents (${stopwatch.elapsedMilliseconds}ms)',
        );
        return leagues;
      },
    );
  }

  @override
  Future<List<socket.LeagueData>> fetchHotLeagues({
    required int sportId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH HOT - sportId: $sportId');

    // Temporarily change sport if needed
    if (_repository.currentSportId != sportId) {
      await _repository.changeSport(sportId);
    }

    final result = await _repository.getHotLeagues();

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ HOT FAILED - sportId: $sportId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        return <socket.LeagueData>[];
      },
      (freezedLeagues) {
        final leagues = _convertLeagues(freezedLeagues, sportId);
        final totalEvents = freezedLeagues.fold<int>(
          0,
          (sum, l) => sum + (l.events.length),
        );
        debugPrint(
          '$_tag ✅ HOT SUCCESS - sportId: $sportId, leagues: ${leagues.length}, events: $totalEvents (${stopwatch.elapsedMilliseconds}ms)',
        );
        return leagues;
      },
    );
  }

  @override
  Future<socket.LeagueData?> fetchLeagueDetail({
    required int sportId,
    required int leagueId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      '$_tag 📡 FETCH LEAGUE DETAIL - sportId: $sportId, leagueId: $leagueId',
    );

    // This would require a specific API endpoint for single league
    // For now, fetch all leagues and filter
    final result = await _repository.getLeagues(sportId: sportId);

    stopwatch.stop();

    return result.fold(
      (failure) {
        debugPrint(
          '$_tag ❌ LEAGUE DETAIL FAILED - leagueId: $leagueId, error: $failure (${stopwatch.elapsedMilliseconds}ms)',
        );
        return null;
      },
      (freezedLeagues) {
        final freezedLeague = freezedLeagues.firstWhere(
          (l) => l.leagueId == leagueId,
          orElse: () => const freezed.LeagueData(),
        );

        if (freezedLeague.leagueId == 0) {
          debugPrint(
            '$_tag ⚠️ LEAGUE DETAIL NOT FOUND - leagueId: $leagueId (${stopwatch.elapsedMilliseconds}ms)',
          );
          return null;
        }

        debugPrint(
          '$_tag ✅ LEAGUE DETAIL SUCCESS - leagueId: $leagueId, events: ${freezedLeague.events.length} (${stopwatch.elapsedMilliseconds}ms)',
        );
        return _convertLeague(freezedLeague, sportId);
      },
    );
  }

  /// Convert a list of Freezed LeagueData to Library LeagueData
  List<socket.LeagueData> _convertLeagues(
    List<freezed.LeagueData> freezedLeagues,
    int sportId,
  ) {
    return freezedLeagues.map((l) => _convertLeague(l, sportId)).toList();
  }

  /// Convert a single Freezed LeagueData to Library LeagueData
  socket.LeagueData _convertLeague(freezed.LeagueData freezed, int sportId) {
    // Use ModelConverter for the conversion
    return socket.ModelConverter.fromFreezedLeague(
      freezed.toJson(),
      sportId: sportId,
    );
  }

  @override
  Future<void> fetchLiveAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH LIVE & POPULATE (V2 API) - sportId: $sportId');

    try {
      // Use V2 API
      final v2Leagues = await _v2DataSource.getLiveEvents(sportId);

      stopwatch.stop();

      if (v2Leagues.isEmpty) {
        debugPrint(
          '$_tag ⚠️ LIVE EMPTY - keeping existing data '
          '(${stopwatch.elapsedMilliseconds}ms)',
        );
        return;
      }

      // Convert V2 → Legacy → JSON for ModelConverter
      final jsonLeagues = v2Leagues
          .toLegacy()
          .map((l) => l.toJson())
          .toList()
          .cast<Map<String, dynamic>>();

      // UPSERT full hierarchy into store
      socket.ModelConverter.upsertPopulateDataStore(
        jsonLeagues,
        store,
        sportId: sportId,
        timeRange: socket.TimeRange.live,
      );

      // Emit changes
      store.emitBatchChanges();

      // Stats logging disabled for LIVE to reduce noise
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
        '$_tag ❌ LIVE POPULATE FAILED (${stopwatch.elapsedMilliseconds}ms): $e',
      );
      debugPrint('Stack: $stack');
      // Do NOT rethrow - keep existing data on failure
    }
  }

  @override
  Future<void> fetchTodayAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH TODAY & POPULATE (V2 API) - sportId: $sportId');

    try {
      // Use V2 API
      final v2Leagues = await _v2DataSource.getTodayEvents(sportId);

      stopwatch.stop();

      if (v2Leagues.isEmpty) {
        debugPrint(
          '$_tag ⚠️ TODAY EMPTY - keeping existing data '
          '(${stopwatch.elapsedMilliseconds}ms)',
        );
        return;
      }

      // Convert V2 → Legacy → JSON for ModelConverter
      final jsonLeagues = v2Leagues
          .toLegacy()
          .map((l) => l.toJson())
          .toList()
          .cast<Map<String, dynamic>>();

      // UPSERT full hierarchy into store
      socket.ModelConverter.upsertPopulateDataStore(
        jsonLeagues,
        store,
        sportId: sportId,
        timeRange: socket.TimeRange.today,
      );

      // Emit changes
      store.emitBatchChanges();

      // Log stats
      final storeLeagues = store.getLeaguesBySport(sportId);
      int eventCount = 0;
      for (final league in storeLeagues) {
        eventCount += store.getEventsByLeague(league.leagueId).length;
      }

      debugPrint(
        '$_tag ✅ TODAY POPULATE DONE\n'
        '   └─ API: ${v2Leagues.length} leagues\n'
        '   └─ Store: ${storeLeagues.length} leagues, $eventCount events\n'
        '   └─ Duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
        '$_tag ❌ TODAY POPULATE FAILED (${stopwatch.elapsedMilliseconds}ms): $e',
      );
      debugPrint('Stack: $stack');
      // Do NOT rethrow - keep existing data on failure
    }
  }

  @override
  Future<void> fetchEarlyAndPopulate({
    required int sportId,
    required socket.SportDataStore store,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH EARLY & POPULATE (V2 API) - sportId: $sportId');

    try {
      // Use V2 API
      final v2Leagues = await _v2DataSource.getEarlyEvents(sportId);

      stopwatch.stop();

      if (v2Leagues.isEmpty) {
        debugPrint(
          '$_tag ⚠️ EARLY EMPTY - keeping existing data '
          '(${stopwatch.elapsedMilliseconds}ms)',
        );
        return;
      }

      // Convert V2 → Legacy → JSON for ModelConverter
      final jsonLeagues = v2Leagues
          .toLegacy()
          .map((l) => l.toJson())
          .toList()
          .cast<Map<String, dynamic>>();

      // UPSERT full hierarchy into store
      socket.ModelConverter.upsertPopulateDataStore(
        jsonLeagues,
        store,
        sportId: sportId,
        timeRange: socket.TimeRange.early,
      );

      // Emit changes
      store.emitBatchChanges();

      // Log stats
      final leagues = store.getLeaguesBySport(sportId);
      int totalEvents = 0;
      for (final league in leagues) {
        totalEvents += store.getEventsByLeague(league.leagueId).length;
      }

      debugPrint(
        '$_tag ✅ EARLY POPULATE DONE\n'
        '   └─ API: ${v2Leagues.length} leagues\n'
        '   └─ Store: ${leagues.length} leagues, $totalEvents events\n'
        '   └─ Duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
        '$_tag ❌ EARLY POPULATE FAILED (${stopwatch.elapsedMilliseconds}ms): $e',
      );
      debugPrint('Stack: $stack');
      // Do NOT rethrow - keep existing data on failure
    }
  }
}
