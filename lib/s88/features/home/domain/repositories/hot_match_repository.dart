import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';

/// Hot Match Repository Interface
///
/// Abstract interface defining contract for hot match data operations.
/// Follows Clean Architecture - domain layer defines interface,
/// data layer provides implementation.
abstract class HotMatchRepository {
  /// Fetch hot matches from API (V2 live events).
  ///
  /// Returns [Right] with list of [LeagueModelV2] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<LeagueModelV2>>> getHotMatches();

  /// Enrich hot match list with bet statistics (bettingTrend, totalUsers) via _enrichHotMatchesWithStatistics.
  /// Returns map eventId -> HotMatchEventStatistics for state.eventStatistics.
  Future<Map<int, HotMatchEventStatistics>> getBetStatisticsForEvents(
    List<HotMatchEventV2> matches,
    int sportId,
  );

  /// Stream bet statistics for all matches concurrently.
  ///
  /// Fires both /bet/statistics/simple và /bet/statistics/users song song cho mỗi match.
  /// Emit [MapEntry<eventId, HotMatchEventStatistics>] ngay khi từng match hoàn thành
  /// (không chờ cả batch) — cho phép notifier update state progressively.
  ///
  /// [maxConcurrent]: số lượng match xử lý đồng thời tối đa (default 10).
  Stream<MapEntry<int, HotMatchEventStatistics>> streamBetStatistics(
    List<HotMatchEventV2> matches,
    int sportId, {
    int maxConcurrent = 10,
  });

  /// Subscribe to WebSocket events for hot matches
  ///
  /// [eventIds] - List of event IDs to subscribe to
  void subscribeToEvents(List<int> eventIds);

  /// Unsubscribe from WebSocket events
  ///
  /// [eventIds] - List of event IDs to unsubscribe from
  void unsubscribeFromEvents(List<int> eventIds);

  /// Get stream of odds updates
  Stream<OddsUpdateEvent> get oddsUpdates;

  /// Get stream of score updates
  Stream<ScoreUpdateEvent> get scoreUpdates;
}

/// Odds Update Event
///
/// Domain-level event for odds changes from WebSocket.
class OddsUpdateEvent {
  final int eventId;
  final int marketId;
  final String selectionId;
  final double newOdds;

  const OddsUpdateEvent({
    required this.eventId,
    required this.marketId,
    required this.selectionId,
    required this.newOdds,
  });
}

/// Score Update Event
///
/// Domain-level event for score changes from WebSocket.
class ScoreUpdateEvent {
  final int eventId;
  final int homeScore;
  final int awayScore;

  const ScoreUpdateEvent({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
  });
}
