// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'odds_model_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OddsModelV2 {

/// Selection Home ID (e.g., "45422650010000000h")
 String get selectionHomeId;/// Selection Away ID (e.g., "45422650010000000a")
 String get selectionAwayId;/// Selection Draw ID (e.g., "45422650010000000d") - optional for 2-way markets
 String get selectionDrawId;/// Points/Handicap associated with the odds (e.g., "1.0", "-0.5", "0.0")
 String get points;/// Home team odds in different formats
 OddsStyleModelV2? get homeOdds;/// Away team odds in different formats
 OddsStyleModelV2? get awayOdds;/// Draw odds in different formats (for 1X2 markets)
 OddsStyleModelV2? get drawOdds;/// String Offer ID for betting placement
 String get strOfferId;/// Indicates if the odds is for the main line
 bool get isMainLine;/// Indicates if the odds is suspended (cannot place bet)
 bool get isSuspended;/// Indicates if the odds is hidden (should not be displayed)
 bool get isHidden;
/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OddsModelV2CopyWith<OddsModelV2> get copyWith => _$OddsModelV2CopyWithImpl<OddsModelV2>(this as OddsModelV2, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OddsModelV2&&(identical(other.selectionHomeId, selectionHomeId) || other.selectionHomeId == selectionHomeId)&&(identical(other.selectionAwayId, selectionAwayId) || other.selectionAwayId == selectionAwayId)&&(identical(other.selectionDrawId, selectionDrawId) || other.selectionDrawId == selectionDrawId)&&(identical(other.points, points) || other.points == points)&&(identical(other.homeOdds, homeOdds) || other.homeOdds == homeOdds)&&(identical(other.awayOdds, awayOdds) || other.awayOdds == awayOdds)&&(identical(other.drawOdds, drawOdds) || other.drawOdds == drawOdds)&&(identical(other.strOfferId, strOfferId) || other.strOfferId == strOfferId)&&(identical(other.isMainLine, isMainLine) || other.isMainLine == isMainLine)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}


@override
int get hashCode => Object.hash(runtimeType,selectionHomeId,selectionAwayId,selectionDrawId,points,homeOdds,awayOdds,drawOdds,strOfferId,isMainLine,isSuspended,isHidden);

