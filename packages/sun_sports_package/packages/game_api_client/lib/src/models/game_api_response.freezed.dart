// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameApiResponse<T> {
  String get message;
  int get code;
  int get status;
  Object? get data;

  /// Create a copy of GameApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameApiResponseCopyWith<T, GameApiResponse<T>> get copyWith =>
      _$GameApiResponseCopyWithImpl<T, GameApiResponse<T>>(
          this as GameApiResponse<T>, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameApiResponse<T> &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, status,
      const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'GameApiResponse<$T>(message: $message, code: $code, status: $status, data: $data)';
  }
}

/// @nodoc
abstract mixin class $GameApiResponseCopyWith<T, $Res> {
  factory $GameApiResponseCopyWith(
          GameApiResponse<T> value, $Res Function(GameApiResponse<T>) _then) =
      _$GameApiResponseCopyWithImpl;
  @useResult
  $Res call({String message, int code, int status});
}

/// @nodoc
class _$GameApiResponseCopyWithImpl<T, $Res>
    implements $GameApiResponseCopyWith<T, $Res> {
  _$GameApiResponseCopyWithImpl(this._self, this._then);

  final GameApiResponse<T> _self;
  final $Res Function(GameApiResponse<T>) _then;

  /// Create a copy of GameApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [GameApiResponse].
extension GameApiResponsePatterns<T> on GameApiResponse<T> {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameApiSuccessResponse<T> value)? success,
    TResult Function(GameApiFailureResponse<T> value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case GameApiSuccessResponse() when success != null:
        return success(_that);
      case GameApiFailureResponse() when failure != null:
        return failure(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(GameApiSuccessResponse<T> value) success,
    required TResult Function(GameApiFailureResponse<T> value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case GameApiSuccessResponse():
        return success(_that);
      case GameApiFailureResponse():
        return failure(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameApiSuccessResponse<T> value)? success,
    TResult? Function(GameApiFailureResponse<T> value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case GameApiSuccessResponse() when success != null:
        return success(_that);
      case GameApiFailureResponse() when failure != null:
        return failure(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int code, int status, T data)? success,
    TResult Function(String message, int code, int status, Object? data)?
        failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case GameApiSuccessResponse() when success != null:
        return success(_that.message, _that.code, _that.status, _that.data);
      case GameApiFailureResponse() when failure != null:
        return failure(_that.message, _that.code, _that.status, _that.data);
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
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int code, int status, T data)
        success,
    required TResult Function(
            String message, int code, int status, Object? data)
        failure,
  }) {
    final _that = this;
    switch (_that) {
      case GameApiSuccessResponse():
        return success(_that.message, _that.code, _that.status, _that.data);
      case GameApiFailureResponse():
        return failure(_that.message, _that.code, _that.status, _that.data);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int code, int status, T data)? success,
    TResult? Function(String message, int code, int status, Object? data)?
        failure,
  }) {
    final _that = this;
    switch (_that) {
      case GameApiSuccessResponse() when success != null:
        return success(_that.message, _that.code, _that.status, _that.data);
      case GameApiFailureResponse() when failure != null:
        return failure(_that.message, _that.code, _that.status, _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc

class GameApiSuccessResponse<T> implements GameApiResponse<T> {
  const GameApiSuccessResponse(
      {required this.message,
      required this.code,
      required this.status,
      required this.data});

  @override
  final String message;
  @override
  final int code;
  @override
  final int status;
  @override
  final T data;

  /// Create a copy of GameApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameApiSuccessResponseCopyWith<T, GameApiSuccessResponse<T>> get copyWith =>
      _$GameApiSuccessResponseCopyWithImpl<T, GameApiSuccessResponse<T>>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameApiSuccessResponse<T> &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, status,
      const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'GameApiResponse<$T>.success(message: $message, code: $code, status: $status, data: $data)';
  }
}

/// @nodoc
abstract mixin class $GameApiSuccessResponseCopyWith<T, $Res>
    implements $GameApiResponseCopyWith<T, $Res> {
  factory $GameApiSuccessResponseCopyWith(GameApiSuccessResponse<T> value,
          $Res Function(GameApiSuccessResponse<T>) _then) =
      _$GameApiSuccessResponseCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int code, int status, T data});
}

/// @nodoc
class _$GameApiSuccessResponseCopyWithImpl<T, $Res>
    implements $GameApiSuccessResponseCopyWith<T, $Res> {
  _$GameApiSuccessResponseCopyWithImpl(this._self, this._then);

  final GameApiSuccessResponse<T> _self;
  final $Res Function(GameApiSuccessResponse<T>) _then;

  /// Create a copy of GameApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = null,
    Object? status = null,
    Object? data = freezed,
  }) {
    return _then(GameApiSuccessResponse<T>(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class GameApiFailureResponse<T> implements GameApiResponse<T> {
  const GameApiFailureResponse(
      {required this.message,
      required this.code,
      required this.status,
      this.data});

  @override
  final String message;
  @override
  final int code;
  @override
  final int status;
  @override
  final Object? data;

  /// Create a copy of GameApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameApiFailureResponseCopyWith<T, GameApiFailureResponse<T>> get copyWith =>
      _$GameApiFailureResponseCopyWithImpl<T, GameApiFailureResponse<T>>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameApiFailureResponse<T> &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, status,
      const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'GameApiResponse<$T>.failure(message: $message, code: $code, status: $status, data: $data)';
  }
}

/// @nodoc
abstract mixin class $GameApiFailureResponseCopyWith<T, $Res>
    implements $GameApiResponseCopyWith<T, $Res> {
  factory $GameApiFailureResponseCopyWith(GameApiFailureResponse<T> value,
          $Res Function(GameApiFailureResponse<T>) _then) =
      _$GameApiFailureResponseCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int code, int status, Object? data});
}

/// @nodoc
class _$GameApiFailureResponseCopyWithImpl<T, $Res>
    implements $GameApiFailureResponseCopyWith<T, $Res> {
  _$GameApiFailureResponseCopyWithImpl(this._self, this._then);

  final GameApiFailureResponse<T> _self;
  final $Res Function(GameApiFailureResponse<T>) _then;

  /// Create a copy of GameApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = null,
    Object? status = null,
    Object? data = freezed,
  }) {
    return _then(GameApiFailureResponse<T>(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      data: freezed == data ? _self.data : data,
    ));
  }
}

// dart format on
