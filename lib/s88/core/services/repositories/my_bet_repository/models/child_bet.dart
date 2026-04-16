// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;

import 'bet_slip_status.dart';
import 'local_time_converter.dart';
import 'match_type.dart';
import 'settlement_status_enum.dart';

part 'child_bet.freezed.dart';
part 'child_bet.g.dart';

@freezed
sealed class ChildBet with _$ChildBet {
  const factory ChildBet({
    String? homeName,
    String? awayName,
    required String id,
    required num stake,
    required num winning,
    @BetSlipStatusConverter() required BetSlipStatus status,
    required String displayOdds,
    required String score,
    required String cls,
    required String oddsName,
    required String ticketId,
    required String marketName,
    required int sportId,
    required int marketId,
    required String selectionId,
    required String currency,
    required String matchId,
    required int homeId,
    required int awayId,
    required String leagueName,
    required String oddsStyle,
    @LocalTimeConverter() required DateTime startDate,
    String? settlementStatus,
    String? matchType,
    String? htScore,
  }) = _ChildBet;

  factory ChildBet.fromJson(Map<String, dynamic> json) =>
      _$ChildBetFromJson(json);
}

extension ChildBetX on ChildBet {
  /// Get sport type enum default is football
  SportType? get sport => SportType.fromId(sportId);

  /// Get match type enum
  MatchType get matchTypeEnum => MatchType.fromString(matchType);

  /// Get settlement status enum
  SettlementStatusEnum get settlementStatusEnum =>
      SettlementStatusEnum.fromString(settlementStatus);

  /// Check if match is currently live (has started and status is active/running)
  bool get isMatchLive {
    final now = DateTime.now();
    final hasStarted = startDate.isBefore(now);
    final isStatusActive = status.isActiveStatus;
    return hasStarted && isStatusActive;
  }
}
