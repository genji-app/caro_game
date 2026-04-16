// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;

import 'bet_slip_status.dart';
import 'cashout_info.dart';
import 'cashout_response.dart';
import 'child_bet.dart';
import 'match_type.dart';
import 'settlement_status_enum.dart';
import 'local_time_converter.dart';

part 'bet_slip.freezed.dart';
part 'bet_slip.g.dart';

@freezed
sealed class BetSlip with _$BetSlip {
  const factory BetSlip({
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
    required String matchType,
    required String matchId,
    required int homeId,
    required int awayId,
    required String leagueName,
    required String oddsStyle,
    @LocalTimeConverter() required DateTime startDate,
    @LocalTimeConverter() required DateTime betTime,
    @Default([]) List<ChildBet> childBets,
    String? settlementStatus,
    num? cashOutAbleAmount,
    String? matchName,
    String? htScore,
    @Default([]) List<CashoutInfo> cashoutHistory,
  }) = _BetSlip;

  factory BetSlip.fromJson(Map<String, dynamic> json) =>
      _$BetSlipFromJson(json);
}

extension BetSlipX on BetSlip {
  /// Get settlement status enum
  SettlementStatusEnum get settlementStatusEnum =>
      SettlementStatusEnum.fromString(settlementStatus);

  /// Get sport type enum default is football
  SportType? get sport => SportType.fromId(sportId);

  /// Get match type enum
  MatchType get matchTypeEnum => MatchType.fromString(matchType);

  /// Check if this is a combo/parlay bet
  bool get isComboBet => childBets.isNotEmpty;

  /// Check if bet is active/running
  bool get isActive => status.isActiveStatus;

  /// Check if bet is pending
  bool get isPending => status.isPendingStatus;

  /// Check if bet is settled
  bool get isSettled {
    // return !isMatchLive && !isPending && status != BetSlipStatus.declined;
    switch (status) {
      case BetSlipStatus.cashout:
      case BetSlipStatus.settled:
        return true;

      case BetSlipStatus.active:
      case BetSlipStatus.running:
      case BetSlipStatus.declined:
      case BetSlipStatus.pending:
      case BetSlipStatus.unknown:
        return false;
    }
  }

  /// Check if match has started (based on startDate)
  bool get hasMatchStarted => startDate.isBefore(DateTime.now());

  /// Check if match is currently live (has started and status is active/running)
  bool get isMatchLive {
    final now = DateTime.now();
    final hasStarted = startDate.isBefore(now);
    final isStatusActive = status.isActiveStatus;
    return hasStarted && isStatusActive;
  }

  /// Check if cashout is available
  /// Conditions:
  /// 1. Not a combo/parlay bet (cược xiên)
  /// 2. Match has NOT started yet (chưa diễn ra)
  /// 3. Has cashout amount > 0
  bool get isCashoutAvailable {
    // Combo bets cannot cashout
    if (isComboBet) return false;

    // Match must NOT have started yet (chưa diễn ra)
    if (hasMatchStarted) return false;

    // Must have cashout amount
    return (cashOutAbleAmount ?? 0) > 0;
  }

  /// Get potential profit
  num get potentialProfit => winning - stake;

  /// Apply cashout response to create updated BetSlip
  ///
  /// This centralizes the logic for updating a BetSlip after successful cashout.
  /// Used by:
  /// - BettingHistoryDetail (detail page)
  /// - BettingHistoryNotifier (list page)
  ///
  /// Returns a new BetSlip with:
  /// - status: BetSlipStatus.cashout
  /// - settlementStatus: from response
  /// - winning: cashoutAmount from response (or keep original if null)
  /// - cashOutAbleAmount: 0 (no longer cashout-able)
  BetSlip applyCashout(CashoutResponse cashoutResponse) {
    // Handle both CashoutResponse and Map types
    final String? responseSettlementStatus;
    final num? responseCashoutAmount;
    responseSettlementStatus = cashoutResponse.settlementStatus;
    responseCashoutAmount = cashoutResponse.cashoutAmount;

    return copyWith(
      status: BetSlipStatus.cashout,
      settlementStatus: responseSettlementStatus,
      winning: responseCashoutAmount ?? winning,
      cashOutAbleAmount: 0,
    );
  }
}
