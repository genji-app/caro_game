import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/create_code_pay_qr_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/usecases/submit_codepay_deposit_usecase.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_storage.dart';

/// Codepay submit notifier - manages codepay deposit submission
/// Uses UseCases to separate business logic from state management
class CodepaySubmitNotifier extends StateNotifier<CodepaySubmitState> {
  final SubmitCodepayDepositUseCase _submitCodepayDepositUseCase;
  final CreateCodePayQrUseCase _createCodePayQrUseCase;
  CodepayCreateQrResponse? _codepayCreateResponse;

  CodepaySubmitNotifier(
    this._submitCodepayDepositUseCase,
    this._createCodePayQrUseCase,
  ) : super(const CodepaySubmitState.idle());

  /// Get last QR response from the last successful createCodePay call
  CodepayCreateQrResponse? get codepayCreateResponse => _codepayCreateResponse;

  /// Submit codepay deposit
  Future<void> submit(CodepayDepositRequest request) async {
    state = const CodepaySubmitState.submitting();

    // Use UseCase for business logic
    final result = await _submitCodepayDepositUseCase(request);

    result.fold(
      (failure) => state = CodepaySubmitState.error(failure.message),
      (response) => state = const CodepaySubmitState.success(),
    );
  }

  /// Create Codepay QR code
  ///
  /// [request] - Codepay create QR request
  /// [paymentMethod] - Payment method (default: codepay, can be eWallet for MoMo)
  /// [walletName] - Optional wallet name for eWallet (e.g., "MoMo", "ViettelPay")
  Future<void> createCodePay(
    CodepayCreateQrRequest request, {
    PaymentMethod paymentMethod = PaymentMethod.codepay,
    String? walletName,
  }) async {
    state = const CodepaySubmitState.submitting();

    // Use UseCase for business logic
    final result = await _createCodePayQrUseCase(request);

    result.fold(
      (failure) => state = CodepaySubmitState.error(failure.message),
      (response) async {
        _codepayCreateResponse = response;
        state = const CodepaySubmitState.success();
        // Get current user ID to isolate storage per user
        final userId = SbHttpManager.instance.custId;
        if (userId.isNotEmpty) {
          await DepositStorage.saveCodepayResponse(
            response,
            userId: userId,
            paymentMethod: paymentMethod,
            walletName: walletName,
          );
        }
      },
    );
  }

  /// Reset submit state
  void reset() {
    state = const CodepaySubmitState.idle();
    _codepayCreateResponse = null;
  }
}
