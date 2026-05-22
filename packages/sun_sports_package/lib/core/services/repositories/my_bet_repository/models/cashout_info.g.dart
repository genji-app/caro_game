// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cashout_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CashoutInfo _$CashoutInfoFromJson(Map<String, dynamic> json) => _CashoutInfo(
  id: json['0'] as String,
  time: DateTime.parse(json['6'] as String),
  stakeAmount: json['1'] as num? ?? 0,
  cashoutAmount: json['3'] as num? ?? 0,
  fee: (json['4'] as num?)?.toDouble() ?? 0.0,
  isSuccess: json['5'] as bool? ?? false,
);

Map<String, dynamic> _$CashoutInfoToJson(_CashoutInfo instance) =>
    <String, dynamic>{
      '0': instance.id,
      '6': instance.time.toIso8601String(),
      '1': instance.stakeAmount,
      '3': instance.cashoutAmount,
      '4': instance.fee,
      '5': instance.isSuccess,
    };
