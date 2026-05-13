// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caxilo_game_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
CaxiloGameBlock _$CaxiloGameBlockFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'liveStream':
          return CaxiloGameBlockLiveStream.fromJson(
            json
          );
                case 'inHouse':
          return CaxiloGameBlockInHouse.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'CaxiloGameBlock',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$CaxiloGameBlock {

// --- provider data & resolved image ---
/// The unique id of the provider (e.g. `amb-vn`, `vivo`, `sunwin`)
 String get providerId;/// The human-readable name of the provider.
 String get providerName;/// The resolved image path or name for the game thumbnail.
 String get image;// --- core game data ---
/// The specific product API identifier (e.g., 'SEXY', 'EVO').
 String get productId;/// The specific unique code for this game within the provider.
 String get gameCode;/// The human-readable name of the game.
 String get gameName;/// The required language code for the game url.
 String get lang;/// The generic category of this game (e.g. slot, live, sport).
@JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) caxiloconfig.GameType get gameType;/// Allowed orientations on mobile phones.
@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get mobileOrientation;/// Allowed orientations on tablets.
@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get tabletOrientation;/// Allowed orientations on desktops.
@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get desktopOrientation;/// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
 Duration? get loadStopDebounce;/// Determines the order in which this game is displayed relative to others.
 int get sortOrder;
/// Create a copy of CaxiloGameBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloGameBlockCopyWith<CaxiloGameBlock> get copyWith => _$CaxiloGameBlockCopyWithImpl<CaxiloGameBlock>(this as CaxiloGameBlock, _$identity);

  /// Serializes this CaxiloGameBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloGameBlock&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&const DeepCollectionEquality().equals(other.mobileOrientation, mobileOrientation)&&const DeepCollectionEquality().equals(other.tabletOrientation, tabletOrientation)&&const DeepCollectionEquality().equals(other.desktopOrientation, desktopOrientation)&&(identical(other.loadStopDebounce, loadStopDebounce) || other.loadStopDebounce == loadStopDebounce)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,providerName,image,productId,gameCode,gameName,lang,gameType,const DeepCollectionEquality().hash(mobileOrientation),const DeepCollectionEquality().hash(tabletOrientation),const DeepCollectionEquality().hash(desktopOrientation),loadStopDebounce,sortOrder);

