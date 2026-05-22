// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventsRequestModel {

/// Sport ID (required)
/// 1=Soccer, 2=Basketball, 3=Boxing, 5=Tennis, etc.
 int get sportId;/// Time range: 0=Live, 1=Today, 2=Early, 3=Today+Early
 int get timeRange;/// Sport type ID (only for Boxing sportId=3)
/// 1=Muay Thai, 2=MMA/UFC, 3=Boxing
 int? get sportTypeId;/// Filter by team ID
 int? get teamId;/// Filter by league IDs
 List<int>? get leagueIds;/// Filter by date (format: yyyy-M-d)
 String? get date;/// Timezone offset in minutes
/// Default: -420 = UTC+7 (Vietnam)
 int get tzOffset;/// Is mobile device
 bool get isMobile;/// Sort by start time
 bool get sortByTime;/// Only pinned leagues
 bool get onlyPinLeague;/// Only parlay events
 bool get onlyParlay;/// Only GS events
 bool get onlyGs;/// Filter: has live stream
 bool get isLiveStream;/// Filter: has live tracker
 bool get isLiveTracker;/// Filter: has statistics
 bool get isSportRadar;/// Filter: has cash out
 bool get isCashOut;
/// Create a copy of EventsRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsRequestModelCopyWith<EventsRequestModel> get copyWith => _$EventsRequestModelCopyWithImpl<EventsRequestModel>(this as EventsRequestModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsRequestModel&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.sportTypeId, sportTypeId) || other.sportTypeId == sportTypeId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&const DeepCollectionEquality().equals(other.leagueIds, leagueIds)&&(identical(other.date, date) || other.date == date)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset)&&(identical(other.isMobile, isMobile) || other.isMobile == isMobile)&&(identical(other.sortByTime, sortByTime) || other.sortByTime == sortByTime)&&(identical(other.onlyPinLeague, onlyPinLeague) || other.onlyPinLeague == onlyPinLeague)&&(identical(other.onlyParlay, onlyParlay) || other.onlyParlay == onlyParlay)&&(identical(other.onlyGs, onlyGs) || other.onlyGs == onlyGs)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.isLiveTracker, isLiveTracker) || other.isLiveTracker == isLiveTracker)&&(identical(other.isSportRadar, isSportRadar) || other.isSportRadar == isSportRadar)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,timeRange,sportTypeId,teamId,const DeepCollectionEquality().hash(leagueIds),date,tzOffset,isMobile,sortByTime,onlyPinLeague,onlyParlay,onlyGs,isLiveStream,isLiveTracker,isSportRadar,isCashOut);

@override
String toString() {
  return 'EventsRequestModel(sportId: $sportId, timeRange: $timeRange, sportTypeId: $sportTypeId, teamId: $teamId, leagueIds: $leagueIds, date: $date, tzOffset: $tzOffset, isMobile: $isMobile, sortByTime: $sortByTime, onlyPinLeague: $onlyPinLeague, onlyParlay: $onlyParlay, onlyGs: $onlyGs, isLiveStream: $isLiveStream, isLiveTracker: $isLiveTracker, isSportRadar: $isSportRadar, isCashOut: $isCashOut)';
}


}

