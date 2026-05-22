// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'score_model_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SoccerScoreModelV2 {

/// Sport ID (always 1 for Soccer)
 int get sportId;/// Home score full time
 int get homeScoreFT;/// Away score full time
 int get awayScoreFT;/// Home score second half
 int get homeScoreH2;/// Away score second half
 int get awayScoreH2;/// Home team corner count
 int get homeCorner;/// Away team corner count
 int get awayCorner;/// Home score overtime
 int get homeScoreOT;/// Away score overtime
 int get awayScoreOT;/// Home score penalty
 int get homeScorePen;/// Away score penalty
 int get awayScorePen;/// Home yellow cards
 int get yellowCardsHome;/// Away yellow cards
 int get yellowCardsAway;/// Home red cards
 int get redCardsHome;/// Away red cards
 int get redCardsAway;
/// Create a copy of SoccerScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoccerScoreModelV2CopyWith<SoccerScoreModelV2> get copyWith => _$SoccerScoreModelV2CopyWithImpl<SoccerScoreModelV2>(this as SoccerScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoccerScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.homeScoreFT, homeScoreFT) || other.homeScoreFT == homeScoreFT)&&(identical(other.awayScoreFT, awayScoreFT) || other.awayScoreFT == awayScoreFT)&&(identical(other.homeScoreH2, homeScoreH2) || other.homeScoreH2 == homeScoreH2)&&(identical(other.awayScoreH2, awayScoreH2) || other.awayScoreH2 == awayScoreH2)&&(identical(other.homeCorner, homeCorner) || other.homeCorner == homeCorner)&&(identical(other.awayCorner, awayCorner) || other.awayCorner == awayCorner)&&(identical(other.homeScoreOT, homeScoreOT) || other.homeScoreOT == homeScoreOT)&&(identical(other.awayScoreOT, awayScoreOT) || other.awayScoreOT == awayScoreOT)&&(identical(other.homeScorePen, homeScorePen) || other.homeScorePen == homeScorePen)&&(identical(other.awayScorePen, awayScorePen) || other.awayScorePen == awayScorePen)&&(identical(other.yellowCardsHome, yellowCardsHome) || other.yellowCardsHome == yellowCardsHome)&&(identical(other.yellowCardsAway, yellowCardsAway) || other.yellowCardsAway == yellowCardsAway)&&(identical(other.redCardsHome, redCardsHome) || other.redCardsHome == redCardsHome)&&(identical(other.redCardsAway, redCardsAway) || other.redCardsAway == redCardsAway));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,homeScoreFT,awayScoreFT,homeScoreH2,awayScoreH2,homeCorner,awayCorner,homeScoreOT,awayScoreOT,homeScorePen,awayScorePen,yellowCardsHome,yellowCardsAway,redCardsHome,redCardsAway);

@override
String toString() {
  return 'SoccerScoreModelV2(sportId: $sportId, homeScoreFT: $homeScoreFT, awayScoreFT: $awayScoreFT, homeScoreH2: $homeScoreH2, awayScoreH2: $awayScoreH2, homeCorner: $homeCorner, awayCorner: $awayCorner, homeScoreOT: $homeScoreOT, awayScoreOT: $awayScoreOT, homeScorePen: $homeScorePen, awayScorePen: $awayScorePen, yellowCardsHome: $yellowCardsHome, yellowCardsAway: $yellowCardsAway, redCardsHome: $redCardsHome, redCardsAway: $redCardsAway)';
}


}

/// @nodoc
abstract mixin class $SoccerScoreModelV2CopyWith<$Res>  {
  factory $SoccerScoreModelV2CopyWith(SoccerScoreModelV2 value, $Res Function(SoccerScoreModelV2) _then) = _$SoccerScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, int homeScoreFT, int awayScoreFT, int homeScoreH2, int awayScoreH2, int homeCorner, int awayCorner, int homeScoreOT, int awayScoreOT, int homeScorePen, int awayScorePen, int yellowCardsHome, int yellowCardsAway, int redCardsHome, int redCardsAway
});




}
/// @nodoc
class _$SoccerScoreModelV2CopyWithImpl<$Res>
    implements $SoccerScoreModelV2CopyWith<$Res> {
  _$SoccerScoreModelV2CopyWithImpl(this._self, this._then);

  final SoccerScoreModelV2 _self;
  final $Res Function(SoccerScoreModelV2) _then;

/// Create a copy of SoccerScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? homeScoreFT = null,Object? awayScoreFT = null,Object? homeScoreH2 = null,Object? awayScoreH2 = null,Object? homeCorner = null,Object? awayCorner = null,Object? homeScoreOT = null,Object? awayScoreOT = null,Object? homeScorePen = null,Object? awayScorePen = null,Object? yellowCardsHome = null,Object? yellowCardsAway = null,Object? redCardsHome = null,Object? redCardsAway = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,homeScoreFT: null == homeScoreFT ? _self.homeScoreFT : homeScoreFT // ignore: cast_nullable_to_non_nullable
as int,awayScoreFT: null == awayScoreFT ? _self.awayScoreFT : awayScoreFT // ignore: cast_nullable_to_non_nullable
as int,homeScoreH2: null == homeScoreH2 ? _self.homeScoreH2 : homeScoreH2 // ignore: cast_nullable_to_non_nullable
as int,awayScoreH2: null == awayScoreH2 ? _self.awayScoreH2 : awayScoreH2 // ignore: cast_nullable_to_non_nullable
as int,homeCorner: null == homeCorner ? _self.homeCorner : homeCorner // ignore: cast_nullable_to_non_nullable
as int,awayCorner: null == awayCorner ? _self.awayCorner : awayCorner // ignore: cast_nullable_to_non_nullable
as int,homeScoreOT: null == homeScoreOT ? _self.homeScoreOT : homeScoreOT // ignore: cast_nullable_to_non_nullable
as int,awayScoreOT: null == awayScoreOT ? _self.awayScoreOT : awayScoreOT // ignore: cast_nullable_to_non_nullable
as int,homeScorePen: null == homeScorePen ? _self.homeScorePen : homeScorePen // ignore: cast_nullable_to_non_nullable
as int,awayScorePen: null == awayScorePen ? _self.awayScorePen : awayScorePen // ignore: cast_nullable_to_non_nullable
as int,yellowCardsHome: null == yellowCardsHome ? _self.yellowCardsHome : yellowCardsHome // ignore: cast_nullable_to_non_nullable
as int,yellowCardsAway: null == yellowCardsAway ? _self.yellowCardsAway : yellowCardsAway // ignore: cast_nullable_to_non_nullable
as int,redCardsHome: null == redCardsHome ? _self.redCardsHome : redCardsHome // ignore: cast_nullable_to_non_nullable
as int,redCardsAway: null == redCardsAway ? _self.redCardsAway : redCardsAway // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SoccerScoreModelV2].
extension SoccerScoreModelV2Patterns on SoccerScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoccerScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoccerScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoccerScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _SoccerScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoccerScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _SoccerScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  int homeScoreFT,  int awayScoreFT,  int homeScoreH2,  int awayScoreH2,  int homeCorner,  int awayCorner,  int homeScoreOT,  int awayScoreOT,  int homeScorePen,  int awayScorePen,  int yellowCardsHome,  int yellowCardsAway,  int redCardsHome,  int redCardsAway)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoccerScoreModelV2() when $default != null:
return $default(_that.sportId,_that.homeScoreFT,_that.awayScoreFT,_that.homeScoreH2,_that.awayScoreH2,_that.homeCorner,_that.awayCorner,_that.homeScoreOT,_that.awayScoreOT,_that.homeScorePen,_that.awayScorePen,_that.yellowCardsHome,_that.yellowCardsAway,_that.redCardsHome,_that.redCardsAway);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  int homeScoreFT,  int awayScoreFT,  int homeScoreH2,  int awayScoreH2,  int homeCorner,  int awayCorner,  int homeScoreOT,  int awayScoreOT,  int homeScorePen,  int awayScorePen,  int yellowCardsHome,  int yellowCardsAway,  int redCardsHome,  int redCardsAway)  $default,) {final _that = this;
switch (_that) {
case _SoccerScoreModelV2():
return $default(_that.sportId,_that.homeScoreFT,_that.awayScoreFT,_that.homeScoreH2,_that.awayScoreH2,_that.homeCorner,_that.awayCorner,_that.homeScoreOT,_that.awayScoreOT,_that.homeScorePen,_that.awayScorePen,_that.yellowCardsHome,_that.yellowCardsAway,_that.redCardsHome,_that.redCardsAway);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  int homeScoreFT,  int awayScoreFT,  int homeScoreH2,  int awayScoreH2,  int homeCorner,  int awayCorner,  int homeScoreOT,  int awayScoreOT,  int homeScorePen,  int awayScorePen,  int yellowCardsHome,  int yellowCardsAway,  int redCardsHome,  int redCardsAway)?  $default,) {final _that = this;
switch (_that) {
case _SoccerScoreModelV2() when $default != null:
return $default(_that.sportId,_that.homeScoreFT,_that.awayScoreFT,_that.homeScoreH2,_that.awayScoreH2,_that.homeCorner,_that.awayCorner,_that.homeScoreOT,_that.awayScoreOT,_that.homeScorePen,_that.awayScorePen,_that.yellowCardsHome,_that.yellowCardsAway,_that.redCardsHome,_that.redCardsAway);case _:
  return null;

}
}

}

