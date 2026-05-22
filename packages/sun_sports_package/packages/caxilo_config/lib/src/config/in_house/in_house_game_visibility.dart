import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/game_status.dart';

part 'in_house_game_visibility.freezed.dart';
part 'in_house_game_visibility.g.dart';

/// Default fallback for games not explicitly configured in visibility block.
const kDefaultInHouseGameVisibility = InHouseGameVisibility(
  isVisible: false,
  status: GameStatus.underDevelopment,
);

/// Decision model for game visibility and operational state.
@freezed
abstract class InHouseGameVisibility with _$InHouseGameVisibility {
  /// Defines the JSON structure for a game's visibility settings.
  const factory InHouseGameVisibility({
    /// Whether the game is visible in the lobby.
    @JsonKey(name: 'is_visible') @Default(false) bool isVisible,

    /// Detailed operational status affecting UI rendering and clickability.
    @JsonKey(name: 'status') @Default(GameStatus.underDevelopment) GameStatus status,
  }) = _InHouseGameVisibility;

  /// Creates a [InHouseGameVisibility] from a JSON map.
  factory InHouseGameVisibility.fromJson(Map<String, dynamic> json) =>
      _$InHouseGameVisibilityFromJson(json);
}
