import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/codepay_create_qr_response.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';

/// Layout type for shared Codepay transfer section
enum CodepayTransferLayout { mobile, web }

/// Shared transfer content (QR + transaction details) for Codepay
/// Used by both mobile bottom sheet and web/tablet overlay.
class CodepayTransferSection extends ConsumerWidget {
  final CodepayCreateQrResponse qrResponse;
  final PaymentMethod paymentMethod;
  final CodepayTransferLayout layout;

  const CodepayTransferSection({
    super.key,
    required this.qrResponse,
    required this.paymentMethod,
    this.layout = CodepayTransferLayout.mobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QRCodeSection(
          qrCode: qrResponse.qrcode,
          layout: layout,
          remainingTime: qrResponse.remainingTime,
        ),
        const SizedBox(height: 24),
        _buildTransactionDetailsSection(context),
      ],
    );
  }

  /// Transaction details section
  Widget _buildTransactionDetailsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray700, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildTransactionDetailRow(
            context: context,
            label: 'Ngân hàng',
            value: qrResponse.bankName,
            showCopy: false,
          ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Tên TK',
            value: qrResponse.accountName,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, qrResponse.accountName),
          ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Số TK',
            value: qrResponse.bankAccount,
            valueColor: AppColors.green400,
            showCopy: true,
            onCopy: () => _copyToClipboard(
              context,
              qrResponse.bankAccount.replaceAll(' ', ''),
            ),
          ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Số tiền',
            value:
                '${qrResponse.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            valueColor: AppColors.green400,
            showCopy: true,
            onCopy: () =>
                _copyToClipboard(context, qrResponse.amount.toString()),
          ),
          if (qrResponse.bankBranch.isNotEmpty)
            _buildTransactionDetailRow(
              context: context,
              label: 'Chi nhánh',
              value: qrResponse.bankBranch,
              showCopy: false,
            ),
          _buildTransactionDetailRow(
            context: context,
            label: 'Nội dung',
            value: qrResponse.codepay,
            valueColor: AppColors.green400,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, qrResponse.codepay),
          ),
        ],
      ),
    );
  }

  /// Transaction detail row
  Widget _buildTransactionDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    required bool showCopy,
    VoidCallback? onCopy,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(
              color: valueColor ?? AppColors.gray25,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Visibility(
          visible: label == 'Số tiền',
          child: const Row(children: [Gap(4), SCoinIcon()]),
        ),
        SizedBox(
          width: 56,
          child: showCopy
              ? Center(child: _buildCopyButton(onCopy ?? () {}))
              : const SizedBox.shrink(),
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
        color: AppColors.gray700,
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
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// QR Code section widget - separate from timer to avoid rebuild
/// QR code image is cached to prevent flickering when timer updates
class _QRCodeSection extends StatefulWidget {
  final String qrCode;
  final CodepayTransferLayout layout;
  final int remainingTime;

  const _QRCodeSection({
    required this.qrCode,
    required this.layout,
    required this.remainingTime,
  });

  @override
  State<_QRCodeSection> createState() => _QRCodeSectionState();
}

class _QRCodeSectionState extends State<_QRCodeSection> {
  Uint8List? _cachedQrImageBytes;

  @override
  void initState() {
    super.initState();
    // Decode QR code once and cache it
    _decodeAndCacheQRCode();
  }

  void _decodeAndCacheQRCode() {
    if (widget.qrCode.isNotEmpty) {
      try {
        _cachedQrImageBytes = base64Decode(widget.qrCode);
      } catch (e) {
        _cachedQrImageBytes = null;
      }
    }
  }

  @override
  void didUpdateWidget(_QRCodeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-decode if QR code data changed
    if (oldWidget.qrCode != widget.qrCode) {
      _decodeAndCacheQRCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWebLayout = widget.layout == CodepayTransferLayout.web;
    final qrSize = isWebLayout ? 200.0 : 160.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Quét mã QR',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray300,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray700, width: 1),
            ),
            child: _cachedQrImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.memory(
                        _cachedQrImageBytes!,
                        width: qrSize,
                        height: qrSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildQRCodePlaceholder(qrSize),
                      ),
                    ),
                  )
                : _buildQRCodePlaceholder(qrSize),
          ),
          const SizedBox(height: 16),
          // Timer text widget - only this widget rebuilds when timer updates
          _TimerTextWidget(remainingTime: widget.remainingTime),
        ],
      ),
    );
  }

  /// QR Code placeholder when image is not available
  Widget _buildQRCodePlaceholder(double size) => Center(
    child: Icon(
      Icons.qr_code_scanner,
      size: size * 0.6,
      color: AppColors.gray400,
    ),
  );
}

/// Timer text widget - only rebuilds when timer state changes
/// This prevents rebuilding the entire QR code section
class _TimerTextWidget extends ConsumerWidget {
  final int remainingTime;

  const _TimerTextWidget({required this.remainingTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch timer state - this widget will rebuild when timer updates
    final timerState = ref.watch(codepayQrTimerProvider(remainingTime));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hết hạn sau: ',
          style: AppTextStyles.labelSmall(color: AppColors.gray300),
        ),
        Text(
          timerState.formattedTime,
          style: AppTextStyles.labelSmall(color: const Color(0xFFEF6820)),
        ),
      ],
    );
  }
}
