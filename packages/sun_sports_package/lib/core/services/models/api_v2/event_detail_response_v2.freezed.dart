// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_detail_response_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventDetailResponseV2 {

/// Children events (Corner, Extra Time, Penalty)
 List<EventDetailResponseV2> get children;/// Full markets array
 List<MarketModelV2> get markets;/// Sport ID (1=Soccer, 2=Basketball, etc.)
 int get sportId;/// League ID
 int get leagueId;/// Event ID - unique identifier
 int get eventId;/// Event start date in ISO format
 String get startDate;/// Event start time in epoch milliseconds
 int get startTime;/// Indicates if the event is suspended
 bool get isSuspended;/// Indicates if the event is hidden
 bool get isHidden;/// Indicates if the event supports parlay
 bool get isParlay;/// Indicates if cash out is available
 bool get isCashOut;/// Event type
 int get type;/// Event statistics ID for tracker
 int get eventStatsId;/// Home team ID
 int get homeId;/// Away team ID
 int get awayId;/// Home team name
 String get homeName;/// Away team name
 String get awayName;/// Home team logo URL
 String get homeLogo;/// Away team logo URL
 String get awayLogo;/// Total number of markets available
 int get marketCount;/// Market group IDs for tab filtering
 List<int>? get marketGroups;/// Indicates if the event is hot/featured
 bool get isHot;/// Indicates if the event is going live soon
 bool get isGoingLive;/// Indicates if the event is currently live
 bool get isLive;/// Indicates if live streaming is available
 bool get isLiveStream;/// Current part of the game (1=1H, 2=2H, 3=HT, etc.)
 int get gamePart;/// Current game time in milliseconds
 int get gameTime;/// Stoppage time in milliseconds
 int get stoppageTime;/// Raw score data (parse separately based on sportId)
 Map<String, dynamic>? get scoreRaw;/// Child type (only for child events: 1=Extra, 2=Corner, 3=Penalty)
 int? get childType;
/// Create a copy of EventDetailResponseV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDetailResponseV2CopyWith<EventDetailResponseV2> get copyWith => _$EventDetailResponseV2CopyWithImpl<EventDetailResponseV2>(this as EventDetailResponseV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDetailResponseV2&&const DeepCollectionEquality().equals(other.children, children)&&const DeepCollectionEquality().equals(other.markets, markets)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut)&&(identical(other.type, type) || other.type == type)&&(identical(other.eventStatsId, eventStatsId) || other.eventStatsId == eventStatsId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.homeLogo, homeLogo) || other.homeLogo == homeLogo)&&(identical(other.awayLogo, awayLogo) || other.awayLogo == awayLogo)&&(identical(other.marketCount, marketCount) || other.marketCount == marketCount)&&const DeepCollectionEquality().equals(other.marketGroups, marketGroups)&&(identical(other.isHot, isHot) || other.isHot == isHot)&&(identical(other.isGoingLive, isGoingLive) || other.isGoingLive == isGoingLive)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.gamePart, gamePart) || other.gamePart == gamePart)&&(identical(other.gameTime, gameTime) || other.gameTime == gameTime)&&(identical(other.stoppageTime, stoppageTime) || other.stoppageTime == stoppageTime)&&const DeepCollectionEquality().equals(other.scoreRaw, scoreRaw)&&(identical(other.childType, childType) || other.childType == childType));
}


@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(children),const DeepCollectionEquality().hash(markets),sportId,leagueId,eventId,startDate,startTime,isSuspended,isHidden,isParlay,isCashOut,type,eventStatsId,homeId,awayId,homeName,awayName,homeLogo,awayLogo,marketCount,const DeepCollectionEquality().hash(marketGroups),isHot,isGoingLive,isLive,isLiveStream,gamePart,gameTime,stoppageTime,const DeepCollectionEquality().hash(scoreRaw),childType]);

@override
String toString() {
  return 'EventDetailResponseV2(children: $children, markets: $markets, sportId: $sportId, leagueId: $leagueId, eventId: $eventId, startDate: $startDate, startTime: $startTime, isSuspended: $isSuspended, isHidden: $isHidden, isParlay: $isParlay, isCashOut: $isCashOut, type: $type, eventStatsId: $eventStatsId, homeId: $homeId, awayId: $awayId, homeName: $homeName, awayName: $awayName, homeLogo: $homeLogo, awayLogo: $awayLogo, marketCount: $marketCount, marketGroups: $marketGroups, isHot: $isHot, isGoingLive: $isGoingLive, isLive: $isLive, isLiveStream: $isLiveStream, gamePart: $gamePart, gameTime: $gameTime, stoppageTime: $stoppageTime, scoreRaw: $scoreRaw, childType: $childType)';
}


}

