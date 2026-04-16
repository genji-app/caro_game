import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/tracker/tracker_popup_dialog.dart';

/// Hot Match Container Widget
///
/// Displays hot match card(s) with:
/// - Mobile: Single item (current behavior)
/// - Tablet: List of 2 items
/// - Desktop: List of 3 items
///
/// Features:
/// - Header with title and navigation arrows (for single item)
/// - Match info bar (time, icons, view count)
/// - Team logos and names
/// - Betting sentiment (percentage and team)
/// - Betting odds buttons
class HotMatchContainer extends ConsumerWidget {
  final HotMatchEventV2 match;
  final List<HotMatchEventV2>? matches;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTap;
  final void Function(LeagueOddsData odds, bool isHome, int marketId)?
  onOddsTap;

  /// Time until match (e.g., "3 giờ")
  final String? timeUntilMatch;

  /// View count (e.g., 18700 for "18.7K")
  final int? viewCount;

  /// Betting percentage (e.g., 95 for "95%")
  final int? bettingPercentage;

  /// Team with highest betting percentage (e.g., "Juventus FC")
  final String? favoredTeam;

  /// Whether this is the first item (disable previous button)
  final bool isFirstItem;

  /// Whether this is the last item (disable next button)
  final bool isLastItem;

  /// Start index for sliding window (tablet/desktop list). Next = +1, Prev = -1.
  final int currentIndex;
  final bool isRightSidebar;

  const HotMatchContainer({
    super.key,
    required this.match,
    required this.isRightSidebar,
    this.matches,
    this.onPrevious,
    this.onNext,
    this.currentIndex = 0,
    this.onTap,
    this.onOddsTap,
    this.timeUntilMatch,
    this.viewCount,
    this.bettingPercentage,
    this.favoredTeam,
    this.isFirstItem = false,
    this.isLastItem = false,
  });

  static const double _horizontalGap = 8;
  static const double _horizontalPadding = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final isTablet = MediaQuery.sizeOf(context).width <= 1530 && !isMobile;

    // Determine how many items to show
    final itemsToShow = isMobile || isRightSidebar ? 1 : (isTablet ? 2 : 3);

    // Get matches list - use provided list or create single-item list
    final matchesList = matches ?? [match];
    // Sliding window: skip currentIndex, take itemsToShow. Next = +1, Prev = -1.
    final start = currentIndex.clamp(
      0,
      (matchesList.length - itemsToShow).clamp(0, matchesList.length),
    );
    final displayMatches = matchesList.skip(start).take(itemsToShow).toList();

    // Mobile: single item or swipeable cards (only card area)
    if (isMobile) {
      return _buildSingleItem(context, ref);
    }

