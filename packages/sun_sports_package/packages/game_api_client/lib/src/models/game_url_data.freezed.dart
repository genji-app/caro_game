// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_url_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameUrlData {
  String get url;

  /// Create a copy of GameUrlData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameUrlDataCopyWith<GameUrlData> get copyWith =>
      _$GameUrlDataCopyWithImpl<GameUrlData>(this as GameUrlData, _$identity);

  /// Serializes this GameUrlData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameUrlData &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url);

  @override
  String toString() {
    return 'GameUrlData(url: $url)';
  }
}

/// @nodoc
abstract mixin class $GameUrlDataCopyWith<$Res> {
  factory $GameUrlDataCopyWith(
          GameUrlData value, $Res Function(GameUrlData) _then) =
      _$GameUrlDataCopyWithImpl;
  @useResult
  $Res call({String url});
}

/// @nodoc
class _$GameUrlDataCopyWithImpl<$Res> implements $GameUrlDataCopyWith<$Res> {
  _$GameUrlDataCopyWithImpl(this._self, this._then);

  final GameUrlData _self;
  final $Res Function(GameUrlData) _then;

  /// Create a copy of GameUrlData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_self.copyWith(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [GameUrlData].
extension GameUrlDataPatterns on GameUrlData {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GameUrlData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameUrlData() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GameUrlData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameUrlData():
        return $default(_that);
    }
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GameUrlData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameUrlData() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String url)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameUrlData() when $default != null:
        return $default(_that.url);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String url) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameUrlData():
        return $default(_that.url);
    }
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String url)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameUrlData() when $default != null:
        return $default(_that.url);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GameUrlData implements GameUrlData {
  const _GameUrlData({required this.url});
  factory _GameUrlData.fromJson(Map<String, dynamic> json) =>
      _$GameUrlDataFromJson(json);

  @override
  final String url;

  /// Create a copy of GameUrlData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameUrlDataCopyWith<_GameUrlData> get copyWith =>
      __$GameUrlDataCopyWithImpl<_GameUrlData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GameUrlDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameUrlData &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url);

  @override
  String toString() {
    return 'GameUrlData(url: $url)';
  }
}

/// @nodoc
abstract mixin class _$GameUrlDataCopyWith<$Res>
    implements $GameUrlDataCopyWith<$Res> {
  factory _$GameUrlDataCopyWith(
          _GameUrlData value, $Res Function(_GameUrlData) _then) =
      __$GameUrlDataCopyWithImpl;
  @override
  @useResult
  $Res call({String url});
}

/// @nodoc
class __$GameUrlDataCopyWithImpl<$Res> implements _$GameUrlDataCopyWith<$Res> {
  __$GameUrlDataCopyWithImpl(this._self, this._then);

  final _GameUrlData _self;
  final $Res Function(_GameUrlData) _then;

  /// Create a copy of GameUrlData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
  }) {
    return _then(_GameUrlData(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
