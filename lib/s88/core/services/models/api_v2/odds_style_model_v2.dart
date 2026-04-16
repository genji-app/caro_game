import 'package:freezed_annotation/freezed_annotation.dart';

part 'odds_style_model_v2.freezed.dart';

/// Odds Style Model V2
///
/// Represents different odds formats (Decimal, Malay, Indo, HK).
/// API returns numeric keys: 0=decimal, 1=malay, 2=indo, 3=hk
@freezed
sealed class OddsStyleModelV2 with _$OddsStyleModelV2 {
  const factory OddsStyleModelV2({
    /// Decimal odds format (e.g., "1.85")
    @Default('') String decimal,

    /// Malay odds format (e.g., "0.85")
    @Default('') String malay,

    /// Indonesian odds format (e.g., "-1.18")
    @Default('') String indo,

    /// Hong Kong odds format (e.g., "0.85")
    @Default('') String hk,
  }) = _OddsStyleModelV2;

  const OddsStyleModelV2._();

  /// Factory constructor for JSON deserialization
  /// API returns numeric keys: 0=decimal, 1=malay, 2=indo, 3=hk
  factory OddsStyleModelV2.fromJson(Map<String, dynamic> json) {
    return OddsStyleModelV2(
      decimal: json['0']?.toString() ?? '',
      malay: json['1']?.toString() ?? '',
      indo: json['2']?.toString() ?? '',
      hk: json['3']?.toString() ?? '',
    );
  }

  /// Parse decimal odds to double for calculations
  double get decimalValue => double.tryParse(decimal) ?? 0.0;

  /// Parse malay odds to double
  double get malayValue => double.tryParse(malay) ?? 0.0;

  /// Parse indo odds to double
  double get indoValue => double.tryParse(indo) ?? 0.0;

  /// Parse hk odds to double
  double get hkValue => double.tryParse(hk) ?? 0.0;

  /// Check if odds data is valid/available
  bool get isValid => decimal.isNotEmpty && decimalValue > 0;

  /// Get odds value by format type
  String getOddsByFormat(OddsFormatV2 format) {
    switch (format) {
      case OddsFormatV2.decimal:
        return decimal;
      case OddsFormatV2.malay:
        return malay;
      case OddsFormatV2.indo:
        return indo;
      case OddsFormatV2.hk:
        return hk;
    }
  }

  /// Get odds value as double by format type
  double getValueByFormat(OddsFormatV2 format) {
    switch (format) {
      case OddsFormatV2.decimal:
        return decimalValue;
      case OddsFormatV2.malay:
        return malayValue;
      case OddsFormatV2.indo:
        return indoValue;
      case OddsFormatV2.hk:
        return hkValue;
    }
  }
}

/// Enum for odds format types
enum OddsFormatV2 {
  decimal,
  malay,
  indo,
  hk;

  String get displayName {
    switch (this) {
      case OddsFormatV2.decimal:
        return 'Decimal';
      case OddsFormatV2.malay:
        return 'Malay';
      case OddsFormatV2.indo:
        return 'Indo';
      case OddsFormatV2.hk:
        return 'HK';
    }
  }
}
