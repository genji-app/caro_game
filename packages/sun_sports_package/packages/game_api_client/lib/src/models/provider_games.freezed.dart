// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_games.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderGames {
  @JsonKey(name: 'providerId')
  String get providerId;
  @JsonKey(name: 'providerName')
  String get providerName;
  @JsonKey(name: 'gameList')
  List<Game> get gameList;

  /// Create a copy of ProviderGames
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProviderGamesCopyWith<ProviderGames> get copyWith =>
      _$ProviderGamesCopyWithImpl<ProviderGames>(
          this as ProviderGames, _$identity);

  /// Serializes this ProviderGames to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProviderGames &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.providerName, providerName) ||
                other.providerName == providerName) &&
            const DeepCollectionEquality().equals(other.gameList, gameList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, providerId, providerName,
      const DeepCollectionEquality().hash(gameList));

  @override
  String toString() {
    return 'ProviderGames(providerId: $providerId, providerName: $providerName, gameList: $gameList)';
  }
}

/// @nodoc
abstract mixin class $ProviderGamesCopyWith<$Res> {
  factory $ProviderGamesCopyWith(
          ProviderGames value, $Res Function(ProviderGames) _then) =
      _$ProviderGamesCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'providerId') String providerId,
      @JsonKey(name: 'providerName') String providerName,
      @JsonKey(name: 'gameList') List<Game> gameList});
}

/// @nodoc
class _$ProviderGamesCopyWithImpl<$Res>
    implements $ProviderGamesCopyWith<$Res> {
  _$ProviderGamesCopyWithImpl(this._self, this._then);

  final ProviderGames _self;
  final $Res Function(ProviderGames) _then;

  /// Create a copy of ProviderGames
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerId = null,
    Object? providerName = null,
    Object? gameList = null,
  }) {
    return _then(_self.copyWith(
      providerId: null == providerId
          ? _self.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      providerName: null == providerName
          ? _self.providerName
          : providerName // ignore: cast_nullable_to_non_nullable
              as String,
      gameList: null == gameList
          ? _self.gameList
          : gameList // ignore: cast_nullable_to_non_nullable
              as List<Game>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProviderGames].
extension ProviderGamesPatterns on ProviderGames {
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
    TResult Function(_ProviderGames value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProviderGames() when $default != null:
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
    TResult Function(_ProviderGames value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProviderGames():
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
    TResult? Function(_ProviderGames value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProviderGames() when $default != null:
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
    TResult Function(
            @JsonKey(name: 'providerId') String providerId,
            @JsonKey(name: 'providerName') String providerName,
            @JsonKey(name: 'gameList') List<Game> gameList)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProviderGames() when $default != null:
        return $default(_that.providerId, _that.providerName, _that.gameList);
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
    TResult Function(
            @JsonKey(name: 'providerId') String providerId,
            @JsonKey(name: 'providerName') String providerName,
            @JsonKey(name: 'gameList') List<Game> gameList)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProviderGames():
        return $default(_that.providerId, _that.providerName, _that.gameList);
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
    TResult? Function(
            @JsonKey(name: 'providerId') String providerId,
            @JsonKey(name: 'providerName') String providerName,
            @JsonKey(name: 'gameList') List<Game> gameList)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProviderGames() when $default != null:
        return $default(_that.providerId, _that.providerName, _that.gameList);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProviderGames implements ProviderGames {
  const _ProviderGames(
      {@JsonKey(name: 'providerId') required this.providerId,
      @JsonKey(name: 'providerName') required this.providerName,
      @JsonKey(name: 'gameList') final List<Game> gameList = const []})
      : _gameList = gameList;
  factory _ProviderGames.fromJson(Map<String, dynamic> json) =>
      _$ProviderGamesFromJson(json);

  @override
  @JsonKey(name: 'providerId')
  final String providerId;
  @override
  @JsonKey(name: 'providerName')
  final String providerName;
  final List<Game> _gameList;
  @override
  @JsonKey(name: 'gameList')
  List<Game> get gameList {
    if (_gameList is EqualUnmodifiableListView) return _gameList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gameList);
  }

  /// Create a copy of ProviderGames
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProviderGamesCopyWith<_ProviderGames> get copyWith =>
      __$ProviderGamesCopyWithImpl<_ProviderGames>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProviderGamesToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProviderGames &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.providerName, providerName) ||
                other.providerName == providerName) &&
            const DeepCollectionEquality().equals(other._gameList, _gameList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, providerId, providerName,
      const DeepCollectionEquality().hash(_gameList));

  @override
  String toString() {
    return 'ProviderGames(providerId: $providerId, providerName: $providerName, gameList: $gameList)';
  }
}

/// @nodoc
abstract mixin class _$ProviderGamesCopyWith<$Res>
    implements $ProviderGamesCopyWith<$Res> {
  factory _$ProviderGamesCopyWith(
          _ProviderGames value, $Res Function(_ProviderGames) _then) =
      __$ProviderGamesCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'providerId') String providerId,
      @JsonKey(name: 'providerName') String providerName,
      @JsonKey(name: 'gameList') List<Game> gameList});
}

