// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'external_game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExternalGame {

/// Unique short code for the game (e.g., 'mx-live-001').
@JsonKey(name: 'game_code') String get gameCode;/// Optional file path or name for the game thumbnail.
/// If null, a fallback naming convention may be used.
@JsonKey(name: 'image') String? get image;
/// Create a copy of ExternalGame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalGameCopyWith<ExternalGame> get copyWith => _$ExternalGameCopyWithImpl<ExternalGame>(this as ExternalGame, _$identity);

  /// Serializes this ExternalGame to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalGame&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameCode,image);

@override
String toString() {
  return 'ExternalGame(gameCode: $gameCode, image: $image)';
}


}

/// @nodoc
abstract mixin class $ExternalGameCopyWith<$Res>  {
  factory $ExternalGameCopyWith(ExternalGame value, $Res Function(ExternalGame) _then) = _$ExternalGameCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'game_code') String gameCode,@JsonKey(name: 'image') String? image
});




}
/// @nodoc
class _$ExternalGameCopyWithImpl<$Res>
    implements $ExternalGameCopyWith<$Res> {
  _$ExternalGameCopyWithImpl(this._self, this._then);

  final ExternalGame _self;
  final $Res Function(ExternalGame) _then;

/// Create a copy of ExternalGame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameCode = null,Object? image = freezed,}) {
  return _then(_self.copyWith(
gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExternalGame].
extension ExternalGamePatterns on ExternalGame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExternalGame value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExternalGame() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExternalGame value)  $default,){
final _that = this;
switch (_that) {
case _ExternalGame():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExternalGame value)?  $default,){
final _that = this;
switch (_that) {
case _ExternalGame() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'game_code')  String gameCode, @JsonKey(name: 'image')  String? image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExternalGame() when $default != null:
return $default(_that.gameCode,_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'game_code')  String gameCode, @JsonKey(name: 'image')  String? image)  $default,) {final _that = this;
switch (_that) {
case _ExternalGame():
return $default(_that.gameCode,_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'game_code')  String gameCode, @JsonKey(name: 'image')  String? image)?  $default,) {final _that = this;
switch (_that) {
case _ExternalGame() when $default != null:
return $default(_that.gameCode,_that.image);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExternalGame implements ExternalGame {
  const _ExternalGame({@JsonKey(name: 'game_code') required this.gameCode, @JsonKey(name: 'image') this.image});
  factory _ExternalGame.fromJson(Map<String, dynamic> json) => _$ExternalGameFromJson(json);

/// Unique short code for the game (e.g., 'mx-live-001').
@override@JsonKey(name: 'game_code') final  String gameCode;
/// Optional file path or name for the game thumbnail.
/// If null, a fallback naming convention may be used.
@override@JsonKey(name: 'image') final  String? image;

/// Create a copy of ExternalGame
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExternalGameCopyWith<_ExternalGame> get copyWith => __$ExternalGameCopyWithImpl<_ExternalGame>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExternalGameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExternalGame&&(identical(other.gameCode, gameCode) || other.gameCode == gameCode)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameCode,image);

@override
String toString() {
  return 'ExternalGame(gameCode: $gameCode, image: $image)';
}


}

/// @nodoc
abstract mixin class _$ExternalGameCopyWith<$Res> implements $ExternalGameCopyWith<$Res> {
  factory _$ExternalGameCopyWith(_ExternalGame value, $Res Function(_ExternalGame) _then) = __$ExternalGameCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'game_code') String gameCode,@JsonKey(name: 'image') String? image
});




}
/// @nodoc
class __$ExternalGameCopyWithImpl<$Res>
    implements _$ExternalGameCopyWith<$Res> {
  __$ExternalGameCopyWithImpl(this._self, this._then);

  final _ExternalGame _self;
  final $Res Function(_ExternalGame) _then;

/// Create a copy of ExternalGame
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameCode = null,Object? image = freezed,}) {
  return _then(_ExternalGame(
gameCode: null == gameCode ? _self.gameCode : gameCode // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
