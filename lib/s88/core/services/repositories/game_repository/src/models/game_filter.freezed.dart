// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameFilter {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameFilter()';
}


}

/// @nodoc
class $GameFilterCopyWith<$Res>  {
$GameFilterCopyWith(GameFilter _, $Res Function(GameFilter) __);
}


/// Adds pattern-matching-related methods to [GameFilter].
extension GameFilterPatterns on GameFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReleaseDateFilter value)?  byReleaseDate,TResult Function( PopularityFilter value)?  byPopularity,TResult Function( ProvidersFilter value)?  byProviders,TResult Function( GameTypesFilter value)?  byGameTypes,TResult Function( AllFilter value)?  all,TResult Function( AnyFilter value)?  any,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReleaseDateFilter() when byReleaseDate != null:
return byReleaseDate(_that);case PopularityFilter() when byPopularity != null:
return byPopularity(_that);case ProvidersFilter() when byProviders != null:
return byProviders(_that);case GameTypesFilter() when byGameTypes != null:
return byGameTypes(_that);case AllFilter() when all != null:
return all(_that);case AnyFilter() when any != null:
return any(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReleaseDateFilter value)  byReleaseDate,required TResult Function( PopularityFilter value)  byPopularity,required TResult Function( ProvidersFilter value)  byProviders,required TResult Function( GameTypesFilter value)  byGameTypes,required TResult Function( AllFilter value)  all,required TResult Function( AnyFilter value)  any,}){
final _that = this;
switch (_that) {
case ReleaseDateFilter():
return byReleaseDate(_that);case PopularityFilter():
return byPopularity(_that);case ProvidersFilter():
return byProviders(_that);case GameTypesFilter():
return byGameTypes(_that);case AllFilter():
return all(_that);case AnyFilter():
return any(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReleaseDateFilter value)?  byReleaseDate,TResult? Function( PopularityFilter value)?  byPopularity,TResult? Function( ProvidersFilter value)?  byProviders,TResult? Function( GameTypesFilter value)?  byGameTypes,TResult? Function( AllFilter value)?  all,TResult? Function( AnyFilter value)?  any,}){
final _that = this;
switch (_that) {
case ReleaseDateFilter() when byReleaseDate != null:
return byReleaseDate(_that);case PopularityFilter() when byPopularity != null:
return byPopularity(_that);case ProvidersFilter() when byProviders != null:
return byProviders(_that);case GameTypesFilter() when byGameTypes != null:
return byGameTypes(_that);case AllFilter() when all != null:
return all(_that);case AnyFilter() when any != null:
return any(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int daysAgo)?  byReleaseDate,TResult Function( int minPlayCount)?  byPopularity,TResult Function( List<String> providerIds)?  byProviders,TResult Function( List<GameType> gameTypes)?  byGameTypes,TResult Function( List<GameFilter> filters)?  all,TResult Function( List<GameFilter> filters)?  any,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReleaseDateFilter() when byReleaseDate != null:
return byReleaseDate(_that.daysAgo);case PopularityFilter() when byPopularity != null:
return byPopularity(_that.minPlayCount);case ProvidersFilter() when byProviders != null:
return byProviders(_that.providerIds);case GameTypesFilter() when byGameTypes != null:
return byGameTypes(_that.gameTypes);case AllFilter() when all != null:
return all(_that.filters);case AnyFilter() when any != null:
return any(_that.filters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int daysAgo)  byReleaseDate,required TResult Function( int minPlayCount)  byPopularity,required TResult Function( List<String> providerIds)  byProviders,required TResult Function( List<GameType> gameTypes)  byGameTypes,required TResult Function( List<GameFilter> filters)  all,required TResult Function( List<GameFilter> filters)  any,}) {final _that = this;
switch (_that) {
case ReleaseDateFilter():
return byReleaseDate(_that.daysAgo);case PopularityFilter():
return byPopularity(_that.minPlayCount);case ProvidersFilter():
return byProviders(_that.providerIds);case GameTypesFilter():
return byGameTypes(_that.gameTypes);case AllFilter():
return all(_that.filters);case AnyFilter():
return any(_that.filters);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int daysAgo)?  byReleaseDate,TResult? Function( int minPlayCount)?  byPopularity,TResult? Function( List<String> providerIds)?  byProviders,TResult? Function( List<GameType> gameTypes)?  byGameTypes,TResult? Function( List<GameFilter> filters)?  all,TResult? Function( List<GameFilter> filters)?  any,}) {final _that = this;
switch (_that) {
case ReleaseDateFilter() when byReleaseDate != null:
return byReleaseDate(_that.daysAgo);case PopularityFilter() when byPopularity != null:
return byPopularity(_that.minPlayCount);case ProvidersFilter() when byProviders != null:
return byProviders(_that.providerIds);case GameTypesFilter() when byGameTypes != null:
return byGameTypes(_that.gameTypes);case AllFilter() when all != null:
return all(_that.filters);case AnyFilter() when any != null:
return any(_that.filters);case _:
  return null;

}
}

}

