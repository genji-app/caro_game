import 'package:freezed_annotation/freezed_annotation.dart';

part 'display_config.freezed.dart';
part 'display_config.g.dart';

/// Presentation and marketing configuration for the casino lobby.
@freezed
abstract class DisplayConfig with _$DisplayConfig {
  /// Defines how games are ordered and highlighted in the UI.
  const factory DisplayConfig({
    /// List of game codes in the desired display order.
    @Default([]) List<String> order,

    /// Arbitrary collections of games defined by the server (e.g., "popular", "hot").
    /// Map key is the collection ID, value is the list of game codes.
    @Default({}) Map<String, List<String>> collections,
  }) = _DisplayConfig;

  /// Creates a [DisplayConfig] from a JSON map.
  factory DisplayConfig.fromJson(Map<String, dynamic> json) => _$DisplayConfigFromJson(json);
}
