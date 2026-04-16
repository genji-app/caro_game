import 'package:intl/intl.dart';

/// Utility class để format và hiển thị tiền trong app
///
/// Server thường trả về value với đơn vị 1000
/// Ví dụ: server trả 50 tức là 50,000 VND
class MoneyFormatter {
  MoneyFormatter._();

  static final _numberFormat = NumberFormat('#,###');
  static final _viFormat = NumberFormat.decimalPattern('vi');

  /// Format giá trị từ server (đơn vị 1000) sang dạng hiển thị K/M
  ///
  /// Ví dụ:
  /// - serverValue = 50 -> "50K" (tức 50,000)
  /// - serverValue = 1000 -> "1M" (tức 1,000,000)
  /// - serverValue = 1500 -> "1.5M" (tức 1,500,000)
  static String formatServerMoney(num serverValue) {
    // Server value đã là đơn vị nghìn
    // 50 = 50K, 1000 = 1M
    if (serverValue >= 1000) {
      // Triệu (M)
      final millions = serverValue / 1000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}M';
      }
      return '${millions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    }

    // Nghìn (K)
    if (serverValue == serverValue.toInt()) {
      return '${serverValue.toInt()}K';
    }
    return '${serverValue.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
  }

  /// Format giá trị thực tế (VND) sang dạng hiển thị K/M
  ///
  /// Ví dụ:
  /// - value = 50000 -> "50K"
  /// - value = 1000000 -> "1M"
  /// - value = 1500000 -> "1.5M"
  static String formatCompact(int value) {
    if (value >= 1000000000) {
      final millions = value / 1000000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}B';
      }
      return '${millions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
    }
    if (value >= 1000000) {
      final millions = value / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}M';
      }
      return '${millions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    }

    if (value >= 1000) {
      final thousands = value / 1000;
      if (thousands == thousands.roundToDouble()) {
        return '${thousands.toInt()}K';
      }
      return '${thousands.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    }

    return formatWithCommas(value);
  }

  /// Format số tiền với dấu phẩy ngăn cách hàng nghìn
  ///
  /// Ví dụ:
  /// - 1000000 -> "1,000,000"
  /// - 50000 -> "50,000"
  static String formatWithCommas(num amount) {
    if (amount == 0) return '0';
    return _numberFormat.format(amount);
  }

  /// Format số tiền với dấu chấm ngăn cách (theo chuẩn Việt Nam)
  ///
  /// Ví dụ:
  /// - 1000000 -> "1.000.000"
  /// - 50000 -> "50.000"
  static String formatVietnamese(num amount) => _viFormat.format(amount);

  /// Format số tiền với suffix VND
  ///
  /// Ví dụ:
  /// - 1000000 -> "1,000,000 VND"
  static String formatWithCurrency(num amount, {String currency = 'VND'}) =>
      '${formatWithCommas(amount)} $currency';

  /// Format số tiền từ double với suffix VND
  ///
  /// Ví dụ:
  /// - 1000000.0 -> "1,000,000 $"
  static String formatDoubleWithCurrency(double value, {String currency = ''}) {
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$formatted $currency';
  }

  /// Chuyển đổi giá trị server sang giá trị thực tế (VND)
  ///
  /// Ví dụ:
  /// - serverValue = 50 -> 50000
  /// - serverValue = 1000 -> 1000000
  static int serverToActual(num serverValue) {
    return (serverValue * 1000).toInt();
  }

  /// Chuyển đổi giá trị thực tế (VND) sang giá trị server
  ///
  /// Ví dụ:
  /// - actualValue = 50000 -> 50
  /// - actualValue = 1000000 -> 1000
  static num actualToServer(int actualValue) {
    return actualValue / 1000;
  }
}
