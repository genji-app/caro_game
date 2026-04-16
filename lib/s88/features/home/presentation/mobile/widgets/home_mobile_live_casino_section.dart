import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class HomeMobileLiveCasinoSection extends StatefulWidget {
  const HomeMobileLiveCasinoSection({super.key});

  @override
  State<HomeMobileLiveCasinoSection> createState() =>
      _HomeMobileLiveCasinoSectionState();
}

class _HomeMobileLiveCasinoSectionState
    extends State<HomeMobileLiveCasinoSection> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtStart = true;
  bool _isAtEnd = false;

  // Danh sách các game cards
  final List<Map<String, String>> _gameCards = [
    {'name': 'SICBO 88', 'provider': 'sunwin'},
    {'name': 'SICBO 88', 'provider': 'sunwin'},
    {'name': 'SICBO 88', 'provider': 'sunwin'},
    {'name': 'SICBO 88', 'provider': 'sunwin'},
    {'name': 'SICBO 88', 'provider': 'sunwin'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Sau khi build xong, kiểm tra xem có thể scroll không
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollState();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateScrollState();
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Kiểm tra xem đã đến đầu hay cuối chưa (với threshold 1px)
    final isAtStart = currentOffset <= 1;
    final isAtEnd = currentOffset >= maxScrollExtent - 1;

    if (_isAtStart != isAtStart || _isAtEnd != isAtEnd) {
      setState(() {
        _isAtStart = isAtStart;
        _isAtEnd = isAtEnd;
      });
    }
  }

  void _scrollToPrevious() {
    if (_isAtStart) return;

    final currentOffset = _scrollController.offset;

    // Tính toán vị trí scroll mới (scroll lùi lại 1 card)
    // Padding: 4 mỗi bên = 8 total
    // Gaps giữa 3 cards hiển thị: 6 + 6 = 12
    // Card width = (screenWidth - 8 - 12) / 3
    // Khi scroll thêm 1 card: cardWidth + gap (6)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 8 - 12) / 3.0;
    final scrollDistance = cardWidth + 6.0; // card width + gap

    final newOffset = currentOffset - scrollDistance;
    final targetOffset = newOffset < 0 ? 0.0 : newOffset;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToNext() {
    if (_isAtEnd) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Tính toán vị trí scroll mới (scroll tới 1 card)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 8 - 12) / 3.0;
    final scrollDistance = cardWidth + 6.0; // card width + gap

    final newOffset = currentOffset + scrollDistance;
    final targetOffset = newOffset > maxScrollExtent
        ? maxScrollExtent
        : newOffset;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    borderRadius: 12,
    child: Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Live Casino'),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _gameCards.asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    return Row(
                      children: [
                        SizedBox(
                          width:
                              (MediaQuery.of(context).size.width - 8 - 12) / 3,
                          child: _buildGameCard(
                            card['name']!,
                            card['provider']!,
                          ),
                        ),
                        if (index < _gameCards.length - 1) const Gap(6),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSectionHeader(String title) => Container(
    height: 40,
    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavigationButton(Icons.chevron_left, isLeft: true),
            const Gap(4),
            _buildNavigationButton(Icons.chevron_right, isLeft: false),
          ],
        ),
      ],
    ),
  );

  Widget _buildNavigationButton(IconData icon, {required bool isLeft}) {
    final canNavigate = isLeft ? !_isAtStart : !_isAtEnd;

    return GestureDetector(
      onTap: () {
        if (isLeft) {
          _scrollToPrevious();
        } else {
          _scrollToNext();
        }
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: canNavigate
                ? Colors.orange[200]
                : AppColorStyles.contentPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(String gameName, String provider) {
    const backgroundColor = AppColors.orange700;

    return InnerShadowCard(
      borderRadius: 10,
      child: AspectRatio(
        aspectRatio: 100 / 140,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ImageHelper.load(
                      path: AppIcons.sunShadow,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.25, 1.0],
                        colors: [
                          backgroundColor.withOpacity(0),
                          backgroundColor.withOpacity(0.5),
                          backgroundColor,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gameName,
                          style:
                              AppTextStyles.labelSmall(
                                color: const Color(0xFFFFFEF5),
                              ).copyWith(
                                fontWeight: FontWeight.w900,
                                height: 14 / 14,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          provider,
                          style: AppTextStyles.labelXXSmall(
                            color: AppColorStyles.contentPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
