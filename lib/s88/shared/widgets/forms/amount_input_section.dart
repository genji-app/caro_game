import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/quick_amount_buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';

/// Default quick amount buttons configuration
class DefaultQuickAmountButtons {
  DefaultQuickAmountButtons._();

  /// Default quick amount buttons map for deposit/withdraw
  static const Map<String, String> defaultAmounts = {
    '+50K': '50,000',
    '+100K': '100,000',
    '+500K': '500,000',
    '+1M': '1,000,000',
    '+5M': '5,000,000',
    '+10M': '10,000,000',
    '+50M': '50,000,000',
    '+100M': '100,000,000',
  };
}

/// Amount input section with input field and quick amount buttons
class AmountInputSection extends StatelessWidget {
  /// Label text for the input field
  final String label;

  /// Text editing controller for amount input
  final TextEditingController controller;

  /// Placeholder text for input field
  final String? placeholder;

  // /// Currency label (e.g., 'VND')
  // final String currencyLabel;

  /// Map of quick amount buttons (label -> value)
  /// Example: {'+50K': '50,000', '+100K': '100,000'}
  final Map<String, String> quickAmountButtons;

  /// Spacing between input and quick buttons (default: 16)
  final double spacing;

  const AmountInputSection({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    required this.quickAmountButtons,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(label, style: AppTextStyles.labelSmall(color: AppColors.gray25)),
        const SizedBox(height: 6),
        // Input field
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray900, // #111010
            border: Border.all(
              color: AppColors.gray700, // #252423
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Input text
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                  decoration: InputDecoration(
                    hintText: placeholder ?? 'Nhập số tiền',
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
              // Close icon - chỉ hiển thị khi có text
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  if (value.text.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        controller.clear();
                      },
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
              // Currency label
              const SCoinIcon(),
            ],
          ),
        ),
        SizedBox(height: spacing),
        // Quick amount buttons
        QuickAmountButtons(
          buttons: quickAmountButtons.entries
              .map(
                (entry) =>
                    QuickAmountButton(label: entry.key, value: entry.value),
              )
              .toList(),
          onButtonTap: (value) {
            // Update controller and trigger rebuild
            controller.value = TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            );
          },
        ),
      ],
    );
  }
}
