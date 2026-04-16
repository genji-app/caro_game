import '../models/models.dart';

/// Centralized service for parsing bet status from BetSlip
class SettlementStatusParser {
  /// Parse SettlementStatusEnum from BetSlip
  static SettlementStatusEnum parseStatus(BetSlip bet) {
    // Priority 1: Check if cashed out
    if (bet.status == BetSlipStatus.cashout) {
      return SettlementStatusEnum.cashout;
    }

    final ticketStatus = bet.status;
    final settlementStatus = bet.settlementStatus?.toLowerCase();

    // If status is unknown/empty (fallback check), use settlementStatus
    if (ticketStatus == BetSlipStatus.unknown && settlementStatus != null) {
      return _parseFromSettlementStatus(settlementStatus, bet);
    }

    // Parse primary status
    return _parseFromStatus(ticketStatus, settlementStatus, bet);
  }

  static SettlementStatusEnum _parseFromSettlementStatus(
    String settlementStatus,
    BetSlip bet,
  ) {
    switch (settlementStatus) {
      case 'active':
        return SettlementStatusEnum.running;
      case 'settled':
        if (bet.winning > 0) return SettlementStatusEnum.won;
        if (bet.stake > 0 && bet.winning == 0) return SettlementStatusEnum.lost;
        return SettlementStatusEnum.draw;
      case 'cashout':
        return SettlementStatusEnum.cashout;
      case 'pending':
        return SettlementStatusEnum.pending;
      default:
        return SettlementStatusEnum.pending;
    }
  }

  static SettlementStatusEnum _parseFromStatus(
    BetSlipStatus ticketStatus,
    String? settlementStatus,
    BetSlip bet,
  ) {
    switch (ticketStatus) {
      case BetSlipStatus.cashout:
        return SettlementStatusEnum.cashout;
      case BetSlipStatus.pending:
        return SettlementStatusEnum.pending;
      case BetSlipStatus.active:
      case BetSlipStatus.running:
        return SettlementStatusEnum.running;
      case BetSlipStatus.declined:
        return SettlementStatusEnum
            .pending; // Or added a declined status to SettlementStatusEnum if needed
      case BetSlipStatus.settled:
        if (settlementStatus != null) {
          return _parseFromSettlementStatus(settlementStatus, bet);
        }
        // Fallback calculation based on amounts
        if (bet.winning > 0) return SettlementStatusEnum.won;
        if (bet.stake > 0 && bet.winning == 0) return SettlementStatusEnum.lost;
        return SettlementStatusEnum.draw;
      case BetSlipStatus.unknown:
        if (settlementStatus != null) {
          return _parseFromSettlementStatus(settlementStatus, bet);
        }
        return SettlementStatusEnum.pending;
    }
  }
}
