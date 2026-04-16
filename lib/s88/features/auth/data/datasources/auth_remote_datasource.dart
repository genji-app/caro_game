import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:co_caro_flame/s88/core/services/auth/auth_config_service.dart';
import 'package:co_caro_flame/s88/core/services/auth/device_info_service.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';
import 'package:co_caro_flame/s88/core/utils/hash_utils.dart';
import 'package:co_caro_flame/s88/features/auth/data/models/auth_model.dart';

/// Remote data source for authentication
/// Implements login/register with MD5 hash based on Cocos Creator specs
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> submitOtp(OtpRequestModel request);
  Future<UsernameCheckResult> checkUsernameAvailable(String username);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
}

/// Username availability check result
enum UsernameCheckResult { available, taken, existsOnOtherBrand }

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthConfigService _configService = AuthConfigService.instance;
  final DeviceInfoService _deviceService = DeviceInfoService.instance;
  final SbConfig _config = SbConfig.instance;

  AuthRemoteDataSourceImpl();

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    // Ensure config is ready
    if (!_configService.isReady) {
      throw Exception('Auth config not initialized');
    }

    // Get device info
    // deviceId: empty on web, actual device ID on native
    final deviceId = kIsWeb ? '' : await _deviceService.getDeviceId();
    final osVersion = await _deviceService.getOsVersion();
    final platformId = SbConfig.platformId;

    // Prepare data
    final usernameLC = request.username.toLowerCase();
    const displayName = ''; // Empty for login

    // Create hash using new formula:
    // MD5(username + password + displayName + platformId + advId + deviceId + osVersion + bundleId + brand + secretKey)
    final hash = HashUtils.createAuthHashSS(
      username: usernameLC,
      password: request.password,
      displayName: displayName,
      platformId: platformId,
      advId: '', // Always empty
      deviceId: deviceId,
      osVersion: osVersion,
      bundleId: SbConfig.bundleId,
      brand: SbConfig.authBrand,
      secretKey: SbConfig.secretKey,
    );

    // Build request body for loginHashSS
    final body = <String, dynamic>{
      'command': 'loginHashSS',
      'username': usernameLC,
      'password': request.password,
      'displayName': displayName,
      'platformId': platformId,
      'advId': '',
      'deviceId': deviceId,
      'os': osVersion,
      'alsoLogin': true,
      'hash': hash,
      'bundle': SbConfig.bundleId,
      'brand': SbConfig.authBrand,
    };

    // Call API - idServiceUrl directly, no additional path
    final response = await http.post(
      Uri.parse(_config.idServiceUrl!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    // Ensure config is ready
    if (!_configService.isReady) {
      throw Exception('Auth config not initialized');
    }

    // Get device info
    // deviceId: empty on web, actual device ID on native
    final deviceId = kIsWeb ? '' : await _deviceService.getDeviceId();
    final osVersion = await _deviceService.getOsVersion();
    final platformId = SbConfig.platformId;

    // Prepare data
    final usernameLC = request.username.toLowerCase();
    final displayNameLC = request.displayName.toLowerCase();

    // Create hash using new formula:
    // MD5(username + password + displayName + platformId + advId + deviceId + osVersion + bundleId + brand + secretKey)
    final hash = HashUtils.createAuthHashSS(
      username: usernameLC,
      password: request.password,
      displayName: displayNameLC,
      platformId: platformId,
      advId: '', // Always empty
      deviceId: deviceId,
      osVersion: osVersion,
      bundleId: SbConfig.bundleId,
      brand: SbConfig.authBrand,
      secretKey: SbConfig.secretKey,
    );

    // Build request body for registerHashSS
    final body = <String, dynamic>{
      'command': 'registerHashSS',
      'username': usernameLC,
      'password': request.password,
      'displayName': displayNameLC,
      'platformId': platformId,
      'advId': '',
      'deviceId': deviceId,
      'os': osVersion,
      'alsoLogin': true, // Auto login after register
      'hash': hash,
      'bundle': SbConfig.bundleId,
      'brand': SbConfig.authBrand,
    };

    // Add tracking params if provided
    if (request.affId != null) body['affId'] = request.affId;
    if (request.utmSource != null) body['utmSource'] = request.utmSource;
    if (request.utmMedium != null) body['utmMedium'] = request.utmMedium;
    if (request.utmCampaign != null) body['utmCampaign'] = request.utmCampaign;
    if (request.utmContent != null) body['utmContent'] = request.utmContent;
    if (request.utmTerm != null) body['utmTerm'] = request.utmTerm;

    // Call API - idServiceUrl directly, no additional path
    final response = await http.post(
      Uri.parse(_config.idServiceUrl!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('Register failed: ${response.statusCode}');
    }
  }

  @override
  Future<AuthResponseModel> submitOtp(OtpRequestModel request) async {
    // Ensure config is ready
    if (!_configService.isReady) {
      throw Exception('Auth config not initialized');
    }

    // Create hash
    final hash = HashUtils.createOtpHash(
      sessionId: request.sessionId,
      otp: request.otp,
      hsk: SbConfig.hsk,
    );

    final body = {
      'command': 'submitOTP',
      'sessionId': request.sessionId,
      'otp': request.otp,
      'hash': hash,
    };

    // Call API
    final response = await http.post(
      Uri.parse(_config.idServiceUrl!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('OTP verification failed: ${response.statusCode}');
    }
  }

  @override
  Future<UsernameCheckResult> checkUsernameAvailable(String username) async {
    // Ensure config is ready
    if (!_configService.isReady) {
      throw Exception('Auth config not initialized');
    }

    // Create hash
    final hash = HashUtils.createCheckUsernameHash(
      username: username.toLowerCase(),
      brand: SbConfig.brand,
      hsk: SbConfig.hsk,
    );

    final body = {
      'command': 'checkUserByUsernameOnWeb',
      'username': username.toLowerCase(),
      'brand': SbConfig.brand,
      'hash': hash,
    };

    // Call API
    final response = await http.post(
      Uri.parse(_config.idServiceUrl!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final status = data['status'] as int?;

      switch (status) {
        case 0:
          return UsernameCheckResult.available;
        case 309:
          return UsernameCheckResult.existsOnOtherBrand;
        default:
          return UsernameCheckResult.taken;
      }
    } else {
      throw Exception('Check username failed: ${response.statusCode}');
    }
  }

  @override
  Future<void> logout() async {
    // For this API, logout is just clearing local tokens
    // No server API call needed
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    // Ensure config is ready
    if (!_configService.isReady) {
      throw Exception('Auth config not initialized');
    }

    final url =
        '${_config.idServiceUrl}?command=refreshToken&refreshToken=$refreshToken';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } else {
      throw Exception('Token refresh failed: ${response.statusCode}');
    }
  }
}
