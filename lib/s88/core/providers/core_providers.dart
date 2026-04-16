import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/network/api_client.dart';
import 'package:co_caro_flame/s88/core/network/network_info.dart';

// ============================================================================
// Core Infrastructure Providers
// These providers are used across the entire app
// ============================================================================

/// API Client provider
/// Provides a configured Dio client for HTTP requests
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Connectivity provider
/// Provides access to connectivity checking
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Network Info provider
/// Checks if device has internet connection
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});