/// @nodoc


class _SoccerScoreModelV2 extends SoccerScoreModelV2 {
  const _SoccerScoreModelV2({this.sportId = 1, this.homeScoreFT = 0, this.awayScoreFT = 0, this.homeScoreH2 = 0, this.awayScoreH2 = 0, this.homeCorner = 0, this.awayCorner = 0, this.homeScoreOT = 0, this.awayScoreOT = 0, this.homeScorePen = 0, this.awayScorePen = 0, this.yellowCardsHome = 0, this.yellowCardsAway = 0, this.redCardsHome = 0, this.redCardsAway = 0}): super._();
  

/// Sport ID (always 1 for Soccer)
@override@JsonKey() final  int sportId;
/// Home score full time
@override@JsonKey() final  int homeScoreFT;
/// Away score full time
@override@JsonKey() final  int awayScoreFT;
/// Home score second half
@override@JsonKey() final  int homeScoreH2;
/// Away score second half
@override@JsonKey() final  int awayScoreH2;
/// Home team corner count
@override@JsonKey() final  int homeCorner;
/// Away team corner count
@override@JsonKey() final  int awayCorner;
/// Home score overtime
@override@JsonKey() final  int homeScoreOT;
/// Away score overtime
@override@JsonKey() final  int awayScoreOT;
/// Home score penalty
@override@JsonKey() final  int homeScorePen;
/// Away score penalty
@override@JsonKey() final  int awayScorePen;
/// Home yellow cards
@override@JsonKey() final  int yellowCardsHome;
/// Away yellow cards
@override@JsonKey() final  int yellowCardsAway;
/// Home red cards
@override@JsonKey() final  int redCardsHome;
/// Away red cards
@override@JsonKey() final  int redCardsAway;

/// Create a copy of SoccerScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoccerScoreModelV2CopyWith<_SoccerScoreModelV2> get copyWith => __$SoccerScoreModelV2CopyWithImpl<_SoccerScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoccerScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.homeScoreFT, homeScoreFT) || other.homeScoreFT == homeScoreFT)&&(identical(other.awayScoreFT, awayScoreFT) || other.awayScoreFT == awayScoreFT)&&(identical(other.homeScoreH2, homeScoreH2) || other.homeScoreH2 == homeScoreH2)&&(identical(other.awayScoreH2, awayScoreH2) || other.awayScoreH2 == awayScoreH2)&&(identical(other.homeCorner, homeCorner) || other.homeCorner == homeCorner)&&(identical(other.awayCorner, awayCorner) || other.awayCorner == awayCorner)&&(identical(other.homeScoreOT, homeScoreOT) || other.homeScoreOT == homeScoreOT)&&(identical(other.awayScoreOT, awayScoreOT) || other.awayScoreOT == awayScoreOT)&&(identical(other.homeScorePen, homeScorePen) || other.homeScorePen == homeScorePen)&&(identical(other.awayScorePen, awayScorePen) || other.awayScorePen == awayScorePen)&&(identical(other.yellowCardsHome, yellowCardsHome) || other.yellowCardsHome == yellowCardsHome)&&(identical(other.yellowCardsAway, yellowCardsAway) || other.yellowCardsAway == yellowCardsAway)&&(identical(other.redCardsHome, redCardsHome) || other.redCardsHome == redCardsHome)&&(identical(other.redCardsAway, redCardsAway) || other.redCardsAway == redCardsAway));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,homeScoreFT,awayScoreFT,homeScoreH2,awayScoreH2,homeCorner,awayCorner,homeScoreOT,awayScoreOT,homeScorePen,awayScorePen,yellowCardsHome,yellowCardsAway,redCardsHome,redCardsAway);

@override
String toString() {
  return 'SoccerScoreModelV2(sportId: $sportId, homeScoreFT: $homeScoreFT, awayScoreFT: $awayScoreFT, homeScoreH2: $homeScoreH2, awayScoreH2: $awayScoreH2, homeCorner: $homeCorner, awayCorner: $awayCorner, homeScoreOT: $homeScoreOT, awayScoreOT: $awayScoreOT, homeScorePen: $homeScorePen, awayScorePen: $awayScorePen, yellowCardsHome: $yellowCardsHome, yellowCardsAway: $yellowCardsAway, redCardsHome: $redCardsHome, redCardsAway: $redCardsAway)';
}


}

/// @nodoc
abstract mixin class _$SoccerScoreModelV2CopyWith<$Res> implements $SoccerScoreModelV2CopyWith<$Res> {
  factory _$SoccerScoreModelV2CopyWith(_SoccerScoreModelV2 value, $Res Function(_SoccerScoreModelV2) _then) = __$SoccerScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, int homeScoreFT, int awayScoreFT, int homeScoreH2, int awayScoreH2, int homeCorner, int awayCorner, int homeScoreOT, int awayScoreOT, int homeScorePen, int awayScorePen, int yellowCardsHome, int yellowCardsAway, int redCardsHome, int redCardsAway
});




}
/// @nodoc
class __$SoccerScoreModelV2CopyWithImpl<$Res>
    implements _$SoccerScoreModelV2CopyWith<$Res> {
  __$SoccerScoreModelV2CopyWithImpl(this._self, this._then);

  final _SoccerScoreModelV2 _self;
  final $Res Function(_SoccerScoreModelV2) _then;

/// Create a copy of SoccerScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? homeScoreFT = null,Object? awayScoreFT = null,Object? homeScoreH2 = null,Object? awayScoreH2 = null,Object? homeCorner = null,Object? awayCorner = null,Object? homeScoreOT = null,Object? awayScoreOT = null,Object? homeScorePen = null,Object? awayScorePen = null,Object? yellowCardsHome = null,Object? yellowCardsAway = null,Object? redCardsHome = null,Object? redCardsAway = null,}) {
  return _then(_SoccerScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,homeScoreFT: null == homeScoreFT ? _self.homeScoreFT : homeScoreFT // ignore: cast_nullable_to_non_nullable
as int,awayScoreFT: null == awayScoreFT ? _self.awayScoreFT : awayScoreFT // ignore: cast_nullable_to_non_nullable
as int,homeScoreH2: null == homeScoreH2 ? _self.homeScoreH2 : homeScoreH2 // ignore: cast_nullable_to_non_nullable
as int,awayScoreH2: null == awayScoreH2 ? _self.awayScoreH2 : awayScoreH2 // ignore: cast_nullable_to_non_nullable
as int,homeCorner: null == homeCorner ? _self.homeCorner : homeCorner // ignore: cast_nullable_to_non_nullable
as int,awayCorner: null == awayCorner ? _self.awayCorner : awayCorner // ignore: cast_nullable_to_non_nullable
as int,homeScoreOT: null == homeScoreOT ? _self.homeScoreOT : homeScoreOT // ignore: cast_nullable_to_non_nullable
as int,awayScoreOT: null == awayScoreOT ? _self.awayScoreOT : awayScoreOT // ignore: cast_nullable_to_non_nullable
as int,homeScorePen: null == homeScorePen ? _self.homeScorePen : homeScorePen // ignore: cast_nullable_to_non_nullable
as int,awayScorePen: null == awayScorePen ? _self.awayScorePen : awayScorePen // ignore: cast_nullable_to_non_nullable
as int,yellowCardsHome: null == yellowCardsHome ? _self.yellowCardsHome : yellowCardsHome // ignore: cast_nullable_to_non_nullable
as int,yellowCardsAway: null == yellowCardsAway ? _self.yellowCardsAway : yellowCardsAway // ignore: cast_nullable_to_non_nullable
as int,redCardsHome: null == redCardsHome ? _self.redCardsHome : redCardsHome // ignore: cast_nullable_to_non_nullable
as int,redCardsAway: null == redCardsAway ? _self.redCardsAway : redCardsAway // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$BasketballScoreModelV2 {

/// Sport ID (2 for Basketball)
 int get sportId;/// Live scores per quarter - list of HomeAwayScoreV2 pairs
 List<HomeAwayScoreV2> get liveScores;/// Home score full time
 int get homeScoreFT;/// Away score full time
 int get awayScoreFT;/// Home score overtime
 int get homeScoreOT;/// Away score overtime
 int get awayScoreOT;
/// Create a copy of BasketballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BasketballScoreModelV2CopyWith<BasketballScoreModelV2> get copyWith => _$BasketballScoreModelV2CopyWithImpl<BasketballScoreModelV2>(this as BasketballScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BasketballScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other.liveScores, liveScores)&&(identical(other.homeScoreFT, homeScoreFT) || other.homeScoreFT == homeScoreFT)&&(identical(other.awayScoreFT, awayScoreFT) || other.awayScoreFT == awayScoreFT)&&(identical(other.homeScoreOT, homeScoreOT) || other.homeScoreOT == homeScoreOT)&&(identical(other.awayScoreOT, awayScoreOT) || other.awayScoreOT == awayScoreOT));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(liveScores),homeScoreFT,awayScoreFT,homeScoreOT,awayScoreOT);

@override
String toString() {
  return 'BasketballScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeScoreFT: $homeScoreFT, awayScoreFT: $awayScoreFT, homeScoreOT: $homeScoreOT, awayScoreOT: $awayScoreOT)';
}


}

/// @nodoc
abstract mixin class $BasketballScoreModelV2CopyWith<$Res>  {
  factory $BasketballScoreModelV2CopyWith(BasketballScoreModelV2 value, $Res Function(BasketballScoreModelV2) _then) = _$BasketballScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeScoreFT, int awayScoreFT, int homeScoreOT, int awayScoreOT
});




}
/// @nodoc
class _$BasketballScoreModelV2CopyWithImpl<$Res>
    implements $BasketballScoreModelV2CopyWith<$Res> {
  _$BasketballScoreModelV2CopyWithImpl(this._self, this._then);

  final BasketballScoreModelV2 _self;
  final $Res Function(BasketballScoreModelV2) _then;

/// Create a copy of BasketballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? liveScores = null,Object? homeScoreFT = null,Object? awayScoreFT = null,Object? homeScoreOT = null,Object? awayScoreOT = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self.liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeScoreFT: null == homeScoreFT ? _self.homeScoreFT : homeScoreFT // ignore: cast_nullable_to_non_nullable
as int,awayScoreFT: null == awayScoreFT ? _self.awayScoreFT : awayScoreFT // ignore: cast_nullable_to_non_nullable
as int,homeScoreOT: null == homeScoreOT ? _self.homeScoreOT : homeScoreOT // ignore: cast_nullable_to_non_nullable
as int,awayScoreOT: null == awayScoreOT ? _self.awayScoreOT : awayScoreOT // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BasketballScoreModelV2].
extension BasketballScoreModelV2Patterns on BasketballScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BasketballScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BasketballScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BasketballScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _BasketballScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BasketballScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _BasketballScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeScoreFT,  int awayScoreFT,  int homeScoreOT,  int awayScoreOT)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BasketballScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeScoreFT,_that.awayScoreFT,_that.homeScoreOT,_that.awayScoreOT);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeScoreFT,  int awayScoreFT,  int homeScoreOT,  int awayScoreOT)  $default,) {final _that = this;
switch (_that) {
case _BasketballScoreModelV2():
return $default(_that.sportId,_that.liveScores,_that.homeScoreFT,_that.awayScoreFT,_that.homeScoreOT,_that.awayScoreOT);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeScoreFT,  int awayScoreFT,  int homeScoreOT,  int awayScoreOT)?  $default,) {final _that = this;
switch (_that) {
case _BasketballScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeScoreFT,_that.awayScoreFT,_that.homeScoreOT,_that.awayScoreOT);case _:
  return null;

}
}

}

