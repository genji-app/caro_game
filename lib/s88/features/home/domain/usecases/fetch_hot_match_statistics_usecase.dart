import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/repositories/hot_match_repository.dart';

/// Fetch Hot Match Statistics Use Case
///
/// Fetches bet statistics (simple + user-details) for given event IDs.
/// Used to enrich hot match carousel with bettingTrend and totalUsers.
class FetchHotMatchStatisticsUseCase {
  final HotMatchRepository _repository;

  FetchHotMatchStatisticsUseCase(this._repository);

  Future<Map<int, HotMatchEventStatistics>> call(
    List<HotMatchEventV2> matches,
    int sportId,
  ) async {
    return _repository.getBetStatisticsForEvents(matches, sportId);
  }
}
