import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank_deposit_request.dart';

part 'bank_deposit_request_model.freezed.dart';
part 'bank_deposit_request_model.g.dart';

/// Bank deposit request model with JSON serialization
@freezed
sealed class BankDepositRequestModel with _$BankDepositRequestModel {
  const factory BankDepositRequestModel({
    @JsonKey(name: 'bank_id') required String bankId,
    @JsonKey(name: 'account_number') required String accountNumber,
    @JsonKey(name: 'account_name') required String accountName,
    required String amount,
  }) = _BankDepositRequestModel;

  /// From JSON (if needed for response handling)
  factory BankDepositRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BankDepositRequestModelFromJson(json);
}

/// Extension for BankDepositRequestModel
extension BankDepositRequestModelX on BankDepositRequestModel {
  /// Convert to domain BankDepositRequest entity
  BankDepositRequest toEntity() => BankDepositRequest(
    bankId: bankId,
    accountNumber: accountNumber,
    accountName: accountName,
    amount: amount,
  );
}

/// Extension for BankDepositRequest entity
extension BankDepositRequestX on BankDepositRequest {
  /// Convert to model for API serialization
  BankDepositRequestModel toModel() => BankDepositRequestModel(
    bankId: bankId,
    accountNumber: accountNumber,
    accountName: accountName,
    amount: amount,
  );
}
