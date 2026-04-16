import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/verified_bank_account.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/payment_util.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_providers.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_bank_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/mobile/withdraw_waiting_payment_confirm_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/deposit_action_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_field.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

/// Bank container for withdraw
class WithdrawBankContainer extends ConsumerStatefulWidget {
  const WithdrawBankContainer({super.key});

  @override
  ConsumerState<WithdrawBankContainer> createState() =>
      _WithdrawBankContainerState();
}

class _WithdrawBankContainerState extends ConsumerState<WithdrawBankContainer> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isAccountNumberReadOnly = false;
  bool _isAccountNameReadOnly = true; // Default to read-only
  bool _isSubmitting = false;
  bool _isUpdatingProgrammatically =
      false; // Flag để bỏ qua onChanged khi set text programmatically
  String?
  _lastUpdatedBankId; // Track bank ID đã được update để tránh update nhiều lần
  bool _isAccountNameInitialized = false; // Track xem đã init account name chưa

  @override
  void initState() {
    super.initState();
    // Không dùng listener để tránh xung đột với TextInputFormatter trên web
    // Sẽ dùng onChanged callback trong TextField thay thế
  }

  void _onAccountNumberChanged(String value) {
    // Bỏ qua nếu đang set text programmatically
    if (_isUpdatingProgrammatically) return;
    ref.read(withdrawBankFormProvider.notifier).updateAccountNumber(value);
  }

  void _onAccountNameChanged(String value) {
    // Bỏ qua nếu đang set text programmatically
    if (_isUpdatingProgrammatically) return;
    ref.read(withdrawBankFormProvider.notifier).updateAccountName(value);
  }

  void _onAmountChanged(String value) {
    // Bỏ qua nếu đang set text programmatically
    if (_isUpdatingProgrammatically) return;
    ref.read(withdrawBankFormProvider.notifier).updateAmount(value);
  }

  /// Initialize account name từ verifiedBankAccounts (chỉ gọi 1 lần)
  /// Logic:
  /// - If verifiedBankAccounts is empty → 'chủ tài khoản' is editable
  /// - If verifiedBankAccounts has items → 'chủ tài khoản' is filled from first item's accountHolder and read-only
  void _initializeAccountName(FetchBankAccountsData depositData) {
    if (_isAccountNameInitialized) return; // Chỉ init 1 lần
    _isAccountNameInitialized = true;

    try {
      final verifiedAccounts = depositData.verifiedBankAccounts;
      _isUpdatingProgrammatically = true;

      if (verifiedAccounts.isEmpty) {
        // No verified accounts → 'chủ tài khoản' is editable
        setState(() {
          _isAccountNameReadOnly = false;
        });
        _isUpdatingProgrammatically = false;
        return;
      }

      // verifiedBankAccounts has items → fill 'chủ tài khoản' from first item
      final firstVerifiedAccount = verifiedAccounts.first;
      final accountHolder = firstVerifiedAccount.accountHolder;

      _accountNameController.text = accountHolder;
      ref
          .read(withdrawBankFormProvider.notifier)
          .updateAccountName(accountHolder);

      setState(() {
        _isAccountNameReadOnly = true; // Read-only (filled from first item)
      });

      _isUpdatingProgrammatically = false;
    } catch (e) {
      debugPrint('Error initializing account name: $e');
      setState(() {
        _isAccountNameReadOnly = false; // Allow input on error
      });
      _isUpdatingProgrammatically = false;
    }
  }

  /// Update account number dựa trên bank được chọn (chỉ update khi bank thay đổi)
  /// Logic:
  /// - If bank matches verifiedBankAccounts → 'số tài khoản' auto-fill and read-only
  /// - If bank doesn't match → 'số tài khoản' is editable
  void _updateAccountNumberForBank(
    FetchBankAccountsData depositData,
    String bankId,
  ) {
    // Tránh update nhiều lần cho cùng một bankId
    if (_lastUpdatedBankId == bankId) {
      return;
    }
    _lastUpdatedBankId = bankId;

    try {
      final verifiedAccounts = depositData.verifiedBankAccounts;
      _isUpdatingProgrammatically = true;

      // Try to find verified account matching the selected bank
      VerifiedBankAccount? matchedAccount;
      if (verifiedAccounts.isNotEmpty) {
        try {
          matchedAccount = verifiedAccounts.firstWhere(
            (account) => account.bankId == bankId,
          );
        } catch (e) {
          // Bank not found in verifiedBankAccounts
          matchedAccount = null;
        }
      }

      if (matchedAccount != null) {
        // Bank found in verifiedBankAccounts → auto-fill 'số tài khoản' and make it read-only
        final accountNo = matchedAccount.accountNo;
        _accountNumberController.text = accountNo;
        ref
            .read(withdrawBankFormProvider.notifier)
            .updateAccountNumber(accountNo);

        setState(() {
          _isAccountNumberReadOnly =
              true; // Read-only (matched with selected bank)
        });
      } else {
        // Bank not in verifiedBankAccounts → 'số tài khoản' is editable
        if (_accountNumberController.text.isNotEmpty) {
          _accountNumberController.clear();
          ref.read(withdrawBankFormProvider.notifier).updateAccountNumber('');
        }

        setState(() {
          _isAccountNumberReadOnly = false; // Editable (bank not matched)
        });
      }

      _isUpdatingProgrammatically = false;
    } catch (e) {
      debugPrint('Error updating account number for bank: $e');
      setState(() {
        _isAccountNumberReadOnly = false;
      });
      _isUpdatingProgrammatically = false;
    }
  }

  @override
  void dispose() {
    // Không cần remove listener nữa vì đã dùng onChanged callback
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(withdrawBankFormProvider);
    final depositConfigAsync = ref.watch(configDepositProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildBankSelectionForm(formState, depositConfigAsync),
                const SizedBox(height: 24),
                _buildAccountNumberForm(),
                const SizedBox(height: 24),
                _buildAccountNameForm(),
                const SizedBox(height: 24),
                _buildAmountForm(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildBankSelectionForm(
    WithdrawBankFormState formState,
    AsyncValue<FetchBankAccountsData> depositConfigAsync,
  ) => depositConfigAsync.when(
    data: (depositData) {
      // Filter only BankAccountItems that have accounts (non-empty)
      final banksWithAccounts = depositData.items
          // .where((BankAccountItem item) => item.accounts.isNotEmpty)
          .toList();

      if (banksWithAccounts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Không có ngân hàng nào',
              style: AppTextStyles.labelMedium(color: AppColors.gray300),
            ),
          ),
        );
      }

      // Initialize account name chỉ 1 lần khi data sẵn sàng
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeAccountName(depositData);
        }
      });

      // Auto-select first bank if none selected
      if (formState.selectedBank == null && banksWithAccounts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final firstBankId = banksWithAccounts.first.id;
            ref.read(withdrawBankFormProvider.notifier).updateBank(firstBankId);
            _updateAccountNumberForBank(depositData, firstBankId);
          }
        });
      } else if (formState.selectedBank != null) {
        // Update account number khi đã có selectedBank
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateAccountNumberForBank(depositData, formState.selectedBank!);
          }
        });
      }

      final menuItems = banksWithAccounts
          .map(
            (BankAccountItem bank) => SelectionMenuItem(
              value: bank.id,
              label: bank.name,
              iconUrl: PaymentUtil.getIconPayment(
                name: bank.name,
                patchIconDefault: bank.url.toString().toLowerCase(),
              ),
            ),
          )
          .toList();

      return SelectionField(
        label: 'Ngân hàng',
        placeholder: 'Chọn ngân hàng',
        selectedValue: formState.selectedBank,
        errorMessage: formState.bankError,
        items: menuItems,
        onSelected: (value) {
          ref.read(withdrawBankFormProvider.notifier).updateBank(value);
          // Chỉ update account number khi bank thay đổi
          _updateAccountNumberForBank(depositData, value);
        },
        iconStyle: SelectionIconStyle.defaultStyle,
        isLoading: false,
      );
    },
    loading: () => SelectionField(
      label: 'Ngân hàng',
      placeholder: 'Đang tải...',
      selectedValue: null,
      items: const [],
      onSelected: (_) {},
      isLoading: true,
    ),
    error: (error, stack) => SelectionField(
      label: 'Ngân hàng',
      placeholder: 'Lỗi tải dữ liệu',
      selectedValue: null,
      items: const [],
      onSelected: (_) {},
      errorMessage: 'Error: $error',
    ),
  );

  Widget _buildAccountNumberForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Số tài khoản',
        style: AppTextStyles.labelSmall(color: AppColors.gray25),
      ),
      const SizedBox(height: 6),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          border: Border.all(color: AppColors.gray700, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _accountNumberController,
          readOnly: _isAccountNumberReadOnly,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập số tài khoản',
            hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onChanged: _onAccountNumberChanged,
        ),
      ),
    ],
  );

  Widget _buildAccountNameForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Chủ tài khoản',
        style: AppTextStyles.labelSmall(color: AppColors.gray25),
      ),
      const SizedBox(height: 6),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          border: Border.all(color: AppColors.gray700, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _accountNameController,
          readOnly: _isAccountNameReadOnly,
          style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
          decoration: InputDecoration(
            hintText: 'Nhập tên tài khoản',
            hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
          ],
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          onChanged: _onAccountNameChanged,
        ),
      ),
    ],
  );

  Widget _buildAmountForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Số tiền', style: AppTextStyles.labelSmall(color: AppColors.gray25)),
      const SizedBox(height: 6),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          border: Border.all(color: AppColors.gray700, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                decoration: InputDecoration(
                  hintText: 'Tối thiểu 200,000',
                  hintStyle: AppTextStyles.paragraphMedium(
                    color: AppColors.gray400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                onChanged: _onAmountChanged,
              ),
            ),
            const Gap(4),
            const SCoinIcon(),
          ],
        ),
      ),
    ],
  );

  Widget _buildBottomButton() {
    final formState = ref.watch(withdrawBankFormProvider);
    final isValid = formState.isValid;

    return DepositActionButton(
      text: _isSubmitting ? 'Đang xử lý...' : 'Rút tiền',
      isEnabled: isValid && !_isSubmitting,
      onTap: isValid && !_isSubmitting ? _handleSubmit : null,
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    final formState = ref.read(withdrawBankFormProvider);
    final depositConfigAsync = ref.read(configDepositProvider);
    final rootContext = context;

    try {
      await depositConfigAsync.whenData((depositData) async {
        final selectedBank = depositData.items.firstWhere(
          (bank) => bank.id == formState.selectedBank,
          orElse: () => depositData.items.first,
        );

        final amountInt =
            int.tryParse(
              formState.amount.replaceAll(',', '').replaceAll('.', ''),
            ) ??
            0;
        if (amountInt <= 0) {
          if (mounted) {
            AppToast.showError(rootContext, message: 'Số tiền không hợp lệ');
          }
          return;
        }

        final request = WithdrawBankRequest(
          bankId: selectedBank.id,
          accountNumber: formState.accountNumber,
          accountName: formState.accountName,
          amount: amountInt,
          slipType: 2,
        );

        final usecase = ref.read(submitWithdrawBankUseCaseProvider);
        final result = await usecase(request);

        result.fold(
          (failure) {
            if (mounted) {
              AppToast.showError(rootContext, message: failure.toString());
            }
          },
          (response) {
            // Generate transaction ID from timestamp if not provided
            final transactionId = DateTime.now().millisecondsSinceEpoch
                .toString();

            final confirmationData = WithdrawConfirmationData(
              amount: formState.amount,
              id: transactionId,
              methodType: WithdrawPaymentMethodType.bank,
              bankName: selectedBank.name,
              accountName: formState.accountName,
              accountNumber: formState.accountNumber,
            );

            // Set data before showing dialog
            ref.read(withdrawConfirmationDataProvider.notifier).state =
                confirmationData;

            // Show confirmation screen based on device type
            final deviceType = ResponsiveBuilder.getDeviceType(rootContext);
            if (deviceType == DeviceType.mobile) {
              // Show bottom sheet
              WithdrawMobileWaitingPaymentConfirmBottomSheet.show(rootContext);
            } else {
              // Show overlay for web/tablet
              Future(() {
                showGeneralDialog(
                  context: rootContext,
                  barrierColor: Colors.black.withOpacity(0.5),
                  barrierDismissible: true,
                  barrierLabel: MaterialLocalizations.of(
                    rootContext,
                  ).modalBarrierDismissLabel,
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (dialogContext, animation, secondaryAnimation) {
                    return const WithdrawWaitingPaymentConfirmOverlayWeb();
                  },
                );
              });
            }
          },
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