/// @nodoc


class _BasketballScoreModelV2 extends BasketballScoreModelV2 {
  const _BasketballScoreModelV2({this.sportId = 2, final  List<HomeAwayScoreV2> liveScores = const [], this.homeScoreFT = 0, this.awayScoreFT = 0, this.homeScoreOT = 0, this.awayScoreOT = 0}): _liveScores = liveScores,super._();
  

/// Sport ID (2 for Basketball)
@override@JsonKey() final  int sportId;
/// Live scores per quarter - list of HomeAwayScoreV2 pairs
 final  List<HomeAwayScoreV2> _liveScores;
/// Live scores per quarter - list of HomeAwayScoreV2 pairs
@override@JsonKey() List<HomeAwayScoreV2> get liveScores {
  if (_liveScores is EqualUnmodifiableListView) return _liveScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveScores);
}

/// Home score full time
@override@JsonKey() final  int homeScoreFT;
/// Away score full time
@override@JsonKey() final  int awayScoreFT;
/// Home score overtime
@override@JsonKey() final  int homeScoreOT;
/// Away score overtime
@override@JsonKey() final  int awayScoreOT;

/// Create a copy of BasketballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BasketballScoreModelV2CopyWith<_BasketballScoreModelV2> get copyWith => __$BasketballScoreModelV2CopyWithImpl<_BasketballScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BasketballScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other._liveScores, _liveScores)&&(identical(other.homeScoreFT, homeScoreFT) || other.homeScoreFT == homeScoreFT)&&(identical(other.awayScoreFT, awayScoreFT) || other.awayScoreFT == awayScoreFT)&&(identical(other.homeScoreOT, homeScoreOT) || other.homeScoreOT == homeScoreOT)&&(identical(other.awayScoreOT, awayScoreOT) || other.awayScoreOT == awayScoreOT));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(_liveScores),homeScoreFT,awayScoreFT,homeScoreOT,awayScoreOT);

@override
String toString() {
  return 'BasketballScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeScoreFT: $homeScoreFT, awayScoreFT: $awayScoreFT, homeScoreOT: $homeScoreOT, awayScoreOT: $awayScoreOT)';
}


}

/// @nodoc
abstract mixin class _$BasketballScoreModelV2CopyWith<$Res> implements $BasketballScoreModelV2CopyWith<$Res> {
  factory _$BasketballScoreModelV2CopyWith(_BasketballScoreModelV2 value, $Res Function(_BasketballScoreModelV2) _then) = __$BasketballScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeScoreFT, int awayScoreFT, int homeScoreOT, int awayScoreOT
});




}
/// @nodoc
class __$BasketballScoreModelV2CopyWithImpl<$Res>
    implements _$BasketballScoreModelV2CopyWith<$Res> {
  __$BasketballScoreModelV2CopyWithImpl(this._self, this._then);

  final _BasketballScoreModelV2 _self;
  final $Res Function(_BasketballScoreModelV2) _then;

/// Create a copy of BasketballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? liveScores = null,Object? homeScoreFT = null,Object? awayScoreFT = null,Object? homeScoreOT = null,Object? awayScoreOT = null,}) {
  return _then(_BasketballScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self._liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeScoreFT: null == homeScoreFT ? _self.homeScoreFT : homeScoreFT // ignore: cast_nullable_to_non_nullable
as int,awayScoreFT: null == awayScoreFT ? _self.awayScoreFT : awayScoreFT // ignore: cast_nullable_to_non_nullable
as int,homeScoreOT: null == homeScoreOT ? _self.homeScoreOT : homeScoreOT // ignore: cast_nullable_to_non_nullable
as int,awayScoreOT: null == awayScoreOT ? _self.awayScoreOT : awayScoreOT // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TennisScoreModelV2 {

/// Sport ID (4 for Tennis)
 int get sportId;/// Games won per set — 5 slots, empty string = set chưa diễn ra
 List<HomeAwayScoreV2> get liveScores;/// Số set đã thắng — tỉ số chính "1 - 1"
 int get homeSetScore; int get awaySetScore;// 403/404 (homeGameScore/awayGameScore) — ABSENT in server data, skipped
/// Điểm trong game hiện tại
/// Regular: "0","15","30","40","Ad" — Tie-break: "1","2","3"...
 String? get homeCurrentPoint; String? get awayCurrentPoint;/// Bên đang giao bóng: "1" = home, "2" = away
 String? get servingSide;/// Set đang đấu (1-based)
 int get currentSet;
/// Create a copy of TennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TennisScoreModelV2CopyWith<TennisScoreModelV2> get copyWith => _$TennisScoreModelV2CopyWithImpl<TennisScoreModelV2>(this as TennisScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TennisScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other.liveScores, liveScores)&&(identical(other.homeSetScore, homeSetScore) || other.homeSetScore == homeSetScore)&&(identical(other.awaySetScore, awaySetScore) || other.awaySetScore == awaySetScore)&&(identical(other.homeCurrentPoint, homeCurrentPoint) || other.homeCurrentPoint == homeCurrentPoint)&&(identical(other.awayCurrentPoint, awayCurrentPoint) || other.awayCurrentPoint == awayCurrentPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(liveScores),homeSetScore,awaySetScore,homeCurrentPoint,awayCurrentPoint,servingSide,currentSet);

@override
String toString() {
  return 'TennisScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeSetScore: $homeSetScore, awaySetScore: $awaySetScore, homeCurrentPoint: $homeCurrentPoint, awayCurrentPoint: $awayCurrentPoint, servingSide: $servingSide, currentSet: $currentSet)';
}


}

/// @nodoc
abstract mixin class $TennisScoreModelV2CopyWith<$Res>  {
  factory $TennisScoreModelV2CopyWith(TennisScoreModelV2 value, $Res Function(TennisScoreModelV2) _then) = _$TennisScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeSetScore, int awaySetScore, String? homeCurrentPoint, String? awayCurrentPoint, String? servingSide, int currentSet
});




}
/// @nodoc
class _$TennisScoreModelV2CopyWithImpl<$Res>
    implements $TennisScoreModelV2CopyWith<$Res> {
  _$TennisScoreModelV2CopyWithImpl(this._self, this._then);

  final TennisScoreModelV2 _self;
  final $Res Function(TennisScoreModelV2) _then;

/// Create a copy of TennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? liveScores = null,Object? homeSetScore = null,Object? awaySetScore = null,Object? homeCurrentPoint = freezed,Object? awayCurrentPoint = freezed,Object? servingSide = freezed,Object? currentSet = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self.liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeSetScore: null == homeSetScore ? _self.homeSetScore : homeSetScore // ignore: cast_nullable_to_non_nullable
as int,awaySetScore: null == awaySetScore ? _self.awaySetScore : awaySetScore // ignore: cast_nullable_to_non_nullable
as int,homeCurrentPoint: freezed == homeCurrentPoint ? _self.homeCurrentPoint : homeCurrentPoint // ignore: cast_nullable_to_non_nullable
as String?,awayCurrentPoint: freezed == awayCurrentPoint ? _self.awayCurrentPoint : awayCurrentPoint // ignore: cast_nullable_to_non_nullable
as String?,servingSide: freezed == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String?,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TennisScoreModelV2].
extension TennisScoreModelV2Patterns on TennisScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TennisScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TennisScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TennisScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _TennisScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TennisScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _TennisScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  String? homeCurrentPoint,  String? awayCurrentPoint,  String? servingSide,  int currentSet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TennisScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeCurrentPoint,_that.awayCurrentPoint,_that.servingSide,_that.currentSet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  String? homeCurrentPoint,  String? awayCurrentPoint,  String? servingSide,  int currentSet)  $default,) {final _that = this;
switch (_that) {
case _TennisScoreModelV2():
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeCurrentPoint,_that.awayCurrentPoint,_that.servingSide,_that.currentSet);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  String? homeCurrentPoint,  String? awayCurrentPoint,  String? servingSide,  int currentSet)?  $default,) {final _that = this;
switch (_that) {
case _TennisScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeCurrentPoint,_that.awayCurrentPoint,_that.servingSide,_that.currentSet);case _:
  return null;

}
}

}

