// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'external_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExternalProviderConfig {

/// Optional override for the game category.
@JsonKey(name: 'game_type') GameType? get gameType;/// Allowed orientations on mobile phones.
@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation>? get mobileOrientation;/// Allowed orientations on tablets.
@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation>? get tabletOrientation;/// Allowed orientations on desktops.
@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation>? get desktopOrientation;/// Whether this provider should forcefully render in landscape on iPad.
@JsonKey(name: 'force_landscape_viewport_on_ipad') bool? get forceLandscapeViewportOnIpad;/// Whether games from this provider should be opened in a new tab to avoid crashes.
@JsonKey(name: 'open_in_new_tab_on_ios_safari_web') bool? get openInNewTabOnIOSSafariWeb;/// Whether a session cooldown guard is required before launching.
@JsonKey(name: 'requires_session_guard') bool? get requiresSessionGuard;/// Debounce duration (in milliseconds) for the load stop event.
@JsonKey(name: 'load_stop_debounce_ms') int? get loadStopDebounceMs;/// The list of supported games and their specific overrides for this provider.
@JsonKey(name: 'games') List<ExternalGame> get games;
/// Create a copy of ExternalProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalProviderConfigCopyWith<ExternalProviderConfig> get copyWith => _$ExternalProviderConfigCopyWithImpl<ExternalProviderConfig>(this as ExternalProviderConfig, _$identity);

  /// Serializes this ExternalProviderConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalProviderConfig&&(identical(other.gameType, gameType) || other.gameType == gameType)&&const DeepCollectionEquality().equals(other.mobileOrientation, mobileOrientation)&&const DeepCollectionEquality().equals(other.tabletOrientation, tabletOrientation)&&const DeepCollectionEquality().equals(other.desktopOrientation, desktopOrientation)&&(identical(other.forceLandscapeViewportOnIpad, forceLandscapeViewportOnIpad) || other.forceLandscapeViewportOnIpad == forceLandscapeViewportOnIpad)&&(identical(other.openInNewTabOnIOSSafariWeb, openInNewTabOnIOSSafariWeb) || other.openInNewTabOnIOSSafariWeb == openInNewTabOnIOSSafariWeb)&&(identical(other.requiresSessionGuard, requiresSessionGuard) || other.requiresSessionGuard == requiresSessionGuard)&&(identical(other.loadStopDebounceMs, loadStopDebounceMs) || other.loadStopDebounceMs == loadStopDebounceMs)&&const DeepCollectionEquality().equals(other.games, games));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameType,const DeepCollectionEquality().hash(mobileOrientation),const DeepCollectionEquality().hash(tabletOrientation),const DeepCollectionEquality().hash(desktopOrientation),forceLandscapeViewportOnIpad,openInNewTabOnIOSSafariWeb,requiresSessionGuard,loadStopDebounceMs,const DeepCollectionEquality().hash(games));

@override
String toString() {
  return 'ExternalProviderConfig(gameType: $gameType, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, forceLandscapeViewportOnIpad: $forceLandscapeViewportOnIpad, openInNewTabOnIOSSafariWeb: $openInNewTabOnIOSSafariWeb, requiresSessionGuard: $requiresSessionGuard, loadStopDebounceMs: $loadStopDebounceMs, games: $games)';
}


}

