import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/codepay_bank.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/check_codepay_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_form_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/payment_util.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/verify_bank_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/verify_bank_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/ewallet/ewallet_confirm_money_transfer_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/ewallet_confirm_money_transfer_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/codepay_transfer_section.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/amount_input_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_field.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

/// Container for E-Wallet payment method form
class EWalletContainer extends ConsumerStatefulWidget {
  const EWalletContainer({super.key});

  @override
  ConsumerState<EWalletContainer> createState() => _EWalletContainerState();
}

class _EWalletContainerState extends ConsumerState<EWalletContainer> {
  final TextEditingController _amountController = TextEditingController();
  CodepayCreateQrResponse? _savedResponse;
  String?
  _lastCheckedWalletName; // Track last checked wallet to avoid duplicate calls

  @override
  void initState() {
    super.initState();
    // Listen to amount changes to sync with provider
    _amountController.addListener(() {
      ref
          .read(ewalletFormProvider.notifier)
          .updateAmount(_amountController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(ewalletFormProvider);
    final walletsAsync = ref.watch(walletListProvider);
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    // Listen to submit state changes
    ref.listen<CodepaySubmitState>(codepaySubmitNotifierProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(
        success: () => _handleSubmitSuccess(),
        error: (message) => _handleSubmitError(message),
        orElse: () {},
      );
    });

    if (_savedResponse != null) {
      final timerState = ref.watch(
        codepayQrTimerProvider(_savedResponse!.remainingTime),
      );
      if (timerState.isExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkSavedResponseAfterExpiry(formState, walletsAsync);
          }
        });
      }
    }

