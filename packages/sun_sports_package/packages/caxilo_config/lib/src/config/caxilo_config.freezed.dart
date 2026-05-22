// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caxilo_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaxiloConfig {

/// ISO 8601 timestamp of the last configuration update.
@JsonKey(name: 'updated_at') String get updatedAt;/// Schema version for backward compatibility checks.
 int get version;/// Global map of environment variables (mostly base URLs).
 Map<String, String> get environments;/// Configuration for game display and marketing (shared across modules).
 DisplayConfig get display;/// Lobby feature config: "All / Home" tab presentation + SDUI home sections.
/// When null, the repository falls back to hardcoded presets.
 LobbyConfig? get lobby;/// List of game categories to be displayed in the lobby.
 List<CategoryConfig> get categories;/// Configuration specific to in-house games.
@JsonKey(name: 'in_house') InHouseConfig get inHouse;/// Configuration specific to 3rd-party remote providers.
@JsonKey(name: 'external') ExternalConfig get external;
/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloConfigCopyWith<CaxiloConfig> get copyWith => _$CaxiloConfigCopyWithImpl<CaxiloConfig>(this as CaxiloConfig, _$identity);

  /// Serializes this CaxiloConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloConfig&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.environments, environments)&&(identical(other.display, display) || other.display == display)&&(identical(other.lobby, lobby) || other.lobby == lobby)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.inHouse, inHouse) || other.inHouse == inHouse)&&(identical(other.external, external) || other.external == external));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updatedAt,version,const DeepCollectionEquality().hash(environments),display,lobby,const DeepCollectionEquality().hash(categories),inHouse,external);

@override
String toString() {
  return 'CaxiloConfig(updatedAt: $updatedAt, version: $version, environments: $environments, display: $display, lobby: $lobby, categories: $categories, inHouse: $inHouse, external: $external)';
}


}

/// @nodoc
abstract mixin class $CaxiloConfigCopyWith<$Res>  {
  factory $CaxiloConfigCopyWith(CaxiloConfig value, $Res Function(CaxiloConfig) _then) = _$CaxiloConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'updated_at') String updatedAt, int version, Map<String, String> environments, DisplayConfig display, LobbyConfig? lobby, List<CategoryConfig> categories,@JsonKey(name: 'in_house') InHouseConfig inHouse,@JsonKey(name: 'external') ExternalConfig external
});


