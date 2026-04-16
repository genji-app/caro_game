/// Bank transaction slip request entity for domain layer
/// Used for creating transaction slip via API
class BankTransactionSlipRequest {
  final String bankAccountId; // ID của account trong items
  final int amount; // Số tiền (đã clean)
  final String accountName; // Tên người gửi
  final String transactionCode; // Mã giao dịch (ghi chú)
  final int type; // Type trong account

  const BankTransactionSlipRequest({
    required this.bankAccountId,
    required this.amount,
    required this.accountName,
    required this.transactionCode,
    required this.type,
  });
}
