import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Constants for odds style information and examples.
/// Used in bet preferences and odds info bottom sheet.
abstract class OddsInfo {
  // ==========================================================================
  // LABELS
  // ==========================================================================
  static const malayLabel = 'Malaysia';
  static const hongKongLabel = 'Hong Kong';
  static const indoLabel = 'Indonesia';
  static const decimalLabel = 'Decimal';

  // ==========================================================================
  // SECTIONS (Separated by positive/negative for card display)
  // ==========================================================================

  // Malaysia - 2 sections (positive + negative)
  static const malayPositiveSection = '''
<title>Tỷ lệ cược <odds>Malaysia</odds> số dương:</title>
<content>• Tiền thắng = Tiền cược x Tỷ lệ.</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 100k tỷ lệ <number>0.78</number>:
• Thắng 78K
• Thua 100K''';

  static const malayNegativeSection = '''
<title>Tỷ lệ cược <odds>Malaysia</odds> số âm:</title>
<content>• Tiền thắng = Tiền cược.</content>
<content>• Tiền thua = Tiền cược x Tỷ lệ.</content>

Ví dụ cược 100k tỷ lệ <number>-0.78</number>:
• Thắng 100K
• Thua 78K''';

  static const List<String> malaySections = [
    malayPositiveSection,
    malayNegativeSection,
  ];

  // Hong Kong - 1 section (no positive/negative distinction)
  static const hongKongSection = '''
<title>Tỷ lệ cược <odds>Hongkong</odds>:</title>
<content>• Tiền thắng = Tiền cược x Tỷ lệ.</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 100K tỷ lệ <number>1.23</number>:
• Thắng 123K
• Thua 100K''';

  static const List<String> hongKongSections = [hongKongSection];

  // Indonesia - 2 sections (positive + negative)
  static const indoPositiveSection = '''
<title>Tỷ lệ cược <odds>Indonesia</odds> số dương:</title>
<content>• Tiền thắng = Tiền cược.</content>
<content>• Tiền thua = Tiền cược x Tỷ lệ.</content>

Ví dụ cược 100K tỷ lệ <number>1.23</number>:
• Thắng 123K
• Thua 100K''';

  static const indoNegativeSection = '''
<title>Tỷ lệ cược <odds>Indonesia</odds> số âm:</title>
<content>• Tiền thắng = Tiền cược ÷ Tỷ lệ.</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 123K tỷ lệ <number>-1.23</number>:
• Thắng 100K
• Thua 123K''';

  static const List<String> indoSections = [
    indoPositiveSection,
    indoNegativeSection,
  ];

  // Decimal - 1 section (no positive/negative distinction)
  static const decimalSection = '''
<title>Tỷ lệ cược <odds>Decimal</odds>:</title>
<content>• Tiền thắng = Tiền cược x (Tỷ lệ - 1).</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 100K tỷ lệ <number>2.34</number>:
• Thắng 134K
• Thua 100K''';

  static const List<String> decimalSections = [decimalSection];
}

/// Extension to provide display properties for [OddsStyle]
extension OddsStyleDisplayExt on OddsStyle {
  /// Display label for the odds style
  String get label => switch (this) {
    OddsStyle.malay => OddsInfo.malayLabel,
    OddsStyle.hongKong => OddsInfo.hongKongLabel,
    OddsStyle.indo => OddsInfo.indoLabel,
    OddsStyle.decimal => OddsInfo.decimalLabel,
  };

  /// Content sections for the odds style
  /// Returns a list of sections, each representing a separate card
  /// (e.g., Malaysia has 2 sections: positive and negative)
  List<String> get sections => switch (this) {
    OddsStyle.malay => OddsInfo.malaySections,
    OddsStyle.hongKong => OddsInfo.hongKongSections,
    OddsStyle.indo => OddsInfo.indoSections,
    OddsStyle.decimal => OddsInfo.decimalSections,
  };
}
