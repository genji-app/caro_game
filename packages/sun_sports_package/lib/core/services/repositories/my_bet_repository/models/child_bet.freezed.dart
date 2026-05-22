// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_bet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChildBet {

 String? get homeName; String? get awayName; String get id; num get stake; num get winning;@BetSlipStatusConverter() BetSlipStatus get status; String get displayOdds; String get score; String get cls; String get oddsName; String get ticketId; String get marketName; int get sportId; int get marketId; String get selectionId; String get currency; String get matchId; int get homeId; int get awayId; String get leagueName; String get oddsStyle;@LocalTimeConverter() DateTime get startDate; String? get settlementStatus; String? get matchType; String? get htScore;
/// Create a copy of ChildBet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildBetCopyWith<ChildBet> get copyWith => _$ChildBetCopyWithImpl<ChildBet>(this as ChildBet, _$identity);

  /// Serializes this ChildBet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildBet&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.id, id) || other.id == id)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winning, winning) || other.winning == winning)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.score, score) || other.score == score)&&(identical(other.cls, cls) || other.cls == cls)&&(identical(other.oddsName, oddsName) || other.oddsName == oddsName)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.settlementStatus, settlementStatus) || other.settlementStatus == settlementStatus)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.htScore, htScore) || other.htScore == htScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,homeName,awayName,id,stake,winning,status,displayOdds,score,cls,oddsName,ticketId,marketName,sportId,marketId,selectionId,currency,matchId,homeId,awayId,leagueName,oddsStyle,startDate,settlementStatus,matchType,htScore]);

@override
String toString() {
  return 'ChildBet(homeName: $homeName, awayName: $awayName, id: $id, stake: $stake, winning: $winning, status: $status, displayOdds: $displayOdds, score: $score, cls: $cls, oddsName: $oddsName, ticketId: $ticketId, marketName: $marketName, sportId: $sportId, marketId: $marketId, selectionId: $selectionId, currency: $currency, matchId: $matchId, homeId: $homeId, awayId: $awayId, leagueName: $leagueName, oddsStyle: $oddsStyle, startDate: $startDate, settlementStatus: $settlementStatus, matchType: $matchType, htScore: $htScore)';
}


}

