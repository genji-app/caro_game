import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';

/// Empty state khi chưa nhập từ khóa search. Dùng chung cho dialog và mobile.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.message,
    this.minHeight = 320,
  });

  /// Nội dung gợi ý hiển thị (vd: "Nhập từ khóa để tìm kiếm trận đấu, đội bóng.")
  final String message;

  /// Chiều cao tối thiểu của vùng empty.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacingStyles.space600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_rounded,
                size: 48,
                color: AppColorStyles.contentQuaternary,
              ),
              const Gap(AppSpacingStyles.space300),
              Text(
                message,
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
