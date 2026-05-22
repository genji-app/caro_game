// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggested_trans_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SuggestedTransCode {

 String get text; int get type;
/// Create a copy of SuggestedTransCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedTransCodeCopyWith<SuggestedTransCode> get copyWith => _$SuggestedTransCodeCopyWithImpl<SuggestedTransCode>(this as SuggestedTransCode, _$identity);

  /// Serializes this SuggestedTransCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedTransCode&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type);

@override
String toString() {
  return 'SuggestedTransCode(text: $text, type: $type)';
}


}

/// @nodoc
abstract mixin class $SuggestedTransCodeCopyWith<$Res>  {
  factory $SuggestedTransCodeCopyWith(SuggestedTransCode value, $Res Function(SuggestedTransCode) _then) = _$SuggestedTransCodeCopyWithImpl;
@useResult
$Res call({
 String text, int type
});




}
/// @nodoc
class _$SuggestedTransCodeCopyWithImpl<$Res>
    implements $SuggestedTransCodeCopyWith<$Res> {
  _$SuggestedTransCodeCopyWithImpl(this._self, this._then);

  final SuggestedTransCode _self;
  final $Res Function(SuggestedTransCode) _then;

/// Create a copy of SuggestedTransCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? type = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestedTransCode].
extension SuggestedTransCodePatterns on SuggestedTransCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedTransCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedTransCode value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedTransCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedTransCode value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that.text,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int type)  $default,) {final _that = this;
switch (_that) {
case _SuggestedTransCode():
return $default(_that.text,_that.type);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int type)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedTransCode() when $default != null:
return $default(_that.text,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SuggestedTransCode implements SuggestedTransCode {
  const _SuggestedTransCode({required this.text, required this.type});
  factory _SuggestedTransCode.fromJson(Map<String, dynamic> json) => _$SuggestedTransCodeFromJson(json);

@override final  String text;
@override final  int type;

/// Create a copy of SuggestedTransCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedTransCodeCopyWith<_SuggestedTransCode> get copyWith => __$SuggestedTransCodeCopyWithImpl<_SuggestedTransCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestedTransCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedTransCode&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type);

@override
String toString() {
  return 'SuggestedTransCode(text: $text, type: $type)';
}


}

/// @nodoc
abstract mixin class _$SuggestedTransCodeCopyWith<$Res> implements $SuggestedTransCodeCopyWith<$Res> {
  factory _$SuggestedTransCodeCopyWith(_SuggestedTransCode value, $Res Function(_SuggestedTransCode) _then) = __$SuggestedTransCodeCopyWithImpl;
@override @useResult
$Res call({
 String text, int type
});




}
/// @nodoc
class __$SuggestedTransCodeCopyWithImpl<$Res>
    implements _$SuggestedTransCodeCopyWith<$Res> {
  __$SuggestedTransCodeCopyWithImpl(this._self, this._then);

  final _SuggestedTransCode _self;
  final $Res Function(_SuggestedTransCode) _then;

/// Create a copy of SuggestedTransCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? type = null,}) {
  return _then(_SuggestedTransCode(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
