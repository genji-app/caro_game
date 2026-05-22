import 'models/caxilo_game_block.dart';

/// {@template caxilo_storage}
/// An interface for storing/caching game data.
/// {@endtemplate}
abstract class CaxiloStorage {
  /// Returns the stored list of [CaxiloGameBlock] if available and valid.
  List<CaxiloGameBlock>? get();

  /// Updates the storage with a new list of [CaxiloGameBlock].
  void set(List<CaxiloGameBlock> games);

  /// Clears the storage.
  void clear();
}

/// {@template in_memory_caxilo_storage}
/// An in-memory implementation of [CaxiloStorage] with a time-to-live (TTL).
/// {@endtemplate}
class InMemoryCaxiloStorage implements CaxiloStorage {
  /// {@macro in_memory_caxilo_storage}
  InMemoryCaxiloStorage({required Duration ttl}) : _ttl = ttl;

  final Duration _ttl;
  List<CaxiloGameBlock>? _games;
  DateTime? _lastFetchTime;

  @override
  List<CaxiloGameBlock>? get() {
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
  void set(List<CaxiloGameBlock> games) {
    _games = games;
    _lastFetchTime = DateTime.now();
  }

  @override
  void clear() {
    _games = null;
    _lastFetchTime = null;
  }
}
