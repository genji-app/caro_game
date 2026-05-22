import 'package:freezed_annotation/freezed_annotation.dart';

part 'jwt_user_info_model.freezed.dart';
part 'jwt_user_info_model.g.dart';

/// Model for JWT payload user info
///
/// Maps to the structure in wsToken JWT payload.
/// This model represents the complete user information
/// that can be extracted from the JWT token.
@freezed
sealed class JwtUserInfoModel with _$JwtUserInfoModel {
  const JwtUserInfoModel._();

  const factory JwtUserInfoModel({
    // Core user fields (required in JWT)
    required String userId,
    required String username,
    required String displayName,
    required String avatar,
    required String brand,
    required int customerId,
    required int platformId,
    // required int amount, // User balance
    // Optional fields with defaults
    @Default(0) int gender,

    // Boolean fields that come as int (0/1) in JWT
    @JsonKey(fromJson: _intToBool) @Default(false) bool banned,
    @JsonKey(fromJson: _intToBool) @Default(false) bool bot,
    @JsonKey(fromJson: _intToBool) @Default(false) bool lockChat,
    @JsonKey(fromJson: _intToBool) @Default(false) bool mute,
    @JsonKey(fromJson: _intToBool) @Default(false) bool phoneVerified,
    @JsonKey(fromJson: _intToBool) @Default(false) bool deposit,
    @JsonKey(fromJson: _intToBool) @Default(false) bool verifiedBankAccount,
    @JsonKey(fromJson: _intToBool) @Default(false) bool canViewStat,
    @JsonKey(fromJson: _intToBool) @Default(false) bool isMerchant,
    @JsonKey(fromJson: _intToBool) @Default(false) bool playEventLobby,
    @Default([]) List<dynamic> lockGames,

    // Nullable fields
    String? phone,
    String? affId,
    String? ipAddress,
    int? timestamp,
    int? regTime,
  }) = _JwtUserInfoModel;

  factory JwtUserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$JwtUserInfoModelFromJson(json);
}

/// Helper function to convert int (0/1) to bool
///
/// JWT payload uses 0 for false and 1 for true
bool _intToBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  return false;
}
