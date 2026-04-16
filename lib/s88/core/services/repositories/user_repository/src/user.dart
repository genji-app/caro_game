import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/models/user_model.dart';
import 'package:co_caro_flame/s88/core/services/repositories/user_repository/src/jwt_user_info_model.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/string_helper.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Unified User Model
///
/// This model combines data from:
/// - JwtUserInfoModel (from JWT token)
/// - UserModel (from HTTP manager)
///
/// It provides a complete view of user information with all available fields.
@freezed
sealed class User with _$User {
  const User._();

  const factory User({
    // ===== CORE IDENTITY =====
    required String uid,
    required String username,
    required String displayName,
    required String custLogin,
    required String custId,

    // ===== BALANCE & CURRENCY =====
    required double balance, // In 1K units (e.g., 450.0 = 450,000 VND)
    // ===== PROFILE INFO =====
    required String avatarUrl,
    required String brand,

    // ===== OPTIONAL FIELDS =====
    @Default('VND') String currency,
    @Default(0) int gender, // 0 = unknown, 1 = male, 2 = female
    // ===== CONTACT INFO =====
    String? email,
    String? phone,

    // ===== ACCOUNT STATUS =====
    @Default('Active') String status, // Active, Banned, Inactive
    @Default(false) bool isBanned,
    @Default(false) bool isActivated, // Has made first deposit
    @Default(false) bool isPhoneVerified,
    @Default(false) bool isVerifiedBankAccount,

    // ===== PLATFORM INFO =====
    @Default(0) int platformId,
    @Default(0) int customerId,

    // ===== PERMISSIONS & FLAGS =====
    @Default(false) bool isBot,
    @Default(false) bool isLockChat,
    @Default(false) bool isMute,
    @Default(false) bool canViewStat,
    @Default(false) bool isMerchant,
    @Default(false) bool playEventLobby,
    @Default([]) List<dynamic> lockGames,

    // ===== METADATA =====
    String? affId, // Affiliate ID
    String? ipAddress,
    int? timestamp,
    int? regTime, // Registration timestamp
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Create from JWT token info
  factory User.fromJwt(JwtUserInfoModel jwt) {
    return User(
      uid: jwt.userId,
      username: jwt.username,
      displayName: jwt.displayName,
      custLogin: jwt.username,
      custId: jwt.customerId.toString(),
      balance: 0, // Convert to 1K units
      // balance: jwt.amount.toDouble() / 1000.0, // Convert to 1K units
      currency: 'VND',
      avatarUrl: jwt.avatar,
      brand: jwt.brand,
      gender: jwt.gender,
      phone: jwt.phone,
      status: jwt.banned ? 'Banned' : 'Active',
      isBanned: jwt.banned,
      isActivated: jwt.deposit,
      isPhoneVerified: jwt.phoneVerified,
      isVerifiedBankAccount: jwt.verifiedBankAccount,
      platformId: jwt.platformId,
      customerId: jwt.customerId,
      isBot: jwt.bot,
      isLockChat: jwt.lockChat,
      isMute: jwt.mute,
      canViewStat: jwt.canViewStat,
      isMerchant: jwt.isMerchant,
      playEventLobby: jwt.playEventLobby,
      lockGames: jwt.lockGames,
      affId: jwt.affId,
      ipAddress: jwt.ipAddress,
      timestamp: jwt.timestamp,
      regTime: jwt.regTime,
    );
  }

  /// Create from UserModel (HTTP manager)
  factory User.fromUserModel(UserModel userModel) {
    return User(
      uid: userModel.uid,
      username: userModel.custLogin,
      displayName: userModel.displayName,
      custLogin: userModel.custLogin,
      custId: userModel.custId,
      balance: userModel.balance,
      currency: userModel.currency,
      avatarUrl: '', // Not available in UserModel
      brand: '', // Not available in UserModel
      email: userModel.email,
      phone: userModel.phone,
      status: userModel.status,
      isBanned: userModel.status == 'Banned',
    );
  }

  /// Merge JWT data with UserModel data (JWT takes priority)
  factory User.merge({required JwtUserInfoModel jwt, UserModel? userModel}) {
    final base = User.fromJwt(jwt);

    // If no UserModel, return JWT-only data
    if (userModel == null) {
      return base;
    }

    // Merge: JWT data takes priority, UserModel fills gaps
    return base.copyWith(
      email: userModel.email ?? base.email,
      balance: userModel.balance,
      // UserModel's balance might be more up-to-date from HTTP
      // but we prefer JWT for consistency
    );
  }

  /// Create empty user (guest)
  factory User.empty() => const User(
    uid: '',
    username: '',
    displayName: 'Guest',
    custLogin: '',
    custId: '',
    balance: 0.0,
    currency: 'VND',
    avatarUrl: '',
    brand: '',
    status: 'Inactive',
  );
}

/// User Extensions
extension UserX on User {
  /// Check if user is logged in
  bool get isLoggedIn => uid.isNotEmpty && custId.isNotEmpty;

  /// Check if user is active
  bool get isActive => status == 'Active' && !isBanned;

  /// Get formatted balance string
  String get formattedBalance => '${balance.toStringAsFixed(0)}K $currency';

  /// Get full balance in VND (multiply by 1000)
  double get balanceInVND => balance * 1000;

  /// Check if user can chat
  bool get canChat => !isLockChat && !isMute && !isBanned;

  /// Check if user can place bets
  bool get canBet => isActive && !isBanned;

  /// Get gender display string
  String get genderDisplay {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return 'Unknown';
    }
  }

  /// Get masked phone number (e.g., 09******78)
  String get maskedPhone => StringHelper.maskPhone(phone);
}
