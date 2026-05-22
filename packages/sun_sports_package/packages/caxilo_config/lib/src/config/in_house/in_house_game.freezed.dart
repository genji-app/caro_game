// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_house_game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InHouseGame {

/// Unique product identifier (e.g., 'sunwin_AVENGER').
@JsonKey(name: 'product_id') String get productId;/// Unique short code for the game (e.g., 'AVENGER').
@JsonKey(name: 'game_code') String get gameCode;/// Human-readable name of the game.
@JsonKey(name: 'game_name') String get gameName;/// Unique id of the provider.
@JsonKey(name: 'provider_id') String get providerId;/// Human-readable name of the provider.
@JsonKey(name: 'provider_name') String get providerName;/// File path or name for the game thumbnail.
@JsonKey(name: 'image') String get image;/// Language code to be used in the launch URL.
@JsonKey(name: 'lang') String get lang;/// Categorization of the game.
@JsonKey(name: 'game_type') GameType get gameType;/// Execution strategy for launching the game.
@JsonKey(name: 'launch_strategy') GameLaunchStrategy get launchStrategy;/// Key used to resolve the base URL from environments.
@JsonKey(name: 'base_url_key') String? get baseUrlKey;/// Screen orientations supported on mobile devices.
@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation> get mobileOrientation;/// Screen orientations supported on tablets.
@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation> get tabletOrientation;/// Screen orientations supported on desktop.
@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation> get desktopOrientation;/// Whether to enable bidirectional messaging between JS and Flutter.
@JsonKey(name: 'enable_host_message') bool get enableHostMessage;/// Optional specific game identifier for internal provider systems.
@JsonKey(name: 'game_id') int? get gameId;
/// Create a copy of InHouseGame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InHouseGameCopyWith<InHouseGame> get copyWith => _$InHouseGameCopyWithImpl<InHouseGame>(this as InHouseGame, _$identity);

  /// Serializes this InHouseGame to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InHouseGame&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.launchStrategy, launchStrategy) || other.launchStrategy == launchStrategy)&&(identical(other.baseUrlKey, baseUrlKey) || other.baseUrlKey == baseUrlKey)&&const DeepCollectionEquality().equals(other.mobileOrientation, mobileOrientation)&&const DeepCollectionEquality().equals(other.tabletOrientation, tabletOrientation)&&const DeepCollectionEquality().equals(other.desktopOrientation, desktopOrientation)&&(identical(other.enableHostMessage, enableHostMessage) || other.enableHostMessage == enableHostMessage)&&(identical(other.gameId, gameId) || other.gameId == gameId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,gameCode,gameName,providerId,providerName,image,lang,gameType,launchStrategy,baseUrlKey,const DeepCollectionEquality().hash(mobileOrientation),const DeepCollectionEquality().hash(tabletOrientation),const DeepCollectionEquality().hash(desktopOrientation),enableHostMessage,gameId);

@override
String toString() {
  return 'InHouseGame(productId: $productId, gameCode: $gameCode, gameName: $gameName, providerId: $providerId, providerName: $providerName, image: $image, lang: $lang, gameType: $gameType, launchStrategy: $launchStrategy, baseUrlKey: $baseUrlKey, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, enableHostMessage: $enableHostMessage, gameId: $gameId)';
}


}

