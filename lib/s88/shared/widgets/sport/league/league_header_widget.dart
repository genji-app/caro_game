import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// League header widget for virtualized sliver list
///
/// Features:
/// - Displays league logo and name
/// - Expand/collapse toggle with animation
/// - Platform-aware sizing (desktop/mobile)
class LeagueHeaderWidget extends ConsumerWidget {
  final LeagueData league;
  final bool isDesktop;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  static const _logoDecoration = BoxDecoration(
    color: Color(0xFFE0E0E0),
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );

  const LeagueHeaderWidget({
    super.key,
    required this.league,
    this.isDesktop = false,
    this.isExpanded = true,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current sport ID for icon fallback
    final currentSportId = ref.watch(
      leagueProvider.select((s) => s.currentSportId),
    );

    return Container(
      height: isDesktop ? 48 : 40,
      // margin: EdgeInsets.only(bottom: isDesktop ? 4 : 2),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // League logo
                _buildLeagueLogo(currentSportId),
                const SizedBox(width: 8),
                // League name
                Expanded(
                  child: Text(
                    league.leagueName,
                    style: AppTextStyles.textStyle(
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.w400,
                      color: AppColorStyles.contentPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Chevron toggle
          if (onToggleExpand != null)
            GestureDetector(
              onTap: onToggleExpand,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0 : 0.5,
                  child: RepaintBoundary(
                    child: ImageHelper.load(
                      path: AppIcons.chevronUp,
                      width: isDesktop ? 24 : 20,
                      height: isDesktop ? 24 : 20,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeagueLogo(int currentSportId) {
    if (league.leagueLogo.isNotEmpty) {
      return Container(
        width: isDesktop ? 28 : 26,
        height: isDesktop ? 28 : 26,
        decoration: _logoDecoration,
        padding: const EdgeInsets.all(2),
        child: ImageHelper.getNetworkImage(
          imageUrl: league.leagueLogo,
          width: isDesktop ? 24 : 22,
          height: isDesktop ? 24 : 22,
          fit: BoxFit.contain,
          errorWidget: RepaintBoundary(
            child: ImageHelper.load(path: AppIcons.iconSoccer),
          ),
          placeholder: const SizedBox.shrink(),
        ),
      );
    }

    return RepaintBoundary(
      child: ImageHelper.load(
        path: SportType.fromId(currentSportId)?.iconPath ?? '',
        width: isDesktop ? 26 : 24,
        height: isDesktop ? 26 : 24,
        fit: BoxFit.contain,
        color: const Color(0xB3FFFCDB),
      ),
    );
  }
}
