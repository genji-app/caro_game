// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_house_game_visibility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InHouseGameVisibility {

/// Whether the game is visible in the lobby.
@JsonKey(name: 'is_visible') bool get isVisible;/// Detailed operational status affecting UI rendering and clickability.
@JsonKey(name: 'status') GameStatus get status;
/// Create a copy of InHouseGameVisibility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InHouseGameVisibilityCopyWith<InHouseGameVisibility> get copyWith => _$InHouseGameVisibilityCopyWithImpl<InHouseGameVisibility>(this as InHouseGameVisibility, _$identity);

  /// Serializes this InHouseGameVisibility to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InHouseGameVisibility&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isVisible,status);

@override
String toString() {
  return 'InHouseGameVisibility(isVisible: $isVisible, status: $status)';
}


}

/// @nodoc
abstract mixin class $InHouseGameVisibilityCopyWith<$Res>  {
  factory $InHouseGameVisibilityCopyWith(InHouseGameVisibility value, $Res Function(InHouseGameVisibility) _then) = _$InHouseGameVisibilityCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'is_visible') bool isVisible,@JsonKey(name: 'status') GameStatus status
});




}
/// @nodoc
class _$InHouseGameVisibilityCopyWithImpl<$Res>
    implements $InHouseGameVisibilityCopyWith<$Res> {
  _$InHouseGameVisibilityCopyWithImpl(this._self, this._then);

  final InHouseGameVisibility _self;
  final $Res Function(InHouseGameVisibility) _then;

/// Create a copy of InHouseGameVisibility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isVisible = null,Object? status = null,}) {
  return _then(_self.copyWith(
isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [InHouseGameVisibility].
extension InHouseGameVisibilityPatterns on InHouseGameVisibility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InHouseGameVisibility value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InHouseGameVisibility() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InHouseGameVisibility value)  $default,){
final _that = this;
switch (_that) {
case _InHouseGameVisibility():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InHouseGameVisibility value)?  $default,){
final _that = this;
switch (_that) {
case _InHouseGameVisibility() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_visible')  bool isVisible, @JsonKey(name: 'status')  GameStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InHouseGameVisibility() when $default != null:
return $default(_that.isVisible,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_visible')  bool isVisible, @JsonKey(name: 'status')  GameStatus status)  $default,) {final _that = this;
switch (_that) {
case _InHouseGameVisibility():
return $default(_that.isVisible,_that.status);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'is_visible')  bool isVisible, @JsonKey(name: 'status')  GameStatus status)?  $default,) {final _that = this;
switch (_that) {
case _InHouseGameVisibility() when $default != null:
return $default(_that.isVisible,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InHouseGameVisibility implements InHouseGameVisibility {
  const _InHouseGameVisibility({@JsonKey(name: 'is_visible') this.isVisible = false, @JsonKey(name: 'status') this.status = GameStatus.underDevelopment});
  factory _InHouseGameVisibility.fromJson(Map<String, dynamic> json) => _$InHouseGameVisibilityFromJson(json);

/// Whether the game is visible in the lobby.
@override@JsonKey(name: 'is_visible') final  bool isVisible;
/// Detailed operational status affecting UI rendering and clickability.
@override@JsonKey(name: 'status') final  GameStatus status;

/// Create a copy of InHouseGameVisibility
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InHouseGameVisibilityCopyWith<_InHouseGameVisibility> get copyWith => __$InHouseGameVisibilityCopyWithImpl<_InHouseGameVisibility>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InHouseGameVisibilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InHouseGameVisibility&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isVisible,status);

@override
String toString() {
  return 'InHouseGameVisibility(isVisible: $isVisible, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InHouseGameVisibilityCopyWith<$Res> implements $InHouseGameVisibilityCopyWith<$Res> {
  factory _$InHouseGameVisibilityCopyWith(_InHouseGameVisibility value, $Res Function(_InHouseGameVisibility) _then) = __$InHouseGameVisibilityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'is_visible') bool isVisible,@JsonKey(name: 'status') GameStatus status
});




}
/// @nodoc
class __$InHouseGameVisibilityCopyWithImpl<$Res>
    implements _$InHouseGameVisibilityCopyWith<$Res> {
  __$InHouseGameVisibilityCopyWithImpl(this._self, this._then);

  final _InHouseGameVisibility _self;
  final $Res Function(_InHouseGameVisibility) _then;

/// Create a copy of InHouseGameVisibility
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isVisible = null,Object? status = null,}) {
  return _then(_InHouseGameVisibility(
isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,
  ));
}


}

// dart format on
