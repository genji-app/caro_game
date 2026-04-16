import 'package:flutter/foundation.dart';

/// {@template game_provider}
/// Identifies a game provider with its unique ID and display name.
///
/// Used in [GameBlock] to carry provider context alongside game data.
/// {@endtemplate}
@immutable
class GameProvider {
  const GameProvider({required this.id, required this.name});

  /// The provider's unique API identifier (e.g. `'amb-vn'`).
  final String id;

  /// The provider's display name (e.g. `'SEXY'`).
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameProvider &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'GameProvider(id: $id, name: $name)';
}