@override
String toString() {
  return 'CaxiloGameBlock(providerId: $providerId, providerName: $providerName, image: $image, productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, gameType: $gameType, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, loadStopDebounce: $loadStopDebounce, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $CaxiloGameBlockCopyWith<$Res>  {
  factory $CaxiloGameBlockCopyWith(CaxiloGameBlock value, $Res Function(CaxiloGameBlock) _then) = _$CaxiloGameBlockCopyWithImpl;
@useResult
$Res call({
 String providerId, String providerName, String image, String productId, String gameCode, String gameName, String lang,@JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) caxiloconfig.GameType gameType,@GameOrientationListConverter() List<GameOrientation> mobileOrientation,@GameOrientationListConverter() List<GameOrientation> tabletOrientation,@GameOrientationListConverter() List<GameOrientation> desktopOrientation, Duration? loadStopDebounce, int sortOrder
});




}
/// @nodoc
class _$CaxiloGameBlockCopyWithImpl<$Res>
    implements $CaxiloGameBlockCopyWith<$Res> {
  _$CaxiloGameBlockCopyWithImpl(this._self, this._then);

  final CaxiloGameBlock _self;
  final $Res Function(CaxiloGameBlock) _then;

/// Create a copy of CaxiloGameBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? providerName = null,Object? image = null,Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? gameType = null,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? loadStopDebounce = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as caxiloconfig.GameType,mobileOrientation: null == mobileOrientation ? _self.mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,tabletOrientation: null == tabletOrientation ? _self.tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,desktopOrientation: null == desktopOrientation ? _self.desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<GameOrientation>,loadStopDebounce: freezed == loadStopDebounce ? _self.loadStopDebounce : loadStopDebounce // ignore: cast_nullable_to_non_nullable
as Duration?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CaxiloGameBlock].
extension CaxiloGameBlockPatterns on CaxiloGameBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CaxiloGameBlockLiveStream value)?  liveStream,TResult Function( CaxiloGameBlockInHouse value)?  inHouse,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CaxiloGameBlockLiveStream() when liveStream != null:
return liveStream(_that);case CaxiloGameBlockInHouse() when inHouse != null:
return inHouse(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CaxiloGameBlockLiveStream value)  liveStream,required TResult Function( CaxiloGameBlockInHouse value)  inHouse,}){
final _that = this;
switch (_that) {
case CaxiloGameBlockLiveStream():
return liveStream(_that);case CaxiloGameBlockInHouse():
return inHouse(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CaxiloGameBlockLiveStream value)?  liveStream,TResult? Function( CaxiloGameBlockInHouse value)?  inHouse,}){
final _that = this;
switch (_that) {
case CaxiloGameBlockLiveStream() when liveStream != null:
return liveStream(_that);case CaxiloGameBlockInHouse() when inHouse != null:
return inHouse(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)  caxiloconfig.GameType gameType,  String lobbyUrl,  String cashierUrl,  bool mobileLogin, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> mobileOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> tabletOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> desktopOrientation,  Duration? loadStopDebounce,  int sortOrder,  bool forceLandscapeViewportOnIpad,  bool openInNewTabOnIOSSafariWeb,  bool requiresSessionGuard)?  liveStream,TResult Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)  caxiloconfig.GameType gameType, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> mobileOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> tabletOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> desktopOrientation,  Duration? loadStopDebounce,  int sortOrder,  bool enableHostMessage)?  inHouse,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CaxiloGameBlockLiveStream() when liveStream != null:
return liveStream(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.gameType,_that.lobbyUrl,_that.cashierUrl,_that.mobileLogin,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.loadStopDebounce,_that.sortOrder,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard);case CaxiloGameBlockInHouse() when inHouse != null:
return inHouse(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.gameType,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.loadStopDebounce,_that.sortOrder,_that.enableHostMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)  caxiloconfig.GameType gameType,  String lobbyUrl,  String cashierUrl,  bool mobileLogin, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> mobileOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> tabletOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> desktopOrientation,  Duration? loadStopDebounce,  int sortOrder,  bool forceLandscapeViewportOnIpad,  bool openInNewTabOnIOSSafariWeb,  bool requiresSessionGuard)  liveStream,required TResult Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)  caxiloconfig.GameType gameType, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> mobileOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> tabletOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> desktopOrientation,  Duration? loadStopDebounce,  int sortOrder,  bool enableHostMessage)  inHouse,}) {final _that = this;
switch (_that) {
case CaxiloGameBlockLiveStream():
return liveStream(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.gameType,_that.lobbyUrl,_that.cashierUrl,_that.mobileLogin,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.loadStopDebounce,_that.sortOrder,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard);case CaxiloGameBlockInHouse():
return inHouse(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.gameType,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.loadStopDebounce,_that.sortOrder,_that.enableHostMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)  caxiloconfig.GameType gameType,  String lobbyUrl,  String cashierUrl,  bool mobileLogin, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> mobileOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> tabletOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> desktopOrientation,  Duration? loadStopDebounce,  int sortOrder,  bool forceLandscapeViewportOnIpad,  bool openInNewTabOnIOSSafariWeb,  bool requiresSessionGuard)?  liveStream,TResult? Function( String providerId,  String providerName,  String image,  String productId,  String gameCode,  String gameName,  String lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)  caxiloconfig.GameType gameType, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> mobileOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> tabletOrientation, @GameOrientationListConverter()  List<caxiloconfig.GameOrientation> desktopOrientation,  Duration? loadStopDebounce,  int sortOrder,  bool enableHostMessage)?  inHouse,}) {final _that = this;
switch (_that) {
case CaxiloGameBlockLiveStream() when liveStream != null:
return liveStream(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.gameType,_that.lobbyUrl,_that.cashierUrl,_that.mobileLogin,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.loadStopDebounce,_that.sortOrder,_that.forceLandscapeViewportOnIpad,_that.openInNewTabOnIOSSafariWeb,_that.requiresSessionGuard);case CaxiloGameBlockInHouse() when inHouse != null:
return inHouse(_that.providerId,_that.providerName,_that.image,_that.productId,_that.gameCode,_that.gameName,_that.lang,_that.gameType,_that.mobileOrientation,_that.tabletOrientation,_that.desktopOrientation,_that.loadStopDebounce,_that.sortOrder,_that.enableHostMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CaxiloGameBlockLiveStream implements CaxiloGameBlock {
  const CaxiloGameBlockLiveStream({required this.providerId, required this.providerName, required this.image, required this.productId, required this.gameCode, required this.gameName, required this.lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) required this.gameType, required this.lobbyUrl, required this.cashierUrl, this.mobileLogin = false, @GameOrientationListConverter() final  List<caxiloconfig.GameOrientation> mobileOrientation = caxiloconfig.GameOrientation.portrait, @GameOrientationListConverter() final  List<caxiloconfig.GameOrientation> tabletOrientation = caxiloconfig.GameOrientation.landscape, @GameOrientationListConverter() final  List<caxiloconfig.GameOrientation> desktopOrientation = caxiloconfig.GameOrientation.all, this.loadStopDebounce, this.sortOrder = 999, this.forceLandscapeViewportOnIpad = false, this.openInNewTabOnIOSSafariWeb = false, this.requiresSessionGuard = false, final  String? $type}): _mobileOrientation = mobileOrientation,_tabletOrientation = tabletOrientation,_desktopOrientation = desktopOrientation,$type = $type ?? 'liveStream';
  factory CaxiloGameBlockLiveStream.fromJson(Map<String, dynamic> json) => _$CaxiloGameBlockLiveStreamFromJson(json);

// --- provider data & resolved image ---
/// The unique id of the provider (e.g. `amb-vn`, `vivo`, `sunwin`)
@override final  String providerId;
/// The human-readable name of the provider.
@override final  String providerName;
/// The resolved image path or name for the game thumbnail.
@override final  String image;
// --- core game data ---
/// The specific product API identifier (e.g., 'SEXY', 'EVO').
@override final  String productId;
/// The specific unique code for this game within the provider.
@override final  String gameCode;
/// The human-readable name of the game.
@override final  String gameName;
/// The required language code for the game url.
@override final  String lang;
/// The generic category of this game (e.g. slot, live, sport).
@override@JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) final  caxiloconfig.GameType gameType;
// --- live stream specific ---
/// The lobby URL for this live stream game (used to return to the provider's lobby).
 final  String lobbyUrl;
/// The cashier URL for this live stream game (used if player needs to deposit).
 final  String cashierUrl;
/// Whether this game requires setting a mobile specific flag in its URL.
@JsonKey() final  bool mobileLogin;
/// Allowed orientations on mobile phones.
 final  List<caxiloconfig.GameOrientation> _mobileOrientation;
/// Allowed orientations on mobile phones.
@override@JsonKey()@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get mobileOrientation {
  if (_mobileOrientation is EqualUnmodifiableListView) return _mobileOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mobileOrientation);
}

/// Allowed orientations on tablets.
 final  List<caxiloconfig.GameOrientation> _tabletOrientation;
/// Allowed orientations on tablets.
@override@JsonKey()@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get tabletOrientation {
  if (_tabletOrientation is EqualUnmodifiableListView) return _tabletOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabletOrientation);
}

