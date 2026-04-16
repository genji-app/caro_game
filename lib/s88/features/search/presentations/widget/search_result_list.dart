import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_result_row.dart';

/// Danh sách kết quả search. Hiển thị ListView hoặc empty/not found. Dùng chung cho dialog và mobile.
class SearchResultList extends StatelessWidget {
  const SearchResultList({
    super.key,
    required this.events,
    this.padding,
    this.emptyMessage = 'Không tìm thấy kết quả',
    this.onSearchResultTap,
  });

  final List<SearchResultItem> events;

  /// Padding cho ListView. Mặc định dùng spacing chuẩn.
  final EdgeInsetsGeometry? padding;

  /// Text hiển thị khi events rỗng.
  final String emptyMessage;

  /// Called when a search result row is tapped (navigate to bet detail).
  final void Function(SearchResultItem item)? onSearchResultTap;

  static const EdgeInsets _defaultPadding = EdgeInsets.fromLTRB(
    AppSpacingStyles.space400,
    AppSpacingStyles.space200,
    AppSpacingStyles.space400,
    AppSpacingStyles.space400,
  );

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTextStyles.paragraphSmall(
            color: AppColorStyles.contentTertiary,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: padding ?? _defaultPadding,
      itemCount: events.length,
      cacheExtent: 200,
      itemBuilder: (context, index) {
        final item = events[index];
        return RepaintBoundary(
          key: ValueKey<int>(item.eventId),
          child: SearchResultRow(
            item: item,
            onTap: onSearchResultTap != null
                ? () => onSearchResultTap!(item)
                : null,
          ),
        );
      },
    );
  }
}
