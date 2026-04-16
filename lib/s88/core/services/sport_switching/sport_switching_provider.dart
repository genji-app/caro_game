import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';

import 'sport_switch_state.dart';
import 'sport_switching_config.dart';
import 'sport_switching_service.dart';

/// Provider cho SportSwitchingService
final sportSwitchingServiceProvider = Provider<SportSwitchingService>((ref) {
  // ✅ FIX: Use ref.read() - both are singletons that never change
  // Using watch() creates unnecessary listeners that accumulate over time
  final adapter = ref.read(sportSocketAdapterProvider);
  final storage = ref.read(sportStorageProvider);

  final service = SportSwitchingService(
    adapter: adapter,
    storage: storage,
    config: SportSwitchingConfig.defaultConfig,
  );

  ref.onDispose(() => service.dispose());

  return service;
});

/// Provider cho SportSwitchState stream
///
/// ✅ FIX: Use ref.read() instead of ref.watch() to prevent listener accumulation
/// - service is singleton that never changes
/// - stream handles updates internally
/// - using watch() causes provider to rebuild and create new subscriptions
final sportSwitchStateProvider = StreamProvider<SportSwitchState>((ref) {
  final service = ref.read(sportSwitchingServiceProvider);
  return service.stateStream;
});

/// Provider cho current sport ID (convenience)
///
/// ✅ FIX: Watch the state stream instead of service directly
/// This ensures updates are received when state changes
final sportSwitchCurrentSportIdProvider = Provider<int>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.currentSportId ?? 1;
});

/// Provider cho switching status (convenience)
final isSportSwitchingProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.isSwitching ?? false;
});

/// Provider cho error state (convenience)
final sportSwitchErrorProvider = Provider<String?>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.errorMessage;
});

/// Provider cho display sport ID (target nếu đang switch, current nếu không)
final displaySportIdProvider = Provider<int>((ref) {
  final asyncState = ref.watch(sportSwitchStateProvider);
  return asyncState.valueOrNull?.displaySportId ?? 1;
});
