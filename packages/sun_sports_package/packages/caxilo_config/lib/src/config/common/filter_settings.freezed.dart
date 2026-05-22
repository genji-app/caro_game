// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaxiloFilter {

@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson) CaxiloFilterStrategy get strategy; Map<String, dynamic>? get params;
/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloFilterCopyWith<CaxiloFilter> get copyWith => _$CaxiloFilterCopyWithImpl<CaxiloFilter>(this as CaxiloFilter, _$identity);

  /// Serializes this CaxiloFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloFilter&&(identical(other.strategy, strategy) || other.strategy == strategy)&&const DeepCollectionEquality().equals(other.params, params));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,strategy,const DeepCollectionEquality().hash(params));

@override
String toString() {
  return 'CaxiloFilter(strategy: $strategy, params: $params)';
}


}

/// @nodoc
abstract mixin class $CaxiloFilterCopyWith<$Res>  {
  factory $CaxiloFilterCopyWith(CaxiloFilter value, $Res Function(CaxiloFilter) _then) = _$CaxiloFilterCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson) CaxiloFilterStrategy strategy, Map<String, dynamic>? params
});




}
/// @nodoc
class _$CaxiloFilterCopyWithImpl<$Res>
    implements $CaxiloFilterCopyWith<$Res> {
  _$CaxiloFilterCopyWithImpl(this._self, this._then);

  final CaxiloFilter _self;
  final $Res Function(CaxiloFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? strategy = null,Object? params = freezed,}) {
  return _then(_self.copyWith(
strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as CaxiloFilterStrategy,params: freezed == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CaxiloFilter].
extension CaxiloFilterPatterns on CaxiloFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaxiloFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaxiloFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaxiloFilter value)  $default,){
final _that = this;
switch (_that) {
case _CaxiloFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaxiloFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CaxiloFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson)  CaxiloFilterStrategy strategy,  Map<String, dynamic>? params)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaxiloFilter() when $default != null:
return $default(_that.strategy,_that.params);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson)  CaxiloFilterStrategy strategy,  Map<String, dynamic>? params)  $default,) {final _that = this;
switch (_that) {
case _CaxiloFilter():
return $default(_that.strategy,_that.params);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson)  CaxiloFilterStrategy strategy,  Map<String, dynamic>? params)?  $default,) {final _that = this;
switch (_that) {
case _CaxiloFilter() when $default != null:
return $default(_that.strategy,_that.params);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaxiloFilter implements CaxiloFilter {
  const _CaxiloFilter({@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson) required this.strategy, final  Map<String, dynamic>? params}): _params = params;
  factory _CaxiloFilter.fromJson(Map<String, dynamic> json) => _$CaxiloFilterFromJson(json);

@override@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson) final  CaxiloFilterStrategy strategy;
 final  Map<String, dynamic>? _params;
@override Map<String, dynamic>? get params {
  final value = _params;
  if (value == null) return null;
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaxiloFilterCopyWith<_CaxiloFilter> get copyWith => __$CaxiloFilterCopyWithImpl<_CaxiloFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaxiloFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaxiloFilter&&(identical(other.strategy, strategy) || other.strategy == strategy)&&const DeepCollectionEquality().equals(other._params, _params));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,strategy,const DeepCollectionEquality().hash(_params));

@override
String toString() {
  return 'CaxiloFilter(strategy: $strategy, params: $params)';
}


}

/// @nodoc
abstract mixin class _$CaxiloFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory _$CaxiloFilterCopyWith(_CaxiloFilter value, $Res Function(_CaxiloFilter) _then) = __$CaxiloFilterCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson) CaxiloFilterStrategy strategy, Map<String, dynamic>? params
});




}
/// @nodoc
class __$CaxiloFilterCopyWithImpl<$Res>
    implements _$CaxiloFilterCopyWith<$Res> {
  __$CaxiloFilterCopyWithImpl(this._self, this._then);

  final _CaxiloFilter _self;
  final $Res Function(_CaxiloFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? strategy = null,Object? params = freezed,}) {
  return _then(_CaxiloFilter(
strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as CaxiloFilterStrategy,params: freezed == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
