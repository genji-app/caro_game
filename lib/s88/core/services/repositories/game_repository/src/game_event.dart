import 'models/game_block.dart';

/// {@template game_event}
/// Events emitted by [GameRepository] to notify listeners of state changes.
///
/// Use [GameRepository.events] stream to subscribe:
/// ```dart
/// repository.events.listen((event) {
///   switch (event) {
///     case GameDataChanged(:final games):
///       print('Games updated: ${games.length}');
///   }
/// });
/// ```
/// {@endtemplate}
sealed class GameEvent {
  /// {@macro game_event}
  const GameEvent();
}

/// {@template game_data_changed}
/// Emitted when the game cache is refreshed with new data
/// (e.g., after a remote API fetch completes).
/// {@endtemplate}
class GameDataChanged extends GameEvent {
  /// {@macro game_data_changed}
  const GameDataChanged(this.games);

  /// The updated list of all games (local + remote).
  final List<GameBlock> games;
}
