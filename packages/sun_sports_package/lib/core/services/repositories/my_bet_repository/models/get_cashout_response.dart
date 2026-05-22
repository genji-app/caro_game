import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_cashout_response.freezed.dart';
part 'get_cashout_response.g.dart';

/// Get Cashout Response Model
///
/// API Input (POST request):
/// - amount: 47500 (số tiền cash out mong muốn)
/// - displayOdds: "0.66" (tỷ lệ hiển thị)
/// - stake: 50000 (số tiền cược ban đầu)
/// - ticketId: "542273190" (ID vé cược)
/// - token: "32-40393e000f724261cfdd73aca340b1c5" (token xác thực)
/// - userId: "" (ID người dùng)
///
/// API Response format (numeric keys):
/// {
///   "0": "542273190",  // Ticket ID
///   "1": true,         // Trạng thái có thể cash out
///   "3": 47500,        // Số tiền cash out hiện tại
///   "4": 1.66,         // Tỷ lệ cược hiện tại (odds)
///   "5": 0,            // Phí hoặc giá trị điều chỉnh
///   "6": 50000,        // Số tiền cược gốc (stake)
/// }
@freezed
sealed class GetCashoutResponse with _$GetCashoutResponse {
  const factory GetCashoutResponse({
    /// Ticket ID - ID của vé cược
    @JsonKey(name: '0') required String ticketId,

    /// Cash out availability - Trạng thái có thể cash out hay không
    @JsonKey(name: '1') required bool isCashoutAvailable,

    /// Current cashout amount - Số tiền cash out hiện tại có thể nhận được
    @JsonKey(name: '3') num? cashoutAmount,

    /// Current odds - Tỷ lệ cược hiện tại
    @JsonKey(name: '4') num? odds,

    /// Fee or adjustment value - Phí hoặc giá trị điều chỉnh (thường là 0)
    @JsonKey(name: '5') num? feeOrAdjustment,

    /// Original stake amount - Số tiền cược ban đầu
    @JsonKey(name: '6') num? originalStake,
  }) = _GetCashoutResponse;

  /// Parse from numeric key format JSON
  factory GetCashoutResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCashoutResponseFromJson(json);
}
