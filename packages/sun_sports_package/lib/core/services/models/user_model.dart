import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User Model
///
/// Represents a sportbook user with balance and profile information.
/// Balance is stored in 1K units (e.g., 1000.0 = 1,000,000 VND).
@freezed
sealed class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @JsonKey(name: 'uid') required String uid,
    @JsonKey(name: 'displayName') required String displayName,
    @JsonKey(name: 'cust_login') required String custLogin,
    @JsonKey(name: 'cust_id') required String custId,
    @JsonKey(name: 'balance', fromJson: _parseBalance) required double balance,
    @JsonKey(name: 'currency') @Default('VND') String currency,
    @JsonKey(name: 'status') @Default('Active') String status,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone') String? phone,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Creates a [UserModel] from the raw [Map] returned by
  /// [SbHttpManager.user].
  ///
  /// Keys in the map use server naming (`cust_login`, `cust_id`),
  /// which match the [JsonKey] annotations on this class.
  factory UserModel.fromHttpMap(Map<String, dynamic> httpMap) =>
      UserModel.fromJson(httpMap);

  /// Create empty user
  factory UserModel.empty() => const UserModel(
    uid: '',
    displayName: '',
    custLogin: '',
    custId: '',
    balance: 0.0,
    currency: 'VND',
    status: 'Inactive',
  );
}

/// Parse balance from server format
/// Server returns the balance already in 1K units (e.g. "390" = 390,000 VND).
/// Dots are thousand separators (e.g. "1.500" = 1,500 K units = 1,500,000 VND).
/// We need: 390.0 (double in 1K units)
/// {"0":"________","1":"VND","2":"390","3":"Active","4":"________"}

double _parseBalance(dynamic value) {
  if (value == null) return 0.0;

  if (value is num) {
    return value.toDouble(); // Already in K units from SbHttpManager
  }

  if (value is String) {
    // Remove thousand separators (dots); value is already in K units.
    final cleaned = value.replaceAll('.', '');
    return (int.tryParse(cleaned) ?? 0).toDouble();
  }

  return 0.0;
}

/// User Status Extension
extension UserModelX on UserModel {
  /// Check if user is active
  bool get isActive => status == 'Active';

  /// Check if user is logged in (has valid ID)
  bool get isLoggedIn => uid.isNotEmpty && custId.isNotEmpty;

  /// Get formatted balance string
  String get formattedBalance => '${balance.toStringAsFixed(0)}K $currency';

  /// Get full balance in VND (multiply by 1000)
  double get balanceInVND => balance * 1000;
}
