// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_deposit_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BankDepositRequestModel {

@JsonKey(name: 'bank_id') String get bankId;@JsonKey(name: 'account_number') String get accountNumber;@JsonKey(name: 'account_name') String get accountName; String get amount;
/// Create a copy of BankDepositRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankDepositRequestModelCopyWith<BankDepositRequestModel> get copyWith => _$BankDepositRequestModelCopyWithImpl<BankDepositRequestModel>(this as BankDepositRequestModel, _$identity);

  /// Serializes this BankDepositRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankDepositRequestModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumber,accountName,amount);

@override
String toString() {
  return 'BankDepositRequestModel(bankId: $bankId, accountNumber: $accountNumber, accountName: $accountName, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $BankDepositRequestModelCopyWith<$Res>  {
  factory $BankDepositRequestModelCopyWith(BankDepositRequestModel value, $Res Function(BankDepositRequestModel) _then) = _$BankDepositRequestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bank_id') String bankId,@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'account_name') String accountName, String amount
});




}
/// @nodoc
class _$BankDepositRequestModelCopyWithImpl<$Res>
    implements $BankDepositRequestModelCopyWith<$Res> {
  _$BankDepositRequestModelCopyWithImpl(this._self, this._then);

  final BankDepositRequestModel _self;
  final $Res Function(BankDepositRequestModel) _then;

/// Create a copy of BankDepositRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountNumber = null,Object? accountName = null,Object? amount = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BankDepositRequestModel].
extension BankDepositRequestModelPatterns on BankDepositRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankDepositRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankDepositRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _BankDepositRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankDepositRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'bank_id')  String bankId, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'account_name')  String accountName,  String amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
return $default(_that.bankId,_that.accountNumber,_that.accountName,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'bank_id')  String bankId, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'account_name')  String accountName,  String amount)  $default,) {final _that = this;
switch (_that) {
case _BankDepositRequestModel():
return $default(_that.bankId,_that.accountNumber,_that.accountName,_that.amount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'bank_id')  String bankId, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'account_name')  String accountName,  String amount)?  $default,) {final _that = this;
switch (_that) {
case _BankDepositRequestModel() when $default != null:
return $default(_that.bankId,_that.accountNumber,_that.accountName,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BankDepositRequestModel implements BankDepositRequestModel {
  const _BankDepositRequestModel({@JsonKey(name: 'bank_id') required this.bankId, @JsonKey(name: 'account_number') required this.accountNumber, @JsonKey(name: 'account_name') required this.accountName, required this.amount});
  factory _BankDepositRequestModel.fromJson(Map<String, dynamic> json) => _$BankDepositRequestModelFromJson(json);

@override@JsonKey(name: 'bank_id') final  String bankId;
@override@JsonKey(name: 'account_number') final  String accountNumber;
@override@JsonKey(name: 'account_name') final  String accountName;
@override final  String amount;

/// Create a copy of BankDepositRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankDepositRequestModelCopyWith<_BankDepositRequestModel> get copyWith => __$BankDepositRequestModelCopyWithImpl<_BankDepositRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankDepositRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankDepositRequestModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumber,accountName,amount);

@override
String toString() {
  return 'BankDepositRequestModel(bankId: $bankId, accountNumber: $accountNumber, accountName: $accountName, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$BankDepositRequestModelCopyWith<$Res> implements $BankDepositRequestModelCopyWith<$Res> {
  factory _$BankDepositRequestModelCopyWith(_BankDepositRequestModel value, $Res Function(_BankDepositRequestModel) _then) = __$BankDepositRequestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'bank_id') String bankId,@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'account_name') String accountName, String amount
});




}
/// @nodoc
class __$BankDepositRequestModelCopyWithImpl<$Res>
    implements _$BankDepositRequestModelCopyWith<$Res> {
  __$BankDepositRequestModelCopyWithImpl(this._self, this._then);

  final _BankDepositRequestModel _self;
  final $Res Function(_BankDepositRequestModel) _then;

/// Create a copy of BankDepositRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountNumber = null,Object? accountName = null,Object? amount = null,}) {
  return _then(_BankDepositRequestModel(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
