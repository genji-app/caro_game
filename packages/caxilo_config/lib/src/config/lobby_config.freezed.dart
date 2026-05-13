// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LobbyConfig {

@JsonKey(name: 'translation_key') String? get translationKey; String? get icon;@JsonKey(name: 'icon_active') String? get iconActive; List<LobbySectionConfig> get sections;
/// Create a copy of LobbyConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyConfigCopyWith<LobbyConfig> get copyWith => _$LobbyConfigCopyWithImpl<LobbyConfig>(this as LobbyConfig, _$identity);

  /// Serializes this LobbyConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyConfig&&(identical(other.translationKey, translationKey) || other.translationKey == translationKey)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,translationKey,icon,iconActive,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'LobbyConfig(translationKey: $translationKey, icon: $icon, iconActive: $iconActive, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $LobbyConfigCopyWith<$Res>  {
  factory $LobbyConfigCopyWith(LobbyConfig value, $Res Function(LobbyConfig) _then) = _$LobbyConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'translation_key') String? translationKey, String? icon,@JsonKey(name: 'icon_active') String? iconActive, List<LobbySectionConfig> sections
});




}
/// @nodoc
class _$LobbyConfigCopyWithImpl<$Res>
    implements $LobbyConfigCopyWith<$Res> {
  _$LobbyConfigCopyWithImpl(this._self, this._then);

  final LobbyConfig _self;
  final $Res Function(LobbyConfig) _then;

/// Create a copy of LobbyConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? translationKey = freezed,Object? icon = freezed,Object? iconActive = freezed,Object? sections = null,}) {
  return _then(_self.copyWith(
translationKey: freezed == translationKey ? _self.translationKey : translationKey // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<LobbySectionConfig>,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbyConfig].
extension LobbyConfigPatterns on LobbyConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbyConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbyConfig value)  $default,){
final _that = this;
switch (_that) {
case _LobbyConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbyConfig value)?  $default,){
final _that = this;
switch (_that) {
case _LobbyConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'translation_key')  String? translationKey,  String? icon, @JsonKey(name: 'icon_active')  String? iconActive,  List<LobbySectionConfig> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyConfig() when $default != null:
return $default(_that.translationKey,_that.icon,_that.iconActive,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'translation_key')  String? translationKey,  String? icon, @JsonKey(name: 'icon_active')  String? iconActive,  List<LobbySectionConfig> sections)  $default,) {final _that = this;
switch (_that) {
case _LobbyConfig():
return $default(_that.translationKey,_that.icon,_that.iconActive,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'translation_key')  String? translationKey,  String? icon, @JsonKey(name: 'icon_active')  String? iconActive,  List<LobbySectionConfig> sections)?  $default,) {final _that = this;
switch (_that) {
case _LobbyConfig() when $default != null:
return $default(_that.translationKey,_that.icon,_that.iconActive,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LobbyConfig implements LobbyConfig {
  const _LobbyConfig({@JsonKey(name: 'translation_key') this.translationKey, this.icon, @JsonKey(name: 'icon_active') this.iconActive, final  List<LobbySectionConfig> sections = const []}): _sections = sections;
  factory _LobbyConfig.fromJson(Map<String, dynamic> json) => _$LobbyConfigFromJson(json);

@override@JsonKey(name: 'translation_key') final  String? translationKey;
@override final  String? icon;
@override@JsonKey(name: 'icon_active') final  String? iconActive;
 final  List<LobbySectionConfig> _sections;
@override@JsonKey() List<LobbySectionConfig> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of LobbyConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyConfigCopyWith<_LobbyConfig> get copyWith => __$LobbyConfigCopyWithImpl<_LobbyConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LobbyConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyConfig&&(identical(other.translationKey, translationKey) || other.translationKey == translationKey)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,translationKey,icon,iconActive,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'LobbyConfig(translationKey: $translationKey, icon: $icon, iconActive: $iconActive, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$LobbyConfigCopyWith<$Res> implements $LobbyConfigCopyWith<$Res> {
  factory _$LobbyConfigCopyWith(_LobbyConfig value, $Res Function(_LobbyConfig) _then) = __$LobbyConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'translation_key') String? translationKey, String? icon,@JsonKey(name: 'icon_active') String? iconActive, List<LobbySectionConfig> sections
});




}
/// @nodoc
class __$LobbyConfigCopyWithImpl<$Res>
    implements _$LobbyConfigCopyWith<$Res> {
  __$LobbyConfigCopyWithImpl(this._self, this._then);

  final _LobbyConfig _self;
  final $Res Function(_LobbyConfig) _then;

/// Create a copy of LobbyConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? translationKey = freezed,Object? icon = freezed,Object? iconActive = freezed,Object? sections = null,}) {
  return _then(_LobbyConfig(
translationKey: freezed == translationKey ? _self.translationKey : translationKey // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<LobbySectionConfig>,
  ));
}


}


