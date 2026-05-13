// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lobby_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LobbyConfig _$LobbyConfigFromJson(Map<String, dynamic> json) => _LobbyConfig(
  translationKey: json['translation_key'] as String?,
  icon: json['icon'] as String?,
  iconActive: json['icon_active'] as String?,
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map((e) => LobbySectionConfig.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LobbyConfigToJson(_LobbyConfig instance) =>
    <String, dynamic>{
      'translation_key': instance.translationKey,
      'icon': instance.icon,
      'icon_active': instance.iconActive,
      'sections': instance.sections.map((e) => e.toJson()).toList(),
    };

_LobbySectionConfig _$LobbySectionConfigFromJson(Map<String, dynamic> json) =>
    _LobbySectionConfig(
      title: json['title'] as String?,
      filter: json['filter'] == null
          ? null
          : CaxiloFilter.fromJson(json['filter'] as Map<String, dynamic>),
      limit: (json['limit'] as num?)?.toInt() ?? -1,
      bannerId: json['banner_id'] as String?,
    );

Map<String, dynamic> _$LobbySectionConfigToJson(_LobbySectionConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'filter': instance.filter?.toJson(),
      'limit': instance.limit,
      'banner_id': instance.bannerId,
    };
