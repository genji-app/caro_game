// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'special_outright_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpecialOutrightModel {

/// Selections array (API: "0")
@JsonKey(name: '0') List<SpecialOutrightSelection> get selections;/// Outright ID (API: "1")
@JsonKey(name: '1', fromJson: _safeParseInt) int get outrightId;/// Outright Name (API: "2")
/// Example: "UEFA Champions League 2025/2026 - Winner"
@JsonKey(name: '2') String get outrightName;/// End Date ISO 8601 (API: "4")
/// Example: "2026-05-30T19:00:00Z"
@JsonKey(name: '4') String get endDate;/// Start/End timestamp in milliseconds (API: "5")
@JsonKey(name: '5', fromJson: _safeParseInt) int get startTime;/// League ID (API: "6")
@JsonKey(name: '6', fromJson: _safeParseInt) int get leagueId;/// League Logo URL (API: "7")
@JsonKey(name: '7') String get leagueLogo;/// League Name (API: "8")
@JsonKey(name: '8') String get leagueName;
/// Create a copy of SpecialOutrightModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialOutrightModelCopyWith<SpecialOutrightModel> get copyWith => _$SpecialOutrightModelCopyWithImpl<SpecialOutrightModel>(this as SpecialOutrightModel, _$identity);

  /// Serializes this SpecialOutrightModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpecialOutrightModel&&const DeepCollectionEquality().equals(other.selections, selections)&&(identical(other.outrightId, outrightId) || other.outrightId == outrightId)&&(identical(other.outrightName, outrightName) || other.outrightName == outrightName)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selections),outrightId,outrightName,endDate,startTime,leagueId,leagueLogo,leagueName);

@override
String toString() {
  return 'SpecialOutrightModel(selections: $selections, outrightId: $outrightId, outrightName: $outrightName, endDate: $endDate, startTime: $startTime, leagueId: $leagueId, leagueLogo: $leagueLogo, leagueName: $leagueName)';
}


}

