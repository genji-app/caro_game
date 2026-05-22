// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_slip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BetSlip _$BetSlipFromJson(Map<String, dynamic> json) => _BetSlip(
  homeName: json['homeName'] as String?,
  awayName: json['awayName'] as String?,
  id: json['id'] as String,
  stake: json['stake'] as num,
  winning: json['winning'] as num,
  status: const BetSlipStatusConverter().fromJson(json['status'] as String),
  displayOdds: json['displayOdds'] as String,
  score: json['score'] as String,
  cls: json['cls'] as String,
  oddsName: json['oddsName'] as String,
  ticketId: json['ticketId'] as String,
  marketName: json['marketName'] as String,
  sportId: (json['sportId'] as num).toInt(),
  marketId: (json['marketId'] as num).toInt(),
  selectionId: json['selectionId'] as String,
  currency: json['currency'] as String,
  matchType: json['matchType'] as String,
  matchId: json['matchId'] as String,
  homeId: (json['homeId'] as num).toInt(),
  awayId: (json['awayId'] as num).toInt(),
  leagueName: json['leagueName'] as String,
  oddsStyle: json['oddsStyle'] as String,
  startDate: const LocalTimeConverter().fromJson(json['startDate'] as String),
  betTime: const LocalTimeConverter().fromJson(json['betTime'] as String),
  childBets:
      (json['childBets'] as List<dynamic>?)
          ?.map((e) => ChildBet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  settlementStatus: json['settlementStatus'] as String?,
  cashOutAbleAmount: json['cashOutAbleAmount'] as num?,
  matchName: json['matchName'] as String?,
  htScore: json['htScore'] as String?,
  cashoutHistory:
      (json['cashoutHistory'] as List<dynamic>?)
          ?.map((e) => CashoutInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BetSlipToJson(_BetSlip instance) => <String, dynamic>{
  'homeName': instance.homeName,
  'awayName': instance.awayName,
  'id': instance.id,
  'stake': instance.stake,
  'winning': instance.winning,
  'status': const BetSlipStatusConverter().toJson(instance.status),
  'displayOdds': instance.displayOdds,
  'score': instance.score,
  'cls': instance.cls,
  'oddsName': instance.oddsName,
  'ticketId': instance.ticketId,
  'marketName': instance.marketName,
  'sportId': instance.sportId,
  'marketId': instance.marketId,
  'selectionId': instance.selectionId,
  'currency': instance.currency,
  'matchType': instance.matchType,
  'matchId': instance.matchId,
  'homeId': instance.homeId,
  'awayId': instance.awayId,
  'leagueName': instance.leagueName,
  'oddsStyle': instance.oddsStyle,
  'startDate': const LocalTimeConverter().toJson(instance.startDate),
  'betTime': const LocalTimeConverter().toJson(instance.betTime),
  'childBets': instance.childBets.map((e) => e.toJson()).toList(),
  'settlementStatus': instance.settlementStatus,
  'cashOutAbleAmount': instance.cashOutAbleAmount,
  'matchName': instance.matchName,
  'htScore': instance.htScore,
  'cashoutHistory': instance.cashoutHistory.map((e) => e.toJson()).toList(),
};