/// @nodoc
abstract mixin class $EventsRequestModelCopyWith<$Res>  {
  factory $EventsRequestModelCopyWith(EventsRequestModel value, $Res Function(EventsRequestModel) _then) = _$EventsRequestModelCopyWithImpl;
@useResult
$Res call({
 int sportId, int timeRange, int? sportTypeId, int? teamId, List<int>? leagueIds, String? date, int tzOffset, bool isMobile, bool sortByTime, bool onlyPinLeague, bool onlyParlay, bool onlyGs, bool isLiveStream, bool isLiveTracker, bool isSportRadar, bool isCashOut
});




}
/// @nodoc
class _$EventsRequestModelCopyWithImpl<$Res>
    implements $EventsRequestModelCopyWith<$Res> {
  _$EventsRequestModelCopyWithImpl(this._self, this._then);

  final EventsRequestModel _self;
  final $Res Function(EventsRequestModel) _then;

/// Create a copy of EventsRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? timeRange = null,Object? sportTypeId = freezed,Object? teamId = freezed,Object? leagueIds = freezed,Object? date = freezed,Object? tzOffset = null,Object? isMobile = null,Object? sortByTime = null,Object? onlyPinLeague = null,Object? onlyParlay = null,Object? onlyGs = null,Object? isLiveStream = null,Object? isLiveTracker = null,Object? isSportRadar = null,Object? isCashOut = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as int,sportTypeId: freezed == sportTypeId ? _self.sportTypeId : sportTypeId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,leagueIds: freezed == leagueIds ? _self.leagueIds : leagueIds // ignore: cast_nullable_to_non_nullable
as List<int>?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,tzOffset: null == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int,isMobile: null == isMobile ? _self.isMobile : isMobile // ignore: cast_nullable_to_non_nullable
as bool,sortByTime: null == sortByTime ? _self.sortByTime : sortByTime // ignore: cast_nullable_to_non_nullable
as bool,onlyPinLeague: null == onlyPinLeague ? _self.onlyPinLeague : onlyPinLeague // ignore: cast_nullable_to_non_nullable
as bool,onlyParlay: null == onlyParlay ? _self.onlyParlay : onlyParlay // ignore: cast_nullable_to_non_nullable
as bool,onlyGs: null == onlyGs ? _self.onlyGs : onlyGs // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,isLiveTracker: null == isLiveTracker ? _self.isLiveTracker : isLiveTracker // ignore: cast_nullable_to_non_nullable
as bool,isSportRadar: null == isSportRadar ? _self.isSportRadar : isSportRadar // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EventsRequestModel].
extension EventsRequestModelPatterns on EventsRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventsRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventsRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _EventsRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventsRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  int timeRange,  int? sportTypeId,  int? teamId,  List<int>? leagueIds,  String? date,  int tzOffset,  bool isMobile,  bool sortByTime,  bool onlyPinLeague,  bool onlyParlay,  bool onlyGs,  bool isLiveStream,  bool isLiveTracker,  bool isSportRadar,  bool isCashOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
return $default(_that.sportId,_that.timeRange,_that.sportTypeId,_that.teamId,_that.leagueIds,_that.date,_that.tzOffset,_that.isMobile,_that.sortByTime,_that.onlyPinLeague,_that.onlyParlay,_that.onlyGs,_that.isLiveStream,_that.isLiveTracker,_that.isSportRadar,_that.isCashOut);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  int timeRange,  int? sportTypeId,  int? teamId,  List<int>? leagueIds,  String? date,  int tzOffset,  bool isMobile,  bool sortByTime,  bool onlyPinLeague,  bool onlyParlay,  bool onlyGs,  bool isLiveStream,  bool isLiveTracker,  bool isSportRadar,  bool isCashOut)  $default,) {final _that = this;
switch (_that) {
case _EventsRequestModel():
return $default(_that.sportId,_that.timeRange,_that.sportTypeId,_that.teamId,_that.leagueIds,_that.date,_that.tzOffset,_that.isMobile,_that.sortByTime,_that.onlyPinLeague,_that.onlyParlay,_that.onlyGs,_that.isLiveStream,_that.isLiveTracker,_that.isSportRadar,_that.isCashOut);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  int timeRange,  int? sportTypeId,  int? teamId,  List<int>? leagueIds,  String? date,  int tzOffset,  bool isMobile,  bool sortByTime,  bool onlyPinLeague,  bool onlyParlay,  bool onlyGs,  bool isLiveStream,  bool isLiveTracker,  bool isSportRadar,  bool isCashOut)?  $default,) {final _that = this;
switch (_that) {
case _EventsRequestModel() when $default != null:
return $default(_that.sportId,_that.timeRange,_that.sportTypeId,_that.teamId,_that.leagueIds,_that.date,_that.tzOffset,_that.isMobile,_that.sortByTime,_that.onlyPinLeague,_that.onlyParlay,_that.onlyGs,_that.isLiveStream,_that.isLiveTracker,_that.isSportRadar,_that.isCashOut);case _:
  return null;

}
}

}

/// @nodoc


