import 'package:freezed_annotation/freezed_annotation.dart';

/// Outcome settlement status of a bet (won/lost/etc)
/// This is different from BetSlipStatus which represents the lifecycle status
enum SettlementStatusEnum {
  won, // Thắng
  lost, // Thua
  halfWon, // Thắng 1/2
  halfLost, // Thua 1/2
  draw, // Hoà
  cashout, // Đã bán (Cashout)
  pending, // Đang chờ
  running, // Đang diễn ra
  refunded, // Hoàn tiền
  voided, // Hủy/Hoàn tiền
  processing, // Đang xử lý
  unknown; // Không xác định

  /// Check if the status represents a final result or settled bet
  bool get isSettled => switch (this) {
    SettlementStatusEnum.won ||
    SettlementStatusEnum.lost ||
    SettlementStatusEnum.halfWon ||
    SettlementStatusEnum.halfLost ||
    SettlementStatusEnum.draw ||
    SettlementStatusEnum.cashout ||
    SettlementStatusEnum.refunded ||
    SettlementStatusEnum.voided => true,
    _ => false,
  };

  /// Parse from API string value (handles various formats from different API endpoints)
  factory SettlementStatusEnum.fromString(String? value) {
    if (value == null || value.isEmpty) return SettlementStatusEnum.unknown;

    // Normalize string: lowercase, remove spaces
    final s = value.toLowerCase().replaceAll(' ', '').trim();

    return switch (s) {
      'won' => SettlementStatusEnum.won,
      'lost' => SettlementStatusEnum.lost,
      'wonhalf' || 'halfwon' => SettlementStatusEnum.halfWon,
      'losthalf' || 'halflost' => SettlementStatusEnum.halfLost,
      'draw' || 'tie' => SettlementStatusEnum.draw,
      'void' || 'voided' => SettlementStatusEnum.voided,
      'refund' || 'refunded' => SettlementStatusEnum.refunded,
      'cashout' => SettlementStatusEnum.cashout,
      'pending' => SettlementStatusEnum.pending,
      'running' || 'active' => SettlementStatusEnum.running,
      'processing' => SettlementStatusEnum.processing,
      _ => SettlementStatusEnum.unknown,
    };
  }

  /// Convert to API string value
  String toApiString() => switch (this) {
    SettlementStatusEnum.won => 'Won',
    SettlementStatusEnum.lost => 'Lost',
    SettlementStatusEnum.halfWon => 'Half Won',
    SettlementStatusEnum.halfLost => 'Half Lost',
    SettlementStatusEnum.draw => 'Draw',
    SettlementStatusEnum.voided => 'Voided',
    SettlementStatusEnum.refunded => 'Refunded',
    SettlementStatusEnum.cashout => 'Cashout',
    SettlementStatusEnum.pending => 'Pending',
    SettlementStatusEnum.running => 'Running',
    SettlementStatusEnum.processing => 'Processing',
    SettlementStatusEnum.unknown => 'Unknown',
  };
}

/// JsonConverter for Freezed integration
class SettlementStatusEnumConverter
    implements JsonConverter<SettlementStatusEnum, String> {
  const SettlementStatusEnumConverter();

  @override
  SettlementStatusEnum fromJson(String json) =>
      SettlementStatusEnum.fromString(json);

  @override
  String toJson(SettlementStatusEnum object) => object.toApiString();
}
