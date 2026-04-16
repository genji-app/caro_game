import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/clipboard_utils.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/deposit_action_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class CryptoConfirmMoneyTransferContainer extends ConsumerStatefulWidget {
  final CryptoAddressResponse cryptoAddressResponse;
  final CryptoOption cryptoOption;
  final PaymentMethod paymentMethod;

  const CryptoConfirmMoneyTransferContainer({
    super.key,
    required this.cryptoAddressResponse,
    required this.cryptoOption,
    required this.paymentMethod,
  });

  @override
  ConsumerState<CryptoConfirmMoneyTransferContainer> createState() =>
      _CryptoConfirmMoneyTransferContainerState();
}

class _CryptoConfirmMoneyTransferContainerState
    extends ConsumerState<CryptoConfirmMoneyTransferContainer> {
  Uint8List? _cachedQrImageBytes;

  @override
  void initState() {
    super.initState();
    // Decode QR code once and cache it
    _decodeAndCacheQRCode();
  }

  void _decodeAndCacheQRCode() {
    if (widget.cryptoAddressResponse.qrCode.isNotEmpty) {
      try {
        _cachedQrImageBytes = base64Decode(widget.cryptoAddressResponse.qrCode);
      } catch (e) {
        _cachedQrImageBytes = null;
      }
    }
  }

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
        // Fallback to a default icon if name doesn't match
        return AppIcons.icCryptoUsdt;
    }
  }

  /// Check if icon is WebP format
  bool _isWebP(String path) {
    return path.toLowerCase().endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(cryptoSubmitNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Header
        _buildHeader(),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information banner
                _buildInfoBanner(),
                const SizedBox(height: 24),
                // QR Code section
                _buildQRCodeSection(),
                const SizedBox(height: 24),
                // Crypto details
                _buildCryptoDetailsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Bottom button
        _buildBottomButton(submitState),
      ],
    );
  }

  /// Header with back button, title, and close button
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        // Back button
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: SizedBox(
            width: 20,
            height: 20,
            child: ImageHelper.load(
              path: AppIcons.icBack,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const Gap(12),
        // Title (centered)
        Expanded(
          child: Text(
            'Nạp tiền điện tử',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25, // #fffef5
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(12),
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

  /// Information banner
  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.yellow400.withValues(alpha: 0.16), // 16% opacity
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Warning icon
        ImageHelper.load(path: AppIcons.icWarning, width: 20, height: 20),
        const SizedBox(width: 12),
        // Info text with bullet points
        Expanded(
          child: Text(
            '• Vui lòng chuyển tới địa chỉ ví dưới đây.\n• Địa chỉ ví được tạo riêng biệt cho mỗi tài khoản, luôn thay đổi, vui lòng không lưu lại',
            style: AppTextStyles.paragraphXSmall(
              color: AppColors.gray25, // White text
            ),
          ),
        ),
      ],
    ),
  );

  /// QR Code section
  Widget _buildQRCodeSection() => Container(
    width: double.infinity,
    child: Column(
      children: [
        // Crypto name and network (above QR code)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Crypto icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isWebP(_getCryptoIconPath(widget.cryptoOption.name))
                    ? ImageHelper.getNetworkImage(
                        imageUrl: _getCryptoIconPath(widget.cryptoOption.name),
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      )
                    : ImageHelper.load(
                        path: _getCryptoIconPath(widget.cryptoOption.name),
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Crypto name
            Text(
              widget.cryptoOption.name,
              style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            ),
            const SizedBox(width: 4),
            // Network
            Text(
              widget.cryptoOption.network,
              style: AppTextStyles.paragraphXSmall(
                color: AppColors.gray300, // #9c9b95
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // QR Code from API response
        if (_cachedQrImageBytes != null)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray700, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.memory(
                _cachedQrImageBytes!,
                width: 176, // 200 - 24 (padding)
                height: 176,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    'Lỗi hiển thị QR',
                    style: AppTextStyles.labelSmall(color: AppColors.gray400),
                  ),
                ),
              ),
            ),
          )
        else
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.gray900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray700, width: 1),
            ),
            child: Center(
              child: Text(
                'Không thể hiển thị QR',
                style: AppTextStyles.labelSmall(color: AppColors.gray400),
              ),
            ),
          ),
      ],
    ),
  );

  /// Crypto details section
  Widget _buildCryptoDetailsSection() => Container(
    width: double.infinity,
    child: Column(
      children: [
        _buildDetailRow(
          label: 'Mạng lưới',
          value: widget.cryptoAddressResponse.network,
          showCopy: false,
        ),
        _buildDetailRow(
          label: 'Địa chỉ nạp',
          value: widget.cryptoAddressResponse.address,
          showCopy: true,
          onCopy: () => _copyToClipboard(widget.cryptoAddressResponse.address),
        ),
      ],
    ),
  );

  /// Detail row - Vertical layout: Label on top, value below
  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
  }) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.labelSmall(
            color: AppColors.gray300, // #9c9b95
          ),
        ),
        // Value with optional copy button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.labelSmall(
                  color: AppColors.gray25, // #fffef5
                ),
              ),
            ),
            if (showCopy) ...[
              const SizedBox(width: 24),
              _buildCopyButton(onCopy ?? () {}),
            ],
          ],
        ),
      ],
    ),
  );

  /// Copy button
  Widget _buildCopyButton(VoidCallback onCopy) => SizedBox(
    width: 28,
    height: 28,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: AppColors.gray700, // #252423
        child: InkWell(
          onTap: onCopy,
          child: Center(
            child: ImageHelper.load(
              path: AppIcons.icCopy,
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    ),
  );

  /// Copy to clipboard
  Future<void> _copyToClipboard(String text) async {
    if (!mounted) return;
    await ClipboardUtils.copyToClipboardWithSnackBar(context, text);
  }

  /// Bottom action button
  Widget _buildBottomButton(CryptoSubmitState submitState) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: AppColors.gray700, // #252423
          width: 0.5,
        ),
      ),
    ),
    child: DepositActionButton(
      text: submitState.maybeWhen(
        submitting: () => 'Đang xử lý...',
        orElse: () => 'Xác nhận chuyển tiền',
      ),
      isEnabled: submitState.maybeWhen(
        submitting: () => false,
        orElse: () => true,
      ),
      onTap: () => _handleConfirm(submitState),
      padding: EdgeInsets.zero,
    ),
  );

  /// Handle confirm button tap
  Future<void> _handleConfirm(CryptoSubmitState submitState) async {
    // Check if already submitting - skip if already in progress
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );
    if (isSubmitting) {
      return;
    }

    // Create request using data from API response
    final request = CryptoDepositRequest(
      cryptoType: widget.cryptoOption.id,
      amount: '0', // Amount will be entered in confirm screen if needed
      depositAddress: widget.cryptoAddressResponse.address,
    );

    // Submit deposit
    await ref.read(cryptoSubmitNotifierProvider.notifier).submit(request);
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    // Check submit result
    final newState = ref.read(cryptoSubmitNotifierProvider);
    newState.when(
      idle: () {},
      submitting: () {},
      success: () async {
        // Get root context before any navigation
        Navigator.of(context).pop();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await AppToast.showSuccess(
            rootContext,
            message: 'Chúng tôi đang xác nhận. Vui lòng đợi vài phút !',
          );
        }
      },
      error: (message) {
        if (mounted) {
          AppToast.showError(rootContext, message: message);
        }
      },
    );
  }
}
