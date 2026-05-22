import 'package:freezed_annotation/freezed_annotation.dart';

part 'external_game.freezed.dart';
part 'external_game.g.dart';

/// {@template external_game}
/// Configuration for a single 3rd-party (external) game.
/// {@endtemplate}
@freezed
abstract class ExternalGame with _$ExternalGame {
  const factory ExternalGame({
    /// Unique short code for the game (e.g., 'mx-live-001').
    @JsonKey(name: 'game_code') required String gameCode,

    /// Optional file path or name for the game thumbnail.
    /// If null, a fallback naming convention may be used.
    @JsonKey(name: 'image') String? image,
  }) = _ExternalGame;

  /// Creates a [ExternalGame] from a JSON map.
  factory ExternalGame.fromJson(Map<String, dynamic> json) => _$ExternalGameFromJson(json);
}
