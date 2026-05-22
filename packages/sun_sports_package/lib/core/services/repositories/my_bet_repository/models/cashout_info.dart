import 'package:freezed_annotation/freezed_annotation.dart';

part 'cashout_info.freezed.dart';
part 'cashout_info.g.dart';

/// Cashout Info - Information about cashout transaction
///
/// Key "24" in API response - Array of cashout transactions
@freezed
sealed class CashoutInfo with _$CashoutInfo {
  const factory CashoutInfo({
    @JsonKey(name: '0') required String id,
    @JsonKey(name: '6') required DateTime time,
    @JsonKey(name: '1') @Default(0) num stakeAmount,
    @JsonKey(name: '3') @Default(0) num cashoutAmount,
    @JsonKey(name: '4') @Default(0.0) double fee,
    @JsonKey(name: '5') @Default(false) bool isSuccess,
  }) = _CashoutInfo;

  factory CashoutInfo.fromJson(Map<String, dynamic> json) =>
      _$CashoutInfoFromJson(json);
}
