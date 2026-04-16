import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/clipboard_utils.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_crypto_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_providers.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/state/withdraw_state.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/mobile/withdraw_waiting_payment_confirm_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/deposit_action_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/models/withdraw_crypto_option.dart';

/// Withdraw Crypto screen
class WithdrawCrypto extends ConsumerStatefulWidget {
  final WithdrawCryptoOption selectedCrypto;

  const WithdrawCrypto({super.key, required this.selectedCrypto});

  @override
  ConsumerState<WithdrawCrypto> createState() => _WithdrawCryptoState();
}

class _WithdrawCryptoState extends ConsumerState<WithdrawCrypto> {
  final TextEditingController _walletAddressController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  /// Get crypto icon path based on crypto name
  String _getCryptoIconPath(String cryptoName) {
    final name = cryptoName.toLowerCase();
    switch (name) {
      case 'bnb':
        return AppIcons.icCryptoBnb;
      case 'eth':
        return AppIcons.icCryptoEth;
      case 'kdg':
        return AppImages.icCryptoKdg;
      case 'usdt':
        return AppIcons.icCryptoUsdt;
      default:
        return AppIcons.icCryptoUsdt;
    }
  }

  /// Check if icon is WebP format
  bool _isWebP(String path) {
    return path.toLowerCase().endsWith('.webp');
  }

