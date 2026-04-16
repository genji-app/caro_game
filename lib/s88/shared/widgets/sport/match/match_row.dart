import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/models/bet_column.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/utils/league_data_converter.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/pip_manager.dart';
import 'package:co_caro_flame/s88/shared/widgets/stats/stats_dialog.dart';
import 'package:co_caro_flame/s88/shared/widgets/teams/team_display.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/parlay_tooltip.dart';
import 'package:co_caro_flame/s88/shared/widgets/tracker/tracker_popup_dialog.dart';

/// Match row displaying team info, live status, and odds
///
/// Performance:
/// - Uses ConsumerWidget
/// - Static team info from props (no rebuild)
/// - Live data uses Consumer with select (partial rebuild)
/// - Each BetCard manages its own odds subscription
class MatchRow extends ConsumerWidget {
  final LeagueEventData event;
  final LeagueData? league;
  final bool isDesktop;
  final VoidCallback? onTap;

  const MatchRow({
    super.key,
    required this.event,
    this.league,
    this.isDesktop = false,
    this.onTap,
  });

  /// Check if stats can be shown (eventStatsId > 0)
  bool get _canShowStats => event.eventStatsId > 0;

  /// Check if tracker can be shown (eventStatsId > 0)
  bool get _canShowTracker => event.eventStatsId > 0;

  /// Get bet columns for this event
  /// Ensures only FT (Full Time) columns: handicap, overUnder, matchResult
  /// Each type appears only once and in fixed order
  ///
  /// ⚠️ NOTE: Luôn trả về đủ 3 columns (thậm chí khi market bị suspended/hidden)
  /// → UI sẽ render locked placeholder cho missing columns
  List<BetColumn?> _getBetColumns(OddsStyle oddsStyle) {
    final allBetColumns = event.toBetColumns(oddsStyle: oddsStyle);

    // Find first column of each FT type (ignore H1 types)
    BetColumn? handicapCol;
    BetColumn? overUnderCol;
    BetColumn? matchResultCol;

    for (final col in allBetColumns) {
      // Only accept FT types, skip H1 types
      switch (col.type) {
        case BetColumnType.handicap:
          handicapCol ??= col;
        case BetColumnType.overUnder:
          overUnderCol ??= col;
        case BetColumnType.matchResult:
          matchResultCol ??= col;
        default:
          // Skip H1 types: handicapH1, overUnderH1, matchResultH1
          break;
      }
    }

    // ✅ Luôn trả về đủ 3 columns (nullable) theo thứ tự cố định
    // Nếu column = null → UI sẽ render locked placeholder
    return [handicapCol, overUnderCol, matchResultCol];
  }

  /// Check if column is 1X2 type (has 3 items)
  bool _is1X2Column(BetColumn column) {
    return column.type == BetColumnType.matchResult;
  }

  /// Get maximum items count from all columns
  int _getMaxColumnItems(List<BetColumn?> columns) {
    for (final col in columns) {
      if (col != null && _is1X2Column(col) && col.items.length >= 3) {
        return 3;
      }
    }
    // Default: Nếu có 1X2 column (index 2) → 3 items, else → 2 items
    return columns.length == 3 ? 3 : 2;
  }

  /// Parse matchTime to extract minute and period
  (String? minute, String? period) _parseMatchTime(String? matchTime) {
    if (matchTime == null) return (null, null);
    final parts = matchTime.split(RegExp(r'\s*\|\s*'));
    if (parts.length >= 2) {
      return (parts[0].trim(), parts[1].trim());
    }
    return (matchTime, null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oddsStyle = ref.watch(oddsStyleProvider);
    final betColumns = _getBetColumns(oddsStyle);
    final maxColumnItems = _getMaxColumnItems(betColumns);
    final isLive = event.isLive;
    final matchTime = isLive ? event.liveStatusDisplay : event.formattedTime;
    final (minute, period) = _parseMatchTime(matchTime);

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with live indicator and bet type tabs
          _MatchHeader(
            columns: betColumns,
            isLive: isLive,
            isDesktop: isDesktop,
            minute: minute,
            period: period,
            eventId: event.eventId,
          ),

          // Teams and bets section
          Expanded(
            child: Container(
              color: AppColorStyles.backgroundQuaternary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teams column with score
                  _TeamsSection(
                    event: event,
                    league: league,
                    isLive: isLive,
                    isDesktop: isDesktop,
                    onTap: () => _navigateToBetDetail(ref),
                  ),

                  const SizedBox(width: 24),

                  // Bet columns
                  _OddsSection(
                    sportId: ref.read(leagueProvider).currentSportId,
                    event: event,
                    league: league,
                    columns: betColumns,
                    maxColumnItems: maxColumnItems,
                    isLive: isLive,
                    isDesktop: isDesktop,
                  ),
                ],
              ),
            ),
          ),

