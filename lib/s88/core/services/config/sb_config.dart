import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'domain_override.dart';

/// Sportbook Configuration Center
///
/// This is the central configuration object that contains all URLs, tokens, and settings.
/// Configuration is loaded dynamically from GitHub to allow server changes without rebuilding the app.
class SbConfig {
  // ===== SINGLETON PATTERN =====
  static final SbConfig _instance = SbConfig._internal();
  factory SbConfig() => _instance;
  SbConfig._internal();

  static SbConfig get instance => _instance;

  // ===== HARDCODED REMOTE CONFIG URLS =====
  /// Main config URL (base64-encoded JSON from GitHub)
  static const String mainConfigUrl =
      'https://raw.githubusercontent.com/jamesgreenmango/configs/master/creator_s_prod.json';

  /// Sportbook config URL (contains settings, domains, team/league maps)
  static const String sbConfigUrl =
      'https://raw.githubusercontent.com/jamesgreenmango/configs/master/sb.json';

  /// Auth config URL (base64-encoded JSON from GitHub)
  /// Contains: host_domain, brand, appName
  static const String authConfigUrl =
      'https://raw.githubusercontent.com/dev-itto/configs/main/sun/config/sappv363.json';

  // //Config sun88 brand
  // static const String sun88BrandConfigUrl =
  //     'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88.json';

  static const String sun88BrandConfigUrl = String.fromEnvironment(
    'BRAND_CONFIG_URL',
    defaultValue:
        'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88.json',
  );

  // ===== BRAND & AGENT INFO =====
  // All values loaded at runtime from sun88BrandConfigUrl — not hardcoded
  static int agentId = 0;
  static String agentCode = '';
  static String clientId = '';
  static String brandId = '';
  static String chatZone = '';
  static String chatRoom = '';

  // ===== AUTH BRAND INFO =====
  static String brand = '';
  static String bundleId = '';
  static String appName = '';
  static String hsk = '';

  /// Assembled at runtime from obfuscated parts in brand config
  static String secretKey = '';

  static String authBrand = '';

  // ===== CDN & EXTERNAL SERVICE URLS =====
  static String cdnIcons = '';
  static String cdnImages = '';
  static String cdnAudio = '';
  static String gameApiUrl = '';
  static String livechatLicense = '';
  static String cdnRives = '';

  static String get livechatUrl =>
      'https://secure.livechatinc.com/licence/$livechatLicense/v2/open_chat.cgi';

  // ===== BRAND CONFIG (loaded from sun88BrandConfigUrl) =====
  Map<String, dynamic> brandConfig = {};

  // ===== DOMAIN OVERRIDE (parsed from brandConfig) =====
  DomainOverride _domainOverride = const DomainOverride();
  DomainOverride get domainOverride => _domainOverride;

  /// Apply brand config fetched from [sun88BrandConfigUrl].
  /// Overrides static defaults and assembles [secretKey] from obfuscated parts.
  void applyBrandConfig(Map<String, dynamic> config) {
    brandConfig = config;

    if (config['agentId'] != null) agentId = config['agentId'] as int;
    if (config['agentCode'] != null) agentCode = config['agentCode'] as String;
    if (config['clientId'] != null) clientId = config['clientId'] as String;
    if (config['brandId'] != null) brandId = config['brandId'] as String;
    if (config['chatZone'] != null) chatZone = config['chatZone'] as String;
    if (config['chatRoom'] != null) chatRoom = config['chatRoom'] as String;
    if (config['brand'] != null) brand = config['brand'] as String;
    if (config['bundleId'] != null) bundleId = config['bundleId'] as String;
    if (config['appName'] != null) appName = config['appName'] as String;
    if (config['authBrand'] != null) authBrand = config['authBrand'] as String;
    if (config['cdn_icons'] != null) cdnIcons = config['cdn_icons'] as String;
    if (config['cdn_images'] != null)
      cdnImages = config['cdn_images'] as String;
    if (config['cdn_audio'] != null) cdnAudio = config['cdn_audio'] as String;
    if (config['game_api_url'] != null)
      gameApiUrl = config['game_api_url'] as String;
    if (config['livechat_license'] != null)
      livechatLicense = config['livechat_license'] as String;
    if (config['cdn_rives'] != null) cdnRives = config['cdn_rives'] as String;

    // Assemble secretKey from obfuscated parts (order: cache_prefix → display_key → locale_suffix → render_token)
    final p0 = config['cache_prefix'] as String? ?? '';
    final p1 = config['display_key'] as String? ?? '';
    final p2 = config['locale_suffix'] as String? ?? '';
    final p3 = config['render_token'] as String? ?? '';
    if (p0.isNotEmpty && p1.isNotEmpty && p2.isNotEmpty && p3.isNotEmpty) {
      secretKey = '$p0$p1$p2$p3';
    }

    // Domain override layer — brand config fields take priority over external configs
    _domainOverride = DomainOverride.fromBrandConfig(config);
  }

