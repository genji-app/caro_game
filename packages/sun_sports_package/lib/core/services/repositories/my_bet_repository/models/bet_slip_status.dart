import 'package:freezed_annotation/freezed_annotation.dart';

/// Status of a bet ticket (lifecycle status)
/// This is different from SettlementStatusEnum which represents settlement status (won/lost/etc)
enum BetSlipStatus {
  active, // Đang hoạt động
  running, // Đang chạy (alias for active)
  pending, // Chờ xử lý
  settled, // Đã kết toán
  declined, // Bị từ chối
  cashout, // Đã xả kèo
  unknown; // Không xác định

  /// Parse from API string value
  factory BetSlipStatus.fromString(String? value) {
    if (value == null || value.isEmpty) return BetSlipStatus.settled;
    final normalized = value.toLowerCase().trim();

    return switch (normalized) {
      'active' || 'running' => BetSlipStatus.active,
      'pending' => BetSlipStatus.pending,
      'settled' => BetSlipStatus.settled,
      'declined' => BetSlipStatus.declined,
      'cashout' => BetSlipStatus.cashout,
      _ => BetSlipStatus.unknown,
    };
  }

  /// Convert to API string value
  String toApiString() => switch (this) {
    BetSlipStatus.active || BetSlipStatus.running => 'Active',
    BetSlipStatus.pending => 'Pending',
    BetSlipStatus.settled => 'Settled',
    BetSlipStatus.declined => 'Declined',
    BetSlipStatus.cashout => 'Cashout',
    BetSlipStatus.unknown => 'Unknown',
  };

  /// Helper: Check if status represents an active/running bet
  bool get isActiveStatus =>
      this == BetSlipStatus.active || this == BetSlipStatus.running;

  /// Helper: Check if bet is pending
  bool get isPendingStatus => this == BetSlipStatus.pending;
}

/// JsonConverter for Freezed integration
class BetSlipStatusConverter implements JsonConverter<BetSlipStatus, String> {
  const BetSlipStatusConverter();

  @override
  BetSlipStatus fromJson(String json) => BetSlipStatus.fromString(json);

  @override
  String toJson(BetSlipStatus object) => object.toApiString();
}
