import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/cashout_gift_card.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/cashout_gift_card_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/payment_util.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/entities/withdraw_card_request.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_providers.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/mobile/withdraw_waiting_payment_confirm_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/web_tablet/withdraw_waiting_payment_confirm_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/deposit_action_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_field.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

/// Card container for withdraw
class WithdrawCardContainer extends ConsumerStatefulWidget {
  const WithdrawCardContainer({super.key});

  @override
  ConsumerState<WithdrawCardContainer> createState() =>
      _WithdrawCardContainerState();
}

class _WithdrawCardContainerState extends ConsumerState<WithdrawCardContainer> {
  String? _selectedCardType;
  String? _selectedDenomination;
  int _quantity = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardTypesAsync = ref.watch(cardTypeListProvider);
    final denominations = ref.watch(
      denominationListProvider(_selectedCardType),
    );

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
                cardTypesAsync.when(
                  data: (cardTypes) => _buildCardTypeSelectionForm(cardTypes),
                  loading: () => _buildCardTypeSelectionForm([]),
                  error: (_, __) => _buildCardTypeSelectionForm([]),
                ),
                const SizedBox(height: 24),
                _buildDenominationForm(denominations),
                const SizedBox(height: 24),
                _buildQuantityForm(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildCardTypeSelectionForm(List<CashoutGiftCard> cardTypes) {
    if (cardTypes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có loại thẻ nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    }

    if (_selectedCardType == null && cardTypes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCardType = cardTypes.first.name;
          });
        }
      });
    }

    final menuItems = cardTypes
        .map(
          (cardType) => SelectionMenuItem(
            value: cardType.name,
            label: cardType.name,
            iconUrl: PaymentUtil.getIconPayment(
              name: cardType.name,
              patchIconDefault: cardType.url.toString().toLowerCase(),
            ),
          ),
        )
        .toList();

    return SelectionField(
      label: 'Chọn thẻ',
      placeholder: 'Chọn thẻ',
      selectedValue: _selectedCardType,
      items: menuItems,
      onSelected: (value) {
        setState(() {
          _selectedCardType = value;
          _selectedDenomination = null;
        });
      },
      iconStyle: SelectionIconStyle.defaultStyle,
    );
  }

  Widget _buildDenominationForm(List<String> denominations) {
    if (denominations.isEmpty) {
      return const SizedBox.shrink();
    }

    final denominationButtons = denominations.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mệnh giá',
          style: AppTextStyles.labelSmall(color: AppColors.gray25),
        ),
        const SizedBox(height: 6),
        Column(
          children: [
            // Row 1: First 3 items (0, 1, 2)
            Row(
              children: [
                for (
                  int i = 0;
                  i < 3 && i < denominationButtons.length;
                  i++
                ) ...[
                  Expanded(
                    child: _buildDenominationButton(denominationButtons[i]),
                  ),
                  if (i < 2 && i < denominationButtons.length - 1) const Gap(8),
                ],
              ],
            ),
            // Row 2: Next 3 items (3, 4, 5)
            if (denominationButtons.length > 3) ...[
              const Gap(8),
              Row(
                children: [
                  for (
                    int i = 3;
                    i < 6 && i < denominationButtons.length;
                    i++
                  ) ...[
                    Expanded(
                      child: _buildDenominationButton(denominationButtons[i]),
                    ),
                    if (i < 5 && i < denominationButtons.length - 1)
                      const Gap(8),
                  ],
                ],
              ),
            ],
            // Row 3: Remaining items (6, 7) - 2 items max for better mobile layout
            if (denominationButtons.length > 6) ...[
              const Gap(8),
              Row(
                children: [
                  for (int i = 6; i < denominationButtons.length; i++) ...[
                    Expanded(
                      child: _buildDenominationButton(denominationButtons[i]),
                    ),
                    if (i < denominationButtons.length - 1) const Gap(8),
                  ],
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDenominationButton(String denomination) {
    final isSelected = _selectedDenomination == denomination;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDenomination = denomination;
        });
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray700,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.yellow700, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            denomination,
            style: AppTextStyles.paragraphMedium(color: AppColors.yellow200),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Số lượng thẻ muốn rút',
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (_quantity > 1) {
                  setState(() {
                    _quantity--;
                  });
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.yellow300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, size: 16, color: Colors.black),
              ),
            ),
            const Gap(8),
            Text(
              _quantity.toString(),
              style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
            ),
            const Gap(8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _quantity++;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.yellow300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildBottomButton() {
    final isValid = _selectedCardType != null && _selectedDenomination != null;

    return DepositActionButton(
      text: _isSubmitting ? 'Đang xử lý...' : 'Rút tiền',
      isEnabled: isValid && !_isSubmitting,
      onTap: isValid && !_isSubmitting ? _handleSubmit : null,
    );
  }

  /// Find itemId from cashoutGiftCards based on selected card type and denomination
  String? _findItemId(String? cardTypeName, String? denomination) {
    if (cardTypeName == null || denomination == null) {
      return null;
    }

    final depositDataAsync = ref.read(configDepositProvider);
    return depositDataAsync.when(
      data: (depositData) {
        try {
          // Find the selected card by name
          final selectedCard = depositData.cashoutGiftCards.firstWhere(
            (CashoutGiftCard card) => card.name == cardTypeName,
          );

          // Parse denomination amount (remove commas and " VND")
          final denominationAmount = int.tryParse(
            denomination.replaceAll(',', '').replaceAll(' VND', ''),
          );

          if (denominationAmount == null) {
            return null;
          }

          // Find item with matching amount and active status
          final matchingItem = selectedCard.items.firstWhere(
            (CashoutGiftCardItem item) =>
                item.amount == denominationAmount && item.active,
            orElse: () => selectedCard.items.first,
          );

          return matchingItem.id;
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final rootContext = context;

    // Find itemId from cashoutGiftCards
    final itemId = _findItemId(_selectedCardType, _selectedDenomination);
    if (itemId == null) {
      if (mounted) {
        AppToast.showError(
          rootContext,
          message: 'Không tìm thấy thông tin thẻ. Vui lòng thử lại.',
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API
      final useCase = ref.read(submitWithdrawCardUseCaseProvider);
      final request = WithdrawCardRequest(itemId: itemId);
      final result = await useCase(request);

      result.fold(
        // Error
        (failure) {
          if (mounted) {
            AppToast.showError(rootContext, message: failure.message);
          }
        },
        // Success
        (response) {
          // Calculate total amount
          final denominationString = _selectedDenomination!
              .replaceAll(',', '')
              .replaceAll(' VND', '');
          final denominationValue = int.tryParse(denominationString) ?? 0;
          final totalAmount = (denominationValue * _quantity).toString();

          // Create confirmation data
          final confirmationData = WithdrawConfirmationData(
            amount: totalAmount,
            id: response.data.message ?? '',
            methodType: WithdrawPaymentMethodType.card,
            cardType: _selectedCardType,
            quantity: _quantity,
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
