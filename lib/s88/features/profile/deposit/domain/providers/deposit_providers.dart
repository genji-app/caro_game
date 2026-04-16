import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/data/repositories/deposit_repository_impl.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/constants/deposit_constants.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/cashout_gift_card.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/cashout_gift_card_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/codepay_bank.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/crypto_deposit_option.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/repositories/deposit_repository.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/deposit_notifiers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/bank_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/bank_transaction_slip_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/card_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/codepay_qr_timer_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/codepay_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/crypto_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/giftcode_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/notifiers/verify_bank_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/create_code_pay_qr_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/check_code_pay_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/create_transaction_slip_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/get_crypto_address_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_bank_deposit_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_card_deposit_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_codepay_deposit_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_crypto_deposit_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_giftcode_deposit_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/verify_bank_account_usecase.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// Repository provider
final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  final httpManager = ref.read(sbHttpManagerProvider);
  return DepositRepositoryImpl(httpManager: httpManager);
});

// ============================================================================
// Options Providers (Load Data)
// ============================================================================
/// Bank list provider for bank transfer
/// Extract banks from configDepositProvider and filter only banks with accounts
/// Uses keepAlive to cache the result
final bankListNoNeedAccountProvider = FutureProvider.autoDispose<List<Bank>>((
  ref,
) async {
  // Keep provider alive to cache the result
  ref.keepAlive();

  // Wait for configDepositProvider to finish loading
  final depositData = await ref.read(configDepositProvider.future);

  // Filter only BankAccountItems that have accounts (non-empty)
  final banksWithAccounts = depositData.items
      .map(
        (BankAccountItem item) => Bank(
          id: item.id,
          name: item.name,
          iconUrl: item.url.isNotEmpty ? item.url : null,
        ),
      )
      .toList();

  return banksWithAccounts;
});

/// Bank list provider for bank transfer
/// Extract banks from configDepositProvider and filter only banks with accounts
/// Uses keepAlive to cache the result
final bankListProvider = FutureProvider.autoDispose<List<Bank>>((ref) async {
  // Keep provider alive to cache the result
  ref.keepAlive();

  // Wait for configDepositProvider to finish loading
  final depositData = await ref.read(configDepositProvider.future);

  // Filter only BankAccountItems that have accounts (non-empty)
  final banksWithAccounts = depositData.items
      .where((BankAccountItem item) => item.accounts.isNotEmpty)
      .map(
        (BankAccountItem item) => Bank(
          id: item.id,
          name: item.name,
          iconUrl: item.url.isNotEmpty ? item.url : null,
        ),
      )
      .toList();

  return banksWithAccounts;
});

/// Config deposit provider with caching
/// This provider fetches deposit configuration and caches it to avoid unnecessary API calls
/// Uses keepAlive to maintain cache across widget rebuilds
final configDepositProvider = FutureProvider.autoDispose<FetchBankAccountsData>(
  (ref) async {
    // Keep provider alive to cache the result
    ref.keepAlive();

    final repository = ref.read(depositRepositoryProvider);
    final result = await repository.getConfigDeposit();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );
  },
);

/// Wallet list provider for e-wallet
/// Gets wallets from cashoutGiftCards with bankType=2
final walletListProvider = FutureProvider<List<CodepayBank>>((ref) async {
  final depositData = await ref.read(configDepositProvider.future);

  // Filter cashoutGiftCards with bankType=2 (e-wallet)
  final eWallets = depositData.codepay
      .where((CodepayBank item) => item.bankType == BankType.eWallet)
      .toList();
  return eWallets;
});

/// Card type list provider for scratch card
/// Gets card types from cashoutGiftCards based on name
final cardTypeListProvider = FutureProvider<List<CashoutGiftCard>>((ref) async {
  final depositData = await ref.read(configDepositProvider.future);

  // Extract card type names from cashoutGiftCards
  return depositData.cashoutGiftCards;
});

