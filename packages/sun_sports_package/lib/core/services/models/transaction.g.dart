// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bank _$BankFromJson(Map<String, dynamic> json) => _Bank(
  bankId: json['bankId'] as String,
  publicRss: (json['publicRss'] as num).toInt(),
  type: (json['type'] as num).toInt(),
  accountName: json['accountName'] as String?,
  accountNumber: json['accountNumber'] as String?,
);

Map<String, dynamic> _$BankToJson(_Bank instance) => <String, dynamic>{
  'bankId': instance.bankId,
  'publicRss': instance.publicRss,
  'type': instance.type,
  'accountName': instance.accountName,
  'accountNumber': instance.accountNumber,
};

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: (json['id'] as num).toInt(),
  transactionCode: json['transactionCode'] as String,
  amount: json['amount'] as num,
  type: (json['type'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  slipType: (json['slipType'] as num).toInt(),
  statusDescription: json['statusDescription'] as String,
  bankSent: Bank.fromJson(json['bankSent'] as Map<String, dynamic>),
  bankReceive: Bank.fromJson(json['bankReceive'] as Map<String, dynamic>),
  requestTime: (json['requestTime'] as num).toInt(),
  responseTime: (json['responseTime'] as num).toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionCode': instance.transactionCode,
      'amount': instance.amount,
      'type': instance.type,
      'status': instance.status,
      'slipType': instance.slipType,
      'statusDescription': instance.statusDescription,
      'bankSent': instance.bankSent.toJson(),
      'bankReceive': instance.bankReceive.toJson(),
      'requestTime': instance.requestTime,
      'responseTime': instance.responseTime,
      'notes': instance.notes,
    };

_TransactionResponseData _$TransactionResponseDataFromJson(
  Map<String, dynamic> json,
) => _TransactionResponseData(
  count: (json['count'] as num).toInt(),
  message: json['message'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TransactionResponseDataToJson(
  _TransactionResponseData instance,
) => <String, dynamic>{
  'count': instance.count,
  'message': instance.message,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
