// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caxilo_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CaxiloFilter implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter()';
}


}

/// @nodoc
class $CaxiloFilterCopyWith<$Res>  {
$CaxiloFilterCopyWith(CaxiloFilter _, $Res Function(CaxiloFilter) __);
}


/// Adds pattern-matching-related methods to [CaxiloFilter].
extension CaxiloFilterPatterns on CaxiloFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CollectionFilter value)?  byCollection,TResult Function( GameCodesFilter value)?  byGameCodes,TResult Function( ProvidersFilter value)?  byProviders,TResult Function( CaxiloTypesFilter value)?  byGameTypes,TResult Function( InHouseFilter value)?  isInHouse,TResult Function( AllFilter value)?  all,TResult Function( AnyFilter value)?  any,TResult Function( NoneFilter value)?  none,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CollectionFilter() when byCollection != null:
return byCollection(_that);case GameCodesFilter() when byGameCodes != null:
return byGameCodes(_that);case ProvidersFilter() when byProviders != null:
return byProviders(_that);case CaxiloTypesFilter() when byGameTypes != null:
return byGameTypes(_that);case InHouseFilter() when isInHouse != null:
return isInHouse(_that);case AllFilter() when all != null:
return all(_that);case AnyFilter() when any != null:
return any(_that);case NoneFilter() when none != null:
return none(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CollectionFilter value)  byCollection,required TResult Function( GameCodesFilter value)  byGameCodes,required TResult Function( ProvidersFilter value)  byProviders,required TResult Function( CaxiloTypesFilter value)  byGameTypes,required TResult Function( InHouseFilter value)  isInHouse,required TResult Function( AllFilter value)  all,required TResult Function( AnyFilter value)  any,required TResult Function( NoneFilter value)  none,}){
final _that = this;
switch (_that) {
case CollectionFilter():
return byCollection(_that);case GameCodesFilter():
return byGameCodes(_that);case ProvidersFilter():
return byProviders(_that);case CaxiloTypesFilter():
return byGameTypes(_that);case InHouseFilter():
return isInHouse(_that);case AllFilter():
return all(_that);case AnyFilter():
return any(_that);case NoneFilter():
return none(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CollectionFilter value)?  byCollection,TResult? Function( GameCodesFilter value)?  byGameCodes,TResult? Function( ProvidersFilter value)?  byProviders,TResult? Function( CaxiloTypesFilter value)?  byGameTypes,TResult? Function( InHouseFilter value)?  isInHouse,TResult? Function( AllFilter value)?  all,TResult? Function( AnyFilter value)?  any,TResult? Function( NoneFilter value)?  none,}){
final _that = this;
switch (_that) {
case CollectionFilter() when byCollection != null:
return byCollection(_that);case GameCodesFilter() when byGameCodes != null:
return byGameCodes(_that);case ProvidersFilter() when byProviders != null:
return byProviders(_that);case CaxiloTypesFilter() when byGameTypes != null:
return byGameTypes(_that);case InHouseFilter() when isInHouse != null:
return isInHouse(_that);case AllFilter() when all != null:
return all(_that);case AnyFilter() when any != null:
return any(_that);case NoneFilter() when none != null:
return none(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String collectionId)?  byCollection,TResult Function( List<String> gameCodes)?  byGameCodes,TResult Function( List<String> providerIds)?  byProviders,TResult Function( List<caxiloconfig.GameType> gameTypes)?  byGameTypes,TResult Function()?  isInHouse,TResult Function( List<CaxiloFilter> filters)?  all,TResult Function( List<CaxiloFilter> filters)?  any,TResult Function()?  none,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CollectionFilter() when byCollection != null:
return byCollection(_that.collectionId);case GameCodesFilter() when byGameCodes != null:
return byGameCodes(_that.gameCodes);case ProvidersFilter() when byProviders != null:
return byProviders(_that.providerIds);case CaxiloTypesFilter() when byGameTypes != null:
return byGameTypes(_that.gameTypes);case InHouseFilter() when isInHouse != null:
return isInHouse();case AllFilter() when all != null:
return all(_that.filters);case AnyFilter() when any != null:
return any(_that.filters);case NoneFilter() when none != null:
return none();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String collectionId)  byCollection,required TResult Function( List<String> gameCodes)  byGameCodes,required TResult Function( List<String> providerIds)  byProviders,required TResult Function( List<caxiloconfig.GameType> gameTypes)  byGameTypes,required TResult Function()  isInHouse,required TResult Function( List<CaxiloFilter> filters)  all,required TResult Function( List<CaxiloFilter> filters)  any,required TResult Function()  none,}) {final _that = this;
switch (_that) {
case CollectionFilter():
return byCollection(_that.collectionId);case GameCodesFilter():
return byGameCodes(_that.gameCodes);case ProvidersFilter():
return byProviders(_that.providerIds);case CaxiloTypesFilter():
return byGameTypes(_that.gameTypes);case InHouseFilter():
return isInHouse();case AllFilter():
return all(_that.filters);case AnyFilter():
return any(_that.filters);case NoneFilter():
return none();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String collectionId)?  byCollection,TResult? Function( List<String> gameCodes)?  byGameCodes,TResult? Function( List<String> providerIds)?  byProviders,TResult? Function( List<caxiloconfig.GameType> gameTypes)?  byGameTypes,TResult? Function()?  isInHouse,TResult? Function( List<CaxiloFilter> filters)?  all,TResult? Function( List<CaxiloFilter> filters)?  any,TResult? Function()?  none,}) {final _that = this;
switch (_that) {
case CollectionFilter() when byCollection != null:
return byCollection(_that.collectionId);case GameCodesFilter() when byGameCodes != null:
return byGameCodes(_that.gameCodes);case ProvidersFilter() when byProviders != null:
return byProviders(_that.providerIds);case CaxiloTypesFilter() when byGameTypes != null:
return byGameTypes(_that.gameTypes);case InHouseFilter() when isInHouse != null:
return isInHouse();case AllFilter() when all != null:
return all(_that.filters);case AnyFilter() when any != null:
return any(_that.filters);case NoneFilter() when none != null:
return none();case _:
  return null;

}
}

}

