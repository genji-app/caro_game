import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionPaymentMethod {
  ibanking,
  atm,
  office,
  digitalWallets,
  smartPay,
  codePay,
  card,
  crypto,
  qrPay,
  iap,
  other,
}

enum TransactionSlipType { deposit, withdraw, other }

enum TransactionStatus {
  pending,
  success,
  rejected,
  transfered,
  processing,
  newRequest,
  other,
}

@freezed
sealed class Bank with _$Bank {
  const factory Bank({
    @JsonKey(name: 'bankId') required String bankId,
    @JsonKey(name: 'publicRss') required int publicRss,
    @JsonKey(name: 'type') required int type,
    @JsonKey(name: 'accountName') String? accountName,
    @JsonKey(name: 'accountNumber') String? accountNumber,
  }) = _Bank;

  factory Bank.fromJson(Map<String, Object?> json) => _$BankFromJson(json);
}

@freezed
sealed class Transaction with _$Transaction {
  const factory Transaction({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'transactionCode') required String transactionCode,
    @JsonKey(name: 'amount') required num amount,
    @JsonKey(name: 'type') required int type,
    @JsonKey(name: 'status') required int status,
    @JsonKey(name: 'slipType') required int slipType,
    @JsonKey(name: 'statusDescription') required String statusDescription,
    @JsonKey(name: 'bankSent') required Bank bankSent,
    @JsonKey(name: 'bankReceive') required Bank bankReceive,
    @JsonKey(name: 'requestTime') required int requestTime,
    @JsonKey(name: 'responseTime') required int responseTime,
    @JsonKey(name: 'notes') String? notes,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, Object?> json) =>
      _$TransactionFromJson(json);
}

@freezed
abstract class TransactionResponseData with _$TransactionResponseData {
  const factory TransactionResponseData({
    @JsonKey(name: 'count') required int count,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'items') required List<Transaction> items,
  }) = _TransactionResponseData;

  factory TransactionResponseData.fromJson(Map<String, Object?> json) =>
      _$TransactionResponseDataFromJson(json);
}

// extension TransactionX on Transaction {
//   String get statusText => statusDescription;

//   DateTime get date => DateTime.fromMillisecondsSinceEpoch(responseTime);

//   TransactionPaymentMethod get paymentMethod => switch (type) {
//     1 => TransactionPaymentMethod.ibanking,
//     2 => TransactionPaymentMethod.atm,
//     3 => TransactionPaymentMethod.office,
//     4 => TransactionPaymentMethod.digitalWallets,
//     5 => TransactionPaymentMethod.smartPay,
//     6 => TransactionPaymentMethod.codePay,
//     7 => TransactionPaymentMethod.card,
//     8 => TransactionPaymentMethod.crypto,
//     9 => TransactionPaymentMethod.qrPay,
//     11 => TransactionPaymentMethod.iap,
//     _ => TransactionPaymentMethod.other,
//   };

//   TransactionStatus get transactionStatus => switch (status) {
//     1 => TransactionStatus.pending,
//     2 => TransactionStatus.success,
//     3 => TransactionStatus.rejected,
//     4 => TransactionStatus.transfered,
//     5 || 9 || 10 => TransactionStatus.processing,
//     6 => TransactionStatus.newRequest,
//     11 => TransactionStatus.pending,
//     12 => TransactionStatus.success,
//     _ => TransactionStatus.other,
//   };

//   TransactionSlipType get transactionSlipType => switch (slipType) {
//     1 => TransactionSlipType.deposit,
//     2 => TransactionSlipType.withdraw,
//     _ => TransactionSlipType.other,
//   };
// }