$DisplayConfigCopyWith<$Res> get display;$LobbyConfigCopyWith<$Res>? get lobby;$InHouseConfigCopyWith<$Res> get inHouse;$ExternalConfigCopyWith<$Res> get external;

}
/// @nodoc
class _$CaxiloConfigCopyWithImpl<$Res>
    implements $CaxiloConfigCopyWith<$Res> {
  _$CaxiloConfigCopyWithImpl(this._self, this._then);

  final CaxiloConfig _self;
  final $Res Function(CaxiloConfig) _then;

/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? updatedAt = null,Object? version = null,Object? environments = null,Object? display = null,Object? lobby = freezed,Object? categories = null,Object? inHouse = null,Object? external = null,}) {
  return _then(_self.copyWith(
updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,environments: null == environments ? _self.environments : environments // ignore: cast_nullable_to_non_nullable
as Map<String, String>,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as DisplayConfig,lobby: freezed == lobby ? _self.lobby : lobby // ignore: cast_nullable_to_non_nullable
as LobbyConfig?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryConfig>,inHouse: null == inHouse ? _self.inHouse : inHouse // ignore: cast_nullable_to_non_nullable
as InHouseConfig,external: null == external ? _self.external : external // ignore: cast_nullable_to_non_nullable
as ExternalConfig,
  ));
}
/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DisplayConfigCopyWith<$Res> get display {
  
  return $DisplayConfigCopyWith<$Res>(_self.display, (value) {
    return _then(_self.copyWith(display: value));
  });
}/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LobbyConfigCopyWith<$Res>? get lobby {
    if (_self.lobby == null) {
    return null;
  }

  return $LobbyConfigCopyWith<$Res>(_self.lobby!, (value) {
    return _then(_self.copyWith(lobby: value));
  });
}/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InHouseConfigCopyWith<$Res> get inHouse {
  
  return $InHouseConfigCopyWith<$Res>(_self.inHouse, (value) {
    return _then(_self.copyWith(inHouse: value));
  });
}/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExternalConfigCopyWith<$Res> get external {
  
  return $ExternalConfigCopyWith<$Res>(_self.external, (value) {
    return _then(_self.copyWith(external: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaxiloConfig].
extension CaxiloConfigPatterns on CaxiloConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaxiloConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaxiloConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaxiloConfig value)  $default,){
final _that = this;
switch (_that) {
case _CaxiloConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaxiloConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CaxiloConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'updated_at')  String updatedAt,  int version,  Map<String, String> environments,  DisplayConfig display,  LobbyConfig? lobby,  List<CategoryConfig> categories, @JsonKey(name: 'in_house')  InHouseConfig inHouse, @JsonKey(name: 'external')  ExternalConfig external)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaxiloConfig() when $default != null:
return $default(_that.updatedAt,_that.version,_that.environments,_that.display,_that.lobby,_that.categories,_that.inHouse,_that.external);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'updated_at')  String updatedAt,  int version,  Map<String, String> environments,  DisplayConfig display,  LobbyConfig? lobby,  List<CategoryConfig> categories, @JsonKey(name: 'in_house')  InHouseConfig inHouse, @JsonKey(name: 'external')  ExternalConfig external)  $default,) {final _that = this;
switch (_that) {
case _CaxiloConfig():
return $default(_that.updatedAt,_that.version,_that.environments,_that.display,_that.lobby,_that.categories,_that.inHouse,_that.external);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'updated_at')  String updatedAt,  int version,  Map<String, String> environments,  DisplayConfig display,  LobbyConfig? lobby,  List<CategoryConfig> categories, @JsonKey(name: 'in_house')  InHouseConfig inHouse, @JsonKey(name: 'external')  ExternalConfig external)?  $default,) {final _that = this;
switch (_that) {
case _CaxiloConfig() when $default != null:
return $default(_that.updatedAt,_that.version,_that.environments,_that.display,_that.lobby,_that.categories,_that.inHouse,_that.external);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaxiloConfig implements CaxiloConfig {
  const _CaxiloConfig({@JsonKey(name: 'updated_at') required this.updatedAt, this.version = 1, final  Map<String, String> environments = const {}, this.display = const DisplayConfig(), this.lobby, final  List<CategoryConfig> categories = const [], @JsonKey(name: 'in_house') this.inHouse = const InHouseConfig(), @JsonKey(name: 'external') this.external = const ExternalConfig()}): _environments = environments,_categories = categories;
  factory _CaxiloConfig.fromJson(Map<String, dynamic> json) => _$CaxiloConfigFromJson(json);

/// ISO 8601 timestamp of the last configuration update.
@override@JsonKey(name: 'updated_at') final  String updatedAt;
/// Schema version for backward compatibility checks.
@override@JsonKey() final  int version;
/// Global map of environment variables (mostly base URLs).
 final  Map<String, String> _environments;
/// Global map of environment variables (mostly base URLs).
@override@JsonKey() Map<String, String> get environments {
  if (_environments is EqualUnmodifiableMapView) return _environments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_environments);
}

/// Configuration for game display and marketing (shared across modules).
@override@JsonKey() final  DisplayConfig display;
/// Lobby feature config: "All / Home" tab presentation + SDUI home sections.
/// When null, the repository falls back to hardcoded presets.
@override final  LobbyConfig? lobby;
/// List of game categories to be displayed in the lobby.
 final  List<CategoryConfig> _categories;
/// List of game categories to be displayed in the lobby.
@override@JsonKey() List<CategoryConfig> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// Configuration specific to in-house games.
@override@JsonKey(name: 'in_house') final  InHouseConfig inHouse;
/// Configuration specific to 3rd-party remote providers.
@override@JsonKey(name: 'external') final  ExternalConfig external;

/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaxiloConfigCopyWith<_CaxiloConfig> get copyWith => __$CaxiloConfigCopyWithImpl<_CaxiloConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaxiloConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaxiloConfig&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._environments, _environments)&&(identical(other.display, display) || other.display == display)&&(identical(other.lobby, lobby) || other.lobby == lobby)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.inHouse, inHouse) || other.inHouse == inHouse)&&(identical(other.external, external) || other.external == external));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updatedAt,version,const DeepCollectionEquality().hash(_environments),display,lobby,const DeepCollectionEquality().hash(_categories),inHouse,external);

