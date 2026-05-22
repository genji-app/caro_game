// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_game_url_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GetGameUrlRequest {
  String get providerId;
  String get productId;
  String get gameCode;
  String? get lang;
  bool? get isMobileLogin;

  /// Create a copy of GetGameUrlRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GetGameUrlRequestCopyWith<GetGameUrlRequest> get copyWith =>
      _$GetGameUrlRequestCopyWithImpl<GetGameUrlRequest>(
          this as GetGameUrlRequest, _$identity);

  /// Serializes this GetGameUrlRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GetGameUrlRequest &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.gameCode, gameCode) ||
                other.gameCode == gameCode) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.isMobileLogin, isMobileLogin) ||
                other.isMobileLogin == isMobileLogin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, providerId, productId, gameCode, lang, isMobileLogin);

  @override
  String toString() {
    return 'GetGameUrlRequest(providerId: $providerId, productId: $productId, gameCode: $gameCode, lang: $lang, isMobileLogin: $isMobileLogin)';
  }
}

/// @nodoc
abstract mixin class $GetGameUrlRequestCopyWith<$Res> {
  factory $GetGameUrlRequestCopyWith(
          GetGameUrlRequest value, $Res Function(GetGameUrlRequest) _then) =
      _$GetGameUrlRequestCopyWithImpl;
  @useResult
  $Res call(
      {String providerId,
      String productId,
      String gameCode,
      String? lang,
      bool? isMobileLogin});
}

/// @nodoc
class _$GetGameUrlRequestCopyWithImpl<$Res>
    implements $GetGameUrlRequestCopyWith<$Res> {
  _$GetGameUrlRequestCopyWithImpl(this._self, this._then);

  final GetGameUrlRequest _self;
  final $Res Function(GetGameUrlRequest) _then;

  /// Create a copy of GetGameUrlRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerId = null,
    Object? productId = null,
    Object? gameCode = null,
    Object? lang = freezed,
    Object? isMobileLogin = freezed,
  }) {
    return _then(_self.copyWith(
      providerId: null == providerId
          ? _self.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      gameCode: null == gameCode
          ? _self.gameCode
          : gameCode // ignore: cast_nullable_to_non_nullable
              as String,
      lang: freezed == lang
          ? _self.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      isMobileLogin: freezed == isMobileLogin
          ? _self.isMobileLogin
          : isMobileLogin // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GetGameUrlRequest].
extension GetGameUrlRequestPatterns on GetGameUrlRequest {
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
    TResult Function(_GetGameUrlRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GetGameUrlRequest() when $default != null:
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
    TResult Function(_GetGameUrlRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GetGameUrlRequest():
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
    TResult? Function(_GetGameUrlRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GetGameUrlRequest() when $default != null:
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
    TResult Function(String providerId, String productId, String gameCode,
            String? lang, bool? isMobileLogin)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GetGameUrlRequest() when $default != null:
        return $default(_that.providerId, _that.productId, _that.gameCode,
            _that.lang, _that.isMobileLogin);
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
    TResult Function(String providerId, String productId, String gameCode,
            String? lang, bool? isMobileLogin)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GetGameUrlRequest():
        return $default(_that.providerId, _that.productId, _that.gameCode,
            _that.lang, _that.isMobileLogin);
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
    TResult? Function(String providerId, String productId, String gameCode,
            String? lang, bool? isMobileLogin)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GetGameUrlRequest() when $default != null:
        return $default(_that.providerId, _that.productId, _that.gameCode,
            _that.lang, _that.isMobileLogin);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GetGameUrlRequest extends GetGameUrlRequest {
  const _GetGameUrlRequest(
      {required this.providerId,
      required this.productId,
      required this.gameCode,
      this.lang,
      this.isMobileLogin})
      : super._();
  factory _GetGameUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$GetGameUrlRequestFromJson(json);

  @override
  final String providerId;
  @override
  final String productId;
  @override
  final String gameCode;
  @override
  final String? lang;
  @override
  final bool? isMobileLogin;

  /// Create a copy of GetGameUrlRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GetGameUrlRequestCopyWith<_GetGameUrlRequest> get copyWith =>
      __$GetGameUrlRequestCopyWithImpl<_GetGameUrlRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GetGameUrlRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GetGameUrlRequest &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.gameCode, gameCode) ||
                other.gameCode == gameCode) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.isMobileLogin, isMobileLogin) ||
                other.isMobileLogin == isMobileLogin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, providerId, productId, gameCode, lang, isMobileLogin);

  @override
  String toString() {
    return 'GetGameUrlRequest(providerId: $providerId, productId: $productId, gameCode: $gameCode, lang: $lang, isMobileLogin: $isMobileLogin)';
  }
}

/// @nodoc
abstract mixin class _$GetGameUrlRequestCopyWith<$Res>
    implements $GetGameUrlRequestCopyWith<$Res> {
  factory _$GetGameUrlRequestCopyWith(
          _GetGameUrlRequest value, $Res Function(_GetGameUrlRequest) _then) =
      __$GetGameUrlRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String providerId,
      String productId,
      String gameCode,
      String? lang,
      bool? isMobileLogin});
}

/// @nodoc
class __$GetGameUrlRequestCopyWithImpl<$Res>
    implements _$GetGameUrlRequestCopyWith<$Res> {
  __$GetGameUrlRequestCopyWithImpl(this._self, this._then);

  final _GetGameUrlRequest _self;
  final $Res Function(_GetGameUrlRequest) _then;

  /// Create a copy of GetGameUrlRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? providerId = null,
    Object? productId = null,
    Object? gameCode = null,
    Object? lang = freezed,
    Object? isMobileLogin = freezed,
  }) {
    return _then(_GetGameUrlRequest(
      providerId: null == providerId
          ? _self.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      gameCode: null == gameCode
          ? _self.gameCode
          : gameCode // ignore: cast_nullable_to_non_nullable
              as String,
      lang: freezed == lang
          ? _self.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      isMobileLogin: freezed == isMobileLogin
          ? _self.isMobileLogin
          : isMobileLogin // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

// dart format on
