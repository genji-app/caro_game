import 'bank.dart';
import 'crypto_config.dart';
import 'payment_config_data.dart';

/// Payment method type enum for identifying bank vs e-wallet vs crypto
enum PaymentMethodType {
  bank(1),
  eWallet(2),
  crypto(4);

  const PaymentMethodType(this.value);
  final int value;

  static PaymentMethodType fromValue(int? value) => switch (value) {
    1 => PaymentMethodType.bank,
    2 => PaymentMethodType.eWallet,
    4 => PaymentMethodType.crypto,
    _ => PaymentMethodType.bank,
  };

  String get label => switch (this) {
    PaymentMethodType.bank => 'Ngân hàng',
    PaymentMethodType.eWallet => 'Ví điện tử',
    PaymentMethodType.crypto => 'Tiền mã hóa',
  };
}

/// Simplified payment method info for UI display
/// Can represent: Bank, E-Wallet (MOMO, ZaloPay, ViettelPay), or Crypto
class PaymentMethodInfo {
  const PaymentMethodInfo({
    required this.id,
    required this.name,
    this.fullName,
    this.shortName,
    this.imageUrl,
    this.methodType = PaymentMethodType.bank,
    this.supportQRCode = false,
    this.supportWithdraw = false,
  });

  final String id;
  final String name;
  final String? fullName;
  final String? shortName;
  final String? imageUrl;
  final PaymentMethodType methodType;
  final bool supportQRCode;
  final bool supportWithdraw;

  /// Display name (prefer shortName, then name)
  String get displayName => shortName ?? name;

  /// Type label for UI (Ngân hàng, Ví điện tử, Tiền mã hóa)
  String get typeLabel => methodType.label;

  /// Is this a bank
  bool get isBank => methodType == PaymentMethodType.bank;

  /// Is this an e-wallet (MOMO, ZaloPay, ViettelPay)
  bool get isEWallet => methodType == PaymentMethodType.eWallet;

  /// Is this crypto
  bool get isCrypto => methodType == PaymentMethodType.crypto;
}

/// Extension to get payment method info by ID
/// Uses cached Map for O(1) lookup performance
extension PaymentConfigDataX on PaymentConfigData {
  /// Build a lookup map for fast access
  /// Called once when needed, result should be cached by consumer
  Map<String, PaymentMethodInfo> buildPaymentMethodMap() {
    final map = <String, PaymentMethodInfo>{};

    // 1. Add items (bank accounts with details)
    for (final item in items ?? <BankItem>[]) {
      if (item.id.isNotEmpty) {
        map[item.id] = PaymentMethodInfo(
          id: item.id,
          name: item.name,
          fullName: item.fullName,
          shortName: item.shortName,
          imageUrl: item.url,
          methodType: PaymentMethodType.fromValue(item.bankType),
          supportQRCode: item.supportQRCode ?? false,
          supportWithdraw: item.supportWithdraw ?? false,
        );
      }
    }

    // 2. Add codepay (banks and e-wallets) - won't override items
    for (final item in codepay ?? <CodePayBank>[]) {
      if (item.id.isNotEmpty && !map.containsKey(item.id)) {
        map[item.id] = PaymentMethodInfo(
          id: item.id,
          name: item.name,
          fullName: item.fullName,
          shortName: item.shortName,
          imageUrl: item.url,
          methodType: PaymentMethodType.fromValue(item.bankType),
          supportQRCode: item.supportQRCode ?? false,
          supportWithdraw: item.supportWithdraw ?? false,
        );
      }
    }

    // 3. Add crypto (uses bankId as key) - won't override existing
    for (final item in crypto ?? <CryptoConfig>[]) {
      final id = item.bankId;
      if (id != null && id.isNotEmpty && !map.containsKey(id)) {
        map[id] = PaymentMethodInfo(
          id: id,
          name: item.currencyName ?? 'Crypto',
          fullName: item.currencyName,
          shortName: item.currencyName,
          imageUrl: null,
          methodType: PaymentMethodType.crypto,
          supportQRCode: false,
          supportWithdraw: false,
        );
      }
    }

    return map;
  }

  /// Get payment method info by ID
  /// Note: For repeated lookups, use buildPaymentMethodMap() and cache the result
  PaymentMethodInfo? getPaymentMethodById(String id) {
    return buildPaymentMethodMap()[id];
  }

  /// Get all available payment methods (from codepay list)
  List<PaymentMethodInfo> get allPaymentMethods {
    return buildPaymentMethodMap().values.toList();
  }
}
