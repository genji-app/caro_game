import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/deposit_response.dart';

part 'deposit_response_model.freezed.dart';
part 'deposit_response_model.g.dart';

/// Deposit response model with JSON serialization
@freezed
sealed class DepositResponseModel with _$DepositResponseModel {
  const factory DepositResponseModel({
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'qr_code_url') String? qrCodeUrl,
    @JsonKey(name: 'deposit_address') String? depositAddress,
    @JsonKey(name: 'additional_data') Map<String, dynamic>? additionalData,
  }) = _DepositResponseModel;

  /// From JSON
  factory DepositResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DepositResponseModelFromJson(json);
}

/// Extension for DepositResponseModel
extension DepositResponseModelX on DepositResponseModel {
  /// Convert to domain DepositResponse entity
  DepositResponse toEntity() => DepositResponse(
    transactionId: transactionId,
    qrCodeUrl: qrCodeUrl,
    depositAddress: depositAddress,
    additionalData: additionalData,
  );
}
