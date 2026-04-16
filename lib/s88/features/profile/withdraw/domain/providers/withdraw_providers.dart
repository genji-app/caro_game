import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/data/repositories/withdraw_repository_impl.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/notifiers/crypto_withdraw_submit_notifier.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/repositories/withdraw_repository.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/usecases/submit_withdraw_bank_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/usecases/submit_withdraw_card_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/usecases/submit_withdraw_crypto_usecase.dart';

// ============================================================================
// Repository Provider
// ============================================================================

/// Withdraw repository provider
final withdrawRepositoryProvider = Provider<WithdrawRepository>((ref) {
  return WithdrawRepositoryImpl();
});

// ============================================================================
// Usecase Providers
// ============================================================================

/// Submit bank withdraw usecase provider
final submitWithdrawBankUseCaseProvider = Provider<SubmitWithdrawBankUseCase>((
  ref,
) {
  final repository = ref.read(withdrawRepositoryProvider);
  return SubmitWithdrawBankUseCase(repository);
});

/// Submit card withdraw usecase provider
final submitWithdrawCardUseCaseProvider = Provider<SubmitWithdrawCardUseCase>((
  ref,
) {
  final repository = ref.read(withdrawRepositoryProvider);
  return SubmitWithdrawCardUseCase(repository);
});

/// Submit crypto withdraw usecase provider
final submitWithdrawCryptoUseCaseProvider =
    Provider<SubmitWithdrawCryptoUseCase>((ref) {
      final repository = ref.read(withdrawRepositoryProvider);
      return SubmitWithdrawCryptoUseCase(repository);
    });

// ============================================================================
// Notifier Providers
// ============================================================================

/// Crypto withdraw submit notifier provider
final cryptoWithdrawSubmitNotifierProvider =
    StateNotifierProvider.autoDispose<
      CryptoWithdrawSubmitNotifier,
      CryptoWithdrawSubmitState
    >((ref) {
      final useCase = ref.read(submitWithdrawCryptoUseCaseProvider);
      return CryptoWithdrawSubmitNotifier(useCase);
    });
