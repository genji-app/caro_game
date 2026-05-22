/// Codepay create QR response entity for domain layer
class CodepayCreateQrResponse {
  final String bankAccount; // Account number
  final int amount;
  final int statusId;
  final String accountName;
  final String bankBranch;
  final String qrcode; // Base64 QR code image
  final String codepay; // Codepay code
  final String bankName;
  final String message;
  final int remainingTime; // Time in seconds

  const CodepayCreateQrResponse({
    required this.bankAccount,
    required this.amount,
    required this.statusId,
    required this.accountName,
    required this.bankBranch,
    required this.qrcode,
    required this.codepay,
    required this.bankName,
    required this.message,
    required this.remainingTime,
  });

  /// Create from JSON data map
  factory CodepayCreateQrResponse.fromJson(Map<String, dynamic> json) {
    return CodepayCreateQrResponse(
      bankAccount: json['bankAccount']?.toString() ?? '',
      amount: json['amount'] as int? ?? 0,
      statusId: json['statusId'] as int? ?? 0,
      accountName: json['accountName']?.toString() ?? '',
      bankBranch: json['bankBranch']?.toString() ?? '',
      qrcode: json['qrcode']?.toString() ?? '',
      codepay: json['codepay']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      remainingTime: json['remainingTime'] as int? ?? 0,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'bankAccount': bankAccount,
      'amount': amount,
      'statusId': statusId,
      'accountName': accountName,
      'bankBranch': bankBranch,
      'qrcode': qrcode,
      'codepay': codepay,
      'bankName': bankName,
      'message': message,
      'remainingTime': remainingTime,
    };
  }
}
