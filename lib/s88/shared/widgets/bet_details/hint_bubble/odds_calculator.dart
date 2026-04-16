import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Odds Calculator
///
/// Utility class for calculating win/lose amounts based on odds style.
/// Based on FLUTTER_HINT_BUBBLE_IMPLEMENTATION_GUIDE.md Section 4
class OddsCalculator {
  OddsCalculator._();

  /// Tính tiền thắng
  ///
  /// [stake] - Số tiền cược (đơn vị: VND)
  /// [ratio] - Tỷ lệ cược
  /// [style] - Loại odds (Decimal, Malay, Indo, HongKong)
  static double calculateWin(double stake, double ratio, OddsStyle style) {
    if (stake <= 0) return 0;

    switch (style) {
      case OddsStyle.decimal:
        // Win = stake * (ratio - 1)
        return stake * (ratio - 1);

      case OddsStyle.malay:
        if (ratio >= 0) {
          // Malay dương: Win = stake * ratio
          return stake * ratio;
        } else {
          // Malay âm: Win = stake (tiền nhập vào là "mức thắng")
          return stake.toDouble();
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          // Indo dương: Win = stake * ratio
          return stake * ratio;
        } else {
          // Indo âm: Win = stake
          return stake.toDouble();
        }

      case OddsStyle.hongKong:
        // HK: Win = stake * ratio
        return stake * ratio;
    }
  }

  /// Tính tiền thua
  ///
  /// [stake] - Số tiền cược (đơn vị: VND)
  /// [ratio] - Tỷ lệ cược
  /// [style] - Loại odds
  static double calculateLose(double stake, double ratio, OddsStyle style) {
    if (stake <= 0) return 0;

    switch (style) {
      case OddsStyle.decimal:
      case OddsStyle.hongKong:
        // Lose = stake
        return stake.toDouble();

      case OddsStyle.malay:
        if (ratio >= 0) {
          return stake.toDouble();
        } else {
          // Malay âm: Lose = stake * |ratio|
          return stake * ratio.abs();
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return stake.toDouble();
        } else {
          // Indo âm: Lose = stake * |ratio|
          return stake * ratio.abs();
        }
    }
  }

  /// Tính tiền thắng nửa (cho kèo 1/4)
  static double calculateHalfWin(double stake, double ratio, OddsStyle style) {
    return calculateWin(stake, ratio, style) / 2;
  }

  /// Tính tiền thua nửa (cho kèo 1/4)
  static double calculateHalfLose(double stake, double ratio, OddsStyle style) {
    return calculateLose(stake, ratio, style) / 2;
  }

  /// Tính tổng tiền hoàn trả khi thắng (bao gồm vốn)
  static double calculateTotalReturn(
    double stake,
    double ratio,
    OddsStyle style,
  ) {
    return stake + calculateWin(stake, ratio, style);
  }

  /// Get odds style name in Vietnamese
  static String getStyleName(OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return 'Decimal';
      case OddsStyle.malay:
        return 'Malaysia';
      case OddsStyle.indo:
        return 'Indonesia';
      case OddsStyle.hongKong:
        return 'Hongkong';
    }
  }

  /// Get win formula text
  static String getWinFormula(double ratio, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return 'Tiền cược x ${(ratio - 1).toStringAsFixed(2)}';

      case OddsStyle.malay:
        if (ratio >= 0) {
          return 'Tiền cược x ${ratio.toStringAsFixed(2)}';
        } else {
          return 'Tiền cược';
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return 'Tiền cược x ${ratio.toStringAsFixed(2)}';
        } else {
          return 'Tiền cược';
        }

      case OddsStyle.hongKong:
        return 'Tiền cược x ${ratio.toStringAsFixed(2)}';
    }
  }

  /// Get lose formula text
  static String getLoseFormula(double ratio, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
      case OddsStyle.hongKong:
        return 'Tiền cược';

      case OddsStyle.malay:
        if (ratio >= 0) {
          return 'Tiền cược';
        } else {
          return 'Tiền cược x ${ratio.abs().toStringAsFixed(2)}';
        }

      case OddsStyle.indo:
        if (ratio >= 1) {
          return 'Tiền cược';
        } else {
          return 'Tiền cược x ${ratio.abs().toStringAsFixed(2)}';
        }
    }
  }

  /// Format money value for display (e.g., 50000 VND -> "50K", 1500000 VND -> "1.5M")
  ///
  /// Input: value in VND (e.g., 1000000 = 1,000,000 VND)
  /// Output: formatted string (e.g., "1M")
  static String formatMoney(double value) {
    // value is already in VND, formatCompact expects VND
    return MoneyFormatter.formatCompact(value.toInt());
  }

  /// Format money value without 'k' suffix
  static String formatMoneyValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