/// Denomination list provider for scratch card (family provider)
/// Gets denominations from items of selected card type
/// Pass card type name as parameter, returns empty list if null
///
/// Performance: Uses ref.watch() with cached provider (keepAlive: true)
/// Only rebuilds when data actually changes, not on every widget rebuild
final denominationListProvider = Provider.family<List<String>, String?>((
  ref,
  cardTypeName,
) {
  if (cardTypeName == null || cardTypeName.isEmpty) {
    return [];
  }

  // Watch configDepositProvider but only rebuild when data changes
  // Since configDepositProvider is cached with keepAlive, this won't cause unnecessary rebuilds
  final depositDataAsync = ref.watch(configDepositProvider);

  return depositDataAsync.when(
    data: (depositData) {
      // Find the selected card by name
      try {
        final selectedCard = depositData.cashoutGiftCards.firstWhere(
          (CashoutGiftCard card) => card.name == cardTypeName,
        );

        // Extract denominations from items (format amount with commas)
        final denominations =
            selectedCard.items
                .where(
                  (CashoutGiftCardItem item) => item.active,
                ) // Only active items
                .map((CashoutGiftCardItem item) => _formatAmount(item.amount))
                .toSet() // Remove duplicates
                .toList()
              ..sort((String a, String b) {
                // Sort by numeric value
                final aValue = int.tryParse(a.replaceAll(',', '')) ?? 0;
                final bValue = int.tryParse(b.replaceAll(',', '')) ?? 0;
                return aValue.compareTo(bValue);
              });

        return denominations;
      } catch (e) {
        // Card not found, return empty list
        return [];
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Helper function to format amount with commas
/// Uses simple string manipulation for better performance and memory efficiency
/// Example: 10000 -> "10,000", 500000 -> "500,000", 86548696 -> "86,548,696"
///
/// Memory efficient: O(n) time and space complexity where n is number of digits
/// Safe for large numbers (up to int max value: 9,223,372,036,854,775,807)
String _formatAmount(int amount) {
  if (amount < 0) {
    return '-${_formatAmount(-amount)}';
  }

  final amountStr = amount.toString();
  final length = amountStr.length;

  // No need to format if 3 digits or less
  if (length <= 3) {
    return amountStr;
  }

  // Use StringBuffer for efficient string building (avoid string concatenation)
  final buffer = StringBuffer();

  // Build formatted string from left to right
  // Insert comma after every 3 digits from the right
  final remainder = length % 3;
  final firstGroupSize = remainder == 0 ? 3 : remainder;

  // Write first group
  buffer.write(amountStr.substring(0, firstGroupSize));

  // Write remaining groups with commas
  for (int i = firstGroupSize; i < length; i += 3) {
    buffer.write(',');
    buffer.write(amountStr.substring(i, i + 3));
  }

  return buffer.toString();
}

/// Helper function to format price with currency symbol
/// Example: 86548696 -> "₫86,548,696"
String _formatPrice(int price) {
  final formatted = _formatAmount(price);
  return '$formatted';
}

/// Crypto list provider
/// Gets crypto options from configDepositProvider.crypto
/// Maps CryptoDepositOption to CryptoOption format
/// Display format: crypto[i].name - depositNetworks[j]
final cryptoListProvider = FutureProvider<List<CryptoOption>>((ref) async {
  try {
    final depositData = await ref.read(configDepositProvider.future);

    if (depositData.crypto.isEmpty) {
      return [];
    }

    final cryptoOptions = <CryptoOption>[];
    for (final CryptoDepositOption crypto in depositData.crypto) {
      final networks = crypto.depositNetworks.isEmpty
          ? [crypto.network]
          : crypto.depositNetworks;

      if (networks.isEmpty) {
        continue;
      }

      for (final String network in networks) {
        if (network.isEmpty) {
          continue;
        }

        cryptoOptions.add(
          CryptoOption(
            id: '${crypto.bankId}-${crypto.currencyName.toLowerCase()}-${network.toLowerCase()}',
            name: crypto.currencyName,
            network: network,
            iconPath: AppIcons.icPaymentCrypto,
            price: _formatPrice(crypto.exchangeRate),
          ),
        );
      }
    }

    return cryptoOptions;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('cryptoListProvider error: $e');
    }
    return [];
  }
});

// ============================================================================
// Use Cases Providers
// ============================================================================

/// Submit card deposit use case provider
final submitCardDepositUseCaseProvider = Provider<SubmitCardDepositUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return SubmitCardDepositUseCase(repository);
});

/// Submit bank deposit use case provider
final submitBankDepositUseCaseProvider = Provider<SubmitBankDepositUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return SubmitBankDepositUseCase(repository);
});

/// Submit codepay deposit use case provider
final submitCodepayDepositUseCaseProvider =
    Provider<SubmitCodepayDepositUseCase>((ref) {
      final repository = ref.read(depositRepositoryProvider);
      return SubmitCodepayDepositUseCase(repository);
    });

/// Submit crypto deposit use case provider
final submitCryptoDepositUseCaseProvider = Provider<SubmitCryptoDepositUseCase>(
  (ref) {
    final repository = ref.read(depositRepositoryProvider);
    return SubmitCryptoDepositUseCase(repository);
  },
);

/// Submit giftcode deposit use case provider
final submitGiftcodeDepositUseCaseProvider =
    Provider<SubmitGiftcodeDepositUseCase>((ref) {
      final repository = ref.read(depositRepositoryProvider);
      return SubmitGiftcodeDepositUseCase(repository);
    });

/// Use case: verify bank account
final verifyBankAccountUseCaseProvider = Provider<VerifyBankAccountUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return VerifyBankAccountUseCase(repository);
});

/// Create code pay QR use case provider
final createCodePayQrUseCaseProvider = Provider<CreateCodePayQrUseCase>((ref) {
  final repository = ref.read(depositRepositoryProvider);
  return CreateCodePayQrUseCase(repository);
});

