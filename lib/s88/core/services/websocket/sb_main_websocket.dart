import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:co_caro_flame/s88/core/services/websocket/base_websocket.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';

/// Main WebSocket CMD Types (based on game server protocol)
class MainWsCMD {
  /// Login to game server
  static const int login = 1;

  /// Logout / Kicked
  static const int logout = 2;

  /// Join room
  static const int joinRoom = 3;

  /// Leave room
  static const int leaveRoom = 4;

  /// User Info response
  static const int userInfo = 5;

  /// Pong response
  static const int pong = 6;

  /// Ping request
  static const int ping = 7;

  /// Inner command for user info detail
  static const int innerUserInfo = 100;
}

/// Main WebSocket Configuration
class MainWsConfig {
  /// Zone name (fixed)
  static const String zone = 'Simms';

  /// Ping interval (seconds)
  static const int pingInterval = 5;

  /// Get platform ID
  static int getPlatformId() {
    if (kIsWeb) return 4; // Web
    if (Platform.isIOS) return 1;
    if (Platform.isAndroid) return 2;
    return 3; // Desktop/Other
  }
}

/// User Info Model from Main WebSocket
class MainWsUserInfo {
  final String? displayName; // dn
  final String? avatarUrl; // a
  final String? brand; // br
  final int? balanceGold; // As.gold
  final int? innerCmd; // cmd
  final int? id; // id - User ID number
  final String? uid; // uid - UUID
  final String? username; // u - Username

  const MainWsUserInfo({
    this.displayName,
    this.avatarUrl,
    this.brand,
    this.balanceGold,
    this.innerCmd,
    this.id,
    this.uid,
    this.username,
  });

  factory MainWsUserInfo.fromJson(Map<String, dynamic> json) {
    return MainWsUserInfo(
      displayName: json['dn'] as String?,
      avatarUrl: json['a'] as String?,
      brand: json['br'] as String?,
      balanceGold: (json['As'] as Map?)?['gold'] as int?,
      innerCmd: json['cmd'] as int?,
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      username: json['u'] as String?,
    );
  }

  /// Balance converted (gold / 1000)
  double? get balance => balanceGold != null ? balanceGold! / 1000 : null;

  @override
  String toString() {
    return 'MainWsUserInfo(dn: $displayName, id: $id, uid: $uid, username: $username, balance: ${balance}K, avatar: $avatarUrl, brand: $brand)';
  }
}

/// Main Game Server WebSocket
///
/// Handles communication with the main game server:
/// - Login with loginInfo (info, signature, platform)
/// - User Info (displayName, avatar, balance, brand)
/// - Ping/Pong to keep connection alive
/// - Logout/Kick detection
class SbMainWebSocket extends BaseWebSocket {
  final AppLogger _logger = AppLogger();

  // ===== CONNECTION STATE =====

  /// Is authenticated/logged in
  bool _isAuthenticated = false;

  // ===== PING/PONG STATE =====

  /// Ping timer
  Timer? _pingTimer;

  /// Current ping ID
  int _pingId = 0;

  // ===== STREAM CONTROLLERS =====

  /// User Info stream
  final StreamController<MainWsUserInfo> _userInfoController =
      StreamController<MainWsUserInfo>.broadcast();

  /// Balance update stream (from User Info)
  final StreamController<double> _balanceController =
      StreamController<double>.broadcast();

  /// Notification stream
  final StreamController<String> _notificationController =
      StreamController<String>.broadcast();

  /// Kick event stream (force logout)
  final StreamController<String> _kickController =
      StreamController<String>.broadcast();

  @override
  String get name => 'SbMainWebSocket';

  // ===== GETTERS =====

  /// Is authenticated
  bool get isAuthenticated => _isAuthenticated;

  // ===== STREAMS =====

  /// User Info stream
  Stream<MainWsUserInfo> get userInfoStream => _userInfoController.stream;

  /// Balance update stream
  Stream<double> get balanceStream => _balanceController.stream;

  /// Notification stream
  Stream<String> get notificationStream => _notificationController.stream;

  /// Kick event stream (force logout)
  Stream<String> get kickStream => _kickController.stream;

  // ===== PUBLIC METHODS =====