/// @nodoc


class CollectionFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const CollectionFilter({required this.collectionId});
  

 final  String collectionId;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionFilterCopyWith<CollectionFilter> get copyWith => _$CollectionFilterCopyWithImpl<CollectionFilter>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.byCollection'))
    ..add(DiagnosticsProperty('collectionId', collectionId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionFilter&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId));
}


@override
int get hashCode => Object.hash(runtimeType,collectionId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.byCollection(collectionId: $collectionId)';
}


}

/// @nodoc
abstract mixin class $CollectionFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory $CollectionFilterCopyWith(CollectionFilter value, $Res Function(CollectionFilter) _then) = _$CollectionFilterCopyWithImpl;
@useResult
$Res call({
 String collectionId
});




}
/// @nodoc
class _$CollectionFilterCopyWithImpl<$Res>
    implements $CollectionFilterCopyWith<$Res> {
  _$CollectionFilterCopyWithImpl(this._self, this._then);

  final CollectionFilter _self;
  final $Res Function(CollectionFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? collectionId = null,}) {
  return _then(CollectionFilter(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GameCodesFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const GameCodesFilter({required final  List<String> gameCodes}): _gameCodes = gameCodes;
  

 final  List<String> _gameCodes;
 List<String> get gameCodes {
  if (_gameCodes is EqualUnmodifiableListView) return _gameCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameCodes);
}


/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCodesFilterCopyWith<GameCodesFilter> get copyWith => _$GameCodesFilterCopyWithImpl<GameCodesFilter>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.byGameCodes'))
    ..add(DiagnosticsProperty('gameCodes', gameCodes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameCodesFilter&&const DeepCollectionEquality().equals(other._gameCodes, _gameCodes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_gameCodes));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.byGameCodes(gameCodes: $gameCodes)';
}


}

/// @nodoc
abstract mixin class $GameCodesFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory $GameCodesFilterCopyWith(GameCodesFilter value, $Res Function(GameCodesFilter) _then) = _$GameCodesFilterCopyWithImpl;
@useResult
$Res call({
 List<String> gameCodes
});




}
/// @nodoc
class _$GameCodesFilterCopyWithImpl<$Res>
    implements $GameCodesFilterCopyWith<$Res> {
  _$GameCodesFilterCopyWithImpl(this._self, this._then);

  final GameCodesFilter _self;
  final $Res Function(GameCodesFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? gameCodes = null,}) {
  return _then(GameCodesFilter(
gameCodes: null == gameCodes ? _self._gameCodes : gameCodes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ProvidersFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const ProvidersFilter({required final  List<String> providerIds}): _providerIds = providerIds;
  

 final  List<String> _providerIds;
 List<String> get providerIds {
  if (_providerIds is EqualUnmodifiableListView) return _providerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerIds);
}


/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProvidersFilterCopyWith<ProvidersFilter> get copyWith => _$ProvidersFilterCopyWithImpl<ProvidersFilter>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.byProviders'))
    ..add(DiagnosticsProperty('providerIds', providerIds));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProvidersFilter&&const DeepCollectionEquality().equals(other._providerIds, _providerIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_providerIds));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.byProviders(providerIds: $providerIds)';
}


}

