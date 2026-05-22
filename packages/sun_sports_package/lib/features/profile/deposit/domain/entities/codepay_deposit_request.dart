/// Codepay deposit request entity for domain layer
class CodepayDepositRequest {
  final String bankId; // Selected bank ID
  final String amount;

  const CodepayDepositRequest({required this.bankId, required this.amount});
}
