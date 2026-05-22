// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caxilo_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaxiloConfig _$CaxiloConfigFromJson(Map<String, dynamic> json) =>
    _CaxiloConfig(
      updatedAt: json['updated_at'] as String,
      version: (json['version'] as num?)?.toInt() ?? 1,
      environments:
          (json['environments'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      display: json['display'] == null
          ? const DisplayConfig()
          : DisplayConfig.fromJson(json['display'] as Map<String, dynamic>),
      lobby: json['lobby'] == null
          ? null
          : LobbyConfig.fromJson(json['lobby'] as Map<String, dynamic>),
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      inHouse: json['in_house'] == null
          ? const InHouseConfig()
          : InHouseConfig.fromJson(json['in_house'] as Map<String, dynamic>),
      external: json['external'] == null
          ? const ExternalConfig()
          : ExternalConfig.fromJson(json['external'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CaxiloConfigToJson(_CaxiloConfig instance) =>
    <String, dynamic>{
      'updated_at': instance.updatedAt,
      'version': instance.version,
      'environments': instance.environments,
      'display': instance.display.toJson(),
      'lobby': instance.lobby?.toJson(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'in_house': instance.inHouse.toJson(),
      'external': instance.external.toJson(),
    };