/// @nodoc
abstract mixin class $ProvidersFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory $ProvidersFilterCopyWith(ProvidersFilter value, $Res Function(ProvidersFilter) _then) = _$ProvidersFilterCopyWithImpl;
@useResult
$Res call({
 List<String> providerIds
});




}
/// @nodoc
class _$ProvidersFilterCopyWithImpl<$Res>
    implements $ProvidersFilterCopyWith<$Res> {
  _$ProvidersFilterCopyWithImpl(this._self, this._then);

  final ProvidersFilter _self;
  final $Res Function(ProvidersFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? providerIds = null,}) {
  return _then(ProvidersFilter(
providerIds: null == providerIds ? _self._providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class CaxiloTypesFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const CaxiloTypesFilter({required final  List<caxiloconfig.GameType> gameTypes}): _gameTypes = gameTypes;
  

 final  List<caxiloconfig.GameType> _gameTypes;
 List<caxiloconfig.GameType> get gameTypes {
  if (_gameTypes is EqualUnmodifiableListView) return _gameTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameTypes);
}


/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaxiloTypesFilterCopyWith<CaxiloTypesFilter> get copyWith => _$CaxiloTypesFilterCopyWithImpl<CaxiloTypesFilter>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.byGameTypes'))
    ..add(DiagnosticsProperty('gameTypes', gameTypes));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaxiloTypesFilter&&const DeepCollectionEquality().equals(other._gameTypes, _gameTypes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_gameTypes));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.byGameTypes(gameTypes: $gameTypes)';
}


}

/// @nodoc
abstract mixin class $CaxiloTypesFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory $CaxiloTypesFilterCopyWith(CaxiloTypesFilter value, $Res Function(CaxiloTypesFilter) _then) = _$CaxiloTypesFilterCopyWithImpl;
@useResult
$Res call({
 List<caxiloconfig.GameType> gameTypes
});




}
/// @nodoc
class _$CaxiloTypesFilterCopyWithImpl<$Res>
    implements $CaxiloTypesFilterCopyWith<$Res> {
  _$CaxiloTypesFilterCopyWithImpl(this._self, this._then);

  final CaxiloTypesFilter _self;
  final $Res Function(CaxiloTypesFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? gameTypes = null,}) {
  return _then(CaxiloTypesFilter(
gameTypes: null == gameTypes ? _self._gameTypes : gameTypes // ignore: cast_nullable_to_non_nullable
as List<caxiloconfig.GameType>,
  ));
}


}

/// @nodoc


class InHouseFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const InHouseFilter();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.isInHouse'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InHouseFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.isInHouse()';
}


}




/// @nodoc


class AllFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const AllFilter({required final  List<CaxiloFilter> filters}): _filters = filters;
  

 final  List<CaxiloFilter> _filters;
 List<CaxiloFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllFilterCopyWith<AllFilter> get copyWith => _$AllFilterCopyWithImpl<AllFilter>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.all'))
    ..add(DiagnosticsProperty('filters', filters));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllFilter&&const DeepCollectionEquality().equals(other._filters, _filters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.all(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $AllFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory $AllFilterCopyWith(AllFilter value, $Res Function(AllFilter) _then) = _$AllFilterCopyWithImpl;
@useResult
$Res call({
 List<CaxiloFilter> filters
});




}
/// @nodoc
class _$AllFilterCopyWithImpl<$Res>
    implements $AllFilterCopyWith<$Res> {
  _$AllFilterCopyWithImpl(this._self, this._then);

  final AllFilter _self;
  final $Res Function(AllFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(AllFilter(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<CaxiloFilter>,
  ));
}


}

/// @nodoc


class AnyFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const AnyFilter({required final  List<CaxiloFilter> filters}): _filters = filters;
  

 final  List<CaxiloFilter> _filters;
 List<CaxiloFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}


/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnyFilterCopyWith<AnyFilter> get copyWith => _$AnyFilterCopyWithImpl<AnyFilter>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.any'))
    ..add(DiagnosticsProperty('filters', filters));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnyFilter&&const DeepCollectionEquality().equals(other._filters, _filters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_filters));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.any(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $AnyFilterCopyWith<$Res> implements $CaxiloFilterCopyWith<$Res> {
  factory $AnyFilterCopyWith(AnyFilter value, $Res Function(AnyFilter) _then) = _$AnyFilterCopyWithImpl;
@useResult
$Res call({
 List<CaxiloFilter> filters
});




}
/// @nodoc
class _$AnyFilterCopyWithImpl<$Res>
    implements $AnyFilterCopyWith<$Res> {
  _$AnyFilterCopyWithImpl(this._self, this._then);

  final AnyFilter _self;
  final $Res Function(AnyFilter) _then;

/// Create a copy of CaxiloFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(AnyFilter(
filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<CaxiloFilter>,
  ));
}


}

/// @nodoc


class NoneFilter with DiagnosticableTreeMixin implements CaxiloFilter {
  const NoneFilter();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CaxiloFilter.none'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoneFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CaxiloFilter.none()';
}


}




// dart format on