    // Tablet/Desktop: show list with sliding window + nav
    final listFirst = start == 0;
    final listLast = start + itemsToShow >= matchesList.length;
    return _buildListItems(context, ref, displayMatches, listFirst, listLast);
  }

  /// Build single item layout (for mobile) - horizontal, full width.
  /// When height is bounded, content is wrapped in [SingleChildScrollView]
  /// to avoid overflow.
  Widget _buildSingleItem(BuildContext context, WidgetRef ref) {
    final sportId = ref.watch(leagueProvider.select((s) => s.currentSportId));
    final oddsStyle = ref.watch(leagueProvider.select((s) => s.oddsStyle));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(isFirstItem: isFirstItem, isLastItem: isLastItem),
        Padding(
          padding: const EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            bottom: 12,
          ),
          child: _buildMatchCard(
            ref: ref,
            matchItem: match,
            sportId: sportId,
            oddsStyle: oddsStyle,
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          if (maxHeight.isFinite && maxHeight > 0) {
            return SizedBox(
              height: maxHeight,
              child: SingleChildScrollView(child: content),
            );
          }
          return content;
        },
      ),
    );
  }

  /// Build list items layout (for tablet/desktop) - horizontal Row, width auto-calculated
  Widget _buildListItems(
    BuildContext context,
    WidgetRef ref,
    List<HotMatchEventV2> displayMatches,
    bool listFirst,
    bool listLast,
  ) {
    final sportId = ref.watch(leagueProvider.select((s) => s.currentSportId));
    final oddsStyle = ref.watch(leagueProvider.select((s) => s.oddsStyle));
    final n = displayMatches.length;
    final totalGaps = n > 1 ? (n - 1) * _horizontalGap : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final contentWidth = maxWidth - _horizontalPadding * 2;
          // Floor to avoid floating-point overflow (e.g. RIGHT OVERFLOWED BY 0.5px)
          final itemWidth = n > 0
              ? ((contentWidth - totalGaps) / n).floorToDouble()
              : contentWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isFirstItem: listFirst, isLastItem: listLast),
              Padding(
                padding: const EdgeInsets.only(
                  left: _horizontalPadding,
                  right: _horizontalPadding,
                  bottom: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < displayMatches.length; i++) ...[
                      if (i > 0) const Gap(_horizontalGap),
                      SizedBox(
                        width: itemWidth,
                        child: _buildMatchCard(
                          ref: ref,
                          matchItem: displayMatches[i],
                          sportId: sportId,
                          oddsStyle: oddsStyle,
                          cardWidth: itemWidth,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// When [cardWidth] is set (tablet/desktop list), use compact layout if narrow.
  static const double _compactThreshold = 110;

  Widget _buildMatchCard({
    required WidgetRef ref,
    required HotMatchEventV2 matchItem,
    required int sportId,
    required OddsStyle oddsStyle,
    double? cardWidth,
  }) {
    final handicapMarket = matchItem.getHandicapMarket(sportId);
    final oddsV2 = handicapMarket?.mainLineOdds;
    final handicapOdds = oddsV2?.toLegacy();
    final compact = cardWidth != null && cardWidth < _compactThreshold;
    final padding = compact ? 8.0 : 16.0;
    final gap = compact ? 8.0 : 16.0;
    final logoSize = compact ? 24.0 : 32.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -0.65),
                blurRadius: 0.5,
                spreadRadius: 0.05,
                blurStyle: BlurStyle.inner,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMatchInfoBar(match: matchItem, compact: compact),
              _buildLeagueName(match: matchItem, compact: compact),
              _buildTeamsSection(
                match: matchItem,
                padding: padding,
                gap: gap,
                logoSize: logoSize,
              ),
              _buildBettingSentiment(match: matchItem, padding: padding),
              if (handicapOdds != null)
                _buildBettingOdds(
                  match: matchItem,
                  handicapOdds: handicapOdds,
                  oddsStyle: oddsStyle,
                  marketId: handicapMarket?.marketId ?? 5,
                  padding: padding,
                  gap: gap,
                )
              else
                const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with title and navigation arrows
  Widget _buildHeader({required bool isFirstItem, required bool isLastItem}) =>
      Container(
        padding: const EdgeInsets.only(left: 12, right: 6, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -0.65),
              blurRadius: 0.5,
              spreadRadius: 0.05,
              blurStyle: BlurStyle.inner,
              color: Colors.white.withOpacity(0.15),
            ),
          ],
        ),
        child: Row(
          children: [
            // Title
            Expanded(
              child: Text(
                'Trận đấu hot',
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            // Navigation buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavButton(
                  icon: Icons.chevron_left,
                  onTap: onPrevious,
                  isLeft: true,
                  isEnabled: !isFirstItem,
                ),
                const Gap(2),
                _buildNavButton(
                  icon: Icons.chevron_right,
                  onTap: onNext,
                  isLeft: false,
                  isEnabled: !isLastItem,
                ),
              ],
            ),
          ],
        ),
      );

  /// Build navigation button
  Widget _buildNavButton({
    required IconData icon,
    VoidCallback? onTap,
    required bool isLeft,
    required bool isEnabled,
  }) => InkWell(
    onTap: isEnabled ? onTap : null,
    child: Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: isLeft
              ? const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled
              ? AppColorStyles.contentPrimary
              : AppColorStyles.contentSecondary,
        ),
      ),
    ),
  );

  /// Build match info bar with time, icons, and total users
  Widget _buildMatchInfoBar({
    required HotMatchEventV2 match,
    bool compact = false,
  }) => RepaintBoundary(
    child: _MatchInfoBar(
      match: match,
      viewCount: match.totalUsers ?? viewCount,
      compact: compact,
      onTap: onTap,
    ),
  );

  /// League name – dưới MatchInfoBar, trên TeamsSection (theo Figma).
  Widget _buildLeagueName({
    required HotMatchEventV2 match,
    bool compact = false,
  }) {
    final leagueName = match.leagueName;
    if (leagueName.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundPrimary,
        gradient: LinearGradient(
          colors: [Color(0x00FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
        ),
      ),
      child: Center(
        child: Text(
          leagueName,
          style: AppTextStyles.labelXSmall(
            color: AppColorStyles.contentTertiary,
          ).copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Build teams section with logos and names
  Widget _buildTeamsSection({
    required HotMatchEventV2 match,
    double padding = 16,
    double gap = 16,
    double logoSize = 32,
  }) => Padding(
    padding: EdgeInsets.fromLTRB(padding, 8, padding, padding > 10 ? 16 : 8),
    child: Row(
      children: [
        _buildTeamLogo(match.homeLogo, size: logoSize),
        Gap(gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                match.homeName,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              Text(
                match.awayName,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Gap(gap),
        _buildTeamLogo(match.awayLogo, size: logoSize),
      ],
    ),
  );

  /// Build team logo with gradient border
  Widget _buildTeamLogo(String logoUrl, {double size = 32}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFD5DCEB)],
      ),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1),
    ),
    child: ClipOval(
      child: logoUrl.isNotEmpty
          ? ImageHelper.getNetworkImage(
              imageUrl: logoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorWidget: ImageHelper.load(
                path: AppIcons.iconSoccer,
                width: size,
                height: size,
              ),
            )
          : ImageHelper.load(
              path: AppIcons.iconSoccer,
              width: size,
              height: size,
            ),
    ),
  );

  /// Build betting sentiment section
  Widget _buildBettingSentiment({
    required HotMatchEventV2 match,
    double padding = 16,
  }) {
    // Only show if we have betting trend data
    final bettingTrend = match.bettingTrend;
    if (bettingTrend == null || bettingTrend.isEmpty) {
      // Keep divider + empty space to maintain consistent item height
      // Height: divider (1px) + empty (32px) = 33px total
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: AppColorStyles.borderPrimary),
          const SizedBox(height: 37),
        ],
      );
    }

    // Parse bettingTrend format: "TeamName X.X%"
    // Extract percentage and team name
    final parts = bettingTrend.split(' ');
    String? percentageText;
    String teamName;

    if (parts.length >= 2) {
      // Last part should be percentage (e.g., "65.5%")
      percentageText = parts.last;
      // Everything before last part is team name
      teamName = parts.sublist(0, parts.length - 1).join(' ');
    } else {
      // Fallback: use entire string as team name
      teamName = bettingTrend;
    }

    return SizedBox(
      height: 38,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Divider
          Container(height: 1, color: AppColorStyles.borderPrimary),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
            child: Row(
              children: [
                // Flame icons
                ImageHelper.load(
                  path: AppIcons.iconBettingPercent,
                  width: 12,
                  height: 12,
                ),
                if (percentageText != null && percentageText.isNotEmpty) ...[
                  const Gap(4),
                  // Percentage
                  Text(
                    percentageText,
                    style: AppTextStyles.labelXSmall(
                      color: const Color(0xFFFDE272), // accent/yellow
                    ),
                  ),
                ],
                if (teamName.isNotEmpty) ...[
                  const Gap(4),
                  // "cược vào"
                  Text(
                    'cược vào',
                    style: AppTextStyles.paragraphXSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                  const Gap(4),
                  // Favored team
                  Expanded(
                    child: Text(
                      teamName,
                      style: AppTextStyles.paragraphXSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build betting odds buttons
  Widget _buildBettingOdds({
    required HotMatchEventV2 match,
    required LeagueOddsData handicapOdds,
    required OddsStyle oddsStyle,
    required int marketId,
    double padding = 16,
    double gap = 16,
  }) {
    final pointsValue = handicapOdds.pointsValue;
    final formattedPoints = PointsFormatter.format(pointsValue.abs());

    // Mapping từ API V2 (market 5 handicap): key 3=points, 4=homeOdds, 5=awayOdds, 8=isMainLine.
    // mainLineOdds = odds có isMainLine=true hoặc odds đầu tiên.
    // Handicap logic:
    // - points <= 0: Home được chấp → Home hiển thị points dương, Away hiển thị points âm
    // - points > 0: Away được chấp → Away hiển thị points dương, Home hiển thị points âm
    // VD: API points="1", homeOdds=1.94, awayOdds=1.74 → UI: Home "-1" 1.94, Away "1" 1.74
    String homePointsLabel;
    String awayPointsLabel;

    if (pointsValue <= 0) {
      // Home được chấp
      homePointsLabel = formattedPoints; // "0.5"
      awayPointsLabel = '-$formattedPoints'; // "-0.5"
    } else {
      // Away được chấp
      homePointsLabel = '-$formattedPoints'; // "-0.5"
      awayPointsLabel = formattedPoints; // "0.5"
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding > 10 ? 16 : 12),
      child: Row(
        children: [
          Expanded(
            child: _buildBetButton(
              points: homePointsLabel,
              odds: handicapOdds.getHomeOdds(oddsStyle),
              onTap: () => onOddsTap?.call(handicapOdds, true, marketId),
            ),
          ),
          Gap(gap),
          Expanded(
            child: _buildBetButton(
              points: awayPointsLabel,
              odds: handicapOdds.getAwayOdds(oddsStyle),
              onTap: () => onOddsTap?.call(handicapOdds, false, marketId),
            ),
          ),
        ],
      ),
    );
  }

  /// Build single bet button
  Widget _buildBetButton({
    required String points,
    required double odds,
    VoidCallback? onTap,
  }) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                points,
                style: AppTextStyles.labelXSmall(
                  color: AppColorStyles.contentSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(4),
            Text(
              odds.toStringAsFixed(2),
              style: AppTextStyles.labelSmall(
                color: const Color(0xFFACDC79), // accent/green
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Match Info Bar with countdown timer
class _MatchInfoBar extends StatefulWidget {
  final HotMatchEventV2 match;
  final int? viewCount;
  final bool compact;
  final VoidCallback? onTap;

  const _MatchInfoBar({
    required this.match,
    this.viewCount,
    this.compact = false,
    this.onTap,
  });

  @override
  State<_MatchInfoBar> createState() => _MatchInfoBarState();
}

class _MatchInfoBarState extends State<_MatchInfoBar> {
  Timer? _timer;
  String _countdownText = '';
  bool _isShowingDate = false;

  bool get _canShowTracker => widget.match.event.eventStatsId > 0;

  void _showTrackerPopup(BuildContext context) {
    TrackerPopupDialog.show(
      context: context,
      eventStatsId: widget.match.event.eventStatsId,
      homeName: widget.match.event.homeName,
      awayName: widget.match.event.awayName,
    );
  }

  @override
  void initState() {
    super.initState();
    _updateCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MatchInfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.startTime != widget.match.startTime ||
        oldWidget.match.isLive != widget.match.isLive) {
      _timer?.cancel();
      _updateCountdown();
    }
  }

  void _startTimer(Duration interval) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      if (mounted) {
        _updateCountdown();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _updateCountdown() {
    // Check isLive first — API provides this directly and is authoritative
    if (widget.match.isLive) {
      setState(() {
        _countdownText = 'Trực tiếp';
        _isShowingDate = false;
      });
      _timer?.cancel();
      return;
    }

    final startTime = widget.match.startTime;
    if (startTime == 0) {
      setState(() {
        _countdownText = '';
        _isShowingDate = false;
      });
      return;
    }

    final now = DateTime.now();
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(startTime);
    final difference = startDateTime.difference(now);

    if (difference.isNegative) {
      setState(() {
        _countdownText = 'Trực tiếp';
        _isShowingDate = false;
      });
      _timer?.cancel();
      return;
    }

    final totalSeconds = difference.inSeconds;

    setState(() {
      if (totalSeconds >= 86400) {
        // ≥ 24h: chỉ hiển thị dd/MM/YYYY HH:mm (không countdown). Timer 1h để kiểm tra khi < 24h.
        final day = startDateTime.day.toString().padLeft(2, '0');
        final month = startDateTime.month.toString().padLeft(2, '0');
        final year = startDateTime.year;
        final hour = startDateTime.hour.toString().padLeft(2, '0');
        final minute = startDateTime.minute.toString().padLeft(2, '0');
        _isShowingDate = true;
        _countdownText = '$day/$month/$year $hour:$minute';
        _startTimer(const Duration(hours: 1));
      } else if (totalSeconds >= 3600) {
        // 1h -> < 24h: hiển thị "X giờ", timer mỗi giờ
        _isShowingDate = false;
        final hours = totalSeconds ~/ 3600;
        _countdownText = '$hours giờ';
        _startTimer(const Duration(hours: 1));
      } else if (totalSeconds >= 60) {
        // < 1h: hiển thị "X phút", timer mỗi phút
        _isShowingDate = false;
        final minutes = totalSeconds ~/ 60;
        _countdownText = '$minutes phút';
        _startTimer(const Duration(minutes: 1));
      } else {
        // < 1 phút: hiển thị "X giây", timer mỗi giây
        _isShowingDate = false;
        _countdownText = '$totalSeconds giây';
        _startTimer(const Duration(seconds: 1));
      }
    });
  }

  /// Format view count (e.g., 18700 -> "18,7K" with comma)
  String _formatViewCount(int count) {
    if (count >= 1000000) {
      final millions = count / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}M';
      }
      return '${millions.toStringAsFixed(1).replaceAll('.', ',')}M';
    }
    if (count >= 1000) {
      final thousands = count / 1000;
      if (thousands == thousands.roundToDouble()) {
        return '${thousands.toInt()}K';
      }
      return '${thousands.toStringAsFixed(1).replaceAll('.', ',')}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final badgeMaxWidth = _isShowingDate ? 120.0 : 80.0;
    final gap = 4.0;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_countdownText.isNotEmpty)
                  Flexible(
                    child: Container(
                      width: badgeMaxWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: _countdownText == 'Trực tiếp'
                            ? AppColors.red500
                            : AppColorStyles.borderPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _countdownText,
                        style: AppTextStyles.labelXSmall(
                          color: _countdownText == 'Trực tiếp'
                              ? Colors.white
                              : AppColorStyles.contentSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Visibility(
                  visible: _countdownText == 'Trực tiếp',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Gap(gap),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: ImageHelper.load(
                            path: AppIcons.iconLiveHotMatch,
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(gap),
                GestureDetector(
                  onTap: _canShowTracker
                      ? () => _showTrackerPopup(context)
                      : null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: ImageHelper.load(
                      path: AppIcons.iconChart,
                      width: 16,
                      height: 16,
                      color: _canShowTracker
                          ? AppColorStyles.contentSecondary
                          : AppColorStyles.contentSecondary.withValues(
                              alpha: 0.3,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // People icon
              Icon(
                Icons.people_outline,
                size: 16,
                color: AppColorStyles.contentPrimary,
              ),
              const Gap(4),
              // View count
              Text(
                widget.viewCount != null
                    ? _formatViewCount(widget.viewCount!)
                    : '-',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
