// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_player_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GamePlayerState {

/// Current lifecycle status of the player.
 GamePlayerStatus get status;/// Error message to display — `null` means no error.
 String? get errorMessage;/// Whether the orientation is locked and ready for rendering/fetching.
 bool get isOrientationReady;/// Whether the WebView should be visible (controls fade-in animation).
 bool get showWebView;/// The resolved game URL to load in the WebView.
 String? get gameUrl;/// Whether the game has been opened in a new tab (for iOS Safari fallback).
 bool get isNewTabOpened;/// Number of times the game URL fetch has been retried.
 int get retryCount;
/// Create a copy of GamePlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerStateCopyWith<GamePlayerState> get copyWith => _$GamePlayerStateCopyWithImpl<GamePlayerState>(this as GamePlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isOrientationReady, isOrientationReady) || other.isOrientationReady == isOrientationReady)&&(identical(other.showWebView, showWebView) || other.showWebView == showWebView)&&(identical(other.gameUrl, gameUrl) || other.gameUrl == gameUrl)&&(identical(other.isNewTabOpened, isNewTabOpened) || other.isNewTabOpened == isNewTabOpened)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,isOrientationReady,showWebView,gameUrl,isNewTabOpened,retryCount);

@override
String toString() {
  return 'GamePlayerState(status: $status, errorMessage: $errorMessage, isOrientationReady: $isOrientationReady, showWebView: $showWebView, gameUrl: $gameUrl, isNewTabOpened: $isNewTabOpened, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class $GamePlayerStateCopyWith<$Res>  {
  factory $GamePlayerStateCopyWith(GamePlayerState value, $Res Function(GamePlayerState) _then) = _$GamePlayerStateCopyWithImpl;
@useResult
$Res call({
 GamePlayerStatus status, String? errorMessage, bool isOrientationReady, bool showWebView, String? gameUrl, bool isNewTabOpened, int retryCount
});




}
/// @nodoc
class _$GamePlayerStateCopyWithImpl<$Res>
    implements $GamePlayerStateCopyWith<$Res> {
  _$GamePlayerStateCopyWithImpl(this._self, this._then);

  final GamePlayerState _self;
  final $Res Function(GamePlayerState) _then;

/// Create a copy of GamePlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? isOrientationReady = null,Object? showWebView = null,Object? gameUrl = freezed,Object? isNewTabOpened = null,Object? retryCount = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GamePlayerStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isOrientationReady: null == isOrientationReady ? _self.isOrientationReady : isOrientationReady // ignore: cast_nullable_to_non_nullable
as bool,showWebView: null == showWebView ? _self.showWebView : showWebView // ignore: cast_nullable_to_non_nullable
as bool,gameUrl: freezed == gameUrl ? _self.gameUrl : gameUrl // ignore: cast_nullable_to_non_nullable
as String?,isNewTabOpened: null == isNewTabOpened ? _self.isNewTabOpened : isNewTabOpened // ignore: cast_nullable_to_non_nullable
as bool,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GamePlayerState].
extension GamePlayerStatePatterns on GamePlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamePlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamePlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamePlayerState value)  $default,){
final _that = this;
switch (_that) {
case _GamePlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamePlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _GamePlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GamePlayerStatus status,  String? errorMessage,  bool isOrientationReady,  bool showWebView,  String? gameUrl,  bool isNewTabOpened,  int retryCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePlayerState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.isOrientationReady,_that.showWebView,_that.gameUrl,_that.isNewTabOpened,_that.retryCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GamePlayerStatus status,  String? errorMessage,  bool isOrientationReady,  bool showWebView,  String? gameUrl,  bool isNewTabOpened,  int retryCount)  $default,) {final _that = this;
switch (_that) {
case _GamePlayerState():
return $default(_that.status,_that.errorMessage,_that.isOrientationReady,_that.showWebView,_that.gameUrl,_that.isNewTabOpened,_that.retryCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GamePlayerStatus status,  String? errorMessage,  bool isOrientationReady,  bool showWebView,  String? gameUrl,  bool isNewTabOpened,  int retryCount)?  $default,) {final _that = this;
switch (_that) {
case _GamePlayerState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.isOrientationReady,_that.showWebView,_that.gameUrl,_that.isNewTabOpened,_that.retryCount);case _:
  return null;

}
}

}