/// @nodoc
class __$ProviderGamesCopyWithImpl<$Res>
    implements _$ProviderGamesCopyWith<$Res> {
  __$ProviderGamesCopyWithImpl(this._self, this._then);

  final _ProviderGames _self;
  final $Res Function(_ProviderGames) _then;

  /// Create a copy of ProviderGames
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? providerId = null,
    Object? providerName = null,
    Object? gameList = null,
  }) {
    return _then(_ProviderGames(
      providerId: null == providerId
          ? _self.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      providerName: null == providerName
          ? _self.providerName
          : providerName // ignore: cast_nullable_to_non_nullable
              as String,
      gameList: null == gameList
          ? _self._gameList
          : gameList // ignore: cast_nullable_to_non_nullable
              as List<Game>,
    ));
  }
}

/// @nodoc
mixin _$Game {
  @JsonKey(name: 'productId')
  String get productId;
  @JsonKey(name: 'gameCode')
  String get gameCode;
  @JsonKey(name: 'gameName')
  String get gameName;
  @JsonKey(name: 'lang')
  String get lang;
  @JsonKey(name: 'lobbyUrl')
  String get lobbyUrl;
  @JsonKey(name: 'cashierUrl')
  String get cashierUrl;
  @JsonKey(
      name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson)
  GameType get gameType;
  @JsonKey(name: 'mobileLogin')
  bool get mobileLogin;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameCopyWith<Game> get copyWith =>
      _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Game &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.gameCode, gameCode) ||
                other.gameCode == gameCode) &&
            (identical(other.gameName, gameName) ||
                other.gameName == gameName) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.lobbyUrl, lobbyUrl) ||
                other.lobbyUrl == lobbyUrl) &&
            (identical(other.cashierUrl, cashierUrl) ||
                other.cashierUrl == cashierUrl) &&
            (identical(other.gameType, gameType) ||
                other.gameType == gameType) &&
            (identical(other.mobileLogin, mobileLogin) ||
                other.mobileLogin == mobileLogin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, gameCode, gameName,
      lang, lobbyUrl, cashierUrl, gameType, mobileLogin);

  @override
  String toString() {
    return 'Game(productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, gameType: $gameType, mobileLogin: $mobileLogin)';
  }
}

/// @nodoc
abstract mixin class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) =
      _$GameCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'productId') String productId,
      @JsonKey(name: 'gameCode') String gameCode,
      @JsonKey(name: 'gameName') String gameName,
      @JsonKey(name: 'lang') String lang,
      @JsonKey(name: 'lobbyUrl') String lobbyUrl,
      @JsonKey(name: 'cashierUrl') String cashierUrl,
      @JsonKey(
          name: 'gameType',
          fromJson: GameType.fromJson,
          toJson: GameType.toJson)
      GameType gameType,
      @JsonKey(name: 'mobileLogin') bool mobileLogin});
}

