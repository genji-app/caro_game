import 'package:json_annotation/json_annotation.dart';

/// Represents the current operational status of a casino game.
enum GameStatus {
  /// The game is fully operational and playable.
  active,

  /// The game is undergoing maintenance.
  maintenance,

  /// The game is announced but not yet playable.
  @JsonValue('coming_soon')
  comingSoon,

  /// The game is in internal development.
  @JsonValue('under_development')
  underDevelopment,

  /// The game is explicitly disabled and hidden.
  disabled,

  /// Fallback for unknown/unsupported statuses.
  unknown;

  /// Parses a string into a [GameStatus].
  /// Returns [GameStatus.unknown] if the value is not recognized.
  static GameStatus fromJson(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'coming_soon') return GameStatus.comingSoon;
    if (normalized == 'under_development') {
      return GameStatus.underDevelopment;
    }

    return GameStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => GameStatus.unknown,
    );
  }

  /// Converts the enum to a string for JSON serialization.
  String toJson() => switch (this) {
    comingSoon => 'coming_soon',
    underDevelopment => 'under_development',
    _ => name,
  };
}
