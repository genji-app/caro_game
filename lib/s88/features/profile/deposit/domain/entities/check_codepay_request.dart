/// Check Codepay request entity for domain layer
/// Used to check if a Codepay QR code was previously created
class CheckCodePayRequest {
  final String bankAccountId; // Bank account ID (same as createCodePay)
  final String bankId; // Bank ID (same as createCodePay)
  final String type; // Type: "cc_v363" (passed directly)

  const CheckCodePayRequest({
    required this.bankAccountId,
    required this.bankId,
    required this.type,
  });
}
