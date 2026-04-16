import 'package:freezed_annotation/freezed_annotation.dart';

part 'codepay_account.freezed.dart';
part 'codepay_account.g.dart';

enum BankBranch {
  @JsonValue('AUTOMOMO')
  automomo,
  @JsonValue('NICEPAY')
  nicepay,
  @JsonValue('SUNPAY')
  sunpay,
  @JsonValue('UNKNOWN')
  unknown,
}

/// Custom JSON converter for BankBranch to handle unknown values
class BankBranchConverter implements JsonConverter<BankBranch, String> {
  const BankBranchConverter();

  @override
  BankBranch fromJson(String json) {
    switch (json) {
      case 'AUTOMOMO':
        return BankBranch.automomo;
      case 'NICEPAY':
        return BankBranch.nicepay;
      case 'SUNPAY':
        return BankBranch.sunpay;
      default:
        return BankBranch.unknown;
    }
  }

  @override
  String toJson(BankBranch object) {
    switch (object) {
      case BankBranch.automomo:
        return 'AUTOMOMO';
      case BankBranch.nicepay:
        return 'NICEPAY';
      case BankBranch.sunpay:
        return 'SUNPAY';
      case BankBranch.unknown:
        return 'UNKNOWN';
    }
  }
}

@freezed
sealed class CodepayAccount with _$CodepayAccount {
  const factory CodepayAccount({
    required String bankId,
    required String accountName,
    @BankBranchConverter() required BankBranch bankBranch,
    required int publicRss,
    required String id,
    required String accountNumber,
    required int type,
  }) = _CodepayAccount;

  factory CodepayAccount.fromJson(Map<String, dynamic> json) =>
      _$CodepayAccountFromJson(json);
}