  /// Connect with authentication
  ///
  /// The URL should already contain the wsToken: wss://...?token={wsToken}
  /// After connection, you need to call sendLogin() to authenticate
  Future<bool> connectWithAuth(String url, String token, String userId) async {
    _logger.i('$name: 🔌 Connecting with auth...');
    // _logger.i('$name: URL: $url');
    // _logger.i('$name: Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    // _logger.i('$name: UserId: $userId');

    _isAuthenticated = false;
    return connect(url);
  }

  /// Send login message
  ///
  /// Format: [1, "Simms", username, password, loginInfo]
  ///
  /// Parameters:
  /// - username: Can be null/empty
  /// - password: Can be null/empty
  /// - loginInfo: Object with {info, signature, pid, subi}
  void sendLogin({
    String? username,
    String? password,
    required String? info,
    required String? signature,
  }) {
    if (!isConnected) {
      _logger.e('$name: ❌ Cannot send login - not connected');
      return;
    }

    _logger.i('$name: 🔐 Sending login message...');
    // _logger.i('$name: Username: ${username ?? "(null)"}');
    // _logger.i('$name: Password: ${password != null ? "***" : "(null)"}');
    // _logger.i('$name: Info: ${info != null ? "${info.substring(0, info.length > 50 ? 50 : info.length)}..." : "(null)"}');
    // _logger.i('$name: Signature: ${signature != null ? "${signature.substring(0, signature.length > 20 ? 20 : signature.length)}..." : "(null)"}');

    final loginInfo = {
      'info': info,
      'signature': signature,
      'pid': MainWsConfig.getPlatformId(),
      'subi': true,
    };

    final loginMessage = [
      MainWsCMD.login, // 1
      MainWsConfig.zone, // "Simms"
      username ?? '', // username (can be empty)
      password ?? '', // password (can be empty)
      loginInfo, // loginInfo object
    ];

    final jsonMessage = jsonEncode(loginMessage);
    // _logger.i('$name: 📤 Login message: $jsonMessage');
    send(jsonMessage);
  }

  /// Send ping
  void sendPing() {
    if (!isConnected) {
      return;
    }

    _pingId++;
    final pingMessage = [
      MainWsCMD.ping, // 7
      MainWsConfig.zone, // "Simms"
      _pingId,
      0,
    ];

    send(jsonEncode(pingMessage));
    // _logger.d('$name: 🏓 Ping sent: $_pingId');
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _userInfoController.close();
    _balanceController.close();
    _notificationController.close();
    _kickController.close();
    super.dispose();
  }

  // ===== PROTECTED OVERRIDES =====

  @override
  void onConnected() {
    _logger.i('$name: ✅ Connected successfully');
    _logger.i('$name: ⚠️ Remember to call sendLogin() to authenticate!');
  }

  @override
  void onMessage(String message) {
    // Log raw message received
    // _logger.d('$name: 📨 RAW MESSAGE: $message');

    try {
      final data = jsonDecode(message);

      // Check for pong response
      if (_handlePong(data)) {
        return;
      }

      // Handle array format: [CMD, payload]
      if (data is List && data.isNotEmpty) {
        final cmd = data[0] as int;
        final payload = data.length > 1 ? data[1] : null;

        // _logger.d('$name: 📋 CMD=$cmd, Payload type: ${payload?.runtimeType}');

        switch (cmd) {
          case MainWsCMD.login: // 1 — login success acknowledgment
            _isAuthenticated = payload == true;
            _logger.i('$name: 🔐 Login ${_isAuthenticated ? 'success' : 'failed'}');
            if (_isAuthenticated) _startPing();
            break;

          case MainWsCMD.userInfo: // 5
            _handleUserInfo(payload);
            break;

          case MainWsCMD.logout: // 2
            _handleLogout(payload);
            break;

          default:
            _logger.w('$name: ❓ Unknown CMD: $cmd');
            _logger.w('$name: Payload: $payload');
        }
      } else {
        _logger.w('$name: ⚠️ Message is not an array format');
        _logger.w('$name: Data: $data');
      }
    } catch (e, stackTrace) {
      _logger.e('$name: 🔴 Parse error: $e');
      _logger.e('$name: StackTrace: $stackTrace');
      _logger.e('$name: Raw message: $message');
    }
  }

  @override
  void onDisconnected() {
    _logger.w('$name: ❌ Disconnected from server');
    _isAuthenticated = false;
    _pingTimer?.cancel();
  }

  @override
  void onError(dynamic error) {
    _logger.e('$name: 🔴 Error occurred: $error');
  }

  // ===== PRIVATE HANDLERS =====

