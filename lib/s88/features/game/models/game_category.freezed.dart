// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameCategory {

 String get displayLabel; String? get icon; String? get iconActive; int get gameCount;
/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCategoryCopyWith<GameCategory> get copyWith => _$GameCategoryCopyWithImpl<GameCategory>(this as GameCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameCategory&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&(identical(other.gameCount, gameCount) || other.gameCount == gameCount));
}


@override
int get hashCode => Object.hash(runtimeType,displayLabel,icon,iconActive,gameCount);

@override
String toString() {
  return 'GameCategory(displayLabel: $displayLabel, icon: $icon, iconActive: $iconActive, gameCount: $gameCount)';
}


}

/// @nodoc
abstract mixin class $GameCategoryCopyWith<$Res>  {
  factory $GameCategoryCopyWith(GameCategory value, $Res Function(GameCategory) _then) = _$GameCategoryCopyWithImpl;
@useResult
$Res call({
 String displayLabel, String? icon, String? iconActive, int gameCount
});




}
/// @nodoc
class _$GameCategoryCopyWithImpl<$Res>
    implements $GameCategoryCopyWith<$Res> {
  _$GameCategoryCopyWithImpl(this._self, this._then);

  final GameCategory _self;
  final $Res Function(GameCategory) _then;

/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayLabel = null,Object? icon = freezed,Object? iconActive = freezed,Object? gameCount = null,}) {
  return _then(_self.copyWith(
displayLabel: null == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,gameCount: null == gameCount ? _self.gameCount : gameCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameCategory].
extension GameCategoryPatterns on GameCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GameTypeCategory value)?  gameType,TResult Function( ProviderCategory value)?  provider,TResult Function( CustomCategory value)?  custom,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GameTypeCategory() when gameType != null:
return gameType(_that);case ProviderCategory() when provider != null:
return provider(_that);case CustomCategory() when custom != null:
return custom(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GameTypeCategory value)  gameType,required TResult Function( ProviderCategory value)  provider,required TResult Function( CustomCategory value)  custom,}){
final _that = this;
switch (_that) {
case GameTypeCategory():
return gameType(_that);case ProviderCategory():
return provider(_that);case CustomCategory():
return custom(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GameTypeCategory value)?  gameType,TResult? Function( ProviderCategory value)?  provider,TResult? Function( CustomCategory value)?  custom,}){
final _that = this;
switch (_that) {
case GameTypeCategory() when gameType != null:
return gameType(_that);case ProviderCategory() when provider != null:
return provider(_that);case CustomCategory() when custom != null:
return custom(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( GameType type,  String displayLabel,  String? icon,  String? iconActive,  int gameCount,  List<String> providerIds)?  gameType,TResult Function( String providerId,  String displayLabel,  String? icon,  String? iconActive,  int gameCount,  List<GameType> gameTypes)?  provider,TResult Function( String categoryId,  String displayLabel,  GameFilter filter,  String? icon,  String? iconActive,  int gameCount)?  custom,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GameTypeCategory() when gameType != null:
return gameType(_that.type,_that.displayLabel,_that.icon,_that.iconActive,_that.gameCount,_that.providerIds);case ProviderCategory() when provider != null:
return provider(_that.providerId,_that.displayLabel,_that.icon,_that.iconActive,_that.gameCount,_that.gameTypes);case CustomCategory() when custom != null:
return custom(_that.categoryId,_that.displayLabel,_that.filter,_that.icon,_that.iconActive,_that.gameCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( GameType type,  String displayLabel,  String? icon,  String? iconActive,  int gameCount,  List<String> providerIds)  gameType,required TResult Function( String providerId,  String displayLabel,  String? icon,  String? iconActive,  int gameCount,  List<GameType> gameTypes)  provider,required TResult Function( String categoryId,  String displayLabel,  GameFilter filter,  String? icon,  String? iconActive,  int gameCount)  custom,}) {final _that = this;
switch (_that) {
case GameTypeCategory():
return gameType(_that.type,_that.displayLabel,_that.icon,_that.iconActive,_that.gameCount,_that.providerIds);case ProviderCategory():
return provider(_that.providerId,_that.displayLabel,_that.icon,_that.iconActive,_that.gameCount,_that.gameTypes);case CustomCategory():
return custom(_that.categoryId,_that.displayLabel,_that.filter,_that.icon,_that.iconActive,_that.gameCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( GameType type,  String displayLabel,  String? icon,  String? iconActive,  int gameCount,  List<String> providerIds)?  gameType,TResult? Function( String providerId,  String displayLabel,  String? icon,  String? iconActive,  int gameCount,  List<GameType> gameTypes)?  provider,TResult? Function( String categoryId,  String displayLabel,  GameFilter filter,  String? icon,  String? iconActive,  int gameCount)?  custom,}) {final _that = this;
switch (_that) {
case GameTypeCategory() when gameType != null:
return gameType(_that.type,_that.displayLabel,_that.icon,_that.iconActive,_that.gameCount,_that.providerIds);case ProviderCategory() when provider != null:
return provider(_that.providerId,_that.displayLabel,_that.icon,_that.iconActive,_that.gameCount,_that.gameTypes);case CustomCategory() when custom != null:
return custom(_that.categoryId,_that.displayLabel,_that.filter,_that.icon,_that.iconActive,_that.gameCount);case _:
  return null;

}
}

}

/// @nodoc


class GameTypeCategory extends GameCategory {
  const GameTypeCategory({required this.type, required this.displayLabel, this.icon, this.iconActive, this.gameCount = 0, final  List<String> providerIds = const []}): _providerIds = providerIds,super._();
  

 final  GameType type;
@override final  String displayLabel;
@override final  String? icon;
@override final  String? iconActive;
@override@JsonKey() final  int gameCount;
 final  List<String> _providerIds;
@JsonKey() List<String> get providerIds {
  if (_providerIds is EqualUnmodifiableListView) return _providerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerIds);
}


/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameTypeCategoryCopyWith<GameTypeCategory> get copyWith => _$GameTypeCategoryCopyWithImpl<GameTypeCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameTypeCategory&&(identical(other.type, type) || other.type == type)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&(identical(other.gameCount, gameCount) || other.gameCount == gameCount)&&const DeepCollectionEquality().equals(other._providerIds, _providerIds));
}


