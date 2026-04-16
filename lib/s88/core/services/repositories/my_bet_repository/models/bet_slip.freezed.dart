// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_slip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BetSlip {

 String? get homeName; String? get awayName; String get id; num get stake; num get winning;@BetSlipStatusConverter() BetSlipStatus get status; String get displayOdds; String get score; String get cls; String get oddsName; String get ticketId; String get marketName; int get sportId; int get marketId; String get selectionId; String get currency; String get matchType; String get matchId; int get homeId; int get awayId; String get leagueName; String get oddsStyle;@LocalTimeConverter() DateTime get startDate;@LocalTimeConverter() DateTime get betTime; List<ChildBet> get childBets; String? get settlementStatus; num? get cashOutAbleAmount; String? get matchName; String? get htScore; List<CashoutInfo> get cashoutHistory;
/// Create a copy of BetSlip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetSlipCopyWith<BetSlip> get copyWith => _$BetSlipCopyWithImpl<BetSlip>(this as BetSlip, _$identity);

  /// Serializes this BetSlip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetSlip&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.id, id) || other.id == id)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winning, winning) || other.winning == winning)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.score, score) || other.score == score)&&(identical(other.cls, cls) || other.cls == cls)&&(identical(other.oddsName, oddsName) || other.oddsName == oddsName)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.betTime, betTime) || other.betTime == betTime)&&const DeepCollectionEquality().equals(other.childBets, childBets)&&(identical(other.settlementStatus, settlementStatus) || other.settlementStatus == settlementStatus)&&(identical(other.cashOutAbleAmount, cashOutAbleAmount) || other.cashOutAbleAmount == cashOutAbleAmount)&&(identical(other.matchName, matchName) || other.matchName == matchName)&&(identical(other.htScore, htScore) || other.htScore == htScore)&&const DeepCollectionEquality().equals(other.cashoutHistory, cashoutHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,homeName,awayName,id,stake,winning,status,displayOdds,score,cls,oddsName,ticketId,marketName,sportId,marketId,selectionId,currency,matchType,matchId,homeId,awayId,leagueName,oddsStyle,startDate,betTime,const DeepCollectionEquality().hash(childBets),settlementStatus,cashOutAbleAmount,matchName,htScore,const DeepCollectionEquality().hash(cashoutHistory)]);

@override
String toString() {
  return 'BetSlip(homeName: $homeName, awayName: $awayName, id: $id, stake: $stake, winning: $winning, status: $status, displayOdds: $displayOdds, score: $score, cls: $cls, oddsName: $oddsName, ticketId: $ticketId, marketName: $marketName, sportId: $sportId, marketId: $marketId, selectionId: $selectionId, currency: $currency, matchType: $matchType, matchId: $matchId, homeId: $homeId, awayId: $awayId, leagueName: $leagueName, oddsStyle: $oddsStyle, startDate: $startDate, betTime: $betTime, childBets: $childBets, settlementStatus: $settlementStatus, cashOutAbleAmount: $cashOutAbleAmount, matchName: $matchName, htScore: $htScore, cashoutHistory: $cashoutHistory)';
}


}

