import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/bank_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/codepay_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/ewallet_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/card_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/crypto_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/giftcode_form_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/verify_bank_form_notifier.dart';

// ============================================================================
// Form State Providers (Per Method)
// ============================================================================

/// Bank form provider
final bankFormProvider = StateNotifierProvider<BankFormNotifier, BankFormState>(
  (ref) => BankFormNotifier(),
);

/// Codepay form provider
final codepayFormProvider =
    StateNotifierProvider<CodepayFormNotifier, CodepayFormState>(
      (ref) => CodepayFormNotifier(),
    );

/// EWallet form provider
final ewalletFormProvider =
    StateNotifierProvider<EWalletFormNotifier, EWalletFormState>(
      (ref) => EWalletFormNotifier(),
    );

/// Card (Scratch Card) form provider
final cardFormProvider = StateNotifierProvider<CardFormNotifier, CardFormState>(
  (ref) => CardFormNotifier(),
);

/// Crypto form provider
final cryptoFormProvider =
    StateNotifierProvider<CryptoFormNotifier, CryptoFormState>(
      (ref) => CryptoFormNotifier(),
    );

/// Giftcode form provider
final giftcodeFormProvider =
    StateNotifierProvider<GiftcodeFormNotifier, GiftcodeFormState>(
      (ref) => GiftcodeFormNotifier(),
    );

/// Verify bank form provider
final verifyBankFormProvider =
    StateNotifierProvider<VerifyBankFormNotifier, VerifyBankFormState>(
      (ref) => VerifyBankFormNotifier(),
    );
