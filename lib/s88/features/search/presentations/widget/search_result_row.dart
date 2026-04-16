import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/border_radius_styles.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Single row for a search result. Dùng chung cho desktop (search dialog) và mobile.
/// Min height 56, padding 16h/12v, background quaternary, radius 12.
class SearchResultRow extends StatelessWidget {
  const SearchResultRow({super.key, required this.item, this.onTap});

  final SearchResultItem item;

  /// Called when row is tapped. Parent should close search and navigate to bet detail.
  final VoidCallback? onTap;

  static const double minHeight = 56;

  @override
  Widget build(BuildContext context) {
    final eventNames = item.eventName.split(' vs ');
    final homeName = eventNames[0];
    final awayName = eventNames.length > 1 ? eventNames[1] : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColorStyles.backgroundTertiary,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundTertiary,
                  borderRadius: BorderRadius.circular(
                    AppBorderRadiusStyles.radius300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          _buildLeagueIcon(),
                          const Gap(6),
                          Text(
                            item.leagueName,
                            style: AppTextStyles.paragraphXSmall(
                              color: AppColorStyles.contentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0x1FFFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _timeStatusBadge(),
                    ),
                    const Gap(8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColorStyles.backgroundQuaternary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: _buildTeamNamesSection(
                          homeName: homeName,
                          awayName: awayName,
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

  /// Logo giải đấu: nếu leagueIconUrl có giá trị thì load từ URL, ngược lại dùng icon sport theo sportId.
  Widget _buildLeagueIcon() {
    final url = item.leagueIconUrl.trim();
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 20,
          height: 20,
          child: ImageHelper.load(
            path: url,
            fit: BoxFit.contain,
            errorWidget: ImageHelper.load(path: AppIcons.iconSoccer),
          ),
        ),
      );
    }
    return ImageHelper.load(
      path: _sportIconPath(item.sportId),
      width: 20,
      height: 20,
    );
  }

  /// Icon path theo sportId (1=bóng đá, 2=bóng rổ, 3=boxing, 4=tennis, 5=bóng chuyền). Mặc định iconSoccer.
  static String _sportIconPath(int sportId) {
    final path = SportType.fromId(sportId)?.iconPath ?? '';
    return path.isNotEmpty ? path : AppIcons.iconSoccer;
  }

  /// Phần tên 2 đội: nếu cả 2 logo URL có giá trị thì hiển thị logo + tên, ngược lại chỉ tên.
  Widget _buildTeamNamesSection({
    required String homeName,
    required String awayName,
  }) {
    final showLogos =
        item.homeTeamLogoUrl.trim().isNotEmpty &&
        item.awayTeamLogoUrl.trim().isNotEmpty;
    if (!showLogos) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            homeName,
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(10),
          Text(
            awayName,
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      );
    }
    const logoSize = 24.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _teamLogo(item.homeTeamLogoUrl, logoSize),
            const Gap(8),
            Expanded(
              child: Text(
                homeName,
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            _teamLogo(item.awayTeamLogoUrl, logoSize),
            const Gap(8),
            Expanded(
              child: Text(
                awayName,
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _teamLogo(String url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url.trim(),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Badge: isLive -> "Trực tiếp" (red500); else theo thời gian start vs now.
  Widget _timeStatusBadge() {
    if (item.isLive) {
      return _buildBadge(
        'Trực tiếp',
        backgroundColor: AppColors.red500,
        textColor: Colors.white,
      );
    }
    final start = _parseStartDateTime();
    if (start == null) {
      return _buildBadge(
        '--',
        backgroundColor: Colors.transparent,
        textColor: AppColorStyles.contentSecondary,
      );
    }
    final now = DateTime.now();
    final diff = start.difference(now);
    if (diff.isNegative) {
      return _buildBadge(
        _formatDateTime(start),
        backgroundColor: Colors.transparent,
        textColor: AppColorStyles.contentSecondary,
      );
    }
    if (diff.inMinutes < 60) {
      return _buildBadge(
        '${diff.inMinutes} phút',
        backgroundColor: AppColors.gray25,
        textColor: AppColors.gray950,
      );
    }
    if (diff.inHours < 24) {
      return _buildBadge(
        '${diff.inHours} giờ',
        backgroundColor: AppColors.gray600,
        textColor: AppColorStyles.contentSecondary,
      );
    }
    return _buildBadge(
      _formatDateTime(start),
      backgroundColor: Colors.transparent,
      textColor: AppColorStyles.contentSecondary,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildBadge(
    String text, {
    required Color backgroundColor,
    required Color textColor,
    FontWeight? fontWeight = FontWeight.w700,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadiusStyles.radius100),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelXSmall(
          color: textColor,
        ).copyWith(fontWeight: fontWeight),
      ),
    );
  }

  DateTime? _parseStartDateTime() {
    if (item.startTimeMs > 0) {
      return DateTime.fromMillisecondsSinceEpoch(item.startTimeMs);
    }
    if (item.startTimeIso.isNotEmpty) {
      try {
        return DateTime.parse(item.startTimeIso);
      } catch (_) {}
    }
    return null;
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(local);
  }
}
