import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/constants/deposit_constants.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/card_deposit_request.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/cashout_gift_card.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/cashout_gift_card_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/fetch_bank_account_data.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_form_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/state/deposit_state.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/clipboard_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/payment_util.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_field.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

/// Container for Card (Scratch Card) payment method form
class CardContainer extends ConsumerStatefulWidget {
  const CardContainer({super.key});

  @override
  ConsumerState<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends ConsumerState<CardContainer> {
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _cardCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to form changes to sync with provider
    _serialNumberController.addListener(() {
      ref
          .read(cardFormProvider.notifier)
          .updateSerialNumber(_serialNumberController.text);
    });
    _cardCodeController.addListener(() {
      ref
          .read(cardFormProvider.notifier)
          .updateCardCode(_cardCodeController.text);
    });
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _cardCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use select() to only rebuild when specific fields change
    final selectedCardType = ref.watch(
      cardFormProvider.select((state) => state.selectedCardType),
    );
    final formState = ref.watch(cardFormProvider);
    final cardTypesAsync = ref.watch(cardTypeListProvider);
    final denominations = ref.watch(denominationListProvider(selectedCardType));

    // Listen to submit state changes
    ref.listen<CardSubmitState>(cardSubmitNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: () => _handleSubmitSuccess(),
        error: (message) => _handleSubmitError(message),
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
                SizedBox(height: DepositUIConstants.defaultSpacing),
                cardTypesAsync.when(
                  data: (card) => _buildCardSelectionForm(formState, card),
                  loading: () => _buildCardSelectionForm(formState, []),
                  error: (_, __) => _buildCardSelectionForm(formState, []),
                ),
                // Only show denomination if cardTypes exist and a cardType is selected
                if (cardTypesAsync.maybeWhen(
                  data: (cardTypes) =>
                      cardTypes.isNotEmpty && selectedCardType != null,
                  orElse: () => false,
                )) ...[
                  SizedBox(height: DepositUIConstants.defaultSpacing),
                  _buildDenominationForm(formState, denominations),
                  SizedBox(height: 6),
                  _buildActualReceivedAmount(formState),
                ],
                SizedBox(height: DepositUIConstants.defaultSpacing),
                _buildSerialNumberForm(formState),
                SizedBox(height: DepositUIConstants.defaultSpacing),
                _buildCardCodeForm(formState),
                SizedBox(height: DepositUIConstants.bottomSpacing),
              ],
            ),
          ),
        ),
        // Bottom button (fixed)
        _buildBottomButton(formState),
      ],
    );
  }

  /// Card selection form with validation error
  Widget _buildCardSelectionForm(
    CardFormState formState,
    List<CashoutGiftCard> cardTypes,
  ) {
    // If no card types, show empty message (like bank)
    if (cardTypes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Không có thẻ nào',
            style: AppTextStyles.labelMedium(color: AppColors.gray300),
          ),
        ),
      );
    } else {
      // Set default selectedCardType to first item if not selected and list is not empty
      String? selectedCardType = formState.selectedCardType;
      if (selectedCardType == null && cardTypes.isNotEmpty) {
        selectedCardType = cardTypes.first.name;
        // Update provider with default value
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(cardFormProvider.notifier)
                .updateCardType(selectedCardType);
          }
        });
      }

      // Convert card types to menu items
      final menuItems = cardTypes
          .map(
            (cardType) => SelectionMenuItem(
              value: cardType.name,
              label: cardType.name,
              iconUrl: PaymentUtil.getIconPayment(
                name: cardType.name,
                patchIconDefault: cardType.url.isNotEmpty ? cardType.url : '',
              ),
            ),
          )
          .toList();

      return SelectionField(
        label: 'Chọn thẻ',
        placeholder: 'Chọn thẻ',
        selectedValue: formState.selectedCardType,
        errorMessage: formState.cardTypeError,
        items: menuItems,
        onSelected: (value) =>
            ref.read(cardFormProvider.notifier).updateCardType(value),
        iconStyle: SelectionIconStyle.defaultStyle,
      );
    }
  }

  /// Denomination form with validation error
  Widget _buildDenominationForm(
    CardFormState formState,
    List<String> denominations,
  ) {
    final menuItems = denominations
        .map(
          (denomination) =>
              SelectionMenuItem(value: denomination, label: denomination),
        )
        .toList();

    return SelectionField(
      label: 'Mệnh giá',
      placeholder: 'Chọn mệnh giá',
      selectedValue: formState.selectedDenomination,
      errorMessage: formState.denominationError,
      items: menuItems,
      onSelected: (value) =>
          ref.read(cardFormProvider.notifier).updateDenomination(value),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  /// Actual received amount display (Thực nhận)
  Widget _buildActualReceivedAmount(CardFormState formState) {
    final depositConfigAsync = ref.watch(configDepositProvider);

    return depositConfigAsync.when(
      data: (depositData) {
        final actualReceived = _calculateActualReceivedAmount(
          depositData,
          formState.selectedCardType,
          formState.selectedDenomination,
        );

        if (actualReceived == null) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thực nhận',
              style: AppTextStyles.labelXSmall(color: AppColors.gray25),
            ),
            Row(
              children: [
                Text(
                  _formatAmount(actualReceived),
                  style: AppTextStyles.labelXSmall(color: AppColors.yellow400),
                ),
                const Gap(4),
                const SCoinIcon(),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Calculate actual received amount from telcos
  /// Returns gold value from exchangeRates where:
  /// - telcos.name == selectedCard
  /// - exchangeRates.amount == denomination
  int? _calculateActualReceivedAmount(
    FetchBankAccountsData depositData,
    String? selectedCard,
    String? selectedDenomination,
  ) {
    if (selectedCard == null || selectedDenomination == null) {
      return null;
    }

    try {
      final denominationAmount = int.tryParse(
        selectedDenomination.replaceAll(',', '').replaceAll('.', ''),
      );

      if (denominationAmount == null) {
        return null;
      }

      if (depositData.telcos.isEmpty) {
        return null;
      }

      final telco = depositData.telcos.firstWhere(
        (CashoutGiftCard telco) => telco.name == selectedCard,
        orElse: () => depositData.telcos.first,
      );

      // Check if exchangeRates is empty or null
      if (telco.exchangeRates.isEmpty) {
        return null;
      }

      final exchangeRate = telco.exchangeRates.firstWhere((
        Map<String, dynamic> rate,
      ) {
        final rateAmount = rate['amount'];
        if (rateAmount is int) {
          return rateAmount == denominationAmount;
        } else if (rateAmount is String) {
          final parsed = int.tryParse(
            rateAmount.replaceAll(',', '').replaceAll('.', ''),
          );
          return parsed == denominationAmount;
        }
        return false;
      }, orElse: () => <String, dynamic>{});

      if (exchangeRate.isEmpty) {
        return null;
      }

      final gold = exchangeRate['gold'];
      if (gold is int) {
        return gold;
      } else if (gold is String) {
        return int.tryParse(gold.replaceAll(',', '').replaceAll('.', ''));
      } else if (gold is num) {
        return gold.toInt();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Format amount with commas (e.g., 100000 -> "100,000 VND")
  String _formatAmount(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formatted';
  }

  /// Serial number form with validation error
  Widget _buildSerialNumberForm(CardFormState formState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Label
      Text(
        'Số Seri',
        style: AppTextStyles.labelSmall(
          color: AppColors.gray300, // #9c9b95
        ),
      ),
      if (formState.serialNumberError != null) ...[
        const SizedBox(height: 4),
        Text(
          formState.serialNumberError!,
          style: AppTextStyles.labelSmall(color: Colors.red),
        ),
      ],
      const SizedBox(height: 8),
      // Input field with paste button
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900, // #111010
          border: Border.all(
            color: formState.serialNumberError != null
                ? Colors.red
                : AppColors.gray700, // #252423
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Input field
            Expanded(
              child: TextField(
                controller: _serialNumberController,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                decoration: InputDecoration(
                  hintText: '0000 0000 0000 0000',
                  hintStyle: AppTextStyles.paragraphMedium(
                    color: AppColors.gray400, // #74736f
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
            ),
            const Gap(8),
            // Paste button
            InkWell(
              onTap: () => _pasteSerialNumber(),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Dán',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.yellow400, // #fac515
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  /// Card code form with validation error
  Widget _buildCardCodeForm(CardFormState formState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Label
      Text(
        'Mã thẻ',
        style: AppTextStyles.labelSmall(
          color: AppColors.gray300, // #9c9b95
        ),
      ),
      if (formState.cardCodeError != null) ...[
        const SizedBox(height: 4),
        Text(
          formState.cardCodeError!,
          style: AppTextStyles.labelSmall(color: Colors.red),
        ),
      ],
      const SizedBox(height: 8),
      // Input field with paste button
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900, // #111010
          border: Border.all(
            color: formState.cardCodeError != null
                ? Colors.red
                : AppColors.gray700, // #252423
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Input field
            Expanded(
              child: TextField(
                controller: _cardCodeController,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                decoration: InputDecoration(
                  hintText: '0000 0000 0000',
                  hintStyle: AppTextStyles.paragraphMedium(
                    color: AppColors.gray400, // #74736f
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
            ),
            const Gap(8),
            // Paste button
            InkWell(
              onTap: () => _pasteCardCode(),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Dán',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.yellow400, // #fac515
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  /// Paste serial number from clipboard
  Future<void> _pasteSerialNumber() async {
    await ClipboardUtils.pasteToController(
      controller: _serialNumberController,
      onPaste: (text) =>
          ref.read(cardFormProvider.notifier).updateSerialNumber(text),
    );
  }

  /// Paste card code from clipboard
  Future<void> _pasteCardCode() async {
    await ClipboardUtils.pasteToController(
      controller: _cardCodeController,
      onPaste: (text) =>
          ref.read(cardFormProvider.notifier).updateCardCode(text),
    );
  }

  /// Submit button with enable/disable states
  Widget _buildBottomButton(CardFormState formState) {
    final submitState = ref.watch(cardSubmitNotifierProvider);

    // Disable if submitting
    final isSubmitting = submitState.maybeWhen(
      submitting: () => true,
      orElse: () => false,
    );

    final isEnabled = formState.isValid && !isSubmitting;

    return DepositActionButton(
      text: isSubmitting ? 'Đang xử lý...' : 'Xác nhận',
      isEnabled: isEnabled,
      onTap: () => _handleSubmit(formState),
    );
  }

  /// Handle submit button tap
  Future<void> _handleSubmit(CardFormState formState) async {
    // Validate form before submitting
    if (!ref.read(cardFormProvider.notifier).validate()) {
      // Error messages are already displayed in UI
      AppToast.showError(
        context,
        message: DepositErrorMessages.pleaseCheckInfo,
      );
      return;
    }

    // Get deposit config to find selected card and denomination item
    final depositDataAsync = ref.read(configDepositProvider.future);
    final depositData = await depositDataAsync;

    // Find selected card type
    final selectedCard = depositData.cashoutGiftCards.firstWhere(
      (CashoutGiftCard card) => card.name == formState.selectedCardType,
      orElse: () => depositData.cashoutGiftCards.first,
    );

    // Parse selected denomination to numeric value
    final denominationAmount = int.tryParse(
      formState.selectedDenomination!.replaceAll(',', '').replaceAll('.', ''),
    );

    if (denominationAmount == null) {
      if (mounted) {
        AppToast.showError(
          context,
          message: DepositErrorMessages.invalidDenomination,
        );
      }
      return;
    }

    // Check if items is empty
    if (selectedCard.items.isEmpty) {
      if (mounted) {
        AppToast.showError(
          context,
          message: 'Không có mệnh giá nào cho loại thẻ này',
        );
      }
      return;
    }

    // Find denomination item to get telcoId and price
    final denominationItem = selectedCard.items.firstWhere(
      (CashoutGiftCardItem item) =>
          item.active && item.amount == denominationAmount,
      orElse: () => selectedCard.items.firstWhere(
        (CashoutGiftCardItem item) => item.active,
        orElse: () => selectedCard.items.first,
      ),
    );

    // Create request and call API through notifier
    final request = CardDepositRequest(
      serial: formState.serialNumber.trim(),
      code: formState.cardCode.trim(),
      telcoId: denominationItem.telcoId,
      amount: denominationItem.price,
    );

    // Call provider to charge card
    await ref.read(cardSubmitNotifierProvider.notifier).submit(request);
  }

  /// Handle submit success
  void _handleSubmitSuccess() async {
    try {
      // Deposit response is available in notifier if needed

      // Transaction ID is available in depositResponse if needed

      Navigator.of(context).pop();
      await Future<void>.delayed(DepositAnimationDurations.navigationDelay);
      AppToast.showSuccess(context, message: DepositErrorMessages.processing);
    } catch (e) {
      AppToast.showError(context, message: 'Error in _handleSubmitSuccess: $e');
    }
  }

  /// Handle submit error
  void _handleSubmitError(String message) {
    if (!mounted) return;
    AppToast.showError(context, message: message);
  }
}
