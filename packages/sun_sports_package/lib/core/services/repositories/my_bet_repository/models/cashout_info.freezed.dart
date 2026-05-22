// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cashout_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CashoutInfo {

@JsonKey(name: '0') String get id;@JsonKey(name: '6') DateTime get time;@JsonKey(name: '1') num get stakeAmount;@JsonKey(name: '3') num get cashoutAmount;@JsonKey(name: '4') double get fee;@JsonKey(name: '5') bool get isSuccess;
/// Create a copy of CashoutInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashoutInfoCopyWith<CashoutInfo> get copyWith => _$CashoutInfoCopyWithImpl<CashoutInfo>(this as CashoutInfo, _$identity);

  /// Serializes this CashoutInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashoutInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.stakeAmount, stakeAmount) || other.stakeAmount == stakeAmount)&&(identical(other.cashoutAmount, cashoutAmount) || other.cashoutAmount == cashoutAmount)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,stakeAmount,cashoutAmount,fee,isSuccess);

@override
String toString() {
  return 'CashoutInfo(id: $id, time: $time, stakeAmount: $stakeAmount, cashoutAmount: $cashoutAmount, fee: $fee, isSuccess: $isSuccess)';
}


}

/// @nodoc
abstract mixin class $CashoutInfoCopyWith<$Res>  {
  factory $CashoutInfoCopyWith(CashoutInfo value, $Res Function(CashoutInfo) _then) = _$CashoutInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') String id,@JsonKey(name: '6') DateTime time,@JsonKey(name: '1') num stakeAmount,@JsonKey(name: '3') num cashoutAmount,@JsonKey(name: '4') double fee,@JsonKey(name: '5') bool isSuccess
});




}
/// @nodoc
class _$CashoutInfoCopyWithImpl<$Res>
    implements $CashoutInfoCopyWith<$Res> {
  _$CashoutInfoCopyWithImpl(this._self, this._then);

  final CashoutInfo _self;
  final $Res Function(CashoutInfo) _then;

/// Create a copy of CashoutInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? time = null,Object? stakeAmount = null,Object? cashoutAmount = null,Object? fee = null,Object? isSuccess = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,stakeAmount: null == stakeAmount ? _self.stakeAmount : stakeAmount // ignore: cast_nullable_to_non_nullable
as num,cashoutAmount: null == cashoutAmount ? _self.cashoutAmount : cashoutAmount // ignore: cast_nullable_to_non_nullable
as num,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CashoutInfo].
extension CashoutInfoPatterns on CashoutInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashoutInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashoutInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashoutInfo value)  $default,){
final _that = this;
switch (_that) {
case _CashoutInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashoutInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CashoutInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String id, @JsonKey(name: '6')  DateTime time, @JsonKey(name: '1')  num stakeAmount, @JsonKey(name: '3')  num cashoutAmount, @JsonKey(name: '4')  double fee, @JsonKey(name: '5')  bool isSuccess)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashoutInfo() when $default != null:
return $default(_that.id,_that.time,_that.stakeAmount,_that.cashoutAmount,_that.fee,_that.isSuccess);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String id, @JsonKey(name: '6')  DateTime time, @JsonKey(name: '1')  num stakeAmount, @JsonKey(name: '3')  num cashoutAmount, @JsonKey(name: '4')  double fee, @JsonKey(name: '5')  bool isSuccess)  $default,) {final _that = this;
switch (_that) {
case _CashoutInfo():
return $default(_that.id,_that.time,_that.stakeAmount,_that.cashoutAmount,_that.fee,_that.isSuccess);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  String id, @JsonKey(name: '6')  DateTime time, @JsonKey(name: '1')  num stakeAmount, @JsonKey(name: '3')  num cashoutAmount, @JsonKey(name: '4')  double fee, @JsonKey(name: '5')  bool isSuccess)?  $default,) {final _that = this;
switch (_that) {
case _CashoutInfo() when $default != null:
return $default(_that.id,_that.time,_that.stakeAmount,_that.cashoutAmount,_that.fee,_that.isSuccess);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CashoutInfo implements CashoutInfo {
  const _CashoutInfo({@JsonKey(name: '0') required this.id, @JsonKey(name: '6') required this.time, @JsonKey(name: '1') this.stakeAmount = 0, @JsonKey(name: '3') this.cashoutAmount = 0, @JsonKey(name: '4') this.fee = 0.0, @JsonKey(name: '5') this.isSuccess = false});
  factory _CashoutInfo.fromJson(Map<String, dynamic> json) => _$CashoutInfoFromJson(json);

@override@JsonKey(name: '0') final  String id;
@override@JsonKey(name: '6') final  DateTime time;
@override@JsonKey(name: '1') final  num stakeAmount;
@override@JsonKey(name: '3') final  num cashoutAmount;
@override@JsonKey(name: '4') final  double fee;
@override@JsonKey(name: '5') final  bool isSuccess;

/// Create a copy of CashoutInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashoutInfoCopyWith<_CashoutInfo> get copyWith => __$CashoutInfoCopyWithImpl<_CashoutInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashoutInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashoutInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.stakeAmount, stakeAmount) || other.stakeAmount == stakeAmount)&&(identical(other.cashoutAmount, cashoutAmount) || other.cashoutAmount == cashoutAmount)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,stakeAmount,cashoutAmount,fee,isSuccess);

@override
String toString() {
  return 'CashoutInfo(id: $id, time: $time, stakeAmount: $stakeAmount, cashoutAmount: $cashoutAmount, fee: $fee, isSuccess: $isSuccess)';
}


}

/// @nodoc
abstract mixin class _$CashoutInfoCopyWith<$Res> implements $CashoutInfoCopyWith<$Res> {
  factory _$CashoutInfoCopyWith(_CashoutInfo value, $Res Function(_CashoutInfo) _then) = __$CashoutInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') String id,@JsonKey(name: '6') DateTime time,@JsonKey(name: '1') num stakeAmount,@JsonKey(name: '3') num cashoutAmount,@JsonKey(name: '4') double fee,@JsonKey(name: '5') bool isSuccess
});




}
/// @nodoc
class __$CashoutInfoCopyWithImpl<$Res>
    implements _$CashoutInfoCopyWith<$Res> {
  __$CashoutInfoCopyWithImpl(this._self, this._then);

  final _CashoutInfo _self;
  final $Res Function(_CashoutInfo) _then;

/// Create a copy of CashoutInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? time = null,Object? stakeAmount = null,Object? cashoutAmount = null,Object? fee = null,Object? isSuccess = null,}) {
  return _then(_CashoutInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,stakeAmount: null == stakeAmount ? _self.stakeAmount : stakeAmount // ignore: cast_nullable_to_non_nullable
as num,cashoutAmount: null == cashoutAmount ? _self.cashoutAmount : cashoutAmount // ignore: cast_nullable_to_non_nullable
as num,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