/// Allowed orientations on desktops.
 final  List<caxiloconfig.GameOrientation> _desktopOrientation;
/// Allowed orientations on desktops.
@override@JsonKey()@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get desktopOrientation {
  if (_desktopOrientation is EqualUnmodifiableListView) return _desktopOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desktopOrientation);
}

/// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
@override final  Duration? loadStopDebounce;
/// Determines the order in which this game is displayed relative to others.
@override@JsonKey() final  int sortOrder;
/// Whether this game should forcefully render in an immersive landscape virtual viewport on iPad.
@JsonKey() final  bool forceLandscapeViewportOnIpad;
/// Determines whether this game should be opened in a new tab to avoid crashes.
@JsonKey() final  bool openInNewTabOnIOSSafariWeb;
/// Whether this game requires a session cooldown guard before launching.
@JsonKey() final  bool requiresSessionGuard;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CaxiloGameBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloGameBlockLiveStreamCopyWith<CaxiloGameBlockLiveStream> get copyWith => _$CaxiloGameBlockLiveStreamCopyWithImpl<CaxiloGameBlockLiveStream>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaxiloGameBlockLiveStreamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloGameBlockLiveStream&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.lobbyUrl, lobbyUrl) || other.lobbyUrl == lobbyUrl)&&(identical(other.cashierUrl, cashierUrl) || other.cashierUrl == cashierUrl)&&(identical(other.mobileLogin, mobileLogin) || other.mobileLogin == mobileLogin)&&const DeepCollectionEquality().equals(other._mobileOrientation, _mobileOrientation)&&const DeepCollectionEquality().equals(other._tabletOrientation, _tabletOrientation)&&const DeepCollectionEquality().equals(other._desktopOrientation, _desktopOrientation)&&(identical(other.loadStopDebounce, loadStopDebounce) || other.loadStopDebounce == loadStopDebounce)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.forceLandscapeViewportOnIpad, forceLandscapeViewportOnIpad) || other.forceLandscapeViewportOnIpad == forceLandscapeViewportOnIpad)&&(identical(other.openInNewTabOnIOSSafariWeb, openInNewTabOnIOSSafariWeb) || other.openInNewTabOnIOSSafariWeb == openInNewTabOnIOSSafariWeb)&&(identical(other.requiresSessionGuard, requiresSessionGuard) || other.requiresSessionGuard == requiresSessionGuard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,providerId,providerName,image,productId,gameCode,gameName,lang,gameType,lobbyUrl,cashierUrl,mobileLogin,const DeepCollectionEquality().hash(_mobileOrientation),const DeepCollectionEquality().hash(_tabletOrientation),const DeepCollectionEquality().hash(_desktopOrientation),loadStopDebounce,sortOrder,forceLandscapeViewportOnIpad,openInNewTabOnIOSSafariWeb,requiresSessionGuard]);

