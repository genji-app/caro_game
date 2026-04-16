import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Text input section with input field and clear button
class TextInputSection extends StatelessWidget {
  /// Label text for the input field
  final String label;

  /// Text editing controller for text input
  final TextEditingController controller;

  /// Placeholder text for input field
  final String? placeholder;

  /// Keyboard type (default: TextInputType.text)
  final TextInputType keyboardType;

  /// Whether to show clear button (default: true)
  final bool showClearButton;

  const TextInputSection({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.showClearButton = true,
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
                  keyboardType: keyboardType,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                  decoration: InputDecoration(
                    hintText: placeholder ?? 'Nhập thông tin',
                    hintStyle: AppTextStyles.paragraphMedium(
                      color: AppColors.gray400, // #74736f
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // Close icon - chỉ hiển thị khi có text và showClearButton = true
              if (showClearButton)
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
            ],
          ),
        ),
      ],
    );
  }
}