/// @nodoc
abstract mixin class $BetSlipCopyWith<$Res>  {
  factory $BetSlipCopyWith(BetSlip value, $Res Function(BetSlip) _then) = _$BetSlipCopyWithImpl;
@useResult
$Res call({
 String? homeName, String? awayName, String id, num stake, num winning,@BetSlipStatusConverter() BetSlipStatus status, String displayOdds, String score, String cls, String oddsName, String ticketId, String marketName, int sportId, int marketId, String selectionId, String currency, String matchType, String matchId, int homeId, int awayId, String leagueName, String oddsStyle,@LocalTimeConverter() DateTime startDate,@LocalTimeConverter() DateTime betTime, List<ChildBet> childBets, String? settlementStatus, num? cashOutAbleAmount, String? matchName, String? htScore, List<CashoutInfo> cashoutHistory
});




}
/// @nodoc
class _$BetSlipCopyWithImpl<$Res>
    implements $BetSlipCopyWith<$Res> {
  _$BetSlipCopyWithImpl(this._self, this._then);

  final BetSlip _self;
  final $Res Function(BetSlip) _then;

/// Create a copy of BetSlip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeName = freezed,Object? awayName = freezed,Object? id = null,Object? stake = null,Object? winning = null,Object? status = null,Object? displayOdds = null,Object? score = null,Object? cls = null,Object? oddsName = null,Object? ticketId = null,Object? marketName = null,Object? sportId = null,Object? marketId = null,Object? selectionId = null,Object? currency = null,Object? matchType = null,Object? matchId = null,Object? homeId = null,Object? awayId = null,Object? leagueName = null,Object? oddsStyle = null,Object? startDate = null,Object? betTime = null,Object? childBets = null,Object? settlementStatus = freezed,Object? cashOutAbleAmount = freezed,Object? matchName = freezed,Object? htScore = freezed,Object? cashoutHistory = null,}) {
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
as String,matchType: null == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,betTime: null == betTime ? _self.betTime : betTime // ignore: cast_nullable_to_non_nullable
as DateTime,childBets: null == childBets ? _self.childBets : childBets // ignore: cast_nullable_to_non_nullable
as List<ChildBet>,settlementStatus: freezed == settlementStatus ? _self.settlementStatus : settlementStatus // ignore: cast_nullable_to_non_nullable
as String?,cashOutAbleAmount: freezed == cashOutAbleAmount ? _self.cashOutAbleAmount : cashOutAbleAmount // ignore: cast_nullable_to_non_nullable
as num?,matchName: freezed == matchName ? _self.matchName : matchName // ignore: cast_nullable_to_non_nullable
as String?,htScore: freezed == htScore ? _self.htScore : htScore // ignore: cast_nullable_to_non_nullable
as String?,cashoutHistory: null == cashoutHistory ? _self.cashoutHistory : cashoutHistory // ignore: cast_nullable_to_non_nullable
as List<CashoutInfo>,
  ));
}

}


