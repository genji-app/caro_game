import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_address_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/crypto_option.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_form_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/crypto/crypto_confirm_money_transfer_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/crypto_confirm_money_transfer_overlay.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Container for Crypto payment method form
class CryptoContainer extends ConsumerStatefulWidget {
  const CryptoContainer({super.key});

  @override
  ConsumerState<CryptoContainer> createState() => _CryptoContainerState();
}

class _CryptoContainerState extends ConsumerState<CryptoContainer> {
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
    final formState = ref.watch(cryptoFormProvider);
    final cryptosAsync = ref.watch(cryptoListProvider);
    // Listen to submit state changes
    ref.listen<CryptoSubmitState>(cryptoSubmitNotifierProvider, (
      previous,
      next,
    ) {
      next.maybeWhen(
        success: () => _handleGetCryptoAddressSuccess(),
        error: (message) => _handleGetCryptoAddressError(message),
        orElse: () {},
      );
    });

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
                cryptosAsync.when(
                  data: (cryptos) =>
                      _buildCryptoSelectionForm(formState, cryptos),
                  loading: () => _buildCryptoSelectionForm(formState, []),
                  error: (_, __) => _buildCryptoSelectionForm(formState, []),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Crypto selection form
  Widget _buildCryptoSelectionForm(
    CryptoFormState formState,
    List<CryptoOption> cryptos,
  ) {
    debugPrint('✅ cryptos: ${cryptos.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Loại tiền',
          style: AppTextStyles.labelSmall(
            color: AppColors.gray300, // #9c9b95
          ),
        ),
        if (formState.cryptoError != null) ...[
          const SizedBox(height: 4),
          Text(
            formState.cryptoError!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 8),
        // Crypto options container
        cryptos.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Không có loại tiền nào',
                    style: AppTextStyles.labelMedium(color: AppColors.gray300),
                  ),
                ),
              )
            : Column(
                children: [
                  // Crypto options list
                  for (int index = 0; index < cryptos.length; index++)
                    Builder(
                      builder: (context) {
                        final crypto = cryptos[index];
                        final isLast = index == cryptos.length - 1;

                        return InkWell(
                          onTap: () => _handleCryptoItemTap(crypto),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                        color: AppColors.gray700,
                                        width: 0.75,
                                      ),
                                    ),
                            ),
                            child: Row(
                              children: [
                                // Crypto icon
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child:
                                        _isWebP(_getCryptoIconPath(crypto.name))
                                        ? ImageHelper.getNetworkImage(
                                            imageUrl: _getCryptoIconPath(
                                              crypto.name,
                                            ),
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          )
                                        : ImageHelper.load(
                                            path: _getCryptoIconPath(
                                              crypto.name,
                                            ),
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const Gap(8),
                                // Crypto name and network
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        crypto.name,
                                        style: AppTextStyles.paragraphMedium(
                                          color: AppColors.gray25,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${crypto.name} - ${crypto.network}',
                                        style: AppTextStyles.paragraphXSmall(
                                          color: AppColors.gray300, // #9c9b95
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price
                                Row(
                                  children: [
                                    Text(
                                      crypto.price,
                                      style: AppTextStyles.paragraphMedium(
                                        color: AppColors.yellow300, // #fde272
                                      ),
                                    ),
                                    const Row(children: [Gap(4), SCoinIcon()]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
      ],
    );
  }

  /// Handle crypto item tap - call API and navigate to confirm screen
  Future<void> _handleCryptoItemTap(CryptoOption crypto) async {
    // Update provider with selected crypto
    ref.read(cryptoFormProvider.notifier).updateCrypto(crypto.id);

    // Validate
    if (!ref.read(cryptoFormProvider.notifier).validate()) {
      return;
    }

    // Call API to get crypto address
    final request = CryptoAddressRequest(
      network: crypto.network, // e.g., "TRC20"
      currencyName: crypto.name, // e.g., "USDT"
      fiatCurrency: 'VND',
    );

    // Call API through notifier
    await ref
        .read(cryptoSubmitNotifierProvider.notifier)
        .getCryptoAddress(request);
  }

  /// Handle API success - navigate to confirm screen
  void _handleGetCryptoAddressSuccess() {
    final cryptoAddressResponse = ref
        .read(cryptoSubmitNotifierProvider.notifier)
        .cryptoAddressResponse;

    if (cryptoAddressResponse == null) {
      debugPrint('⚠️ Crypto address response is null');
      return;
    }

    // Get selected crypto from form state
    final formState = ref.read(cryptoFormProvider);
    final cryptosAsync = ref.read(cryptoListProvider);

    // Get crypto option to find the selected one
    cryptosAsync.whenData((cryptos) {
      final selectedCrypto = cryptos.firstWhere(
        (c) => c.id == formState.selectedCrypto,
        orElse: () => cryptos.first,
      );

      // Get root context for navigation
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      final navigator = DepositNavigator();

      // Use DepositNavigator for consistent navigation flow
      navigator.push(
        context: rootContext,
        mobileShowMethod: (ctx) => CryptoConfirmMoneyTransferBottomSheet.show(
          ctx,
          cryptoAddressResponse: cryptoAddressResponse,
          cryptoOption: selectedCrypto,
          paymentMethod: PaymentMethod.crypto,
        ),
        webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
          context: ctx,
          builder: (dialogContext, animation, secondaryAnimation) =>
              CryptoConfirmMoneyTransferOverlay(
                cryptoAddressResponse: cryptoAddressResponse,
                cryptoOption: selectedCrypto,
                paymentMethod: PaymentMethod.crypto,
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
                  .selectPaymentMethod(PaymentMethod.crypto);
            }
          }
        },
      );
    });
  }

  /// Handle API error
  void _handleGetCryptoAddressError(String message) {
    if (!mounted) return;
    AppToast.showError(context, message: message);
  }
}