@override
String toString() {
  return 'CaxiloGameBlock.liveStream(providerId: $providerId, providerName: $providerName, image: $image, productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, gameType: $gameType, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, mobileLogin: $mobileLogin, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, loadStopDebounce: $loadStopDebounce, sortOrder: $sortOrder, forceLandscapeViewportOnIpad: $forceLandscapeViewportOnIpad, openInNewTabOnIOSSafariWeb: $openInNewTabOnIOSSafariWeb, requiresSessionGuard: $requiresSessionGuard)';
}


}

/// @nodoc
abstract mixin class $CaxiloGameBlockLiveStreamCopyWith<$Res> implements $CaxiloGameBlockCopyWith<$Res> {
  factory $CaxiloGameBlockLiveStreamCopyWith(CaxiloGameBlockLiveStream value, $Res Function(CaxiloGameBlockLiveStream) _then) = _$CaxiloGameBlockLiveStreamCopyWithImpl;
@override @useResult
$Res call({
 String providerId, String providerName, String image, String productId, String gameCode, String gameName, String lang,@JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) caxiloconfig.GameType gameType, String lobbyUrl, String cashierUrl, bool mobileLogin,@GameOrientationListConverter() List<caxiloconfig.GameOrientation> mobileOrientation,@GameOrientationListConverter() List<caxiloconfig.GameOrientation> tabletOrientation,@GameOrientationListConverter() List<caxiloconfig.GameOrientation> desktopOrientation, Duration? loadStopDebounce, int sortOrder, bool forceLandscapeViewportOnIpad, bool openInNewTabOnIOSSafariWeb, bool requiresSessionGuard
});




}
/// @nodoc
class _$CaxiloGameBlockLiveStreamCopyWithImpl<$Res>
    implements $CaxiloGameBlockLiveStreamCopyWith<$Res> {
  _$CaxiloGameBlockLiveStreamCopyWithImpl(this._self, this._then);

  final CaxiloGameBlockLiveStream _self;
  final $Res Function(CaxiloGameBlockLiveStream) _then;

/// Create a copy of CaxiloGameBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? providerName = null,Object? image = null,Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? gameType = null,Object? lobbyUrl = null,Object? cashierUrl = null,Object? mobileLogin = null,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? loadStopDebounce = freezed,Object? sortOrder = null,Object? forceLandscapeViewportOnIpad = null,Object? openInNewTabOnIOSSafariWeb = null,Object? requiresSessionGuard = null,}) {
  return _then(CaxiloGameBlockLiveStream(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as caxiloconfig.GameType,lobbyUrl: null == lobbyUrl ? _self.lobbyUrl : lobbyUrl // ignore: cast_nullable_to_non_nullable
as String,cashierUrl: null == cashierUrl ? _self.cashierUrl : cashierUrl // ignore: cast_nullable_to_non_nullable
as String,mobileLogin: null == mobileLogin ? _self.mobileLogin : mobileLogin // ignore: cast_nullable_to_non_nullable
as bool,mobileOrientation: null == mobileOrientation ? _self._mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameOrientation>,tabletOrientation: null == tabletOrientation ? _self._tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameOrientation>,desktopOrientation: null == desktopOrientation ? _self._desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameOrientation>,loadStopDebounce: freezed == loadStopDebounce ? _self.loadStopDebounce : loadStopDebounce // ignore: cast_nullable_to_non_nullable
as Duration?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,forceLandscapeViewportOnIpad: null == forceLandscapeViewportOnIpad ? _self.forceLandscapeViewportOnIpad : forceLandscapeViewportOnIpad // ignore: cast_nullable_to_non_nullable
as bool,openInNewTabOnIOSSafariWeb: null == openInNewTabOnIOSSafariWeb ? _self.openInNewTabOnIOSSafariWeb : openInNewTabOnIOSSafariWeb // ignore: cast_nullable_to_non_nullable
as bool,requiresSessionGuard: null == requiresSessionGuard ? _self.requiresSessionGuard : requiresSessionGuard // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CaxiloGameBlockInHouse implements CaxiloGameBlock {
  const CaxiloGameBlockInHouse({required this.providerId, required this.providerName, required this.image, required this.productId, required this.gameCode, required this.gameName, required this.lang, @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) required this.gameType, @GameOrientationListConverter() final  List<caxiloconfig.GameOrientation> mobileOrientation = caxiloconfig.GameOrientation.portrait, @GameOrientationListConverter() final  List<caxiloconfig.GameOrientation> tabletOrientation = caxiloconfig.GameOrientation.all, @GameOrientationListConverter() final  List<caxiloconfig.GameOrientation> desktopOrientation = caxiloconfig.GameOrientation.all, this.loadStopDebounce, this.sortOrder = 999, this.enableHostMessage = false, final  String? $type}): _mobileOrientation = mobileOrientation,_tabletOrientation = tabletOrientation,_desktopOrientation = desktopOrientation,$type = $type ?? 'inHouse';
  factory CaxiloGameBlockInHouse.fromJson(Map<String, dynamic> json) => _$CaxiloGameBlockInHouseFromJson(json);

// --- provider data & resolved image ---
/// The unique id of the provider (e.g. `amb-vn`, `vivo`, `sunwin`)
@override final  String providerId;
/// The human-readable name of the provider.
@override final  String providerName;
/// The resolved image path or name for the game thumbnail.
@override final  String image;
// --- core game data ---
/// The specific product API identifier (e.g., 'SEXY', 'EVO').
@override final  String productId;
/// The specific unique code for this game within the provider.
@override final  String gameCode;
/// The human-readable name of the game.
@override final  String gameName;
/// The required language code for the game url.
@override final  String lang;
/// The generic category of this game (e.g. slot, live, sport).
@override@JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) final  caxiloconfig.GameType gameType;
/// Allowed orientations on mobile phones.
 final  List<caxiloconfig.GameOrientation> _mobileOrientation;
/// Allowed orientations on mobile phones.
@override@JsonKey()@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get mobileOrientation {
  if (_mobileOrientation is EqualUnmodifiableListView) return _mobileOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mobileOrientation);
}