/// @nodoc
abstract mixin class $InHouseGameCopyWith<$Res>  {
  factory $InHouseGameCopyWith(InHouseGame value, $Res Function(InHouseGame) _then) = _$InHouseGameCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'game_code') String gameCode,@JsonKey(name: 'game_name') String gameName,@JsonKey(name: 'provider_id') String providerId,@JsonKey(name: 'provider_name') String providerName,@JsonKey(name: 'image') String image,@JsonKey(name: 'lang') String lang,@JsonKey(name: 'game_type') GameType gameType,@JsonKey(name: 'launch_strategy') GameLaunchStrategy launchStrategy,@JsonKey(name: 'base_url_key') String? baseUrlKey,@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation> mobileOrientation,@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation> tabletOrientation,@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation> desktopOrientation,@JsonKey(name: 'enable_host_message') bool enableHostMessage,@JsonKey(name: 'game_id') int? gameId
});




}
/// @nodoc
class _$InHouseGameCopyWithImpl<$Res>
    implements $InHouseGameCopyWith<$Res> {
  _$InHouseGameCopyWithImpl(this._self, this._then);

  final InHouseGame _self;
  final $Res Function(InHouseGame) _then;

/// Create a copy of InHouseGame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? providerId = null,Object? providerName = null,Object? image = null,Object? lang = null,Object? gameType = null,Object? launchStrategy = null,Object? baseUrlKey = freezed,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? enableHostMessage = null,Object? gameId = freezed,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,launchStrategy: null == launchStrategy ? _self.launchStrategy : launchStrategy // ignore: cast_nullable_to_non_nullable
as GameLaunchStrategy,baseUrlKey: freezed == baseUrlKey ? _self.baseUrlKey : baseUrlKey // ignore: cast_nullable_to_non_nullable
as String?,mobileOrientation: null == mobileOrientation ? _self.mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,tabletOrientation: null == tabletOrientation ? _self.tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,desktopOrientation: null == desktopOrientation ? _self.desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,enableHostMessage: null == enableHostMessage ? _self.enableHostMessage : enableHostMessage // ignore: cast_nullable_to_non_nullable
as bool,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [InHouseGame].
extension InHouseGamePatterns on InHouseGame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InHouseGame value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InHouseGame() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InHouseGame value)  $default,){
final _that = this;
switch (_that) {
case _InHouseGame():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InHouseGame value)?  $default,){
final _that = this;
switch (_that) {
case _InHouseGame() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'game_code')  String gameCode, @JsonKey(name: 'game_name')  String gameName, @JsonKey(name: 'provider_id')  String providerId, @JsonKey(name: 'provider_name')  String providerName, @JsonKey(name: 'image')  String image, @JsonKey(name: 'lang')  String lang, @JsonKey(name: 'game_type')  GameType gameType, @JsonKey(name: 'launch_strategy')  GameLaunchStrategy launchStrategy, @JsonKey(name: 'base_url_key')  String? baseUrlKey, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter()  List<GameOrientation> mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter()  List<GameOrientation> tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter()  List<GameOrientation> desktopOrientation, @JsonKey(name: 'enable_host_message')  bool enableHostMessage, @JsonKey(name: 'game_id')  int? gameId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InHouseGame() when $default != null:
return $default(_that.productId,_that.gameCode,_that.gameName,_that.providerId,_that.providerName,_that.image,_that.lang,_that.gameType,_that.launchStrategy,_that.baseUrlKey,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.enableHostMessage,_that.gameId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'game_code')  String gameCode, @JsonKey(name: 'game_name')  String gameName, @JsonKey(name: 'provider_id')  String providerId, @JsonKey(name: 'provider_name')  String providerName, @JsonKey(name: 'image')  String image, @JsonKey(name: 'lang')  String lang, @JsonKey(name: 'game_type')  GameType gameType, @JsonKey(name: 'launch_strategy')  GameLaunchStrategy launchStrategy, @JsonKey(name: 'base_url_key')  String? baseUrlKey, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter()  List<GameOrientation> mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter()  List<GameOrientation> tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter()  List<GameOrientation> desktopOrientation, @JsonKey(name: 'enable_host_message')  bool enableHostMessage, @JsonKey(name: 'game_id')  int? gameId)  $default,) {final _that = this;
switch (_that) {
case _InHouseGame():
return $default(_that.productId,_that.gameCode,_that.gameName,_that.providerId,_that.providerName,_that.image,_that.lang,_that.gameType,_that.launchStrategy,_that.baseUrlKey,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.enableHostMessage,_that.gameId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'game_code')  String gameCode, @JsonKey(name: 'game_name')  String gameName, @JsonKey(name: 'provider_id')  String providerId, @JsonKey(name: 'provider_name')  String providerName, @JsonKey(name: 'image')  String image, @JsonKey(name: 'lang')  String lang, @JsonKey(name: 'game_type')  GameType gameType, @JsonKey(name: 'launch_strategy')  GameLaunchStrategy launchStrategy, @JsonKey(name: 'base_url_key')  String? baseUrlKey, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter()  List<GameOrientation> mobileOrientation, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter()  List<GameOrientation> tabletOrientation, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter()  List<GameOrientation> desktopOrientation, @JsonKey(name: 'enable_host_message')  bool enableHostMessage, @JsonKey(name: 'game_id')  int? gameId)?  $default,) {final _that = this;
switch (_that) {
case _InHouseGame() when $default != null:
return $default(_that.productId,_that.gameCode,_that.gameName,_that.providerId,_that.providerName,_that.image,_that.lang,_that.gameType,_that.launchStrategy,_that.baseUrlKey,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.enableHostMessage,_that.gameId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InHouseGame implements InHouseGame {
  const _InHouseGame({@JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'game_code') required this.gameCode, @JsonKey(name: 'game_name') required this.gameName, @JsonKey(name: 'provider_id') required this.providerId, @JsonKey(name: 'provider_name') required this.providerName, @JsonKey(name: 'image') required this.image, @JsonKey(name: 'lang') required this.lang, @JsonKey(name: 'game_type') required this.gameType, @JsonKey(name: 'launch_strategy') required this.launchStrategy, @JsonKey(name: 'base_url_key') this.baseUrlKey, @JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() final  List<GameOrientation> mobileOrientation = GameOrientation.landscape, @JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() final  List<GameOrientation> tabletOrientation = GameOrientation.landscape, @JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() final  List<GameOrientation> desktopOrientation = GameOrientation.landscape, @JsonKey(name: 'enable_host_message') this.enableHostMessage = true, @JsonKey(name: 'game_id') this.gameId}): _mobileOrientation = mobileOrientation,_tabletOrientation = tabletOrientation,_desktopOrientation = desktopOrientation;
  factory _InHouseGame.fromJson(Map<String, dynamic> json) => _$InHouseGameFromJson(json);

/// Unique product identifier (e.g., 'sunwin_AVENGER').
@override@JsonKey(name: 'product_id') final  String productId;
/// Unique short code for the game (e.g., 'AVENGER').
@override@JsonKey(name: 'game_code') final  String gameCode;
/// Human-readable name of the game.
@override@JsonKey(name: 'game_name') final  String gameName;
/// Unique id of the provider.
@override@JsonKey(name: 'provider_id') final  String providerId;
/// Human-readable name of the provider.
@override@JsonKey(name: 'provider_name') final  String providerName;
/// File path or name for the game thumbnail.
@override@JsonKey(name: 'image') final  String image;
/// Language code to be used in the launch URL.
@override@JsonKey(name: 'lang') final  String lang;
/// Categorization of the game.
@override@JsonKey(name: 'game_type') final  GameType gameType;
/// Execution strategy for launching the game.
@override@JsonKey(name: 'launch_strategy') final  GameLaunchStrategy launchStrategy;
/// Key used to resolve the base URL from environments.
@override@JsonKey(name: 'base_url_key') final  String? baseUrlKey;
/// Screen orientations supported on mobile devices.
 final  List<GameOrientation> _mobileOrientation;
/// Screen orientations supported on mobile devices.
@override@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation> get mobileOrientation {
  if (_mobileOrientation is EqualUnmodifiableListView) return _mobileOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mobileOrientation);
}

/// Screen orientations supported on tablets.
 final  List<GameOrientation> _tabletOrientation;
/// Screen orientations supported on tablets.
@override@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation> get tabletOrientation {
  if (_tabletOrientation is EqualUnmodifiableListView) return _tabletOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabletOrientation);
}

/// Screen orientations supported on desktop.
 final  List<GameOrientation> _desktopOrientation;
/// Screen orientations supported on desktop.
@override@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation> get desktopOrientation {
  if (_desktopOrientation is EqualUnmodifiableListView) return _desktopOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desktopOrientation);
}

