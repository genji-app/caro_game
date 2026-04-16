import 'package:co_caro_flame/s88/core/services/models/transaction.dart'
    show
        Transaction,
        TransactionPaymentMethod,
        TransactionStatus,
        TransactionSlipType;

extension TransactionX on Transaction {
  String get statusText => statusDescription;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(responseTime);

  TransactionPaymentMethod get paymentMethod => switch (type) {
    1 => TransactionPaymentMethod.ibanking,
    2 => TransactionPaymentMethod.atm,
    3 => TransactionPaymentMethod.office,
    4 => TransactionPaymentMethod.digitalWallets,
    5 => TransactionPaymentMethod.smartPay,
    6 => TransactionPaymentMethod.codePay,
    7 => TransactionPaymentMethod.card,
    8 => TransactionPaymentMethod.crypto,
    9 => TransactionPaymentMethod.qrPay,
    11 => TransactionPaymentMethod.iap,
    _ => TransactionPaymentMethod.other,
  };

  TransactionStatus get transactionStatus => switch (status) {
    1 => TransactionStatus.pending,
    2 => TransactionStatus.success,
    3 => TransactionStatus.rejected,
    4 => TransactionStatus.transfered,
    5 || 9 || 10 => TransactionStatus.processing,
    6 => TransactionStatus.newRequest,
    11 => TransactionStatus.pending,
    12 => TransactionStatus.success,
    _ => TransactionStatus.other,
  };

  TransactionSlipType get transactionSlipType => switch (slipType) {
    1 => TransactionSlipType.deposit,
    2 => TransactionSlipType.withdraw,
    _ => TransactionSlipType.other,
  };
}
