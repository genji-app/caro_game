// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameBlock {

// --- provider data & resolved image ---
 String get providerId; String get providerName; String get image;// --- core game data ---
 String get productId; String get gameCode; String get gameName; String get lang; String get lobbyUrl; String get cashierUrl; GameType get gameType; bool get mobileLogin; List<GameOrientation> get mobileOrientation; List<GameOrientation> get tabletOrientation; List<GameOrientation> get desktopOrientation; bool get forceLandscapeViewportOnIpad;/// Determines whether this game should be opened in a new tab to avoid crashes.
///
/// Context: Some providers (e.g., Sexy/amb-vn) utilize resource-intensive
/// WebGL and live video. When loaded inside an iframe on iPhone Safari, they
/// share a ~1GB-limited WebContent process with Flutter's CanvasKit,
/// ultimately causing Safari to force-kill the webpage. Opening in a new tab
/// gives the game an isolated process with independent GPU and memory pool.
///
/// **Design Note:** This flag should be set to `true` for heavy games.
/// The UI presentation layer (GamePlayerScreen) combines this flag with
/// `isIOSSafariWeb`. Thus, even if `true`, lighter environments (PC, Android)
/// will still seamlessly open the game in an iframe, and only Safari iPhone
/// will trigger the new-tab fallback.
 bool get openInNewTabOnIOSSafariWeb;/// Whether this game requires a session cooldown guard before launching.
///
/// Some providers (e.g. SEXY/amb-vn) maintain a single active session
/// per player server-side. Opening a new game before the previous session
/// is released causes error 1028 ("Unable to proceed").
/// When `true`, [GamePlayerScreen.push] enforces a cooldown between launches.
 bool get requiresSessionGuard;/// Whether this game enables host message channel.
 bool get enableHostMessage;/// Whether this game belongs to an in-house provider (e.g., Sunwin, X88).
///
/// In-house games are typically internal developments that require
/// specialized runners (like IHRunner) and specific event handling
/// compared to third-party integrated games.
 bool get isInHouseGame;/// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
 Duration? get loadStopDebounce;
/// Create a copy of GameBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameBlockCopyWith<GameBlock> get copyWith => _$GameBlockCopyWithImpl<GameBlock>(this as GameBlock, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameBlock&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.lobbyUrl, lobbyUrl) || other.lobbyUrl == lobbyUrl)&&(identical(other.cashierUrl, cashierUrl) || other.cashierUrl == cashierUrl)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.mobileLogin, mobileLogin) || other.mobileLogin == mobileLogin)&&const DeepCollectionEquality().equals(other.mobileOrientation, mobileOrientation)&&const DeepCollectionEquality().equals(other.tabletOrientation, tabletOrientation)&&const DeepCollectionEquality().equals(other.desktopOrientation, desktopOrientation)&&(identical(other.forceLandscapeViewportOnIpad, forceLandscapeViewportOnIpad) || other.forceLandscapeViewportOnIpad == forceLandscapeViewportOnIpad)&&(identical(other.openInNewTabOnIOSSafariWeb, openInNewTabOnIOSSafariWeb) || other.openInNewTabOnIOSSafariWeb == openInNewTabOnIOSSafariWeb)&&(identical(other.requiresSessionGuard, requiresSessionGuard) || other.requiresSessionGuard == requiresSessionGuard)&&(identical(other.enableHostMessage, enableHostMessage) || other.enableHostMessage == enableHostMessage)&&(identical(other.isInHouseGame, isInHouseGame) || other.isInHouseGame == isInHouseGame)&&(identical(other.loadStopDebounce, loadStopDebounce) || other.loadStopDebounce == loadStopDebounce));
}


@override
int get hashCode => Object.hashAll([runtimeType,providerId,providerName,image,productId,gameCode,gameName,lang,lobbyUrl,cashierUrl,gameType,mobileLogin,const DeepCollectionEquality().hash(mobileOrientation),const DeepCollectionEquality().hash(tabletOrientation),const DeepCollectionEquality().hash(desktopOrientation),forceLandscapeViewportOnIpad,openInNewTabOnIOSSafariWeb,requiresSessionGuard,enableHostMessage,isInHouseGame,loadStopDebounce]);

