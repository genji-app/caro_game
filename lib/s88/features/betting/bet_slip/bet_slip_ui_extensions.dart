import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/repositories/my_bet_repository/my_bet_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// UI extensions for SettlementStatusEnum
extension SettlementStatusUIExt on SettlementStatusEnum {
  /// Get localized display label
  String get label => switch (this) {
    SettlementStatusEnum.won => I18n.txtWon,
    SettlementStatusEnum.lost => I18n.txtLost,
    SettlementStatusEnum.halfWon => I18n.txtHalfWon,
    SettlementStatusEnum.halfLost => I18n.txtHalfLost,
    SettlementStatusEnum.draw => I18n.txtDraw,
    SettlementStatusEnum.voided ||
    SettlementStatusEnum.refunded => I18n.txtRefunded,
    SettlementStatusEnum.cashout => I18n.txtSold,
    SettlementStatusEnum.processing => I18n.txtProcessing,
    SettlementStatusEnum.running => I18n.txtCurrentlyActive,
    _ => I18n.txtPending,
  };

  /// Get status badge color
  Color get color => switch (this) {
    SettlementStatusEnum.won ||
    SettlementStatusEnum.halfWon => AppColors.green400,
    SettlementStatusEnum.lost ||
    SettlementStatusEnum.halfLost => AppColors.red400,
    SettlementStatusEnum.draw ||
    SettlementStatusEnum.voided ||
    SettlementStatusEnum.refunded => AppColors.gray300,
    SettlementStatusEnum.cashout => AppColors.blue300,
    SettlementStatusEnum.processing => AppColors.yellow400,
    _ => AppColors.gray300,
  };
}

/// UI extensions for BetSlip
extension BetSlipUIExt on BetSlip {
  /// Get localized status description
  String get formattedStatus => settlementStatusEnum.label;

  /// Get full match name with score (e.g., "Home Team 2 - 0 Away Team")
  String get fullMatchNameWithScore {
    if (matchTypeEnum == MatchType.leagueBetting) {
      return 'CƯỢC ĐẶC BIỆT - $matchName';
    }
    return '$homeName $formattedScore $awayName';
  }

  /// Get score display
  String get displayScore => score.isEmpty ? '[0-0]' : score;

  /// Get full match name
  String get fullMatchName {
    if (matchName != null && matchName!.isNotEmpty) return matchName!;
    return '$homeName vs $awayName';
  }

  /// Get market display name
  String get displayMarketName {
    // if (marketName.toUpperCase() == 'AH FT') return 'Chấp (Toàn trận)';
    // if (marketName.toUpperCase() == 'OU FT') return 'Tài/Xỉu (Toàn trận)';
    // if (marketName.toUpperCase() == '1X2 FT') return '1X2 (Toàn trận)';
    // return marketName;
    // return marketName.isNotEmpty
    //     ? marketName
    //     : MarketHelper.getMarketName(marketId);
    return MarketHelper.getMarketNameViDisplay(marketId);
  }

  /// Get formatted stake (e.g., "50K")
  String get formattedStake => '${(stake / 1000).toStringAsFixed(0)}K';

  /// Get formatted winning (e.g., "92.5K")
  String get formattedWinning => '${(winning / 1000).toStringAsFixed(1)}K';

  /// Get formatted score (e.g., "[2-0]" -> "2 - 0", include HT if available)
  String get formattedScore {
    final s = score.isEmpty
        ? '0-0'
        : score.replaceAll('[', '').replaceAll(']', '');
    final ft = s.contains('-') && !s.contains(' - ')
        ? s.replaceAll('-', ' - ')
        : s;

    if (htScore != null && htScore!.isNotEmpty && htScore != '[0-0]') {
      final ht = htScore!
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('-', ' - ');
      return '$ft (HT $ht)';
    }
    return ft;
  }
}

/// UI extensions for ChildBet
extension ChildBetUIExt on ChildBet {
  /// Get localized status description
  String get formattedStatus => settlementStatusEnum.label;

  /// Get full match name with score (e.g., "Home Team 2 - 0 Away Team")
  String get fullMatchNameWithScore {
    // if (matchTypeEnum == MatchType.leagueBetting) {
    //   return 'CƯỢC ĐẶC BIỆT';
    // }
    return '$homeName $formattedScore $awayName';
  }

  /// Get market display name
  String get displayMarketName => MarketHelper.getMarketNameViDisplay(marketId);

  /// Get formatted score (e.g., "[2-0]" -> "2 - 0", include HT if available)
  String get formattedScore {
    final s = score.isEmpty
        ? '0-0'
        : score.replaceAll('[', '').replaceAll(']', '');
    final ft = s.contains('-') && !s.contains(' - ')
        ? s.replaceAll('-', ' - ')
        : s;

    if (htScore != null && htScore!.isNotEmpty && htScore != '[0-0]') {
      final ht = htScore!
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('-', ' - ');
      return '$ft (HT $ht)';
    }
    return ft;
  }
}