/// Adds pattern-matching-related methods to [BetSlip].
extension BetSlipPatterns on BetSlip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetSlip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetSlip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetSlip value)  $default,){
final _that = this;
switch (_that) {
case _BetSlip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetSlip value)?  $default,){
final _that = this;
switch (_that) {
case _BetSlip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? homeName,  String? awayName,  String id,  num stake,  num winning, @BetSlipStatusConverter()  BetSlipStatus status,  String displayOdds,  String score,  String cls,  String oddsName,  String ticketId,  String marketName,  int sportId,  int marketId,  String selectionId,  String currency,  String matchType,  String matchId,  int homeId,  int awayId,  String leagueName,  String oddsStyle, @LocalTimeConverter()  DateTime startDate, @LocalTimeConverter()  DateTime betTime,  List<ChildBet> childBets,  String? settlementStatus,  num? cashOutAbleAmount,  String? matchName,  String? htScore,  List<CashoutInfo> cashoutHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetSlip() when $default != null:
return $default(_that.homeName,_that.awayName,_that.id,_that.stake,_that.winning,_that.status,_that.displayOdds,_that.score,_that.cls,_that.oddsName,_that.ticketId,_that.marketName,_that.sportId,_that.marketId,_that.selectionId,_that.currency,_that.matchType,_that.matchId,_that.homeId,_that.awayId,_that.leagueName,_that.oddsStyle,_that.startDate,_that.betTime,_that.childBets,_that.settlementStatus,_that.cashOutAbleAmount,_that.matchName,_that.htScore,_that.cashoutHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? homeName,  String? awayName,  String id,  num stake,  num winning, @BetSlipStatusConverter()  BetSlipStatus status,  String displayOdds,  String score,  String cls,  String oddsName,  String ticketId,  String marketName,  int sportId,  int marketId,  String selectionId,  String currency,  String matchType,  String matchId,  int homeId,  int awayId,  String leagueName,  String oddsStyle, @LocalTimeConverter()  DateTime startDate, @LocalTimeConverter()  DateTime betTime,  List<ChildBet> childBets,  String? settlementStatus,  num? cashOutAbleAmount,  String? matchName,  String? htScore,  List<CashoutInfo> cashoutHistory)  $default,) {final _that = this;
switch (_that) {
case _BetSlip():
return $default(_that.homeName,_that.awayName,_that.id,_that.stake,_that.winning,_that.status,_that.displayOdds,_that.score,_that.cls,_that.oddsName,_that.ticketId,_that.marketName,_that.sportId,_that.marketId,_that.selectionId,_that.currency,_that.matchType,_that.matchId,_that.homeId,_that.awayId,_that.leagueName,_that.oddsStyle,_that.startDate,_that.betTime,_that.childBets,_that.settlementStatus,_that.cashOutAbleAmount,_that.matchName,_that.htScore,_that.cashoutHistory);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? homeName,  String? awayName,  String id,  num stake,  num winning, @BetSlipStatusConverter()  BetSlipStatus status,  String displayOdds,  String score,  String cls,  String oddsName,  String ticketId,  String marketName,  int sportId,  int marketId,  String selectionId,  String currency,  String matchType,  String matchId,  int homeId,  int awayId,  String leagueName,  String oddsStyle, @LocalTimeConverter()  DateTime startDate, @LocalTimeConverter()  DateTime betTime,  List<ChildBet> childBets,  String? settlementStatus,  num? cashOutAbleAmount,  String? matchName,  String? htScore,  List<CashoutInfo> cashoutHistory)?  $default,) {final _that = this;
switch (_that) {
case _BetSlip() when $default != null:
return $default(_that.homeName,_that.awayName,_that.id,_that.stake,_that.winning,_that.status,_that.displayOdds,_that.score,_that.cls,_that.oddsName,_that.ticketId,_that.marketName,_that.sportId,_that.marketId,_that.selectionId,_that.currency,_that.matchType,_that.matchId,_that.homeId,_that.awayId,_that.leagueName,_that.oddsStyle,_that.startDate,_that.betTime,_that.childBets,_that.settlementStatus,_that.cashOutAbleAmount,_that.matchName,_that.htScore,_that.cashoutHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BetSlip implements BetSlip {
  const _BetSlip({this.homeName, this.awayName, required this.id, required this.stake, required this.winning, @BetSlipStatusConverter() required this.status, required this.displayOdds, required this.score, required this.cls, required this.oddsName, required this.ticketId, required this.marketName, required this.sportId, required this.marketId, required this.selectionId, required this.currency, required this.matchType, required this.matchId, required this.homeId, required this.awayId, required this.leagueName, required this.oddsStyle, @LocalTimeConverter() required this.startDate, @LocalTimeConverter() required this.betTime, final  List<ChildBet> childBets = const [], this.settlementStatus, this.cashOutAbleAmount, this.matchName, this.htScore, final  List<CashoutInfo> cashoutHistory = const []}): _childBets = childBets,_cashoutHistory = cashoutHistory;
  factory _BetSlip.fromJson(Map<String, dynamic> json) => _$BetSlipFromJson(json);

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
@override final  String matchType;
@override final  String matchId;
@override final  int homeId;
@override final  int awayId;
@override final  String leagueName;
@override final  String oddsStyle;
@override@LocalTimeConverter() final  DateTime startDate;
@override@LocalTimeConverter() final  DateTime betTime;
 final  List<ChildBet> _childBets;
@override@JsonKey() List<ChildBet> get childBets {
  if (_childBets is EqualUnmodifiableListView) return _childBets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childBets);
}

@override final  String? settlementStatus;
@override final  num? cashOutAbleAmount;
@override final  String? matchName;
@override final  String? htScore;
 final  List<CashoutInfo> _cashoutHistory;
@override@JsonKey() List<CashoutInfo> get cashoutHistory {
  if (_cashoutHistory is EqualUnmodifiableListView) return _cashoutHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cashoutHistory);
}


/// Create a copy of BetSlip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetSlipCopyWith<_BetSlip> get copyWith => __$BetSlipCopyWithImpl<_BetSlip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetSlipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetSlip&&(identical(other.homeName, homeName) || other.homeName == homeName)&&(identical(other.awayName, awayName) || other.awayName == awayName)&&(identical(other.id, id) || other.id == id)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.winning, winning) || other.winning == winning)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayOdds, displayOdds) || other.displayOdds == displayOdds)&&(identical(other.score, score) || other.score == score)&&(identical(other.cls, cls) || other.cls == cls)&&(identical(other.oddsName, oddsName) || other.oddsName == oddsName)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.marketName, marketName) || other.marketName == marketName)&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName)&&(identical(other.oddsStyle, oddsStyle) || other.oddsStyle == oddsStyle)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.betTime, betTime) || other.betTime == betTime)&&const DeepCollectionEquality().equals(other._childBets, _childBets)&&(identical(other.settlementStatus, settlementStatus) || other.settlementStatus == settlementStatus)&&(identical(other.cashOutAbleAmount, cashOutAbleAmount) || other.cashOutAbleAmount == cashOutAbleAmount)&&(identical(other.matchName, matchName) || other.matchName == matchName)&&(identical(other.htScore, htScore) || other.htScore == htScore)&&const DeepCollectionEquality().equals(other._cashoutHistory, _cashoutHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,homeName,awayName,id,stake,winning,status,displayOdds,score,cls,oddsName,ticketId,marketName,sportId,marketId,selectionId,currency,matchType,matchId,homeId,awayId,leagueName,oddsStyle,startDate,betTime,const DeepCollectionEquality().hash(_childBets),settlementStatus,cashOutAbleAmount,matchName,htScore,const DeepCollectionEquality().hash(_cashoutHistory)]);

@override
String toString() {
  return 'BetSlip(homeName: $homeName, awayName: $awayName, id: $id, stake: $stake, winning: $winning, status: $status, displayOdds: $displayOdds, score: $score, cls: $cls, oddsName: $oddsName, ticketId: $ticketId, marketName: $marketName, sportId: $sportId, marketId: $marketId, selectionId: $selectionId, currency: $currency, matchType: $matchType, matchId: $matchId, homeId: $homeId, awayId: $awayId, leagueName: $leagueName, oddsStyle: $oddsStyle, startDate: $startDate, betTime: $betTime, childBets: $childBets, settlementStatus: $settlementStatus, cashOutAbleAmount: $cashOutAbleAmount, matchName: $matchName, htScore: $htScore, cashoutHistory: $cashoutHistory)';
}


}

/// @nodoc
abstract mixin class _$BetSlipCopyWith<$Res> implements $BetSlipCopyWith<$Res> {
  factory _$BetSlipCopyWith(_BetSlip value, $Res Function(_BetSlip) _then) = __$BetSlipCopyWithImpl;
@override @useResult
$Res call({
 String? homeName, String? awayName, String id, num stake, num winning,@BetSlipStatusConverter() BetSlipStatus status, String displayOdds, String score, String cls, String oddsName, String ticketId, String marketName, int sportId, int marketId, String selectionId, String currency, String matchType, String matchId, int homeId, int awayId, String leagueName, String oddsStyle,@LocalTimeConverter() DateTime startDate,@LocalTimeConverter() DateTime betTime, List<ChildBet> childBets, String? settlementStatus, num? cashOutAbleAmount, String? matchName, String? htScore, List<CashoutInfo> cashoutHistory
});




}
/// @nodoc
class __$BetSlipCopyWithImpl<$Res>
    implements _$BetSlipCopyWith<$Res> {
  __$BetSlipCopyWithImpl(this._self, this._then);

  final _BetSlip _self;
  final $Res Function(_BetSlip) _then;

/// Create a copy of BetSlip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeName = freezed,Object? awayName = freezed,Object? id = null,Object? stake = null,Object? winning = null,Object? status = null,Object? displayOdds = null,Object? score = null,Object? cls = null,Object? oddsName = null,Object? ticketId = null,Object? marketName = null,Object? sportId = null,Object? marketId = null,Object? selectionId = null,Object? currency = null,Object? matchType = null,Object? matchId = null,Object? homeId = null,Object? awayId = null,Object? leagueName = null,Object? oddsStyle = null,Object? startDate = null,Object? betTime = null,Object? childBets = null,Object? settlementStatus = freezed,Object? cashOutAbleAmount = freezed,Object? matchName = freezed,Object? htScore = freezed,Object? cashoutHistory = null,}) {
  return _then(_BetSlip(
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
as String,matchType: null == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,homeId: null == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int,awayId: null == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,oddsStyle: null == oddsStyle ? _self.oddsStyle : oddsStyle // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,betTime: null == betTime ? _self.betTime : betTime // ignore: cast_nullable_to_non_nullable
as DateTime,childBets: null == childBets ? _self._childBets : childBets // ignore: cast_nullable_to_non_nullable
as List<ChildBet>,settlementStatus: freezed == settlementStatus ? _self.settlementStatus : settlementStatus // ignore: cast_nullable_to_non_nullable
as String?,cashOutAbleAmount: freezed == cashOutAbleAmount ? _self.cashOutAbleAmount : cashOutAbleAmount // ignore: cast_nullable_to_non_nullable
as num?,matchName: freezed == matchName ? _self.matchName : matchName // ignore: cast_nullable_to_non_nullable
as String?,htScore: freezed == htScore ? _self.htScore : htScore // ignore: cast_nullable_to_non_nullable
as String?,cashoutHistory: null == cashoutHistory ? _self._cashoutHistory : cashoutHistory // ignore: cast_nullable_to_non_nullable
as List<CashoutInfo>,
  ));
}


}

// dart format on
