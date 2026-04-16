// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_deposit_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BankDepositRequestModel _$BankDepositRequestModelFromJson(
  Map<String, dynamic> json,
) => _BankDepositRequestModel(
  bankId: json['bank_id'] as String,
  accountNumber: json['account_number'] as String,
  accountName: json['account_name'] as String,
  amount: json['amount'] as String,
);

Map<String, dynamic> _$BankDepositRequestModelToJson(
  _BankDepositRequestModel instance,
) => <String, dynamic>{
  'bank_id': instance.bankId,
  'account_number': instance.accountNumber,
  'account_name': instance.accountName,
  'amount': instance.amount,
};