    final hasValidSavedResponse = _savedResponse != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                walletsAsync.when(
                  data: (wallets) =>
                      _buildWalletSelectionForm(formState, wallets),
                  loading: () => _buildWalletSelectionForm(formState, []),
                  error: (_, __) => _buildWalletSelectionForm(formState, []),
                ),
                const SizedBox(height: 24),
                if (hasValidSavedResponse)
                  CodepayTransferSection(
                    qrResponse: _savedResponse!,
                    paymentMethod: PaymentMethod.eWallet,
                    layout: deviceType == DeviceType.mobile
                        ? CodepayTransferLayout.mobile
                        : CodepayTransferLayout.web,
                  )
                else
                  AmountInputSection(
                    label: 'Số tiền',
                    controller: _amountController,
                    placeholder: 'Nhập số tiền',
                    quickAmountButtons:
                        DefaultQuickAmountButtons.defaultAmounts,
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Bottom button (fixed)
        if (!hasValidSavedResponse) _buildBottomButton(formState),
      ],
    );
  }

  /// Wallet selection form
  Widget _buildWalletSelectionForm(
    EWalletFormState formState,
    List<CodepayBank> wallets,
  ) {
    if (wallets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có ví điện tử nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    }

    // Auto-select first wallet if not selected
    if (formState.selectedWallet == null && wallets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final firstWalletName = wallets.first.name;
          ref.read(ewalletFormProvider.notifier).updateWallet(firstWalletName);
          _checkSavedResponse(wallets, firstWalletName);
        }
      });
    } else if (formState.selectedWallet != null) {
      // Load saved response khi đã có selectedWallet (khi mở lại widget)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkSavedResponse(wallets, formState.selectedWallet);
        }
      });
    }

    // Convert wallets to menu items
    final menuItems = wallets.map((wallet) {
      // Determine icon path based on wallet name
      // Note: AppIcons returns network URLs, so use iconUrl
      final iconPath = PaymentUtil.getIconPayment(name: wallet.name);

      return SelectionMenuItem(
        value: wallet.name,
        label: wallet.name,
        iconUrl: iconPath,
      );
    }).toList();

    return SelectionField(
      label: 'Chọn ví',
      placeholder: 'Chọn ví',
      selectedValue: formState.selectedWallet,
      errorMessage: formState.walletError,
      items: menuItems,
      onSelected: (value) {
        ref.read(ewalletFormProvider.notifier).updateWallet(value);
        _checkSavedResponse(wallets, value);
      },
      iconStyle: SelectionIconStyle.defaultStyle,
    );
  }

  Future<void> _checkSavedResponse(
    List<CodepayBank> wallets,
    String? selectedWalletName,
  ) async {
    if (selectedWalletName == null) {
      _lastCheckedWalletName = null;
      setState(() {
        _savedResponse = null;
      });
      return;
    }

    // Avoid duplicate calls for the same wallet
    if (_lastCheckedWalletName == selectedWalletName) {
      return;
    }
    _lastCheckedWalletName = selectedWalletName;

    // Find wallet by name
    final selectedWallet = wallets.firstWhere(
      (wallet) => wallet.name == selectedWalletName,
      orElse: () => wallets.first,
    );

    // Check if wallet has accounts
    if (selectedWallet.accounts.isEmpty) {
      setState(() {
        _savedResponse = null;
      });
      return;
    }

    final firstAccount = selectedWallet.accounts.first;
    final bankAccountId = firstAccount.bankId;

    // Always call checkCodePay API when item is selected
    final checkRequest = CheckCodePayRequest(
      bankAccountId: bankAccountId,
      bankId: selectedWallet.id,
      type: 'cc_v363', // Hardcoded type as per requirement
    );

    final checkUseCase = ref.read(checkCodePayUseCaseProvider);
    final result = await checkUseCase(checkRequest);

    result.fold(
      (failure) {
        // If check fails (not found or error), set to null
        // This is expected if no QR code was created before
        if (mounted) {
          setState(() {
            _savedResponse = null;
          });
        }
      },
      (response) {
        // If found, use it directly (don't save to local storage)
        // Local storage is only saved when createCodePay succeeds
        if (mounted) {
          setState(() {
            _savedResponse = response;
          });
        }
      },
    );
  }

  void _checkSavedResponseAfterExpiry(
    EWalletFormState formState,
    AsyncValue<List<CodepayBank>> walletsAsync,
  ) {
    walletsAsync.whenData((wallets) {
      if (wallets.isEmpty || formState.selectedWallet == null) {
        setState(() {
          _savedResponse = null;
        });
        return;
      }

      // When expired, call API again instead of checking local storage
      _checkSavedResponse(wallets, formState.selectedWallet);
    });
  }

  /// Submit button with enable/disable states from Figma design
  Widget _buildBottomButton(EWalletFormState formState) {
    final submitState = ref.watch(codepaySubmitNotifierProvider);

    // Disable if submitting
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );

    final isEnabled = formState.isValid && !isSubmitting;

    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Nạp tiền',
      isEnabled: isEnabled,
      onTap: () => _handleSubmit(formState),
    );
  }

  /// Handle submit button tap
  Future<void> _handleSubmit(EWalletFormState formState) async {
    // Validate form
    if (!ref.read(ewalletFormProvider.notifier).validate()) {
      return;
    }

    // Get wallets from provider and find the selected wallet
    final walletsAsync = ref.read(walletListProvider.future);
    final wallets = await walletsAsync;
    final selectedWalletName = formState.selectedWallet;

    if (selectedWalletName == null || selectedWalletName.isEmpty) {
      return;
    }

    // Find the CodepayBank object by name
    final selectedWallet = wallets.firstWhere(
      (wallet) => wallet.name == selectedWalletName,
      orElse: () => wallets.first,
    );

    // Check if wallet has accounts
    if (selectedWallet.accounts.isEmpty) {
      if (mounted) {
        AppToast.showError(context, message: 'Ví không có tài khoản');
      }
      return;
    }

    // Get first account's id for bankAccountId
    final firstAccount = selectedWallet.accounts.first;
    final bankAccountId = firstAccount.id;

    // Parse amount
    final amountText = formState.amount.replaceAll(',', '').replaceAll('.', '');
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      if (mounted) {
        AppToast.showError(context, message: 'Số tiền không hợp lệ');
      }
      return;
    }

    // Check if bank account verification is required
    final needVerify = ref.read(needVerifyBankAccountProvider);

    if (needVerify) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final navigator = DepositNavigator();

      await navigator.push(
        context: rootContext,
        mobileShowMethod: (ctx) =>
            VerifyBankBottomSheet.show(ctx, selectedBankId: selectedWallet.id),
        webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
          context: ctx,
          builder: (dialogContext, animation, secondaryAnimation) =>
              VerifyBankOverlay(selectedBankId: selectedWallet.id),
        ),
        showPreviousDialog: (rootContext, deviceType) async {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          if (deviceType == DeviceType.mobile) {
            await DepositMobileBottomSheet.show(rootContext);
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.eWallet);
            }
          } else {
            container.read(depositOverlayVisibleProvider.notifier).state = true;
            await Future<void>.delayed(const Duration(milliseconds: 100));
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.eWallet);
            }
          }
        },
      );

      // After verification, stop here so user can re-submit
      return;
    }

    // Create request and call API through notifier
    final request = CodepayCreateQrRequest(
      bankId: selectedWallet.id,
      amount: amount,
      bankAccountId: bankAccountId,
    );

    debugPrint('selectedWallet.id: ${selectedWallet.id}');
    debugPrint('bankAccountId: $bankAccountId');
    debugPrint('amount: $amount');

    // https://api1.azhkthg1.net/paygate?command=createCodePay&
    // bankAccountId=5c7cd8d337ce56e0113c7f46&
    // amount=111111&
    // bankId=5c7cd8d337ce56e0113c7f46
    // Call provider to create QR code
    // EWallet: truyền PaymentMethod.eWallet và walletName
    await ref
        .read(codepaySubmitNotifierProvider.notifier)
        .createCodePay(
          request,
          paymentMethod: PaymentMethod.eWallet,
          walletName: selectedWallet.name,
        );
  }

  /// Handle submit success
  void _handleSubmitSuccess() {
    final codepayCreateResponse = ref
        .read(codepaySubmitNotifierProvider.notifier)
        .codepayCreateResponse;

    debugPrint('codepayCreateResponse: ${codepayCreateResponse?.bankAccount}');
    if (codepayCreateResponse == null) {
      return;
    }

    // Update _savedResponse để show CodepayTransferSection ngay lập tức
    final formState = ref.read(ewalletFormProvider);
    if (formState.selectedWallet != null) {
      setState(() {
        _savedResponse = codepayCreateResponse;
      });
    }

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final navigator = DepositNavigator();

    // Use DepositNavigator for consistent navigation flow
    navigator.push(
      context: rootContext,
      mobileShowMethod: (ctx) => EWalletConfirmMoneyTransferBottomSheet.show(
        ctx,
        qrResponse: codepayCreateResponse,
        paymentMethod: PaymentMethod.eWallet,
        hideButtons: false, // Show buttons for newly created ticket
      ),
      webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
        context: ctx,
        builder: (dialogContext, animation, secondaryAnimation) =>
            EWalletConfirmMoneyTransferOverlay(
              qrResponse: codepayCreateResponse,
              paymentMethod: PaymentMethod.eWallet,
              hideButtons: false, // Show buttons for newly created ticket
            ),
      ),
      showPreviousDialog: (rootContext, deviceType) async {
        if (deviceType == DeviceType.mobile) {
          await DepositMobileBottomSheet.show(rootContext);
        } else {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          container.read(depositOverlayVisibleProvider.notifier).state = true;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (rootContext.mounted) {
            container
                .read(depositSelectionProvider.notifier)
                .selectPaymentMethod(PaymentMethod.eWallet);
          }
        }
      },
    );
  }

  /// Handle submit error
  void _handleSubmitError(String message) {
    if (!mounted) return;

    AppToast.showError(context, message: message);
  }
}
