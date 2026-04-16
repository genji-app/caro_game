import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';
import '../config/sb_config.dart';
import '../network/sb_http_manager.dart';
import '../websocket/websocket_manager.dart';
import 'package:co_caro_flame/s88/core/services/auth/auth_config_service.dart';

/// Sportbook Login & Initialization
///
/// This is the entry point for the app that handles:
/// - Loading remote configuration from GitHub (base64-encoded)
/// - Authentication flow: user_token -> wsToken -> user_token_sb
/// - Loading server settings and domains
/// - WebSocket connections (Main, Chat, Sportbook)
/// - Auto-reconnect logic
class SbLogin {
  static final AppLogger _logger = AppLogger();
  static final SbConfig _config = SbConfig.instance;
  static final SbHttpManager _http = SbHttpManager.instance;

  // Force logout stream - emits when token expired or auth error
  static final StreamController<String> _forceLogoutController =
      StreamController<String>.broadcast();

  /// Stream to listen for force logout events (token expired, auth error, etc.)
  static Stream<String> get forceLogoutStream => _forceLogoutController.stream;

  // ===== MAIN ENTRY POINT =====

  /// Connect to Sportbook Server
  ///
  /// This is the main entry point that:
  /// 1. Loads remote config from GitHub
  /// 2. Refreshes access token
  /// 3. Gets sportbook token
  /// 4. Loads server settings
  /// 5. Validates user token
  /// 6. Connects WebSockets
  ///
  /// [isReconnect]: Skip loading config if reconnecting
  /// [hideLoading]: Don't show loading indicator
  static Future<bool> connect({
    bool isReconnect = false,
    bool hideLoading = false,
  }) async {
    try {
      _logger.i('SbLogin.connect() starting...');

      // Initialize (load config & authenticate)
      await _init(!isReconnect);

      // Connect to WebSocket servers
      await _connectToServer();

      _logger.i('SbLogin.connect() completed successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e('SbLogin.connect() failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== INITIALIZATION FLOW =====

  /// Step-by-step initialization
  ///
  /// Flow:
  /// 1. Load mainConfig from GitHub (if getConfig = true)
  /// 2. Refresh access token (get wsToken)
  /// 3. Load sbConfig (contains urlSetting, team/league maps)
  /// 4. Load server settings and domains
  /// 5. Get sportbook token
  /// 6. Validate token and get user info
  static Future<bool> _init(bool getConfig) async {
    try {
      // 0. Load brand config — skip if already loaded by loadBrandConfigOnly()
      if (getConfig && SbConfig.sun88BrandConfigUrl.isNotEmpty && _config.brandConfig.isEmpty) {
        _logger.i('Loading brand config from GitHub...');
        final brandConfig = await SbHttpManager.getConfig(
          SbConfig.sun88BrandConfigUrl,
        );
        _config.applyBrandConfig(brandConfig);
        _logger.i('Brand config applied');
      }

      // 1. Initialize auth config (distId, idServiceUrl, etc.)
      if (getConfig) {
        _logger.i('Initializing auth config...');
        final authConfigReady = await AuthConfigService.instance
            .initializeConfig();
        if (authConfigReady) {
          _logger.i('Auth config initialized successfully');
        } else {
          _logger.w('Auth config initialization failed, continuing anyway...');
        }
      }

      // 1. Load mainConfig from GitHub (base64-encoded)
      if (getConfig && SbConfig.mainConfigUrl.isNotEmpty) {
        _logger.i('Loading mainConfig from GitHub...');
        final mainConfig = await SbHttpManager.getConfig(
          SbConfig.mainConfigUrl,
        );
        // _logger.i('MainConfig: $mainConfig');
        _config.mainConfig = {..._config.mainConfig, ...mainConfig};
        // _logger.i('MainConfig loaded: ${mainConfig.keys.toList()}');

        // Override domains from brand config (project GitHub > external GitHub)
        final patch = _config.domainOverride.toMainConfigPatch();
        if (patch.isNotEmpty) {
          _config.mainConfig = {..._config.mainConfig, ...patch};
          _logger.i('Domain overrides applied: ${patch.keys.toList()}');
        }
      }

      // 2. Load sbConfig (contains urlSetting, team/league maps)
      // Cần load TRƯỚC refreshToken() vì refreshToken() → getSbToken() cần domains
      if (getConfig && SbConfig.sbConfigUrl.isNotEmpty) {
        _logger.i('Loading sbConfig from GitHub...');
        final sbConfig =
            await _http.send(SbConfig.sbConfigUrl, json: true)
                as Map<String, dynamic>;

        // Extract urlSetting
        final urlSetting = sbConfig['urlSetting'] as String?;
        if (urlSetting == null) {
          throw Exception('sbConfig does not contain urlSetting');
        }

        // 3. Load server settings and domains
        _logger.i('Loading server settings from: $urlSetting');
        await _http.getSetting(urlSetting, SbConfig.agentId);
        _logger.i('Server settings loaded');

        // Store team/league maps if needed
        // final teamMap = sbConfig['team'];
        // final leagueMap = sbConfig['league'];
      }

      // 4. Refresh token (get wsToken + userTokenSb)
      // Cần refresh trong các trường hợp:
      // - getConfig=true: normal login flow
      // - userTokenSb trống: sau initConfigOnly() hoặc app reload (tokens trong storage nhưng chưa trong memory)
      // Khi reconnect() gọi, refreshToken() đã được gọi trước nên userTokenSb đã có
      if (getConfig || _http.userTokenSb.isEmpty) {
        _logger.i('Refreshing access token...');
        await refreshToken();
      }

      // 6. Validate token and get user info
      _logger.i('Validating user token...');
      await _http.getUserByToken();
      _logger.i('User info loaded: ${_http.displayName} (${_http.custLogin})');

      return true;
    } catch (e, stackTrace) {
      _logger.e('SbLogin._init() failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== TOKEN REFRESH =====

  /// Refresh Access Token + WebSocket Token + Sportbook Token
  ///
  /// Three-step process:
  /// 1. Use refresh_token to get new access token (user_token)
  ///    Request: GET {api_domain}id?command=refreshToken&refreshToken={refresh_token}
  ///    Response: { status, data: { accessToken, ... } }
  /// 2. Use new access token to get wsToken
  ///    Request: GET {api_domain}id?command=loginAccessToken
  ///    Header: Authorization: {user_token}
  ///    Response: { status, data: { wsToken, ... } }
  /// 3. Use new access token to get userTokenSb (sportbook token)
  static Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Step 1: Get new access token using refresh token
      final storedRefreshToken = prefs.getString(SbConfig.refreshTokenKey);
      final actualToken = storedRefreshToken ?? '';

      if (actualToken.isEmpty) {
        _logger.e('No refresh token found in localStorage');
        throw Exception('No refresh token available');
      }

      _logger.i('Refresh token loaded from localStorage');

      // Call refresh token API to get new access token
      final refreshResponse =
          await _http.send('${_config.refreshUrl}$actualToken', json: true)
              as Map<String, dynamic>;

      // Extract new access token
      String? newAccessToken;
      if (refreshResponse['data'] != null) {
        final data = refreshResponse['data'] as Map<String, dynamic>;
        newAccessToken = data['accessToken'] as String?;

        if (newAccessToken == null || newAccessToken.isEmpty) {
          throw Exception('No access token in refresh response');
        }

        // Save new access token to localStorage
        await prefs.setString(SbConfig.userTokenKey, newAccessToken);
        _logger.i('New access token obtained and saved');
      }

      // Step 2: Use new access token to get wsToken and login credentials
      final loginResponse =
          await _http.send(
                _config.loginUrl,
                authorization: true,
                token: newAccessToken,
                json: true,
              )
              as Map<String, dynamic>;

      // Extract wsToken, info, and signature for Main WebSocket
      if (loginResponse['data'] != null) {
        final data = loginResponse['data'] as Map<String, dynamic>;

        // wsToken for WebSocket URL
        if (data['wsToken'] != null) {
          _config.wsToken = data['wsToken'] as String;
          _logger.i('wsToken obtained');
        }

        // info and signature for Main WebSocket login message
        if (data['info'] != null) {
          // Convert info object to JSON string
          _config.mainWsLoginInfo = jsonEncode(data['info']);
          _logger.i('mainWsLoginInfo obtained');
        }

        if (data['signature'] != null) {
          _config.mainWsLoginSignature = data['signature'] as String;
          _logger.i('mainWsLoginSignature obtained');
        }
      }

      // Set user token in HTTP manager
      _http.userToken = newAccessToken!;

      // Step 3: Get sportbook token (userTokenSb)
      _logger.i('Getting sportbook token...');
      await _http.getSbToken();
      _logger.i('Sportbook token obtained');

      _logger.i('Token refresh completed (all tokens updated)');
    } catch (e, stackTrace) {
      _logger.e('Failed to refresh token', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== WEBSOCKET CONNECTION =====

  /// Connect to WebSocket Servers
  ///
  /// Connects to Chat WebSocket and Sportbook WebSocket using WebSocketManager
  static Future<void> _connectToServer() async {
    try {
      _logger.i('Connecting to WebSocket servers...');

      final wsManager = WebSocketManager.instance;

      // Connect Main WebSocket
      final mainWsUrl = SbConfig.instance.mainWs;
      if (mainWsUrl.isNotEmpty) {
        // _logger.i('Connecting Main WebSocket: $mainWsUrl');
        final mainConnected = await wsManager.connectMain(
          mainWsUrl,
          _http.userToken,
          _http.custLogin, // Using custLogin as userId
        );
        if (mainConnected) {
          _logger.i('Main WebSocket connected successfully');

          // Send login message to authenticate
          _logger.i('Sending Main WebSocket login message...');
          wsManager.sendMainLogin(
            username: _config.mainWsUsername,
            password: _config.mainWsPassword,
            info: _config.mainWsLoginInfo,
            signature: _config.mainWsLoginSignature,
          );
          // _logger.i('Main WebSocket login message sent');
        } else {
          _logger.w('Main WebSocket connection failed');
        }
      } else {
        _logger.w('Main WebSocket URL is empty, skipping connection');
      }

      // Connect Chat WebSocket
      final chatConnected = await wsManager.connectChat();
      if (chatConnected) {
        _logger.i('Chat WebSocket connected successfully');
      } else {
        _logger.w('Chat WebSocket connection failed');
      }

      // ============================================================
      // V1 SPORTBOOK WEBSOCKET - DISABLED FOR V2 TESTING
      // ============================================================
      // Connect Sportbook WebSocket (for real-time odds, balance, user info)
      // final sportbookWsUrl = _http.urlHomeWebsocket;
      // _logger.i('urlHomeWebsocket from settings: "$sportbookWsUrl"');

      // if (sportbookWsUrl.isNotEmpty) {
      //   final sbWsFullUrl =
      //       '$sportbookWsUrl/ws?clientId=${SbConfig.clientId}&token=${_http.userTokenSb}';
      //   _logger.i('Connecting Sportbook WebSocket: $sbWsFullUrl');

      //   final sbConnected = await wsManager.connectSportbook(
      //     sbWsFullUrl,
      //     custLogin: _http.custLogin,
      //   );
      //   if (sbConnected) {
      //     _logger.i('Sportbook WebSocket connected successfully');
      //     // Subscribe to default sport (Football = 1)
      //     wsManager.subscribeSport(1);
      //   } else {
      //     _logger.w('Sportbook WebSocket connection failed');
      //   }
      // } else {
      //   _logger.w('Sportbook WebSocket URL is empty, skipping connection');
      // }
      _logger.i(
        'V1 Sportbook WebSocket DISABLED - using V2 SportSocketClient instead',
      );

      _logger.i('WebSocket connections initiated');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to connect WebSockets',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ===== RECONNECT =====

  /// Reconnect to Server
  ///
  /// Called when app resumes from background or connection is lost.
  /// Refreshes all tokens and reconnects.
  static bool _isReconnecting = false;

  static Future<void> reconnect() async {
    if (_isReconnecting) return;
    _isReconnecting = true;
    try {
      _logger.i('Reconnecting...');

      // Kill ALL WebSocket connections BEFORE reconnecting
      // Uses killAll() (fire-and-forget) to avoid blocking on weak network
      WebSocketManager.instance.killAll();

      // Reset HTTP manager state
      _http.reset();

      // Refresh all tokens TRƯỚC (đã bao gồm getSbToken bên trong)
      await refreshToken();

      // Reconnect với tokens mới (isReconnect=true để skip duplicate refreshToken trong _init)
      await connect(isReconnect: true, hideLoading: true);

      _logger.i('Reconnect completed');
    } catch (e, stackTrace) {
      _logger.e('Reconnect failed', error: e, stackTrace: stackTrace);
      await closeCreatorGame(
        555,
        withPopup: true,
        info: 'Reconnect failed after maximum retries',
      );
    } finally {
      _isReconnecting = false;
    }
  }

  // ===== ERROR HANDLING =====

  /// Close Game and Show Error
  ///
  /// Kills all WebSocket connections and optionally shows error popup.
  ///
  /// Error codes:
  /// - 111: Token refresh failed
  /// - 222: HttpManager not initialized
  /// - 333: No user token
  /// - 401: Config load failed
  /// - 402: SB token failed
  /// - 403: Auth failed
  /// - 404: User not found
  /// - 444: Refresh token failed
  /// - 555: Connection retry exceeded
  /// - 666: Request timeout
  static Future<void> closeCreatorGame(
    int errorCode, {
    bool withPopup = true,
    String info = 'Mất kết nối đến máy chủ!',
  }) async {
    try {
      _logger.e('Closing game with error code: $errorCode - $info');

      // Kill all WebSocket connections
      WebSocketManager.instance.killAll();

      // Reset configuration
      _config.reset();
      _http.reset();

      // Notify listeners to force logout (will update auth state)
      _forceLogoutController.add('$info ($errorCode)');

      if (withPopup) {
        _logger.w('Show error popup: $info ($errorCode)');
        // TODO: Show popup dialog
        // SbCommonPopup.show('Thông báo', '$info\n($errorCode)', () {
        //   SbConfig.backToLobby();
        // });
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error during closeCreatorGame',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ===== LOGOUT =====

  /// Logout and cleanup all connections
  ///
  /// This will:
  /// 1. Disconnect all WebSocket connections
  /// 2. Clear ALL tokens, user data, and config
  ///
  /// After this, user needs to login again and config will be reloaded.
  static Future<void> logout() async {
    try {
      _logger.i('SbLogin.logout() starting...');

      // 1. Disconnect all WebSocket connections
      _logger.i('Disconnecting all WebSockets...');
      WebSocketManager.instance.killAll();
      _logger.i('All WebSockets disconnected');

      // 2. Reset SbConfig completely (clear mainConfig, authConfig, tokens)
      _logger.i('Resetting SbConfig completely...');
      _config.reset();

      // 3. Reset SbHttpManager completely (clear tokens, domains, user data)
      _logger.i('Resetting SbHttpManager completely...');
      _http.reset();

      _logger.i('SbLogin.logout() completed');
    } catch (e, stackTrace) {
      _logger.e('SbLogin.logout() failed', error: e, stackTrace: stackTrace);
      // Still try to reset even if disconnect fails
      _config.reset();
      _http.reset();
    }
  }

  // ===== BRAND CONFIG PRELOAD =====

  /// Load brand config only — call this before runApp() so SplashScreen has
  /// cdnImages available on the very first frame.
  static Future<void> loadBrandConfigOnly() async {
    if (SbConfig.sun88BrandConfigUrl.isEmpty) return;
    if (_config.brandConfig.isNotEmpty) return; // already loaded
    final brandConfig = await SbHttpManager.getConfig(SbConfig.sun88BrandConfigUrl);
    _config.applyBrandConfig(brandConfig);
  }

  // ===== CONFIG ONLY INITIALIZATION =====

  /// Initialize config only (without token refresh)
  ///
  /// This should be called when app starts BEFORE user login.
  /// It loads all necessary config for login/register to work:
  /// - Auth config (distId, idServiceUrl, etc.)
  /// - Main config from GitHub
  /// - SB config and server settings
  ///
  /// After login success, call [connect()] to complete the flow.
  static Future<bool> initConfigOnly() async {
    try {
      _logger.i('SbLogin.initConfigOnly() starting...');

      // 0. Load brand config — skip if already loaded by loadBrandConfigOnly()
      if (SbConfig.sun88BrandConfigUrl.isNotEmpty && _config.brandConfig.isEmpty) {
        _logger.i('Loading brand config from GitHub...');
        final brandConfig = await SbHttpManager.getConfig(
          SbConfig.sun88BrandConfigUrl,
        );
        _config.applyBrandConfig(brandConfig);
        _logger.i('Brand config applied');
      }

      // 1. Initialize auth config (distId, idServiceUrl, etc.)
      _logger.i('Initializing auth config...');
      final authConfigReady = await AuthConfigService.instance
          .initializeConfig();
      if (authConfigReady) {
        _logger.i('Auth config initialized successfully');
      } else {
        _logger.w('Auth config initialization failed');
        return false;
      }

      // 2. Load mainConfig from GitHub (base64-encoded)
      if (SbConfig.mainConfigUrl.isNotEmpty) {
        _logger.i('Loading mainConfig from GitHub...');
        final mainConfig = await SbHttpManager.getConfig(
          SbConfig.mainConfigUrl,
        );
        _config.mainConfig = {..._config.mainConfig, ...mainConfig};

        // Override domains from brand config (project GitHub > external GitHub)
        final patch = _config.domainOverride.toMainConfigPatch();
        if (patch.isNotEmpty) {
          _config.mainConfig = {..._config.mainConfig, ...patch};
          _logger.i('Domain overrides applied: ${patch.keys.toList()}');
        }
      }

      // 3. Load sbConfig (contains urlSetting, team/league maps)
      if (SbConfig.sbConfigUrl.isNotEmpty) {
        _logger.i('Loading sbConfig from GitHub...');
        final sbConfig =
            await _http.send(SbConfig.sbConfigUrl, json: true)
                as Map<String, dynamic>;

        // Extract urlSetting
        final urlSetting = sbConfig['urlSetting'] as String?;
        if (urlSetting != null) {
          // 4. Load server settings and domains
          _logger.i('Loading server settings from: $urlSetting');
          await _http.getSetting(urlSetting, SbConfig.agentId);
          _logger.i('Server settings loaded');
        }
      }

      _logger.i('SbLogin.initConfigOnly() completed successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'SbLogin.initConfigOnly() failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check if user has valid tokens saved in localStorage
  ///
  /// Returns true if refreshToken exists, meaning user has logged in before.
  /// Call this after [initConfigOnly()] to decide whether to:
  /// - Call [connect()] for auto-login (if has tokens)
  /// - Show login screen (if no tokens)
  static Future<bool> hasValidTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(SbConfig.refreshTokenKey);
      final accessToken = prefs.getString(SbConfig.userTokenKey);

      final hasTokens =
          refreshToken != null &&
          refreshToken.isNotEmpty &&
          accessToken != null &&
          accessToken.isNotEmpty;

      _logger.i(
        'hasValidTokens: $hasTokens (refreshToken: ${refreshToken != null && refreshToken.isNotEmpty}, accessToken: ${accessToken != null && accessToken.isNotEmpty})',
      );
      return hasTokens;
    } catch (e) {
      _logger.e('Error checking tokens', error: e);
      return false;
    }
  }

  // ===== HELPERS =====

  /// Check if initialized
  static bool get isInitialized =>
      _config.isConfigLoaded && _http.userTokenSb.isNotEmpty;

  /// Check if config is loaded (ready for login/register)
  static bool get isConfigReady =>
      _config.isConfigLoaded && _config.isAuthConfigReady;

  /// Get current user display name
  static String get displayName => _http.displayName;

  /// Get current user balance
  static double get userBalance => _http.userBalance;
}
