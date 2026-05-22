// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

// ===== CORE IDENTITY =====
 String get uid; String get username; String get displayName; String get custLogin; String get custId;// ===== BALANCE & CURRENCY =====
 double get balance;// In 1K units (e.g., 450.0 = 450,000 VND)
// ===== PROFILE INFO =====
 String get avatarUrl; String get brand;// ===== OPTIONAL FIELDS =====
 String get currency; int get gender;// 0 = unknown, 1 = male, 2 = female
// ===== CONTACT INFO =====
 String? get email; String? get phone;// ===== ACCOUNT STATUS =====
 String get status;// Active, Banned, Inactive
 bool get isBanned; bool get isActivated;// Has made first deposit
 bool get isPhoneVerified; bool get isVerifiedBankAccount;// ===== PLATFORM INFO =====
 int get platformId; int get customerId;// ===== PERMISSIONS & FLAGS =====
 bool get isBot; bool get isLockChat; bool get isMute; bool get canViewStat; bool get isMerchant; bool get playEventLobby; List<dynamic> get lockGames;// ===== METADATA =====
 String? get affId;// Affiliate ID
 String? get ipAddress; int? get timestamp; int? get regTime;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.custLogin, custLogin) || other.custLogin == custLogin)&&(identical(other.custId, custId) || other.custId == custId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isVerifiedBankAccount, isVerifiedBankAccount) || other.isVerifiedBankAccount == isVerifiedBankAccount)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLockChat, isLockChat) || other.isLockChat == isLockChat)&&(identical(other.isMute, isMute) || other.isMute == isMute)&&(identical(other.canViewStat, canViewStat) || other.canViewStat == canViewStat)&&(identical(other.isMerchant, isMerchant) || other.isMerchant == isMerchant)&&(identical(other.playEventLobby, playEventLobby) || other.playEventLobby == playEventLobby)&&const DeepCollectionEquality().equals(other.lockGames, lockGames)&&(identical(other.affId, affId) || other.affId == affId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.regTime, regTime) || other.regTime == regTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,username,displayName,custLogin,custId,balance,avatarUrl,brand,currency,gender,email,phone,status,isBanned,isActivated,isPhoneVerified,isVerifiedBankAccount,platformId,customerId,isBot,isLockChat,isMute,canViewStat,isMerchant,playEventLobby,const DeepCollectionEquality().hash(lockGames),affId,ipAddress,timestamp,regTime]);