@override
int get hashCode => Object.hash(runtimeType,type,displayLabel,icon,iconActive,gameCount,const DeepCollectionEquality().hash(_providerIds));

@override
String toString() {
  return 'GameCategory.gameType(type: $type, displayLabel: $displayLabel, icon: $icon, iconActive: $iconActive, gameCount: $gameCount, providerIds: $providerIds)';
}


}

/// @nodoc
abstract mixin class $GameTypeCategoryCopyWith<$Res> implements $GameCategoryCopyWith<$Res> {
  factory $GameTypeCategoryCopyWith(GameTypeCategory value, $Res Function(GameTypeCategory) _then) = _$GameTypeCategoryCopyWithImpl;
@override @useResult
$Res call({
 GameType type, String displayLabel, String? icon, String? iconActive, int gameCount, List<String> providerIds
});




}
/// @nodoc
class _$GameTypeCategoryCopyWithImpl<$Res>
    implements $GameTypeCategoryCopyWith<$Res> {
  _$GameTypeCategoryCopyWithImpl(this._self, this._then);

  final GameTypeCategory _self;
  final $Res Function(GameTypeCategory) _then;

/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? displayLabel = null,Object? icon = freezed,Object? iconActive = freezed,Object? gameCount = null,Object? providerIds = null,}) {
  return _then(GameTypeCategory(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GameType,displayLabel: null == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,gameCount: null == gameCount ? _self.gameCount : gameCount // ignore: cast_nullable_to_non_nullable
as int,providerIds: null == providerIds ? _self._providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ProviderCategory extends GameCategory {
  const ProviderCategory({required this.providerId, required this.displayLabel, this.icon, this.iconActive, this.gameCount = 0, final  List<GameType> gameTypes = const []}): _gameTypes = gameTypes,super._();
  

 final  String providerId;
@override final  String displayLabel;
@override final  String? icon;
@override final  String? iconActive;
@override@JsonKey() final  int gameCount;
 final  List<GameType> _gameTypes;
@JsonKey() List<GameType> get gameTypes {
  if (_gameTypes is EqualUnmodifiableListView) return _gameTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameTypes);
}


/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderCategoryCopyWith<ProviderCategory> get copyWith => _$ProviderCategoryCopyWithImpl<ProviderCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderCategory&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&(identical(other.gameCount, gameCount) || other.gameCount == gameCount)&&const DeepCollectionEquality().equals(other._gameTypes, _gameTypes));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,displayLabel,icon,iconActive,gameCount,const DeepCollectionEquality().hash(_gameTypes));

@override
String toString() {
  return 'GameCategory.provider(providerId: $providerId, displayLabel: $displayLabel, icon: $icon, iconActive: $iconActive, gameCount: $gameCount, gameTypes: $gameTypes)';
}


}