@override
String toString() {
  return 'CaxiloConfig(updatedAt: $updatedAt, version: $version, environments: $environments, display: $display, lobby: $lobby, categories: $categories, inHouse: $inHouse, external: $external)';
}


}

/// @nodoc
abstract mixin class _$CaxiloConfigCopyWith<$Res> implements $CaxiloConfigCopyWith<$Res> {
  factory _$CaxiloConfigCopyWith(_CaxiloConfig value, $Res Function(_CaxiloConfig) _then) = __$CaxiloConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'updated_at') String updatedAt, int version, Map<String, String> environments, DisplayConfig display, LobbyConfig? lobby, List<CategoryConfig> categories,@JsonKey(name: 'in_house') InHouseConfig inHouse,@JsonKey(name: 'external') ExternalConfig external
});


@override $DisplayConfigCopyWith<$Res> get display;@override $LobbyConfigCopyWith<$Res>? get lobby;@override $InHouseConfigCopyWith<$Res> get inHouse;@override $ExternalConfigCopyWith<$Res> get external;

}
/// @nodoc
class __$CaxiloConfigCopyWithImpl<$Res>
    implements _$CaxiloConfigCopyWith<$Res> {
  __$CaxiloConfigCopyWithImpl(this._self, this._then);

  final _CaxiloConfig _self;
  final $Res Function(_CaxiloConfig) _then;

/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? updatedAt = null,Object? version = null,Object? environments = null,Object? display = null,Object? lobby = freezed,Object? categories = null,Object? inHouse = null,Object? external = null,}) {
  return _then(_CaxiloConfig(
updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,environments: null == environments ? _self._environments : environments // ignore: cast_nullable_to_non_nullable
as Map<String, String>,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as DisplayConfig,lobby: freezed == lobby ? _self.lobby : lobby // ignore: cast_nullable_to_non_nullable
as LobbyConfig?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryConfig>,inHouse: null == inHouse ? _self.inHouse : inHouse // ignore: cast_nullable_to_non_nullable
as InHouseConfig,external: null == external ? _self.external : external // ignore: cast_nullable_to_non_nullable
as ExternalConfig,
  ));
}

/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DisplayConfigCopyWith<$Res> get display {
  
  return $DisplayConfigCopyWith<$Res>(_self.display, (value) {
    return _then(_self.copyWith(display: value));
  });
}/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LobbyConfigCopyWith<$Res>? get lobby {
    if (_self.lobby == null) {
    return null;
  }

  return $LobbyConfigCopyWith<$Res>(_self.lobby!, (value) {
    return _then(_self.copyWith(lobby: value));
  });
}/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InHouseConfigCopyWith<$Res> get inHouse {
  
  return $InHouseConfigCopyWith<$Res>(_self.inHouse, (value) {
    return _then(_self.copyWith(inHouse: value));
  });
}/// Create a copy of CaxiloConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExternalConfigCopyWith<$Res> get external {
  
  return $ExternalConfigCopyWith<$Res>(_self.external, (value) {
    return _then(_self.copyWith(external: value));
  });
}
}

// dart format on
