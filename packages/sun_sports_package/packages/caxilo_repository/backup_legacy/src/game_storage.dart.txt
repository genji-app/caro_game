import 'models/game_block.dart';

/// {@template game_storage}
/// An interface for storing/caching game data.
/// {@endtemplate}
abstract class GameStorage {
  /// Returns the stored list of [GameBlock] if available and valid.
  List<GameBlock>? get();

  /// Updates the storage with a new list of [GameBlock].
  void set(List<GameBlock> games);

  /// Clears the storage.
  void clear();
}

/// {@template in_memory_game_storage}
/// An in-memory implementation of [GameStorage] with a time-to-live (TTL).
/// {@endtemplate}
class InMemoryGameStorage implements GameStorage {
  /// {@macro in_memory_game_storage}
  InMemoryGameStorage({required Duration ttl}) : _ttl = ttl;

  final Duration _ttl;
  List<GameBlock>? _games;
  DateTime? _lastFetchTime;

  @override
  List<GameBlock>? get() {
    final lastFetchTime = _lastFetchTime;
    final games = _games;

    if (games == null || lastFetchTime == null) {
      return null;
    }

    final now = DateTime.now();
    if (now.difference(lastFetchTime) > _ttl) {
      clear();
      return null;
    }

    return games;
  }

  @override
  void set(List<GameBlock> games) {
    _games = games;
    _lastFetchTime = DateTime.now();
  }

  @override
  void clear() {
    _games = null;
    _lastFetchTime = null;
  }
}
