// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_cashout_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GetCashoutResponse {

/// Ticket ID - ID của vé cược
@JsonKey(name: '0') String get ticketId;/// Cash out availability - Trạng thái có thể cash out hay không
@JsonKey(name: '1') bool get isCashoutAvailable;/// Current cashout amount - Số tiền cash out hiện tại có thể nhận được
@JsonKey(name: '3') num? get cashoutAmount;/// Current odds - Tỷ lệ cược hiện tại
@JsonKey(name: '4') num? get odds;/// Fee or adjustment value - Phí hoặc giá trị điều chỉnh (thường là 0)
@JsonKey(name: '5') num? get feeOrAdjustment;/// Original stake amount - Số tiền cược ban đầu
@JsonKey(name: '6') num? get originalStake;
/// Create a copy of GetCashoutResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetCashoutResponseCopyWith<GetCashoutResponse> get copyWith => _$GetCashoutResponseCopyWithImpl<GetCashoutResponse>(this as GetCashoutResponse, _$identity);

  /// Serializes this GetCashoutResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetCashoutResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.isCashoutAvailable, isCashoutAvailable) || other.isCashoutAvailable == isCashoutAvailable)&&(identical(other.cashoutAmount, cashoutAmount) || other.cashoutAmount == cashoutAmount)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.feeOrAdjustment, feeOrAdjustment) || other.feeOrAdjustment == feeOrAdjustment)&&(identical(other.originalStake, originalStake) || other.originalStake == originalStake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,isCashoutAvailable,cashoutAmount,odds,feeOrAdjustment,originalStake);

@override
String toString() {
  return 'GetCashoutResponse(ticketId: $ticketId, isCashoutAvailable: $isCashoutAvailable, cashoutAmount: $cashoutAmount, odds: $odds, feeOrAdjustment: $feeOrAdjustment, originalStake: $originalStake)';
}


}

