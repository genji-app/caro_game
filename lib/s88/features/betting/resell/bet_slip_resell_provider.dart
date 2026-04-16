// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/providers/providers.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

import 'bet_slip_resell_notifier.dart';

final betResellProvider =
    StateNotifierProvider<BetResellNotifier, BetResellState>((ref) {
      final repository = ref.watch(myBetRepositoryProvider);
      return BetResellNotifier(repository);
    });

final betResellControllerProvider = Provider((ref) {
  return (WidgetRef ref) => BetResellController(ref);
});

/// A controller to manage the UI flow of reselling a ticket
class BetResellController {
  BetResellController(this.ref);
  final WidgetRef ref;

  /// Execute resell and show toast based on result
  /// Returns true if successful, false otherwise
  Future<bool> startResellFlow(BuildContext context, BetSlip bet) async {
    // Reset state before starting new flow
    ref.read(betResellProvider.notifier).reset();

    // Execute resell
    await ref.read(betResellProvider.notifier).resell(bet);

    // Check result and show toast
    final state = ref.read(betResellProvider);

    return state.maybeWhen(
      success: (_, __) {
        _showSuccessToast(context);
        ref.read(userProvider.notifier).refreshBalance();
        return true;
      },
      error: (_, message) {
        _showErrorToast(context, message);
        return false;
      },
      orElse: () => false,
    );
  }

  void _showSuccessToast(BuildContext context) {
    if (!context.mounted) return;
    AppToast.showSuccess(
      context,
      message: '${I18n.txtSellTicket} ${I18n.txtSuccess}',
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showError(
      context,
      message: '${I18n.txtSellTicket} ${I18n.txtFailure}: $message',
    );
  }
}
