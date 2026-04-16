import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';

/// Service for initializing auth configuration
/// Implements the 3-step config flow:
/// 1. Get Config Domain from GitHub (base64 encoded)
/// 2. Get Distributor ID
/// 3. Get ACS Config (services URLs)
class AuthConfigService {
  AuthConfigService._();

  static final AuthConfigService _instance = AuthConfigService._();
  static AuthConfigService get instance => _instance;

  final SbConfig _config = SbConfig.instance;

  /// Initialize auth configuration
  /// This should be called when app starts before showing login/register
  Future<bool> initializeConfig() async {
    try {
      // Step 1: Get config from GitHub
      await _getConfigDomain();

      // Step 2: Get Distributor ID
      await _getDistributorId();

      // Step 3: Get ACS Config (service URLs)
      await _getAcsConfig();

      return _config.isAuthConfigReady;
    } catch (e) {
      print('[AuthConfigService] Error initializing config: $e');
      return false;
    }
  }

  /// Step 1: Get Config Domain from GitHub
  /// Response is base64 encoded JSON
  Future<void> _getConfigDomain() async {
    final response = await http.get(Uri.parse(SbConfig.authConfigUrl));

    if (response.statusCode == 200) {
      // Response is base64 encoded JSON string
      final decoded = utf8.decode(base64.decode(response.body.trim()));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      _config.authConfig = data;
      _config.hostDomain = data['host_domain'] as String?;

      // Override host_domain from brand config if provided
      final domainOverride = SbConfig.instance.domainOverride;
      if (domainOverride.hasHostDomainOverride) {
        _config.hostDomain = domainOverride.hostDomain;
      }

      print(
        '[AuthConfigService] Config loaded - hostDomain: ${_config.hostDomain}',
      );
    } else {
      throw Exception('Failed to load config: ${response.statusCode}');
    }
  }

  /// Step 2: Get Distributor ID
  /// GET: {host_domain}/distributor?command=regdis&bundle={bundleId}&appName={appName}
  Future<void> _getDistributorId() async {
    if (_config.hostDomain == null) {
      throw Exception('hostDomain is not set');
    }

    final url = _config.distributorUrl;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] == 0) {
        final responseData = data['data'] as Map<String, dynamic>;
        _config.distId = responseData['distId'] as String?;
        _config.appId = responseData['applicationId'] as String?;

        print(
          '[AuthConfigService] Distributor loaded - distId: ${_config.distId}',
        );
      } else {
        throw Exception('Failed to get distributor: ${data['message']}');
      }
    } else {
      throw Exception('Failed to get distributor: ${response.statusCode}');
    }
  }

  /// Step 3: Get ACS Config
  /// GET: {host_domain}/acs?command=get-bid&distId={distId}&versionId={versionId}&platformId={platformId}&appId={appId}
  Future<void> _getAcsConfig() async {
    if (_config.hostDomain == null ||
        _config.distId == null ||
        _config.appId == null) {
      throw Exception('Required config not set for ACS');
    }

    final url = _config.acsConfigUrl;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] == 0) {
        final responseData = data['data']['config'] as Map<String, dynamic>?;
        final services = responseData?['services'] as Map<String, dynamic>?;

        if (services != null) {
          _config.idServiceUrl = services['id'] as String?;
          _config.paygateUrl = services['paygate'] as String?;

          print(
            '[AuthConfigService] ACS loaded - idServiceUrl: ${_config.idServiceUrl}',
          );
        }
      } else {
        throw Exception('Failed to get ACS config: ${data['message']}');
      }
    } else {
      throw Exception('Failed to get ACS config: ${response.statusCode}');
    }
  }

  /// Get server time (for web platform)
  /// GET: {idServiceUrl}?command=getTime
  Future<String> getServerTime() async {
    if (_config.idServiceUrl == null) {
      // Fallback to local time
      return DateTime.now().millisecondsSinceEpoch.toString();
    }

    try {
      final url = _config.serverTimeUrl;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['status'] == 0) {
          final responseData = data['data'] as Map<String, dynamic>;
          return responseData['message'] as String? ??
              DateTime.now().millisecondsSinceEpoch.toString();
        }
      }
    } catch (e) {
      print('[AuthConfigService] Error getting server time: $e');
    }

    // Fallback to local time
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Check if config is ready for auth operations
  bool get isReady => _config.isAuthConfigReady;

  /// Get the ID service URL
  String? get idServiceUrl => _config.idServiceUrl;
}