/// @nodoc


class _TennisScoreModelV2 extends TennisScoreModelV2 {
  const _TennisScoreModelV2({this.sportId = 4, final  List<HomeAwayScoreV2> liveScores = const [], this.homeSetScore = 0, this.awaySetScore = 0, this.homeCurrentPoint, this.awayCurrentPoint, this.servingSide, this.currentSet = 0}): _liveScores = liveScores,super._();
  

/// Sport ID (4 for Tennis)
@override@JsonKey() final  int sportId;
/// Games won per set — 5 slots, empty string = set chưa diễn ra
 final  List<HomeAwayScoreV2> _liveScores;
/// Games won per set — 5 slots, empty string = set chưa diễn ra
@override@JsonKey() List<HomeAwayScoreV2> get liveScores {
  if (_liveScores is EqualUnmodifiableListView) return _liveScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveScores);
}

/// Số set đã thắng — tỉ số chính "1 - 1"
@override@JsonKey() final  int homeSetScore;
@override@JsonKey() final  int awaySetScore;
// 403/404 (homeGameScore/awayGameScore) — ABSENT in server data, skipped
/// Điểm trong game hiện tại
/// Regular: "0","15","30","40","Ad" — Tie-break: "1","2","3"...
@override final  String? homeCurrentPoint;
@override final  String? awayCurrentPoint;
/// Bên đang giao bóng: "1" = home, "2" = away
@override final  String? servingSide;
/// Set đang đấu (1-based)
@override@JsonKey() final  int currentSet;

/// Create a copy of TennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TennisScoreModelV2CopyWith<_TennisScoreModelV2> get copyWith => __$TennisScoreModelV2CopyWithImpl<_TennisScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TennisScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other._liveScores, _liveScores)&&(identical(other.homeSetScore, homeSetScore) || other.homeSetScore == homeSetScore)&&(identical(other.awaySetScore, awaySetScore) || other.awaySetScore == awaySetScore)&&(identical(other.homeCurrentPoint, homeCurrentPoint) || other.homeCurrentPoint == homeCurrentPoint)&&(identical(other.awayCurrentPoint, awayCurrentPoint) || other.awayCurrentPoint == awayCurrentPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(_liveScores),homeSetScore,awaySetScore,homeCurrentPoint,awayCurrentPoint,servingSide,currentSet);

@override
String toString() {
  return 'TennisScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeSetScore: $homeSetScore, awaySetScore: $awaySetScore, homeCurrentPoint: $homeCurrentPoint, awayCurrentPoint: $awayCurrentPoint, servingSide: $servingSide, currentSet: $currentSet)';
}


}

/// @nodoc
abstract mixin class _$TennisScoreModelV2CopyWith<$Res> implements $TennisScoreModelV2CopyWith<$Res> {
  factory _$TennisScoreModelV2CopyWith(_TennisScoreModelV2 value, $Res Function(_TennisScoreModelV2) _then) = __$TennisScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeSetScore, int awaySetScore, String? homeCurrentPoint, String? awayCurrentPoint, String? servingSide, int currentSet
});




}
/// @nodoc
class __$TennisScoreModelV2CopyWithImpl<$Res>
    implements _$TennisScoreModelV2CopyWith<$Res> {
  __$TennisScoreModelV2CopyWithImpl(this._self, this._then);

  final _TennisScoreModelV2 _self;
  final $Res Function(_TennisScoreModelV2) _then;

/// Create a copy of TennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? liveScores = null,Object? homeSetScore = null,Object? awaySetScore = null,Object? homeCurrentPoint = freezed,Object? awayCurrentPoint = freezed,Object? servingSide = freezed,Object? currentSet = null,}) {
  return _then(_TennisScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self._liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeSetScore: null == homeSetScore ? _self.homeSetScore : homeSetScore // ignore: cast_nullable_to_non_nullable
as int,awaySetScore: null == awaySetScore ? _self.awaySetScore : awaySetScore // ignore: cast_nullable_to_non_nullable
as int,homeCurrentPoint: freezed == homeCurrentPoint ? _self.homeCurrentPoint : homeCurrentPoint // ignore: cast_nullable_to_non_nullable
as String?,awayCurrentPoint: freezed == awayCurrentPoint ? _self.awayCurrentPoint : awayCurrentPoint // ignore: cast_nullable_to_non_nullable
as String?,servingSide: freezed == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String?,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$VolleyballScoreModelV2 {

/// Sport ID (5 for Volleyball)
 int get sportId;/// Live scores per set
 List<HomeAwayScoreV2> get liveScores;/// Home number of set wins
 int get homeSetScore;/// Away number of set wins
 int get awaySetScore;/// Home total points
 int get homeTotalPoint;/// Away total points
 int get awayTotalPoint;/// Serving side
 String get servingSide;/// Current set
 int get currentSet;/// Number of sets
 String get numOfSets;
/// Create a copy of VolleyballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VolleyballScoreModelV2CopyWith<VolleyballScoreModelV2> get copyWith => _$VolleyballScoreModelV2CopyWithImpl<VolleyballScoreModelV2>(this as VolleyballScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VolleyballScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other.liveScores, liveScores)&&(identical(other.homeSetScore, homeSetScore) || other.homeSetScore == homeSetScore)&&(identical(other.awaySetScore, awaySetScore) || other.awaySetScore == awaySetScore)&&(identical(other.homeTotalPoint, homeTotalPoint) || other.homeTotalPoint == homeTotalPoint)&&(identical(other.awayTotalPoint, awayTotalPoint) || other.awayTotalPoint == awayTotalPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.numOfSets, numOfSets) || other.numOfSets == numOfSets));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(liveScores),homeSetScore,awaySetScore,homeTotalPoint,awayTotalPoint,servingSide,currentSet,numOfSets);

@override
String toString() {
  return 'VolleyballScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeSetScore: $homeSetScore, awaySetScore: $awaySetScore, homeTotalPoint: $homeTotalPoint, awayTotalPoint: $awayTotalPoint, servingSide: $servingSide, currentSet: $currentSet, numOfSets: $numOfSets)';
}


}

/// @nodoc
abstract mixin class $VolleyballScoreModelV2CopyWith<$Res>  {
  factory $VolleyballScoreModelV2CopyWith(VolleyballScoreModelV2 value, $Res Function(VolleyballScoreModelV2) _then) = _$VolleyballScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeSetScore, int awaySetScore, int homeTotalPoint, int awayTotalPoint, String servingSide, int currentSet, String numOfSets
});




}
/// @nodoc
class _$VolleyballScoreModelV2CopyWithImpl<$Res>
    implements $VolleyballScoreModelV2CopyWith<$Res> {
  _$VolleyballScoreModelV2CopyWithImpl(this._self, this._then);

  final VolleyballScoreModelV2 _self;
  final $Res Function(VolleyballScoreModelV2) _then;

/// Create a copy of VolleyballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? liveScores = null,Object? homeSetScore = null,Object? awaySetScore = null,Object? homeTotalPoint = null,Object? awayTotalPoint = null,Object? servingSide = null,Object? currentSet = null,Object? numOfSets = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self.liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeSetScore: null == homeSetScore ? _self.homeSetScore : homeSetScore // ignore: cast_nullable_to_non_nullable
as int,awaySetScore: null == awaySetScore ? _self.awaySetScore : awaySetScore // ignore: cast_nullable_to_non_nullable
as int,homeTotalPoint: null == homeTotalPoint ? _self.homeTotalPoint : homeTotalPoint // ignore: cast_nullable_to_non_nullable
as int,awayTotalPoint: null == awayTotalPoint ? _self.awayTotalPoint : awayTotalPoint // ignore: cast_nullable_to_non_nullable
as int,servingSide: null == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,numOfSets: null == numOfSets ? _self.numOfSets : numOfSets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VolleyballScoreModelV2].
extension VolleyballScoreModelV2Patterns on VolleyballScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VolleyballScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VolleyballScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VolleyballScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _VolleyballScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VolleyballScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _VolleyballScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  int homeTotalPoint,  int awayTotalPoint,  String servingSide,  int currentSet,  String numOfSets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VolleyballScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  int homeTotalPoint,  int awayTotalPoint,  String servingSide,  int currentSet,  String numOfSets)  $default,) {final _that = this;
switch (_that) {
case _VolleyballScoreModelV2():
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  int homeTotalPoint,  int awayTotalPoint,  String servingSide,  int currentSet,  String numOfSets)?  $default,) {final _that = this;
switch (_that) {
case _VolleyballScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);case _:
  return null;

}
}

}

