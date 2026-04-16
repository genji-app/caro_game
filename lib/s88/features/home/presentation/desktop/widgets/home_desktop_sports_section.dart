import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class HomeDesktopSportsSection extends ConsumerWidget {
  const HomeDesktopSportsSection({super.key});

  // Supported sport IDs: football(1), basketball(2), tennis(4), volleyball(5), badminton(7)
  static const Set<int> _supportedSportIds = {1, 2, 4, 5, 7};

  static final List<Map<String, dynamic>> _sportCards = [
    {
      'name': 'BÓNG ĐÁ',
      'color': const Color(0xFFFF5882),
      'image': AppImages.personSoccer,
      'sportId': 1,
    },
    {
      'name': 'BÓNG CHUYỀN',
      'color': AppColors.yellow600,
      'image': AppImages.personVolleyball,
      'sportId': 5,
    },
    {
      'name': 'BÓNG RỔ',
      'color': AppColors.blue700,
      'image': AppImages.personBasketball,
      'sportId': 2,
    },
    {
      'name': 'CẦU LÔNG',
      'color': AppColors.red600,
      'image': AppImages.personBadminton,
      'sportId': 7,
    },
    {
      'name': 'QUẦN VỢT',
      'color': const Color(0xFF21847B),
      'image': AppImages.personTennis,
      'sportId': 4,
    },
  ];

  /// Handle tap on sport card
  void _onSportCardTap(
    BuildContext context,
    WidgetRef ref,
    int sportId,
    String sportName,
  ) {
    if (_supportedSportIds.contains(sportId)) {
      ref.read(previousContentProvider.notifier).state = MainContentType.home;
      final sport = v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
      ref.read(selectedSportV2Provider.notifier).state = sport;
      ref
          .read(sportSocketAdapterProvider)
          .subscriptionManager
          .setActiveSport(sportId);
      ref.read(mainContentProvider.notifier).goToSportDetail();
    } else {
      AppToast.showError(context, message: 'Môn $sportName chưa được cập nhật');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(16),
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
      children: [
        _buildSectionHeader('Thể thao nổi bật'),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(
            children: _sportCards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final sportId = card['sportId'] as int;
              final sportName = card['name'] as String;
              return Expanded(
                child: Row(
                  children: [
                    if (index > 0) const Gap(8),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _onSportCardTap(context, ref, sportId, sportName),
                        child: _buildSportCard(
                          sportName,
                          card['color'] as Color,
                          card['image'] as String,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionHeader(String title) => Container(
    height: 44,
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     _buildNavigationButton(Icons.chevron_left),
        //     const Gap(4),
        //     _buildNavigationButton(Icons.chevron_right),
        //   ],
        // ),
      ],
    ),
  );

  Widget _buildNavigationButton(IconData icon) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Center(
      child: Icon(icon, size: 20, color: AppColorStyles.contentPrimary),
    ),
  );

  Widget _buildSportCard(
    String sportName,
    Color backgroundColor,
    String imagePath,
  ) => InnerShadowCard(
    borderRadius: 12,
    child: AspectRatio(
      aspectRatio: 149 / 200,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background overlay with mix blend mode
              Positioned.fill(
                child: Opacity(
                  opacity: 1.0,
                  child: ImageHelper.load(
                    path: AppIcons.sunShadow,
                    fit: BoxFit.cover,
                    // colorFilter: const ColorFilter.mode(
                    //   Colors.white,
                    //   BlendMode.overlay,
                    // ),
                  ),
                ),
              ),
              // Person image
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ImageHelper.getNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay with text at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 72,
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
                  padding: const EdgeInsets.only(top: 12, bottom: 32),
                  alignment: Alignment.center,
                  child: Text(
                    sportName,
                    style: AppTextStyles.headingXSmall(
                      color: const Color(0xFFFFFEF5),
                    ).copyWith(fontWeight: FontWeight.w900, height: 20 / 20),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
