// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayHistoryResponse {

 int get count; List<PlayHistoryItem> get items;
/// Create a copy of PlayHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayHistoryResponseCopyWith<PlayHistoryResponse> get copyWith => _$PlayHistoryResponseCopyWithImpl<PlayHistoryResponse>(this as PlayHistoryResponse, _$identity);

  /// Serializes this PlayHistoryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayHistoryResponse&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PlayHistoryResponse(count: $count, items: $items)';
}


}

/// @nodoc
abstract mixin class $PlayHistoryResponseCopyWith<$Res>  {
  factory $PlayHistoryResponseCopyWith(PlayHistoryResponse value, $Res Function(PlayHistoryResponse) _then) = _$PlayHistoryResponseCopyWithImpl;
@useResult
$Res call({
 int count, List<PlayHistoryItem> items
});




}
/// @nodoc
class _$PlayHistoryResponseCopyWithImpl<$Res>
    implements $PlayHistoryResponseCopyWith<$Res> {
  _$PlayHistoryResponseCopyWithImpl(this._self, this._then);

  final PlayHistoryResponse _self;
  final $Res Function(PlayHistoryResponse) _then;

/// Create a copy of PlayHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? items = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PlayHistoryItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayHistoryResponse].
extension PlayHistoryResponsePatterns on PlayHistoryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayHistoryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayHistoryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayHistoryResponse value)  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayHistoryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  List<PlayHistoryItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayHistoryResponse() when $default != null:
return $default(_that.count,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  List<PlayHistoryItem> items)  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryResponse():
return $default(_that.count,_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  List<PlayHistoryItem> items)?  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryResponse() when $default != null:
return $default(_that.count,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayHistoryResponse implements PlayHistoryResponse {
  const _PlayHistoryResponse({this.count = 0, final  List<PlayHistoryItem> items = const []}): _items = items;
  factory _PlayHistoryResponse.fromJson(Map<String, dynamic> json) => _$PlayHistoryResponseFromJson(json);

@override@JsonKey() final  int count;
 final  List<PlayHistoryItem> _items;
@override@JsonKey() List<PlayHistoryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of PlayHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayHistoryResponseCopyWith<_PlayHistoryResponse> get copyWith => __$PlayHistoryResponseCopyWithImpl<_PlayHistoryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayHistoryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayHistoryResponse&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PlayHistoryResponse(count: $count, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PlayHistoryResponseCopyWith<$Res> implements $PlayHistoryResponseCopyWith<$Res> {
  factory _$PlayHistoryResponseCopyWith(_PlayHistoryResponse value, $Res Function(_PlayHistoryResponse) _then) = __$PlayHistoryResponseCopyWithImpl;
@override @useResult
$Res call({
 int count, List<PlayHistoryItem> items
});




}
/// @nodoc
class __$PlayHistoryResponseCopyWithImpl<$Res>
    implements _$PlayHistoryResponseCopyWith<$Res> {
  __$PlayHistoryResponseCopyWithImpl(this._self, this._then);

  final _PlayHistoryResponse _self;
  final $Res Function(_PlayHistoryResponse) _then;

/// Create a copy of PlayHistoryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? items = null,}) {
  return _then(_PlayHistoryResponse(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PlayHistoryItem>,
  ));
}


}


/// @nodoc
mixin _$PlayHistoryItem {

 int get activityType; int get createdTime; String get serviceName; String get description; num get closingValue; num get exchangeValue;
/// Create a copy of PlayHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayHistoryItemCopyWith<PlayHistoryItem> get copyWith => _$PlayHistoryItemCopyWithImpl<PlayHistoryItem>(this as PlayHistoryItem, _$identity);

  /// Serializes this PlayHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayHistoryItem&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.description, description) || other.description == description)&&(identical(other.closingValue, closingValue) || other.closingValue == closingValue)&&(identical(other.exchangeValue, exchangeValue) || other.exchangeValue == exchangeValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activityType,createdTime,serviceName,description,closingValue,exchangeValue);

@override
String toString() {
  return 'PlayHistoryItem(activityType: $activityType, createdTime: $createdTime, serviceName: $serviceName, description: $description, closingValue: $closingValue, exchangeValue: $exchangeValue)';
}


}

/// @nodoc
abstract mixin class $PlayHistoryItemCopyWith<$Res>  {
  factory $PlayHistoryItemCopyWith(PlayHistoryItem value, $Res Function(PlayHistoryItem) _then) = _$PlayHistoryItemCopyWithImpl;
@useResult
$Res call({
 int activityType, int createdTime, String serviceName, String description, num closingValue, num exchangeValue
});




}
/// @nodoc
class _$PlayHistoryItemCopyWithImpl<$Res>
    implements $PlayHistoryItemCopyWith<$Res> {
  _$PlayHistoryItemCopyWithImpl(this._self, this._then);

  final PlayHistoryItem _self;
  final $Res Function(PlayHistoryItem) _then;

/// Create a copy of PlayHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activityType = null,Object? createdTime = null,Object? serviceName = null,Object? description = null,Object? closingValue = null,Object? exchangeValue = null,}) {
  return _then(_self.copyWith(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as int,createdTime: null == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,closingValue: null == closingValue ? _self.closingValue : closingValue // ignore: cast_nullable_to_non_nullable
as num,exchangeValue: null == exchangeValue ? _self.exchangeValue : exchangeValue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayHistoryItem].
extension PlayHistoryItemPatterns on PlayHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _PlayHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activityType,  int createdTime,  String serviceName,  String description,  num closingValue,  num exchangeValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayHistoryItem() when $default != null:
return $default(_that.activityType,_that.createdTime,_that.serviceName,_that.description,_that.closingValue,_that.exchangeValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activityType,  int createdTime,  String serviceName,  String description,  num closingValue,  num exchangeValue)  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryItem():
return $default(_that.activityType,_that.createdTime,_that.serviceName,_that.description,_that.closingValue,_that.exchangeValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activityType,  int createdTime,  String serviceName,  String description,  num closingValue,  num exchangeValue)?  $default,) {final _that = this;
switch (_that) {
case _PlayHistoryItem() when $default != null:
return $default(_that.activityType,_that.createdTime,_that.serviceName,_that.description,_that.closingValue,_that.exchangeValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayHistoryItem implements PlayHistoryItem {
  const _PlayHistoryItem({this.activityType = 0, this.createdTime = 0, this.serviceName = '', this.description = '', this.closingValue = 0.0, this.exchangeValue = 0.0});
  factory _PlayHistoryItem.fromJson(Map<String, dynamic> json) => _$PlayHistoryItemFromJson(json);

@override@JsonKey() final  int activityType;
@override@JsonKey() final  int createdTime;
@override@JsonKey() final  String serviceName;
@override@JsonKey() final  String description;
@override@JsonKey() final  num closingValue;
@override@JsonKey() final  num exchangeValue;

/// Create a copy of PlayHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayHistoryItemCopyWith<_PlayHistoryItem> get copyWith => __$PlayHistoryItemCopyWithImpl<_PlayHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayHistoryItem&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.description, description) || other.description == description)&&(identical(other.closingValue, closingValue) || other.closingValue == closingValue)&&(identical(other.exchangeValue, exchangeValue) || other.exchangeValue == exchangeValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activityType,createdTime,serviceName,description,closingValue,exchangeValue);

@override
String toString() {
  return 'PlayHistoryItem(activityType: $activityType, createdTime: $createdTime, serviceName: $serviceName, description: $description, closingValue: $closingValue, exchangeValue: $exchangeValue)';
}


}

/// @nodoc
abstract mixin class _$PlayHistoryItemCopyWith<$Res> implements $PlayHistoryItemCopyWith<$Res> {
  factory _$PlayHistoryItemCopyWith(_PlayHistoryItem value, $Res Function(_PlayHistoryItem) _then) = __$PlayHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 int activityType, int createdTime, String serviceName, String description, num closingValue, num exchangeValue
});




}
/// @nodoc
class __$PlayHistoryItemCopyWithImpl<$Res>
    implements _$PlayHistoryItemCopyWith<$Res> {
  __$PlayHistoryItemCopyWithImpl(this._self, this._then);

  final _PlayHistoryItem _self;
  final $Res Function(_PlayHistoryItem) _then;

/// Create a copy of PlayHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activityType = null,Object? createdTime = null,Object? serviceName = null,Object? description = null,Object? closingValue = null,Object? exchangeValue = null,}) {
  return _then(_PlayHistoryItem(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as int,createdTime: null == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as int,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,closingValue: null == closingValue ? _self.closingValue : closingValue // ignore: cast_nullable_to_non_nullable
as num,exchangeValue: null == exchangeValue ? _self.exchangeValue : exchangeValue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