/// @nodoc


class ReleaseDateFilter implements GameFilter {
  const ReleaseDateFilter({required this.daysAgo});
  

 final  int daysAgo;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseDateFilterCopyWith<ReleaseDateFilter> get copyWith => _$ReleaseDateFilterCopyWithImpl<ReleaseDateFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseDateFilter&&(identical(other.daysAgo, daysAgo) || other.daysAgo == daysAgo));
}


@override
int get hashCode => Object.hash(runtimeType,daysAgo);

@override
String toString() {
  return 'GameFilter.byReleaseDate(daysAgo: $daysAgo)';
}


}

/// @nodoc
abstract mixin class $ReleaseDateFilterCopyWith<$Res> implements $GameFilterCopyWith<$Res> {
  factory $ReleaseDateFilterCopyWith(ReleaseDateFilter value, $Res Function(ReleaseDateFilter) _then) = _$ReleaseDateFilterCopyWithImpl;
@useResult
$Res call({
 int daysAgo
});




}
/// @nodoc
class _$ReleaseDateFilterCopyWithImpl<$Res>
    implements $ReleaseDateFilterCopyWith<$Res> {
  _$ReleaseDateFilterCopyWithImpl(this._self, this._then);

  final ReleaseDateFilter _self;
  final $Res Function(ReleaseDateFilter) _then;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? daysAgo = null,}) {
  return _then(ReleaseDateFilter(
daysAgo: null == daysAgo ? _self.daysAgo : daysAgo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PopularityFilter implements GameFilter {
  const PopularityFilter({required this.minPlayCount});
  

 final  int minPlayCount;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopularityFilterCopyWith<PopularityFilter> get copyWith => _$PopularityFilterCopyWithImpl<PopularityFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularityFilter&&(identical(other.minPlayCount, minPlayCount) || other.minPlayCount == minPlayCount));
}


@override
int get hashCode => Object.hash(runtimeType,minPlayCount);

@override
String toString() {
  return 'GameFilter.byPopularity(minPlayCount: $minPlayCount)';
}


}

/// @nodoc
abstract mixin class $PopularityFilterCopyWith<$Res> implements $GameFilterCopyWith<$Res> {
  factory $PopularityFilterCopyWith(PopularityFilter value, $Res Function(PopularityFilter) _then) = _$PopularityFilterCopyWithImpl;
@useResult
$Res call({
 int minPlayCount
});




}
/// @nodoc
class _$PopularityFilterCopyWithImpl<$Res>
    implements $PopularityFilterCopyWith<$Res> {
  _$PopularityFilterCopyWithImpl(this._self, this._then);

  final PopularityFilter _self;
  final $Res Function(PopularityFilter) _then;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minPlayCount = null,}) {
  return _then(PopularityFilter(
minPlayCount: null == minPlayCount ? _self.minPlayCount : minPlayCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ProvidersFilter implements GameFilter {
  const ProvidersFilter({required final  List<String> providerIds}): _providerIds = providerIds;
  

 final  List<String> _providerIds;
 List<String> get providerIds {
  if (_providerIds is EqualUnmodifiableListView) return _providerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerIds);
}


/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProvidersFilterCopyWith<ProvidersFilter> get copyWith => _$ProvidersFilterCopyWithImpl<ProvidersFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProvidersFilter&&const DeepCollectionEquality().equals(other._providerIds, _providerIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_providerIds));

@override
String toString() {
  return 'GameFilter.byProviders(providerIds: $providerIds)';
}


}

/// @nodoc
abstract mixin class $ProvidersFilterCopyWith<$Res> implements $GameFilterCopyWith<$Res> {
  factory $ProvidersFilterCopyWith(ProvidersFilter value, $Res Function(ProvidersFilter) _then) = _$ProvidersFilterCopyWithImpl;
@useResult
$Res call({
 List<String> providerIds
});




}
/// @nodoc
class _$ProvidersFilterCopyWithImpl<$Res>
    implements $ProvidersFilterCopyWith<$Res> {
  _$ProvidersFilterCopyWithImpl(this._self, this._then);

  final ProvidersFilter _self;
  final $Res Function(ProvidersFilter) _then;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? providerIds = null,}) {
  return _then(ProvidersFilter(
providerIds: null == providerIds ? _self._providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class GameTypesFilter implements GameFilter {
  const GameTypesFilter({required final  List<GameType> gameTypes}): _gameTypes = gameTypes;
  

 final  List<GameType> _gameTypes;
 List<GameType> get gameTypes {
  if (_gameTypes is EqualUnmodifiableListView) return _gameTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameTypes);
}


/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameTypesFilterCopyWith<GameTypesFilter> get copyWith => _$GameTypesFilterCopyWithImpl<GameTypesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameTypesFilter&&const DeepCollectionEquality().equals(other._gameTypes, _gameTypes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_gameTypes));

@override
String toString() {
  return 'GameFilter.byGameTypes(gameTypes: $gameTypes)';
}


}

/// @nodoc
abstract mixin class $GameTypesFilterCopyWith<$Res> implements $GameFilterCopyWith<$Res> {
  factory $GameTypesFilterCopyWith(GameTypesFilter value, $Res Function(GameTypesFilter) _then) = _$GameTypesFilterCopyWithImpl;
@useResult
$Res call({
 List<GameType> gameTypes
});




}
/// @nodoc
class _$GameTypesFilterCopyWithImpl<$Res>
    implements $GameTypesFilterCopyWith<$Res> {
  _$GameTypesFilterCopyWithImpl(this._self, this._then);

  final GameTypesFilter _self;
  final $Res Function(GameTypesFilter) _then;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? gameTypes = null,}) {
  return _then(GameTypesFilter(
gameTypes: null == gameTypes ? _self._gameTypes : gameTypes // ignore: cast_nullable_to_non_nullable
as List<GameType>,
  ));
}


}

