/// Codepay create QR request entity for domain layer
class CodepayCreateQrRequest {
  final String bankId; // Codepay bank ID
  final int amount; // Amount
  final String bankAccountId; // Bank account ID from codepay.accounts.bankId

  const CodepayCreateQrRequest({
    required this.bankId,
    required this.amount,
    required this.bankAccountId,
  });
}
