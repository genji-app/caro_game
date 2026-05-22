import '../models/models.dart';
import 'betting_history_constants.dart';

/// Parser for BetSlip from numeric key JSON format (betsReporting API)
class BetSlipParser {
  /// Parse BetSlip from numeric key JSON format
  static BetSlip parse(Map<String, dynamic> json) {
    final ticketId = json['0']?.toString() ?? '';
    final betTimeStr = json['1'] as String? ?? DateTime.now().toIso8601String();
    final startDateStr = json['18'] as String? ?? betTimeStr;

    // Parse childBets (key "21")
    final childBets = _parseChildBets(json);

    // Parse parlay/combo summary info from key "20"
    num? cashOutAmount;
    if (json['20'] is Map<String, dynamic>) {
      final summary = json['20'] as Map<String, dynamic>;
      // Key "3" in summary is often the stake, key "0" can be a cashout/win value
      cashOutAmount = (summary['0'] as num?)?.toDouble();
    }

    // Parse cashout history (key "24")
    final cashoutHistory = _parseCashoutHistory(json['24'] as List? ?? []);

    return BetSlip(
      homeName: json['33'] as String? ?? '',
      awayName: json['34'] as String? ?? '',
      id: ticketId,
      stake: (json['9'] as num?)?.toDouble() ?? 0.0,
      winning: (json['10'] as num?)?.toDouble() ?? 0.0,
      status: BetSlipStatus.fromString(json['12'] as String?),
      settlementStatus:
          json['11'] as String?, // 11 is settlement result (Won, Lost, Cashout)
      displayOdds: json['8']?.toString() ?? '0.00',
      score: _formatScore(json['14'] as String?), // 14 is FT score
      htScore: _formatScore(json['16'] as String?), // 16 is HT score
      cls: json['7']?.toString() ?? '',
      oddsName: json['5'] as String? ?? '',
      ticketId: ticketId,
      marketName: json['6'] as String? ?? '',
      sportId: (json['2'] as num?)?.toInt() ?? 1,
      marketId: (json['15'] as num?)?.toInt() ?? 0,
      selectionId: json['27']?.toString() ?? '',
      currency:
          json['19'] as String? ?? BettingHistoryConstants.defaultCurrency,
      matchType: BettingHistoryConstants.defaultMatchType,
      matchId: json['26']?.toString() ?? '',
      childBets: childBets,
      homeId: (json['26'] as num?)?.toInt() ?? 0,
      awayId: (json['27'] as num?)?.toInt() ?? 0,
      leagueName: json['3'] as String? ?? '',
      oddsStyle: json['25'] as String? ?? 'ma',
      startDate: DateTime.tryParse(startDateStr) ?? DateTime.now(),
      betTime: DateTime.tryParse(betTimeStr) ?? DateTime.now(),
      cashOutAbleAmount: cashOutAmount?.toInt(),
      matchName: json['4'] as String?,
      cashoutHistory: cashoutHistory,
    );
  }

  /// Parse childBets from key "21"
  static List<ChildBet> _parseChildBets(Map<String, dynamic> json) {
    final childBetsData = json['21'] as List<dynamic>? ?? [];
    return childBetsData
        .map((child) {
          if (child is! Map<String, dynamic>) return null;
          final id = child['0']?.toString() ?? '';
          final startDateStr =
              child['18'] as String? ??
              child['1'] as String? ??
              DateTime.now().toIso8601String();

          return ChildBet(
            homeName: child['33'] as String? ?? '',
            awayName: child['34'] as String? ?? '',
            id: id,
            stake: (child['9'] as num?)?.toDouble() ?? 0.0,
            winning: (child['10'] as num?)?.toDouble() ?? 0.0,
            status: BetSlipStatus.fromString(child['12'] as String?),
            displayOdds: child['8']?.toString() ?? '0.00',
            score: _formatScore(child['14'] as String?),
            htScore: _formatScore(child['16'] as String?),
            cls: child['7']?.toString() ?? '',
            oddsName: child['5'] as String? ?? '',
            ticketId: id,
            marketName: child['6'] as String? ?? '',
            sportId: (child['2'] as num?)?.toInt() ?? 1,
            marketId: (child['15'] as num?)?.toInt() ?? 0,
            selectionId: child['27']?.toString() ?? '',
            currency:
                child['19'] as String? ??
                BettingHistoryConstants.defaultCurrency,
            matchId: child['26']?.toString() ?? '',
            homeId: (child['26'] as num?)?.toInt() ?? 0,
            awayId: (child['27'] as num?)?.toInt() ?? 0,
            leagueName: child['3'] as String? ?? '',
            oddsStyle: child['25'] as String? ?? 'ma',
            startDate: DateTime.tryParse(startDateStr) ?? DateTime.now(),
            settlementStatus:
                child['11'] as String? ??
                BettingHistoryConstants.apiStatusSettled,
          );
        })
        .whereType<ChildBet>()
        .toList();
  }

  /// Parse cashout history from key "24"
  static List<CashoutInfo> _parseCashoutHistory(List<dynamic> data) {
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) return null;
          try {
            return CashoutInfo.fromJson(item);
          } catch (e) {
            return null;
          }
        })
        .whereType<CashoutInfo>()
        .toList();
  }

  /// Format score from "0:0" to "[0-0]" format
  static String _formatScore(String? scoreStr) {
    if (scoreStr == null || scoreStr.isEmpty) {
      return BettingHistoryConstants.defaultScore;
    }
    if (scoreStr.contains(BettingHistoryConstants.scoreSeparatorApi)) {
      final parts = scoreStr.split(BettingHistoryConstants.scoreSeparatorApi);
      return '${BettingHistoryConstants.scoreBracketStart}${parts[0]}${BettingHistoryConstants.scoreDash}${parts[1]}${BettingHistoryConstants.scoreBracketEnd}';
    }
    return scoreStr;
  }
}