/// @nodoc
abstract mixin class $EventDetailResponseV2CopyWith<$Res>  {
  factory $EventDetailResponseV2CopyWith(EventDetailResponseV2 value, $Res Function(EventDetailResponseV2) _then) = _$EventDetailResponseV2CopyWithImpl;
@useResult
$Res call({
 List<EventDetailResponseV2> children, List<MarketModelV2> markets, int sportId, int leagueId, int eventId, String startDate, int startTime, bool isSuspended, bool isHidden, bool isParlay, bool isCashOut, int type, int eventStatsId, int homeId, int awayId, String homeName, String awayName, String homeLogo, String awayLogo, int marketCount, List<int>? marketGroups, bool isHot, bool isGoingLive, bool isLive, bool isLiveStream, int gamePart, int gameTime, int stoppageTime, Map<String, dynamic>? scoreRaw, int? childType
});




}
/// @nodoc
class _$EventDetailResponseV2CopyWithImpl<$Res>
    implements $EventDetailResponseV2CopyWith<$Res> {
  _$EventDetailResponseV2CopyWithImpl(this._self, this._then);

  final EventDetailResponseV2 _self;
  final $Res Function(EventDetailResponseV2) _then;

/// Create a copy of EventDetailResponseV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? children = null,Object? markets = null,Object? sportId = null,Object? leagueId = null,Object? eventId = null,Object? startDate = null,Object? startTime = null,Object? isSuspended = null,Object? isHidden = null,Object? isParlay = null,Object? isCashOut = null,Object? type = null,Object? eventStatsId = null,Object? homeId = null,Object? awayId = null,Object? homeName = null,Object? awayName = null,Object? homeLogo = null,Object? awayLogo = null,Object? marketCount = null,Object? marketGroups = freezed,Object? isHot = null,Object? isGoingLive = null,Object? isLive = null,Object? isLiveStream = null,Object? gamePart = null,Object? gameTime = null,Object? stoppageTime = null,Object? scoreRaw = freezed,Object? childType = freezed,}) {
  return _then(_self.copyWith(
children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<EventDetailResponseV2>,markets: null == markets ? _self.markets : markets // ignore: cast_nullable_to_non_nullable
as List<MarketModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
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
as int,marketGroups: freezed == marketGroups ? _self.marketGroups : marketGroups // ignore: cast_nullable_to_non_nullable
as List<int>?,isHot: null == isHot ? _self.isHot : isHot // ignore: cast_nullable_to_non_nullable
as bool,isGoingLive: null == isGoingLive ? _self.isGoingLive : isGoingLive // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,gamePart: null == gamePart ? _self.gamePart : gamePart // ignore: cast_nullable_to_non_nullable
as int,gameTime: null == gameTime ? _self.gameTime : gameTime // ignore: cast_nullable_to_non_nullable
as int,stoppageTime: null == stoppageTime ? _self.stoppageTime : stoppageTime // ignore: cast_nullable_to_non_nullable
as int,scoreRaw: freezed == scoreRaw ? _self.scoreRaw : scoreRaw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,childType: freezed == childType ? _self.childType : childType // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventDetailResponseV2].
extension EventDetailResponseV2Patterns on EventDetailResponseV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDetailResponseV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDetailResponseV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDetailResponseV2 value)  $default,){
final _that = this;
switch (_that) {
case _EventDetailResponseV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDetailResponseV2 value)?  $default,){
final _that = this;
switch (_that) {
case _EventDetailResponseV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EventDetailResponseV2> children,  List<MarketModelV2> markets,  int sportId,  int leagueId,  int eventId,  String startDate,  int startTime,  bool isSuspended,  bool isHidden,  bool isParlay,  bool isCashOut,  int type,  int eventStatsId,  int homeId,  int awayId,  String homeName,  String awayName,  String homeLogo,  String awayLogo,  int marketCount,  List<int>? marketGroups,  bool isHot,  bool isGoingLive,  bool isLive,  bool isLiveStream,  int gamePart,  int gameTime,  int stoppageTime,  Map<String, dynamic>? scoreRaw,  int? childType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDetailResponseV2() when $default != null:
return $default(_that.children,_that.markets,_that.sportId,_that.leagueId,_that.eventId,_that.startDate,_that.startTime,_that.isSuspended,_that.isHidden,_that.isParlay,_that.isCashOut,_that.type,_that.eventStatsId,_that.homeId,_that.awayId,_that.homeName,_that.awayName,_that.homeLogo,_that.awayLogo,_that.marketCount,_that.marketGroups,_that.isHot,_that.isGoingLive,_that.isLive,_that.isLiveStream,_that.gamePart,_that.gameTime,_that.stoppageTime,_that.scoreRaw,_that.childType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EventDetailResponseV2> children,  List<MarketModelV2> markets,  int sportId,  int leagueId,  int eventId,  String startDate,  int startTime,  bool isSuspended,  bool isHidden,  bool isParlay,  bool isCashOut,  int type,  int eventStatsId,  int homeId,  int awayId,  String homeName,  String awayName,  String homeLogo,  String awayLogo,  int marketCount,  List<int>? marketGroups,  bool isHot,  bool isGoingLive,  bool isLive,  bool isLiveStream,  int gamePart,  int gameTime,  int stoppageTime,  Map<String, dynamic>? scoreRaw,  int? childType)  $default,) {final _that = this;
switch (_that) {
case _EventDetailResponseV2():
return $default(_that.children,_that.markets,_that.sportId,_that.leagueId,_that.eventId,_that.startDate,_that.startTime,_that.isSuspended,_that.isHidden,_that.isParlay,_that.isCashOut,_that.type,_that.eventStatsId,_that.homeId,_that.awayId,_that.homeName,_that.awayName,_that.homeLogo,_that.awayLogo,_that.marketCount,_that.marketGroups,_that.isHot,_that.isGoingLive,_that.isLive,_that.isLiveStream,_that.gamePart,_that.gameTime,_that.stoppageTime,_that.scoreRaw,_that.childType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EventDetailResponseV2> children,  List<MarketModelV2> markets,  int sportId,  int leagueId,  int eventId,  String startDate,  int startTime,  bool isSuspended,  bool isHidden,  bool isParlay,  bool isCashOut,  int type,  int eventStatsId,  int homeId,  int awayId,  String homeName,  String awayName,  String homeLogo,  String awayLogo,  int marketCount,  List<int>? marketGroups,  bool isHot,  bool isGoingLive,  bool isLive,  bool isLiveStream,  int gamePart,  int gameTime,  int stoppageTime,  Map<String, dynamic>? scoreRaw,  int? childType)?  $default,) {final _that = this;
switch (_that) {
case _EventDetailResponseV2() when $default != null:
return $default(_that.children,_that.markets,_that.sportId,_that.leagueId,_that.eventId,_that.startDate,_that.startTime,_that.isSuspended,_that.isHidden,_that.isParlay,_that.isCashOut,_that.type,_that.eventStatsId,_that.homeId,_that.awayId,_that.homeName,_that.awayName,_that.homeLogo,_that.awayLogo,_that.marketCount,_that.marketGroups,_that.isHot,_that.isGoingLive,_that.isLive,_that.isLiveStream,_that.gamePart,_that.gameTime,_that.stoppageTime,_that.scoreRaw,_that.childType);case _:
  return null;

}
}

}

/// @nodoc


class _EventDetailResponseV2 extends EventDetailResponseV2 {
  const _EventDetailResponseV2({final  List<EventDetailResponseV2> children = const [], final  List<MarketModelV2> markets = const [], this.sportId = 0, this.leagueId = 0, this.eventId = 0, this.startDate = '', this.startTime = 0, this.isSuspended = false, this.isHidden = false, this.isParlay = false, this.isCashOut = false, this.type = 0, this.eventStatsId = 0, this.homeId = 0, this.awayId = 0, this.homeName = '', this.awayName = '', this.homeLogo = '', this.awayLogo = '', this.marketCount = 0, final  List<int>? marketGroups, this.isHot = false, this.isGoingLive = false, this.isLive = false, this.isLiveStream = false, this.gamePart = 0, this.gameTime = 0, this.stoppageTime = 0, final  Map<String, dynamic>? scoreRaw, this.childType}): _children = children,_markets = markets,_marketGroups = marketGroups,_scoreRaw = scoreRaw,super._();
  

/// Children events (Corner, Extra Time, Penalty)
 final  List<EventDetailResponseV2> _children;
/// Children events (Corner, Extra Time, Penalty)
@override@JsonKey() List<EventDetailResponseV2> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

/// Full markets array
 final  List<MarketModelV2> _markets;
/// Full markets array
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
/// Event start date in ISO format
@override@JsonKey() final  String startDate;
/// Event start time in epoch milliseconds
@override@JsonKey() final  int startTime;
/// Indicates if the event is suspended
@override@JsonKey() final  bool isSuspended;
/// Indicates if the event is hidden
@override@JsonKey() final  bool isHidden;
/// Indicates if the event supports parlay
@override@JsonKey() final  bool isParlay;
/// Indicates if cash out is available
@override@JsonKey() final  bool isCashOut;
/// Event type
@override@JsonKey() final  int type;
/// Event statistics ID for tracker
@override@JsonKey() final  int eventStatsId;
/// Home team ID
@override@JsonKey() final  int homeId;
/// Away team ID
@override@JsonKey() final  int awayId;
/// Home team name
@override@JsonKey() final  String homeName;
/// Away team name
@override@JsonKey() final  String awayName;
/// Home team logo URL
@override@JsonKey() final  String homeLogo;
/// Away team logo URL
@override@JsonKey() final  String awayLogo;
/// Total number of markets available
@override@JsonKey() final  int marketCount;
/// Market group IDs for tab filtering
 final  List<int>? _marketGroups;
/// Market group IDs for tab filtering
@override List<int>? get marketGroups {
  final value = _marketGroups;
  if (value == null) return null;
  if (_marketGroups is EqualUnmodifiableListView) return _marketGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Indicates if the event is hot/featured
@override@JsonKey() final  bool isHot;
/// Indicates if the event is going live soon
@override@JsonKey() final  bool isGoingLive;
/// Indicates if the event is currently live
@override@JsonKey() final  bool isLive;
/// Indicates if live streaming is available
@override@JsonKey() final  bool isLiveStream;
/// Current part of the game (1=1H, 2=2H, 3=HT, etc.)
@override@JsonKey() final  int gamePart;
/// Current game time in milliseconds
@override@JsonKey() final  int gameTime;
/// Stoppage time in milliseconds
@override@JsonKey() final  int stoppageTime;
/// Raw score data (parse separately based on sportId)
 final  Map<String, dynamic>? _scoreRaw;
/// Raw score data (parse separately based on sportId)
@override Map<String, dynamic>? get scoreRaw {
  final value = _scoreRaw;
  if (value == null) return null;
  if (_scoreRaw is EqualUnmodifiableMapView) return _scoreRaw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Child type (only for child events: 1=Extra, 2=Corner, 3=Penalty)
@override final  int? childType;

/// Create a copy of EventDetailResponseV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDetailResponseV2CopyWith<_EventDetailResponseV2> get copyWith => __$EventDetailResponseV2CopyWithImpl<_EventDetailResponseV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDetailResponseV2&&const DeepCollectionEquality().equals(other._children, _children)&&const DeepCollectionEquality().equals(other._markets, _markets)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.isParlay, isParlay) || other.isParlay == isParlay)&&(identical(other.isCashOut, isCashOut) || other.isCashOut == isCashOut)&&(identical(other.type, type) || other.type == type)&&(identical(other.eventStatsId, eventStatsId) || other.eventStatsId == eventStatsId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.homeLogo, homeLogo) || other.homeLogo == homeLogo)&&(identical(other.awayLogo, awayLogo) || other.awayLogo == awayLogo)&&(identical(other.marketCount, marketCount) || other.marketCount == marketCount)&&const DeepCollectionEquality().equals(other._marketGroups, _marketGroups)&&(identical(other.isHot, isHot) || other.isHot == isHot)&&(identical(other.isGoingLive, isGoingLive) || other.isGoingLive == isGoingLive)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.isLiveStream, isLiveStream) || other.isLiveStream == isLiveStream)&&(identical(other.gamePart, gamePart) || other.gamePart == gamePart)&&(identical(other.gameTime, gameTime) || other.gameTime == gameTime)&&(identical(other.stoppageTime, stoppageTime) || other.stoppageTime == stoppageTime)&&const DeepCollectionEquality().equals(other._scoreRaw, _scoreRaw)&&(identical(other.childType, childType) || other.childType == childType));
}


@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_children),const DeepCollectionEquality().hash(_markets),sportId,leagueId,eventId,startDate,startTime,isSuspended,isHidden,isParlay,isCashOut,type,eventStatsId,homeId,awayId,homeName,awayName,homeLogo,awayLogo,marketCount,const DeepCollectionEquality().hash(_marketGroups),isHot,isGoingLive,isLive,isLiveStream,gamePart,gameTime,stoppageTime,const DeepCollectionEquality().hash(_scoreRaw),childType]);

@override
String toString() {
  return 'EventDetailResponseV2(children: $children, markets: $markets, sportId: $sportId, leagueId: $leagueId, eventId: $eventId, startDate: $startDate, startTime: $startTime, isSuspended: $isSuspended, isHidden: $isHidden, isParlay: $isParlay, isCashOut: $isCashOut, type: $type, eventStatsId: $eventStatsId, homeId: $homeId, awayId: $awayId, homeName: $homeName, awayName: $awayName, homeLogo: $homeLogo, awayLogo: $awayLogo, marketCount: $marketCount, marketGroups: $marketGroups, isHot: $isHot, isGoingLive: $isGoingLive, isLive: $isLive, isLiveStream: $isLiveStream, gamePart: $gamePart, gameTime: $gameTime, stoppageTime: $stoppageTime, scoreRaw: $scoreRaw, childType: $childType)';
}


}

