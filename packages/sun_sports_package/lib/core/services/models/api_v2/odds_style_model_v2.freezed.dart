// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'odds_style_model_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OddsStyleModelV2 {

/// Decimal odds format (e.g., "1.85")
 String get decimal;/// Malay odds format (e.g., "0.85")
 String get malay;/// Indonesian odds format (e.g., "-1.18")
 String get indo;/// Hong Kong odds format (e.g., "0.85")
 String get hk;
/// Create a copy of OddsStyleModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<OddsStyleModelV2> get copyWith => _$OddsStyleModelV2CopyWithImpl<OddsStyleModelV2>(this as OddsStyleModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OddsStyleModelV2&&(identical(other.decimal, decimal) || other.decimal == decimal)&&(identical(other.malay, malay) || other.malay == malay)&&(identical(other.indo, indo) || other.indo == indo)&&(identical(other.hk, hk) || other.hk == hk));
}


@override
int get hashCode => Object.hash(runtimeType,decimal,malay,indo,hk);

@override
String toString() {
  return 'OddsStyleModelV2(decimal: $decimal, malay: $malay, indo: $indo, hk: $hk)';
}


}

/// @nodoc
abstract mixin class $OddsStyleModelV2CopyWith<$Res>  {
  factory $OddsStyleModelV2CopyWith(OddsStyleModelV2 value, $Res Function(OddsStyleModelV2) _then) = _$OddsStyleModelV2CopyWithImpl;
@useResult
$Res call({
 String decimal, String malay, String indo, String hk
});




}
/// @nodoc
class _$OddsStyleModelV2CopyWithImpl<$Res>
    implements $OddsStyleModelV2CopyWith<$Res> {
  _$OddsStyleModelV2CopyWithImpl(this._self, this._then);

  final OddsStyleModelV2 _self;
  final $Res Function(OddsStyleModelV2) _then;

/// Create a copy of OddsStyleModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? decimal = null,Object? malay = null,Object? indo = null,Object? hk = null,}) {
  return _then(_self.copyWith(
decimal: null == decimal ? _self.decimal : decimal // ignore: cast_nullable_to_non_nullable
as String,malay: null == malay ? _self.malay : malay // ignore: cast_nullable_to_non_nullable
as String,indo: null == indo ? _self.indo : indo // ignore: cast_nullable_to_non_nullable
as String,hk: null == hk ? _self.hk : hk // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OddsStyleModelV2].
extension OddsStyleModelV2Patterns on OddsStyleModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OddsStyleModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OddsStyleModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OddsStyleModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _OddsStyleModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OddsStyleModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _OddsStyleModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String decimal,  String malay,  String indo,  String hk)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OddsStyleModelV2() when $default != null:
return $default(_that.decimal,_that.malay,_that.indo,_that.hk);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String decimal,  String malay,  String indo,  String hk)  $default,) {final _that = this;
switch (_that) {
case _OddsStyleModelV2():
return $default(_that.decimal,_that.malay,_that.indo,_that.hk);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String decimal,  String malay,  String indo,  String hk)?  $default,) {final _that = this;
switch (_that) {
case _OddsStyleModelV2() when $default != null:
return $default(_that.decimal,_that.malay,_that.indo,_that.hk);case _:
  return null;

}
}

}

/// @nodoc


class _OddsStyleModelV2 extends OddsStyleModelV2 {
  const _OddsStyleModelV2({this.decimal = '', this.malay = '', this.indo = '', this.hk = ''}): super._();
  

/// Decimal odds format (e.g., "1.85")
@override@JsonKey() final  String decimal;
/// Malay odds format (e.g., "0.85")
@override@JsonKey() final  String malay;
/// Indonesian odds format (e.g., "-1.18")
@override@JsonKey() final  String indo;
/// Hong Kong odds format (e.g., "0.85")
@override@JsonKey() final  String hk;

/// Create a copy of OddsStyleModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OddsStyleModelV2CopyWith<_OddsStyleModelV2> get copyWith => __$OddsStyleModelV2CopyWithImpl<_OddsStyleModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OddsStyleModelV2&&(identical(other.decimal, decimal) || other.decimal == decimal)&&(identical(other.malay, malay) || other.malay == malay)&&(identical(other.indo, indo) || other.indo == indo)&&(identical(other.hk, hk) || other.hk == hk));
}


@override
int get hashCode => Object.hash(runtimeType,decimal,malay,indo,hk);

@override
String toString() {
  return 'OddsStyleModelV2(decimal: $decimal, malay: $malay, indo: $indo, hk: $hk)';
}


}

/// @nodoc
abstract mixin class _$OddsStyleModelV2CopyWith<$Res> implements $OddsStyleModelV2CopyWith<$Res> {
  factory _$OddsStyleModelV2CopyWith(_OddsStyleModelV2 value, $Res Function(_OddsStyleModelV2) _then) = __$OddsStyleModelV2CopyWithImpl;
@override @useResult
$Res call({
 String decimal, String malay, String indo, String hk
});




}
/// @nodoc
class __$OddsStyleModelV2CopyWithImpl<$Res>
    implements _$OddsStyleModelV2CopyWith<$Res> {
  __$OddsStyleModelV2CopyWithImpl(this._self, this._then);

  final _OddsStyleModelV2 _self;
  final $Res Function(_OddsStyleModelV2) _then;

/// Create a copy of OddsStyleModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? decimal = null,Object? malay = null,Object? indo = null,Object? hk = null,}) {
  return _then(_OddsStyleModelV2(
decimal: null == decimal ? _self.decimal : decimal // ignore: cast_nullable_to_non_nullable
as String,malay: null == malay ? _self.malay : malay // ignore: cast_nullable_to_non_nullable
as String,indo: null == indo ? _self.indo : indo // ignore: cast_nullable_to_non_nullable
as String,hk: null == hk ? _self.hk : hk // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
