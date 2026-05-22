// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'special_outright_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpecialOutrightModel _$SpecialOutrightModelFromJson(
  Map<String, dynamic> json,
) => _SpecialOutrightModel(
  selections:
      (json['0'] as List<dynamic>?)
          ?.map(
            (e) => SpecialOutrightSelection.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  outrightId: json['1'] == null ? 0 : _safeParseInt(json['1']),
  outrightName: json['2'] as String? ?? '',
  endDate: json['4'] as String? ?? '',
  startTime: json['5'] == null ? 0 : _safeParseInt(json['5']),
  leagueId: json['6'] == null ? 0 : _safeParseInt(json['6']),
  leagueLogo: json['7'] as String? ?? '',
  leagueName: json['8'] as String? ?? '',
);

Map<String, dynamic> _$SpecialOutrightModelToJson(
  _SpecialOutrightModel instance,
) => <String, dynamic>{
  '0': instance.selections.map((e) => e.toJson()).toList(),
  '1': instance.outrightId,
  '2': instance.outrightName,
  '4': instance.endDate,
  '5': instance.startTime,
  '6': instance.leagueId,
  '7': instance.leagueLogo,
  '8': instance.leagueName,
};

_SpecialOutrightSelection _$SpecialOutrightSelectionFromJson(
  Map<String, dynamic> json,
) => _SpecialOutrightSelection(
  selectionId: json['0'] as String? ?? '',
  selectionName: json['1'] as String? ?? '',
  logoUrl: json['2'] as String? ?? '',
  offerId: json['3'] as String? ?? '',
  odds: json['4'] == null ? 0.0 : _safeParseDouble(json['4']),
  selectionCode: json['5'] as String? ?? '',
);

Map<String, dynamic> _$SpecialOutrightSelectionToJson(
  _SpecialOutrightSelection instance,
) => <String, dynamic>{
  '0': instance.selectionId,
  '1': instance.selectionName,
  '2': instance.logoUrl,
  '3': instance.offerId,
  '4': instance.odds,
  '5': instance.selectionCode,
};
