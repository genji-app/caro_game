import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_config.dart';
import 'display_config.dart';
import 'external/external_config.dart';
import 'in_house/in_house_config.dart';
import 'lobby_config.dart';

part 'caxilo_config.freezed.dart';
part 'caxilo_config.g.dart';

/// {@template caxilo_config}
/// The root configuration model for the casino module.
///
/// It aggregates all sub-configurations like display orders, categories,
/// and in-house/external provider game settings.
/// {@endtemplate}
// Formerly CasinoSettings.
@freezed
abstract class CaxiloConfig with _$CaxiloConfig {
  const factory CaxiloConfig({
    /// ISO 8601 timestamp of the last configuration update.
    @JsonKey(name: 'updated_at') required String updatedAt,

    /// Schema version for backward compatibility checks.
    @Default(1) int version,

    /// Global map of environment variables (mostly base URLs).
    @Default({}) Map<String, String> environments,

    /// Configuration for game display and marketing (shared across modules).
    @Default(DisplayConfig()) DisplayConfig display,

    /// Lobby feature config: "All / Home" tab presentation + SDUI home sections.
    /// When null, the repository falls back to hardcoded presets.
    LobbyConfig? lobby,

    /// List of game categories to be displayed in the lobby.
    @Default([]) List<CategoryConfig> categories,

    /// Configuration specific to in-house games.
    @Default(InHouseConfig()) @JsonKey(name: 'in_house') InHouseConfig inHouse,

    /// Configuration specific to 3rd-party remote providers.
    @Default(ExternalConfig()) @JsonKey(name: 'external') ExternalConfig external,
  }) = _CaxiloConfig;

  /// Creates a [CaxiloConfig] from a JSON map.
  factory CaxiloConfig.fromJson(Map<String, dynamic> json) => _$CaxiloConfigFromJson(json);
}
