import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_casino_result_list.dart';

/// Hiển thị kết quả tìm kiếm game casino (in-data, không gọi API).
///
/// Khi không có kết quả: icon [iconSearchNoResultCasino] + text.
class SearchCasinoResults extends StatelessWidget {
  const SearchCasinoResults({
    required this.games,
    super.key,
    this.onGameTap,
    this.emptyMessage = 'Không tìm thấy kết quả',
  });

  final List<GameBlock> games;
  final void Function(GameBlock game)? onGameTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingStyles.space600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageHelper.load(
                path: AppImages.iconSearchNoResultCasino,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SearchCasinoResultList(games: games, onGameTap: onGameTap);
  }
}
