// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventModelV2 {

/// List of markets available for this event
 List<MarketModelV2> get markets;/// Sport ID (1=Soccer, 2=Basketball, etc.)
 int get sportId;/// League ID
 int get leagueId;/// Event ID - unique identifier
 int get eventId;/// Event start date in ISO format (e.g., "2026-01-22T07:30:00Z")
 String get startDate;/// Event start time in epoch milliseconds
 int get startTime;/// Indicates if the event is suspended
 bool get isSuspended;/// Indicates if the event supports parlay
 bool get isParlay;/// Indicates if cash out is available
 bool get isCashOut;/// Event type (e.g., 2=pre-match, 3=live, 8=live/running)
 int get type;/// Event statistics ID
 int get eventStatsId;/// Home team ID
 int get homeId;/// Away team ID
 int get awayId;/// Home team name
 String get homeName;/// Away team name
 String get awayName;/// URL of the home team logo
 String get homeLogo;/// URL of the away team logo
 String get awayLogo;/// Total number of markets available
 int get marketCount;/// Indicates if the event is going live soon
 bool get isGoingLive;/// Indicates if the event is currently live
 bool get isLive;/// Indicates if live streaming is available
 bool get isLiveStream;/// Current part of the game (e.g., 1=first half, 2=second half)
 int get gamePart;/// Current game time in milliseconds
 int get gameTime;/// Score information (polymorphic based on sportId)
 ScoreModelV2? get score;/// Indicates if this event is favorited by the user
 bool get isFavorited;
/// Create a copy of EventModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelV2CopyWith<EventModelV2> get copyWith => _$EventModelV2CopyWithImpl<EventModelV2>(this as EventModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModelV2&&const DeepCollectionEquality().equals(other.markets, markets)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut)&&(identical(other.type, type) || other.type == type)&&(identical(other.eventStatsId, eventStatsId) || other.eventStatsId == eventStatsId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.homeLogo, homeLogo) || other.homeLogo == homeLogo)&&(identical(other.awayLogo, awayLogo) || other.awayLogo == awayLogo)&&(identical(other.marketCount, marketCount) || other.marketCount == marketCount)&&(identical(other.isGoingLive, isGoingLive) || other.isGoingLive == isGoingLive)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.gamePart, gamePart) || other.gamePart == gamePart)&&(identical(other.gameTime, gameTime) || other.gameTime == gameTime)&&(identical(other.score, score) || other.score == score)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}


@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(markets),sportId,leagueId,eventId,startDate,startTime,isSuspended,isParlay,isCashOut,type,eventStatsId,homeId,awayId,homeName,awayName,homeLogo,awayLogo,marketCount,isGoingLive,isLive,isLiveStream,gamePart,gameTime,score,isFavorited]);

@override
String toString() {
  return 'EventModelV2(markets: $markets, sportId: $sportId, leagueId: $leagueId, eventId: $eventId, startDate: $startDate, startTime: $startTime, isSuspended: $isSuspended, isParlay: $isParlay, isCashOut: $isCashOut, type: $type, eventStatsId: $eventStatsId, homeId: $homeId, awayId: $awayId, homeName: $homeName, awayName: $awayName, homeLogo: $homeLogo, awayLogo: $awayLogo, marketCount: $marketCount, isGoingLive: $isGoingLive, isLive: $isLive, isLiveStream: $isLiveStream, gamePart: $gamePart, gameTime: $gameTime, score: $score, isFavorited: $isFavorited)';
}


}