/// Allowed orientations on tablets.
 final  List<caxiloconfig.GameOrientation> _tabletOrientation;
/// Allowed orientations on tablets.
@override@JsonKey()@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get tabletOrientation {
  if (_tabletOrientation is EqualUnmodifiableListView) return _tabletOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabletOrientation);
}

/// Allowed orientations on desktops.
 final  List<caxiloconfig.GameOrientation> _desktopOrientation;
/// Allowed orientations on desktops.
@override@JsonKey()@GameOrientationListConverter() List<caxiloconfig.GameOrientation> get desktopOrientation {
  if (_desktopOrientation is EqualUnmodifiableListView) return _desktopOrientation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desktopOrientation);
}

/// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
@override final  Duration? loadStopDebounce;
/// Determines the order in which this game is displayed relative to others.
@override@JsonKey() final  int sortOrder;
// --- in-house specific ---
/// Whether this game enables host message channel.
@JsonKey() final  bool enableHostMessage;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CaxiloGameBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloGameBlockInHouseCopyWith<CaxiloGameBlockInHouse> get copyWith => _$CaxiloGameBlockInHouseCopyWithImpl<CaxiloGameBlockInHouse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaxiloGameBlockInHouseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloGameBlockInHouse&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.image, image) || other.image == image)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.gameName, gameName) || other.gameName == gameName)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&const DeepCollectionEquality().equals(other._mobileOrientation, _mobileOrientation)&&const DeepCollectionEquality().equals(other._tabletOrientation, _tabletOrientation)&&const DeepCollectionEquality().equals(other._desktopOrientation, _desktopOrientation)&&(identical(other.loadStopDebounce, loadStopDebounce) || other.loadStopDebounce == loadStopDebounce)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.enableHostMessage, enableHostMessage) || other.enableHostMessage == enableHostMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,providerName,image,productId,gameCode,gameName,lang,gameType,const DeepCollectionEquality().hash(_mobileOrientation),const DeepCollectionEquality().hash(_tabletOrientation),const DeepCollectionEquality().hash(_desktopOrientation),loadStopDebounce,sortOrder,enableHostMessage);