/// @nodoc
abstract mixin class $ProviderCategoryCopyWith<$Res> implements $GameCategoryCopyWith<$Res> {
  factory $ProviderCategoryCopyWith(ProviderCategory value, $Res Function(ProviderCategory) _then) = _$ProviderCategoryCopyWithImpl;
@override @useResult
$Res call({
 String providerId, String displayLabel, String? icon, String? iconActive, int gameCount, List<GameType> gameTypes
});




}
/// @nodoc
class _$ProviderCategoryCopyWithImpl<$Res>
    implements $ProviderCategoryCopyWith<$Res> {
  _$ProviderCategoryCopyWithImpl(this._self, this._then);

  final ProviderCategory _self;
  final $Res Function(ProviderCategory) _then;

/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? displayLabel = null,Object? icon = freezed,Object? iconActive = freezed,Object? gameCount = null,Object? gameTypes = null,}) {
  return _then(ProviderCategory(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,displayLabel: null == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,gameCount: null == gameCount ? _self.gameCount : gameCount // ignore: cast_nullable_to_non_nullable
as int,gameTypes: null == gameTypes ? _self._gameTypes : gameTypes // ignore: cast_nullable_to_non_nullable
as List<GameType>,
  ));
}


}

/// @nodoc


class CustomCategory extends GameCategory {
  const CustomCategory({required this.categoryId, required this.displayLabel, required this.filter, this.icon, this.iconActive, this.gameCount = 0}): super._();
  

 final  String categoryId;
@override final  String displayLabel;
 final  GameFilter filter;
@override final  String? icon;
@override final  String? iconActive;
@override@JsonKey() final  int gameCount;

/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomCategoryCopyWith<CustomCategory> get copyWith => _$CustomCategoryCopyWithImpl<CustomCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconActive, iconActive) || other.iconActive == iconActive)&&(identical(other.gameCount, gameCount) || other.gameCount == gameCount));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,displayLabel,filter,icon,iconActive,gameCount);

@override
String toString() {
  return 'GameCategory.custom(categoryId: $categoryId, displayLabel: $displayLabel, filter: $filter, icon: $icon, iconActive: $iconActive, gameCount: $gameCount)';
}


}

/// @nodoc
abstract mixin class $CustomCategoryCopyWith<$Res> implements $GameCategoryCopyWith<$Res> {
  factory $CustomCategoryCopyWith(CustomCategory value, $Res Function(CustomCategory) _then) = _$CustomCategoryCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String displayLabel, GameFilter filter, String? icon, String? iconActive, int gameCount
});


$GameFilterCopyWith<$Res> get filter;

}
/// @nodoc
class _$CustomCategoryCopyWithImpl<$Res>
    implements $CustomCategoryCopyWith<$Res> {
  _$CustomCategoryCopyWithImpl(this._self, this._then);

  final CustomCategory _self;
  final $Res Function(CustomCategory) _then;

/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? displayLabel = null,Object? filter = null,Object? icon = freezed,Object? iconActive = freezed,Object? gameCount = null,}) {
  return _then(CustomCategory(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,displayLabel: null == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as GameFilter,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconActive: freezed == iconActive ? _self.iconActive : iconActive // ignore: cast_nullable_to_non_nullable
as String?,gameCount: null == gameCount ? _self.gameCount : gameCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GameCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameFilterCopyWith<$Res> get filter {
  
  return $GameFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on
