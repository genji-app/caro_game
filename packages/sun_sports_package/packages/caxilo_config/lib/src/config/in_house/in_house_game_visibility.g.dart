// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_house_game_visibility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InHouseGameVisibility _$InHouseGameVisibilityFromJson(Map<String, dynamic> json) =>
    _InHouseGameVisibility(
      isVisible: json['is_visible'] as bool? ?? false,
      status:
          $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ?? GameStatus.underDevelopment,
    );

Map<String, dynamic> _$InHouseGameVisibilityToJson(_InHouseGameVisibility instance) =>
    <String, dynamic>{'is_visible': instance.isVisible, 'status': instance.status.toJson()};

const _$GameStatusEnumMap = {
  GameStatus.active: 'active',
  GameStatus.maintenance: 'maintenance',
  GameStatus.comingSoon: 'coming_soon',
  GameStatus.underDevelopment: 'under_development',
  GameStatus.disabled: 'disabled',
  GameStatus.unknown: 'unknown',
};
