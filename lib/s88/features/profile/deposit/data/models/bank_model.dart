import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank.dart';

part 'bank_model.freezed.dart';
part 'bank_model.g.dart';

/// Bank model for deposit options with JSON serialization
@freezed
sealed class BankModel with _$BankModel {
  const factory BankModel({
    required String id,
    required String name,
    @JsonKey(name: 'icon_url') String? iconUrl,
  }) = _BankModel;

  /// From JSON
  factory BankModel.fromJson(Map<String, dynamic> json) =>
      _$BankModelFromJson(json);
}

/// Extension for BankModel
extension BankModelX on BankModel {
  /// Convert to domain Bank entity
  Bank toEntity() => Bank(id: id, name: name, iconUrl: iconUrl);
}
