// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryConfig {

 String get id;@JsonKey(name: 'translation_key') String get translationKey; String get icon;@JsonKey(name: 'icon_active') String get iconActive; CaxiloFilter get filter;/// Optional sidebar group key. Supported values: 'priority', 'standard'.
/// When absent, the repository falls back to type-based classification.
@JsonKey(name: 'group_key') String? get groupKey;
/// Create a copy of CategoryConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryConfigCopyWith<CategoryConfig> get copyWith => _$CategoryConfigCopyWithImpl<CategoryConfig>(this as CategoryConfig, _$identity);

  /// Serializes this CategoryConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.translationKey, translationKey) || other.translationKey == translationKey)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.groupKey, groupKey) || other.groupKey == groupKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,translationKey,icon,iconActive,filter,groupKey);

@override
String toString() {
  return 'CategoryConfig(id: $id, translationKey: $translationKey, icon: $icon, iconActive: $iconActive, filter: $filter, groupKey: $groupKey)';
}


}

/// @nodoc
abstract mixin class $CategoryConfigCopyWith<$Res>  {
  factory $CategoryConfigCopyWith(CategoryConfig value, $Res Function(CategoryConfig) _then) = _$CategoryConfigCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'translation_key') String translationKey, String icon,@JsonKey(name: 'icon_active') String iconActive, CaxiloFilter filter,@JsonKey(name: 'group_key') String? groupKey
});


$CaxiloFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$CategoryConfigCopyWithImpl<$Res>
    implements $CategoryConfigCopyWith<$Res> {
  _$CategoryConfigCopyWithImpl(this._self, this._then);

  final CategoryConfig _self;
  final $Res Function(CategoryConfig) _then;

/// Create a copy of CategoryConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? translationKey = null,Object? icon = null,Object? iconActive = null,Object? filter = null,Object? groupKey = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,translationKey: null == translationKey ? _self.translationKey : translationKey // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,iconActive: null == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CaxiloFilter,groupKey: freezed == groupKey ? _self.groupKey : groupKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CategoryConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaxiloFilterCopyWith<$Res> get filter {
  
  return $CaxiloFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryConfig].
extension CategoryConfigPatterns on CategoryConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryConfig value)  $default,){
final _that = this;
switch (_that) {
case _CategoryConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'translation_key')  String translationKey,  String icon, @JsonKey(name: 'icon_active')  String iconActive,  CaxiloFilter filter, @JsonKey(name: 'group_key')  String? groupKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryConfig() when $default != null:
return $default(_that.id,_that.translationKey,_that.icon,_that.iconActive,_that.filter,_that.groupKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'translation_key')  String translationKey,  String icon, @JsonKey(name: 'icon_active')  String iconActive,  CaxiloFilter filter, @JsonKey(name: 'group_key')  String? groupKey)  $default,) {final _that = this;
switch (_that) {
case _CategoryConfig():
return $default(_that.id,_that.translationKey,_that.icon,_that.iconActive,_that.filter,_that.groupKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'translation_key')  String translationKey,  String icon, @JsonKey(name: 'icon_active')  String iconActive,  CaxiloFilter filter, @JsonKey(name: 'group_key')  String? groupKey)?  $default,) {final _that = this;
switch (_that) {
case _CategoryConfig() when $default != null:
return $default(_that.id,_that.translationKey,_that.icon,_that.iconActive,_that.filter,_that.groupKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryConfig implements CategoryConfig {
  const _CategoryConfig({required this.id, @JsonKey(name: 'translation_key') required this.translationKey, required this.icon, @JsonKey(name: 'icon_active') required this.iconActive, required this.filter, @JsonKey(name: 'group_key') this.groupKey});
  factory _CategoryConfig.fromJson(Map<String, dynamic> json) => _$CategoryConfigFromJson(json);

@override final  String id;
@override@JsonKey(name: 'translation_key') final  String translationKey;
@override final  String icon;
@override@JsonKey(name: 'icon_active') final  String iconActive;
@override final  CaxiloFilter filter;
/// Optional sidebar group key. Supported values: 'priority', 'standard'.
/// When absent, the repository falls back to type-based classification.
@override@JsonKey(name: 'group_key') final  String? groupKey;

/// Create a copy of CategoryConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryConfigCopyWith<_CategoryConfig> get copyWith => __$CategoryConfigCopyWithImpl<_CategoryConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.translationKey, translationKey) || other.translationKey == translationKey)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.groupKey, groupKey) || other.groupKey == groupKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,translationKey,icon,iconActive,filter,groupKey);

@override
String toString() {
  return 'CategoryConfig(id: $id, translationKey: $translationKey, icon: $icon, iconActive: $iconActive, filter: $filter, groupKey: $groupKey)';
}


}

/// @nodoc
abstract mixin class _$CategoryConfigCopyWith<$Res> implements $CategoryConfigCopyWith<$Res> {
  factory _$CategoryConfigCopyWith(_CategoryConfig value, $Res Function(_CategoryConfig) _then) = __$CategoryConfigCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'translation_key') String translationKey, String icon,@JsonKey(name: 'icon_active') String iconActive, CaxiloFilter filter,@JsonKey(name: 'group_key') String? groupKey
});


@override $CaxiloFilterCopyWith<$Res> get filter;

}
/// @nodoc
class __$CategoryConfigCopyWithImpl<$Res>
    implements _$CategoryConfigCopyWith<$Res> {
  __$CategoryConfigCopyWithImpl(this._self, this._then);

  final _CategoryConfig _self;
  final $Res Function(_CategoryConfig) _then;

/// Create a copy of CategoryConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? translationKey = null,Object? icon = null,Object? iconActive = null,Object? filter = null,Object? groupKey = freezed,}) {
  return _then(_CategoryConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,translationKey: null == translationKey ? _self.translationKey : translationKey // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,iconActive: null == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CaxiloFilter,groupKey: freezed == groupKey ? _self.groupKey : groupKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CategoryConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaxiloFilterCopyWith<$Res> get filter {
  
  return $CaxiloFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on
