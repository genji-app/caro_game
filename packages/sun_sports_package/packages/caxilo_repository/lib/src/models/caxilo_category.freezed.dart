// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caxilo_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CaxiloCategory {

 String get categoryId; String get translationKey; CaxiloFilter get filter; String? get icon; String? get iconActive;
/// Create a copy of CaxiloCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloCategoryCopyWith<CaxiloCategory> get copyWith => _$CaxiloCategoryCopyWithImpl<CaxiloCategory>(this as CaxiloCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.translationKey, translationKey) || other.translationKey == translationKey)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,translationKey,filter,icon,iconActive);

@override
String toString() {
  return 'CaxiloCategory(categoryId: $categoryId, translationKey: $translationKey, filter: $filter, icon: $icon, iconActive: $iconActive)';
}


}

/// @nodoc
abstract mixin class $CaxiloCategoryCopyWith<$Res>  {
  factory $CaxiloCategoryCopyWith(CaxiloCategory value, $Res Function(CaxiloCategory) _then) = _$CaxiloCategoryCopyWithImpl;
@useResult
$Res call({
 String categoryId, String translationKey, CaxiloFilter filter, String? icon, String? iconActive
});


$CaxiloFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$CaxiloCategoryCopyWithImpl<$Res>
    implements $CaxiloCategoryCopyWith<$Res> {
  _$CaxiloCategoryCopyWithImpl(this._self, this._then);

  final CaxiloCategory _self;
  final $Res Function(CaxiloCategory) _then;

/// Create a copy of CaxiloCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? translationKey = null,Object? filter = null,Object? icon = freezed,Object? iconActive = freezed,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,translationKey: null == translationKey ? _self.translationKey : translationKey // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CaxiloFilter,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CaxiloCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaxiloFilterCopyWith<$Res> get filter {
  
  return $CaxiloFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaxiloCategory].
extension CaxiloCategoryPatterns on CaxiloCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaxiloCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaxiloCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaxiloCategory value)  $default,){
final _that = this;
switch (_that) {
case _CaxiloCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaxiloCategory value)?  $default,){
final _that = this;
switch (_that) {
case _CaxiloCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String translationKey,  CaxiloFilter filter,  String? icon,  String? iconActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaxiloCategory() when $default != null:
return $default(_that.categoryId,_that.translationKey,_that.filter,_that.icon,_that.iconActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String translationKey,  CaxiloFilter filter,  String? icon,  String? iconActive)  $default,) {final _that = this;
switch (_that) {
case _CaxiloCategory():
return $default(_that.categoryId,_that.translationKey,_that.filter,_that.icon,_that.iconActive);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String translationKey,  CaxiloFilter filter,  String? icon,  String? iconActive)?  $default,) {final _that = this;
switch (_that) {
case _CaxiloCategory() when $default != null:
return $default(_that.categoryId,_that.translationKey,_that.filter,_that.icon,_that.iconActive);case _:
  return null;

}
}

}

/// @nodoc


class _CaxiloCategory implements CaxiloCategory {
  const _CaxiloCategory({required this.categoryId, required this.translationKey, required this.filter, this.icon, this.iconActive});
  

@override final  String categoryId;
@override final  String translationKey;
@override final  CaxiloFilter filter;
@override final  String? icon;
@override final  String? iconActive;

/// Create a copy of CaxiloCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaxiloCategoryCopyWith<_CaxiloCategory> get copyWith => __$CaxiloCategoryCopyWithImpl<_CaxiloCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaxiloCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.translationKey, translationKey) || other.translationKey == translationKey)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,translationKey,filter,icon,iconActive);

@override
String toString() {
  return 'CaxiloCategory(categoryId: $categoryId, translationKey: $translationKey, filter: $filter, icon: $icon, iconActive: $iconActive)';
}


}

/// @nodoc
abstract mixin class _$CaxiloCategoryCopyWith<$Res> implements $CaxiloCategoryCopyWith<$Res> {
  factory _$CaxiloCategoryCopyWith(_CaxiloCategory value, $Res Function(_CaxiloCategory) _then) = __$CaxiloCategoryCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String translationKey, CaxiloFilter filter, String? icon, String? iconActive
});


@override $CaxiloFilterCopyWith<$Res> get filter;

}
/// @nodoc
class __$CaxiloCategoryCopyWithImpl<$Res>
    implements _$CaxiloCategoryCopyWith<$Res> {
  __$CaxiloCategoryCopyWithImpl(this._self, this._then);

  final _CaxiloCategory _self;
  final $Res Function(_CaxiloCategory) _then;

/// Create a copy of CaxiloCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? translationKey = null,Object? filter = null,Object? icon = freezed,Object? iconActive = freezed,}) {
  return _then(_CaxiloCategory(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,translationKey: null == translationKey ? _self.translationKey : translationKey // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CaxiloFilter,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CaxiloCategory
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