@override
String toString() {
  return 'OddsModelV2(selectionHomeId: $selectionHomeId, selectionAwayId: $selectionAwayId, selectionDrawId: $selectionDrawId, points: $points, homeOdds: $homeOdds, awayOdds: $awayOdds, drawOdds: $drawOdds, strOfferId: $strOfferId, isMainLine: $isMainLine, isSuspended: $isSuspended, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class $OddsModelV2CopyWith<$Res>  {
  factory $OddsModelV2CopyWith(OddsModelV2 value, $Res Function(OddsModelV2) _then) = _$OddsModelV2CopyWithImpl;
@useResult
$Res call({
 String selectionHomeId, String selectionAwayId, String selectionDrawId, String points, OddsStyleModelV2? homeOdds, OddsStyleModelV2? awayOdds, OddsStyleModelV2? drawOdds, String strOfferId, bool isMainLine, bool isSuspended, bool isHidden
});


$OddsStyleModelV2CopyWith<$Res>? get homeOdds;$OddsStyleModelV2CopyWith<$Res>? get awayOdds;$OddsStyleModelV2CopyWith<$Res>? get drawOdds;

}
/// @nodoc
class _$OddsModelV2CopyWithImpl<$Res>
    implements $OddsModelV2CopyWith<$Res> {
  _$OddsModelV2CopyWithImpl(this._self, this._then);

  final OddsModelV2 _self;
  final $Res Function(OddsModelV2) _then;

/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectionHomeId = null,Object? selectionAwayId = null,Object? selectionDrawId = null,Object? points = null,Object? homeOdds = freezed,Object? awayOdds = freezed,Object? drawOdds = freezed,Object? strOfferId = null,Object? isMainLine = null,Object? isSuspended = null,Object? isHidden = null,}) {
  return _then(_self.copyWith(
selectionHomeId: null == selectionHomeId ? _self.selectionHomeId : selectionHomeId // ignore: cast_nullable_to_non_nullable
as String,selectionAwayId: null == selectionAwayId ? _self.selectionAwayId : selectionAwayId // ignore: cast_nullable_to_non_nullable
as String,selectionDrawId: null == selectionDrawId ? _self.selectionDrawId : selectionDrawId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String,homeOdds: freezed == homeOdds ? _self.homeOdds : homeOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,awayOdds: freezed == awayOdds ? _self.awayOdds : awayOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,drawOdds: freezed == drawOdds ? _self.drawOdds : drawOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,strOfferId: null == strOfferId ? _self.strOfferId : strOfferId // ignore: cast_nullable_to_non_nullable
as String,isMainLine: null == isMainLine ? _self.isMainLine : isMainLine // ignore: cast_nullable_to_non_nullable
as bool,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get homeOdds {
    if (_self.homeOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.homeOdds!, (value) {
    return _then(_self.copyWith(homeOdds: value));
  });
}/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get awayOdds {
    if (_self.awayOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.awayOdds!, (value) {
    return _then(_self.copyWith(awayOdds: value));
  });
}/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get drawOdds {
    if (_self.drawOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.drawOdds!, (value) {
    return _then(_self.copyWith(drawOdds: value));
  });
}
}


/// Adds pattern-matching-related methods to [OddsModelV2].
extension OddsModelV2Patterns on OddsModelV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OddsModelV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OddsModelV2 value)  $default,){
final _that = this;
switch (_that) {
case _OddsModelV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OddsModelV2 value)?  $default,){
final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String selectionHomeId,  String selectionAwayId,  String selectionDrawId,  String points,  OddsStyleModelV2? homeOdds,  OddsStyleModelV2? awayOdds,  OddsStyleModelV2? drawOdds,  String strOfferId,  bool isMainLine,  bool isSuspended,  bool isHidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
return $default(_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.points,_that.homeOdds,_that.awayOdds,_that.drawOdds,_that.strOfferId,_that.isMainLine,_that.isSuspended,_that.isHidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String selectionHomeId,  String selectionAwayId,  String selectionDrawId,  String points,  OddsStyleModelV2? homeOdds,  OddsStyleModelV2? awayOdds,  OddsStyleModelV2? drawOdds,  String strOfferId,  bool isMainLine,  bool isSuspended,  bool isHidden)  $default,) {final _that = this;
switch (_that) {
case _OddsModelV2():
return $default(_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.points,_that.homeOdds,_that.awayOdds,_that.drawOdds,_that.strOfferId,_that.isMainLine,_that.isSuspended,_that.isHidden);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String selectionHomeId,  String selectionAwayId,  String selectionDrawId,  String points,  OddsStyleModelV2? homeOdds,  OddsStyleModelV2? awayOdds,  OddsStyleModelV2? drawOdds,  String strOfferId,  bool isMainLine,  bool isSuspended,  bool isHidden)?  $default,) {final _that = this;
switch (_that) {
case _OddsModelV2() when $default != null:
return $default(_that.selectionHomeId,_that.selectionAwayId,_that.selectionDrawId,_that.points,_that.homeOdds,_that.awayOdds,_that.drawOdds,_that.strOfferId,_that.isMainLine,_that.isSuspended,_that.isHidden);case _:
  return null;

}
}

}

/// @nodoc


class _OddsModelV2 extends OddsModelV2 {
  const _OddsModelV2({this.selectionHomeId = '', this.selectionAwayId = '', this.selectionDrawId = '', this.points = '', this.homeOdds, this.awayOdds, this.drawOdds, this.strOfferId = '', this.isMainLine = false, this.isSuspended = false, this.isHidden = false}): super._();
  

/// Selection Home ID (e.g., "45422650010000000h")
@override@JsonKey() final  String selectionHomeId;
/// Selection Away ID (e.g., "45422650010000000a")
@override@JsonKey() final  String selectionAwayId;
/// Selection Draw ID (e.g., "45422650010000000d") - optional for 2-way markets
@override@JsonKey() final  String selectionDrawId;
/// Points/Handicap associated with the odds (e.g., "1.0", "-0.5", "0.0")
@override@JsonKey() final  String points;
/// Home team odds in different formats
@override final  OddsStyleModelV2? homeOdds;
/// Away team odds in different formats
@override final  OddsStyleModelV2? awayOdds;
/// Draw odds in different formats (for 1X2 markets)
@override final  OddsStyleModelV2? drawOdds;
/// String Offer ID for betting placement
@override@JsonKey() final  String strOfferId;
/// Indicates if the odds is for the main line
@override@JsonKey() final  bool isMainLine;
/// Indicates if the odds is suspended (cannot place bet)
@override@JsonKey() final  bool isSuspended;
/// Indicates if the odds is hidden (should not be displayed)
@override@JsonKey() final  bool isHidden;

/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OddsModelV2CopyWith<_OddsModelV2> get copyWith => __$OddsModelV2CopyWithImpl<_OddsModelV2>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OddsModelV2&&(identical(other.selectionHomeId, selectionHomeId) || other.selectionHomeId == selectionHomeId)&&(identical(other.selectionAwayId, selectionAwayId) || other.selectionAwayId == selectionAwayId)&&(identical(other.selectionDrawId, selectionDrawId) || other.selectionDrawId == selectionDrawId)&&(identical(other.points, points) || other.points == points)&&(identical(other.homeOdds, homeOdds) || other.homeOdds == homeOdds)&&(identical(other.awayOdds, awayOdds) || other.awayOdds == awayOdds)&&(identical(other.drawOdds, drawOdds) || other.drawOdds == drawOdds)&&(identical(other.strOfferId, strOfferId) || other.strOfferId == strOfferId)&&(identical(other.isMainLine, isMainLine) || other.isMainLine == isMainLine)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}