@override
String toString() {
  return 'GameBlock(providerId: $providerId, providerName: $providerName, image: $image, productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, gameType: $gameType, mobileLogin: $mobileLogin, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, forceLandscapeViewportOnIpad: $forceLandscapeViewportOnIpad, openInNewTabOnIOSSafariWeb: $openInNewTabOnIOSSafariWeb, requiresSessionGuard: $requiresSessionGuard, enableHostMessage: $enableHostMessage, isInHouseGame: $isInHouseGame, loadStopDebounce: $loadStopDebounce)';
}


}

/// @nodoc
abstract mixin class $GameBlockCopyWith<$Res>  {
  factory $GameBlockCopyWith(GameBlock value, $Res Function(GameBlock) _then) = _$GameBlockCopyWithImpl;
@useResult
$Res call({
 String providerId, String providerName, String image, String productId, String gameCode, String gameName, String lang, String lobbyUrl, String cashierUrl, GameType gameType, bool mobileLogin, List<GameOrientation> mobileOrientation, List<GameOrientation> tabletOrientation, List<GameOrientation> desktopOrientation, bool forceLandscapeViewportOnIpad, bool openInNewTabOnIOSSafariWeb, bool requiresSessionGuard, bool enableHostMessage, bool isInHouseGame, Duration? loadStopDebounce
});




}
/// @nodoc
class _$GameBlockCopyWithImpl<$Res>
    implements $GameBlockCopyWith<$Res> {
  _$GameBlockCopyWithImpl(this._self, this._then);

  final GameBlock _self;
  final $Res Function(GameBlock) _then;

/// Create a copy of GameBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? providerName = null,Object? image = null,Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? lobbyUrl = null,Object? cashierUrl = null,Object? gameType = null,Object? mobileLogin = null,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? forceLandscapeViewportOnIpad = null,Object? openInNewTabOnIOSSafariWeb = null,Object? requiresSessionGuard = null,Object? enableHostMessage = null,Object? isInHouseGame = null,Object? loadStopDebounce = freezed,}) {
  return _then(_self.copyWith(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,lobbyUrl: null == lobbyUrl ? _self.lobbyUrl : lobbyUrl // ignore: cast_nullable_to_non_nullable
as String,cashierUrl: null == cashierUrl ? _self.cashierUrl : cashierUrl // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,mobileLogin: null == mobileLogin ? _self.mobileLogin : mobileLogin // ignore: cast_nullable_to_non_nullable
as bool,mobileOrientation: null == mobileOrientation ? _self.mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,tabletOrientation: null == tabletOrientation ? _self.tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,desktopOrientation: null == desktopOrientation ? _self.desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,forceLandscapeViewportOnIpad: null == forceLandscapeViewportOnIpad ? _self.forceLandscapeViewportOnIpad : forceLandscapeViewportOnIpad // ignore: cast_nullable_to_non_nullable
as bool,openInNewTabOnIOSSafariWeb: null == openInNewTabOnIOSSafariWeb ? _self.openInNewTabOnIOSSafariWeb : openInNewTabOnIOSSafariWeb // ignore: cast_nullable_to_non_nullable
as bool,requiresSessionGuard: null == requiresSessionGuard ? _self.requiresSessionGuard : requiresSessionGuard // ignore: cast_nullable_to_non_nullable
as bool,enableHostMessage: null == enableHostMessage ? _self.enableHostMessage : enableHostMessage // ignore: cast_nullable_to_non_nullable
as bool,isInHouseGame: null == isInHouseGame ? _self.isInHouseGame : isInHouseGame // ignore: cast_nullable_to_non_nullable
as bool,loadStopDebounce: freezed == loadStopDebounce ? _self.loadStopDebounce : loadStopDebounce // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [GameBlock].
extension GameBlockPatterns on GameBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameBlock value)  $default,){
final _that = this;
switch (_that) {
case _GameBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameBlock value)?  $default,){
final _that = this;
switch (_that) {
case _GameBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang,  String lobbyUrl,  String cashierUrl,  GameType gameType,  bool mobileLogin,  List<GameOrientation> mobileOrientation,  List<GameOrientation> tabletOrientation,  List<GameOrientation> desktopOrientation,  bool forceLandscapeViewportOnIpad,  bool openInNewTabOnIOSSafariWeb,  bool requiresSessionGuard,  bool enableHostMessage,  bool isInHouseGame,  Duration? loadStopDebounce)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameBlock() when $default != null:
return $default(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.lobbyUrl,_that.cashierUrl,_that.gameType,_that.mobileLogin,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard,_that.enableHostMessage,_that.isInHouseGame,_that.loadStopDebounce);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang,  String lobbyUrl,  String cashierUrl,  GameType gameType,  bool mobileLogin,  List<GameOrientation> mobileOrientation,  List<GameOrientation> tabletOrientation,  List<GameOrientation> desktopOrientation,  bool forceLandscapeViewportOnIpad,  bool openInNewTabOnIOSSafariWeb,  bool requiresSessionGuard,  bool enableHostMessage,  bool isInHouseGame,  Duration? loadStopDebounce)  $default,) {final _that = this;
switch (_that) {
case _GameBlock():
return $default(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.lobbyUrl,_that.cashierUrl,_that.gameType,_that.mobileLogin,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard,_that.enableHostMessage,_that.isInHouseGame,_that.loadStopDebounce);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang,  String lobbyUrl,  String cashierUrl,  GameType gameType,  bool mobileLogin,  List<GameOrientation> mobileOrientation,  List<GameOrientation> tabletOrientation,  List<GameOrientation> desktopOrientation,  bool forceLandscapeViewportOnIpad,  bool openInNewTabOnIOSSafariWeb,  bool requiresSessionGuard,  bool enableHostMessage,  bool isInHouseGame,  Duration? loadStopDebounce)?  $default,) {final _that = this;
switch (_that) {
case _GameBlock() when $default != null:
return $default(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.lobbyUrl,_that.cashierUrl,_that.gameType,_that.mobileLogin,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard,_that.enableHostMessage,_that.isInHouseGame,_that.loadStopDebounce);case _:
  return null;

}
}

}