/// @nodoc


class _VolleyballScoreModelV2 extends VolleyballScoreModelV2 {
  const _VolleyballScoreModelV2({this.sportId = 5, final  List<HomeAwayScoreV2> liveScores = const [], this.homeSetScore = 0, this.awaySetScore = 0, this.homeTotalPoint = 0, this.awayTotalPoint = 0, this.servingSide = '', this.currentSet = 0, this.numOfSets = ''}): _liveScores = liveScores,super._();
  

/// Sport ID (5 for Volleyball)
@override@JsonKey() final  int sportId;
/// Live scores per set
 final  List<HomeAwayScoreV2> _liveScores;
/// Live scores per set
@override@JsonKey() List<HomeAwayScoreV2> get liveScores {
  if (_liveScores is EqualUnmodifiableListView) return _liveScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveScores);
}

/// Home number of set wins
@override@JsonKey() final  int homeSetScore;
/// Away number of set wins
@override@JsonKey() final  int awaySetScore;
/// Home total points
@override@JsonKey() final  int homeTotalPoint;
/// Away total points
@override@JsonKey() final  int awayTotalPoint;
/// Serving side
@override@JsonKey() final  String servingSide;
/// Current set
@override@JsonKey() final  int currentSet;
/// Number of sets
@override@JsonKey() final  String numOfSets;

/// Create a copy of VolleyballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VolleyballScoreModelV2CopyWith<_VolleyballScoreModelV2> get copyWith => __$VolleyballScoreModelV2CopyWithImpl<_VolleyballScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VolleyballScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other._liveScores, _liveScores)&&(identical(other.homeSetScore, homeSetScore) || other.homeSetScore == homeSetScore)&&(identical(other.awaySetScore, awaySetScore) || other.awaySetScore == awaySetScore)&&(identical(other.homeTotalPoint, homeTotalPoint) || other.homeTotalPoint == homeTotalPoint)&&(identical(other.awayTotalPoint, awayTotalPoint) || other.awayTotalPoint == awayTotalPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.numOfSets, numOfSets) || other.numOfSets == numOfSets));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(_liveScores),homeSetScore,awaySetScore,homeTotalPoint,awayTotalPoint,servingSide,currentSet,numOfSets);

@override
String toString() {
  return 'VolleyballScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeSetScore: $homeSetScore, awaySetScore: $awaySetScore, homeTotalPoint: $homeTotalPoint, awayTotalPoint: $awayTotalPoint, servingSide: $servingSide, currentSet: $currentSet, numOfSets: $numOfSets)';
}


}

/// @nodoc
abstract mixin class _$VolleyballScoreModelV2CopyWith<$Res> implements $VolleyballScoreModelV2CopyWith<$Res> {
  factory _$VolleyballScoreModelV2CopyWith(_VolleyballScoreModelV2 value, $Res Function(_VolleyballScoreModelV2) _then) = __$VolleyballScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeSetScore, int awaySetScore, int homeTotalPoint, int awayTotalPoint, String servingSide, int currentSet, String numOfSets
});




}
/// @nodoc
class __$VolleyballScoreModelV2CopyWithImpl<$Res>
    implements _$VolleyballScoreModelV2CopyWith<$Res> {
  __$VolleyballScoreModelV2CopyWithImpl(this._self, this._then);

  final _VolleyballScoreModelV2 _self;
  final $Res Function(_VolleyballScoreModelV2) _then;

/// Create a copy of VolleyballScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? liveScores = null,Object? homeSetScore = null,Object? awaySetScore = null,Object? homeTotalPoint = null,Object? awayTotalPoint = null,Object? servingSide = null,Object? currentSet = null,Object? numOfSets = null,}) {
  return _then(_VolleyballScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self._liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeSetScore: null == homeSetScore ? _self.homeSetScore : homeSetScore // ignore: cast_nullable_to_non_nullable
as int,awaySetScore: null == awaySetScore ? _self.awaySetScore : awaySetScore // ignore: cast_nullable_to_non_nullable
as int,homeTotalPoint: null == homeTotalPoint ? _self.homeTotalPoint : homeTotalPoint // ignore: cast_nullable_to_non_nullable
as int,awayTotalPoint: null == awayTotalPoint ? _self.awayTotalPoint : awayTotalPoint // ignore: cast_nullable_to_non_nullable
as int,servingSide: null == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,numOfSets: null == numOfSets ? _self.numOfSets : numOfSets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BadmintonScoreModelV2 {

/// Sport ID (7 for Badminton)
 int get sportId;/// Array 5 slots from server, only max 3 meaningful (numOfGames = "3")
 List<HomeAwayScoreV2> get liveScores;/// Number of games won — main score "1 - 0"
 int get homeGameScore; int get awayGameScore;/// Total points across all games
 int get homeTotalPoint; int get awayTotalPoint;/// Serving side — nullable (705 absent in sample data)
 String? get servingSide;/// Current set/game being played (1-based) — USE THIS for display, NOT gamePart
 int get currentSet;/// Total number of sets: always "3" for badminton
 String get numOfSets;
/// Create a copy of BadmintonScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadmintonScoreModelV2CopyWith<BadmintonScoreModelV2> get copyWith => _$BadmintonScoreModelV2CopyWithImpl<BadmintonScoreModelV2>(this as BadmintonScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadmintonScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other.liveScores, liveScores)&&(identical(other.homeGameScore, homeGameScore) || other.homeGameScore == homeGameScore)&&(identical(other.awayGameScore, awayGameScore) || other.awayGameScore == awayGameScore)&&(identical(other.homeTotalPoint, homeTotalPoint) || other.homeTotalPoint == homeTotalPoint)&&(identical(other.awayTotalPoint, awayTotalPoint) || other.awayTotalPoint == awayTotalPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.numOfSets, numOfSets) || other.numOfSets == numOfSets));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(liveScores),homeGameScore,awayGameScore,homeTotalPoint,awayTotalPoint,servingSide,currentSet,numOfSets);

@override
String toString() {
  return 'BadmintonScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeGameScore: $homeGameScore, awayGameScore: $awayGameScore, homeTotalPoint: $homeTotalPoint, awayTotalPoint: $awayTotalPoint, servingSide: $servingSide, currentSet: $currentSet, numOfSets: $numOfSets)';
}


}

/// @nodoc
abstract mixin class $BadmintonScoreModelV2CopyWith<$Res>  {
  factory $BadmintonScoreModelV2CopyWith(BadmintonScoreModelV2 value, $Res Function(BadmintonScoreModelV2) _then) = _$BadmintonScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeGameScore, int awayGameScore, int homeTotalPoint, int awayTotalPoint, String? servingSide, int currentSet, String numOfSets
});




}
/// @nodoc
class _$BadmintonScoreModelV2CopyWithImpl<$Res>
    implements $BadmintonScoreModelV2CopyWith<$Res> {
  _$BadmintonScoreModelV2CopyWithImpl(this._self, this._then);

  final BadmintonScoreModelV2 _self;
  final $Res Function(BadmintonScoreModelV2) _then;

/// Create a copy of BadmintonScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? liveScores = null,Object? homeGameScore = null,Object? awayGameScore = null,Object? homeTotalPoint = null,Object? awayTotalPoint = null,Object? servingSide = freezed,Object? currentSet = null,Object? numOfSets = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self.liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeGameScore: null == homeGameScore ? _self.homeGameScore : homeGameScore // ignore: cast_nullable_to_non_nullable
as int,awayGameScore: null == awayGameScore ? _self.awayGameScore : awayGameScore // ignore: cast_nullable_to_non_nullable
as int,homeTotalPoint: null == homeTotalPoint ? _self.homeTotalPoint : homeTotalPoint // ignore: cast_nullable_to_non_nullable
as int,awayTotalPoint: null == awayTotalPoint ? _self.awayTotalPoint : awayTotalPoint // ignore: cast_nullable_to_non_nullable
as int,servingSide: freezed == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String?,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,numOfSets: null == numOfSets ? _self.numOfSets : numOfSets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BadmintonScoreModelV2].
extension BadmintonScoreModelV2Patterns on BadmintonScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadmintonScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadmintonScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadmintonScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _BadmintonScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadmintonScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _BadmintonScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeGameScore,  int awayGameScore,  int homeTotalPoint,  int awayTotalPoint,  String? servingSide,  int currentSet,  String numOfSets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadmintonScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeGameScore,_that.awayGameScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeGameScore,  int awayGameScore,  int homeTotalPoint,  int awayTotalPoint,  String? servingSide,  int currentSet,  String numOfSets)  $default,) {final _that = this;
switch (_that) {
case _BadmintonScoreModelV2():
return $default(_that.sportId,_that.liveScores,_that.homeGameScore,_that.awayGameScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeGameScore,  int awayGameScore,  int homeTotalPoint,  int awayTotalPoint,  String? servingSide,  int currentSet,  String numOfSets)?  $default,) {final _that = this;
switch (_that) {
case _BadmintonScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeGameScore,_that.awayGameScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);case _:
  return null;

}
}

}

