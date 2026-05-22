import 'package:freezed_annotation/freezed_annotation.dart';

import 'common/filter_settings.dart';

part 'lobby_config.freezed.dart';
part 'lobby_config.g.dart';

/// Groups all lobby-related configuration under a single `lobby` key.
///
/// - [translationKey], [icon], [iconActive] — presentation config for the
///   "All / Home" tab. When null, the repository falls back to a hardcoded preset.
/// - [sections] — SDUI layout: the ordered list of content sections
///   rendered on the home lobby screen.
@freezed
abstract class LobbyConfig with _$LobbyConfig {
  const factory LobbyConfig({
    @JsonKey(name: 'translation_key') String? translationKey,
    String? icon,
    @JsonKey(name: 'icon_active') String? iconActive,
    @Default([]) List<LobbySectionConfig> sections,
  }) = _LobbyConfig;

  factory LobbyConfig.fromJson(Map<String, dynamic> json) => _$LobbyConfigFromJson(json);
}

/// {@template casino_lobby_section}
///
/// Each section defines what games to display via [filter], or a banner to show via [bannerId].
/// Use [isBanner] or [isGames] to determine the section type.
/// {@endtemplate}
@freezed
abstract class LobbySectionConfig with _$LobbySectionConfig {
  /// Defines a section in the casino lobby.
  /// - [title]: The display title for this section.
  /// - [filter]: The filter configuration defining which games to show.
  /// - [limit]: Maximum number of games to display (-1 for no limit).
  /// - [bannerId]: The unique identifier of the banner to render.
  const factory LobbySectionConfig({
    String? title,
    CaxiloFilter? filter,
    @Default(-1) int limit,
    @JsonKey(name: 'banner_id') String? bannerId,
  }) = _LobbySectionConfig;

  /// Creates a [LobbySectionConfig] from a JSON map.
  factory LobbySectionConfig.fromJson(Map<String, dynamic> json) =>
      _$LobbySectionConfigFromJson(json);
}

/// Helper extensions for [LobbySectionConfig] to easily access common fields.
extension LobbySectionConfigX on LobbySectionConfig {
  bool get isBanner => bannerId != null;
  bool get isGames => filter != null;
  String? get displayTitle => title;
  int get displayLimit => limit;
}
