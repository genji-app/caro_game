import 'package:freezed_annotation/freezed_annotation.dart';

import 'in_house_game.dart';
import 'in_house_game_visibility.dart';

part 'in_house_config.freezed.dart';
part 'in_house_config.g.dart';

/// Aggregator for all in-house game configurations.
///
/// Combines technical data (catalog) with operational status (visibility).
@freezed
abstract class InHouseConfig with _$InHouseConfig {
  /// Defines the JSON structure for the 'in_house' section.
  const factory InHouseConfig({
    /// List of technical game catalog entries.
    @Default([]) List<InHouseGame> catalog,

    /// Map of game codes to their respective visibility and status.
    @Default({}) Map<String, InHouseGameVisibility> visibility,
  }) = _InHouseConfig;

  /// Creates a [InHouseConfig] from a JSON map.
  factory InHouseConfig.fromJson(Map<String, dynamic> json) => _$InHouseConfigFromJson(json);
}
