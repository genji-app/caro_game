import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
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
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/codepay/codepay_transation_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/verify_bank_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/codepay_transfer_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/verify_bank_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/codepay_transfer_section.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:riverpod/riverpod.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/deposit_action_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/amount_input_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_field.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

class CodepayContainerSection extends ConsumerStatefulWidget {
  const CodepayContainerSection({super.key});

  @override
  ConsumerState<CodepayContainerSection> createState() =>
      _CodepayContainerSectionState();
}

class _CodepayContainerSectionState
    extends ConsumerState<CodepayContainerSection> {
  final TextEditingController _amountController = TextEditingController();
  CodepayCreateQrResponse? _savedResponse;
  String?
  _lastCheckedBankId; // Track last checked bank to avoid duplicate calls

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final selectedMethod = ref.read(depositSelectionProvider).selectedMethod;
      if (selectedMethod == PaymentMethod.codepay) {
        ref
            .read(codepayFormProvider.notifier)
            .updateAmount(_amountController.text);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(codepayFormProvider);
    final depositConfigAsync = ref.watch(configDepositProvider);
    final deviceType = ResponsiveBuilder.getDeviceType(context);

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
            _checkSavedResponseAfterExpiry(formState, depositConfigAsync);
          }
        });
      }
    }

    final hasValidSavedResponse = _savedResponse != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildBankSelectionForm(formState, depositConfigAsync),
                  const SizedBox(height: 24),
                  if (hasValidSavedResponse)
                    CodepayTransferSection(
                      qrResponse: _savedResponse!,
                      paymentMethod: PaymentMethod.codepay,
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
        ),
        if (!hasValidSavedResponse) _buildBottomButton(formState),
      ],
    );
  }

  Widget _buildBottomButton(CodepayFormState formState) {
    final submitState = ref.watch(codepaySubmitNotifierProvider);

    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );

    final isEnabled =
        !isSubmitting && formState.isValid && formState.amount.isNotEmpty;

    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Tạo mã QR',
      isEnabled: isEnabled,
      onTap: () => _handleSubmit(formState),
    );
  }

  List<CodepayBank> _extractCodepayBanks(FetchBankAccountsData depositData) =>
      depositData.codepay.where((item) => item.supportQrCode == true).toList();

  Widget _buildBankSelectionForm(
    CodepayFormState formState,
    AsyncValue<FetchBankAccountsData> depositConfigAsync,
  ) => depositConfigAsync.when(
    data: (depositData) {
      // No need to initialize - needVerifyBankAccountProvider is now computed from configDepositProvider

      final banks = _extractCodepayBanks(depositData);
      if (banks.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Không có ngân hàng codepay nào',
              style: AppTextStyles.labelMedium(color: AppColors.gray300),
            ),
          ),
        );
      }

      if (formState.selectedBank == null && banks.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final firstBankId = banks.first.id;
            ref.read(codepayFormProvider.notifier).updateBank(firstBankId);
            _checkSavedResponse(banks, firstBankId);
          }
        });
      } else if (formState.selectedBank != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkSavedResponse(banks, formState.selectedBank);
          }
        });
      }

      final menuItems = banks
          .map(
            (bank) => SelectionMenuItem(
              value: bank.id,
              label: bank.fullName,
              iconUrl: PaymentUtil.getIconPayment(
                name: bank.name,
                patchIconDefault: bank.url.isNotEmpty ? bank.url : '',
              ),
            ),
          )
          .toList();

      return SelectionField(
        label: 'Chọn ngân hàng',
        placeholder: 'Chọn ngân hàng',
        selectedValue: formState.selectedBank,
        errorMessage: formState.bankError,
        items: menuItems,
        onSelected: (value) {
          ref.read(codepayFormProvider.notifier).updateBank(value);
          _checkSavedResponse(banks, value);
        },
        iconStyle: SelectionIconStyle.defaultStyle,
        isLoading: false,
      );
    },
    loading: () => SelectionField(
      label: 'Chọn ngân hàng',
      placeholder: 'Đang tải...',
      selectedValue: null,
      items: const [],
      onSelected: (_) {},
      isLoading: true,
    ),
    error: (error, stack) => SelectionField(
      label: 'Chọn ngân hàng',
      placeholder: 'Lỗi tải dữ liệu',
      selectedValue: null,
      items: const [],
      onSelected: (_) {},
      errorMessage: 'Error: $error',
    ),
  );

  Future<void> _checkSavedResponse(
    List<CodepayBank> banks,
    String? selectedBankId,
  ) async {
    if (selectedBankId == null) {
      _lastCheckedBankId = null;
      setState(() {
        _savedResponse = null;
      });
      return;
    }

    // Avoid duplicate calls for the same bank
    if (_lastCheckedBankId == selectedBankId) {
      return;
    }
    _lastCheckedBankId = selectedBankId;

    final selectedBank = banks.firstWhere(
      (bank) => bank.id == selectedBankId,
      orElse: () => banks.first,
    );

    // Check if bank has accounts
    if (selectedBank.accounts.isEmpty) {
      setState(() {
        _savedResponse = null;
      });
      return;
    }

    final firstAccount = selectedBank.accounts.first;
    final bankAccountId = firstAccount.bankId;

    // Always call checkCodePay API when item is selected
    final checkRequest = CheckCodePayRequest(
      bankAccountId: bankAccountId,
      bankId: selectedBank.id,
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
    CodepayFormState formState,
    AsyncValue<FetchBankAccountsData> depositConfigAsync,
  ) {
    depositConfigAsync.whenData((depositData) {
      final banks = _extractCodepayBanks(depositData);
      if (banks.isEmpty || formState.selectedBank == null) {
        setState(() {
          _savedResponse = null;
        });
        return;
      }

      // When expired, call API again instead of checking local storage
      _checkSavedResponse(banks, formState.selectedBank);
    });
  }

  Future<void> _handleSubmit(CodepayFormState formState) async {
    if (!ref.read(codepayFormProvider.notifier).validate()) {
      return;
    }

    final depositConfigAsync = ref.read(configDepositProvider);
    final depositData = await depositConfigAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (_, __) => null,
    );

    if (depositData == null) {
      if (mounted) {
        AppToast.showError(context, message: 'Không thể tải cấu hình deposit');
      }
      return;
    }

    final banks = _extractCodepayBanks(depositData);
    if (banks.isEmpty) {
      if (mounted) {
        AppToast.showError(context, message: 'Không có ngân hàng codepay nào');
      }
      return;
    }

    final selectedBank = banks.firstWhere(
      (codepayBank) => codepayBank.id == formState.selectedBank,
      orElse: () => banks.first,
    );

    if (selectedBank.accounts.isEmpty) {
      if (mounted) {
        AppToast.showError(context, message: 'Ngân hàng không có tài khoản');
      }
      return;
    }

    final firstAccount = selectedBank.accounts.first;
    final bankAccountId = firstAccount.bankId;

    final amountText = formState.amount.replaceAll(',', '').replaceAll('.', '');
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      if (mounted) {
        AppToast.showError(context, message: 'Số tiền không hợp lệ');
      }
      return;
    }

    final needVerify = ref.watch(needVerifyBankAccountProvider);
    if (needVerify) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final navigator = DepositNavigator();

      await navigator.push(
        context: rootContext,
        mobileShowMethod: (ctx) =>
            VerifyBankBottomSheet.show(ctx, selectedBankId: selectedBank.id),
        webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
          context: ctx,
          builder: (dialogContext, animation, secondaryAnimation) =>
              VerifyBankOverlay(selectedBankId: selectedBank.id),
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
            await Future<void>.delayed(const Duration(milliseconds: 120));
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.codepay);
            }
          }
        },
      );
    } else {
      final request = CodepayCreateQrRequest(
        bankId: selectedBank.id,
        amount: amount,
        bankAccountId: bankAccountId,
      );

      await ref
          .read(codepaySubmitNotifierProvider.notifier)
          .createCodePay(request);
    }
  }

  void _handleSubmitSuccess() {
    final codepayCreateResponse = ref
        .read(codepaySubmitNotifierProvider.notifier)
        .codepayCreateResponse;
    if (codepayCreateResponse == null) {
      return;
    }

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final navigator = DepositNavigator();

    navigator.push(
      context: rootContext,
      mobileShowMethod: (ctx) => CodepayTransationBottomSheet.show(
        ctx,
        qrResponse: codepayCreateResponse,
        paymentMethod: PaymentMethod.codepay,
        hideButtons: false,
      ),
      webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
        context: ctx,
        builder: (dialogContext, animation, secondaryAnimation) =>
            CodepayTransferOverlay(
              qrResponse: codepayCreateResponse,
              paymentMethod: PaymentMethod.codepay,
              hideButtons: false,
            ),
      ),
      showPreviousDialog: (rootContext, deviceType) async {
        final container = ProviderScope.containerOf(rootContext, listen: false);
        if (deviceType == DeviceType.mobile) {
          await DepositMobileBottomSheet.show(rootContext);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        } else {
          container.read(depositOverlayVisibleProvider.notifier).state = true;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        if (rootContext.mounted) {
          container
              .read(depositSelectionProvider.notifier)
              .selectPaymentMethod(PaymentMethod.codepay);
        }
      },
    );
  }

  void _handleSubmitError(String message) {
    if (!mounted) return;
    AppToast.showError(context, message: message);
  }
}