  /// Handle pong response
  ///
  /// Format 1: {"pong": pongId}
  /// Format 2: [6, pongId]
  bool _handlePong(dynamic data) {
    int? pongId;

    // Format 1: JSON object {"pong": 123}
    if (data is Map && data.containsKey('pong')) {
      pongId = data['pong'] as int?;
    }

    // Format 2: Array [6, pongId]
    if (data is List && data.isNotEmpty && data[0] == MainWsCMD.pong) {
      pongId = data.length > 1 ? data[1] as int? : 0;
    }

    if (pongId != null) {
      // _logger.d('$name: 🏓 Pong received: $pongId');
      _schedulePing();
      return true;
    }

    return false;
  }

  /// Handle User Info (CMD=5)
  void _handleUserInfo(dynamic payload) {
    if (payload == null || payload is! Map<String, dynamic>) {
      _logger.w('$name: ⚠️ User Info payload is null or invalid');
      return;
    }

    // Skip empty payloads (heartbeat/ack messages)
    // Only process if payload has meaningful user data
    if (payload.isEmpty ||
        (payload['dn'] == null &&
            payload['id'] == null &&
            payload['uid'] == null &&
            payload['As'] == null)) {
      // _logger.d('$name: ⏭️ Skipping empty User Info payload');
      return;
    }

    // _logger.i('$name: 👤 User Info received');
    // _logger.i('$name: Payload: $payload');

    try {
      final userInfo = MainWsUserInfo.fromJson(payload);
      // _logger.i('$name: ✅ Parsed: $userInfo');

      // Mark as authenticated
      _isAuthenticated = true;

      // Get instances
      final http = SbHttpManager.instance;

      // Update display name (dn) to http manager
      if (userInfo.displayName != null && userInfo.displayName!.isNotEmpty) {
        http.updateUserData('cust_login', userInfo.displayName!);
        http.updateUserData('displayName', userInfo.displayName!);
        // _logger.i('$name: 📝 Updated custLogin: ${userInfo.displayName}');
      }

      // Update user ID (id) - numeric ID
      if (userInfo.id != null) {
        http.updateUserData('cust_id', userInfo.id.toString());
        // _logger.i('$name: 🆔 Updated custId: ${userInfo.id}');
      }

      // Update UID (uid) - UUID string
      if (userInfo.uid != null && userInfo.uid!.isNotEmpty) {
        http.updateUserData('uid', userInfo.uid!);
        // _logger.i('$name: 🔑 Updated uid: ${userInfo.uid}');
      }

      // Update balance (As.gold / 1000)
      if (userInfo.balanceGold != null) {
        final balanceK = userInfo.balanceGold! / 1000;
        http.updateUserData('balance', balanceK);
        _logger.i(
          '$name: 💰 Updated balance: ${balanceK}K (${userInfo.balanceGold} gold)',
        );
        _balanceController.add(balanceK);
      }

      // Update avatar URL (a)
      if (userInfo.avatarUrl != null && userInfo.avatarUrl!.isNotEmpty) {
        // Avatar URL is already full URL from server
        // _logger.i('$name: 🖼️ Avatar URL: ${userInfo.avatarUrl}');
      }

      // Update brand/logo (br)
      if (userInfo.brand != null && userInfo.brand!.isNotEmpty) {
        // Brand identifier (e.g., "sun.win")
        // _logger.i('$name: 🏷️ Brand: ${userInfo.brand}');
      }

      // Emit user info to stream
      _userInfoController.add(userInfo);

      // Start ping/pong
      _startPing();
    } catch (e, stackTrace) {
      _logger.e('$name: 🔴 Failed to parse User Info: $e');
      _logger.e('$name: StackTrace: $stackTrace');
    }
  }

  /// Handle Logout/Kick (CMD=2)
  void _handleLogout(dynamic payload) {
    _logger.w('$name: ⚠️ Logout/Kick received');
    _logger.w('$name: Payload: $payload');

    _isAuthenticated = false;
    _pingTimer?.cancel();

    final reason = payload?.toString() ?? 'Logged in from another device';
    _kickController.add(reason);
  }

  /// Start ping mechanism
  void _startPing() {
    _pingTimer?.cancel();
    _pingId = 0;
    sendPing();
  }

  /// Schedule next ping
  void _schedulePing() {
    _pingTimer?.cancel();
    _pingTimer = Timer(
      const Duration(seconds: MainWsConfig.pingInterval),
      sendPing,
    );
  }
}
