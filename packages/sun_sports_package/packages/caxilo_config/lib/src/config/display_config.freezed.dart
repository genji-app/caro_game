// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayConfig {

/// List of game codes in the desired display order.
 List<String> get order;/// Arbitrary collections of games defined by the server (e.g., "popular", "hot").
/// Map key is the collection ID, value is the list of game codes.
 Map<String, List<String>> get collections;
/// Create a copy of DisplayConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayConfigCopyWith<DisplayConfig> get copyWith => _$DisplayConfigCopyWithImpl<DisplayConfig>(this as DisplayConfig, _$identity);

  /// Serializes this DisplayConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayConfig&&const DeepCollectionEquality().equals(other.order, order)&&const DeepCollectionEquality().equals(other.collections, collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(order),const DeepCollectionEquality().hash(collections));

@override
String toString() {
  return 'DisplayConfig(order: $order, collections: $collections)';
}


}

/// @nodoc
abstract mixin class $DisplayConfigCopyWith<$Res>  {
  factory $DisplayConfigCopyWith(DisplayConfig value, $Res Function(DisplayConfig) _then) = _$DisplayConfigCopyWithImpl;
@useResult
$Res call({
 List<String> order, Map<String, List<String>> collections
});




}
/// @nodoc
class _$DisplayConfigCopyWithImpl<$Res>
    implements $DisplayConfigCopyWith<$Res> {
  _$DisplayConfigCopyWithImpl(this._self, this._then);

  final DisplayConfig _self;
  final $Res Function(DisplayConfig) _then;

/// Create a copy of DisplayConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? collections = null,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as List<String>,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayConfig].
extension DisplayConfigPatterns on DisplayConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayConfig value)  $default,){
final _that = this;
switch (_that) {
case _DisplayConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> order,  Map<String, List<String>> collections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayConfig() when $default != null:
return $default(_that.order,_that.collections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> order,  Map<String, List<String>> collections)  $default,) {final _that = this;
switch (_that) {
case _DisplayConfig():
return $default(_that.order,_that.collections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> order,  Map<String, List<String>> collections)?  $default,) {final _that = this;
switch (_that) {
case _DisplayConfig() when $default != null:
return $default(_that.order,_that.collections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisplayConfig implements DisplayConfig {
  const _DisplayConfig({final  List<String> order = const [], final  Map<String, List<String>> collections = const {}}): _order = order,_collections = collections;
  factory _DisplayConfig.fromJson(Map<String, dynamic> json) => _$DisplayConfigFromJson(json);

/// List of game codes in the desired display order.
 final  List<String> _order;
/// List of game codes in the desired display order.
@override@JsonKey() List<String> get order {
  if (_order is EqualUnmodifiableListView) return _order;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_order);
}

/// Arbitrary collections of games defined by the server (e.g., "popular", "hot").
/// Map key is the collection ID, value is the list of game codes.
 final  Map<String, List<String>> _collections;
/// Arbitrary collections of games defined by the server (e.g., "popular", "hot").
/// Map key is the collection ID, value is the list of game codes.
@override@JsonKey() Map<String, List<String>> get collections {
  if (_collections is EqualUnmodifiableMapView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_collections);
}


/// Create a copy of DisplayConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayConfigCopyWith<_DisplayConfig> get copyWith => __$DisplayConfigCopyWithImpl<_DisplayConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayConfig&&const DeepCollectionEquality().equals(other._order, _order)&&const DeepCollectionEquality().equals(other._collections, _collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_order),const DeepCollectionEquality().hash(_collections));

@override
String toString() {
  return 'DisplayConfig(order: $order, collections: $collections)';
}


}

/// @nodoc
abstract mixin class _$DisplayConfigCopyWith<$Res> implements $DisplayConfigCopyWith<$Res> {
  factory _$DisplayConfigCopyWith(_DisplayConfig value, $Res Function(_DisplayConfig) _then) = __$DisplayConfigCopyWithImpl;
@override @useResult
$Res call({
 List<String> order, Map<String, List<String>> collections
});




}
/// @nodoc
class __$DisplayConfigCopyWithImpl<$Res>
    implements _$DisplayConfigCopyWith<$Res> {
  __$DisplayConfigCopyWithImpl(this._self, this._then);

  final _DisplayConfig _self;
  final $Res Function(_DisplayConfig) _then;

/// Create a copy of DisplayConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? collections = null,}) {
  return _then(_DisplayConfig(
order: null == order ? _self._order : order // ignore: cast_nullable_to_non_nullable
as List<String>,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

// dart format on