/// @nodoc
abstract mixin class $ChildBetCopyWith<$Res>  {
  factory $ChildBetCopyWith(ChildBet value, $Res Function(ChildBet) _then) = _$ChildBetCopyWithImpl;
@useResult
$Res call({
 String? homeName, String? awayName, String id, num stake, num winning,@BetSlipStatusConverter() BetSlipStatus status, String displayOdds, String score, String cls, String oddsName, String ticketId, String marketName, int sportId, int marketId, String selectionId, String currency, String matchId, int homeId, int awayId, String leagueName, String oddsStyle,@LocalTimeConverter() DateTime startDate, String? settlementStatus, String? matchType, String? htScore
});




}
/// @nodoc
class _$ChildBetCopyWithImpl<$Res>
    implements $ChildBetCopyWith<$Res> {
  _$ChildBetCopyWithImpl(this._self, this._then);

  final ChildBet _self;
  final $Res Function(ChildBet) _then;

/// Create a copy of ChildBet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeName = freezed,Object? awayName = freezed,Object? id = null,Object? stake = null,Object? winning = null,Object? status = null,Object? displayOdds = null,Object? score = null,Object? cls = null,Object? oddsName = null,Object? ticketId = null,Object? marketName = null,Object? sportId = null,Object? marketId = null,Object? selectionId = null,Object? currency = null,Object? matchId = null,Object? homeId = null,Object? awayId = null,Object? leagueName = null,Object? oddsStyle = null,Object? startDate = null,Object? settlementStatus = freezed,Object? matchType = freezed,Object? htScore = freezed,}) {
  return _then(_self.copyWith(
homeName: freezed == homeName ? _self.homeName : homeName // ignore: cast_nullable_to_non_nullable
as String?,awayName: freezed == awayName ? _self.awayName : awayName // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stake: null == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as num,winning: null == winning ? _self.winning : winning // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BetSlipStatus,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,cls: null == cls ? _self.cls : cls // ignore: cast_nullable_to_non_nullable
as String,oddsName: null == oddsName ? _self.oddsName : oddsName // ignore: cast_nullable_to_non_nullable
as String,ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,settlementStatus: freezed == settlementStatus ? _self.settlementStatus : settlementStatus // ignore: cast_nullable_to_non_nullable
as String?,matchType: freezed == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as String?,htScore: freezed == htScore ? _self.htScore : htScore // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildBet].
extension ChildBetPatterns on ChildBet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildBet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildBet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildBet value)  $default,){
final _that = this;
switch (_that) {
case _ChildBet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildBet value)?  $default,){
final _that = this;
switch (_that) {
case _ChildBet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? homeName,  String? awayName,  String id,  num stake,  num winning, @BetSlipStatusConverter()  BetSlipStatus status,  String displayOdds,  String score,  String cls,  String oddsName,  String ticketId,  String marketName,  int sportId,  int marketId,  String selectionId,  String currency,  String matchId,  int homeId,  int awayId,  String leagueName,  String oddsStyle, @LocalTimeConverter()  DateTime startDate,  String? settlementStatus,  String? matchType,  String? htScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildBet() when $default != null:
return $default(_that.homeName,_that.awayName,_that.id,_that.stake,_that.winning,_that.status,_that.displayOdds,_that.score,_that.cls,_that.oddsName,_that.ticketId,_that.marketName,_that.sportId,_that.marketId,_that.selectionId,_that.currency,_that.matchId,_that.homeId,_that.awayId,_that.leagueName,_that.oddsStyle,_that.startDate,_that.settlementStatus,_that.matchType,_that.htScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? homeName,  String? awayName,  String id,  num stake,  num winning, @BetSlipStatusConverter()  BetSlipStatus status,  String displayOdds,  String score,  String cls,  String oddsName,  String ticketId,  String marketName,  int sportId,  int marketId,  String selectionId,  String currency,  String matchId,  int homeId,  int awayId,  String leagueName,  String oddsStyle, @LocalTimeConverter()  DateTime startDate,  String? settlementStatus,  String? matchType,  String? htScore)  $default,) {final _that = this;
switch (_that) {
case _ChildBet():
return $default(_that.homeName,_that.awayName,_that.id,_that.stake,_that.winning,_that.status,_that.displayOdds,_that.score,_that.cls,_that.oddsName,_that.ticketId,_that.marketName,_that.sportId,_that.marketId,_that.selectionId,_that.currency,_that.matchId,_that.homeId,_that.awayId,_that.leagueName,_that.oddsStyle,_that.startDate,_that.settlementStatus,_that.matchType,_that.htScore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? homeName,  String? awayName,  String id,  num stake,  num winning, @BetSlipStatusConverter()  BetSlipStatus status,  String displayOdds,  String score,  String cls,  String oddsName,  String ticketId,  String marketName,  int sportId,  int marketId,  String selectionId,  String currency,  String matchId,  int homeId,  int awayId,  String leagueName,  String oddsStyle, @LocalTimeConverter()  DateTime startDate,  String? settlementStatus,  String? matchType,  String? htScore)?  $default,) {final _that = this;
switch (_that) {
case _ChildBet() when $default != null:
return $default(_that.homeName,_that.awayName,_that.id,_that.stake,_that.winning,_that.status,_that.displayOdds,_that.score,_that.cls,_that.oddsName,_that.ticketId,_that.marketName,_that.sportId,_that.marketId,_that.selectionId,_that.currency,_that.matchId,_that.homeId,_that.awayId,_that.leagueName,_that.oddsStyle,_that.startDate,_that.settlementStatus,_that.matchType,_that.htScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChildBet implements ChildBet {
  const _ChildBet({this.homeName, this.awayName, required this.id, required this.stake, required this.winning, @BetSlipStatusConverter() required this.status, required this.displayOdds, required this.score, required this.cls, required this.oddsName, required this.ticketId, required this.marketName, required this.sportId, required this.marketId, required this.selectionId, required this.currency, required this.matchId, required this.homeId, required this.awayId, required this.leagueName, required this.oddsStyle, @LocalTimeConverter() required this.startDate, this.settlementStatus, this.matchType, this.htScore});
  factory _ChildBet.fromJson(Map<String, dynamic> json) => _$ChildBetFromJson(json);

@override final  String? homeName;
@override final  String? awayName;
@override final  String id;
@override final  num stake;
@override final  num winning;
@override@BetSlipStatusConverter() final  BetSlipStatus status;
@override final  String displayOdds;
@override final  String score;
@override final  String cls;
@override final  String oddsName;
@override final  String ticketId;
@override final  String marketName;
@override final  int sportId;
@override final  int marketId;
@override final  String selectionId;
@override final  String currency;
@override final  String matchId;
@override final  int homeId;
@override final  int awayId;
@override final  String leagueName;
@override final  String oddsStyle;
@override@LocalTimeConverter() final  DateTime startDate;
@override final  String? settlementStatus;
@override final  String? matchType;
@override final  String? htScore;

/// Create a copy of ChildBet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildBetCopyWith<_ChildBet> get copyWith => __$ChildBetCopyWithImpl<_ChildBet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildBetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildBet&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.id, id) || other.id == id)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winning, winning) || other.winning == winning)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.score, score) || other.score == score)&&(identical(other.cls, cls) || other.cls == cls)&&(identical(other.oddsName, oddsName) || other.oddsName == oddsName)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.settlementStatus, settlementStatus) || other.settlementStatus == settlementStatus)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.htScore, htScore) || other.htScore == htScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,homeName,awayName,id,stake,winning,status,displayOdds,score,cls,oddsName,ticketId,marketName,sportId,marketId,selectionId,currency,matchId,homeId,awayId,leagueName,oddsStyle,startDate,settlementStatus,matchType,htScore]);

@override
String toString() {
  return 'ChildBet(homeName: $homeName, awayName: $awayName, id: $id, stake: $stake, winning: $winning, status: $status, displayOdds: $displayOdds, score: $score, cls: $cls, oddsName: $oddsName, ticketId: $ticketId, marketName: $marketName, sportId: $sportId, marketId: $marketId, selectionId: $selectionId, currency: $currency, matchId: $matchId, homeId: $homeId, awayId: $awayId, leagueName: $leagueName, oddsStyle: $oddsStyle, startDate: $startDate, settlementStatus: $settlementStatus, matchType: $matchType, htScore: $htScore)';
}


}

/// @nodoc
abstract mixin class _$ChildBetCopyWith<$Res> implements $ChildBetCopyWith<$Res> {
  factory _$ChildBetCopyWith(_ChildBet value, $Res Function(_ChildBet) _then) = __$ChildBetCopyWithImpl;
@override @useResult
$Res call({
 String? homeName, String? awayName, String id, num stake, num winning,@BetSlipStatusConverter() BetSlipStatus status, String displayOdds, String score, String cls, String oddsName, String ticketId, String marketName, int sportId, int marketId, String selectionId, String currency, String matchId, int homeId, int awayId, String leagueName, String oddsStyle,@LocalTimeConverter() DateTime startDate, String? settlementStatus, String? matchType, String? htScore
});




}
/// @nodoc
class __$ChildBetCopyWithImpl<$Res>
    implements _$ChildBetCopyWith<$Res> {
  __$ChildBetCopyWithImpl(this._self, this._then);

  final _ChildBet _self;
  final $Res Function(_ChildBet) _then;

/// Create a copy of ChildBet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeName = freezed,Object? awayName = freezed,Object? id = null,Object? stake = null,Object? winning = null,Object? status = null,Object? displayOdds = null,Object? score = null,Object? cls = null,Object? oddsName = null,Object? ticketId = null,Object? marketName = null,Object? sportId = null,Object? marketId = null,Object? selectionId = null,Object? currency = null,Object? matchId = null,Object? homeId = null,Object? awayId = null,Object? leagueName = null,Object? oddsStyle = null,Object? startDate = null,Object? settlementStatus = freezed,Object? matchType = freezed,Object? htScore = freezed,}) {
  return _then(_ChildBet(
homeName: freezed == homeName ? _self.homeName : homeName // ignore: cast_nullable_to_non_nullable
as String?,awayName: freezed == awayName ? _self.awayName : awayName // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stake: null == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as num,winning: null == winning ? _self.winning : winning // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BetSlipStatus,displayOdds: null == displayOdds ? _self.displayOdds : displayOdds // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,cls: null == cls ? _self.cls : cls // ignore: cast_nullable_to_non_nullable
as String,oddsName: null == oddsName ? _self.oddsName : oddsName // ignore: cast_nullable_to_non_nullable
as String,ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,marketName: null == marketName ? _self.marketName : marketName // ignore: cast_nullable_to_non_nullable
as String,sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,settlementStatus: freezed == settlementStatus ? _self.settlementStatus : settlementStatus // ignore: cast_nullable_to_non_nullable
as String?,matchType: freezed == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as String?,htScore: freezed == htScore ? _self.htScore : htScore // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
