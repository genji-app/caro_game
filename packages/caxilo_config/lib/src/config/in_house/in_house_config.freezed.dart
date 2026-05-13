// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_house_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InHouseConfig {

/// List of technical game catalog entries.
 List<InHouseGame> get catalog;/// Map of game codes to their respective visibility and status.
 Map<String, InHouseGameVisibility> get visibility;
/// Create a copy of InHouseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InHouseConfigCopyWith<InHouseConfig> get copyWith => _$InHouseConfigCopyWithImpl<InHouseConfig>(this as InHouseConfig, _$identity);

  /// Serializes this InHouseConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InHouseConfig&&const DeepCollectionEquality().equals(other.catalog, catalog)&&const DeepCollectionEquality().equals(other.visibility, visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(catalog),const DeepCollectionEquality().hash(visibility));

@override
String toString() {
  return 'InHouseConfig(catalog: $catalog, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $InHouseConfigCopyWith<$Res>  {
  factory $InHouseConfigCopyWith(InHouseConfig value, $Res Function(InHouseConfig) _then) = _$InHouseConfigCopyWithImpl;
@useResult
$Res call({
 List<InHouseGame> catalog, Map<String, InHouseGameVisibility> visibility
});




}
/// @nodoc
class _$InHouseConfigCopyWithImpl<$Res>
    implements $InHouseConfigCopyWith<$Res> {
  _$InHouseConfigCopyWithImpl(this._self, this._then);

  final InHouseConfig _self;
  final $Res Function(InHouseConfig) _then;

/// Create a copy of InHouseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? catalog = null,Object? visibility = null,}) {
  return _then(_self.copyWith(
catalog: null == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as List<InHouseGame>,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Map<String, InHouseGameVisibility>,
  ));
}

}


/// Adds pattern-matching-related methods to [InHouseConfig].
extension InHouseConfigPatterns on InHouseConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InHouseConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InHouseConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InHouseConfig value)  $default,){
final _that = this;
switch (_that) {
case _InHouseConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InHouseConfig value)?  $default,){
final _that = this;
switch (_that) {
case _InHouseConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InHouseGame> catalog,  Map<String, InHouseGameVisibility> visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InHouseConfig() when $default != null:
return $default(_that.catalog,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InHouseGame> catalog,  Map<String, InHouseGameVisibility> visibility)  $default,) {final _that = this;
switch (_that) {
case _InHouseConfig():
return $default(_that.catalog,_that.visibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InHouseGame> catalog,  Map<String, InHouseGameVisibility> visibility)?  $default,) {final _that = this;
switch (_that) {
case _InHouseConfig() when $default != null:
return $default(_that.catalog,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InHouseConfig implements InHouseConfig {
  const _InHouseConfig({final  List<InHouseGame> catalog = const [], final  Map<String, InHouseGameVisibility> visibility = const {}}): _catalog = catalog,_visibility = visibility;
  factory _InHouseConfig.fromJson(Map<String, dynamic> json) => _$InHouseConfigFromJson(json);

/// List of technical game catalog entries.
 final  List<InHouseGame> _catalog;
/// List of technical game catalog entries.
@override@JsonKey() List<InHouseGame> get catalog {
  if (_catalog is EqualUnmodifiableListView) return _catalog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_catalog);
}

/// Map of game codes to their respective visibility and status.
 final  Map<String, InHouseGameVisibility> _visibility;
/// Map of game codes to their respective visibility and status.
@override@JsonKey() Map<String, InHouseGameVisibility> get visibility {
  if (_visibility is EqualUnmodifiableMapView) return _visibility;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_visibility);
}


/// Create a copy of InHouseConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InHouseConfigCopyWith<_InHouseConfig> get copyWith => __$InHouseConfigCopyWithImpl<_InHouseConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InHouseConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InHouseConfig&&const DeepCollectionEquality().equals(other._catalog, _catalog)&&const DeepCollectionEquality().equals(other._visibility, _visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_catalog),const DeepCollectionEquality().hash(_visibility));

@override
String toString() {
  return 'InHouseConfig(catalog: $catalog, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$InHouseConfigCopyWith<$Res> implements $InHouseConfigCopyWith<$Res> {
  factory _$InHouseConfigCopyWith(_InHouseConfig value, $Res Function(_InHouseConfig) _then) = __$InHouseConfigCopyWithImpl;
@override @useResult
$Res call({
 List<InHouseGame> catalog, Map<String, InHouseGameVisibility> visibility
});




}
/// @nodoc
class __$InHouseConfigCopyWithImpl<$Res>
    implements _$InHouseConfigCopyWith<$Res> {
  __$InHouseConfigCopyWithImpl(this._self, this._then);

  final _InHouseConfig _self;
  final $Res Function(_InHouseConfig) _then;

/// Create a copy of InHouseConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? catalog = null,Object? visibility = null,}) {
  return _then(_InHouseConfig(
catalog: null == catalog ? _self._catalog : catalog // ignore: cast_nullable_to_non_nullable
as List<InHouseGame>,visibility: null == visibility ? _self._visibility : visibility // ignore: cast_nullable_to_non_nullable
as Map<String, InHouseGameVisibility>,
  ));
}


}

// dart format on