@override
String toString() {
  return 'User(uid: $uid, username: $username, displayName: $displayName, custLogin: $custLogin, custId: $custId, balance: $balance, avatarUrl: $avatarUrl, brand: $brand, currency: $currency, gender: $gender, email: $email, phone: $phone, status: $status, isBanned: $isBanned, isActivated: $isActivated, isPhoneVerified: $isPhoneVerified, isVerifiedBankAccount: $isVerifiedBankAccount, platformId: $platformId, customerId: $customerId, isBot: $isBot, isLockChat: $isLockChat, isMute: $isMute, canViewStat: $canViewStat, isMerchant: $isMerchant, playEventLobby: $playEventLobby, lockGames: $lockGames, affId: $affId, ipAddress: $ipAddress, timestamp: $timestamp, regTime: $regTime)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String uid, String username, String displayName, String custLogin, String custId, double balance, String avatarUrl, String brand, String currency, int gender, String? email, String? phone, String status, bool isBanned, bool isActivated, bool isPhoneVerified, bool isVerifiedBankAccount, int platformId, int customerId, bool isBot, bool isLockChat, bool isMute, bool canViewStat, bool isMerchant, bool playEventLobby, List<dynamic> lockGames, String? affId, String? ipAddress, int? timestamp, int? regTime
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? username = null,Object? displayName = null,Object? custLogin = null,Object? custId = null,Object? balance = null,Object? avatarUrl = null,Object? brand = null,Object? currency = null,Object? gender = null,Object? email = freezed,Object? phone = freezed,Object? status = null,Object? isBanned = null,Object? isActivated = null,Object? isPhoneVerified = null,Object? isVerifiedBankAccount = null,Object? platformId = null,Object? customerId = null,Object? isBot = null,Object? isLockChat = null,Object? isMute = null,Object? canViewStat = null,Object? isMerchant = null,Object? playEventLobby = null,Object? lockGames = null,Object? affId = freezed,Object? ipAddress = freezed,Object? timestamp = freezed,Object? regTime = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,custLogin: null == custLogin ? _self.custLogin : custLogin // ignore: cast_nullable_to_non_nullable
as String,custId: null == custId ? _self.custId : custId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isVerifiedBankAccount: null == isVerifiedBankAccount ? _self.isVerifiedBankAccount : isVerifiedBankAccount // ignore: cast_nullable_to_non_nullable
as bool,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLockChat: null == isLockChat ? _self.isLockChat : isLockChat // ignore: cast_nullable_to_non_nullable
as bool,isMute: null == isMute ? _self.isMute : isMute // ignore: cast_nullable_to_non_nullable
as bool,canViewStat: null == canViewStat ? _self.canViewStat : canViewStat // ignore: cast_nullable_to_non_nullable
as bool,isMerchant: null == isMerchant ? _self.isMerchant : isMerchant // ignore: cast_nullable_to_non_nullable
as bool,playEventLobby: null == playEventLobby ? _self.playEventLobby : playEventLobby // ignore: cast_nullable_to_non_nullable
as bool,lockGames: null == lockGames ? _self.lockGames : lockGames // ignore: cast_nullable_to_non_nullable
as List<dynamic>,affId: freezed == affId ? _self.affId : affId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String username,  String displayName,  String custLogin,  String custId,  double balance,  String avatarUrl,  String brand,  String currency,  int gender,  String? email,  String? phone,  String status,  bool isBanned,  bool isActivated,  bool isPhoneVerified,  bool isVerifiedBankAccount,  int platformId,  int customerId,  bool isBot,  bool isLockChat,  bool isMute,  bool canViewStat,  bool isMerchant,  bool playEventLobby,  List<dynamic> lockGames,  String? affId,  String? ipAddress,  int? timestamp,  int? regTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.uid,_that.username,_that.displayName,_that.custLogin,_that.custId,_that.balance,_that.avatarUrl,_that.brand,_that.currency,_that.gender,_that.email,_that.phone,_that.status,_that.isBanned,_that.isActivated,_that.isPhoneVerified,_that.isVerifiedBankAccount,_that.platformId,_that.customerId,_that.isBot,_that.isLockChat,_that.isMute,_that.canViewStat,_that.isMerchant,_that.playEventLobby,_that.lockGames,_that.affId,_that.ipAddress,_that.timestamp,_that.regTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String username,  String displayName,  String custLogin,  String custId,  double balance,  String avatarUrl,  String brand,  String currency,  int gender,  String? email,  String? phone,  String status,  bool isBanned,  bool isActivated,  bool isPhoneVerified,  bool isVerifiedBankAccount,  int platformId,  int customerId,  bool isBot,  bool isLockChat,  bool isMute,  bool canViewStat,  bool isMerchant,  bool playEventLobby,  List<dynamic> lockGames,  String? affId,  String? ipAddress,  int? timestamp,  int? regTime)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.uid,_that.username,_that.displayName,_that.custLogin,_that.custId,_that.balance,_that.avatarUrl,_that.brand,_that.currency,_that.gender,_that.email,_that.phone,_that.status,_that.isBanned,_that.isActivated,_that.isPhoneVerified,_that.isVerifiedBankAccount,_that.platformId,_that.customerId,_that.isBot,_that.isLockChat,_that.isMute,_that.canViewStat,_that.isMerchant,_that.playEventLobby,_that.lockGames,_that.affId,_that.ipAddress,_that.timestamp,_that.regTime);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String username,  String displayName,  String custLogin,  String custId,  double balance,  String avatarUrl,  String brand,  String currency,  int gender,  String? email,  String? phone,  String status,  bool isBanned,  bool isActivated,  bool isPhoneVerified,  bool isVerifiedBankAccount,  int platformId,  int customerId,  bool isBot,  bool isLockChat,  bool isMute,  bool canViewStat,  bool isMerchant,  bool playEventLobby,  List<dynamic> lockGames,  String? affId,  String? ipAddress,  int? timestamp,  int? regTime)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.uid,_that.username,_that.displayName,_that.custLogin,_that.custId,_that.balance,_that.avatarUrl,_that.brand,_that.currency,_that.gender,_that.email,_that.phone,_that.status,_that.isBanned,_that.isActivated,_that.isPhoneVerified,_that.isVerifiedBankAccount,_that.platformId,_that.customerId,_that.isBot,_that.isLockChat,_that.isMute,_that.canViewStat,_that.isMerchant,_that.playEventLobby,_that.lockGames,_that.affId,_that.ipAddress,_that.timestamp,_that.regTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User extends User {
  const _User({required this.uid, required this.username, required this.displayName, required this.custLogin, required this.custId, required this.balance, required this.avatarUrl, required this.brand, this.currency = 'VND', this.gender = 0, this.email, this.phone, this.status = 'Active', this.isBanned = false, this.isActivated = false, this.isPhoneVerified = false, this.isVerifiedBankAccount = false, this.platformId = 0, this.customerId = 0, this.isBot = false, this.isLockChat = false, this.isMute = false, this.canViewStat = false, this.isMerchant = false, this.playEventLobby = false, final  List<dynamic> lockGames = const [], this.affId, this.ipAddress, this.timestamp, this.regTime}): _lockGames = lockGames,super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

// ===== CORE IDENTITY =====
@override final  String uid;
@override final  String username;
@override final  String displayName;
@override final  String custLogin;
@override final  String custId;
// ===== BALANCE & CURRENCY =====
@override final  double balance;
// In 1K units (e.g., 450.0 = 450,000 VND)
// ===== PROFILE INFO =====
@override final  String avatarUrl;
@override final  String brand;
// ===== OPTIONAL FIELDS =====
@override@JsonKey() final  String currency;
@override@JsonKey() final  int gender;
// 0 = unknown, 1 = male, 2 = female
// ===== CONTACT INFO =====
@override final  String? email;
@override final  String? phone;
// ===== ACCOUNT STATUS =====
@override@JsonKey() final  String status;
// Active, Banned, Inactive
@override@JsonKey() final  bool isBanned;
@override@JsonKey() final  bool isActivated;
// Has made first deposit
@override@JsonKey() final  bool isPhoneVerified;
@override@JsonKey() final  bool isVerifiedBankAccount;
// ===== PLATFORM INFO =====
@override@JsonKey() final  int platformId;
@override@JsonKey() final  int customerId;
// ===== PERMISSIONS & FLAGS =====
@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool isLockChat;
@override@JsonKey() final  bool isMute;
@override@JsonKey() final  bool canViewStat;
@override@JsonKey() final  bool isMerchant;
@override@JsonKey() final  bool playEventLobby;
 final  List<dynamic> _lockGames;
@override@JsonKey() List<dynamic> get lockGames {
  if (_lockGames is EqualUnmodifiableListView) return _lockGames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lockGames);
}