/// @nodoc


class _BadmintonScoreModelV2 extends BadmintonScoreModelV2 {
  const _BadmintonScoreModelV2({this.sportId = 7, final  List<HomeAwayScoreV2> liveScores = const [], this.homeGameScore = 0, this.awayGameScore = 0, this.homeTotalPoint = 0, this.awayTotalPoint = 0, this.servingSide, this.currentSet = 0, this.numOfSets = '3'}): _liveScores = liveScores,super._();
  

/// Sport ID (7 for Badminton)
@override@JsonKey() final  int sportId;
/// Array 5 slots from server, only max 3 meaningful (numOfGames = "3")
 final  List<HomeAwayScoreV2> _liveScores;
/// Array 5 slots from server, only max 3 meaningful (numOfGames = "3")
@override@JsonKey() List<HomeAwayScoreV2> get liveScores {
  if (_liveScores is EqualUnmodifiableListView) return _liveScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveScores);
}

/// Number of games won — main score "1 - 0"
@override@JsonKey() final  int homeGameScore;
@override@JsonKey() final  int awayGameScore;
/// Total points across all games
@override@JsonKey() final  int homeTotalPoint;
@override@JsonKey() final  int awayTotalPoint;
/// Serving side — nullable (705 absent in sample data)
@override final  String? servingSide;
/// Current set/game being played (1-based) — USE THIS for display, NOT gamePart
@override@JsonKey() final  int currentSet;
/// Total number of sets: always "3" for badminton
@override@JsonKey() final  String numOfSets;

/// Create a copy of BadmintonScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadmintonScoreModelV2CopyWith<_BadmintonScoreModelV2> get copyWith => __$BadmintonScoreModelV2CopyWithImpl<_BadmintonScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadmintonScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other._liveScores, _liveScores)&&(identical(other.homeGameScore, homeGameScore) || other.homeGameScore == homeGameScore)&&(identical(other.awayGameScore, awayGameScore) || other.awayGameScore == awayGameScore)&&(identical(other.homeTotalPoint, homeTotalPoint) || other.homeTotalPoint == homeTotalPoint)&&(identical(other.awayTotalPoint, awayTotalPoint) || other.awayTotalPoint == awayTotalPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.numOfSets, numOfSets) || other.numOfSets == numOfSets));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(_liveScores),homeGameScore,awayGameScore,homeTotalPoint,awayTotalPoint,servingSide,currentSet,numOfSets);

@override
String toString() {
  return 'BadmintonScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeGameScore: $homeGameScore, awayGameScore: $awayGameScore, homeTotalPoint: $homeTotalPoint, awayTotalPoint: $awayTotalPoint, servingSide: $servingSide, currentSet: $currentSet, numOfSets: $numOfSets)';
}


}

/// @nodoc
abstract mixin class _$BadmintonScoreModelV2CopyWith<$Res> implements $BadmintonScoreModelV2CopyWith<$Res> {
  factory _$BadmintonScoreModelV2CopyWith(_BadmintonScoreModelV2 value, $Res Function(_BadmintonScoreModelV2) _then) = __$BadmintonScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeGameScore, int awayGameScore, int homeTotalPoint, int awayTotalPoint, String? servingSide, int currentSet, String numOfSets
});




}
/// @nodoc
class __$BadmintonScoreModelV2CopyWithImpl<$Res>
    implements _$BadmintonScoreModelV2CopyWith<$Res> {
  __$BadmintonScoreModelV2CopyWithImpl(this._self, this._then);

  final _BadmintonScoreModelV2 _self;
  final $Res Function(_BadmintonScoreModelV2) _then;

/// Create a copy of BadmintonScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? liveScores = null,Object? homeGameScore = null,Object? awayGameScore = null,Object? homeTotalPoint = null,Object? awayTotalPoint = null,Object? servingSide = freezed,Object? currentSet = null,Object? numOfSets = null,}) {
  return _then(_BadmintonScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self._liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeGameScore: null == homeGameScore ? _self.homeGameScore : homeGameScore // ignore: cast_nullable_to_non_nullable
as int,awayGameScore: null == awayGameScore ? _self.awayGameScore : awayGameScore // ignore: cast_nullable_to_non_nullable
as int,homeTotalPoint: null == homeTotalPoint ? _self.homeTotalPoint : homeTotalPoint // ignore: cast_nullable_to_non_nullable
as int,awayTotalPoint: null == awayTotalPoint ? _self.awayTotalPoint : awayTotalPoint // ignore: cast_nullable_to_non_nullable
as int,servingSide: freezed == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String?,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,numOfSets: null == numOfSets ? _self.numOfSets : numOfSets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TableTennisScoreModelV2 {

/// Sport ID (6 for Table Tennis)
 int get sportId;/// Scores per set
 List<HomeAwayScoreV2> get liveScores;/// Number of sets won — main score "3 - 1"
 int get homeSetScore; int get awaySetScore;/// Total points across all sets
 int get homeTotalPoint; int get awayTotalPoint;/// Serving side
 String? get servingSide;/// Current set being played (1-based)
 int get currentSet;/// Total number of sets
 String get numOfSets;
/// Create a copy of TableTennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableTennisScoreModelV2CopyWith<TableTennisScoreModelV2> get copyWith => _$TableTennisScoreModelV2CopyWithImpl<TableTennisScoreModelV2>(this as TableTennisScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableTennisScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other.liveScores, liveScores)&&(identical(other.homeSetScore, homeSetScore) || other.homeSetScore == homeSetScore)&&(identical(other.awaySetScore, awaySetScore) || other.awaySetScore == awaySetScore)&&(identical(other.homeTotalPoint, homeTotalPoint) || other.homeTotalPoint == homeTotalPoint)&&(identical(other.awayTotalPoint, awayTotalPoint) || other.awayTotalPoint == awayTotalPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.numOfSets, numOfSets) || other.numOfSets == numOfSets));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(liveScores),homeSetScore,awaySetScore,homeTotalPoint,awayTotalPoint,servingSide,currentSet,numOfSets);

@override
String toString() {
  return 'TableTennisScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeSetScore: $homeSetScore, awaySetScore: $awaySetScore, homeTotalPoint: $homeTotalPoint, awayTotalPoint: $awayTotalPoint, servingSide: $servingSide, currentSet: $currentSet, numOfSets: $numOfSets)';
}


}

/// @nodoc
abstract mixin class $TableTennisScoreModelV2CopyWith<$Res>  {
  factory $TableTennisScoreModelV2CopyWith(TableTennisScoreModelV2 value, $Res Function(TableTennisScoreModelV2) _then) = _$TableTennisScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeSetScore, int awaySetScore, int homeTotalPoint, int awayTotalPoint, String? servingSide, int currentSet, String numOfSets
});




}
/// @nodoc
class _$TableTennisScoreModelV2CopyWithImpl<$Res>
    implements $TableTennisScoreModelV2CopyWith<$Res> {
  _$TableTennisScoreModelV2CopyWithImpl(this._self, this._then);

  final TableTennisScoreModelV2 _self;
  final $Res Function(TableTennisScoreModelV2) _then;

/// Create a copy of TableTennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? liveScores = null,Object? homeSetScore = null,Object? awaySetScore = null,Object? homeTotalPoint = null,Object? awayTotalPoint = null,Object? servingSide = freezed,Object? currentSet = null,Object? numOfSets = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self.liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeSetScore: null == homeSetScore ? _self.homeSetScore : homeSetScore // ignore: cast_nullable_to_non_nullable
as int,awaySetScore: null == awaySetScore ? _self.awaySetScore : awaySetScore // ignore: cast_nullable_to_non_nullable
as int,homeTotalPoint: null == homeTotalPoint ? _self.homeTotalPoint : homeTotalPoint // ignore: cast_nullable_to_non_nullable
as int,awayTotalPoint: null == awayTotalPoint ? _self.awayTotalPoint : awayTotalPoint // ignore: cast_nullable_to_non_nullable
as int,servingSide: freezed == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String?,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,numOfSets: null == numOfSets ? _self.numOfSets : numOfSets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TableTennisScoreModelV2].
extension TableTennisScoreModelV2Patterns on TableTennisScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableTennisScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableTennisScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableTennisScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _TableTennisScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableTennisScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _TableTennisScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  int homeTotalPoint,  int awayTotalPoint,  String? servingSide,  int currentSet,  String numOfSets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableTennisScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  int homeTotalPoint,  int awayTotalPoint,  String? servingSide,  int currentSet,  String numOfSets)  $default,) {final _that = this;
switch (_that) {
case _TableTennisScoreModelV2():
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  List<HomeAwayScoreV2> liveScores,  int homeSetScore,  int awaySetScore,  int homeTotalPoint,  int awayTotalPoint,  String? servingSide,  int currentSet,  String numOfSets)?  $default,) {final _that = this;
switch (_that) {
case _TableTennisScoreModelV2() when $default != null:
return $default(_that.sportId,_that.liveScores,_that.homeSetScore,_that.awaySetScore,_that.homeTotalPoint,_that.awayTotalPoint,_that.servingSide,_that.currentSet,_that.numOfSets);case _:
  return null;

}
}

}