/// @nodoc
abstract mixin class _$EventDetailResponseV2CopyWith<$Res> implements $EventDetailResponseV2CopyWith<$Res> {
  factory _$EventDetailResponseV2CopyWith(_EventDetailResponseV2 value, $Res Function(_EventDetailResponseV2) _then) = __$EventDetailResponseV2CopyWithImpl;
@override @useResult
$Res call({
 List<EventDetailResponseV2> children, List<MarketModelV2> markets, int sportId, int leagueId, int eventId, String startDate, int startTime, bool isSuspended, bool isHidden, bool isParlay, bool isCashOut, int type, int eventStatsId, int homeId, int awayId, String homeName, String awayName, String homeLogo, String awayLogo, int marketCount, List<int>? marketGroups, bool isHot, bool isGoingLive, bool isLive, bool isLiveStream, int gamePart, int gameTime, int stoppageTime, Map<String, dynamic>? scoreRaw, int? childType
});




}
/// @nodoc
class __$EventDetailResponseV2CopyWithImpl<$Res>
    implements _$EventDetailResponseV2CopyWith<$Res> {
  __$EventDetailResponseV2CopyWithImpl(this._self, this._then);

  final _EventDetailResponseV2 _self;
  final $Res Function(_EventDetailResponseV2) _then;

/// Create a copy of EventDetailResponseV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? children = null,Object? markets = null,Object? sportId = null,Object? leagueId = null,Object? eventId = null,Object? startDate = null,Object? startTime = null,Object? isSuspended = null,Object? isHidden = null,Object? isParlay = null,Object? isCashOut = null,Object? type = null,Object? eventStatsId = null,Object? homeId = null,Object? awayId = null,Object? homeName = null,Object? awayName = null,Object? homeLogo = null,Object? awayLogo = null,Object? marketCount = null,Object? marketGroups = freezed,Object? isHot = null,Object? isGoingLive = null,Object? isLive = null,Object? isLiveStream = null,Object? gamePart = null,Object? gameTime = null,Object? stoppageTime = null,Object? scoreRaw = freezed,Object? childType = freezed,}) {
  return _then(_EventDetailResponseV2(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<EventDetailResponseV2>,markets: null == markets ? _self._markets : markets // ignore: cast_nullable_to_non_nullable
as List<MarketModelV2>,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
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
as int,marketGroups: freezed == marketGroups ? _self._marketGroups : marketGroups // ignore: cast_nullable_to_non_nullable
as List<int>?,isHot: null == isHot ? _self.isHot : isHot // ignore: cast_nullable_to_non_nullable
as bool,isGoingLive: null == isGoingLive ? _self.isGoingLive : isGoingLive // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,isLiveStream: null == isLiveStream ? _self.isLiveStream : isLiveStream // ignore: cast_nullable_to_non_nullable
as bool,gamePart: null == gamePart ? _self.gamePart : gamePart // ignore: cast_nullable_to_non_nullable
as int,gameTime: null == gameTime ? _self.gameTime : gameTime // ignore: cast_nullable_to_non_nullable
as int,stoppageTime: null == stoppageTime ? _self.stoppageTime : stoppageTime // ignore: cast_nullable_to_non_nullable
as int,scoreRaw: freezed == scoreRaw ? _self._scoreRaw : scoreRaw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,childType: freezed == childType ? _self.childType : childType // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
