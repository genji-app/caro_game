import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';
import 'package:co_caro_flame/s88/features/notification/domain/notification_item.dart';

import 'jwt_decoder_service.dart';
import 'jwt_user_info_model.dart';
import 'user_failure.dart';

/// {@template user_repository}
/// User Repository Implementation.
///
/// Manages user data retrieval (JWT + HTTP), real-time updates via
/// WebSocket, and balance refresh. All public methods throw typed
/// [UserFailure] subclasses on error.
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  UserRepository({
    required SbHttpManager http,
    required WebSocketManager wsManager,
    JwtDecoderService? jwtDecoder,
    String Function()? tokenProvider,
  }) : _http = http,
       _wsManager = wsManager,
       _jwtDecoder = jwtDecoder ?? JwtDecoderServiceImpl(),
       _tokenProvider = tokenProvider ?? (() => SbConfig.instance.wsToken) {
    _initListeners();
  }

  final SbHttpManager _http;
  final JwtDecoderService _jwtDecoder;
  final WebSocketManager _wsManager;

  /// Provides the current WS token for JWT decoding.
  /// Injected to avoid direct [SbConfig] coupling and enable testing.
  final String Function() _tokenProvider;

  final _userController = StreamController<User?>.broadcast();
  User? _currentUser;
  StreamSubscription<MainWsUserInfo>? _userInfoSub;
  StreamSubscription<double>? _balanceSub;

  /// In-flight balance request, used to deduplicate concurrent calls.
  Future<double>? _balanceFuture;

  void _initListeners() {
    _userInfoSub = _wsManager.main.userInfoStream.listen(
      (wsUserInfo) {
        debugPrint('User info updated: $wsUserInfo');
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            displayName: wsUserInfo.displayName ?? _currentUser!.displayName,
            custLogin: wsUserInfo.displayName ?? _currentUser!.custLogin,
            custId: wsUserInfo.id?.toString() ?? _currentUser!.custId,
            uid: wsUserInfo.uid ?? _currentUser!.uid,
            username: wsUserInfo.username ?? _currentUser!.username,
            balance: wsUserInfo.balance ?? _currentUser!.balance,
            avatarUrl: wsUserInfo.avatarUrl ?? _currentUser!.avatarUrl,
            brand: wsUserInfo.brand ?? _currentUser!.brand,
          );
          _userController.add(_currentUser);
        }
      },
      onError: (Object error) {
        debugPrint('UserRepository: userInfoStream error: $error');
      },
    );

    _balanceSub = _wsManager.main.balanceStream.listen(
      (balance) {
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(balance: balance);
          _userController.add(_currentUser);
        }
      },
      onError: (Object error) {
        debugPrint('UserRepository: balanceStream error: $error');
      },
    );
  }

  /// Stream of user data updates.
  Stream<User?> get userStream => _userController.stream;

  /// Get current user data.
  User? get currentUser => _currentUser;

  /// Fetches user info, merging JWT and HTTP data.
  ///
  /// Tries JWT first (fast, offline), then enriches with HTTP.
  /// Falls back to HTTP-only when JWT is unavailable.
  ///
  /// Throws [GetUserInfoFailure] if the request fails.
  Future<User?> getUserInfo() async {
    try {
      return await _getUserFromJwt() ?? await _getUserFromHttp();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetUserInfoFailure(error), stackTrace);
    }
  }

  /// Fetches the latest balance from the API and pushes it into
  /// [userStream] so all listeners receive the change reactively.
  ///
  /// Concurrent calls share the same in-flight request to avoid
  /// duplicate HTTP calls.
  ///
  /// Throws [GetBalanceFailure] if the request fails.
  Future<double> getBalance() async {
    try {
      return _balanceFuture ??= _fetchBalance()
        ..whenComplete(() => _balanceFuture = null);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetBalanceFailure(error), stackTrace);
    }
  }

  /// Changes the user's password.
  ///
  /// Throws [ChangePasswordFailure] if the request fails.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _http.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ChangePasswordFailure(error), stackTrace);
    }
  }

  /// Verifies the user's phone number via OTP.
  ///
  /// Throws [VerifyPhoneFailure] if verification fails.
  Future<void> verifyPhone({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      await _http.activePhone(otp);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(VerifyPhoneFailure(error), stackTrace);
    }
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final raw = await _http.getNotifications();
      return raw.map(NotificationItem.fromApiMap).toList();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetNotificationsFailure(error), stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _updateCurrentUser(User? user) {
    _currentUser = user;
    _userController.add(_currentUser);
  }

  /// Attempts to build a [User] from the JWT token, optionally
  /// enriched with HTTP data.
  Future<User?> _getUserFromJwt() async {
    final jwtUserModel = _decodeJwtToken();
    if (jwtUserModel == null) return null;

    // Try HTTP enrichment (optional — failure is non-fatal).
    UserModel? userModel;
    try {
      await _http.getUserInfo();
      userModel = UserModel.fromHttpMap(_http.user);
    } catch (_) {
      // HTTP enrichment is optional — continue with JWT-only data.
    }

    final user = User.merge(jwt: jwtUserModel, userModel: userModel);
    _updateCurrentUser(user);
    return user;
  }

  /// Fetches user info purely from HTTP.
  Future<User?> _getUserFromHttp() async {
    await _http.getUserInfo();
    final userModel = UserModel.fromHttpMap(_http.user);

    final user = User.fromUserModel(userModel);
    _updateCurrentUser(user);
    return user;
  }

  /// The actual HTTP balance fetch, separated so [getBalance] can
  /// cache and deduplicate the in-flight future.
  Future<double> _fetchBalance() async {
    await _http.getUserBalance();
    final balance = _http.userBalance;

    // Push updated balance into the user stream.
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(balance: balance);
      _userController.add(_currentUser);
    }

    return balance;
  }

  /// Decodes the JWT token from the injected [_tokenProvider].
  JwtUserInfoModel? _decodeJwtToken() {
    try {
      final wsToken = _tokenProvider();
      if (wsToken.isEmpty) return null;

      final payload = _jwtDecoder.decodeToken(wsToken);
      if (payload == null) return null;

      return JwtUserInfoModel.fromJson(payload);
    } catch (_) {
      // JWT parsing is best-effort — return null to fallback to HTTP.
      return null;
    }
  }

  /// Disposes and cleans up resources.
  void dispose() {
    _userInfoSub?.cancel();
    _balanceSub?.cancel();
    _userController.close();
  }
}
