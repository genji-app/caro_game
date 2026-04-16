import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/bank.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

/// Dialog for bank verification
class DialogConfirmationBank extends ConsumerStatefulWidget {
  const DialogConfirmationBank({super.key});

  /// Show the bank confirmation dialog
  static Future<void> show(BuildContext context) => showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const DialogConfirmationBank(),
  );

  @override
  ConsumerState<DialogConfirmationBank> createState() =>
      _DialogConfirmationBankState();
}

class _DialogConfirmationBankState
    extends ConsumerState<DialogConfirmationBank> {
  String? _selectedBankId;
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final GlobalKey _bankButtonKey = GlobalKey();

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(bankListProvider);
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InnerShadowCard(
          child: Container(
            width: screenSize.width > 500 ? 500 : screenSize.width * 0.9,
            constraints: BoxConstraints(maxHeight: screenSize.height * 0.85),
            decoration: BoxDecoration(
              color: AppColors.gray950,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  offset: const Offset(0, -20),
                  blurRadius: 200,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstructionText(),
                          const SizedBox(height: 24),
                          _buildBankDropdown(banksAsync),
                          const SizedBox(height: 16),
                          _buildAccountNameField(),
                          const SizedBox(height: 16),
                          _buildAccountNumberField(),
                          const SizedBox(height: 16),
                          _buildWarningText(),
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(banksAsync),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with title and close button
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: AppColors.yellow400, // Golden border
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        // Title with golden border container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.yellow400, // Golden border
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Xác Minh Ngân Hàng',
            style: AppTextStyles.headingSmall(color: AppColors.gray25),
          ),
        ),
        const Spacer(),
        // Close button
        InkWell(
          onTap: () => DepositNavigator().closeAll<void>(context),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );

  /// Build instruction text
  Widget _buildInstructionText() => Text(
    'Nhập thông tin ngân hàng của bạn để xác minh chính chủ',
    style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
  );

  /// Build bank dropdown
  Widget _buildBankDropdown(AsyncValue<List<Bank>> banksAsync) =>
      banksAsync.when(
        data: (banks) {
          if (banks.isEmpty) {
            return Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.gray950,
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Không có ngân hàng nào',
                  style: AppTextStyles.labelSmall(color: Colors.red),
                ),
              ),
            );
          }

          // Set default selected bank if not set
          if (_selectedBankId == null && banks.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedBankId = banks.first.id;
              });
            });
          }

          final selectedBank = banks.firstWhere(
            (bank) => bank.id == _selectedBankId,
            orElse: () => banks.first,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              return InkWell(
                onTap: () async {
                  // Convert banks to menu items
                  final menuItems = banks
                      .map(
                        (bank) => SelectionMenuItem(
                          value: bank.id,
                          label: bank.name,
                          iconUrl: bank.iconUrl,
                        ),
                      )
                      .toList();

                  final selectedValue = await SelectionMenu.show(
                    context: context,
                    items: menuItems,
                    buttonKey: _bankButtonKey,
                    buttonWidth: constraints.maxWidth,
                    selectedValue: _selectedBankId,
                  );
                  if (selectedValue != null && mounted) {
                    setState(() {
                      _selectedBankId = selectedValue;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  key: _bankButtonKey,
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray950,
                    border: Border.all(
                      color: AppColors.yellow400, // Golden border
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Bank icon
                      if (selectedBank.iconUrl != null)
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.gray25,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.gray700,
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              selectedBank.iconUrl!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.account_balance,
                                    size: 20,
                                    color: AppColors.gray950,
                                  ),
                            ),
                          ),
                        ),
                      // Bank name
                      Expanded(
                        child: Text(
                          selectedBank.name,
                          style: AppTextStyles.paragraphMedium(
                            color: AppColors.gray25,
                          ),
                        ),
                      ),
                      // Dropdown icon
                      ImageHelper.load(
                        path: AppIcons.chevronDown,
                        width: 20,
                        height: 20,
                        color: AppColors.gray25,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gray950,
            border: Border.all(color: AppColors.yellow400, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.gray950,
            border: Border.all(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Error: $error',
              style: AppTextStyles.labelSmall(color: Colors.red),
            ),
          ),
        ),
      );

  /// Build account name input field
  Widget _buildAccountNameField() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.gray950,
      border: Border.all(
        color: AppColors.yellow400, // Golden border
        width: 1,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: _accountNameController,
      style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
      decoration: InputDecoration(
        hintText: 'Tên Tài Khoản',
        hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
        border: InputBorder.none,
      ),
    ),
  );

  /// Build account number input field
  Widget _buildAccountNumberField() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.gray950,
      border: Border.all(
        color: AppColors.yellow400, // Golden border
        width: 1,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: _accountNumberController,
      style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Số Tài Khoản',
        hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
        border: InputBorder.none,
      ),
    ),
  );

  /// Build warning text
  Widget _buildWarningText() => Text(
    '*Chỉ Cần Xác Minh 1 Lần*',
    style: AppTextStyles.paragraphSmall(
      color: AppColors.yellow400, // Golden/orange color
    ),
  );

  /// Build confirm button
  Widget _buildConfirmButton(AsyncValue<List<Bank>> banksAsync) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.gray700, width: 0.5)),
    ),
    child: ShineButton(
      text: 'XÁC NHẬN',
      height: 48,
      size: ShineButtonSize.large,
      width: double.infinity,
      style: ShineButtonStyle.primaryYellow,
      onPressed: () => _handleConfirm(banksAsync),
    ),
  );

  /// Handle confirm button tap
  void _handleConfirm(AsyncValue<List<Bank>> banksAsync) {
    banksAsync.whenData((banks) {
      if (_selectedBankId == null) {
        // Show error if no bank selected
        return;
      }

      if (_accountNameController.text.trim().isEmpty) {
        // Show error if account name is empty
        return;
      }

      if (_accountNumberController.text.trim().isEmpty) {
        // Show error if account number is empty
        return;
      }

      // TODO: Implement bank verification logic
      // For now, just close the dialog
      Navigator.of(context).pop();
    });
  }
}