@override
String toString() {
  return 'CaxiloGameBlock.inHouse(providerId: $providerId, providerName: $providerName, image: $image, productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, gameType: $gameType, mobileOrientation: $mobileOrientation, tabletOrientation: $tabletOrientation, desktopOrientation: $desktopOrientation, loadStopDebounce: $loadStopDebounce, sortOrder: $sortOrder, enableHostMessage: $enableHostMessage)';
}


}

/// @nodoc
abstract mixin class $CaxiloGameBlockInHouseCopyWith<$Res> implements $CaxiloGameBlockCopyWith<$Res> {
  factory $CaxiloGameBlockInHouseCopyWith(CaxiloGameBlockInHouse value, $Res Function(CaxiloGameBlockInHouse) _then) = _$CaxiloGameBlockInHouseCopyWithImpl;
@override @useResult
$Res call({
 String providerId, String providerName, String image, String productId, String gameCode, String gameName, String lang,@JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson) caxiloconfig.GameType gameType,@GameOrientationListConverter() List<caxiloconfig.GameOrientation> mobileOrientation,@GameOrientationListConverter() List<caxiloconfig.GameOrientation> tabletOrientation,@GameOrientationListConverter() List<caxiloconfig.GameOrientation> desktopOrientation, Duration? loadStopDebounce, int sortOrder, bool enableHostMessage
});




}
/// @nodoc
class _$CaxiloGameBlockInHouseCopyWithImpl<$Res>
    implements $CaxiloGameBlockInHouseCopyWith<$Res> {
  _$CaxiloGameBlockInHouseCopyWithImpl(this._self, this._then);

  final CaxiloGameBlockInHouse _self;
  final $Res Function(CaxiloGameBlockInHouse) _then;

/// Create a copy of CaxiloGameBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? providerName = null,Object? image = null,Object? productId = null,Object? gameCode = null,Object? gameName = null,Object? lang = null,Object? gameType = null,Object? mobileOrientation = null,Object? tabletOrientation = null,Object? desktopOrientation = null,Object? loadStopDebounce = freezed,Object? sortOrder = null,Object? enableHostMessage = null,}) {
  return _then(CaxiloGameBlockInHouse(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,gameName: null == gameName ? _self.gameName : gameName // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as caxiloconfig.GameType,mobileOrientation: null == mobileOrientation ? _self._mobileOrientation : mobileOrientation // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameOrientation>,tabletOrientation: null == tabletOrientation ? _self._tabletOrientation : tabletOrientation // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameOrientation>,desktopOrientation: null == desktopOrientation ? _self._desktopOrientation : desktopOrientation // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameOrientation>,loadStopDebounce: freezed == loadStopDebounce ? _self.loadStopDebounce : loadStopDebounce // ignore: cast_nullable_to_non_nullable
as Duration?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,enableHostMessage: null == enableHostMessage ? _self.enableHostMessage : enableHostMessage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
