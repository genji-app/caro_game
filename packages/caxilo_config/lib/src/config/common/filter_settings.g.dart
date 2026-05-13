// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaxiloFilter _$CaxiloFilterFromJson(Map<String, dynamic> json) => _CaxiloFilter(
  strategy: CaxiloFilterStrategy.fromJson(json['strategy'] as String?),
  params: json['params'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CaxiloFilterToJson(_CaxiloFilter instance) => <String, dynamic>{
  'strategy': _strategyToJson(instance.strategy),
  'params': instance.params,
};

const _$CaxiloFilterStrategyEnumMap = {
  CaxiloFilterStrategy.collection: 'collection',
  CaxiloFilterStrategy.byGameCodes: 'by_game_codes',
  CaxiloFilterStrategy.byGameType: 'by_game_type',
  CaxiloFilterStrategy.byProvider: 'by_provider',
  CaxiloFilterStrategy.inHouse: 'in_house',
  CaxiloFilterStrategy.unknown: 'unknown',
};
