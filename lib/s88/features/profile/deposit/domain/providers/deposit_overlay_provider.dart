import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';

/// Provider for controlling deposit overlay visibility on web/tablet
final depositOverlayVisibleProvider = StateProvider<bool>((ref) => false);
final codepayTransferOverlayVisibleProvider = StateProvider<bool>(
  (ref) => false,
);

/// Override state for needVerifyBankAccount (set to false when user verifies successfully)
/// This overrides the value from API to avoid re-verification after successful verification
final needVerifyBankAccountOverrideProvider = StateProvider<bool?>(
  (ref) => null,
);

/// Computed provider for needVerifyBankAccount
/// Returns override value if set, otherwise returns value from configDepositProvider
/// This allows immediate update when user verifies successfully, even if API hasn't refreshed yet
final needVerifyBankAccountProvider = Provider<bool>((ref) {
  // Check if there's an override (set to false after successful verification)
  final override = ref.watch(needVerifyBankAccountOverrideProvider);
  if (override != null) {
    return override;
  }

  // Otherwise, get from API config
  final depositDataAsync = ref.watch(configDepositProvider);
  return depositDataAsync.maybeWhen(
    data: (data) => data.needVerifyBankAccount,
    orElse: () =>
        true, // Default to true (require verification) if data not loaded yet
  );
});
