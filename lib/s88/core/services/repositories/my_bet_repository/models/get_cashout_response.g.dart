// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_cashout_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GetCashoutResponse _$GetCashoutResponseFromJson(Map<String, dynamic> json) =>
    _GetCashoutResponse(
      ticketId: json['0'] as String,
      isCashoutAvailable: json['1'] as bool,
      cashoutAmount: json['3'] as num?,
      odds: json['4'] as num?,
      feeOrAdjustment: json['5'] as num?,
      originalStake: json['6'] as num?,
    );

Map<String, dynamic> _$GetCashoutResponseToJson(_GetCashoutResponse instance) =>
    <String, dynamic>{
      '0': instance.ticketId,
      '1': instance.isCashoutAvailable,
      '3': instance.cashoutAmount,
      '4': instance.odds,
      '5': instance.feeOrAdjustment,
      '6': instance.originalStake,
    };