/// @nodoc


class _GameBlock implements GameBlock {
  const _GameBlock({required this.providerId, required this.providerName, required this.image, required this.productId, required this.gameCode, required this.gameName, required this.lang, required this.lobbyUrl, required this.cashierUrl, required this.gameType, this.mobileLogin = false, final  List<GameOrientation> mobileOrientation = GameOrientation.portrait, final  List<GameOrientation> tabletOrientation = GameOrientation.landscape, final  List<GameOrientation> desktopOrientation = GameOrientation.all, this.forceLandscapeViewportOnIpad = false, this.openInNewTabOnIOSSafariWeb = false, this.requiresSessionGuard = false, this.enableHostMessage = false, this.isInHouseGame = false, this.loadStopDebounce}): _mobileOrientation = mobileOrientation,_tabletOrientation = tabletOrientation,_desktopOrientation = desktopOrientation;
  

// --- provider data & resolved image ---
@override final  String providerId;
@override final  String providerName;
@override final  String image;
// --- core game data ---
@override final  String productId;
@override final  String gameCode;
@override final  String gameName;
@override final  String lang;
@override final  String lobbyUrl;
@override final  String cashierUrl;
@override final  GameType gameType;
@override@JsonKey() final  bool mobileLogin;
 final  List<GameOrientation> _mobileOrientation;
@override@JsonKey() List<GameOrientation> get mobileOrientation {
  if (_mobileOrientation is EqualUnmodifiableListView) return _mobileOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mobileOrientation);
}

 final  List<GameOrientation> _tabletOrientation;
