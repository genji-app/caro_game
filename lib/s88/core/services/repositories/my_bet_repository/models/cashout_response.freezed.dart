// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cashout_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CashoutResponse {

/// Ticket ID - ID của vé cược
@JsonKey(name: '0') String get ticketId;/// Success status - Trạng thái thành công
@JsonKey(name: '1') bool get isSuccess;/// Settlement status - Trạng thái thanh toán (e.g., "Settled")
@JsonKey(name: '2') String get settlementStatus;/// Cash out amount received - Số tiền cash out đã nhận được
@JsonKey(name: '3') num? get cashoutAmount;/// Final odds - Tỷ lệ cược cuối cùng
@JsonKey(name: '4') num? get odds;/// Original stake amount - Số tiền cược ban đầu
@JsonKey(name: '6') num? get originalStake;
/// Create a copy of CashoutResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashoutResponseCopyWith<CashoutResponse> get copyWith => _$CashoutResponseCopyWithImpl<CashoutResponse>(this as CashoutResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashoutResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.settlementStatus, settlementStatus) || other.settlementStatus == settlementStatus)&&(identical(other.cashoutAmount, cashoutAmount) || other.cashoutAmount == cashoutAmount)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.originalStake, originalStake) || other.originalStake == originalStake));
}


@override
int get hashCode => Object.hash(runtimeType,ticketId,isSuccess,settlementStatus,cashoutAmount,odds,originalStake);

@override
String toString() {
  return 'CashoutResponse(ticketId: $ticketId, isSuccess: $isSuccess, settlementStatus: $settlementStatus, cashoutAmount: $cashoutAmount, odds: $odds, originalStake: $originalStake)';
}


}

/// @nodoc
abstract mixin class $CashoutResponseCopyWith<$Res>  {
  factory $CashoutResponseCopyWith(CashoutResponse value, $Res Function(CashoutResponse) _then) = _$CashoutResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') String ticketId,@JsonKey(name: '1') bool isSuccess,@JsonKey(name: '2') String settlementStatus,@JsonKey(name: '3') num? cashoutAmount,@JsonKey(name: '4') num? odds,@JsonKey(name: '6') num? originalStake
});




}
/// @nodoc
class _$CashoutResponseCopyWithImpl<$Res>
    implements $CashoutResponseCopyWith<$Res> {
  _$CashoutResponseCopyWithImpl(this._self, this._then);

  final CashoutResponse _self;
  final $Res Function(CashoutResponse) _then;

/// Create a copy of CashoutResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = null,Object? isSuccess = null,Object? settlementStatus = null,Object? cashoutAmount = freezed,Object? odds = freezed,Object? originalStake = freezed,}) {
  return _then(_self.copyWith(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,settlementStatus: null == settlementStatus ? _self.settlementStatus : settlementStatus // ignore: cast_nullable_to_non_nullable
as String,cashoutAmount: freezed == cashoutAmount ? _self.cashoutAmount : cashoutAmount // ignore: cast_nullable_to_non_nullable
as num?,odds: freezed == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as num?,originalStake: freezed == originalStake ? _self.originalStake : originalStake // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [CashoutResponse].
extension CashoutResponsePatterns on CashoutResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashoutResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashoutResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashoutResponse value)  $default,){
final _that = this;
switch (_that) {
case _CashoutResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashoutResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CashoutResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String ticketId, @JsonKey(name: '1')  bool isSuccess, @JsonKey(name: '2')  String settlementStatus, @JsonKey(name: '3')  num? cashoutAmount, @JsonKey(name: '4')  num? odds, @JsonKey(name: '6')  num? originalStake)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashoutResponse() when $default != null:
return $default(_that.ticketId,_that.isSuccess,_that.settlementStatus,_that.cashoutAmount,_that.odds,_that.originalStake);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String ticketId, @JsonKey(name: '1')  bool isSuccess, @JsonKey(name: '2')  String settlementStatus, @JsonKey(name: '3')  num? cashoutAmount, @JsonKey(name: '4')  num? odds, @JsonKey(name: '6')  num? originalStake)  $default,) {final _that = this;
switch (_that) {
case _CashoutResponse():
return $default(_that.ticketId,_that.isSuccess,_that.settlementStatus,_that.cashoutAmount,_that.odds,_that.originalStake);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  String ticketId, @JsonKey(name: '1')  bool isSuccess, @JsonKey(name: '2')  String settlementStatus, @JsonKey(name: '3')  num? cashoutAmount, @JsonKey(name: '4')  num? odds, @JsonKey(name: '6')  num? originalStake)?  $default,) {final _that = this;
switch (_that) {
case _CashoutResponse() when $default != null:
return $default(_that.ticketId,_that.isSuccess,_that.settlementStatus,_that.cashoutAmount,_that.odds,_that.originalStake);case _:
  return null;

}
}

}