// ===== METADATA =====
@override final  String? affId;
// Affiliate ID
@override final  String? ipAddress;
@override final  int? timestamp;
@override final  int? regTime;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.custLogin, custLogin) || other.custLogin == custLogin)&&(identical(other.custId, custId) || other.custId == custId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isVerifiedBankAccount, isVerifiedBankAccount) || other.isVerifiedBankAccount == isVerifiedBankAccount)&&(identical(other.platformId, platformId) || other.platformId == platformId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLockChat, isLockChat) || other.isLockChat == isLockChat)&&(identical(other.isMute, isMute) || other.isMute == isMute)&&(identical(other.canViewStat, canViewStat) || other.canViewStat == canViewStat)&&(identical(other.isMerchant, isMerchant) || other.isMerchant == isMerchant)&&(identical(other.playEventLobby, playEventLobby) || other.playEventLobby == playEventLobby)&&const DeepCollectionEquality().equals(other._lockGames, _lockGames)&&(identical(other.affId, affId) || other.affId == affId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.regTime, regTime) || other.regTime == regTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,username,displayName,custLogin,custId,balance,avatarUrl,brand,currency,gender,email,phone,status,isBanned,isActivated,isPhoneVerified,isVerifiedBankAccount,platformId,customerId,isBot,isLockChat,isMute,canViewStat,isMerchant,playEventLobby,const DeepCollectionEquality().hash(_lockGames),affId,ipAddress,timestamp,regTime]);