/// @nodoc
class _$GameCopyWithImpl<$Res> implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? gameCode = null,
    Object? gameName = null,
    Object? lang = null,
    Object? lobbyUrl = null,
    Object? cashierUrl = null,
    Object? gameType = null,
    Object? mobileLogin = null,
  }) {
    return _then(_self.copyWith(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      gameCode: null == gameCode
          ? _self.gameCode
          : gameCode // ignore: cast_nullable_to_non_nullable
              as String,
      gameName: null == gameName
          ? _self.gameName
          : gameName // ignore: cast_nullable_to_non_nullable
              as String,
      lang: null == lang
          ? _self.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      lobbyUrl: null == lobbyUrl
          ? _self.lobbyUrl
          : lobbyUrl // ignore: cast_nullable_to_non_nullable
              as String,
      cashierUrl: null == cashierUrl
          ? _self.cashierUrl
          : cashierUrl // ignore: cast_nullable_to_non_nullable
              as String,
      gameType: null == gameType
          ? _self.gameType
          : gameType // ignore: cast_nullable_to_non_nullable
              as GameType,
      mobileLogin: null == mobileLogin
          ? _self.mobileLogin
          : mobileLogin // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
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
    TResult Function(_Game value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Game() when $default != null:
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
    TResult Function(_Game value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Game():
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
    TResult? Function(_Game value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Game() when $default != null:
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
    TResult Function(
            @JsonKey(name: 'productId') String productId,
            @JsonKey(name: 'gameCode') String gameCode,
            @JsonKey(name: 'gameName') String gameName,
            @JsonKey(name: 'lang') String lang,
            @JsonKey(name: 'lobbyUrl') String lobbyUrl,
            @JsonKey(name: 'cashierUrl') String cashierUrl,
            @JsonKey(
                name: 'gameType',
                fromJson: GameType.fromJson,
                toJson: GameType.toJson)
            GameType gameType,
            @JsonKey(name: 'mobileLogin') bool mobileLogin)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Game() when $default != null:
        return $default(
            _that.productId,
            _that.gameCode,
            _that.gameName,
            _that.lang,
            _that.lobbyUrl,
            _that.cashierUrl,
            _that.gameType,
            _that.mobileLogin);
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
    TResult Function(
            @JsonKey(name: 'productId') String productId,
            @JsonKey(name: 'gameCode') String gameCode,
            @JsonKey(name: 'gameName') String gameName,
            @JsonKey(name: 'lang') String lang,
            @JsonKey(name: 'lobbyUrl') String lobbyUrl,
            @JsonKey(name: 'cashierUrl') String cashierUrl,
            @JsonKey(
                name: 'gameType',
                fromJson: GameType.fromJson,
                toJson: GameType.toJson)
            GameType gameType,
            @JsonKey(name: 'mobileLogin') bool mobileLogin)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Game():
        return $default(
            _that.productId,
            _that.gameCode,
            _that.gameName,
            _that.lang,
            _that.lobbyUrl,
            _that.cashierUrl,
            _that.gameType,
            _that.mobileLogin);
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
    TResult? Function(
            @JsonKey(name: 'productId') String productId,
            @JsonKey(name: 'gameCode') String gameCode,
            @JsonKey(name: 'gameName') String gameName,
            @JsonKey(name: 'lang') String lang,
            @JsonKey(name: 'lobbyUrl') String lobbyUrl,
            @JsonKey(name: 'cashierUrl') String cashierUrl,
            @JsonKey(
                name: 'gameType',
                fromJson: GameType.fromJson,
                toJson: GameType.toJson)
            GameType gameType,
            @JsonKey(name: 'mobileLogin') bool mobileLogin)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Game() when $default != null:
        return $default(
            _that.productId,
            _that.gameCode,
            _that.gameName,
            _that.lang,
            _that.lobbyUrl,
            _that.cashierUrl,
            _that.gameType,
            _that.mobileLogin);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Game implements Game {
  const _Game(
      {@JsonKey(name: 'productId') required this.productId,
      @JsonKey(name: 'gameCode') required this.gameCode,
      @JsonKey(name: 'gameName') required this.gameName,
      @JsonKey(name: 'lang') required this.lang,
      @JsonKey(name: 'lobbyUrl') required this.lobbyUrl,
      @JsonKey(name: 'cashierUrl') required this.cashierUrl,
      @JsonKey(
          name: 'gameType',
          fromJson: GameType.fromJson,
          toJson: GameType.toJson)
      required this.gameType,
      @JsonKey(name: 'mobileLogin') this.mobileLogin = false});
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  @override
  @JsonKey(name: 'productId')
  final String productId;
  @override
  @JsonKey(name: 'gameCode')
  final String gameCode;
  @override
  @JsonKey(name: 'gameName')
  final String gameName;
  @override
  @JsonKey(name: 'lang')
  final String lang;
  @override
  @JsonKey(name: 'lobbyUrl')
  final String lobbyUrl;
  @override
  @JsonKey(name: 'cashierUrl')
  final String cashierUrl;
  @override
  @JsonKey(
      name: 'gameType', fromJson: GameType.fromJson, toJson: GameType.toJson)
  final GameType gameType;
  @override
  @JsonKey(name: 'mobileLogin')
  final bool mobileLogin;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameCopyWith<_Game> get copyWith =>
      __$GameCopyWithImpl<_Game>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GameToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Game &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.gameCode, gameCode) ||
                other.gameCode == gameCode) &&
            (identical(other.gameName, gameName) ||
                other.gameName == gameName) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.lobbyUrl, lobbyUrl) ||
                other.lobbyUrl == lobbyUrl) &&
            (identical(other.cashierUrl, cashierUrl) ||
                other.cashierUrl == cashierUrl) &&
            (identical(other.gameType, gameType) ||
                other.gameType == gameType) &&
            (identical(other.mobileLogin, mobileLogin) ||
                other.mobileLogin == mobileLogin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, gameCode, gameName,
      lang, lobbyUrl, cashierUrl, gameType, mobileLogin);

  @override
  String toString() {
    return 'Game(productId: $productId, gameCode: $gameCode, gameName: $gameName, lang: $lang, lobbyUrl: $lobbyUrl, cashierUrl: $cashierUrl, gameType: $gameType, mobileLogin: $mobileLogin)';
  }
}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) =
      __$GameCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'productId') String productId,
      @JsonKey(name: 'gameCode') String gameCode,
      @JsonKey(name: 'gameName') String gameName,
      @JsonKey(name: 'lang') String lang,
      @JsonKey(name: 'lobbyUrl') String lobbyUrl,
      @JsonKey(name: 'cashierUrl') String cashierUrl,
      @JsonKey(
          name: 'gameType',
          fromJson: GameType.fromJson,
          toJson: GameType.toJson)
      GameType gameType,
      @JsonKey(name: 'mobileLogin') bool mobileLogin});
}

/// @nodoc
class __$GameCopyWithImpl<$Res> implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productId = null,
    Object? gameCode = null,
    Object? gameName = null,
    Object? lang = null,
    Object? lobbyUrl = null,
    Object? cashierUrl = null,
    Object? gameType = null,
    Object? mobileLogin = null,
  }) {
    return _then(_Game(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      gameCode: null == gameCode
          ? _self.gameCode
          : gameCode // ignore: cast_nullable_to_non_nullable
              as String,
      gameName: null == gameName
          ? _self.gameName
          : gameName // ignore: cast_nullable_to_non_nullable
              as String,
      lang: null == lang
          ? _self.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      lobbyUrl: null == lobbyUrl
          ? _self.lobbyUrl
          : lobbyUrl // ignore: cast_nullable_to_non_nullable
              as String,
      cashierUrl: null == cashierUrl
          ? _self.cashierUrl
          : cashierUrl // ignore: cast_nullable_to_non_nullable
              as String,
      gameType: null == gameType
          ? _self.gameType
          : gameType // ignore: cast_nullable_to_non_nullable
              as GameType,
      mobileLogin: null == mobileLogin
          ? _self.mobileLogin
          : mobileLogin // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