  @override
  void dispose() {
    _walletAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depositConfigAsync = ref.watch(configDepositProvider);

    // Listen to submit state changes
    ref.listen<CryptoWithdrawSubmitState>(
      cryptoWithdrawSubmitNotifierProvider,
      (previous, next) {
        next.maybeWhen(
          success: () => _handleSubmitSuccess(),
          error: (message) => _handleSubmitError(message),
          orElse: () {},
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Header
        _buildHeader(),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Warning banner
                _buildWarningBanner(),
                const SizedBox(height: 24),
                // Crypto display
                _buildCryptoDisplay(),
                const SizedBox(height: 24),
                // Amount input
                _buildAmountInput(depositConfigAsync),
                const SizedBox(height: 24),
                // Wallet address input
                _buildWalletAddressInput(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Bottom button
        _buildBottomButton(),
      ],
    );
  }

  /// Build header with back button, title, and close button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: AppColors.gray25, size: 24),
            ),
          ),
          // Title
          Expanded(
            child: Center(
              child: Text(
                'Rút tiền điện tử',
                style: AppTextStyles.headingSmall(color: AppColors.gray25),
              ),
            ),
          ),
          // Close button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, color: AppColors.gray25, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Build warning banner
  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.yellow400.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Info icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.yellow400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Warning text
          Expanded(
            child: Text(
              'Nhập chính xác mã ví nhận tiền. Chúng tôi không chịu trách nhiệm nếu bạn nhập sai mã ví.',
              style: AppTextStyles.paragraphSmall(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Build crypto display (icon, name, network)
  Widget _buildCryptoDisplay() {
    return Center(
      child: Column(
        children: [
          // Crypto icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: _isWebP(_getCryptoIconPath(widget.selectedCrypto.name))
                  ? ImageHelper.getNetworkImage(
                      imageUrl: _getCryptoIconPath(widget.selectedCrypto.name),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    )
                  : ImageHelper.load(
                      path: _getCryptoIconPath(widget.selectedCrypto.name),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // Crypto name
          Text(
            widget.selectedCrypto.name,
            style: AppTextStyles.headingMedium(color: AppColors.gray25),
          ),
          const SizedBox(height: 4),
          // Network
          Text(
            widget.selectedCrypto.network,
            style: AppTextStyles.paragraphSmall(color: AppColors.gray300),
          ),
        ],
      ),
    );
  }

  /// Build amount input section
  Widget _buildAmountInput(
    AsyncValue<FetchBankAccountsData> depositConfigAsync,
  ) {
    return depositConfigAsync.when(
      data: (depositData) {
        // Get available balance (you may need to adjust this based on your data structure)
        final availableBalance =
            '20,000,000'; // TODO: Get from actual balance data

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'Số tiền',
              style: AppTextStyles.labelSmall(color: AppColors.gray25),
            ),
            const SizedBox(height: 6),
            // Input field
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
                  // Input text
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      style: AppTextStyles.paragraphMedium(
                        color: AppColors.gray25,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tối thiểu 200,000',
                        hintStyle: AppTextStyles.paragraphMedium(
                          color: AppColors.gray400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  // Clear button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _amountController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return GestureDetector(
                          onTap: () => _amountController.clear(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.gray25,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Gap(4),
                  const SCoinIcon(),
                  const SizedBox(width: 8),
                  // Max button
                  InkWell(
                    onTap: () {
                      _amountController.text = availableBalance;
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Tối đa',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.yellow400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Build wallet address input section
  Widget _buildWalletAddressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Địa chỉ ví',
          style: AppTextStyles.labelSmall(color: AppColors.gray25),
        ),
        const SizedBox(height: 6),
        // Input field
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
              // Input text
              Expanded(
                child: TextField(
                  controller: _walletAddressController,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ ví',
                    hintStyle: AppTextStyles.paragraphMedium(
                      color: AppColors.gray400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 8),
              // Paste button
              InkWell(
                onTap: () => _pasteWalletAddress(),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Dán',
                    style: AppTextStyles.labelSmall(color: AppColors.yellow400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Paste wallet address from clipboard
  Future<void> _pasteWalletAddress() async {
    await ClipboardUtils.pasteToController(
      controller: _walletAddressController,
    );
  }

  /// Build bottom withdraw button
  Widget _buildBottomButton() {
    final submitState = ref.watch(cryptoWithdrawSubmitNotifierProvider);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _walletAddressController,
      builder: (context, walletValue, _) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: _amountController,
          builder: (context, amountValue, _) {
            final isValid =
                walletValue.text.trim().isNotEmpty &&
                amountValue.text.trim().isNotEmpty;

            final isSubmitting = submitState.maybeWhen(
              submitting: () => true,
              orElse: () => false,
            );

            return DepositActionButton(
              text: isSubmitting ? 'Đang xử lý...' : 'Rút tiền',
              isEnabled: isValid && !isSubmitting,
              onTap: isValid && !isSubmitting ? _handleSubmit : null,
            );
          },
        );
      },
    );
  }

  /// Handle submit button tap
  Future<void> _handleSubmit() async {
    final rootContext = context;
    final walletAddress = _walletAddressController.text.trim();
    final amountText = _amountController.text.trim();

    // Validate
    if (walletAddress.isEmpty) {
      AppToast.showError(rootContext, message: 'Vui lòng nhập địa chỉ ví');
      return;
    }

    if (amountText.isEmpty) {
      AppToast.showError(rootContext, message: 'Vui lòng nhập số tiền');
      return;
    }

    // Parse amount to int (remove commas and dots)
    final amountInt = int.tryParse(
      amountText.replaceAll(',', '').replaceAll('.', ''),
    );

    if (amountInt == null || amountInt <= 0) {
      AppToast.showError(rootContext, message: 'Số tiền không hợp lệ');
      return;
    }

    // Extract network from selectedCrypto (e.g., "USDT - TRC20" -> "TRC20")
    final network = widget.selectedCrypto.network.toUpperCase();
    final cryptoCurrency = widget.selectedCrypto.name.toUpperCase();

    // if (useMockup) {
    //   // Use mockup data - directly show confirmation screen
    //   _handleSubmitSuccess();
    //   return;
    // }

    // Create request
    final request = WithdrawCryptoRequest(
      network: network,
      cryptoCurrency: cryptoCurrency,
      fiatCurrency: 'VND',
      amount: amountInt,
      address: walletAddress,
    );

    // Submit via notifier
    await ref
        .read(cryptoWithdrawSubmitNotifierProvider.notifier)
        .submit(request);
  }

  /// Handle submit success
  void _handleSubmitSuccess() {
    final rootContext = context;
    final walletAddress = _walletAddressController.text.trim();
    final amount = _amountController.text.trim();

    // Create confirmation data
    final confirmationData = WithdrawConfirmationData(
      amount: amount,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      methodType: WithdrawPaymentMethodType.crypto,
      currencyType: widget.selectedCrypto.name,
      network: widget.selectedCrypto.fullName,
      walletAddress: walletAddress,
    );

    // Set data before showing dialog
    ref.read(withdrawConfirmationDataProvider.notifier).state =
        confirmationData;

    // Close current dialog first, then show confirmation screen
    Navigator.of(rootContext).pop();

    // Show confirmation screen based on device type
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!rootContext.mounted) return;

      final deviceType = ResponsiveBuilder.getDeviceType(rootContext);
      if (deviceType == DeviceType.mobile) {
        // Show bottom sheet
        WithdrawMobileWaitingPaymentConfirmBottomSheet.show(rootContext);
      } else {
        // Show overlay for web/tablet
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
      }
    });
  }

  /// Handle submit error
  void _handleSubmitError(String message) {
    if (!mounted) return;
    AppToast.showError(context, message: message);
  }
}