/// Whether to enable bidirectional messaging between JS and Flutter.
@override@JsonKey(name: 'enable_host_message') final  bool enableHostMessage;
/// Optional specific game identifier for internal provider systems.
@override@JsonKey(name: 'game_id') final  int? gameId;

/// Create a copy of InHouseGame
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InHouseGameCopyWith<_InHouseGame> get copyWith => __$InHouseGameCopyWithImpl<_InHouseGame>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InHouseGameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InHouseGame&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.launchStrategy, launchStrategy) || other.launchStrategy == launchStrategy)&&(identical(other.baseUrlKey, baseUrlKey) || other.baseUrlKey == baseUrlKey)&&const DeepCollectionEquality().equals(other._mobileOrientation, _mobileOrientation)&&const DeepCollectionEquality().equals(other._tabletOrientation, _tabletOrientation)&&const DeepCollectionEquality().equals(other._desktopOrientation, _desktopOrientation)&&(identical(other.enableHostMessage, enableHostMessage) || other.enableHostMessage == enableHostMessage)&&(identical(other.gameId, gameId) || other.gameId == gameId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,gameCode,gameName,providerId,providerName,image,lang,gameType,launchStrategy,baseUrlKey,const DeepCollectionEquality().hash(_mobileOrientation),const DeepCollectionEquality().hash(_tabletOrientation),const DeepCollectionEquality().hash(_desktopOrientation),enableHostMessage,gameId);

