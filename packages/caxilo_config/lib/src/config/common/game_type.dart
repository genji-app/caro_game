import 'package:json_annotation/json_annotation.dart';

/// The generic category of a casino game.
enum GameType {
  /// Slot machine games.
  slot,

  /// Sports betting.
  sport,

  /// Jackpot games.
  jackpot,

  /// Card/Table games.
  card,

  /// Dice games.
  dice,

  /// Live dealer games.
  live,

  /// Lottery games.
  lottery,

  /// Mini games (Xoc dia, Tai xiu, etc.)
  miniGame,

  /// Fish shooting games.
  @JsonValue('fish')
  fishing,

  /// Other types.
  others,

  /// Fallback for unknown/unsupported game types.
  unknown;

  /// Parses a string into a [GameType].
  /// Returns [GameType.unknown] if the value is not recognized.
  static GameType fromJson(dynamic value) {
    if (value is! String) return GameType.unknown;

    final normalized = value.toLowerCase().trim();
    if (normalized == 'fish') return GameType.fishing;
    if (normalized == 'cardgame') return GameType.card;

    return GameType.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => GameType.unknown,
    );
  }

  /// Converts the enum to a string for JSON serialization.
  String toJson() => name;

  /// Static helper for JSON serialization.
  static String staticToJson(GameType type) => type.toJson();
}