@override@JsonKey() List<GameOrientation> get tabletOrientation {
  if (_tabletOrientation is EqualUnmodifiableListView) return _tabletOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabletOrientation);
}

 final  List<GameOrientation> _desktopOrientation;
@override@JsonKey() List<GameOrientation> get desktopOrientation {
  if (_desktopOrientation is EqualUnmodifiableListView) return _desktopOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desktopOrientation);
}

@override@JsonKey() final  bool forceLandscapeViewportOnIpad;
/// Determines whether this game should be opened in a new tab to avoid crashes.
///
/// Context: Some providers (e.g., Sexy/amb-vn) utilize resource-intensive
/// WebGL and live video. When loaded inside an iframe on iPhone Safari, they
/// share a ~1GB-limited WebContent process with Flutter's CanvasKit,
/// ultimately causing Safari to force-kill the webpage. Opening in a new tab
/// gives the game an isolated process with independent GPU and memory pool.
///
/// **Design Note:** This flag should be set to `true` for heavy games.
/// The UI presentation layer (GamePlayerScreen) combines this flag with
/// `isIOSSafariWeb`. Thus, even if `true`, lighter environments (PC, Android)
/// will still seamlessly open the game in an iframe, and only Safari iPhone
/// will trigger the new-tab fallback.
@override@JsonKey() final  bool openInNewTabOnIOSSafariWeb;
/// Whether this game requires a session cooldown guard before launching.
///
/// Some providers (e.g. SEXY/amb-vn) maintain a single active session
/// per player server-side. Opening a new game before the previous session
/// is released causes error 1028 ("Unable to proceed").
/// When `true`, [GamePlayerScreen.push] enforces a cooldown between launches.
@override@JsonKey() final  bool requiresSessionGuard;
/// Whether this game enables host message channel.
@override@JsonKey() final  bool enableHostMessage;
/// Whether this game belongs to an in-house provider (e.g., Sunwin, X88).
///
/// In-house games are typically internal developments that require
/// specialized runners (like IHRunner) and specific event handling
/// compared to third-party integrated games.
@override@JsonKey() final  bool isInHouseGame;
/// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
@override final  Duration? loadStopDebounce;

/// Create a copy of GameBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameBlockCopyWith<_GameBlock> get copyWith => __$GameBlockCopyWithImpl<_GameBlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameBlock&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.lobbyUrl, lobbyUrl) || other.lobbyUrl == lobbyUrl)&&(identical(other.cashierUrl, cashierUrl) || other.cashierUrl == cashierUrl)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.mobileLogin, mobileLogin) || other.mobileLogin == mobileLogin)&&const DeepCollectionEquality().equals(other._mobileOrientation, _mobileOrientation)&&const DeepCollectionEquality().equals(other._tabletOrientation, _tabletOrientation)&&const DeepCollectionEquality().equals(other._desktopOrientation, _desktopOrientation)&&(identical(other.forceLandscapeViewportOnIpad, forceLandscapeViewportOnIpad) || other.forceLandscapeViewportOnIpad == forceLandscapeViewportOnIpad)&&(identical(other.openInNewTabOnIOSSafariWeb, openInNewTabOnIOSSafariWeb) || other.openInNewTabOnIOSSafariWeb == openInNewTabOnIOSSafariWeb)&&(identical(other.requiresSessionGuard, requiresSessionGuard) || other.requiresSessionGuard == requiresSessionGuard)&&(identical(other.enableHostMessage, enableHostMessage) || other.enableHostMessage == enableHostMessage)&&(identical(other.isInHouseGame, isInHouseGame) || other.isInHouseGame == isInHouseGame)&&(identical(other.loadStopDebounce, loadStopDebounce) || other.loadStopDebounce == loadStopDebounce));
}


@override
int get hashCode => Object.hashAll([runtimeType,providerId,providerName,image,productId,gameCode,gameName,lang,lobbyUrl,cashierUrl,gameType,mobileLogin,const DeepCollectionEquality().hash(_mobileOrientation),const DeepCollectionEquality().hash(_tabletOrientation),const DeepCollectionEquality().hash(_desktopOrientation),forceLandscapeViewportOnIpad,openInNewTabOnIOSSafariWeb,requiresSessionGuard,enableHostMessage,isInHouseGame,loadStopDebounce]);

