// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_house_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InHouseConfig _$InHouseConfigFromJson(Map<String, dynamic> json) =>
    _InHouseConfig(
      catalog:
          (json['catalog'] as List<dynamic>?)
              ?.map((e) => InHouseGame.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      visibility:
          (json['visibility'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              InHouseGameVisibility.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$InHouseConfigToJson(_InHouseConfig instance) =>
    <String, dynamic>{
      'catalog': instance.catalog.map((e) => e.toJson()).toList(),
      'visibility': instance.visibility.map((k, e) => MapEntry(k, e.toJson())),
    };
