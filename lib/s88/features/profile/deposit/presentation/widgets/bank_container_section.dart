import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_form_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/bank/bank_transfer_money_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/verify_bank_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/verify_bank_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/bank_transfer_overlay.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

class BankContainerSection extends ConsumerStatefulWidget {
  const BankContainerSection({super.key});

  @override
  ConsumerState<BankContainerSection> createState() =>
      _BankContainerSectionState();
}

class _BankContainerSectionState extends ConsumerState<BankContainerSection> {
  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(bankFormProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildBankSelectionForm(formState),
            ),
          ),
        );
      },
    );
  }

  /// Bank selection form
  Widget _buildBankSelectionForm(BankFormState formState) {
    final depositConfigAsync = ref.watch(configDepositProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 36),
        // Label - "Chọn ngân hàng"
        Text(
          'Chọn ngân hàng',
          style: AppTextStyles.labelSmall(
            color: AppColors.gray300, // #9c9b95
          ),
        ),
        if (formState.bankError != null) ...[
          const SizedBox(height: 4),
          Text(
            formState.bankError!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 8),
        // Bank list container
        depositConfigAsync.when(
          data: (depositData) {
            // No need to initialize - needVerifyBankAccountProvider is now computed from configDepositProvider

            // Filter only banks with accounts
            final banksWithAccounts = depositData.items
                .where((item) => item.accounts.isNotEmpty)
                .toList();
            return _buildBankList(banksWithAccounts, formState);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text(
            'Error: $error',
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ),
      ],
    );
  }

  /// Build bank list with icon, name, and description
  Widget _buildBankList(List<BankAccountItem> banks, BankFormState formState) {
    if (banks.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Không có ngân hàng nào',
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0), width: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: banks.asMap().entries.map((entry) {
          final index = entry.key;
          final bankAccountItem = entry.value;
          final isSelected = formState.selectedBank == bankAccountItem.id;
          return _buildBankItem(
            bankAccountItem: bankAccountItem,
            isSelected: isSelected,
            isLast: index == banks.length - 1,
            onTap: () => _handleBankSelection(bankAccountItem),
          );
        }).toList(),
      ),
    );
  }

  /// Build individual bank item
  Widget _buildBankItem({
    required BankAccountItem bankAccountItem,
    required bool isSelected,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: Colors.white.withOpacity(0), width: 0.75),
          ),
        ),
        child: Row(
          children: [
            // Bank icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.gray25, // #fffef5
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gray700, width: 0.5),
              ),
              child: bankAccountItem.url.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        bankAccountItem.url,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.account_balance,
                              size: 20,
                              color: AppColors.gray950,
                            ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Icon(
                            Icons.account_balance,
                            size: 20,
                            color: AppColors.gray950,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.account_balance,
                      size: 20,
                      color: AppColors.gray950,
                    ),
            ),
            const SizedBox(width: 8),
            // Bank name and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankAccountItem.name,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.gray25, // #fffef5
                    ),
                  ),
                  if (bankAccountItem.fullName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      bankAccountItem.fullName,
                      style: AppTextStyles.paragraphXSmall(
                        color: AppColors.gray300, // #9c9b95
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle bank selection - Navigate to BankTransferMoneyBottomSheet or BankTransferOverlay
  Future<void> _handleBankSelection(BankAccountItem bankAccountItem) async {
    // Update form state with selected bank ID
    ref.read(bankFormProvider.notifier).updateBank(bankAccountItem.id);

    // Check needVerifyBankAccount before proceeding
    final needVerify = ref.read(needVerifyBankAccountProvider);

    if (needVerify) {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final navigator = DepositNavigator();

      await navigator.push(
        context: rootContext,
        mobileShowMethod: (ctx) =>
            VerifyBankBottomSheet.show(ctx, selectedBankId: bankAccountItem.id),
        webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
          context: ctx,
          builder: (dialogContext, animation, secondaryAnimation) =>
              VerifyBankOverlay(selectedBankId: bankAccountItem.id),
        ),
        showPreviousDialog: (rootContext, deviceType) async {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          if (deviceType == DeviceType.mobile) {
            await DepositMobileBottomSheet.show(rootContext);
            await Future<void>.delayed(const Duration(milliseconds: 100));
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.bank);
            }
          } else {
            container.read(depositOverlayVisibleProvider.notifier).state = true;
            await Future<void>.delayed(const Duration(milliseconds: 100));
            if (rootContext.mounted) {
              container
                  .read(depositSelectionProvider.notifier)
                  .selectPaymentMethod(PaymentMethod.bank);
            }
          }
        },
      );

      // After verification, return to allow user to re-select bank / proceed
      return;
    }

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final navigator = DepositNavigator();

    // Sử dụng DepositNavigator để tự động track previous dialog
    // DepositNavigator sẽ handle việc pop/close dialog cũ và show dialog mới
    navigator.push(
      context: rootContext,
      mobileShowMethod: (ctx) => BankTransferMoneyBottomSheet.show(
        ctx,
        bankAccountItem: bankAccountItem,
        amount: '', // Empty - will be filled from API
        paymentMethod: PaymentMethod.bank,
      ),
      webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
        context: ctx,
        builder: (dialogContext, animation, secondaryAnimation) =>
            BankTransferOverlay(
              bankAccountItem: bankAccountItem,
              paymentMethod: PaymentMethod.bank,
            ),
      ),
      showPreviousDialog: (rootContext, deviceType) async {
        if (deviceType == DeviceType.mobile) {
          await DepositMobileBottomSheet.show(rootContext);
          // Select payment method as bank after showing bottom sheet
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (rootContext.mounted) {
            final container = ProviderScope.containerOf(
              rootContext,
              listen: false,
            );
            container
                .read(depositSelectionProvider.notifier)
                .selectPaymentMethod(PaymentMethod.bank);
          }
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
                .selectPaymentMethod(PaymentMethod.bank);
          }
        }
      },
    );
  }
}
