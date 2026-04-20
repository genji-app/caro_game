import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_games.freezed.dart';
part 'provider_games.g.dart';

/// Game type enum
enum GameType {
  /// Slot games
  slot(1),

  /// Sports betting
  sport(2),

  /// Jackpot games
  jackpot(3),

  /// Card games
  card(4),

  /// Dice games
  dice(5),

  /// Live casino
  live(6),

  /// Lottery games
  lottery(7),

  /// Mini games
  miniGame(8),

  /// Fishing games
  fishing(9),

  /// Other games
  others(20),

  /// Unknown game type (fallback)
  unknown(-1);

  const GameType(this.value);

  /// Numeric value from API
  final int value;

  /// Get GameType from int value
  static GameType fromValue(int value) {
    return GameType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GameType.unknown,
    );
  }

  /// Convert int to GameType
  static GameType fromJson(int value) => GameType.fromValue(value);

  /// Convert GameType to int
  static int toJson(GameType type) => type.value;
}

/// Provider model containing game list
@freezed
sealed class ProviderGames with _$ProviderGames {
  const factory ProviderGames({
    @JsonKey(name: 'providerId') required String providerId,
    @JsonKey(name: 'providerName') required String providerName,
    @JsonKey(name: 'gameList') @Default([]) List<Game> gameList,
  }) = _ProviderGames;

  factory ProviderGames.fromJson(Map<String, dynamic> json) => _$ProviderGamesFromJson(json);
}

/// Game model
@freezed
sealed class Game with _$Game {
  const factory Game({
    @JsonKey(name: 'productId') required String productId,
    @JsonKey(name: 'gameCode') required String gameCode,
    @JsonKey(name: 'gameName') required String gameName,
    @JsonKey(name: 'lang') required String lang,
    @JsonKey(name: 'lobbyUrl') required String lobbyUrl,
    @JsonKey(name: 'cashierUrl') required String cashierUrl,
    @JsonKey(
      name: 'gameType',
      fromJson: GameType.fromJson,
      toJson: GameType.toJson,
    )
    required GameType gameType,
    @JsonKey(name: 'mobileLogin') @Default(false) bool mobileLogin,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}
