import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/search/domain/providers/search_providers.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_recent_section.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_result_row.dart';

/// Nội dung tab Thể thao khi chưa search: Tìm kiếm gần đây + Phổ biến (5 giải từ API).
class SearchSportEmptyContent extends ConsumerWidget {
  const SearchSportEmptyContent({
    super.key,
    required this.onRecentKeywordTap,
    this.onSearchResultTap,
  });

  final ValueChanged<String> onRecentKeywordTap;

  /// Called when a search result row is tapped (navigate to bet detail).
  final void Function(SearchResultItem item)? onSearchResultTap;

  static const String _sectionPopular = 'Phổ biến';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(searchPopularLeaguesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacingStyles.space400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchRecentSection(isSport: true, onKeywordTap: onRecentKeywordTap),
          const Gap(AppSpacingStyles.space400),
          Text(
            _sectionPopular,
            style: AppTextStyles.labelLarge(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(12),
          popularAsync.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: items
                    .map<Widget>(
                      (item) => SearchResultRow(
                        item: item,
                        onTap: onSearchResultTap != null
                            ? () => onSearchResultTap!(item)
                            : null,
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacingStyles.space600),
                child: CircularProgressIndicator(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