/// @nodoc


class _TableTennisScoreModelV2 extends TableTennisScoreModelV2 {
  const _TableTennisScoreModelV2({this.sportId = 6, final  List<HomeAwayScoreV2> liveScores = const [], this.homeSetScore = 0, this.awaySetScore = 0, this.homeTotalPoint = 0, this.awayTotalPoint = 0, this.servingSide, this.currentSet = 0, this.numOfSets = '7'}): _liveScores = liveScores,super._();
  

/// Sport ID (6 for Table Tennis)
@override@JsonKey() final  int sportId;
/// Scores per set
 final  List<HomeAwayScoreV2> _liveScores;
/// Scores per set
@override@JsonKey() List<HomeAwayScoreV2> get liveScores {
  if (_liveScores is EqualUnmodifiableListView) return _liveScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveScores);
}

/// Number of sets won — main score "3 - 1"
@override@JsonKey() final  int homeSetScore;
@override@JsonKey() final  int awaySetScore;
/// Total points across all sets
@override@JsonKey() final  int homeTotalPoint;
@override@JsonKey() final  int awayTotalPoint;
/// Serving side
@override final  String? servingSide;
/// Current set being played (1-based)
@override@JsonKey() final  int currentSet;
/// Total number of sets
@override@JsonKey() final  String numOfSets;

/// Create a copy of TableTennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableTennisScoreModelV2CopyWith<_TableTennisScoreModelV2> get copyWith => __$TableTennisScoreModelV2CopyWithImpl<_TableTennisScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableTennisScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&const DeepCollectionEquality().equals(other._liveScores, _liveScores)&&(identical(other.homeSetScore, homeSetScore) || other.homeSetScore == homeSetScore)&&(identical(other.awaySetScore, awaySetScore) || other.awaySetScore == awaySetScore)&&(identical(other.homeTotalPoint, homeTotalPoint) || other.homeTotalPoint == homeTotalPoint)&&(identical(other.awayTotalPoint, awayTotalPoint) || other.awayTotalPoint == awayTotalPoint)&&(identical(other.servingSide, servingSide) || other.servingSide == servingSide)&&(identical(other.currentSet, currentSet) || other.currentSet == currentSet)&&(identical(other.numOfSets, numOfSets) || other.numOfSets == numOfSets));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,const DeepCollectionEquality().hash(_liveScores),homeSetScore,awaySetScore,homeTotalPoint,awayTotalPoint,servingSide,currentSet,numOfSets);

@override
String toString() {
  return 'TableTennisScoreModelV2(sportId: $sportId, liveScores: $liveScores, homeSetScore: $homeSetScore, awaySetScore: $awaySetScore, homeTotalPoint: $homeTotalPoint, awayTotalPoint: $awayTotalPoint, servingSide: $servingSide, currentSet: $currentSet, numOfSets: $numOfSets)';
}


}

