/// Strategy defining how a game URL and parameters are constructed.
enum GameLaunchStrategy {
  /// Standard slot or card game launch flow.
  standard,

  /// Fish shooting game specific launch flow.
  fish,

  /// Strategy for games that are still under development.
  underDevelopment,

  /// Fallback for unknown/unsupported launch strategies.
  unknown;

  /// Parses a string into a [GameLaunchStrategy].
  /// Returns [GameLaunchStrategy.unknown] if the value is not recognized.
  static GameLaunchStrategy fromJson(String value) => GameLaunchStrategy.values.firstWhere(
    (e) => e.name == value,
    orElse: () => GameLaunchStrategy.unknown,
  );

  /// Converts the enum to a string for JSON serialization.
  String toJson() => name;
}