/// @nodoc


class AllFilter implements GameFilter {
  const AllFilter({required final  List<GameFilter> filters}): _filters = filters;
  

 final  List<GameFilter> _filters;
 List<GameFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllFilterCopyWith<AllFilter> get copyWith => _$AllFilterCopyWithImpl<AllFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllFilter&&const DeepCollectionEquality().equals(other._filters, _filters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString() {
  return 'GameFilter.all(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $AllFilterCopyWith<$Res> implements $GameFilterCopyWith<$Res> {
  factory $AllFilterCopyWith(AllFilter value, $Res Function(AllFilter) _then) = _$AllFilterCopyWithImpl;
@useResult
$Res call({
 List<GameFilter> filters
});




}
/// @nodoc
class _$AllFilterCopyWithImpl<$Res>
    implements $AllFilterCopyWith<$Res> {
  _$AllFilterCopyWithImpl(this._self, this._then);

  final AllFilter _self;
  final $Res Function(AllFilter) _then;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(AllFilter(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<GameFilter>,
  ));
}


}

/// @nodoc


class AnyFilter implements GameFilter {
  const AnyFilter({required final  List<GameFilter> filters}): _filters = filters;
  

 final  List<GameFilter> _filters;
 List<GameFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnyFilterCopyWith<AnyFilter> get copyWith => _$AnyFilterCopyWithImpl<AnyFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnyFilter&&const DeepCollectionEquality().equals(other._filters, _filters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString() {
  return 'GameFilter.any(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $AnyFilterCopyWith<$Res> implements $GameFilterCopyWith<$Res> {
  factory $AnyFilterCopyWith(AnyFilter value, $Res Function(AnyFilter) _then) = _$AnyFilterCopyWithImpl;
@useResult
$Res call({
 List<GameFilter> filters
});




}
/// @nodoc
class _$AnyFilterCopyWithImpl<$Res>
    implements $AnyFilterCopyWith<$Res> {
  _$AnyFilterCopyWithImpl(this._self, this._then);

  final AnyFilter _self;
  final $Res Function(AnyFilter) _then;

/// Create a copy of GameFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(AnyFilter(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<GameFilter>,
  ));
}


}

// dart format on
