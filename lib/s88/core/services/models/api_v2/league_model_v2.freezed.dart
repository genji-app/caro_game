// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_model_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LeagueModelV2 {

/// List of events in the league
 List<EventModelV2> get events;/// Sport ID (1=Soccer, 2=Basketball, etc.)
 int get sportId;/// League ID - unique identifier
 int get leagueId;/// Localized league name
 String get leagueName;/// League name in English
 String get leagueNameEn;/// League logo URL
 String get leagueLogo;/// League priority order (lower value = higher priority)
 int get priorityOrder;/// Indicates if this league is favorited by the user
 bool get isFavorited;
/// Create a copy of LeagueModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueModelV2CopyWith<LeagueModelV2> get copyWith => _$LeagueModelV2CopyWithImpl<LeagueModelV2>(this as LeagueModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueModelV2&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueNameEn, leagueNameEn) || other.leagueNameEn == leagueNameEn)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.priorityOrder, priorityOrder) || other.priorityOrder == priorityOrder)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(events),sportId,leagueId,leagueName,leagueNameEn,leagueLogo,priorityOrder,isFavorited);

@override
String toString() {
  return 'LeagueModelV2(events: $events, sportId: $sportId, leagueId: $leagueId, leagueName: $leagueName, leagueNameEn: $leagueNameEn, leagueLogo: $leagueLogo, priorityOrder: $priorityOrder, isFavorited: $isFavorited)';
}


}

/// @nodoc
abstract mixin class $LeagueModelV2CopyWith<$Res>  {
  factory $LeagueModelV2CopyWith(LeagueModelV2 value, $Res Function(LeagueModelV2) _then) = _$LeagueModelV2CopyWithImpl;
@useResult
$Res call({
 List<EventModelV2> events, int sportId, int leagueId, String leagueName, String leagueNameEn, String leagueLogo, int priorityOrder, bool isFavorited
});




}
/// @nodoc
class _$LeagueModelV2CopyWithImpl<$Res>
    implements $LeagueModelV2CopyWith<$Res> {
  _$LeagueModelV2CopyWithImpl(this._self, this._then);

  final LeagueModelV2 _self;
  final $Res Function(LeagueModelV2) _then;

/// Create a copy of LeagueModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? events = null,Object? sportId = null,Object? leagueId = null,Object? leagueName = null,Object? leagueNameEn = null,Object? leagueLogo = null,Object? priorityOrder = null,Object? isFavorited = null,}) {
  return _then(_self.copyWith(
events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<EventModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,leagueNameEn: null == leagueNameEn ? _self.leagueNameEn : leagueNameEn // ignore: cast_nullable_to_non_nullable
as String,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,priorityOrder: null == priorityOrder ? _self.priorityOrder : priorityOrder // ignore: cast_nullable_to_non_nullable
as int,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeagueModelV2].
extension LeagueModelV2Patterns on LeagueModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _LeagueModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EventModelV2> events,  int sportId,  int leagueId,  String leagueName,  String leagueNameEn,  String leagueLogo,  int priorityOrder,  bool isFavorited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
return $default(_that.events,_that.sportId,_that.leagueId,_that.leagueName,_that.leagueNameEn,_that.leagueLogo,_that.priorityOrder,_that.isFavorited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EventModelV2> events,  int sportId,  int leagueId,  String leagueName,  String leagueNameEn,  String leagueLogo,  int priorityOrder,  bool isFavorited)  $default,) {final _that = this;
switch (_that) {
case _LeagueModelV2():
return $default(_that.events,_that.sportId,_that.leagueId,_that.leagueName,_that.leagueNameEn,_that.leagueLogo,_that.priorityOrder,_that.isFavorited);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EventModelV2> events,  int sportId,  int leagueId,  String leagueName,  String leagueNameEn,  String leagueLogo,  int priorityOrder,  bool isFavorited)?  $default,) {final _that = this;
switch (_that) {
case _LeagueModelV2() when $default != null:
return $default(_that.events,_that.sportId,_that.leagueId,_that.leagueName,_that.leagueNameEn,_that.leagueLogo,_that.priorityOrder,_that.isFavorited);case _:
  return null;

}
}

}

/// @nodoc


class _LeagueModelV2 extends LeagueModelV2 {
  const _LeagueModelV2({final  List<EventModelV2> events = const [], this.sportId = 0, this.leagueId = 0, this.leagueName = '', this.leagueNameEn = '', this.leagueLogo = '', this.priorityOrder = 0, this.isFavorited = false}): _events = events,super._();
  

/// List of events in the league
 final  List<EventModelV2> _events;
/// List of events in the league
@override@JsonKey() List<EventModelV2> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

/// Sport ID (1=Soccer, 2=Basketball, etc.)
@override@JsonKey() final  int sportId;
/// League ID - unique identifier
@override@JsonKey() final  int leagueId;
/// Localized league name
@override@JsonKey() final  String leagueName;
/// League name in English
@override@JsonKey() final  String leagueNameEn;
/// League logo URL
@override@JsonKey() final  String leagueLogo;
/// League priority order (lower value = higher priority)
@override@JsonKey() final  int priorityOrder;
/// Indicates if this league is favorited by the user
@override@JsonKey() final  bool isFavorited;

/// Create a copy of LeagueModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueModelV2CopyWith<_LeagueModelV2> get copyWith => __$LeagueModelV2CopyWithImpl<_LeagueModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueModelV2&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.leagueNameEn, leagueNameEn) || other.leagueNameEn == leagueNameEn)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.priorityOrder, priorityOrder) || other.priorityOrder == priorityOrder)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_events),sportId,leagueId,leagueName,leagueNameEn,leagueLogo,priorityOrder,isFavorited);

@override
String toString() {
  return 'LeagueModelV2(events: $events, sportId: $sportId, leagueId: $leagueId, leagueName: $leagueName, leagueNameEn: $leagueNameEn, leagueLogo: $leagueLogo, priorityOrder: $priorityOrder, isFavorited: $isFavorited)';
}


}

/// @nodoc
abstract mixin class _$LeagueModelV2CopyWith<$Res> implements $LeagueModelV2CopyWith<$Res> {
  factory _$LeagueModelV2CopyWith(_LeagueModelV2 value, $Res Function(_LeagueModelV2) _then) = __$LeagueModelV2CopyWithImpl;
@override @useResult
$Res call({
 List<EventModelV2> events, int sportId, int leagueId, String leagueName, String leagueNameEn, String leagueLogo, int priorityOrder, bool isFavorited
});




}
/// @nodoc
class __$LeagueModelV2CopyWithImpl<$Res>
    implements _$LeagueModelV2CopyWith<$Res> {
  __$LeagueModelV2CopyWithImpl(this._self, this._then);

  final _LeagueModelV2 _self;
  final $Res Function(_LeagueModelV2) _then;

/// Create a copy of LeagueModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? events = null,Object? sportId = null,Object? leagueId = null,Object? leagueName = null,Object? leagueNameEn = null,Object? leagueLogo = null,Object? priorityOrder = null,Object? isFavorited = null,}) {
  return _then(_LeagueModelV2(
events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<EventModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,leagueNameEn: null == leagueNameEn ? _self.leagueNameEn : leagueNameEn // ignore: cast_nullable_to_non_nullable
as String,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,priorityOrder: null == priorityOrder ? _self.priorityOrder : priorityOrder // ignore: cast_nullable_to_non_nullable
as int,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
