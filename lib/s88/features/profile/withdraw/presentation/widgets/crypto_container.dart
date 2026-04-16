import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/crypto_deposit_option.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/widgets/withdraw_crypto.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/models/withdraw_crypto_option.dart';

/// Crypto container for withdraw
class WithdrawCryptoContainer extends ConsumerStatefulWidget {
  const WithdrawCryptoContainer({super.key});

  @override
  ConsumerState<WithdrawCryptoContainer> createState() =>
      _WithdrawCryptoContainerState();
}

class _WithdrawCryptoContainerState
    extends ConsumerState<WithdrawCryptoContainer> {
  String? _selectedCryptoId;

  /// Format amount with commas
  /// Example: 86548696 -> "86,548,696"
  String _formatAmount(int amount) {
    if (amount < 0) {
      return '-${_formatAmount(-amount)}';
    }

    final amountStr = amount.toString();
    final length = amountStr.length;

    // No need to format if 3 digits or less
    if (length <= 3) {
      return amountStr;
    }

    // Use StringBuffer for efficient string building
    final buffer = StringBuffer();

    // Build formatted string from left to right
    // Insert comma after every 3 digits from the right
    final remainder = length % 3;
    final firstGroupSize = remainder == 0 ? 3 : remainder;

    // Write first group
    buffer.write(amountStr.substring(0, firstGroupSize));

    // Write remaining groups with commas
    for (int i = firstGroupSize; i < length; i += 3) {
      buffer.write(',');
      buffer.write(amountStr.substring(i, i + 3));
    }

    return buffer.toString();
  }

  /// Format price with currency symbol
  /// Example: 86548696 -> "₫86,548,696"
  String _formatPrice(int price) {
    final formatted = _formatAmount(price);
    return '₫$formatted';
  }

  /// Convert CryptoDepositOption to WithdrawCryptoOption
  List<WithdrawCryptoOption> _convertCryptoOptions(
    List<CryptoDepositOption> cryptoOptions,
  ) {
    final List<WithdrawCryptoOption> result = [];

    for (final CryptoDepositOption crypto in cryptoOptions) {
      // Use depositNetworks if available, otherwise use network field
      final networks = crypto.depositNetworks.isNotEmpty
          ? crypto.depositNetworks
          : [crypto.network];

      for (final String network in networks) {
        if (network.isEmpty) {
          continue;
        }

        // Create full name: "CurrencyName - Network"
        final fullName = '${crypto.currencyName} - $network';

        // Create unique ID: "currencyName_network" (lowercase)
        final id =
            '${crypto.currencyName.toLowerCase()}_${network.toLowerCase()}';

        // Format price like deposit: always use _formatPrice for consistent formatting
        final price = _formatPrice(crypto.exchangeRate);

        result.add(
          WithdrawCryptoOption(
            id: id,
            name: crypto.currencyName,
            network: network,
            fullName: fullName,
            price: price,
          ),
        );
      }
    }

    return result;
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
        return AppIcons.icCryptoUsdt;
    }
  }

  /// Check if icon is WebP format
  bool _isWebP(String path) {
    return path.toLowerCase().endsWith('.webp');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                depositConfigAsync.when(
                  data: (depositData) {
                    final cryptoOptions = _convertCryptoOptions(
                      depositData.crypto,
                    );
                    return _buildCryptoSelectionForm(cryptoOptions);
                  },
                  loading: () => _buildCryptoSelectionForm([]),
                  error: (_, __) => _buildCryptoSelectionForm([]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoSelectionForm(List<WithdrawCryptoOption> cryptoOptions) {
    // Auto-select first crypto if none selected
    if (_selectedCryptoId == null && cryptoOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCryptoId = cryptoOptions.first.id;
          });
        }
      });
    }

    if (cryptoOptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có loại tiền nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại tiền',
          style: AppTextStyles.labelSmall(color: AppColors.gray25),
        ),
        const SizedBox(height: 6),
        Column(
          children: [
            for (int i = 0; i < cryptoOptions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _buildCryptoItem(cryptoOptions[i], i < cryptoOptions.length - 1),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCryptoItem(WithdrawCryptoOption crypto, bool showDivider) {
    return GestureDetector(
      onTap: () {
        // Navigate to WithdrawCrypto screen
        final rootContext = Navigator.of(context, rootNavigator: true).context;
        final deviceType = ResponsiveBuilder.getDeviceType(rootContext);

        if (deviceType == DeviceType.mobile) {
          // Show as bottom sheet for mobile
          showGeneralDialog(
            context: rootContext,
            barrierColor: Colors.black.withOpacity(0.5),
            barrierDismissible: true,
            barrierLabel: MaterialLocalizations.of(
              rootContext,
            ).modalBarrierDismissLabel,
            transitionDuration: const Duration(milliseconds: 300),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              final slideAnimation =
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
              return SlideTransition(position: slideAnimation, child: child);
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: const BoxDecoration(
                    color: AppColors.gray950,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: WithdrawCrypto(selectedCrypto: crypto),
                ),
              );
            },
          );
        } else {
          // Show as overlay for web/tablet
          showGeneralDialog(
            context: rootContext,
            barrierColor: Colors.black.withOpacity(0.5),
            barrierDismissible: true,
            barrierLabel: MaterialLocalizations.of(
              rootContext,
            ).modalBarrierDismissLabel,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (context, animation, secondaryAnimation) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(40),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: AppColors.gray950,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: WithdrawCrypto(selectedCrypto: crypto),
                ),
              );
            },
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _isWebP(_getCryptoIconPath(crypto.name))
                        ? ImageHelper.getNetworkImage(
                            imageUrl: _getCryptoIconPath(crypto.name),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : ImageHelper.load(
                            path: _getCryptoIconPath(crypto.name),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crypto.name,
                        style: AppTextStyles.paragraphMedium(
                          color: AppColors.gray25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        crypto.fullName,
                        style: AppTextStyles.paragraphXSmall(
                          color: AppColors.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  crypto.price,
                  style: AppTextStyles.paragraphMedium(
                    color: AppColors.yellow300,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          // Divider at bottom
          if (showDivider)
            Container(
              height: 1,
              margin: const EdgeInsets.only(
                left: 64,
              ), // Align with content (icon + spacing)
              color: AppColors.gray700,
            ),
        ],
      ),
    );
  }

  // Removed unused methods - functionality moved to WithdrawCrypto screen
}
