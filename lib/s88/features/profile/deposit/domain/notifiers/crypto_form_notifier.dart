import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';

/// Crypto form notifier - manages crypto deposit form state
/// Only manages crypto selection (no amount - amount handled in confirm screen)
class CryptoFormNotifier extends StateNotifier<CryptoFormState> {
  CryptoFormNotifier() : super(const CryptoFormState());

  /// Update selected crypto (by ID)
  void updateCrypto(String? cryptoId) {
    state = state.copyWith(
      selectedCrypto: cryptoId,
      cryptoError: cryptoId == null || cryptoId.isEmpty
          ? 'Vui lòng chọn loại tiền'
          : null,
    );
  }

  /// Validate form
  bool validate() {
    String? cryptoError;

    if (state.selectedCrypto == null || state.selectedCrypto!.isEmpty) {
      cryptoError = 'Vui lòng chọn loại tiền';
    }

    state = state.copyWith(cryptoError: cryptoError);

    return cryptoError == null;
  }

  /// Reset form
  void reset() {
    state = const CryptoFormState();
  }
}
