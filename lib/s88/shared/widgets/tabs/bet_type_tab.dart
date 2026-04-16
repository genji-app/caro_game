import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

class BetTypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const BetTypeTab({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.textStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
      ),
    );
  }
}