/// @nodoc
abstract mixin class $EventModelV2CopyWith<$Res>  {
  factory $EventModelV2CopyWith(EventModelV2 value, $Res Function(EventModelV2) _then) = _$EventModelV2CopyWithImpl;
@useResult
$Res call({
 List<MarketModelV2> markets, int sportId, int leagueId, int eventId, String startDate, int startTime, bool isSuspended, bool isParlay, bool isCashOut, int type, int eventStatsId, int homeId, int awayId, String homeName, String awayName, String homeLogo, String awayLogo, int marketCount, bool isGoingLive, bool isLive, bool isLiveStream, int gamePart, int gameTime, ScoreModelV2? score, bool isFavorited
});




}
/// @nodoc
class _$EventModelV2CopyWithImpl<$Res>
    implements $EventModelV2CopyWith<$Res> {
  _$EventModelV2CopyWithImpl(this._self, this._then);

  final EventModelV2 _self;
  final $Res Function(EventModelV2) _then;

/// Create a copy of EventModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? markets = null,Object? sportId = null,Object? leagueId = null,Object? eventId = null,Object? startDate = null,Object? startTime = null,Object? isSuspended = null,Object? isParlay = null,Object? isCashOut = null,Object? type = null,Object? eventStatsId = null,Object? homeId = null,Object? awayId = null,Object? homeName = null,Object? awayName = null,Object? homeLogo = null,Object? awayLogo = null,Object? marketCount = null,Object? isGoingLive = null,Object? isLive = null,Object? isLiveStream = null,Object? gamePart = null,Object? gameTime = null,Object? score = freezed,Object? isFavorited = null,}) {
  return _then(_self.copyWith(
markets: null == markets ? _self.markets : markets // ignore: cast_nullable_to_non_nullable
as List<MarketModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,eventStatsId: null == eventStatsId ? _self.eventStatsId : eventStatsId // ignore: cast_nullable_to_non_nullable
as int,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,homeName: null == homeName ? _self.homeName : homeName // ignore: cast_nullable_to_non_nullable
as String,awayName: null == awayName ? _self.awayName : awayName // ignore: cast_nullable_to_non_nullable
as String,homeLogo: null == homeLogo ? _self.homeLogo : homeLogo // ignore: cast_nullable_to_non_nullable
as String,awayLogo: null == awayLogo ? _self.awayLogo : awayLogo // ignore: cast_nullable_to_non_nullable
as String,marketCount: null == marketCount ? _self.marketCount : marketCount // ignore: cast_nullable_to_non_nullable
as int,isGoingLive: null == isGoingLive ? _self.isGoingLive : isGoingLive // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,gamePart: null == gamePart ? _self.gamePart : gamePart // ignore: cast_nullable_to_non_nullable
as int,gameTime: null == gameTime ? _self.gameTime : gameTime // ignore: cast_nullable_to_non_nullable
as int,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as ScoreModelV2?,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EventModelV2].
extension EventModelV2Patterns on EventModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _EventModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _EventModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MarketModelV2> markets,  int sportId,  int leagueId,  int eventId,  String startDate,  int startTime,  bool isSuspended,  bool isParlay,  bool isCashOut,  int type,  int eventStatsId,  int homeId,  int awayId,  String homeName,  String awayName,  String homeLogo,  String awayLogo,  int marketCount,  bool isGoingLive,  bool isLive,  bool isLiveStream,  int gamePart,  int gameTime,  ScoreModelV2? score,  bool isFavorited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModelV2() when $default != null:
return $default(_that.markets,_that.sportId,_that.leagueId,_that.eventId,_that.startDate,_that.startTime,_that.isSuspended,_that.isParlay,_that.isCashOut,_that.type,_that.eventStatsId,_that.homeId,_that.awayId,_that.homeName,_that.awayName,_that.homeLogo,_that.awayLogo,_that.marketCount,_that.isGoingLive,_that.isLive,_that.isLiveStream,_that.gamePart,_that.gameTime,_that.score,_that.isFavorited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MarketModelV2> markets,  int sportId,  int leagueId,  int eventId,  String startDate,  int startTime,  bool isSuspended,  bool isParlay,  bool isCashOut,  int type,  int eventStatsId,  int homeId,  int awayId,  String homeName,  String awayName,  String homeLogo,  String awayLogo,  int marketCount,  bool isGoingLive,  bool isLive,  bool isLiveStream,  int gamePart,  int gameTime,  ScoreModelV2? score,  bool isFavorited)  $default,) {final _that = this;
switch (_that) {
case _EventModelV2():
return $default(_that.markets,_that.sportId,_that.leagueId,_that.eventId,_that.startDate,_that.startTime,_that.isSuspended,_that.isParlay,_that.isCashOut,_that.type,_that.eventStatsId,_that.homeId,_that.awayId,_that.homeName,_that.awayName,_that.homeLogo,_that.awayLogo,_that.marketCount,_that.isGoingLive,_that.isLive,_that.isLiveStream,_that.gamePart,_that.gameTime,_that.score,_that.isFavorited);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MarketModelV2> markets,  int sportId,  int leagueId,  int eventId,  String startDate,  int startTime,  bool isSuspended,  bool isParlay,  bool isCashOut,  int type,  int eventStatsId,  int homeId,  int awayId,  String homeName,  String awayName,  String homeLogo,  String awayLogo,  int marketCount,  bool isGoingLive,  bool isLive,  bool isLiveStream,  int gamePart,  int gameTime,  ScoreModelV2? score,  bool isFavorited)?  $default,) {final _that = this;
switch (_that) {
case _EventModelV2() when $default != null:
return $default(_that.markets,_that.sportId,_that.leagueId,_that.eventId,_that.startDate,_that.startTime,_that.isSuspended,_that.isParlay,_that.isCashOut,_that.type,_that.eventStatsId,_that.homeId,_that.awayId,_that.homeName,_that.awayName,_that.homeLogo,_that.awayLogo,_that.marketCount,_that.isGoingLive,_that.isLive,_that.isLiveStream,_that.gamePart,_that.gameTime,_that.score,_that.isFavorited);case _:
  return null;

}
}

}

