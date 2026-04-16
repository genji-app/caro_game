import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_result_list.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';

/// Kết quả tìm kiếm tab Thể thao.
///
/// Khi [events] rỗng: hiển thị icon [iconSearchNoResultSport] + text (giống tab Casino).
/// Khi có data: hiển thị [SearchResultList].
class SearchSportResults extends StatelessWidget {
  const SearchSportResults({
    super.key,
    required this.events,
    this.emptyMessage = 'Không tìm thấy kết quả',
    this.onSearchResultTap,
  });

  final List<SearchResultItem> events;
  final String emptyMessage;

  /// Called when a search result row is tapped (navigate to bet detail).
  final void Function(SearchResultItem item)? onSearchResultTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SportEmptyPage(message: 'Không tìm thấy kết quả.');
    }

    return SearchResultList(
      events: events,
      emptyMessage: emptyMessage,
      onSearchResultTap: onSearchResultTap,
    );
  }
}