  // ===== PLATFORM CONSTANTS =====
  /// Platform IDs: 1 = iOS, 2 = Android, 4 = Web
  static int get platformId {
    if (kIsWeb) return 4;
    try {
      if (Platform.isIOS) return 1;
      if (Platform.isAndroid) return 2;
    } catch (_) {
      // Platform not available (web)
    }
    return 4; // fallback to web
  }

  /// Version IDs: 20 = web, 27 = app
  static int get versionId {
    if (kIsWeb) return 20;
    return 27; // App (iOS/Android)
  }

  // ===== LOCAL STORAGE KEYS =====
  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String wsTokenKey = 'ws_token';
  static const String deviceIdKey = 'device_id';
  static const String usernameKey = 'LOGGED_USER_NAME';
  static const String passwordKey = 'LOGGED_PASSWORD';

  // ===== SPORT STORAGE KEYS =====
  static const String sportIdKey = 'sbSportID';
  static const String oddsStyleKey = 'sbOddsStyle';

  // ===== SPORT DEFAULTS =====
  static const int defaultSportId = 1; // Football

  // ===== DEBUG/MOCK MODE =====
  /// Enable debug mode to use mock data without real API calls
  bool isDebugMode = false;

  /// Use mock data instead of real API
  bool useMockData = false;

  // ===== DYNAMIC CONFIG (loaded from mainConfigUrl) =====
  /// Main configuration object loaded from GitHub
  /// Contains: api_domain, sport_domain, sport_domain_top, main_ws_url, ws_sport_domain, avatarUrl, logo
  Map<String, dynamic> mainConfig = {};

  // ===== AUTH CONFIG (loaded from authConfigUrl) =====
  /// Auth configuration loaded from GitHub (base64 decoded)
  /// Contains: host_domain, brand, appName
  Map<String, dynamic> authConfig = {};

  /// Host domain from auth config (e.g., https://cfg.azhkthg1.com)
  String? hostDomain;

  /// Distributor ID from getDistributorId API
  String? distId;

  /// App ID from getDistributorId API
  String? appId;

  /// ID Service URL (IDdomainURL) - main endpoint for login/register
  /// Loaded from getAcsConfig API: services["id"]
  String? idServiceUrl;

  /// Paygate URL for deposit/withdraw
  String? paygateUrl;

  // ===== RUNTIME TOKENS =====
  /// WebSocket token (for main WS and chat WS)
  String wsToken = '';

  // ===== MAIN WEBSOCKET CREDENTIALS =====
  /// Login info from API (JSON string from loginAccessToken response)
  /// Should be stored as JSON.stringify(data.info)
  String? mainWsLoginInfo;

  /// Login signature from API (string from loginAccessToken response)
  String? mainWsLoginSignature;

  /// Optional username for login (can be null)
  String? mainWsUsername;

  /// Optional password for login (can be null)
  String? mainWsPassword;