/// @nodoc


class _EventModelV2 extends EventModelV2 {
  const _EventModelV2({final  List<MarketModelV2> markets = const [], this.sportId = 0, this.leagueId = 0, this.eventId = 0, this.startDate = '', this.startTime = 0, this.isSuspended = false, this.isParlay = false, this.isCashOut = false, this.type = 0, this.eventStatsId = 0, this.homeId = 0, this.awayId = 0, this.homeName = '', this.awayName = '', this.homeLogo = '', this.awayLogo = '', this.marketCount = 0, this.isGoingLive = false, this.isLive = false, this.isLiveStream = false, this.gamePart = 0, this.gameTime = 0, this.score, this.isFavorited = false}): _markets = markets,super._();
  

/// List of markets available for this event
 final  List<MarketModelV2> _markets;
/// List of markets available for this event
@override@JsonKey() List<MarketModelV2> get markets {
  if (_markets is EqualUnmodifiableListView) return _markets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markets);
}

/// Sport ID (1=Soccer, 2=Basketball, etc.)
@override@JsonKey() final  int sportId;
/// League ID
@override@JsonKey() final  int leagueId;
/// Event ID - unique identifier
@override@JsonKey() final  int eventId;
/// Event start date in ISO format (e.g., "2026-01-22T07:30:00Z")
@override@JsonKey() final  String startDate;
/// Event start time in epoch milliseconds
@override@JsonKey() final  int startTime;
/// Indicates if the event is suspended
@override@JsonKey() final  bool isSuspended;
/// Indicates if the event supports parlay
@override@JsonKey() final  bool isParlay;
/// Indicates if cash out is available
@override@JsonKey() final  bool isCashOut;
/// Event type (e.g., 2=pre-match, 3=live, 8=live/running)
@override@JsonKey() final  int type;
/// Event statistics ID
@override@JsonKey() final  int eventStatsId;
/// Home team ID
@override@JsonKey() final  int homeId;
/// Away team ID
@override@JsonKey() final  int awayId;
/// Home team name
@override@JsonKey() final  String homeName;
/// Away team name
@override@JsonKey() final  String awayName;
/// URL of the home team logo
@override@JsonKey() final  String homeLogo;
/// URL of the away team logo
@override@JsonKey() final  String awayLogo;
/// Total number of markets available
@override@JsonKey() final  int marketCount;
/// Indicates if the event is going live soon
@override@JsonKey() final  bool isGoingLive;
/// Indicates if the event is currently live
@override@JsonKey() final  bool isLive;
/// Indicates if live streaming is available
@override@JsonKey() final  bool isLiveStream;
/// Current part of the game (e.g., 1=first half, 2=second half)
@override@JsonKey() final  int gamePart;
/// Current game time in milliseconds
@override@JsonKey() final  int gameTime;
/// Score information (polymorphic based on sportId)
@override final  ScoreModelV2? score;
/// Indicates if this event is favorited by the user
@override@JsonKey() final  bool isFavorited;

/// Create a copy of EventModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelV2CopyWith<_EventModelV2> get copyWith => __$EventModelV2CopyWithImpl<_EventModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModelV2&&const DeepCollectionEquality().equals(other._markets, _markets)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut)&&(identical(other.type, type) || other.type == type)&&(identical(other.eventStatsId, eventStatsId) || other.eventStatsId == eventStatsId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.homeLogo, homeLogo) || other.homeLogo == homeLogo)&&(identical(other.awayLogo, awayLogo) || other.awayLogo == awayLogo)&&(identical(other.marketCount, marketCount) || other.marketCount == marketCount)&&(identical(other.isGoingLive, isGoingLive) || other.isGoingLive == isGoingLive)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.gamePart, gamePart) || other.gamePart == gamePart)&&(identical(other.gameTime, gameTime) || other.gameTime == gameTime)&&(identical(other.score, score) || other.score == score)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}


