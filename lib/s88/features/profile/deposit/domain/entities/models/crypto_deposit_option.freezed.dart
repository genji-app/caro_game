// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crypto_deposit_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CryptoDepositOption {

 List<String> get depositNetworks; String get bankId; String get currencyName; String get exchangeRateString; int get exchangeRate; int get fee; String get network;
/// Create a copy of CryptoDepositOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoDepositOptionCopyWith<CryptoDepositOption> get copyWith => _$CryptoDepositOptionCopyWithImpl<CryptoDepositOption>(this as CryptoDepositOption, _$identity);

  /// Serializes this CryptoDepositOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoDepositOption&&const DeepCollectionEquality().equals(other.depositNetworks, depositNetworks)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.exchangeRateString, exchangeRateString) || other.exchangeRateString == exchangeRateString)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(depositNetworks),bankId,currencyName,exchangeRateString,exchangeRate,fee,network);

@override
String toString() {
  return 'CryptoDepositOption(depositNetworks: $depositNetworks, bankId: $bankId, currencyName: $currencyName, exchangeRateString: $exchangeRateString, exchangeRate: $exchangeRate, fee: $fee, network: $network)';
}


}

/// @nodoc
abstract mixin class $CryptoDepositOptionCopyWith<$Res>  {
  factory $CryptoDepositOptionCopyWith(CryptoDepositOption value, $Res Function(CryptoDepositOption) _then) = _$CryptoDepositOptionCopyWithImpl;
@useResult
$Res call({
 List<String> depositNetworks, String bankId, String currencyName, String exchangeRateString, int exchangeRate, int fee, String network
});




}
/// @nodoc
class _$CryptoDepositOptionCopyWithImpl<$Res>
    implements $CryptoDepositOptionCopyWith<$Res> {
  _$CryptoDepositOptionCopyWithImpl(this._self, this._then);

  final CryptoDepositOption _self;
  final $Res Function(CryptoDepositOption) _then;

/// Create a copy of CryptoDepositOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? depositNetworks = null,Object? bankId = null,Object? currencyName = null,Object? exchangeRateString = null,Object? exchangeRate = null,Object? fee = null,Object? network = null,}) {
  return _then(_self.copyWith(
depositNetworks: null == depositNetworks ? _self.depositNetworks : depositNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,exchangeRateString: null == exchangeRateString ? _self.exchangeRateString : exchangeRateString // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as int,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CryptoDepositOption].
extension CryptoDepositOptionPatterns on CryptoDepositOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CryptoDepositOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CryptoDepositOption value)  $default,){
final _that = this;
switch (_that) {
case _CryptoDepositOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CryptoDepositOption value)?  $default,){
final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> depositNetworks,  String bankId,  String currencyName,  String exchangeRateString,  int exchangeRate,  int fee,  String network)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
return $default(_that.depositNetworks,_that.bankId,_that.currencyName,_that.exchangeRateString,_that.exchangeRate,_that.fee,_that.network);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> depositNetworks,  String bankId,  String currencyName,  String exchangeRateString,  int exchangeRate,  int fee,  String network)  $default,) {final _that = this;
switch (_that) {
case _CryptoDepositOption():
return $default(_that.depositNetworks,_that.bankId,_that.currencyName,_that.exchangeRateString,_that.exchangeRate,_that.fee,_that.network);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> depositNetworks,  String bankId,  String currencyName,  String exchangeRateString,  int exchangeRate,  int fee,  String network)?  $default,) {final _that = this;
switch (_that) {
case _CryptoDepositOption() when $default != null:
return $default(_that.depositNetworks,_that.bankId,_that.currencyName,_that.exchangeRateString,_that.exchangeRate,_that.fee,_that.network);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CryptoDepositOption implements CryptoDepositOption {
  const _CryptoDepositOption({final  List<String> depositNetworks = const [], required this.bankId, required this.currencyName, required this.exchangeRateString, required this.exchangeRate, required this.fee, required this.network}): _depositNetworks = depositNetworks;
  factory _CryptoDepositOption.fromJson(Map<String, dynamic> json) => _$CryptoDepositOptionFromJson(json);

 final  List<String> _depositNetworks;
@override@JsonKey() List<String> get depositNetworks {
  if (_depositNetworks is EqualUnmodifiableListView) return _depositNetworks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_depositNetworks);
}

@override final  String bankId;
@override final  String currencyName;
@override final  String exchangeRateString;
@override final  int exchangeRate;
@override final  int fee;
@override final  String network;

/// Create a copy of CryptoDepositOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoDepositOptionCopyWith<_CryptoDepositOption> get copyWith => __$CryptoDepositOptionCopyWithImpl<_CryptoDepositOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoDepositOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoDepositOption&&const DeepCollectionEquality().equals(other._depositNetworks, _depositNetworks)&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.exchangeRateString, exchangeRateString) || other.exchangeRateString == exchangeRateString)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_depositNetworks),bankId,currencyName,exchangeRateString,exchangeRate,fee,network);

@override
String toString() {
  return 'CryptoDepositOption(depositNetworks: $depositNetworks, bankId: $bankId, currencyName: $currencyName, exchangeRateString: $exchangeRateString, exchangeRate: $exchangeRate, fee: $fee, network: $network)';
}


}

/// @nodoc
abstract mixin class _$CryptoDepositOptionCopyWith<$Res> implements $CryptoDepositOptionCopyWith<$Res> {
  factory _$CryptoDepositOptionCopyWith(_CryptoDepositOption value, $Res Function(_CryptoDepositOption) _then) = __$CryptoDepositOptionCopyWithImpl;
@override @useResult
$Res call({
 List<String> depositNetworks, String bankId, String currencyName, String exchangeRateString, int exchangeRate, int fee, String network
});




}
/// @nodoc
class __$CryptoDepositOptionCopyWithImpl<$Res>
    implements _$CryptoDepositOptionCopyWith<$Res> {
  __$CryptoDepositOptionCopyWithImpl(this._self, this._then);

  final _CryptoDepositOption _self;
  final $Res Function(_CryptoDepositOption) _then;

/// Create a copy of CryptoDepositOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? depositNetworks = null,Object? bankId = null,Object? currencyName = null,Object? exchangeRateString = null,Object? exchangeRate = null,Object? fee = null,Object? network = null,}) {
  return _then(_CryptoDepositOption(
depositNetworks: null == depositNetworks ? _self._depositNetworks : depositNetworks // ignore: cast_nullable_to_non_nullable
as List<String>,bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,exchangeRateString: null == exchangeRateString ? _self.exchangeRateString : exchangeRateString // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as int,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
