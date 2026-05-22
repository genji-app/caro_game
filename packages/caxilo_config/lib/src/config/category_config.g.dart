// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryConfig _$CategoryConfigFromJson(Map<String, dynamic> json) =>
    _CategoryConfig(
      id: json['id'] as String,
      translationKey: json['translation_key'] as String,
      icon: json['icon'] as String,
      iconActive: json['icon_active'] as String,
      filter: CaxiloFilter.fromJson(json['filter'] as Map<String, dynamic>),
      groupKey: json['group_key'] as String?,
    );

Map<String, dynamic> _$CategoryConfigToJson(_CategoryConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'translation_key': instance.translationKey,
      'icon': instance.icon,
      'icon_active': instance.iconActive,
      'filter': instance.filter.toJson(),
      'group_key': instance.groupKey,
    };