/// @nodoc
abstract mixin class $ExternalProviderConfigCopyWith<$Res>  {
  factory $ExternalProviderConfigCopyWith(ExternalProviderConfig value, $Res Function(ExternalProviderConfig) _then) = _$ExternalProviderConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'game_type') GameType? gameType,@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation>? mobileOrientation,@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation>? tabletOrientation,@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation>? desktopOrientation,@JsonKey(name: 'force_landscape_viewport_on_ipad') bool? forceLandscapeViewportOnIpad,@JsonKey(name: 'open_in_new_tab_on_ios_safari_web') bool? openInNewTabOnIOSSafariWeb,@JsonKey(name: 'requires_session_guard') bool? requiresSessionGuard,@JsonKey(name: 'load_stop_debounce_ms') int? loadStopDebounceMs,@JsonKey(name: 'games') List<ExternalGame> games
});




}
/// @nodoc
class _$ExternalProviderConfigCopyWithImpl<$Res>
    implements $ExternalProviderConfigCopyWith<$Res> {
  _$ExternalProviderConfigCopyWithImpl(this._self, this._then);

  final ExternalProviderConfig _self;
  final $Res Function(ExternalProviderConfig) _then;

/// Create a copy of ExternalProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameType = freezed,Object? mobileOrientation = freezed,Object? tabletOrientation = freezed,Object? desktopOrientation = freezed,Object? forceLandscapeViewportOnIpad = freezed,Object? openInNewTabOnIOSSafariWeb = freezed,Object? requiresSessionGuard = freezed,Object? loadStopDebounceMs = freezed,Object? games = null,}) {
  return _then(_self.copyWith(
gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType?,mobileOrientation: freezed == mobileOrientation ? _self.mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>?,tabletOrientation: freezed == tabletOrientation ? _self.tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>?,desktopOrientation: freezed == desktopOrientation ? _self.desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>?,forceLandscapeViewportOnIpad: freezed == forceLandscapeViewportOnIpad ? _self.forceLandscapeViewportOnIpad : forceLandscapeViewportOnIpad // ignore: cast_nullable_to_non_nullable
as bool?,openInNewTabOnIOSSafariWeb: freezed == openInNewTabOnIOSSafariWeb ? _self.openInNewTabOnIOSSafariWeb : openInNewTabOnIOSSafariWeb // ignore: cast_nullable_to_non_nullable
as bool?,requiresSessionGuard: freezed == requiresSessionGuard ? _self.requiresSessionGuard : requiresSessionGuard // ignore: cast_nullable_to_non_nullable
as bool?,loadStopDebounceMs: freezed == loadStopDebounceMs ? _self.loadStopDebounceMs : loadStopDebounceMs // ignore: cast_nullable_to_non_nullable
as int?,games: null == games ? _self.games : games // ignore: cast_nullable_to_non_nullable
as List<ExternalGame>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExternalProviderConfig].
extension ExternalProviderConfigPatterns on ExternalProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExternalProviderConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExternalProviderConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExternalProviderConfig value)  $default,){
final _that = this;
switch (_that) {
case _ExternalProviderConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExternalProviderConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ExternalProviderConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'game_type')  GameType? gameType, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter()  List<GameOrientation>? mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter()  List<GameOrientation>? tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter()  List<GameOrientation>? desktopOrientation, @JsonKey(name: 'force_landscape_viewport_on_ipad')  bool? forceLandscapeViewportOnIpad, @JsonKey(name: 'open_in_new_tab_on_ios_safari_web')  bool? openInNewTabOnIOSSafariWeb, @JsonKey(name: 'requires_session_guard')  bool? requiresSessionGuard, @JsonKey(name: 'load_stop_debounce_ms')  int? loadStopDebounceMs, @JsonKey(name: 'games')  List<ExternalGame> games)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExternalProviderConfig() when $default != null:
return $default(_that.gameType,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard,_that.loadStopDebounceMs,_that.games);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'game_type')  GameType? gameType, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter()  List<GameOrientation>? mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter()  List<GameOrientation>? tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter()  List<GameOrientation>? desktopOrientation, @JsonKey(name: 'force_landscape_viewport_on_ipad')  bool? forceLandscapeViewportOnIpad, @JsonKey(name: 'open_in_new_tab_on_ios_safari_web')  bool? openInNewTabOnIOSSafariWeb, @JsonKey(name: 'requires_session_guard')  bool? requiresSessionGuard, @JsonKey(name: 'load_stop_debounce_ms')  int? loadStopDebounceMs, @JsonKey(name: 'games')  List<ExternalGame> games)  $default,) {final _that = this;
switch (_that) {
case _ExternalProviderConfig():
return $default(_that.gameType,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard,_that.loadStopDebounceMs,_that.games);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'game_type')  GameType? gameType, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter()  List<GameOrientation>? mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter()  List<GameOrientation>? tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter()  List<GameOrientation>? desktopOrientation, @JsonKey(name: 'force_landscape_viewport_on_ipad')  bool? forceLandscapeViewportOnIpad, @JsonKey(name: 'open_in_new_tab_on_ios_safari_web')  bool? openInNewTabOnIOSSafariWeb, @JsonKey(name: 'requires_session_guard')  bool? requiresSessionGuard, @JsonKey(name: 'load_stop_debounce_ms')  int? loadStopDebounceMs, @JsonKey(name: 'games')  List<ExternalGame> games)?  $default,) {final _that = this;
switch (_that) {
case _ExternalProviderConfig() when $default != null:
return $default(_that.gameType,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard,_that.loadStopDebounceMs,_that.games);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExternalProviderConfig implements ExternalProviderConfig {
  const _ExternalProviderConfig({@JsonKey(name: 'game_type') this.gameType, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() final  List<GameOrientation>? mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() final  List<GameOrientation>? tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() final  List<GameOrientation>? desktopOrientation, @JsonKey(name: 'force_landscape_viewport_on_ipad') this.forceLandscapeViewportOnIpad, @JsonKey(name: 'open_in_new_tab_on_ios_safari_web') this.openInNewTabOnIOSSafariWeb, @JsonKey(name: 'requires_session_guard') this.requiresSessionGuard, @JsonKey(name: 'load_stop_debounce_ms') this.loadStopDebounceMs, @JsonKey(name: 'games') final  List<ExternalGame> games = const []}): _mobileOrientation = mobileOrientation,_tabletOrientation = tabletOrientation,_desktopOrientation = desktopOrientation,_games = games;
  factory _ExternalProviderConfig.fromJson(Map<String, dynamic> json) => _$ExternalProviderConfigFromJson(json);

/// Optional override for the game category.
@override@JsonKey(name: 'game_type') final  GameType? gameType;
/// Allowed orientations on mobile phones.
 final  List<GameOrientation>? _mobileOrientation;
/// Allowed orientations on mobile phones.
@override@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation>? get mobileOrientation {
  final value = _mobileOrientation;
  if (value == null) return null;
  if (_mobileOrientation is EqualUnmodifiableListView) return _mobileOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Allowed orientations on tablets.
 final  List<GameOrientation>? _tabletOrientation;
/// Allowed orientations on tablets.
@override@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation>? get tabletOrientation {
  final value = _tabletOrientation;
  if (value == null) return null;
  if (_tabletOrientation is EqualUnmodifiableListView) return _tabletOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Allowed orientations on desktops.
 final  List<GameOrientation>? _desktopOrientation;
/// Allowed orientations on desktops.
@override@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation>? get desktopOrientation {
  final value = _desktopOrientation;
  if (value == null) return null;
  if (_desktopOrientation is EqualUnmodifiableListView) return _desktopOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Whether this provider should forcefully render in landscape on iPad.
@override@JsonKey(name: 'force_landscape_viewport_on_ipad') final  bool? forceLandscapeViewportOnIpad;
/// Whether games from this provider should be opened in a new tab to avoid crashes.
@override@JsonKey(name: 'open_in_new_tab_on_ios_safari_web') final  bool? openInNewTabOnIOSSafariWeb;
/// Whether a session cooldown guard is required before launching.
@override@JsonKey(name: 'requires_session_guard') final  bool? requiresSessionGuard;
/// Debounce duration (in milliseconds) for the load stop event.
@override@JsonKey(name: 'load_stop_debounce_ms') final  int? loadStopDebounceMs;
/// The list of supported games and their specific overrides for this provider.
 final  List<ExternalGame> _games;
/// The list of supported games and their specific overrides for this provider.
@override@JsonKey(name: 'games') List<ExternalGame> get games {
  if (_games is EqualUnmodifiableListView) return _games;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_games);
}


/// Create a copy of ExternalProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExternalProviderConfigCopyWith<_ExternalProviderConfig> get copyWith => __$ExternalProviderConfigCopyWithImpl<_ExternalProviderConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExternalProviderConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExternalProviderConfig&&(identical(other.gameType, gameType) || other.gameType == gameType)&&const DeepCollectionEquality().equals(other._mobileOrientation, _mobileOrientation)&&const DeepCollectionEquality().equals(other._tabletOrientation, _tabletOrientation)&&const DeepCollectionEquality().equals(other._desktopOrientation, _desktopOrientation)&&(identical(other.forceLandscapeViewportOnIpad, forceLandscapeViewportOnIpad) || other.forceLandscapeViewportOnIpad == forceLandscapeViewportOnIpad)&&(identical(other.openInNewTabOnIOSSafariWeb, openInNewTabOnIOSSafariWeb) || other.openInNewTabOnIOSSafariWeb == openInNewTabOnIOSSafariWeb)&&(identical(other.requiresSessionGuard, requiresSessionGuard) || other.requiresSessionGuard == requiresSessionGuard)&&(identical(other.loadStopDebounceMs, loadStopDebounceMs) || other.loadStopDebounceMs == loadStopDebounceMs)&&const DeepCollectionEquality().equals(other._games, _games));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameType,const DeepCollectionEquality().hash(_mobileOrientation),const DeepCollectionEquality().hash(_tabletOrientation),const DeepCollectionEquality().hash(_desktopOrientation),forceLandscapeViewportOnIpad,openInNewTabOnIOSSafariWeb,requiresSessionGuard,loadStopDebounceMs,const DeepCollectionEquality().hash(_games));

@override
String toString() {
  return 'ExternalProviderConfig(gameType: $gameType, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, forceLandscapeViewportOnIpad: $forceLandscapeViewportOnIpad, openInNewTabOnIOSSafariWeb: $openInNewTabOnIOSSafariWeb, requiresSessionGuard: $requiresSessionGuard, loadStopDebounceMs: $loadStopDebounceMs, games: $games)';
}


}

/// @nodoc
abstract mixin class _$ExternalProviderConfigCopyWith<$Res> implements $ExternalProviderConfigCopyWith<$Res> {
  factory _$ExternalProviderConfigCopyWith(_ExternalProviderConfig value, $Res Function(_ExternalProviderConfig) _then) = __$ExternalProviderConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'game_type') GameType? gameType,@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation>? mobileOrientation,@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation>? tabletOrientation,@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation>? desktopOrientation,@JsonKey(name: 'force_landscape_viewport_on_ipad') bool? forceLandscapeViewportOnIpad,@JsonKey(name: 'open_in_new_tab_on_ios_safari_web') bool? openInNewTabOnIOSSafariWeb,@JsonKey(name: 'requires_session_guard') bool? requiresSessionGuard,@JsonKey(name: 'load_stop_debounce_ms') int? loadStopDebounceMs,@JsonKey(name: 'games') List<ExternalGame> games
});




}
/// @nodoc
class __$ExternalProviderConfigCopyWithImpl<$Res>
    implements _$ExternalProviderConfigCopyWith<$Res> {
  __$ExternalProviderConfigCopyWithImpl(this._self, this._then);

  final _ExternalProviderConfig _self;
  final $Res Function(_ExternalProviderConfig) _then;

/// Create a copy of ExternalProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameType = freezed,Object? mobileOrientation = freezed,Object? tabletOrientation = freezed,Object? desktopOrientation = freezed,Object? forceLandscapeViewportOnIpad = freezed,Object? openInNewTabOnIOSSafariWeb = freezed,Object? requiresSessionGuard = freezed,Object? loadStopDebounceMs = freezed,Object? games = null,}) {
  return _then(_ExternalProviderConfig(
gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType?,mobileOrientation: freezed == mobileOrientation ? _self._mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>?,tabletOrientation: freezed == tabletOrientation ? _self._tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>?,desktopOrientation: freezed == desktopOrientation ? _self._desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>?,forceLandscapeViewportOnIpad: freezed == forceLandscapeViewportOnIpad ? _self.forceLandscapeViewportOnIpad : forceLandscapeViewportOnIpad // ignore: cast_nullable_to_non_nullable
as bool?,openInNewTabOnIOSSafariWeb: freezed == openInNewTabOnIOSSafariWeb ? _self.openInNewTabOnIOSSafariWeb : openInNewTabOnIOSSafariWeb // ignore: cast_nullable_to_non_nullable
as bool?,requiresSessionGuard: freezed == requiresSessionGuard ? _self.requiresSessionGuard : requiresSessionGuard // ignore: cast_nullable_to_non_nullable
as bool?,loadStopDebounceMs: freezed == loadStopDebounceMs ? _self.loadStopDebounceMs : loadStopDebounceMs // ignore: cast_nullable_to_non_nullable
as int?,games: null == games ? _self._games : games // ignore: cast_nullable_to_non_nullable
as List<ExternalGame>,
  ));
}


}