@override
int get hashCode => Object.hash(runtimeType,selectionHomeId,selectionAwayId,selectionDrawId,points,homeOdds,awayOdds,drawOdds,strOfferId,isMainLine,isSuspended,isHidden);

@override
String toString() {
  return 'OddsModelV2(selectionHomeId: $selectionHomeId, selectionAwayId: $selectionAwayId, selectionDrawId: $selectionDrawId, points: $points, homeOdds: $homeOdds, awayOdds: $awayOdds, drawOdds: $drawOdds, strOfferId: $strOfferId, isMainLine: $isMainLine, isSuspended: $isSuspended, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class _$OddsModelV2CopyWith<$Res> implements $OddsModelV2CopyWith<$Res> {
  factory _$OddsModelV2CopyWith(_OddsModelV2 value, $Res Function(_OddsModelV2) _then) = __$OddsModelV2CopyWithImpl;
@override @useResult
$Res call({
 String selectionHomeId, String selectionAwayId, String selectionDrawId, String points, OddsStyleModelV2? homeOdds, OddsStyleModelV2? awayOdds, OddsStyleModelV2? drawOdds, String strOfferId, bool isMainLine, bool isSuspended, bool isHidden
});


@override $OddsStyleModelV2CopyWith<$Res>? get homeOdds;@override $OddsStyleModelV2CopyWith<$Res>? get awayOdds;@override $OddsStyleModelV2CopyWith<$Res>? get drawOdds;

}
/// @nodoc
class __$OddsModelV2CopyWithImpl<$Res>
    implements _$OddsModelV2CopyWith<$Res> {
  __$OddsModelV2CopyWithImpl(this._self, this._then);

  final _OddsModelV2 _self;
  final $Res Function(_OddsModelV2) _then;

/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectionHomeId = null,Object? selectionAwayId = null,Object? selectionDrawId = null,Object? points = null,Object? homeOdds = freezed,Object? awayOdds = freezed,Object? drawOdds = freezed,Object? strOfferId = null,Object? isMainLine = null,Object? isSuspended = null,Object? isHidden = null,}) {
  return _then(_OddsModelV2(
selectionHomeId: null == selectionHomeId ? _self.selectionHomeId : selectionHomeId // ignore: cast_nullable_to_non_nullable
as String,selectionAwayId: null == selectionAwayId ? _self.selectionAwayId : selectionAwayId // ignore: cast_nullable_to_non_nullable
as String,selectionDrawId: null == selectionDrawId ? _self.selectionDrawId : selectionDrawId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as String,homeOdds: freezed == homeOdds ? _self.homeOdds : homeOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,awayOdds: freezed == awayOdds ? _self.awayOdds : awayOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,drawOdds: freezed == drawOdds ? _self.drawOdds : drawOdds // ignore: cast_nullable_to_non_nullable
as OddsStyleModelV2?,strOfferId: null == strOfferId ? _self.strOfferId : strOfferId // ignore: cast_nullable_to_non_nullable
as String,isMainLine: null == isMainLine ? _self.isMainLine : isMainLine // ignore: cast_nullable_to_non_nullable
as bool,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get homeOdds {
    if (_self.homeOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.homeOdds!, (value) {
    return _then(_self.copyWith(homeOdds: value));
  });
}/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get awayOdds {
    if (_self.awayOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.awayOdds!, (value) {
    return _then(_self.copyWith(awayOdds: value));
  });
}/// Create a copy of OddsModelV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OddsStyleModelV2CopyWith<$Res>? get drawOdds {
    if (_self.drawOdds == null) {
    return null;
  }

  return $OddsStyleModelV2CopyWith<$Res>(_self.drawOdds!, (value) {
    return _then(_self.copyWith(drawOdds: value));
  });
}
}

// dart format on
