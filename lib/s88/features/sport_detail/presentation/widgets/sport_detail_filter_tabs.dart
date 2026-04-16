import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';

/// Reusable filter tabs for sport detail screens
///
/// Supports both mobile (horizontal scroll) and desktop (expanded) layouts
/// Tab "Đặc biệt" (special) only shows when sportId == 1 (bóng đá)
class SportDetailFilterTabs extends ConsumerWidget {
  final bool isDesktop;
  final ValueChanged<SportDetailFilterType>? onFilterChanged;

  const SportDetailFilterTabs({
    super.key,
    this.isDesktop = false,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dùng select để chỉ watch field id, tránh rebuild khi các field khác thay đổi
    final sportId = ref.watch(selectedSportV2Provider.select((s) => s.id));

    // Filter: only show "Đặc biệt" tab when sportId == 1 (bóng đá)
    final filters = SportDetailFilterType.values
        .where(
          (filter) => filter != SportDetailFilterType.special || sportId == 1,
        )
        .toList();

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: Row(
        children: filters.map((filter) {
          return Expanded(
            child: _FilterTab(
              filter: filter,
              isDesktop: isDesktop,
              onFilterChanged: onFilterChanged,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Widget riêng cho mỗi tab, chỉ rebuild khi selectedFilter thay đổi
class _FilterTab extends ConsumerWidget {
  final SportDetailFilterType filter;
  final bool isDesktop;
  final ValueChanged<SportDetailFilterType>? onFilterChanged;

  const _FilterTab({
    required this.filter,
    required this.isDesktop,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mỗi tab chỉ watch và so sánh với filter của chính nó
    final isSelected = ref.watch(
      sportDetailTabProvider.select((selected) => selected == filter),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onFilterChanged?.call(filter),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                bottom: 0,
                left: isDesktop ? 0 : -20,
                right: isDesktop ? 0 : -20,
                child: ImageHelper.load(
                  path: AppIcons.sportStatusSelected,
                  fit: BoxFit.fill,
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 16 : 12,
                horizontal: isDesktop ? 24 : 12,
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: AppTextStyles.textStyle(
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.yellow300
                        : const Color(0xFF9C9B95),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
