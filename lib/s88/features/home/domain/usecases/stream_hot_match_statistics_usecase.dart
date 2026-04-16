import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/repositories/hot_match_repository.dart';

/// Stream Hot Match Statistics Use Case
///
/// Wraps [HotMatchRepository.streamBetStatistics] cho Clean Architecture.
///
/// Emit [MapEntry<eventId, HotMatchEventStatistics>] progressively:
/// mỗi khi một match hoàn thành cả hai API calls (/simple + /users),
/// kết quả được emit ngay — không chờ toàn bộ batch.
///
/// Cách dùng trong notifier:
/// ```dart
/// _statisticsStreamSub = _streamStatisticsUseCase(matches, sportId).listen(
///   (entry) => state = state.copyWith(
///     eventStatistics: {...state.eventStatistics, entry.key: entry.value},
///   ),
/// );
/// ```
class StreamHotMatchStatisticsUseCase {
  final HotMatchRepository _repository;

  StreamHotMatchStatisticsUseCase(this._repository);

  /// [maxConcurrent]: số match xử lý đồng thời (default 10).
  /// Với ~10-20 hot matches thông thường, 10 là hợp lý —
  /// đủ nhanh mà không gây áp lực quá lớn lên server.
  Stream<MapEntry<int, HotMatchEventStatistics>> call(
    List<HotMatchEventV2> matches,
    int sportId, {
    int maxConcurrent = 10,
  }) {
    return _repository.streamBetStatistics(
      matches,
      sportId,
      maxConcurrent: maxConcurrent,
    );
  }
}
