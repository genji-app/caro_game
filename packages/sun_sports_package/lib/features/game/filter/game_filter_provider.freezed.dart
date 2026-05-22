// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_filter_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameFilterState {

 String get searchQuery; GameCategorySelection get categorySelection; List<GameBlock> get results; GameFilterStatus get status;
/// Create a copy of GameFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameFilterStateCopyWith<GameFilterState> get copyWith => _$GameFilterStateCopyWithImpl<GameFilterState>(this as GameFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameFilterState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categorySelection, categorySelection) || other.categorySelection == categorySelection)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,categorySelection,const DeepCollectionEquality().hash(results),status);

@override
String toString() {
  return 'GameFilterState(searchQuery: $searchQuery, categorySelection: $categorySelection, results: $results, status: $status)';
}


}

/// @nodoc
abstract mixin class $GameFilterStateCopyWith<$Res>  {
  factory $GameFilterStateCopyWith(GameFilterState value, $Res Function(GameFilterState) _then) = _$GameFilterStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, GameCategorySelection categorySelection, List<GameBlock> results, GameFilterStatus status
});




}
/// @nodoc
class _$GameFilterStateCopyWithImpl<$Res>
    implements $GameFilterStateCopyWith<$Res> {
  _$GameFilterStateCopyWithImpl(this._self, this._then);

  final GameFilterState _self;
  final $Res Function(GameFilterState) _then;

/// Create a copy of GameFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? categorySelection = null,Object? results = null,Object? status = null,}) {
  return _then(_self.copyWith(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as GameCategorySelection,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<GameBlock>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameFilterStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [GameFilterState].
extension GameFilterStatePatterns on GameFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameFilterState value)  $default,){
final _that = this;
switch (_that) {
case _GameFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  GameCategorySelection categorySelection,  List<GameBlock> results,  GameFilterStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
return $default(_that.searchQuery,_that.categorySelection,_that.results,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  GameCategorySelection categorySelection,  List<GameBlock> results,  GameFilterStatus status)  $default,) {final _that = this;
switch (_that) {
case _GameFilterState():
return $default(_that.searchQuery,_that.categorySelection,_that.results,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  GameCategorySelection categorySelection,  List<GameBlock> results,  GameFilterStatus status)?  $default,) {final _that = this;
switch (_that) {
case _GameFilterState() when $default != null:
return $default(_that.searchQuery,_that.categorySelection,_that.results,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _GameFilterState implements GameFilterState {
  const _GameFilterState({this.searchQuery = '', this.categorySelection = const GameCategorySelection(), final  List<GameBlock> results = const [], this.status = GameFilterStatus.initial}): _results = results;
  

@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  GameCategorySelection categorySelection;
 final  List<GameBlock> _results;
@override@JsonKey() List<GameBlock> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  GameFilterStatus status;

/// Create a copy of GameFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameFilterStateCopyWith<_GameFilterState> get copyWith => __$GameFilterStateCopyWithImpl<_GameFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameFilterState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categorySelection, categorySelection) || other.categorySelection == categorySelection)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,categorySelection,const DeepCollectionEquality().hash(_results),status);

@override
String toString() {
  return 'GameFilterState(searchQuery: $searchQuery, categorySelection: $categorySelection, results: $results, status: $status)';
}


}

/// @nodoc
abstract mixin class _$GameFilterStateCopyWith<$Res> implements $GameFilterStateCopyWith<$Res> {
  factory _$GameFilterStateCopyWith(_GameFilterState value, $Res Function(_GameFilterState) _then) = __$GameFilterStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, GameCategorySelection categorySelection, List<GameBlock> results, GameFilterStatus status
});




}
/// @nodoc
class __$GameFilterStateCopyWithImpl<$Res>
    implements _$GameFilterStateCopyWith<$Res> {
  __$GameFilterStateCopyWithImpl(this._self, this._then);

  final _GameFilterState _self;
  final $Res Function(_GameFilterState) _then;

/// Create a copy of GameFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? categorySelection = null,Object? results = null,Object? status = null,}) {
  return _then(_GameFilterState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,categorySelection: null == categorySelection ? _self.categorySelection : categorySelection // ignore: cast_nullable_to_non_nullable
as GameCategorySelection,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<GameBlock>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameFilterStatus,
  ));
}


}

// dart format on