/// @nodoc
abstract mixin class _$TableTennisScoreModelV2CopyWith<$Res> implements $TableTennisScoreModelV2CopyWith<$Res> {
  factory _$TableTennisScoreModelV2CopyWith(_TableTennisScoreModelV2 value, $Res Function(_TableTennisScoreModelV2) _then) = __$TableTennisScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, List<HomeAwayScoreV2> liveScores, int homeSetScore, int awaySetScore, int homeTotalPoint, int awayTotalPoint, String? servingSide, int currentSet, String numOfSets
});




}
/// @nodoc
class __$TableTennisScoreModelV2CopyWithImpl<$Res>
    implements _$TableTennisScoreModelV2CopyWith<$Res> {
  __$TableTennisScoreModelV2CopyWithImpl(this._self, this._then);

  final _TableTennisScoreModelV2 _self;
  final $Res Function(_TableTennisScoreModelV2) _then;

/// Create a copy of TableTennisScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? liveScores = null,Object? homeSetScore = null,Object? awaySetScore = null,Object? homeTotalPoint = null,Object? awayTotalPoint = null,Object? servingSide = freezed,Object? currentSet = null,Object? numOfSets = null,}) {
  return _then(_TableTennisScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,liveScores: null == liveScores ? _self._liveScores : liveScores // ignore: cast_nullable_to_non_nullable
as List<HomeAwayScoreV2>,homeSetScore: null == homeSetScore ? _self.homeSetScore : homeSetScore // ignore: cast_nullable_to_non_nullable
as int,awaySetScore: null == awaySetScore ? _self.awaySetScore : awaySetScore // ignore: cast_nullable_to_non_nullable
as int,homeTotalPoint: null == homeTotalPoint ? _self.homeTotalPoint : homeTotalPoint // ignore: cast_nullable_to_non_nullable
as int,awayTotalPoint: null == awayTotalPoint ? _self.awayTotalPoint : awayTotalPoint // ignore: cast_nullable_to_non_nullable
as int,servingSide: freezed == servingSide ? _self.servingSide : servingSide // ignore: cast_nullable_to_non_nullable
as String?,currentSet: null == currentSet ? _self.currentSet : currentSet // ignore: cast_nullable_to_non_nullable
as int,numOfSets: null == numOfSets ? _self.numOfSets : numOfSets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GenericScoreModelV2 {

 int get sportId; String get homeScoreValue; String get awayScoreValue;
/// Create a copy of GenericScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenericScoreModelV2CopyWith<GenericScoreModelV2> get copyWith => _$GenericScoreModelV2CopyWithImpl<GenericScoreModelV2>(this as GenericScoreModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenericScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.homeScoreValue, homeScoreValue) || other.homeScoreValue == homeScoreValue)&&(identical(other.awayScoreValue, awayScoreValue) || other.awayScoreValue == awayScoreValue));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,homeScoreValue,awayScoreValue);

@override
String toString() {
  return 'GenericScoreModelV2(sportId: $sportId, homeScoreValue: $homeScoreValue, awayScoreValue: $awayScoreValue)';
}


}

/// @nodoc
abstract mixin class $GenericScoreModelV2CopyWith<$Res>  {
  factory $GenericScoreModelV2CopyWith(GenericScoreModelV2 value, $Res Function(GenericScoreModelV2) _then) = _$GenericScoreModelV2CopyWithImpl;
@useResult
$Res call({
 int sportId, String homeScoreValue, String awayScoreValue
});




}
/// @nodoc
class _$GenericScoreModelV2CopyWithImpl<$Res>
    implements $GenericScoreModelV2CopyWith<$Res> {
  _$GenericScoreModelV2CopyWithImpl(this._self, this._then);

  final GenericScoreModelV2 _self;
  final $Res Function(GenericScoreModelV2) _then;

/// Create a copy of GenericScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sportId = null,Object? homeScoreValue = null,Object? awayScoreValue = null,}) {
  return _then(_self.copyWith(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,homeScoreValue: null == homeScoreValue ? _self.homeScoreValue : homeScoreValue // ignore: cast_nullable_to_non_nullable
as String,awayScoreValue: null == awayScoreValue ? _self.awayScoreValue : awayScoreValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GenericScoreModelV2].
extension GenericScoreModelV2Patterns on GenericScoreModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenericScoreModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenericScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenericScoreModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _GenericScoreModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenericScoreModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _GenericScoreModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sportId,  String homeScoreValue,  String awayScoreValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenericScoreModelV2() when $default != null:
return $default(_that.sportId,_that.homeScoreValue,_that.awayScoreValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sportId,  String homeScoreValue,  String awayScoreValue)  $default,) {final _that = this;
switch (_that) {
case _GenericScoreModelV2():
return $default(_that.sportId,_that.homeScoreValue,_that.awayScoreValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sportId,  String homeScoreValue,  String awayScoreValue)?  $default,) {final _that = this;
switch (_that) {
case _GenericScoreModelV2() when $default != null:
return $default(_that.sportId,_that.homeScoreValue,_that.awayScoreValue);case _:
  return null;

}
}

}

/// @nodoc


class _GenericScoreModelV2 extends GenericScoreModelV2 {
  const _GenericScoreModelV2({this.sportId = 0, this.homeScoreValue = '0', this.awayScoreValue = '0'}): super._();
  

@override@JsonKey() final  int sportId;
@override@JsonKey() final  String homeScoreValue;
@override@JsonKey() final  String awayScoreValue;

/// Create a copy of GenericScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenericScoreModelV2CopyWith<_GenericScoreModelV2> get copyWith => __$GenericScoreModelV2CopyWithImpl<_GenericScoreModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenericScoreModelV2&&(identical(other.sportId, sportId) || other.sportId == sportId)&&(identical(other.homeScoreValue, homeScoreValue) || other.homeScoreValue == homeScoreValue)&&(identical(other.awayScoreValue, awayScoreValue) || other.awayScoreValue == awayScoreValue));
}


@override
int get hashCode => Object.hash(runtimeType,sportId,homeScoreValue,awayScoreValue);

@override
String toString() {
  return 'GenericScoreModelV2(sportId: $sportId, homeScoreValue: $homeScoreValue, awayScoreValue: $awayScoreValue)';
}


}

/// @nodoc
abstract mixin class _$GenericScoreModelV2CopyWith<$Res> implements $GenericScoreModelV2CopyWith<$Res> {
  factory _$GenericScoreModelV2CopyWith(_GenericScoreModelV2 value, $Res Function(_GenericScoreModelV2) _then) = __$GenericScoreModelV2CopyWithImpl;
@override @useResult
$Res call({
 int sportId, String homeScoreValue, String awayScoreValue
});




}
/// @nodoc
class __$GenericScoreModelV2CopyWithImpl<$Res>
    implements _$GenericScoreModelV2CopyWith<$Res> {
  __$GenericScoreModelV2CopyWithImpl(this._self, this._then);

  final _GenericScoreModelV2 _self;
  final $Res Function(_GenericScoreModelV2) _then;

/// Create a copy of GenericScoreModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sportId = null,Object? homeScoreValue = null,Object? awayScoreValue = null,}) {
  return _then(_GenericScoreModelV2(
sportId: null == sportId ? _self.sportId : sportId // ignore: cast_nullable_to_non_nullable
as int,homeScoreValue: null == homeScoreValue ? _self.homeScoreValue : homeScoreValue // ignore: cast_nullable_to_non_nullable
as String,awayScoreValue: null == awayScoreValue ? _self.awayScoreValue : awayScoreValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$HomeAwayScoreV2 {

 String get homeScore; String get awayScore;
/// Create a copy of HomeAwayScoreV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeAwayScoreV2CopyWith<HomeAwayScoreV2> get copyWith => _$HomeAwayScoreV2CopyWithImpl<HomeAwayScoreV2>(this as HomeAwayScoreV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeAwayScoreV2&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore));
}


@override
int get hashCode => Object.hash(runtimeType,homeScore,awayScore);

@override
String toString() {
  return 'HomeAwayScoreV2(homeScore: $homeScore, awayScore: $awayScore)';
}


}

/// @nodoc
abstract mixin class $HomeAwayScoreV2CopyWith<$Res>  {
  factory $HomeAwayScoreV2CopyWith(HomeAwayScoreV2 value, $Res Function(HomeAwayScoreV2) _then) = _$HomeAwayScoreV2CopyWithImpl;
@useResult
$Res call({
 String homeScore, String awayScore
});




}
/// @nodoc
class _$HomeAwayScoreV2CopyWithImpl<$Res>
    implements $HomeAwayScoreV2CopyWith<$Res> {
  _$HomeAwayScoreV2CopyWithImpl(this._self, this._then);

  final HomeAwayScoreV2 _self;
  final $Res Function(HomeAwayScoreV2) _then;

/// Create a copy of HomeAwayScoreV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeScore = null,Object? awayScore = null,}) {
  return _then(_self.copyWith(
homeScore: null == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as String,awayScore: null == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeAwayScoreV2].
extension HomeAwayScoreV2Patterns on HomeAwayScoreV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeAwayScoreV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeAwayScoreV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeAwayScoreV2 value)  $default,){
final _that = this;
switch (_that) {
case _HomeAwayScoreV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeAwayScoreV2 value)?  $default,){
final _that = this;
switch (_that) {
case _HomeAwayScoreV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String homeScore,  String awayScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeAwayScoreV2() when $default != null:
return $default(_that.homeScore,_that.awayScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String homeScore,  String awayScore)  $default,) {final _that = this;
switch (_that) {
case _HomeAwayScoreV2():
return $default(_that.homeScore,_that.awayScore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String homeScore,  String awayScore)?  $default,) {final _that = this;
switch (_that) {
case _HomeAwayScoreV2() when $default != null:
return $default(_that.homeScore,_that.awayScore);case _:
  return null;

}
}

}

/// @nodoc


class _HomeAwayScoreV2 extends HomeAwayScoreV2 {
  const _HomeAwayScoreV2({this.homeScore = '', this.awayScore = ''}): super._();
  

@override@JsonKey() final  String homeScore;
@override@JsonKey() final  String awayScore;

/// Create a copy of HomeAwayScoreV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeAwayScoreV2CopyWith<_HomeAwayScoreV2> get copyWith => __$HomeAwayScoreV2CopyWithImpl<_HomeAwayScoreV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeAwayScoreV2&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore));
}


@override
int get hashCode => Object.hash(runtimeType,homeScore,awayScore);

@override
String toString() {
  return 'HomeAwayScoreV2(homeScore: $homeScore, awayScore: $awayScore)';
}


}

/// @nodoc
abstract mixin class _$HomeAwayScoreV2CopyWith<$Res> implements $HomeAwayScoreV2CopyWith<$Res> {
  factory _$HomeAwayScoreV2CopyWith(_HomeAwayScoreV2 value, $Res Function(_HomeAwayScoreV2) _then) = __$HomeAwayScoreV2CopyWithImpl;
@override @useResult
$Res call({
 String homeScore, String awayScore
});




}
/// @nodoc
class __$HomeAwayScoreV2CopyWithImpl<$Res>
    implements _$HomeAwayScoreV2CopyWith<$Res> {
  __$HomeAwayScoreV2CopyWithImpl(this._self, this._then);

  final _HomeAwayScoreV2 _self;
  final $Res Function(_HomeAwayScoreV2) _then;

/// Create a copy of HomeAwayScoreV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeScore = null,Object? awayScore = null,}) {
  return _then(_HomeAwayScoreV2(
homeScore: null == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as String,awayScore: null == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