@override
String toString() {
  return 'GameBlock(providerId: $providerId, providerName: $providerName, image: $image, productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, gameType: $gameType, mobileLogin: $mobileLogin, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, forceLandscapeViewportOnIpad: $forceLandscapeViewportOnIpad, openInNewTabOnIOSSafariWeb: $openInNewTabOnIOSSafariWeb, requiresSessionGuard: $requiresSessionGuard, enableHostMessage: $enableHostMessage, isInHouseGame: $isInHouseGame, loadStopDebounce: $loadStopDebounce)';
}


}

/// @nodoc
abstract mixin class _$GameBlockCopyWith<$Res> implements $GameBlockCopyWith<$Res> {
  factory _$GameBlockCopyWith(_GameBlock value, $Res Function(_GameBlock) _then) = __$GameBlockCopyWithImpl;
@override @useResult
$Res call({
 String providerId, String providerName, String image, String productId, String gameCode, String gameName, String lang, String lobbyUrl, String cashierUrl, GameType gameType, bool mobileLogin, List<GameOrientation> mobileOrientation, List<GameOrientation> tabletOrientation, List<GameOrientation> desktopOrientation, bool forceLandscapeViewportOnIpad, bool openInNewTabOnIOSSafariWeb, bool requiresSessionGuard, bool enableHostMessage, bool isInHouseGame, Duration? loadStopDebounce
});




}
/// @nodoc
class __$GameBlockCopyWithImpl<$Res>
    implements _$GameBlockCopyWith<$Res> {
  __$GameBlockCopyWithImpl(this._self, this._then);

  final _GameBlock _self;
  final $Res Function(_GameBlock) _then;

/// Create a copy of GameBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? providerName = null,Object? image = null,Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? lobbyUrl = null,Object? cashierUrl = null,Object? gameType = null,Object? mobileLogin = null,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? forceLandscapeViewportOnIpad = null,Object? openInNewTabOnIOSSafariWeb = null,Object? requiresSessionGuard = null,Object? enableHostMessage = null,Object? isInHouseGame = null,Object? loadStopDebounce = freezed,}) {
  return _then(_GameBlock(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,lobbyUrl: null == lobbyUrl ? _self.lobbyUrl : lobbyUrl // ignore: cast_nullable_to_non_nullable
as String,cashierUrl: null == cashierUrl ? _self.cashierUrl : cashierUrl // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as GameType,mobileLogin: null == mobileLogin ? _self.mobileLogin : mobileLogin // ignore: cast_nullable_to_non_nullable
as bool,mobileOrientation: null == mobileOrientation ? _self._mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,tabletOrientation: null == tabletOrientation ? _self._tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,desktopOrientation: null == desktopOrientation ? _self._desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,forceLandscapeViewportOnIpad: null == forceLandscapeViewportOnIpad ? _self.forceLandscapeViewportOnIpad : forceLandscapeViewportOnIpad // ignore: cast_nullable_to_non_nullable
as bool,openInNewTabOnIOSSafariWeb: null == openInNewTabOnIOSSafariWeb ? _self.openInNewTabOnIOSSafariWeb : openInNewTabOnIOSSafariWeb // ignore: cast_nullable_to_non_nullable
as bool,requiresSessionGuard: null == requiresSessionGuard ? _self.requiresSessionGuard : requiresSessionGuard // ignore: cast_nullable_to_non_nullable
as bool,enableHostMessage: null == enableHostMessage ? _self.enableHostMessage : enableHostMessage // ignore: cast_nullable_to_non_nullable
as bool,isInHouseGame: null == isInHouseGame ? _self.isInHouseGame : isInHouseGame // ignore: cast_nullable_to_non_nullable
as bool,loadStopDebounce: freezed == loadStopDebounce ? _self.loadStopDebounce : loadStopDebounce // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
