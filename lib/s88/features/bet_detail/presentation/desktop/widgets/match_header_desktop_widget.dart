import 'package:flutter/material.dart';

import 'desktop_livestream_iframe_stub.dart'
    if (dart.library.html) 'desktop_livestream_iframe_web.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';
import 'package:co_caro_flame/s88/shared/widgets/stats/stats_dialog.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';

/// Desktop match header widget displaying team names, score, match status, and statistics
///
/// Differences from mobile:
/// - No "Theo dõi" (Tracker) tab - tracker is displayed in right sidebar
/// - Only has: Thống kê, Bảng điểm, Trực tuyến tabs
/// - When [isDesktop] is true, livestream is displayed embedded like tracker using iframe
class MatchHeaderDesktopWidget extends StatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  /// Current sport ID (from selectedSportV2Provider) for background image selection
  final int sportId;

  /// When true, livestream will be displayed embedded using iframe (for web desktop size)
  final bool isDesktop;

  const MatchHeaderDesktopWidget({
    super.key,
    required this.eventData,
    this.leagueData,
    required this.sportId,
    this.isDesktop = false,
  });

  @override
  State<MatchHeaderDesktopWidget> createState() =>
      _MatchHeaderDesktopWidgetState();
}

enum _DesktopMatchTab { statistics, scoreboard, live }

