// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DepositResponseModel {

@JsonKey(name: 'transaction_id') String get transactionId;@JsonKey(name: 'qr_code_url') String? get qrCodeUrl;@JsonKey(name: 'deposit_address') String? get depositAddress;@JsonKey(name: 'additional_data') Map<String, dynamic>? get additionalData;
/// Create a copy of DepositResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepositResponseModelCopyWith<DepositResponseModel> get copyWith => _$DepositResponseModelCopyWithImpl<DepositResponseModel>(this as DepositResponseModel, _$identity);

  /// Serializes this DepositResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepositResponseModel&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.qrCodeUrl, qrCodeUrl) || other.qrCodeUrl == qrCodeUrl)&&(identical(other.depositAddress, depositAddress) || other.depositAddress == depositAddress)&&const DeepCollectionEquality().equals(other.additionalData, additionalData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,qrCodeUrl,depositAddress,const DeepCollectionEquality().hash(additionalData));

@override
String toString() {
  return 'DepositResponseModel(transactionId: $transactionId, qrCodeUrl: $qrCodeUrl, depositAddress: $depositAddress, additionalData: $additionalData)';
}


}

/// @nodoc
abstract mixin class $DepositResponseModelCopyWith<$Res>  {
  factory $DepositResponseModelCopyWith(DepositResponseModel value, $Res Function(DepositResponseModel) _then) = _$DepositResponseModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'transaction_id') String transactionId,@JsonKey(name: 'qr_code_url') String? qrCodeUrl,@JsonKey(name: 'deposit_address') String? depositAddress,@JsonKey(name: 'additional_data') Map<String, dynamic>? additionalData
});




}
/// @nodoc
class _$DepositResponseModelCopyWithImpl<$Res>
    implements $DepositResponseModelCopyWith<$Res> {
  _$DepositResponseModelCopyWithImpl(this._self, this._then);

  final DepositResponseModel _self;
  final $Res Function(DepositResponseModel) _then;

/// Create a copy of DepositResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? qrCodeUrl = freezed,Object? depositAddress = freezed,Object? additionalData = freezed,}) {
  return _then(_self.copyWith(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,qrCodeUrl: freezed == qrCodeUrl ? _self.qrCodeUrl : qrCodeUrl // ignore: cast_nullable_to_non_nullable
as String?,depositAddress: freezed == depositAddress ? _self.depositAddress : depositAddress // ignore: cast_nullable_to_non_nullable
as String?,additionalData: freezed == additionalData ? _self.additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DepositResponseModel].
extension DepositResponseModelPatterns on DepositResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepositResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepositResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepositResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _DepositResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepositResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _DepositResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'qr_code_url')  String? qrCodeUrl, @JsonKey(name: 'deposit_address')  String? depositAddress, @JsonKey(name: 'additional_data')  Map<String, dynamic>? additionalData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepositResponseModel() when $default != null:
return $default(_that.transactionId,_that.qrCodeUrl,_that.depositAddress,_that.additionalData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'qr_code_url')  String? qrCodeUrl, @JsonKey(name: 'deposit_address')  String? depositAddress, @JsonKey(name: 'additional_data')  Map<String, dynamic>? additionalData)  $default,) {final _that = this;
switch (_that) {
case _DepositResponseModel():
return $default(_that.transactionId,_that.qrCodeUrl,_that.depositAddress,_that.additionalData);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'qr_code_url')  String? qrCodeUrl, @JsonKey(name: 'deposit_address')  String? depositAddress, @JsonKey(name: 'additional_data')  Map<String, dynamic>? additionalData)?  $default,) {final _that = this;
switch (_that) {
case _DepositResponseModel() when $default != null:
return $default(_that.transactionId,_that.qrCodeUrl,_that.depositAddress,_that.additionalData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DepositResponseModel implements DepositResponseModel {
  const _DepositResponseModel({@JsonKey(name: 'transaction_id') required this.transactionId, @JsonKey(name: 'qr_code_url') this.qrCodeUrl, @JsonKey(name: 'deposit_address') this.depositAddress, @JsonKey(name: 'additional_data') final  Map<String, dynamic>? additionalData}): _additionalData = additionalData;
  factory _DepositResponseModel.fromJson(Map<String, dynamic> json) => _$DepositResponseModelFromJson(json);

@override@JsonKey(name: 'transaction_id') final  String transactionId;
@override@JsonKey(name: 'qr_code_url') final  String? qrCodeUrl;
@override@JsonKey(name: 'deposit_address') final  String? depositAddress;
 final  Map<String, dynamic>? _additionalData;
@override@JsonKey(name: 'additional_data') Map<String, dynamic>? get additionalData {
  final value = _additionalData;
  if (value == null) return null;
  if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of DepositResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepositResponseModelCopyWith<_DepositResponseModel> get copyWith => __$DepositResponseModelCopyWithImpl<_DepositResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepositResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepositResponseModel&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.qrCodeUrl, qrCodeUrl) || other.qrCodeUrl == qrCodeUrl)&&(identical(other.depositAddress, depositAddress) || other.depositAddress == depositAddress)&&const DeepCollectionEquality().equals(other._additionalData, _additionalData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,qrCodeUrl,depositAddress,const DeepCollectionEquality().hash(_additionalData));

@override
String toString() {
  return 'DepositResponseModel(transactionId: $transactionId, qrCodeUrl: $qrCodeUrl, depositAddress: $depositAddress, additionalData: $additionalData)';
}


}

/// @nodoc
abstract mixin class _$DepositResponseModelCopyWith<$Res> implements $DepositResponseModelCopyWith<$Res> {
  factory _$DepositResponseModelCopyWith(_DepositResponseModel value, $Res Function(_DepositResponseModel) _then) = __$DepositResponseModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'transaction_id') String transactionId,@JsonKey(name: 'qr_code_url') String? qrCodeUrl,@JsonKey(name: 'deposit_address') String? depositAddress,@JsonKey(name: 'additional_data') Map<String, dynamic>? additionalData
});




}
/// @nodoc
class __$DepositResponseModelCopyWithImpl<$Res>
    implements _$DepositResponseModelCopyWith<$Res> {
  __$DepositResponseModelCopyWithImpl(this._self, this._then);

  final _DepositResponseModel _self;
  final $Res Function(_DepositResponseModel) _then;

/// Create a copy of DepositResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? qrCodeUrl = freezed,Object? depositAddress = freezed,Object? additionalData = freezed,}) {
  return _then(_DepositResponseModel(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,qrCodeUrl: freezed == qrCodeUrl ? _self.qrCodeUrl : qrCodeUrl // ignore: cast_nullable_to_non_nullable
as String?,depositAddress: freezed == depositAddress ? _self.depositAddress : depositAddress // ignore: cast_nullable_to_non_nullable
as String?,additionalData: freezed == additionalData ? _self._additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