@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_markets),sportId,leagueId,eventId,startDate,startTime,isSuspended,isParlay,isCashOut,type,eventStatsId,homeId,awayId,homeName,awayName,homeLogo,awayLogo,marketCount,isGoingLive,isLive,isLiveStream,gamePart,gameTime,score,isFavorited]);

@override
String toString() {
  return 'EventModelV2(markets: $markets, sportId: $sportId, leagueId: $leagueId, eventId: $eventId, startDate: $startDate, startTime: $startTime, isSuspended: $isSuspended, isParlay: $isParlay, isCashOut: $isCashOut, type: $type, eventStatsId: $eventStatsId, homeId: $homeId, awayId: $awayId, homeName: $homeName, awayName: $awayName, homeLogo: $homeLogo, awayLogo: $awayLogo, marketCount: $marketCount, isGoingLive: $isGoingLive, isLive: $isLive, isLiveStream: $isLiveStream, gamePart: $gamePart, gameTime: $gameTime, score: $score, isFavorited: $isFavorited)';
}


}

/// @nodoc
abstract mixin class _$EventModelV2CopyWith<$Res> implements $EventModelV2CopyWith<$Res> {
  factory _$EventModelV2CopyWith(_EventModelV2 value, $Res Function(_EventModelV2) _then) = __$EventModelV2CopyWithImpl;
@override @useResult
$Res call({
 List<MarketModelV2> markets, int sportId, int leagueId, int eventId, String startDate, int startTime, bool isSuspended, bool isParlay, bool isCashOut, int type, int eventStatsId, int homeId, int awayId, String homeName, String awayName, String homeLogo, String awayLogo, int marketCount, bool isGoingLive, bool isLive, bool isLiveStream, int gamePart, int gameTime, ScoreModelV2? score, bool isFavorited
});




}
/// @nodoc
class __$EventModelV2CopyWithImpl<$Res>
    implements _$EventModelV2CopyWith<$Res> {
  __$EventModelV2CopyWithImpl(this._self, this._then);

  final _EventModelV2 _self;
  final $Res Function(_EventModelV2) _then;

/// Create a copy of EventModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? markets = null,Object? sportId = null,Object? leagueId = null,Object? eventId = null,Object? startDate = null,Object? startTime = null,Object? isSuspended = null,Object? isParlay = null,Object? isCashOut = null,Object? type = null,Object? eventStatsId = null,Object? homeId = null,Object? awayId = null,Object? homeName = null,Object? awayName = null,Object? homeLogo = null,Object? awayLogo = null,Object? marketCount = null,Object? isGoingLive = null,Object? isLive = null,Object? isLiveStream = null,Object? gamePart = null,Object? gameTime = null,Object? score = freezed,Object? isFavorited = null,}) {
  return _then(_EventModelV2(
markets: null == markets ? _self._markets : markets // ignore: cast_nullable_to_non_nullable
as List<MarketModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isParlay: null == isParlay ? _self.isParlay : isParlay // ignore: cast_nullable_to_non_nullable
as bool,isCashOut: null == isCashOut ? _self.isCashOut : isCashOut // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,eventStatsId: null == eventStatsId ? _self.eventStatsId : eventStatsId // ignore: cast_nullable_to_non_nullable
as int,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,homeName: null == homeName ? _self.homeName : homeName // ignore: cast_nullable_to_non_nullable
as String,awayName: null == awayName ? _self.awayName : awayName // ignore: cast_nullable_to_non_nullable
as String,homeLogo: null == homeLogo ? _self.homeLogo : homeLogo // ignore: cast_nullable_to_non_nullable
as String,awayLogo: null == awayLogo ? _self.awayLogo : awayLogo // ignore: cast_nullable_to_non_nullable
as String,marketCount: null == marketCount ? _self.marketCount : marketCount // ignore: cast_nullable_to_non_nullable
as int,isGoingLive: null == isGoingLive ? _self.isGoingLive : isGoingLive // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,gamePart: null == gamePart ? _self.gamePart : gamePart // ignore: cast_nullable_to_non_nullable
as int,gameTime: null == gameTime ? _self.gameTime : gameTime // ignore: cast_nullable_to_non_nullable
as int,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as ScoreModelV2?,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