/// @nodoc


class _GamePlayerState extends GamePlayerState {
  const _GamePlayerState({this.status = GamePlayerStatus.initial, this.errorMessage, this.isOrientationReady = false, this.showWebView = false, this.gameUrl, this.isNewTabOpened = false, this.retryCount = 0}): super._();
  

/// Current lifecycle status of the player.
@override@JsonKey() final  GamePlayerStatus status;
/// Error message to display — `null` means no error.
@override final  String? errorMessage;
/// Whether the orientation is locked and ready for rendering/fetching.
@override@JsonKey() final  bool isOrientationReady;
/// Whether the WebView should be visible (controls fade-in animation).
@override@JsonKey() final  bool showWebView;
/// The resolved game URL to load in the WebView.
@override final  String? gameUrl;
/// Whether the game has been opened in a new tab (for iOS Safari fallback).
@override@JsonKey() final  bool isNewTabOpened;
/// Number of times the game URL fetch has been retried.
@override@JsonKey() final  int retryCount;

/// Create a copy of GamePlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePlayerStateCopyWith<_GamePlayerState> get copyWith => __$GamePlayerStateCopyWithImpl<_GamePlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlayerState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isOrientationReady, isOrientationReady) || other.isOrientationReady == isOrientationReady)&&(identical(other.showWebView, showWebView) || other.showWebView == showWebView)&&(identical(other.gameUrl, gameUrl) || other.gameUrl == gameUrl)&&(identical(other.isNewTabOpened, isNewTabOpened) || other.isNewTabOpened == isNewTabOpened)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,isOrientationReady,showWebView,gameUrl,isNewTabOpened,retryCount);

@override
String toString() {
  return 'GamePlayerState(status: $status, errorMessage: $errorMessage, isOrientationReady: $isOrientationReady, showWebView: $showWebView, gameUrl: $gameUrl, isNewTabOpened: $isNewTabOpened, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class _$GamePlayerStateCopyWith<$Res> implements $GamePlayerStateCopyWith<$Res> {
  factory _$GamePlayerStateCopyWith(_GamePlayerState value, $Res Function(_GamePlayerState) _then) = __$GamePlayerStateCopyWithImpl;
@override @useResult
$Res call({
 GamePlayerStatus status, String? errorMessage, bool isOrientationReady, bool showWebView, String? gameUrl, bool isNewTabOpened, int retryCount
});




}
/// @nodoc
class __$GamePlayerStateCopyWithImpl<$Res>
    implements _$GamePlayerStateCopyWith<$Res> {
  __$GamePlayerStateCopyWithImpl(this._self, this._then);

  final _GamePlayerState _self;
  final $Res Function(_GamePlayerState) _then;

/// Create a copy of GamePlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? isOrientationReady = null,Object? showWebView = null,Object? gameUrl = freezed,Object? isNewTabOpened = null,Object? retryCount = null,}) {
  return _then(_GamePlayerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GamePlayerStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isOrientationReady: null == isOrientationReady ? _self.isOrientationReady : isOrientationReady // ignore: cast_nullable_to_non_nullable
as bool,showWebView: null == showWebView ? _self.showWebView : showWebView // ignore: cast_nullable_to_non_nullable
as bool,gameUrl: freezed == gameUrl ? _self.gameUrl : gameUrl // ignore: cast_nullable_to_non_nullable
as String?,isNewTabOpened: null == isNewTabOpened ? _self.isNewTabOpened : isNewTabOpened // ignore: cast_nullable_to_non_nullable
as bool,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