/// @nodoc
abstract mixin class $GetCashoutResponseCopyWith<$Res>  {
  factory $GetCashoutResponseCopyWith(GetCashoutResponse value, $Res Function(GetCashoutResponse) _then) = _$GetCashoutResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') String ticketId,@JsonKey(name: '1') bool isCashoutAvailable,@JsonKey(name: '3') num? cashoutAmount,@JsonKey(name: '4') num? odds,@JsonKey(name: '5') num? feeOrAdjustment,@JsonKey(name: '6') num? originalStake
});




}
/// @nodoc
class _$GetCashoutResponseCopyWithImpl<$Res>
    implements $GetCashoutResponseCopyWith<$Res> {
  _$GetCashoutResponseCopyWithImpl(this._self, this._then);

  final GetCashoutResponse _self;
  final $Res Function(GetCashoutResponse) _then;

/// Create a copy of GetCashoutResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = null,Object? isCashoutAvailable = null,Object? cashoutAmount = freezed,Object? odds = freezed,Object? feeOrAdjustment = freezed,Object? originalStake = freezed,}) {
  return _then(_self.copyWith(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,isCashoutAvailable: null == isCashoutAvailable ? _self.isCashoutAvailable : isCashoutAvailable // ignore: cast_nullable_to_non_nullable
as bool,cashoutAmount: freezed == cashoutAmount ? _self.cashoutAmount : cashoutAmount // ignore: cast_nullable_to_non_nullable
as num?,odds: freezed == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as num?,feeOrAdjustment: freezed == feeOrAdjustment ? _self.feeOrAdjustment : feeOrAdjustment // ignore: cast_nullable_to_non_nullable
as num?,originalStake: freezed == originalStake ? _self.originalStake : originalStake // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [GetCashoutResponse].
extension GetCashoutResponsePatterns on GetCashoutResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetCashoutResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetCashoutResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetCashoutResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetCashoutResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetCashoutResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetCashoutResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String ticketId, @JsonKey(name: '1')  bool isCashoutAvailable, @JsonKey(name: '3')  num? cashoutAmount, @JsonKey(name: '4')  num? odds, @JsonKey(name: '5')  num? feeOrAdjustment, @JsonKey(name: '6')  num? originalStake)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetCashoutResponse() when $default != null:
return $default(_that.ticketId,_that.isCashoutAvailable,_that.cashoutAmount,_that.odds,_that.feeOrAdjustment,_that.originalStake);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String ticketId, @JsonKey(name: '1')  bool isCashoutAvailable, @JsonKey(name: '3')  num? cashoutAmount, @JsonKey(name: '4')  num? odds, @JsonKey(name: '5')  num? feeOrAdjustment, @JsonKey(name: '6')  num? originalStake)  $default,) {final _that = this;
switch (_that) {
case _GetCashoutResponse():
return $default(_that.ticketId,_that.isCashoutAvailable,_that.cashoutAmount,_that.odds,_that.feeOrAdjustment,_that.originalStake);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  String ticketId, @JsonKey(name: '1')  bool isCashoutAvailable, @JsonKey(name: '3')  num? cashoutAmount, @JsonKey(name: '4')  num? odds, @JsonKey(name: '5')  num? feeOrAdjustment, @JsonKey(name: '6')  num? originalStake)?  $default,) {final _that = this;
switch (_that) {
case _GetCashoutResponse() when $default != null:
return $default(_that.ticketId,_that.isCashoutAvailable,_that.cashoutAmount,_that.odds,_that.feeOrAdjustment,_that.originalStake);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GetCashoutResponse implements GetCashoutResponse {
  const _GetCashoutResponse({@JsonKey(name: '0') required this.ticketId, @JsonKey(name: '1') required this.isCashoutAvailable, @JsonKey(name: '3') this.cashoutAmount, @JsonKey(name: '4') this.odds, @JsonKey(name: '5') this.feeOrAdjustment, @JsonKey(name: '6') this.originalStake});
  factory _GetCashoutResponse.fromJson(Map<String, dynamic> json) => _$GetCashoutResponseFromJson(json);

/// Ticket ID - ID của vé cược
@override@JsonKey(name: '0') final  String ticketId;
/// Cash out availability - Trạng thái có thể cash out hay không
@override@JsonKey(name: '1') final  bool isCashoutAvailable;
/// Current cashout amount - Số tiền cash out hiện tại có thể nhận được
@override@JsonKey(name: '3') final  num? cashoutAmount;
/// Current odds - Tỷ lệ cược hiện tại
@override@JsonKey(name: '4') final  num? odds;
/// Fee or adjustment value - Phí hoặc giá trị điều chỉnh (thường là 0)
@override@JsonKey(name: '5') final  num? feeOrAdjustment;
/// Original stake amount - Số tiền cược ban đầu
@override@JsonKey(name: '6') final  num? originalStake;

/// Create a copy of GetCashoutResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetCashoutResponseCopyWith<_GetCashoutResponse> get copyWith => __$GetCashoutResponseCopyWithImpl<_GetCashoutResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GetCashoutResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetCashoutResponse&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.isCashoutAvailable, isCashoutAvailable) || other.isCashoutAvailable == isCashoutAvailable)&&(identical(other.cashoutAmount, cashoutAmount) || other.cashoutAmount == cashoutAmount)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.feeOrAdjustment, feeOrAdjustment) || other.feeOrAdjustment == feeOrAdjustment)&&(identical(other.originalStake, originalStake) || other.originalStake == originalStake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,isCashoutAvailable,cashoutAmount,odds,feeOrAdjustment,originalStake);

@override
String toString() {
  return 'GetCashoutResponse(ticketId: $ticketId, isCashoutAvailable: $isCashoutAvailable, cashoutAmount: $cashoutAmount, odds: $odds, feeOrAdjustment: $feeOrAdjustment, originalStake: $originalStake)';
}


}

/// @nodoc
abstract mixin class _$GetCashoutResponseCopyWith<$Res> implements $GetCashoutResponseCopyWith<$Res> {
  factory _$GetCashoutResponseCopyWith(_GetCashoutResponse value, $Res Function(_GetCashoutResponse) _then) = __$GetCashoutResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') String ticketId,@JsonKey(name: '1') bool isCashoutAvailable,@JsonKey(name: '3') num? cashoutAmount,@JsonKey(name: '4') num? odds,@JsonKey(name: '5') num? feeOrAdjustment,@JsonKey(name: '6') num? originalStake
});




}
/// @nodoc
class __$GetCashoutResponseCopyWithImpl<$Res>
    implements _$GetCashoutResponseCopyWith<$Res> {
  __$GetCashoutResponseCopyWithImpl(this._self, this._then);

  final _GetCashoutResponse _self;
  final $Res Function(_GetCashoutResponse) _then;

/// Create a copy of GetCashoutResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = null,Object? isCashoutAvailable = null,Object? cashoutAmount = freezed,Object? odds = freezed,Object? feeOrAdjustment = freezed,Object? originalStake = freezed,}) {
  return _then(_GetCashoutResponse(
ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,isCashoutAvailable: null == isCashoutAvailable ? _self.isCashoutAvailable : isCashoutAvailable // ignore: cast_nullable_to_non_nullable
as bool,cashoutAmount: freezed == cashoutAmount ? _self.cashoutAmount : cashoutAmount // ignore: cast_nullable_to_non_nullable
as num?,odds: freezed == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as num?,feeOrAdjustment: freezed == feeOrAdjustment ? _self.feeOrAdjustment : feeOrAdjustment // ignore: cast_nullable_to_non_nullable
as num?,originalStake: freezed == originalStake ? _self.originalStake : originalStake // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on