/// @nodoc
mixin _$LobbySectionConfig {

 String? get title; CaxiloFilter? get filter; int get limit;@JsonKey(name: 'banner_id') String? get bannerId;
/// Create a copy of LobbySectionConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbySectionConfigCopyWith<LobbySectionConfig> get copyWith => _$LobbySectionConfigCopyWithImpl<LobbySectionConfig>(this as LobbySectionConfig, _$identity);

  /// Serializes this LobbySectionConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbySectionConfig&&(identical(other.title, title) || other.title == title)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.bannerId, bannerId) || other.bannerId == bannerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,filter,limit,bannerId);

@override
String toString() {
  return 'LobbySectionConfig(title: $title, filter: $filter, limit: $limit, bannerId: $bannerId)';
}


}

/// @nodoc
abstract mixin class $LobbySectionConfigCopyWith<$Res>  {
  factory $LobbySectionConfigCopyWith(LobbySectionConfig value, $Res Function(LobbySectionConfig) _then) = _$LobbySectionConfigCopyWithImpl;
@useResult
$Res call({
 String? title, CaxiloFilter? filter, int limit,@JsonKey(name: 'banner_id') String? bannerId
});


$CaxiloFilterCopyWith<$Res>? get filter;

}
/// @nodoc
class _$LobbySectionConfigCopyWithImpl<$Res>
    implements $LobbySectionConfigCopyWith<$Res> {
  _$LobbySectionConfigCopyWithImpl(this._self, this._then);

  final LobbySectionConfig _self;
  final $Res Function(LobbySectionConfig) _then;

/// Create a copy of LobbySectionConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? filter = freezed,Object? limit = null,Object? bannerId = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CaxiloFilter?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,bannerId: freezed == bannerId ? _self.bannerId : bannerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of LobbySectionConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaxiloFilterCopyWith<$Res>? get filter {
    if (_self.filter == null) {
    return null;
  }

  return $CaxiloFilterCopyWith<$Res>(_self.filter!, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [LobbySectionConfig].
extension LobbySectionConfigPatterns on LobbySectionConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbySectionConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbySectionConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbySectionConfig value)  $default,){
final _that = this;
switch (_that) {
case _LobbySectionConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbySectionConfig value)?  $default,){
final _that = this;
switch (_that) {
case _LobbySectionConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  CaxiloFilter? filter,  int limit, @JsonKey(name: 'banner_id')  String? bannerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbySectionConfig() when $default != null:
return $default(_that.title,_that.filter,_that.limit,_that.bannerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  CaxiloFilter? filter,  int limit, @JsonKey(name: 'banner_id')  String? bannerId)  $default,) {final _that = this;
switch (_that) {
case _LobbySectionConfig():
return $default(_that.title,_that.filter,_that.limit,_that.bannerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  CaxiloFilter? filter,  int limit, @JsonKey(name: 'banner_id')  String? bannerId)?  $default,) {final _that = this;
switch (_that) {
case _LobbySectionConfig() when $default != null:
return $default(_that.title,_that.filter,_that.limit,_that.bannerId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LobbySectionConfig implements LobbySectionConfig {
  const _LobbySectionConfig({this.title, this.filter, this.limit = -1, @JsonKey(name: 'banner_id') this.bannerId});
  factory _LobbySectionConfig.fromJson(Map<String, dynamic> json) => _$LobbySectionConfigFromJson(json);

@override final  String? title;
@override final  CaxiloFilter? filter;
@override@JsonKey() final  int limit;
@override@JsonKey(name: 'banner_id') final  String? bannerId;

/// Create a copy of LobbySectionConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbySectionConfigCopyWith<_LobbySectionConfig> get copyWith => __$LobbySectionConfigCopyWithImpl<_LobbySectionConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LobbySectionConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbySectionConfig&&(identical(other.title, title) || other.title == title)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.bannerId, bannerId) || other.bannerId == bannerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,filter,limit,bannerId);

@override
String toString() {
  return 'LobbySectionConfig(title: $title, filter: $filter, limit: $limit, bannerId: $bannerId)';
}


}

/// @nodoc
abstract mixin class _$LobbySectionConfigCopyWith<$Res> implements $LobbySectionConfigCopyWith<$Res> {
  factory _$LobbySectionConfigCopyWith(_LobbySectionConfig value, $Res Function(_LobbySectionConfig) _then) = __$LobbySectionConfigCopyWithImpl;
@override @useResult
$Res call({
 String? title, CaxiloFilter? filter, int limit,@JsonKey(name: 'banner_id') String? bannerId
});


@override $CaxiloFilterCopyWith<$Res>? get filter;

}
/// @nodoc
class __$LobbySectionConfigCopyWithImpl<$Res>
    implements _$LobbySectionConfigCopyWith<$Res> {
  __$LobbySectionConfigCopyWithImpl(this._self, this._then);

  final _LobbySectionConfig _self;
  final $Res Function(_LobbySectionConfig) _then;

/// Create a copy of LobbySectionConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? filter = freezed,Object? limit = null,Object? bannerId = freezed,}) {
  return _then(_LobbySectionConfig(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as CaxiloFilter?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,bannerId: freezed == bannerId ? _self.bannerId : bannerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of LobbySectionConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaxiloFilterCopyWith<$Res>? get filter {
    if (_self.filter == null) {
    return null;
  }

  return $CaxiloFilterCopyWith<$Res>(_self.filter!, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on