/// Check code pay use case provider
final checkCodePayUseCaseProvider = Provider<CheckCodePayUseCase>((ref) {
  final repository = ref.read(depositRepositoryProvider);
  return CheckCodePayUseCase(repository);
});

/// Get crypto address use case provider
final getCryptoAddressUseCaseProvider = Provider<GetCryptoAddressUseCase>((
  ref,
) {
  final repository = ref.read(depositRepositoryProvider);
  return GetCryptoAddressUseCase(repository);
});

/// Create transaction slip use case provider
final createTransactionSlipUseCaseProvider =
    Provider<CreateTransactionSlipUseCase>((ref) {
      final repository = ref.read(depositRepositoryProvider);
      return CreateTransactionSlipUseCase(repository);
    });

// ============================================================================
// Selection Provider (Main Orchestrator)
// ============================================================================

/// Deposit selection provider
final depositSelectionProvider =
    StateNotifierProvider<DepositSelectionNotifier, DepositSelectionState>(
      (ref) => DepositSelectionNotifier(),
    );

// ============================================================================
// Submit Providers (Per Method)
// ============================================================================

/// Bank submit notifier provider
final bankSubmitNotifierProvider =
    StateNotifierProvider<BankSubmitNotifier, BankSubmitState>((ref) {
      final submitBankDepositUseCase = ref.read(
        submitBankDepositUseCaseProvider,
      );
      return BankSubmitNotifier(submitBankDepositUseCase);
    });

/// Bank transaction slip notifier provider
final bankTransactionSlipNotifierProvider =
    StateNotifierProvider<
      BankTransactionSlipNotifier,
      BankTransactionSlipState
    >((ref) {
      final createTransactionSlipUseCase = ref.read(
        createTransactionSlipUseCaseProvider,
      );
      return BankTransactionSlipNotifier(createTransactionSlipUseCase);
    });

/// Codepay submit notifier provider
final codepaySubmitNotifierProvider =
    StateNotifierProvider<CodepaySubmitNotifier, CodepaySubmitState>((ref) {
      final submitCodepayDepositUseCase = ref.read(
        submitCodepayDepositUseCaseProvider,
      );
      final createCodePayQrUseCase = ref.read(createCodePayQrUseCaseProvider);
      return CodepaySubmitNotifier(
        submitCodepayDepositUseCase,
        createCodePayQrUseCase,
      );
    });

/// Crypto submit notifier provider
final cryptoSubmitNotifierProvider =
    StateNotifierProvider<CryptoSubmitNotifier, CryptoSubmitState>((ref) {
      final submitCryptoDepositUseCase = ref.read(
        submitCryptoDepositUseCaseProvider,
      );
      final getCryptoAddressUseCase = ref.read(getCryptoAddressUseCaseProvider);
      return CryptoSubmitNotifier(
        submitCryptoDepositUseCase,
        getCryptoAddressUseCase,
      );
    });

/// Card submit notifier provider
final cardSubmitNotifierProvider =
    StateNotifierProvider<CardSubmitNotifier, CardSubmitState>((ref) {
      final submitCardDepositUseCase = ref.read(
        submitCardDepositUseCaseProvider,
      );
      return CardSubmitNotifier(submitCardDepositUseCase);
    });

/// Giftcode submit notifier provider
final giftcodeSubmitNotifierProvider =
    StateNotifierProvider<GiftcodeSubmitNotifier, GiftcodeSubmitState>((ref) {
      final submitGiftcodeDepositUseCase = ref.read(
        submitGiftcodeDepositUseCaseProvider,
      );
      return GiftcodeSubmitNotifier(submitGiftcodeDepositUseCase);
    });

/// Verify bank submit notifier provider
final verifyBankSubmitNotifierProvider =
    StateNotifierProvider<VerifyBankSubmitNotifier, VerifyBankSubmitState>((
      ref,
    ) {
      final useCase = ref.read(verifyBankAccountUseCaseProvider);
      return VerifyBankSubmitNotifier(ref, useCase);
    });

// ============================================================================
// Timer Providers
// ============================================================================

/// Codepay QR timer provider (family provider - takes initial milliseconds)
/// Uses autoDispose to automatically cleanup timer when not in use
/// Timer is initialized with remainingTime from codepayCreateResponse
/// Note: remainingTime is in milliseconds, will be converted to seconds internally
final codepayQrTimerProvider = StateNotifierProvider.autoDispose
    .family<CodepayQrTimerNotifier, CodepayQrTimerState, int>((
      ref,
      initialMilliseconds,
    ) {
      // Create timer with remainingTime from response (in milliseconds)
      // Timer will convert to seconds internally
      // Note: StateNotifierProvider automatically calls dispose() on the notifier
      // when the provider is disposed, so we don't need ref.onDispose()
      return CodepayQrTimerNotifier(initialMilliseconds);
    });