          // Footer with icons and more markets
          _MatchFooter(
            event: event,
            league: league,
            canShowStats: _canShowStats,
            canShowTracker: _canShowTracker,
            onNavigate: () => _navigateToBetDetail(ref),
          ),
        ],
      ),
    );
  }

  void _navigateToBetDetail(WidgetRef ref) {
    if (league == null) return;

    ref.read(selectedEventProvider.notifier).state = event;
    ref.read(selectedLeagueProvider.notifier).state = league;
    ref.read(mainContentProvider.notifier).goToBetDetail();
  }
}

/// Match header with live indicator and column titles
class _MatchHeader extends StatelessWidget {
  final List<BetColumn?> columns; // ✅ Nullable columns
  final bool isLive;
  final bool isDesktop;
  final String? minute;
  final String? period;
  final int eventId;

  const _MatchHeader({
    required this.columns,
    required this.isLive,
    required this.isDesktop,
    this.minute,
    this.period,
    required this.eventId,
  });

  /// Get default title khi column = null
  String _getDefaultTitle(int index) {
    switch (index) {
      case 0:
        return 'Kèo chấp';
      case 1:
        return 'Tài xỉu';
      case 2:
        return '1X2';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
        ),
      ),
      child: Row(
        children: [
          // Live indicator and time
          Expanded(
            flex: isDesktop && isLive ? 4 : 1,
            child: Row(
              children: [
                if (isLive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.red500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Trực tiếp',
                      style: AppTextStyles.textStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFFFEF5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                // Match time - use realtime widget for live matches
                if (isLive)
                  Expanded(
                    child: LiveMatchTimeDisplay(
                      eventId: eventId,
                      initialMinute: minute,
                      initialPeriod: period,
                    ),
                  )
                else ...[
                  if (minute != null)
                    Text(
                      minute!,
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFFFFEF5),
                      ),
                    ),
                  if (minute != null && period != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (period != null)
                    Flexible(
                      child: Text(
                        period!,
                        style: AppTextStyles.textStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFFFFEF5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Bet type tabs
          Expanded(
            flex: isLive && isDesktop
                ? 6
                : isLive
                ? 1
                : 2,
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        columns[i]?.title ?? _getDefaultTitle(i),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelXSmall(
                          color: const Color(0xFF9C9B95),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Teams section with cards and scores
class _TeamsSection extends StatelessWidget {
  final LeagueEventData event;
  final LeagueData? league;
  final bool isLive;
  final bool isDesktop;
  final VoidCallback? onTap;

  const _TeamsSection({
    required this.event,
    this.league,
    required this.isLive,
    required this.isDesktop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isDesktop && isLive ? 4 : 1,
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teams column
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TeamDisplay(
                            teamName: event.homeName,
                            teamLogo: event.homeLogo,
                            isHome: true,
                          ),
                        ),
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TeamDisplay(
                            teamName: event.awayName,
                            teamLogo: event.awayLogo,
                            isHome: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Cards and score for live matches
                if (isLive) ...[
                  // Yellow cards
                  _CardsColumn(
                    homeCount: event.yellowCardsHome,
                    awayCount: event.yellowCardsAway,
                    color: const Color(0xFFD4A017),
                    textColor: const Color(0xFF1A1A1A),
                  ),
                  // Red cards
                  _CardsColumn(
                    homeCount: event.redCardsHome,
                    awayCount: event.redCardsAway,
                    color: const Color(0xFFCC3333),
                    textColor: const Color(0xFFFFFEF5),
                  ),
                  const SizedBox(width: 4),
                  // Score container
                  _ScoreColumn(
                    eventId: event.eventId,
                    homeScore: event.homeScore,
                    awayScore: event.awayScore,
                  ),
                ],

                if (isDesktop) const Spacer(),
              ],
            ),

            // Livestream badge (fetches h5Link, tap -> PiP)
            if (isLive && event.isLivestream == true)
              _LivestreamBadgePiP(event: event, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

/// Livestream badge: Chỉ hiện icon khi có h5Link. Tap -> PiP ngay + loading, rồi load video.
class _LivestreamBadgePiP extends StatefulWidget {
  final LeagueEventData event;
  final VoidCallback? onTap;

  const _LivestreamBadgePiP({required this.event, this.onTap});

  @override
  State<_LivestreamBadgePiP> createState() => _LivestreamBadgePiPState();
}

class _LivestreamBadgePiPState extends State<_LivestreamBadgePiP> {
  String? _h5Link;
  late final PipManager _pm = PipManager();

  bool get _hasH5Link => _h5Link != null && _h5Link!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.event.isLive && widget.event.isLivestream == true) {
      _fetchH5Link();
    }
  }

  @override
  void didUpdateWidget(_LivestreamBadgePiP oldWidget) {
    super.didUpdateWidget(oldWidget);
    final had = oldWidget.event.isLive && oldWidget.event.isLivestream == true;
    final has = widget.event.isLive && widget.event.isLivestream == true;
    if (has && !had) _fetchH5Link();
    if (!has) setState(() => _h5Link = null);
  }

  Future<void> _fetchH5Link() async {
    try {
      final httpManager = SbHttpManager.instance;
      final brand = SbConfig.brandId;
      final eventId = widget.event.eventId.toString();
      final response = await httpManager.getLiveLink(eventId, brand);
      if (!mounted) return;
      setState(() => _h5Link = response.url);
    } catch (_) {
      if (mounted) setState(() => _h5Link = null);
    }
  }

  void _onTap() {
    if (!_hasH5Link) {
      widget.onTap?.call();
      return;
    }
    _pm.setOnVideoPage(false);
    _pm.initialize(context);
    _pm.loadUrlForPiP(_h5Link!, context);
    _pm.showPiP();
    _pm.liftToOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasH5Link) return const SizedBox.shrink();

    return SizedBox(
      height: 50,
      child: Column(
        children: [
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _onTap,
            child: SizedBox(
              width: 40,
              height: 26,
              child: ImageHelper.getNetworkImage(imageUrl: AppImages.live),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cards column (yellow/red)
class _CardsColumn extends StatelessWidget {
  final int homeCount;
  final int awayCount;
  final Color color;
  final Color textColor;

  const _CardsColumn({
    required this.homeCount,
    required this.awayCount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Column(
        children: [
          _CardCell(count: homeCount, color: color, textColor: textColor),
          _CardCell(count: awayCount, color: color, textColor: textColor),
        ],
      ),
    );
  }
}

class _CardCell extends StatelessWidget {
  final int count;
  final Color color;
  final Color textColor;

  const _CardCell({
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: count > 0
          ? Container(
              width: 16,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Score column with live updates
class _ScoreColumn extends StatelessWidget {
  final int eventId;
  final int homeScore;
  final int awayScore;

  const _ScoreColumn({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        border: Border.all(color: const Color(0xFF393836)),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(top: 5.5),
      child: Column(
        children: [
          Container(
            height: 25.5,
            alignment: Alignment.center,
            child: LiveSingleScoreDisplay(
              eventId: eventId,
              isHome: true,
              initialValue: homeScore,
            ),
          ),
          Container(
            height: 25.5,
            alignment: Alignment.center,
            child: LiveSingleScoreDisplay(
              eventId: eventId,
              isHome: false,
              initialValue: awayScore,
            ),
          ),
        ],
      ),
    );
  }
}

/// Odds section with bet columns
class _OddsSection extends StatelessWidget {
  final int sportId;
  final LeagueEventData event;
  final LeagueData? league;
  final List<BetColumn?> columns; // ✅ Nullable columns
  final int maxColumnItems;
  final bool isLive;
  final bool isDesktop;

  const _OddsSection({
    required this.sportId,
    required this.event,
    this.league,
    required this.columns,
    required this.maxColumnItems,
    required this.isLive,
    required this.isDesktop,
  });

  bool _is1X2Column(BetColumn column) {
    return column.type == BetColumnType.matchResult;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isLive && isDesktop
          ? 6
          : isLive
          ? 1
          : 2,
      child: SizedBox(
        height: 130,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              Expanded(
                child: Column(children: _buildColumnItems(columns[i], i)),
              ),
              if (i != columns.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildColumnItems(BetColumn? column, int columnIndex) {
    // ✅ Nếu column = null hoặc empty (market bị suspended/hidden)
    // → Render locked placeholder widgets
    if (column == null || column.items.isEmpty) {
      return _buildLockedPlaceholder(columnIndex);
    }

    final items = column.items;
    final is1X2 = _is1X2Column(column);
    final itemCount = is1X2 ? 3 : 2;

    return List.generate(itemCount, (index) {
      final isLast = index == itemCount - 1;

      if (index < items.length) {
        final item = items[index];

        BettingPopupData? bettingData;
        if (item.oddsData != null &&
            item.marketData != null &&
            item.oddsType != null) {
          bettingData = BettingPopupData(
            sportId: sportId,
            oddsData: item.oddsData!,
            marketData: item.marketData!,
            eventData: event,
            oddsType: item.oddsType!,
            leagueData: league,
            oddsStyle: OddsStyle.decimal,
          );
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
            child: SizedBox.expand(
              child: BetCardMobile(
                label: item.label,
                value: item.value,
                selectionId: item.selectionId,
                bettingPopupData: bettingData,
                isVertical: true,
                isDesktop: isDesktop,
                isSetHeightOdds: true,
              ),
            ),
          ),
        );
      }

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
          child: const SizedBox.expand(),
        ),
      );
    });
  }

  /// Build locked placeholder widgets khi market bị suspended/hidden
  ///
  /// columnIndex: 0=Handicap (2 items), 1=O/U (2 items), 2=1X2 (3 items)
  List<Widget> _buildLockedPlaceholder(int columnIndex) {
    // 1X2 = 3 items, Handicap/O/U = 2 items
    final itemCount = columnIndex == 2 ? 3 : 2;

    return List.generate(itemCount, (index) {
      final isLast = index == itemCount - 1;

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
          child: SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock, size: 16, color: Colors.white54),
            ),
          ),
        ),
      );
    });
  }
}

/// Footer with action icons and more markets
class _MatchFooter extends StatelessWidget {
  final LeagueEventData event;
  final LeagueData? league;
  final bool canShowStats;
  final bool canShowTracker;
  final VoidCallback? onNavigate;

  const _MatchFooter({
    required this.event,
    this.league,
    required this.canShowStats,
    required this.canShowTracker,
    this.onNavigate,
  });

  int? get _moreMarketsCount {
    final count = event.markets.length;
    return count > 3 ? count - 3 : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorStyles.backgroundQuaternary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Action icons
          Row(
            children: [
              // Stats icon (no RepaintBoundary needed for small static icons)
              GestureDetector(
                onTap: canShowStats ? () => _showStatsDialog(context) : null,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: ImageHelper.load(
                    path: AppIcons.iconBarChart,
                    color: canShowStats
                        ? AppColorStyles.contentSecondary
                        : AppColorStyles.contentSecondary.withValues(
                            alpha: 0.3,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Tracker icon (no RepaintBoundary needed for small static icons)
              GestureDetector(
                onTap: canShowTracker ? () => _showTrackerPopup(context) : null,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: ImageHelper.load(
                    path: AppIcons.iconChart,
                    color: canShowTracker
                        ? AppColorStyles.contentSecondary
                        : AppColorStyles.contentSecondary.withValues(
                            alpha: 0.3,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Parlay icon
              const _ParlayIconButton(),
            ],
          ),
          const Spacer(),
          // More markets count
          if (_moreMarketsCount != null)
            GestureDetector(
              onTap: onNavigate,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$_moreMarketsCount',
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFFEF5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFFFFFEF5),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    StatsDialog.showForMatch(
      context: context,
      eventStatsId: event.eventStatsId,
      homeName: event.homeName,
      awayName: event.awayName,
      config: StatsDialogConfig.mobile,
      width: MediaQuery.of(context).size.width,
    );
  }

  void _showTrackerPopup(BuildContext context) {
    TrackerPopupDialog.show(
      context: context,
      eventStatsId: event.eventStatsId,
      homeName: event.homeName,
      awayName: event.awayName,
    );
  }
}

/// Parlay icon button with tooltip
class _ParlayIconButton extends StatefulWidget {
  const _ParlayIconButton();

  @override
  State<_ParlayIconButton> createState() => _ParlayIconButtonState();
}

class _ParlayIconButtonState extends State<_ParlayIconButton> {
  final GlobalKey _iconKey = GlobalKey();

  void _showTooltip() {
    ParlayTooltip.show(
      context: context,
      targetKey: _iconKey,
      message: 'Trận này chưa thêm vào cược xiên',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTooltip,
      child: SizedBox(
        key: _iconKey,
        width: 20,
        height: 20,
        // No RepaintBoundary needed for small static icons
        child: ImageHelper.load(
          path: AppIcons.iconParlay,
          color: AppColorStyles.contentSecondary,
        ),
      ),
    );
  }
}
