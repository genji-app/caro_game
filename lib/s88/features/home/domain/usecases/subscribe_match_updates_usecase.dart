import 'package:co_caro_flame/s88/features/home/domain/repositories/hot_match_repository.dart';

/// Subscribe Match Updates Use Case
///
/// Single responsibility: Manage WebSocket subscriptions for match updates.
class SubscribeMatchUpdatesUseCase {
  final HotMatchRepository _repository;

  SubscribeMatchUpdatesUseCase(this._repository);

  /// Subscribe to events
  void subscribe(List<int> eventIds) {
    _repository.subscribeToEvents(eventIds);
  }

  /// Unsubscribe from events
  void unsubscribe(List<int> eventIds) {
    _repository.unsubscribeFromEvents(eventIds);
  }

  /// Get odds updates stream
  Stream<OddsUpdateEvent> get oddsUpdates => _repository.oddsUpdates;

  /// Get score updates stream
  Stream<ScoreUpdateEvent> get scoreUpdates => _repository.scoreUpdates;
}
