import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import '../models/models.dart';
import '../storage/payment_config_storage.dart';

/// Provider for payment configuration data
/// This stores bank/e-wallet/crypto info and provides lookup by ID
final paymentConfigProvider =
    StateNotifierProvider<PaymentConfigNotifier, PaymentConfigState>(
      (ref) => PaymentConfigNotifier(),
    );

/// State for payment configuration
class PaymentConfigState {
  PaymentConfigState({
    this.configData,
    this.isLoading = false,
    this.error,
    Map<String, PaymentMethodInfo>? lookupMap,
  }) : _lookupMap = lookupMap ?? configData?.buildPaymentMethodMap() ?? {};

  final PaymentConfigData? configData;
  final bool isLoading;
  final String? error;
  final Map<String, PaymentMethodInfo> _lookupMap;

  /// Check if data is loaded
  bool get isLoaded => configData != null;

  /// Get payment method info by ID (O(1) lookup)
  PaymentMethodInfo? getPaymentMethodById(String? id) {
    if (id == null || id.isEmpty || configData == null) return null;
    return _lookupMap[id];
  }

  PaymentConfigState copyWith({
    PaymentConfigData? configData,
    bool? isLoading,
    String? error,
  }) {
    final newConfigData = configData ?? this.configData;
    return PaymentConfigState(
      configData: newConfigData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      // Rebuild map only if configData changed
      lookupMap: configData != null ? null : _lookupMap,
    );
  }
}

/// Notifier for payment configuration
class PaymentConfigNotifier extends StateNotifier<PaymentConfigState>
    with LoggerMixin {
  PaymentConfigNotifier() : super(PaymentConfigState());

  final _storage = PaymentConfigStorage.instance;

  /// Load from API server with cache support
  ///
  /// Strategy: Cache first, then API if cache expired/missing
  Future<void> loadFromApi(SbHttpManager httpManager) async {
    logDebug('Loading payment config...');
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Try to load from cache first
      final cachedJson = await _storage.get();
      if (cachedJson != null) {
        logInfo('Cache hit - loading from cache');
        final json = jsonDecode(cachedJson) as Map<String, dynamic>;
        final response = PaymentConfigResponse.fromJson(json);
        if (response.data != null) {
          final itemCount = response.data!.codepay?.length ?? 0;
          logInfo('Loaded $itemCount payment methods from cache');
          state = state.copyWith(configData: response.data, isLoading: false);
          return;
        }
        logWarning('Cache data invalid, falling back to API');
      } else {
        logDebug('Cache miss - fetching from API');
      }

      // 2. Cache miss or invalid → fetch from API
      logInfo('Fetching payment config from API...');
      final json =
          await httpManager.fetchBankAccounts() as Map<String, dynamic>;

      final response = PaymentConfigResponse.fromJson(json);
      if (response.data != null) {
        final itemCount = response.data!.codepay?.length ?? 0;

        // Save to cache for next time
        await _storage.save(jsonEncode(json));
        logInfo(
          'Loaded $itemCount payment methods from API and saved to cache',
        );

        state = state.copyWith(configData: response.data, isLoading: false);
      } else {
        logWarning('API returned no data');
        state = state.copyWith(isLoading: false, error: 'No data in response');
      }
    } catch (e, stackTrace) {
      logError('Failed to load payment config', e, stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Force refresh from API (ignore cache)
  Future<void> refreshFromApi(SbHttpManager httpManager) async {
    logInfo('Force refreshing from API (clearing cache)');
    await _storage.clear();
    await loadFromApi(httpManager);
  }

  /// Clear data and cache
  Future<void> clear() async {
    logInfo('Clearing payment config and cache');
    await _storage.clear();
    state = PaymentConfigState();
  }
}

/// Provider to get payment method info by ID
/// Usage: `ref.watch(paymentMethodInfoProvider(id))`
/// Returns PaymentMethodInfo with displayName, imageUrl, methodType, etc.
final paymentMethodInfoProvider = Provider.family<PaymentMethodInfo?, String?>((
  ref,
  id,
) {
  final configState = ref.watch(paymentConfigProvider);
  return configState.getPaymentMethodById(id);
});