/// @nodoc


class _CashoutResponse implements CashoutResponse {
  const _CashoutResponse({@JsonKey(name: '0') required this.ticketId, @JsonKey(name: '1') this.isSuccess = false, @JsonKey(name: '2') required this.settlementStatus, @JsonKey(name: '3') this.cashoutAmount, @JsonKey(name: '4') this.odds, @JsonKey(name: '6') this.originalStake});
  

/// Ticket ID - ID của vé cược
@override@JsonKey(name: '0') final  String ticketId;
/// Success status - Trạng thái thành công
@override@JsonKey(name: '1') final  bool isSuccess;
/// Settlement status - Trạng thái thanh toán (e.g., "Settled")
@override@JsonKey(name: '2') final  String settlementStatus;
/// Cash out amount received - Số tiền cash out đã nhận được
@override@JsonKey(name: '3') final  num? cashoutAmount;
/// Final odds - Tỷ lệ cược cuối cùng
@override@JsonKey(name: '4') final  num? odds;
/// Original stake amount - Số tiền cược ban đầu
@override@JsonKey(name: '6') final  num? originalStake;

/// Create a copy of CashoutResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashoutResponseCopyWith<_CashoutResponse> get copyWith => __$CashoutResponseCopyWithImpl<_CashoutResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashoutResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.settlementStatus, settlementStatus) || other.settlementStatus == settlementStatus)&&(identical(other.cashoutAmount, cashoutAmount) || other.cashoutAmount == cashoutAmount)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.originalStake, originalStake) || other.originalStake == originalStake));
}


@override
int get hashCode => Object.hash(runtimeType,ticketId,isSuccess,settlementStatus,cashoutAmount,odds,originalStake);

@override
String toString() {
  return 'CashoutResponse(ticketId: $ticketId, isSuccess: $isSuccess, settlementStatus: $settlementStatus, cashoutAmount: $cashoutAmount, odds: $odds, originalStake: $originalStake)';
}


}

/// @nodoc
abstract mixin class _$CashoutResponseCopyWith<$Res> implements $CashoutResponseCopyWith<$Res> {
  factory _$CashoutResponseCopyWith(_CashoutResponse value, $Res Function(_CashoutResponse) _then) = __$CashoutResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') String ticketId,@JsonKey(name: '1') bool isSuccess,@JsonKey(name: '2') String settlementStatus,@JsonKey(name: '3') num? cashoutAmount,@JsonKey(name: '4') num? odds,@JsonKey(name: '6') num? originalStake
});




}
/// @nodoc
class __$CashoutResponseCopyWithImpl<$Res>
    implements _$CashoutResponseCopyWith<$Res> {
  __$CashoutResponseCopyWithImpl(this._self, this._then);

  final _CashoutResponse _self;
  final $Res Function(_CashoutResponse) _then;

/// Create a copy of CashoutResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = null,Object? isSuccess = null,Object? settlementStatus = null,Object? cashoutAmount = freezed,Object? odds = freezed,Object? originalStake = freezed,}) {
  return _then(_CashoutResponse(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,settlementStatus: null == settlementStatus ? _self.settlementStatus : settlementStatus // ignore: cast_nullable_to_non_nullable
as String,cashoutAmount: freezed == cashoutAmount ? _self.cashoutAmount : cashoutAmount // ignore: cast_nullable_to_non_nullable
as num?,odds: freezed == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as num?,originalStake: freezed == originalStake ? _self.originalStake : originalStake // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on
