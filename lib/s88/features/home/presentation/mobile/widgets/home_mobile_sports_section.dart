import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class HomeMobileSportsSection extends ConsumerStatefulWidget {
  const HomeMobileSportsSection({super.key});

  @override
  ConsumerState<HomeMobileSportsSection> createState() =>
      _HomeMobileSportsSectionState();
}

class _HomeMobileSportsSectionState
    extends ConsumerState<HomeMobileSportsSection> {
  // Supported sport IDs: football(1), basketball(2), tennis(4), volleyball(5)
  static const Set<int> _supportedSportIds = {1, 2, 4, 5, 7};
  final ScrollController _scrollController = ScrollController();

  // Cache scroll state - chỉ update khi scroll animation hoàn thành
  bool _isAtStart = true;
  bool _isAtEnd = false;

  // Cache screen dimensions để tránh gọi MediaQuery nhiều lần
  double _cachedCardWidth = 0;
  double _cachedScrollDistance = 0;

  // Danh sách các sport cards - dùng static const để tránh tạo lại mỗi build
  static final List<Map<String, dynamic>> _sportCards = [
    {
      'name': 'BÓNG ĐÁ',
      'color': const Color(0xFFFF5882),
      'image': AppImages.personSoccer,
      'sportId': 1, // Football
    },
    {
      'name': 'BÓNG CHUYỀN',
      'color': AppColors.yellow600,
      'image': AppImages.personVolleyball,
      'sportId': 5, // Volleyball
    },
    {
      'name': 'BÓNG RỔ',
      'color': AppColors.blue700,
      'image': AppImages.personBasketball,
      'sportId': 2, // Basketball
    },
    {
      'name': 'CẦU LÔNG',
      'color': AppColors.red600,
      'image': AppImages.personBadminton,
      'sportId': 7, // Badminton
    },
    {
      'name': 'QUẦN VỢT',
      'color': const Color(0xFF21847B),
      'image': AppImages.personTennis,
      'sportId': 4, // Tennis
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache dimensions khi MediaQuery thay đổi (orientation, resize)
    _updateCachedDimensions();
  }

  void _updateCachedDimensions() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = ResponsiveBuilder.isTablet(context);
    final itemsPerView = isTablet ? 5 : 3;
    const paddingH = 8.0;
    const gap = 6.0;
    final gapTotal = (itemsPerView - 1) * gap;
    _cachedCardWidth = (screenWidth - paddingH - gapTotal) / itemsPerView;
    _cachedScrollDistance = _cachedCardWidth + gap;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Update scroll state SAU KHI animation hoàn thành (không phải mỗi frame)
  void _updateScrollStateAfterAnimation() {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    final isAtStart = currentOffset <= 1;
    final isAtEnd = currentOffset >= maxScrollExtent - 1;

    // Chỉ setState nếu state thực sự thay đổi
    if (_isAtStart != isAtStart || _isAtEnd != isAtEnd) {
      setState(() {
        _isAtStart = isAtStart;
        _isAtEnd = isAtEnd;
      });
    }
  }

  void _scrollToPrevious() {
    if (_isAtStart || !_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final newOffset = currentOffset - _cachedScrollDistance;
    final targetOffset = newOffset < 0 ? 0.0 : newOffset;

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          // Chỉ update state SAU KHI animation hoàn thành
          _updateScrollStateAfterAnimation();
        });
  }

  void _scrollToNext() {
    if (_isAtEnd || !_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    final newOffset = currentOffset + _cachedScrollDistance;
    final targetOffset = newOffset > maxScrollExtent
        ? maxScrollExtent
        : newOffset;

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          // Chỉ update state SAU KHI animation hoàn thành
          _updateScrollStateAfterAnimation();
        });
  }

  /// Handle tap on sport card
  void _onSportCardTap(int sportId, String sportName) {
    if (_supportedSportIds.contains(sportId)) {
      // Navigate to sport detail
      ref.read(previousContentProvider.notifier).state = MainContentType.home;
      // Use V2 provider for sport selection
      final sport = v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
      ref.read(selectedSportV2Provider.notifier).state = sport;

      // Update socket subscription (V2 protocol: unsub old sport / sub new sport)
      ref
          .read(sportSocketAdapterProvider)
          .subscriptionManager
          .setActiveSport(sportId);

      ref.read(mainContentProvider.notifier).goToSportDetail();
    } else {
      // Show error toast
      AppToast.showError(context, message: 'Môn $sportName chưa được cập nhật');
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.12),
          offset: const Offset(0, 0.5),
          blurRadius: 0.5,
          spreadRadius: 0,
          blurStyle: BlurStyle.inner,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader('Thể thao nổi bật'),
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
                children: _sportCards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  final sportId = card['sportId'] as int;
                  final sportName = card['name'] as String;
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => _onSportCardTap(sportId, sportName),
                        child: SizedBox(
                          width: _cachedCardWidth,
                          child: _buildSportCard(
                            sportName,
                            card['color'] as Color,
                            card['image'] as String,
                          ),
                        ),
                      ),
                      if (index < _sportCards.length - 1) const Gap(6),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
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
            style: AppTextStyles.labelMedium(
              context: context,
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

  Widget _buildSportCard(
    String sportName,
    Color backgroundColor,
    String imagePath,
  ) => InnerShadowCard(
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
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ImageHelper.getNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
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
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  alignment: Alignment.center,
                  child: Text(
                    sportName,
                    style: AppTextStyles.textStyle(
                      context: context,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
