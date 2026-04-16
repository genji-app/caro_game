import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';

// Conditionally import device_info_plus only for non-web platforms
import 'device_info_service_stub.dart'
    if (dart.library.io) 'device_info_service_io.dart';

/// Service for getting device information
class DeviceInfoService {
  DeviceInfoService._();

  static final DeviceInfoService _instance = DeviceInfoService._();
  static DeviceInfoService get instance => _instance;

  String? _deviceId;
  String? _osVersion;

  /// Get or generate device ID
  /// Device ID is persisted in SharedPreferences
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(SbConfig.deviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate new device ID (20 chars)
      deviceId = const Uuid().v4().replaceAll('-', '').substring(0, 20);
      await prefs.setString(SbConfig.deviceIdKey, deviceId);
    }

    _deviceId = deviceId;
    return deviceId;
  }

  /// Get OS version string
  Future<String> getOsVersion() async {
    if (_osVersion != null) return _osVersion!;

    if (kIsWeb) {
      _osVersion = 'Web';
      return _osVersion!;
    }

    _osVersion = await getDeviceOsVersion();
    return _osVersion!;
  }

  /// Reset cached values
  void reset() {
    _deviceId = null;
    _osVersion = null;
  }
}