class _EventsRequestModel extends EventsRequestModel {
  const _EventsRequestModel({required this.sportId, this.timeRange = 0, this.sportTypeId, this.teamId, final  List<int>? leagueIds, this.date, this.tzOffset = -420, this.isMobile = true, this.sortByTime = false, this.onlyPinLeague = false, this.onlyParlay = false, this.onlyGs = false, this.isLiveStream = false, this.isLiveTracker = false, this.isSportRadar = false, this.isCashOut = false}): _leagueIds = leagueIds,super._();
  

/// Sport ID (required)
/// 1=Soccer, 2=Basketball, 3=Boxing, 5=Tennis, etc.
@override final  int sportId;
/// Time range: 0=Live, 1=Today, 2=Early, 3=Today+Early
@override@JsonKey() final  int timeRange;
/// Sport type ID (only for Boxing sportId=3)
/// 1=Muay Thai, 2=MMA/UFC, 3=Boxing
@override final  int? sportTypeId;
/// Filter by team ID
@override final  int? teamId;
/// Filter by league IDs
 final  List<int>? _leagueIds;
/// Filter by league IDs
@override List<int>? get leagueIds {
  final value = _leagueIds;
  if (value == null) return null;
  if (_leagueIds is EqualUnmodifiableListView) return _leagueIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Filter by date (format: yyyy-M-d)
@override final  String? date;
/// Timezone offset in minutes
/// Default: -420 = UTC+7 (Vietnam)
@override@JsonKey() final  int tzOffset;
/// Is mobile device
@override@JsonKey() final  bool isMobile;
/// Sort by start time
@override@JsonKey() final  bool sortByTime;
/// Only pinned leagues
@override@JsonKey() final  bool onlyPinLeague;
/// Only parlay events
@override@JsonKey() final  bool onlyParlay;
/// Only GS events
@override@JsonKey() final  bool onlyGs;
/// Filter: has live stream
@override@JsonKey() final  bool isLiveStream;
/// Filter: has live tracker
@override@JsonKey() final  bool isLiveTracker;
/// Filter: has statistics
@override@JsonKey() final  bool isSportRadar;
/// Filter: has cash out
@override@JsonKey() final  bool isCashOut;

/// Create a copy of EventsRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventsRequestModelCopyWith<_EventsRequestModel> get copyWith => __$EventsRequestModelCopyWithImpl<_EventsRequestModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventsRequestModel&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.timeRange, timeRange) || other.timeRange == timeRange)&&(identical(other.sportTypeId, sportTypeId) || other.sportTypeId == sportTypeId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&const DeepCollectionEquality().equals(other._leagueIds, _leagueIds)&&(identical(other.date, date) || other.date == date)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset)&&(identical(other.isMobile, isMobile) || other.isMobile == isMobile)&&(identical(other.sortByTime, sortByTime) || other.sortByTime == sortByTime)&&(identical(other.onlyPinLeague, onlyPinLeague) || other.onlyPinLeague == onlyPinLeague)&&(identical(other.onlyParlay, onlyParlay) || other.onlyParlay == onlyParlay)&&(identical(other.onlyGs, onlyGs) || other.onlyGs == onlyGs)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.isLiveTracker, isLiveTracker) || other.isLiveTracker == isLiveTracker)&&(identical(other.isSportRadar, isSportRadar) || other.isSportRadar == isSportRadar)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,timeRange,sportTypeId,teamId,const DeepCollectionEquality().hash(_leagueIds),date,tzOffset,isMobile,sortByTime,onlyPinLeague,onlyParlay,onlyGs,isLiveStream,isLiveTracker,isSportRadar,isCashOut);

@override
String toString() {
  return 'EventsRequestModel(sportId: $sportId, timeRange: $timeRange, sportTypeId: $sportTypeId, teamId: $teamId, leagueIds: $leagueIds, date: $date, tzOffset: $tzOffset, isMobile: $isMobile, sortByTime: $sortByTime, onlyPinLeague: $onlyPinLeague, onlyParlay: $onlyParlay, onlyGs: $onlyGs, isLiveStream: $isLiveStream, isLiveTracker: $isLiveTracker, isSportRadar: $isSportRadar, isCashOut: $isCashOut)';
}


}

/// @nodoc
abstract mixin class _$EventsRequestModelCopyWith<$Res> implements $EventsRequestModelCopyWith<$Res> {
  factory _$EventsRequestModelCopyWith(_EventsRequestModel value, $Res Function(_EventsRequestModel) _then) = __$EventsRequestModelCopyWithImpl;
@override @useResult
$Res call({
 int sportId, int timeRange, int? sportTypeId, int? teamId, List<int>? leagueIds, String? date, int tzOffset, bool isMobile, bool sortByTime, bool onlyPinLeague, bool onlyParlay, bool onlyGs, bool isLiveStream, bool isLiveTracker, bool isSportRadar, bool isCashOut
});




}
/// @nodoc
class __$EventsRequestModelCopyWithImpl<$Res>
    implements _$EventsRequestModelCopyWith<$Res> {
  __$EventsRequestModelCopyWithImpl(this._self, this._then);

  final _EventsRequestModel _self;
  final $Res Function(_EventsRequestModel) _then;

/// Create a copy of EventsRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? timeRange = null,Object? sportTypeId = freezed,Object? teamId = freezed,Object? leagueIds = freezed,Object? date = freezed,Object? tzOffset = null,Object? isMobile = null,Object? sortByTime = null,Object? onlyPinLeague = null,Object? onlyParlay = null,Object? onlyGs = null,Object? isLiveStream = null,Object? isLiveTracker = null,Object? isSportRadar = null,Object? isCashOut = null,}) {
  return _then(_EventsRequestModel(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,timeRange: null == timeRange ? _self.timeRange : timeRange // ignore: cast_nullable_to_non_nullable
as int,sportTypeId: freezed == sportTypeId ? _self.sportTypeId : sportTypeId // ignore: cast_nullable_to_non_nullable
as int?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,leagueIds: freezed == leagueIds ? _self._leagueIds : leagueIds // ignore: cast_nullable_to_non_nullable
as List<int>?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,tzOffset: null == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int,isMobile: null == isMobile ? _self.isMobile : isMobile // ignore: cast_nullable_to_non_nullable
as bool,sortByTime: null == sortByTime ? _self.sortByTime : sortByTime // ignore: cast_nullable_to_non_nullable
as bool,onlyPinLeague: null == onlyPinLeague ? _self.onlyPinLeague : onlyPinLeague // ignore: cast_nullable_to_non_nullable
as bool,onlyParlay: null == onlyParlay ? _self.onlyParlay : onlyParlay // ignore: cast_nullable_to_non_nullable
as bool,onlyGs: null == onlyGs ? _self.onlyGs : onlyGs // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,isLiveTracker: null == isLiveTracker ? _self.isLiveTracker : isLiveTracker // ignore: cast_nullable_to_non_nullable
as bool,isSportRadar: null == isSportRadar ? _self.isSportRadar : isSportRadar // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
