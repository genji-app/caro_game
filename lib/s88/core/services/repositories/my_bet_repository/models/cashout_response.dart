// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cashout_response.freezed.dart';
// part 'cashout_response.g.dart';

/// Cash Out Response Model
///
/// API Endpoint: POST /cash-out?sportId=1
///
/// API Input (POST request):
/// - amount: 47500 (số tiền cash out)
/// - displayOdds: "0.66" (tỷ lệ hiển thị)
/// - stake: 50000 (số tiền cược ban đầu)
/// - ticketId: "542273190" (ID vé cược)
/// - token: "32-e3fddd042b6824a6b08c599f392bf424" (token xác thực)
/// - userId: "" (ID người dùng)
///
/// API Response format (numeric keys):
/// {
///   "0": "542273190",  // Ticket ID
///   "1": true,         // Trạng thái thành công
///   "2": "Settled",    // Trạng thái thanh toán
///   "3": 47500,        // Số tiền cash out đã nhận
///   "4": 1.66,         // Tỷ lệ cược cuối cùng
///   "6": 50000,        // Số tiền cược gốc (stake)
/// }
@freezed
sealed class CashoutResponse with _$CashoutResponse {
  const factory CashoutResponse({
    /// Ticket ID - ID của vé cược
    @JsonKey(name: '0') required String ticketId,

    /// Success status - Trạng thái thành công
    @JsonKey(name: '1') @Default(false) bool isSuccess,

    /// Settlement status - Trạng thái thanh toán (e.g., "Settled")
    @JsonKey(name: '2') required String settlementStatus,

    /// Cash out amount received - Số tiền cash out đã nhận được
    @JsonKey(name: '3') num? cashoutAmount,

    /// Final odds - Tỷ lệ cược cuối cùng
    @JsonKey(name: '4') num? odds,

    /// Original stake amount - Số tiền cược ban đầu
    @JsonKey(name: '6') num? originalStake,
  }) = _CashoutResponse;

  /// Parse from numeric key format JSON
  factory CashoutResponse.fromJson(Map<String, dynamic> json) {
    // Robust parsing to handle potential type mismatches or nulls from API
    return CashoutResponse(
      ticketId: json['0']?.toString() ?? '',
      isSuccess: _parseBool(json['1']),
      settlementStatus: json['2']?.toString() ?? '',
      cashoutAmount: json['3'] as num? ?? 0,
      odds: json['4'] as num? ?? 0,
      originalStake: json['6'] as num? ?? 0,
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}
