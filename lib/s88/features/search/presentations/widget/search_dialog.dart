import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:co_caro_flame/s88/features/search/data/storage/search_recent_storage.dart';
import 'package:co_caro_flame/s88/features/search/domain/providers/search_providers.dart';
import 'package:co_caro_flame/s88/features/search/presentations/mobile/search_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_body.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_tabs.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Tab type in search dialog: Thể thao | Casino
enum SearchDialogTab { sport, casino }

/// Search dialog for desktop/tablet (Figma: Sun Sport - Search).
///
/// - Dark panel with search field and optional results
/// - Close via X button or Escape
/// - Call [SearchDialog.show] to present; returns when dismissed.
/// - On mobile use [SearchDialog.showAsFullHeightBottomSheet] for full-height bottom sheet.
class SearchDialog extends ConsumerStatefulWidget {
  const SearchDialog({super.key, this.asFullHeightBottomSheet = false});

  final bool asFullHeightBottomSheet;

  /// Shows the search dialog. Pops when closed (barrier or close button).
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: false, // Chỉ đóng khi bấm icon close
      builder: (ctx) => const SearchDialog(),
    );
  }

  /// Shows search as full-height bottom sheet (mobile). Delegates to [SearchMobileScreen.showAsBottomSheet].
  static Future<void> showAsFullHeightBottomSheet(BuildContext context) {
    return SearchMobileScreen.showAsBottomSheet(context);
  }

  @override
  ConsumerState<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedTabIndex = 0;
  Timer? _debounceTimer;

  /// Giá trị đang chờ debounce; dùng để (1) không reset timer khi IME gửi onChanged trùng, (2) fallback khi timer fire mà _controller.text rỗng (IME chưa commit).
  String _debouncePendingValue = '';

  /// Sau 500ms không có input thì gọi API search (không cần submit). Timer fire → _commitQuery → debouncedQuery luôn được set.
  static const _debounceDuration = Duration(milliseconds: 500);

  SearchDialogTab get _currentTab =>
      _selectedTabIndex == 0 ? SearchDialogTab.sport : SearchDialogTab.casino;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Commit query: set debouncedQuery; tab Thể thao invalidate + lưu recent; tab Casino chỉ set query (không lưu từ khóa).
  void _commitQuery(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    ref.read(searchDebouncedQueryProvider.notifier).state = query;
    if (_currentTab == SearchDialogTab.sport) {
      ref.invalidate(searchResultProvider(query));
      SearchRecentStorage.addRecentSport(query);
      ref.invalidate(searchRecentSportProvider);
    }
    setState(() {});
  }

  /// Xử lý thay đổi ô search: clear hoặc debounce (gõ text). Sau 500ms không onChanged, timer fire → commit → API được gọi.
  /// - Không reset timer khi value.trim() trùng _debouncePendingValue (tránh IME gửi onChanged trùng làm hủy timer).
  /// - Khi timer fire dùng _controller.text.trim(), nếu rỗng (IME chưa commit) thì dùng _debouncePendingValue.
  void _onSearchChanged(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      _debouncePendingValue = '';
      _debounceTimer?.cancel();
      ref.read(searchDebouncedQueryProvider.notifier).state = '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }

    // IME có thể gửi onChanged nhiều lần cùng giá trị → không cancel timer để tránh không bao giờ đủ 500ms.
    if (trimmed == _debouncePendingValue) return;
    // Đã commit đúng query này rồi (vd. vừa click recent) → không tạo timer mới.
    if (trimmed == ref.read(searchDebouncedQueryProvider)) return;
    _debouncePendingValue = trimmed;
    _debounceTimer?.cancel();
    setState(
      () {},
    ); // Rebuild để SearchBody nhận query mới và hiện loading chờ debounce.

    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      final current = _controller.text.trim();
      final toCommit = current.isNotEmpty ? current : _debouncePendingValue;
      if (toCommit.isNotEmpty) {
        _commitQuery(toCommit);
      }
      _debouncePendingValue = '';
    });
  }

  /// Bấm item recent: commit ngay (set debouncedQuery + invalidate searchResultProvider) để gọi API.
  void _onRecentKeywordTap(String keyword) {
    _controller.text = keyword;
    _onSearchChanged(keyword);
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _onCasinoGameTap(GameBlock game) async {
    await CasinoRecentGamesStorage.addGame(
      game.providerId,
      game.productId,
      game.gameCode,
    );
    ref.invalidate(casinoRecentKeysProvider);

    if (!mounted) return;
    _close(); // close search dialog
    if (mounted) {
      GamePlayerScreen.push(context, ref, game: game);
    } else if (mounted) {
      AppToast.showError(context, message: I18n.msgSomethingWentWrong);
    }
  }

  Widget _buildSearchContent({bool expandBody = false}) {
    final body = SearchBody(
      query: _controller.text,
      isSport: _currentTab == SearchDialogTab.sport,
      onRecentKeywordTap: _onRecentKeywordTap,
      onCasinoGameTap: _onCasinoGameTap,
    );
    return Column(
      mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 8,
          ),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.paragraphMedium(
                color: AppColorStyles.contentPrimary,
              ),
              decoration: InputDecoration(
                hintText: _currentTab == SearchDialogTab.sport
                    ? 'Tìm kiếm trận đấu, đội bóng...'
                    : 'Tìm kiếm game casino...',
                hintStyle: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentTertiary,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacingStyles.space300,
                    right: AppSpacingStyles.space200,
                  ),
                  child: ImageHelper.load(
                    path: AppIcons.icSearch,
                    width: 20,
                    height: 20,
                    color: AppColorStyles.contentTertiary,
                  ),
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColorStyles.contentTertiary,
                        ),
                      ),
                    );
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 14,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _debounceTimer?.cancel();
                final q = value.trim();
                if (q.isNotEmpty) _commitQuery(q);
              },
            ),
          ),
        ),
        SearchTabs(
          selectedIndex: _selectedTabIndex,
          onTabChanged: (index) => setState(() => _selectedTabIndex = index),
        ),
        if (expandBody) Expanded(child: body) else body,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asFullHeightBottomSheet) {
      final topPadding = MediaQuery.paddingOf(context).top;
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Container(
          height: MediaQuery.sizeOf(context).height - topPadding,
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorStyles.contentTertiary.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: _close,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSearchContent(expandBody: true)),
            ],
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height * 3 / 4;
    final screenWidth = screenHeight * 3 / 4;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 48,
            ),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth,
                  minWidth: 320,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: screenWidth,
                        height: screenHeight,
                        decoration: BoxDecoration(
                          color: AppColorStyles.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColorStyles.borderSecondary,
                            width: 1,
                          ),
                        ),
                        child: _buildSearchContent(),
                      ),
                    ),
                    const Gap(8),
                    GestureDetector(
                      onTap: _close,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.gray600,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
