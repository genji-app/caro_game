/// Card (Scratch Card) deposit request entity for domain layer
/// API: {apiDomain}paygate?command=chargeCard
class CardDepositRequest {
  final String serial; // Card serial number
  final String code; // Card code
  final int telcoId; // Telco ID from cashoutGiftCards.items.telcoId
  final int amount; // Price (amount) selected

  const CardDepositRequest({
    required this.serial,
    required this.code,
    required this.telcoId,
    required this.amount,
  });
}
