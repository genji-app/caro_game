// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisplayConfig _$DisplayConfigFromJson(Map<String, dynamic> json) =>
    _DisplayConfig(
      order:
          (json['order'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      collections:
          (json['collections'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$DisplayConfigToJson(_DisplayConfig instance) =>
    <String, dynamic>{
      'order': instance.order,
      'collections': instance.collections,
    };
