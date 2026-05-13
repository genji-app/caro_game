import 'package:freezed_annotation/freezed_annotation.dart';

import 'common/filter_settings.dart';

part 'category_config.freezed.dart';
part 'category_config.g.dart';

/// {@template caxilo_category_config}
/// Represents a game category configuration from the remote settings.
///
/// Each category defines a specific filtering strategy to display a list of games.
/// Standardized through [CaxiloFilter].
/// {@endtemplate}
@freezed
abstract class CategoryConfig with _$CategoryConfig {
  const factory CategoryConfig({
    required String id,
    @JsonKey(name: 'translation_key') required String translationKey,
    required String icon,
    @JsonKey(name: 'icon_active') required String iconActive,
    required CaxiloFilter filter,

    /// Optional sidebar group key. Supported values: 'priority', 'standard'.
    /// When absent, the repository falls back to type-based classification.
    @JsonKey(name: 'group_key') String? groupKey,
  }) = _CategoryConfig;

  /// Creates a [CategoryConfig] from a JSON map.
  factory CategoryConfig.fromJson(Map<String, dynamic> json) => _$CategoryConfigFromJson(json);
}