  // ===== DYNAMIC URL GETTERS =====
  /// Login URL - Exchange access token for wsToken
  /// GET: {api_domain}id?command=loginAccessToken
  /// Header: Authorization: {user_token}
  String get loginUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=loginAccessToken';
  }

  /// Refresh token URL
  /// GET: {api_domain}id?command=refreshToken&refreshToken={refresh_token}
  String get refreshUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=refreshToken&refreshToken=';
  }

  /// Change password URL
  /// GET: {api_domain}id?command=changePass
  String get changePasswordUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '${apiDomain}id?command=changePass';
  }

  /// Sportbook token URL - Get sportbook-specific token
  /// GET: {sport_domain}?command=get-token
  /// Header: Authorization: {user_token}
  /// Response: { data: { token: "sb_token" } }
  String get sportTokenUrl {
    final sportDomain = mainConfig['sport_domain'] ?? '';
    return '$sportDomain?command=get-token';
  }

  /// Main WebSocket URL
  /// WSS: {main_ws_url}?token={wsToken}
  /// Returns empty string if main_ws_url is not configured
  String get mainWs {
    final mainWsUrl = mainConfig['main_ws_url'] as String? ?? '';
    if (mainWsUrl.isEmpty) return '';
    return '$mainWsUrl?token=$wsToken';
  }

  /// Chat WebSocket URL
  /// WSS: {ws_sport_domain}?token={wsToken}
  /// Returns empty string if ws_sport_domain is not configured
  String get chatWs {
    final wsSportDomain = mainConfig['ws_sport_domain'] as String? ?? '';
    if (wsSportDomain.isEmpty) return '';
    return '$wsSportDomain?token=$wsToken';
  }

  /// Top sport domain URL
  String get sportDomainTop => (mainConfig['sport_domain_top'] ?? '') as String;

  /// Avatar CDN URL
  String get avatarUrl => (mainConfig['avatarUrl'] ?? '') as String;

  /// Brand logo identifier
  String get logo => (mainConfig['logo'] ?? '') as String;

  // ===== AUTH URL GETTERS =====
  /// Get server time URL (for web platform)
  /// GET: {idServiceUrl}?command=getTime
  String get serverTimeUrl {
    if (idServiceUrl == null) return '';
    return '$idServiceUrl?command=getTime';
  }

  /// Get distributor URL
  /// GET: {host_domain}/distributor?command=regdis&bundle={bundleId}&appName={appName}
  String get distributorUrl {
    if (hostDomain == null) return '';
    return '${hostDomain}distributor?command=regdis&bundle=$bundleId&appName=$appName';
  }

  /// Get ACS config URL
  /// GET: {host_domain}/acs?command=get-bid&distId={distId}&versionId={versionId}&platformId={platformId}&appId={appId}
  String get acsConfigUrl {
    if (hostDomain == null || distId == null || appId == null) return '';
    return '${hostDomain}acs?command=get-bid&distId=$distId&versionId=$versionId&platformId=$platformId&appId=$appId';
  }

  /// Paygate Path URL
  /// GET: {api_domain}/paygate
  String get paygateDomainUrl {
    final apiDomain = mainConfig['api_domain'] ?? '';
    return '$apiDomain/paygate';
  }

  // ===== HELPER METHODS =====
  /// Reset configuration (useful for logout or reconnect)
  void reset() {
    mainConfig = {};
    authConfig = {};
    wsToken = '';
    mainWsLoginInfo = null;
    mainWsLoginSignature = null;
    mainWsUsername = null;
    mainWsPassword = null;
  }

  /// Reset auth config only (keeps main config)
  void resetAuth() {
    authConfig = {};
    hostDomain = null;
    distId = null;
    appId = null;
    idServiceUrl = null;
    paygateUrl = null;
    wsToken = '';
    mainWsLoginInfo = null;
    mainWsLoginSignature = null;
    mainWsUsername = null;
    mainWsPassword = null;
  }

  /// Reset tokens only for logout (keeps all config data)
  ///
  /// This only clears:
  /// - wsToken
  /// - mainWsLoginInfo/Signature
  ///
  /// Keeps:
  /// - mainConfig (api_domain, sport_domain, etc.)
  /// - authConfig (hostDomain, distId, idServiceUrl, etc.)
  void resetForLogout() {
    wsToken = '';
    mainWsLoginInfo = null;
    mainWsLoginSignature = null;
    mainWsUsername = null;
    mainWsPassword = null;
  }

  /// Check if main config is loaded
  bool get isConfigLoaded => mainConfig.isNotEmpty;

  /// Check if auth config is ready (all required fields loaded)
  bool get isAuthConfigReady =>
      hostDomain != null &&
      distId != null &&
      appId != null &&
      idServiceUrl != null;

  /// Get full avatar URL for a user
  String getAvatarUrl(String avatarId) =>
      (avatarUrl.isEmpty || avatarId.isEmpty) ? '' : '$avatarUrl$avatarId';

  @override
  String toString() =>
      'SbConfig(isConfigLoaded: $isConfigLoaded, isAuthConfigReady: $isAuthConfigReady, wsToken: ${wsToken.isNotEmpty}, useMockData: $useMockData)';
}