@override
String toString() {
  return 'InHouseGame(productId: $productId, gameCode: $gameCode, gameName: $gameName, providerId: $providerId, providerName: $providerName, image: $image, lang: $lang, gameType: $gameType, launchStrategy: $launchStrategy, baseUrlKey: $baseUrlKey, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, enableHostMessage: $enableHostMessage, gameId: $gameId)';
}


}

/// @nodoc
abstract mixin class _$InHouseGameCopyWith<$Res> implements $InHouseGameCopyWith<$Res> {
  factory _$InHouseGameCopyWith(_InHouseGame value, $Res Function(_InHouseGame) _then) = __$InHouseGameCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'game_code') String gameCode,@JsonKey(name: 'game_name') String gameName,@JsonKey(name: 'provider_id') String providerId,@JsonKey(name: 'provider_name') String providerName,@JsonKey(name: 'image') String image,@JsonKey(name: 'lang') String lang,@JsonKey(name: 'game_type') GameType gameType,@JsonKey(name: 'launch_strategy') GameLaunchStrategy launchStrategy,@JsonKey(name: 'base_url_key') String? baseUrlKey,@JsonKey(name: 'mobile_orientation')@GameOrientationListConverter() List<GameOrientation> mobileOrientation,@JsonKey(name: 'tablet_orientation')@GameOrientationListConverter() List<GameOrientation> tabletOrientation,@JsonKey(name: 'desktop_orientation')@GameOrientationListConverter() List<GameOrientation> desktopOrientation,@JsonKey(name: 'enable_host_message') bool enableHostMessage,@JsonKey(name: 'game_id') int? gameId
});




}
/// @nodoc
class __$InHouseGameCopyWithImpl<$Res>
    implements _$InHouseGameCopyWith<$Res> {
  __$InHouseGameCopyWithImpl(this._self, this._then);

  final _InHouseGame _self;
  final $Res Function(_InHouseGame) _then;

/// Create a copy of InHouseGame
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? providerId = null,Object? providerName = null,Object? image = null,Object? lang = null,Object? gameType = null,Object? launchStrategy = null,Object? baseUrlKey = freezed,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? enableHostMessage = null,Object? gameId = freezed,}) {
  return _then(_InHouseGame(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,launchStrategy: null == launchStrategy ? _self.launchStrategy : launchStrategy // ignore: cast_nullable_to_non_nullable
as GameLaunchStrategy,baseUrlKey: freezed == baseUrlKey ? _self.baseUrlKey : baseUrlKey // ignore: cast_nullable_to_non_nullable
as String?,mobileOrientation: null == mobileOrientation ? _self._mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,tabletOrientation: null == tabletOrientation ? _self._tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,desktopOrientation: null == desktopOrientation ? _self._desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,enableHostMessage: null == enableHostMessage ? _self.enableHostMessage : enableHostMessage // ignore: cast_nullable_to_non_nullable
as bool,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