class _MatchHeaderDesktopWidgetState extends State<MatchHeaderDesktopWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late _DesktopMatchTab _selectedTab;

  String? _livestreamUrl;
  bool _isCheckingLivestream = false;

  bool get hasLivestreamUrl {
    if (!widget.eventData.isLive || !widget.eventData.isLivestream) {
      return false;
    }
    return _livestreamUrl != null && _livestreamUrl!.isNotEmpty;
  }

  /// Check if stats can be shown (eventStatsId > 0)
  bool get _canShowStats => widget.eventData.eventStatsId > 0;

  /// Show stats dialog with WebView
  void _showStatsDialog(BuildContext context) {
    if (!_canShowStats) return;

    StatsDialog.showForMatch(
      context: context,
      eventStatsId: widget.eventData.eventStatsId,
      homeName: widget.eventData.homeName,
      awayName: widget.eventData.awayName,
      config: StatsDialogConfig.desktop,
      width: 640,
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedTab = _DesktopMatchTab.scoreboard;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.eventData.isLive) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.eventData.isLive && widget.eventData.isLivestream) {
      _checkLivestreamUrl();
    }
  }

  Future<void> _checkLivestreamUrl() async {
    if (_isCheckingLivestream) return;

    setState(() {
      _isCheckingLivestream = true;
    });

    try {
      final httpManager = SbHttpManager.instance;
      final brand = SbConfig.brandId;
      final eventId = widget.eventData.eventId.toString();

      final response = await httpManager.getLiveLink(eventId, brand);

      if (mounted) {
        setState(() {
          _livestreamUrl = response.url;
          _isCheckingLivestream = false;

          if (hasLivestreamUrl && _selectedTab == _DesktopMatchTab.scoreboard) {
            _selectedTab = _DesktopMatchTab.live;
          } else if (!hasLivestreamUrl &&
              _selectedTab == _DesktopMatchTab.live) {
            _selectedTab = _DesktopMatchTab.scoreboard;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _livestreamUrl = null;
          _isCheckingLivestream = false;
          if (_selectedTab == _DesktopMatchTab.live) {
            _selectedTab = _DesktopMatchTab.scoreboard;
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(MatchHeaderDesktopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.eventData.isLive != oldWidget.eventData.isLive) {
      if (widget.eventData.isLive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    final hadPrerequisites =
        oldWidget.eventData.isLive && oldWidget.eventData.isLivestream;
    final hasPrerequisites =
        widget.eventData.isLive && widget.eventData.isLivestream;

    if (hasPrerequisites != hadPrerequisites) {
      if (hasPrerequisites) {
        _checkLivestreamUrl();
      } else {
        setState(() {
          _livestreamUrl = null;
          if (_selectedTab == _DesktopMatchTab.live) {
            _selectedTab = _DesktopMatchTab.scoreboard;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main content with background
        _buildTabContent(),
        // Tabs section
        Padding(padding: const EdgeInsets.all(4), child: _buildTabs()),
      ],
    ),
  );

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case _DesktopMatchTab.statistics:
      case _DesktopMatchTab.scoreboard:
        return _buildStatisticsContent();
      case _DesktopMatchTab.live:
        return _buildLivestreamContent();
    }
  }

  /// Get statistics background image URL based on sportId
  String _getStatisticsBackgroundImageUrl() {
    switch (widget.sportId) {
      case 1:
        return AppImages.soccerstadiumphotoshot1; // Bóng đá
      case 2:
        return AppImages.betDetailBackgroundBaseketball; // Bóng rổ
      case 4:
        return AppImages.betDetailBackgroundTennis; // Tennis
      case 5:
        return AppImages.betDetailBackgroundVolleyball; // Bóng chuyền
      default:
        return AppImages.soccerstadiumphotoshot1; // Fallback
    }
  }

  Widget _buildStatisticsContent() => Container(
    constraints: const BoxConstraints(minHeight: 208),
    child: Stack(
      children: [
        // Background image with overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ImageHelper.getNetworkImage(
                    imageUrl: _getStatisticsBackgroundImageUrl(),
                    fit: BoxFit.fill,
                  ),
                ),
                Container(color: const Color(0xFF1B1A19).withOpacity(0.7)),
              ],
            ),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: 40,
          ),
          child: _buildStatisticsTable(),
        ),
      ],
    ),
  );

  /// Livestream content - shows iframe when isDesktop is true
  /// Otherwise shows statistics view (livestream handled via external player or sidebar)
  Widget _buildLivestreamContent() {
    // If not desktop mode, show statistics content
    if (!widget.isDesktop) {
      return _buildStatisticsContent();
    }

    // Desktop mode: show livestream iframe like tracker
    return _buildDesktopLivestreamIframe();
  }

  /// Build desktop livestream iframe widget (similar to tracker)
  Widget _buildDesktopLivestreamIframe() {
    if (!hasLivestreamUrl || _livestreamUrl == null) {
      return _buildLivestreamPlaceholder('Không có link livestream');
    }

    // Use separate widget with key based on URL to maintain identity
    return DesktopLivestreamIframe(
      key: ValueKey('livestream-iframe-${_livestreamUrl.hashCode}'),
      url: _livestreamUrl!,
    );
  }

  /// Build placeholder for livestream
  Widget _buildLivestreamPlaceholder(String message) => Container(
    constraints: const BoxConstraints(minHeight: 200),
    decoration: const BoxDecoration(
      color: Color(0xFF1A1A1A),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.live_tv, color: Color(0xFF666666), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.paragraphXSmall(
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStatisticsTable() {
    // Non-soccer sports use sport-specific score tables
    return switch (widget.sportId) {
      2 => StatisticsTableBasketball(
          eventData: widget.eventData,
          pulseAnimation: _pulseAnimation,
        ),
      4 => StatisticsTableTennis(
          eventData: widget.eventData,
          pulseAnimation: _pulseAnimation,
        ),
      5 => StatisticsTableVolleyball(
          eventData: widget.eventData,
          pulseAnimation: _pulseAnimation,
        ),
      7 => StatisticsTableBadminton(
          eventData: widget.eventData,
          pulseAnimation: _pulseAnimation,
        ),
      _ => _buildSoccerStatisticsTable(),
    };
  }

  Widget _buildSoccerStatisticsTable() => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColorStyles.backgroundTertiary,
      ),
      child: Row(
        children: [
          // Team column with live indicator
          Flexible(
            child: Column(
              children: [
                // Header row with live indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Live indicator dot with pulsing effect
                      if (widget.eventData.isLive)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulsing ring
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5172)
                                          .withOpacity(
                                            0.12 * _pulseAnimation.value,
                                          ),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                              // Middle pulsing ring
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5172)
                                          .withOpacity(
                                            0.12 * _pulseAnimation.value,
                                          ),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                              // Inner solid dot
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5172),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.eventData.isLive) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: LiveMatchTimeDisplay(
                            eventId: widget.eventData.eventId,
                            initialMinute:
                                widget.eventData.minuteString.isNotEmpty
                                ? widget.eventData.minuteString
                                : null,
                            initialPeriod:
                                widget.eventData.gamePartEnum.displayName,
                            style: AppTextStyles.paragraphSmall(
                              color: AppColorStyles.contentSecondary,
                            ),
                            separator: const SizedBox(width: 12),
                          ),
                        ),
                      ],
                      if (!widget.eventData.isLive) ...[
                        Text(
                          widget.eventData.formattedTime,
                          style: AppTextStyles.paragraphSmall(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Home team row
                _buildTeamRow(
                  teamName: widget.eventData.homeName,
                  logoUrl:
                      widget.eventData.homeLogoFirst ??
                      widget.eventData.homeLogoLast ??
                      '',
                ),
                // Away team row
                _buildTeamRow(
                  teamName: widget.eventData.awayName,
                  logoUrl:
                      widget.eventData.awayLogoFirst ??
                      widget.eventData.awayLogoLast ??
                      '',
                ),
              ],
            ),
          ),
          // Statistics columns
          Flexible(
            child: Row(
              children: [
                // Corner kicks column
                _buildStatColumn(
                  icon: _buildCornerKickIcon(),
                  homeValue: widget.eventData.cornersHome,
                  awayValue: widget.eventData.cornersAway,
                ),
                // Yellow cards column
                _buildStatColumn(
                  icon: _buildYellowCardIcon(),
                  homeValue: widget.eventData.yellowCardsHome,
                  awayValue: widget.eventData.yellowCardsAway,
                ),
                // Red cards column
                _buildStatColumn(
                  icon: _buildRedCardIcon(),
                  homeValue: widget.eventData.redCardsHome,
                  awayValue: widget.eventData.redCardsAway,
                ),
                // 2nd half goals column
                _buildStatColumn(
                  icon: Text(
                    '2nd',
                    style: AppTextStyles.labelXSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  homeValue: 0,
                  awayValue: 0,
                ),
                // Total goals column
                _buildStatColumn(
                  icon: _buildFootballIcon(),
                  homeValue: widget.eventData.homeScore,
                  awayValue: widget.eventData.awayScore,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTeamRow({required String teamName, required String logoUrl}) =>
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
        child: Row(
          children: [
            // Team logo
            if (logoUrl.isNotEmpty)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 28),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 20,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            const SizedBox(width: 8),
            // Team name
            Expanded(
              child: Text(
                teamName,
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildStatColumn({
    required Widget icon,
    required int homeValue,
    required int awayValue,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Column(
        children: [
          // Header with icon
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: icon),
          ),
          // Home team value
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '$homeValue',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
          // Away team value
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '$awayValue',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCornerKickIcon() =>
      ImageHelper.load(path: AppIcons.phatGoc, width: 20, height: 20);

  Widget _buildYellowCardIcon() =>
      ImageHelper.load(path: AppIcons.iconYellowCard, width: 20, height: 20);

  Widget _buildRedCardIcon() =>
      ImageHelper.load(path: AppIcons.iconRedCard, width: 20, height: 20);

  Widget _buildFootballIcon() => ImageHelper.load(
    path: AppIcons.iconSoccer,
    width: 20,
    height: 20,
    fit: BoxFit.fill,
  );

  Widget _buildTabs() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Thống kê tab (left side)
      InkWell(
        onTap: _canShowStats ? () => _showStatsDialog(context) : null,
        child: Opacity(
          opacity: _canShowStats ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Thống kê',
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _canShowStats
                      ? AppColorStyles.contentPrimary
                      : AppColorStyles.contentSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
      // Right side tabs container (no "Theo dõi" tab for desktop)
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF111010),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Bảng điểm tab
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (_selectedTab != _DesktopMatchTab.scoreboard) {
                    setState(() {
                      _selectedTab = _DesktopMatchTab.scoreboard;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 32,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedTab == _DesktopMatchTab.scoreboard
                        ? AppColorStyles.backgroundQuaternary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Bảng điểm',
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _selectedTab == _DesktopMatchTab.scoreboard
                            ? AppColorStyles.contentPrimary
                            : AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Trực tuyến tab (Livestream)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: hasLivestreamUrl
                    ? () {
                        if (_selectedTab != _DesktopMatchTab.live) {
                          setState(() {
                            _selectedTab = _DesktopMatchTab.live;
                          });
                        }
                      }
                    : null,
                child: Opacity(
                  opacity: hasLivestreamUrl ? 1.0 : 0.5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedTab == _DesktopMatchTab.live
                          ? AppColorStyles.backgroundQuaternary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Trực tuyến',
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _selectedTab == _DesktopMatchTab.live
                                ? AppColorStyles.contentPrimary
                                : AppColorStyles.contentSecondary,
                          ),
                        ),
                        if (hasLivestreamUrl) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFD6F8E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