/// @nodoc
abstract mixin class $SpecialOutrightModelCopyWith<$Res>  {
  factory $SpecialOutrightModelCopyWith(SpecialOutrightModel value, $Res Function(SpecialOutrightModel) _then) = _$SpecialOutrightModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') List<SpecialOutrightSelection> selections,@JsonKey(name: '1', fromJson: _safeParseInt) int outrightId,@JsonKey(name: '2') String outrightName,@JsonKey(name: '4') String endDate,@JsonKey(name: '5', fromJson: _safeParseInt) int startTime,@JsonKey(name: '6', fromJson: _safeParseInt) int leagueId,@JsonKey(name: '7') String leagueLogo,@JsonKey(name: '8') String leagueName
});




}
/// @nodoc
class _$SpecialOutrightModelCopyWithImpl<$Res>
    implements $SpecialOutrightModelCopyWith<$Res> {
  _$SpecialOutrightModelCopyWithImpl(this._self, this._then);

  final SpecialOutrightModel _self;
  final $Res Function(SpecialOutrightModel) _then;

/// Create a copy of SpecialOutrightModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selections = null,Object? outrightId = null,Object? outrightName = null,Object? endDate = null,Object? startTime = null,Object? leagueId = null,Object? leagueLogo = null,Object? leagueName = null,}) {
  return _then(_self.copyWith(
selections: null == selections ? _self.selections : selections // ignore: cast_nullable_to_non_nullable
as List<SpecialOutrightSelection>,outrightId: null == outrightId ? _self.outrightId : outrightId // ignore: cast_nullable_to_non_nullable
as int,outrightName: null == outrightName ? _self.outrightName : outrightName // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpecialOutrightModel].
extension SpecialOutrightModelPatterns on SpecialOutrightModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpecialOutrightModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpecialOutrightModel value)  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpecialOutrightModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  List<SpecialOutrightSelection> selections, @JsonKey(name: '1', fromJson: _safeParseInt)  int outrightId, @JsonKey(name: '2')  String outrightName, @JsonKey(name: '4')  String endDate, @JsonKey(name: '5', fromJson: _safeParseInt)  int startTime, @JsonKey(name: '6', fromJson: _safeParseInt)  int leagueId, @JsonKey(name: '7')  String leagueLogo, @JsonKey(name: '8')  String leagueName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
return $default(_that.selections,_that.outrightId,_that.outrightName,_that.endDate,_that.startTime,_that.leagueId,_that.leagueLogo,_that.leagueName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  List<SpecialOutrightSelection> selections, @JsonKey(name: '1', fromJson: _safeParseInt)  int outrightId, @JsonKey(name: '2')  String outrightName, @JsonKey(name: '4')  String endDate, @JsonKey(name: '5', fromJson: _safeParseInt)  int startTime, @JsonKey(name: '6', fromJson: _safeParseInt)  int leagueId, @JsonKey(name: '7')  String leagueLogo, @JsonKey(name: '8')  String leagueName)  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightModel():
return $default(_that.selections,_that.outrightId,_that.outrightName,_that.endDate,_that.startTime,_that.leagueId,_that.leagueLogo,_that.leagueName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  List<SpecialOutrightSelection> selections, @JsonKey(name: '1', fromJson: _safeParseInt)  int outrightId, @JsonKey(name: '2')  String outrightName, @JsonKey(name: '4')  String endDate, @JsonKey(name: '5', fromJson: _safeParseInt)  int startTime, @JsonKey(name: '6', fromJson: _safeParseInt)  int leagueId, @JsonKey(name: '7')  String leagueLogo, @JsonKey(name: '8')  String leagueName)?  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightModel() when $default != null:
return $default(_that.selections,_that.outrightId,_that.outrightName,_that.endDate,_that.startTime,_that.leagueId,_that.leagueLogo,_that.leagueName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpecialOutrightModel implements SpecialOutrightModel {
  const _SpecialOutrightModel({@JsonKey(name: '0') final  List<SpecialOutrightSelection> selections = const [], @JsonKey(name: '1', fromJson: _safeParseInt) this.outrightId = 0, @JsonKey(name: '2') this.outrightName = '', @JsonKey(name: '4') this.endDate = '', @JsonKey(name: '5', fromJson: _safeParseInt) this.startTime = 0, @JsonKey(name: '6', fromJson: _safeParseInt) this.leagueId = 0, @JsonKey(name: '7') this.leagueLogo = '', @JsonKey(name: '8') this.leagueName = ''}): _selections = selections;
  factory _SpecialOutrightModel.fromJson(Map<String, dynamic> json) => _$SpecialOutrightModelFromJson(json);

/// Selections array (API: "0")
 final  List<SpecialOutrightSelection> _selections;
/// Selections array (API: "0")
@override@JsonKey(name: '0') List<SpecialOutrightSelection> get selections {
  if (_selections is EqualUnmodifiableListView) return _selections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selections);
}

/// Outright ID (API: "1")
@override@JsonKey(name: '1', fromJson: _safeParseInt) final  int outrightId;
/// Outright Name (API: "2")
/// Example: "UEFA Champions League 2025/2026 - Winner"
@override@JsonKey(name: '2') final  String outrightName;
/// End Date ISO 8601 (API: "4")
/// Example: "2026-05-30T19:00:00Z"
@override@JsonKey(name: '4') final  String endDate;
/// Start/End timestamp in milliseconds (API: "5")
@override@JsonKey(name: '5', fromJson: _safeParseInt) final  int startTime;
/// League ID (API: "6")
@override@JsonKey(name: '6', fromJson: _safeParseInt) final  int leagueId;
/// League Logo URL (API: "7")
@override@JsonKey(name: '7') final  String leagueLogo;
/// League Name (API: "8")
@override@JsonKey(name: '8') final  String leagueName;

/// Create a copy of SpecialOutrightModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialOutrightModelCopyWith<_SpecialOutrightModel> get copyWith => __$SpecialOutrightModelCopyWithImpl<_SpecialOutrightModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpecialOutrightModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpecialOutrightModel&&const DeepCollectionEquality().equals(other._selections, _selections)&&(identical(other.outrightId, outrightId) || other.outrightId == outrightId)&&(identical(other.outrightName, outrightName) || other.outrightName == outrightName)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.leagueId, leagueId) || other.leagueId == leagueId)&&(identical(other.leagueLogo, leagueLogo) || other.leagueLogo == leagueLogo)&&(identical(other.leagueName, leagueName) || other.leagueName == leagueName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selections),outrightId,outrightName,endDate,startTime,leagueId,leagueLogo,leagueName);

@override
String toString() {
  return 'SpecialOutrightModel(selections: $selections, outrightId: $outrightId, outrightName: $outrightName, endDate: $endDate, startTime: $startTime, leagueId: $leagueId, leagueLogo: $leagueLogo, leagueName: $leagueName)';
}


}

/// @nodoc
abstract mixin class _$SpecialOutrightModelCopyWith<$Res> implements $SpecialOutrightModelCopyWith<$Res> {
  factory _$SpecialOutrightModelCopyWith(_SpecialOutrightModel value, $Res Function(_SpecialOutrightModel) _then) = __$SpecialOutrightModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') List<SpecialOutrightSelection> selections,@JsonKey(name: '1', fromJson: _safeParseInt) int outrightId,@JsonKey(name: '2') String outrightName,@JsonKey(name: '4') String endDate,@JsonKey(name: '5', fromJson: _safeParseInt) int startTime,@JsonKey(name: '6', fromJson: _safeParseInt) int leagueId,@JsonKey(name: '7') String leagueLogo,@JsonKey(name: '8') String leagueName
});




}
/// @nodoc
class __$SpecialOutrightModelCopyWithImpl<$Res>
    implements _$SpecialOutrightModelCopyWith<$Res> {
  __$SpecialOutrightModelCopyWithImpl(this._self, this._then);

  final _SpecialOutrightModel _self;
  final $Res Function(_SpecialOutrightModel) _then;

/// Create a copy of SpecialOutrightModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selections = null,Object? outrightId = null,Object? outrightName = null,Object? endDate = null,Object? startTime = null,Object? leagueId = null,Object? leagueLogo = null,Object? leagueName = null,}) {
  return _then(_SpecialOutrightModel(
selections: null == selections ? _self._selections : selections // ignore: cast_nullable_to_non_nullable
as List<SpecialOutrightSelection>,outrightId: null == outrightId ? _self.outrightId : outrightId // ignore: cast_nullable_to_non_nullable
as int,outrightName: null == outrightName ? _self.outrightName : outrightName // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as int,leagueId: null == leagueId ? _self.leagueId : leagueId // ignore: cast_nullable_to_non_nullable
as int,leagueLogo: null == leagueLogo ? _self.leagueLogo : leagueLogo // ignore: cast_nullable_to_non_nullable
as String,leagueName: null == leagueName ? _self.leagueName : leagueName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SpecialOutrightSelection {

/// Selection ID (API: "0")
/// Example: "38912720350000155h"
@JsonKey(name: '0') String get selectionId;/// Selection Name (API: "1")
/// Example: "Arsenal"
@JsonKey(name: '1') String get selectionName;/// Logo URL (API: "2")
@JsonKey(name: '2') String get logoUrl;/// Base ID (API: "3") - ID without suffix, used for offer/bet placement
/// Example: "38912720350000155"
@JsonKey(name: '3') String get offerId;/// Odds value (API: "4") - use safe parse in case API returns string
@JsonKey(name: '4', fromJson: _safeParseDouble) double get odds;/// Selection Code (API: "5")
/// Example: "155"
@JsonKey(name: '5') String get selectionCode;
/// Create a copy of SpecialOutrightSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialOutrightSelectionCopyWith<SpecialOutrightSelection> get copyWith => _$SpecialOutrightSelectionCopyWithImpl<SpecialOutrightSelection>(this as SpecialOutrightSelection, _$identity);

  /// Serializes this SpecialOutrightSelection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpecialOutrightSelection&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.selectionCode, selectionCode) || other.selectionCode == selectionCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectionName,logoUrl,offerId,odds,selectionCode);

@override
String toString() {
  return 'SpecialOutrightSelection(selectionId: $selectionId, selectionName: $selectionName, logoUrl: $logoUrl, offerId: $offerId, odds: $odds, selectionCode: $selectionCode)';
}


}

/// @nodoc
abstract mixin class $SpecialOutrightSelectionCopyWith<$Res>  {
  factory $SpecialOutrightSelectionCopyWith(SpecialOutrightSelection value, $Res Function(SpecialOutrightSelection) _then) = _$SpecialOutrightSelectionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '0') String selectionId,@JsonKey(name: '1') String selectionName,@JsonKey(name: '2') String logoUrl,@JsonKey(name: '3') String offerId,@JsonKey(name: '4', fromJson: _safeParseDouble) double odds,@JsonKey(name: '5') String selectionCode
});




}
/// @nodoc
class _$SpecialOutrightSelectionCopyWithImpl<$Res>
    implements $SpecialOutrightSelectionCopyWith<$Res> {
  _$SpecialOutrightSelectionCopyWithImpl(this._self, this._then);

  final SpecialOutrightSelection _self;
  final $Res Function(SpecialOutrightSelection) _then;

/// Create a copy of SpecialOutrightSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectionId = null,Object? selectionName = null,Object? logoUrl = null,Object? offerId = null,Object? odds = null,Object? selectionCode = null,}) {
  return _then(_self.copyWith(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,selectionCode: null == selectionCode ? _self.selectionCode : selectionCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpecialOutrightSelection].
extension SpecialOutrightSelectionPatterns on SpecialOutrightSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpecialOutrightSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpecialOutrightSelection value)  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpecialOutrightSelection value)?  $default,){
final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String selectionId, @JsonKey(name: '1')  String selectionName, @JsonKey(name: '2')  String logoUrl, @JsonKey(name: '3')  String offerId, @JsonKey(name: '4', fromJson: _safeParseDouble)  double odds, @JsonKey(name: '5')  String selectionCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
return $default(_that.selectionId,_that.selectionName,_that.logoUrl,_that.offerId,_that.odds,_that.selectionCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '0')  String selectionId, @JsonKey(name: '1')  String selectionName, @JsonKey(name: '2')  String logoUrl, @JsonKey(name: '3')  String offerId, @JsonKey(name: '4', fromJson: _safeParseDouble)  double odds, @JsonKey(name: '5')  String selectionCode)  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightSelection():
return $default(_that.selectionId,_that.selectionName,_that.logoUrl,_that.offerId,_that.odds,_that.selectionCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '0')  String selectionId, @JsonKey(name: '1')  String selectionName, @JsonKey(name: '2')  String logoUrl, @JsonKey(name: '3')  String offerId, @JsonKey(name: '4', fromJson: _safeParseDouble)  double odds, @JsonKey(name: '5')  String selectionCode)?  $default,) {final _that = this;
switch (_that) {
case _SpecialOutrightSelection() when $default != null:
return $default(_that.selectionId,_that.selectionName,_that.logoUrl,_that.offerId,_that.odds,_that.selectionCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpecialOutrightSelection implements SpecialOutrightSelection {
  const _SpecialOutrightSelection({@JsonKey(name: '0') this.selectionId = '', @JsonKey(name: '1') this.selectionName = '', @JsonKey(name: '2') this.logoUrl = '', @JsonKey(name: '3') this.offerId = '', @JsonKey(name: '4', fromJson: _safeParseDouble) this.odds = 0.0, @JsonKey(name: '5') this.selectionCode = ''});
  factory _SpecialOutrightSelection.fromJson(Map<String, dynamic> json) => _$SpecialOutrightSelectionFromJson(json);

/// Selection ID (API: "0")
/// Example: "38912720350000155h"
@override@JsonKey(name: '0') final  String selectionId;
/// Selection Name (API: "1")
/// Example: "Arsenal"
@override@JsonKey(name: '1') final  String selectionName;
/// Logo URL (API: "2")
@override@JsonKey(name: '2') final  String logoUrl;
/// Base ID (API: "3") - ID without suffix, used for offer/bet placement
/// Example: "38912720350000155"
@override@JsonKey(name: '3') final  String offerId;
/// Odds value (API: "4") - use safe parse in case API returns string
@override@JsonKey(name: '4', fromJson: _safeParseDouble) final  double odds;
/// Selection Code (API: "5")
/// Example: "155"
@override@JsonKey(name: '5') final  String selectionCode;

/// Create a copy of SpecialOutrightSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialOutrightSelectionCopyWith<_SpecialOutrightSelection> get copyWith => __$SpecialOutrightSelectionCopyWithImpl<_SpecialOutrightSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpecialOutrightSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpecialOutrightSelection&&(identical(other.selectionId, selectionId) || other.selectionId == selectionId)&&(identical(other.selectionName, selectionName) || other.selectionName == selectionName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.odds, odds) || other.odds == odds)&&(identical(other.selectionCode, selectionCode) || other.selectionCode == selectionCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectionId,selectionName,logoUrl,offerId,odds,selectionCode);

@override
String toString() {
  return 'SpecialOutrightSelection(selectionId: $selectionId, selectionName: $selectionName, logoUrl: $logoUrl, offerId: $offerId, odds: $odds, selectionCode: $selectionCode)';
}


}

/// @nodoc
abstract mixin class _$SpecialOutrightSelectionCopyWith<$Res> implements $SpecialOutrightSelectionCopyWith<$Res> {
  factory _$SpecialOutrightSelectionCopyWith(_SpecialOutrightSelection value, $Res Function(_SpecialOutrightSelection) _then) = __$SpecialOutrightSelectionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '0') String selectionId,@JsonKey(name: '1') String selectionName,@JsonKey(name: '2') String logoUrl,@JsonKey(name: '3') String offerId,@JsonKey(name: '4', fromJson: _safeParseDouble) double odds,@JsonKey(name: '5') String selectionCode
});




}
/// @nodoc
class __$SpecialOutrightSelectionCopyWithImpl<$Res>
    implements _$SpecialOutrightSelectionCopyWith<$Res> {
  __$SpecialOutrightSelectionCopyWithImpl(this._self, this._then);

  final _SpecialOutrightSelection _self;
  final $Res Function(_SpecialOutrightSelection) _then;

/// Create a copy of SpecialOutrightSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectionId = null,Object? selectionName = null,Object? logoUrl = null,Object? offerId = null,Object? odds = null,Object? selectionCode = null,}) {
  return _then(_SpecialOutrightSelection(
selectionId: null == selectionId ? _self.selectionId : selectionId // ignore: cast_nullable_to_non_nullable
as String,selectionName: null == selectionName ? _self.selectionName : selectionName // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,odds: null == odds ? _self.odds : odds // ignore: cast_nullable_to_non_nullable
as double,selectionCode: null == selectionCode ? _self.selectionCode : selectionCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
