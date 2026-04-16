import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';
import 'package:co_caro_flame/s88/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:co_caro_flame/s88/features/search/domain/providers/search_providers.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_casino_empty_content.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_casino_results.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_sport_empty_content.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_sport_results.dart';

/// Phần nội dung search. Logic:
/// - Tab Thể thao: mặc định = Tìm kiếm gần đây + Phổ biến (API getPopularLeagues, 5 giải).
///   Khi có query: gọi API search (events). Kết quả rỗng = icon + text "Không tìm thấy kết quả".
/// - Tab Casino: mặc định = Chơi gần đây + Phổ biến. Search in-data; rỗng = icon + text.
class SearchBody extends ConsumerWidget {
  const SearchBody({
    super.key,
    required this.query,
    required this.isSport,
    this.onRecentKeywordTap,
    this.onCasinoGameTap,
    this.emptyMessageSport = 'Nhập từ khóa để tìm kiếm trận đấu, đội bóng.',
    this.emptyMessageCasino = 'Nhập từ khóa để tìm kiếm game casino.',
    this.emptyResultMessage = 'Không tìm thấy kết quả',
  });

  /// Nội dung ô search hiện tại.
  final String query;

  final bool isSport;
  final ValueChanged<String>? onRecentKeywordTap;

  /// Gọi khi user tap một game trong kết quả search casino (để đóng search và mở game).
  final void Function(GameBlock game)? onCasinoGameTap;

  final String emptyMessageSport;
  final String emptyMessageCasino;

  /// Hiển thị khi đã search nhưng trả về rỗng.
  final String emptyResultMessage;

  void _onSearchResultTap(
    BuildContext context,
    WidgetRef ref,
    SearchResultItem item,
  ) {
    Navigator.of(context).pop(); // Close search dialog/bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sport = SportType.fromId(item.sportId) ?? SportType.soccer;
      SbHttpManager.instance.sportTypeId = sport.id;
      ref.read(selectedSportV2Provider.notifier).state = sport;
      ref.read(selectedEventV2Provider.notifier).state = item.toEventModelV2();
      ref.read(selectedLeagueV2Provider.notifier).state = item.toLeagueModelV2();
      ref.read(mainContentProvider.notifier).goToBetDetail();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryTrimmed = query.trim();

    // Trạng thái chưa search / đã clear
    if (queryTrimmed.isEmpty) {
      // Tab Casino: chỉ Chơi gần đây (game đã click) + Phổ biến, không hiển thị tìm kiếm gần đây
      if (!isSport) {
        final recentBlocks = ref.watch(casinoRecentGameBlocksProvider);
        final popularBlocks = ref.watch(casinoPopularGamesProvider).value ?? [];
        final allGamesAsync = ref.watch(allGamesProvider);

        return Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: allGamesAsync.when(
              data: (_) => SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacingStyles.space400),
                child: SearchCasinoEmptyContent(
                  recentBlocks: recentBlocks,
                  popularBlocks: popularBlocks,
                  onGameTap: (game) {
                    CasinoRecentGamesStorage.addGame(
                      game.providerId,
                      game.productId,
                      game.gameCode,
                    ).then((_) => ref.invalidate(casinoRecentKeysProvider));
                    onCasinoGameTap?.call(game);
                  },
                ),
              ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacingStyles.space600),
                child: CircularProgressIndicator(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                err.toString(),
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ),
        );
      }

      // Tab Thể thao: Tìm kiếm gần đây + Phổ biến (API getPopularLeagues, 5 giải)
      return Expanded(
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SearchSportEmptyContent(
            onRecentKeywordTap: onRecentKeywordTap ?? (_) {},
            onSearchResultTap: (item) => _onSearchResultTap(context, ref, item),
          ),
        ),
      );
    }

    // Đã có text: đang ở chế độ search. DebouncedQuery set sau debounce hoặc tap recent.
    final debouncedQuery = ref.watch(searchDebouncedQueryProvider);

    if (debouncedQuery.isEmpty) {
      return Expanded(
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacingStyles.space600),
              child: CircularProgressIndicator(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ),
      );
    }

    // Tab Casino: search in-data (allGamesProvider), không gọi API
    if (!isSport) {
      final allGamesAsync = ref.watch(allGamesProvider);
      final casinoResults = ref.watch(casinoSearchResultsProvider);

      return Expanded(
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: allGamesAsync.when(
            data: (_) => SearchCasinoResults(
              games: casinoResults,
              onGameTap: onCasinoGameTap,
              emptyMessage: emptyResultMessage,
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacingStyles.space600),
                child: CircularProgressIndicator(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacingStyles.space400),
                child: Text(
                  err.toString(),
                  style: AppTextStyles.paragraphSmall(
                    color: AppColorStyles.contentTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Tab Thể thao: gọi API search (events). Empty = icon + text như casino.
    final asyncResult = ref.watch(searchResultProvider(debouncedQuery));
    return Expanded(
      child: ScrollConfiguration(
        behavior:
            ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: asyncResult.when(
          data: (model) => SearchSportResults(
            events: model.events,
            emptyMessage: emptyResultMessage,
            onSearchResultTap: (item) =>
                _onSearchResultTap(context, ref, item),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacingStyles.space600),
              child: CircularProgressIndicator(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingStyles.space400),
              child: Text(
                err.toString(),
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
