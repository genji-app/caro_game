// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_bet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChildBet _$ChildBetFromJson(Map<String, dynamic> json) => _ChildBet(
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
  matchId: json['matchId'] as String,
  homeId: (json['homeId'] as num).toInt(),
  awayId: (json['awayId'] as num).toInt(),
  leagueName: json['leagueName'] as String,
  oddsStyle: json['oddsStyle'] as String,
  startDate: const LocalTimeConverter().fromJson(json['startDate'] as String),
  settlementStatus: json['settlementStatus'] as String?,
  matchType: json['matchType'] as String?,
  htScore: json['htScore'] as String?,
);

Map<String, dynamic> _$ChildBetToJson(_ChildBet instance) => <String, dynamic>{
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
  'matchId': instance.matchId,
  'homeId': instance.homeId,
  'awayId': instance.awayId,
  'leagueName': instance.leagueName,
  'oddsStyle': instance.oddsStyle,
  'startDate': const LocalTimeConverter().toJson(instance.startDate),
  'settlementStatus': instance.settlementStatus,
  'matchType': instance.matchType,
  'htScore': instance.htScore,
};