/// @nodoc
mixin _$ExternalConfig {

/// Whether to show all games ignoring the whitelist (Debug/Test only).
@JsonKey(name: 'test_mode') bool get testMode;/// Map of providerId to their respective configuration overrides and game lists.
@JsonKey(name: 'provider_configs') Map<String, ExternalProviderConfig> get providerConfigs;
/// Create a copy of ExternalConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalConfigCopyWith<ExternalConfig> get copyWith => _$ExternalConfigCopyWithImpl<ExternalConfig>(this as ExternalConfig, _$identity);

  /// Serializes this ExternalConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalConfig&&(identical(other.testMode, testMode) || other.testMode == testMode)&&const DeepCollectionEquality().equals(other.providerConfigs, providerConfigs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testMode,const DeepCollectionEquality().hash(providerConfigs));

@override
String toString() {
  return 'ExternalConfig(testMode: $testMode, providerConfigs: $providerConfigs)';
}


}

/// @nodoc
abstract mixin class $ExternalConfigCopyWith<$Res>  {
  factory $ExternalConfigCopyWith(ExternalConfig value, $Res Function(ExternalConfig) _then) = _$ExternalConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'test_mode') bool testMode,@JsonKey(name: 'provider_configs') Map<String, ExternalProviderConfig> providerConfigs
});




}
/// @nodoc
class _$ExternalConfigCopyWithImpl<$Res>
    implements $ExternalConfigCopyWith<$Res> {
  _$ExternalConfigCopyWithImpl(this._self, this._then);

  final ExternalConfig _self;
  final $Res Function(ExternalConfig) _then;

/// Create a copy of ExternalConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testMode = null,Object? providerConfigs = null,}) {
  return _then(_self.copyWith(
testMode: null == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool,providerConfigs: null == providerConfigs ? _self.providerConfigs : providerConfigs // ignore: cast_nullable_to_non_nullable
as Map<String, ExternalProviderConfig>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExternalConfig].
extension ExternalConfigPatterns on ExternalConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExternalConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExternalConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExternalConfig value)  $default,){
final _that = this;
switch (_that) {
case _ExternalConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExternalConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ExternalConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'test_mode')  bool testMode, @JsonKey(name: 'provider_configs')  Map<String, ExternalProviderConfig> providerConfigs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExternalConfig() when $default != null:
return $default(_that.testMode,_that.providerConfigs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'test_mode')  bool testMode, @JsonKey(name: 'provider_configs')  Map<String, ExternalProviderConfig> providerConfigs)  $default,) {final _that = this;
switch (_that) {
case _ExternalConfig():
return $default(_that.testMode,_that.providerConfigs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'test_mode')  bool testMode, @JsonKey(name: 'provider_configs')  Map<String, ExternalProviderConfig> providerConfigs)?  $default,) {final _that = this;
switch (_that) {
case _ExternalConfig() when $default != null:
return $default(_that.testMode,_that.providerConfigs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExternalConfig implements ExternalConfig {
  const _ExternalConfig({@JsonKey(name: 'test_mode') this.testMode = false, @JsonKey(name: 'provider_configs') final  Map<String, ExternalProviderConfig> providerConfigs = const {}}): _providerConfigs = providerConfigs;
  factory _ExternalConfig.fromJson(Map<String, dynamic> json) => _$ExternalConfigFromJson(json);

/// Whether to show all games ignoring the whitelist (Debug/Test only).
@override@JsonKey(name: 'test_mode') final  bool testMode;
/// Map of providerId to their respective configuration overrides and game lists.
 final  Map<String, ExternalProviderConfig> _providerConfigs;
/// Map of providerId to their respective configuration overrides and game lists.
@override@JsonKey(name: 'provider_configs') Map<String, ExternalProviderConfig> get providerConfigs {
  if (_providerConfigs is EqualUnmodifiableMapView) return _providerConfigs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_providerConfigs);
}


/// Create a copy of ExternalConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExternalConfigCopyWith<_ExternalConfig> get copyWith => __$ExternalConfigCopyWithImpl<_ExternalConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExternalConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExternalConfig&&(identical(other.testMode, testMode) || other.testMode == testMode)&&const DeepCollectionEquality().equals(other._providerConfigs, _providerConfigs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testMode,const DeepCollectionEquality().hash(_providerConfigs));

@override
String toString() {
  return 'ExternalConfig(testMode: $testMode, providerConfigs: $providerConfigs)';
}


}

/// @nodoc
abstract mixin class _$ExternalConfigCopyWith<$Res> implements $ExternalConfigCopyWith<$Res> {
  factory _$ExternalConfigCopyWith(_ExternalConfig value, $Res Function(_ExternalConfig) _then) = __$ExternalConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'test_mode') bool testMode,@JsonKey(name: 'provider_configs') Map<String, ExternalProviderConfig> providerConfigs
});




}
/// @nodoc
class __$ExternalConfigCopyWithImpl<$Res>
    implements _$ExternalConfigCopyWith<$Res> {
  __$ExternalConfigCopyWithImpl(this._self, this._then);

  final _ExternalConfig _self;
  final $Res Function(_ExternalConfig) _then;

/// Create a copy of ExternalConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testMode = null,Object? providerConfigs = null,}) {
  return _then(_ExternalConfig(
testMode: null == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool,providerConfigs: null == providerConfigs ? _self._providerConfigs : providerConfigs // ignore: cast_nullable_to_non_nullable
as Map<String, ExternalProviderConfig>,
  ));
}


}

// dart format on