@override
String toString() {
  return 'User(uid: $uid, username: $username, displayName: $displayName, custLogin: $custLogin, custId: $custId, balance: $balance, avatarUrl: $avatarUrl, brand: $brand, currency: $currency, gender: $gender, email: $email, phone: $phone, status: $status, isBanned: $isBanned, isActivated: $isActivated, isPhoneVerified: $isPhoneVerified, isVerifiedBankAccount: $isVerifiedBankAccount, platformId: $platformId, customerId: $customerId, isBot: $isBot, isLockChat: $isLockChat, isMute: $isMute, canViewStat: $canViewStat, isMerchant: $isMerchant, playEventLobby: $playEventLobby, lockGames: $lockGames, affId: $affId, ipAddress: $ipAddress, timestamp: $timestamp, regTime: $regTime)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String username, String displayName, String custLogin, String custId, double balance, String avatarUrl, String brand, String currency, int gender, String? email, String? phone, String status, bool isBanned, bool isActivated, bool isPhoneVerified, bool isVerifiedBankAccount, int platformId, int customerId, bool isBot, bool isLockChat, bool isMute, bool canViewStat, bool isMerchant, bool playEventLobby, List<dynamic> lockGames, String? affId, String? ipAddress, int? timestamp, int? regTime
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? username = null,Object? displayName = null,Object? custLogin = null,Object? custId = null,Object? balance = null,Object? avatarUrl = null,Object? brand = null,Object? currency = null,Object? gender = null,Object? email = freezed,Object? phone = freezed,Object? status = null,Object? isBanned = null,Object? isActivated = null,Object? isPhoneVerified = null,Object? isVerifiedBankAccount = null,Object? platformId = null,Object? customerId = null,Object? isBot = null,Object? isLockChat = null,Object? isMute = null,Object? canViewStat = null,Object? isMerchant = null,Object? playEventLobby = null,Object? lockGames = null,Object? affId = freezed,Object? ipAddress = freezed,Object? timestamp = freezed,Object? regTime = freezed,}) {
  return _then(_User(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,custLogin: null == custLogin ? _self.custLogin : custLogin // ignore: cast_nullable_to_non_nullable
as String,custId: null == custId ? _self.custId : custId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isVerifiedBankAccount: null == isVerifiedBankAccount ? _self.isVerifiedBankAccount : isVerifiedBankAccount // ignore: cast_nullable_to_non_nullable
as bool,platformId: null == platformId ? _self.platformId : platformId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLockChat: null == isLockChat ? _self.isLockChat : isLockChat // ignore: cast_nullable_to_non_nullable
as bool,isMute: null == isMute ? _self.isMute : isMute // ignore: cast_nullable_to_non_nullable
as bool,canViewStat: null == canViewStat ? _self.canViewStat : canViewStat // ignore: cast_nullable_to_non_nullable
as bool,isMerchant: null == isMerchant ? _self.isMerchant : isMerchant // ignore: cast_nullable_to_non_nullable
as bool,playEventLobby: null == playEventLobby ? _self.playEventLobby : playEventLobby // ignore: cast_nullable_to_non_nullable
as bool,lockGames: null == lockGames ? _self._lockGames : lockGames // ignore: cast_nullable_to_non_nullable
as List<dynamic>,affId: freezed == affId ? _self.affId : affId // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int?,regTime: freezed == regTime ? _self.regTime : regTime // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
