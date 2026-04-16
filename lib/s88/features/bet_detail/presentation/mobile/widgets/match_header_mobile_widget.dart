import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/stats/stats_dialog.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_tennis.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_basketball.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_volleyball.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/statistics_table_badminton.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/livestream_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/tracker/tracker_widget.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/pip_manager.dart';

/// Mobile match header widget displaying team names, score, match status, and statistics
///
/// Simplified version for mobile screens with vertical layout
class MatchHeaderMobileWidget extends StatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  /// Current sport ID (from selectedSportV2Provider) for background image
  final int sportId;

  final bool
  hideStatisticsTable; // Ẩn statistics table khi sticky header đã xuất hiện
  final GlobalKey? statisticsTableKey; // Key để track vị trí cho fake sticky
  final bool
  hideStatisticsTableOpacity; // Ẩn bằng opacity khi sticky (fake sticky pattern)
  final GlobalKey? livestreamKey; // Key để track vị trí của LivestreamWidget
  final void Function(MatchTab)? onTabChanged; // Callback khi tab thay đổi

  const MatchHeaderMobileWidget({
    super.key,
    required this.eventData,
    this.leagueData,
    required this.sportId,
    this.hideStatisticsTable = false,
    this.statisticsTableKey,
    this.hideStatisticsTableOpacity = false,
    this.livestreamKey,
    this.onTabChanged,
  });

  @override
  State<MatchHeaderMobileWidget> createState() =>
      _MatchHeaderMobileWidgetState();
}

/// Enum để track tab (dùng cho cả internal và external)
enum MatchTab { statistics, scoreboard, follow, live }

/// Public interface để control tab từ bên ngoài
abstract class MatchHeaderTabController {
  void setTab(MatchTab tab);
}

class _MatchHeaderMobileWidgetState extends State<MatchHeaderMobileWidget>
    with TickerProviderStateMixin
    implements MatchHeaderTabController {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late MatchTab _selectedTab;

  /// Method để set tab từ bên ngoài
  void setTab(MatchTab tab) {
    if (_selectedTab != tab) {
      // Pause video khi switch sang tab khác (không phải tab "Trực tuyến")
      if (tab != MatchTab.live) {
        _pauseVideoIfPlaying();
      } else {
        // Switch về tab "Trực tuyến": Play video nếu đang pause
        _playVideoIfPaused();
      }
      setState(() {
        _selectedTab = tab;
      });
      widget.onTabChanged?.call(tab);
    }
  }

  /// Pause video nếu đang play (khi switch sang tab khác)
  /// Fix Bug 1: Đảm bảo video luôn pause khi click tab (kể cả khi đã ở tab đó)
  /// Livestream dùng WebView: không cần pause/play khi đổi tab (WebView tự quản lý).
  void _pauseVideoIfPlaying() {}

  void _playVideoIfPaused() {}

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
      config: StatsDialogConfig.mobile,
      width: MediaQuery.of(context).size.width,
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedTab = MatchTab.scoreboard;
    // Notify initial tab state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabChanged?.call(_selectedTab);
    });

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

          if (hasLivestreamUrl && _selectedTab == MatchTab.scoreboard) {
            _selectedTab = MatchTab.live;
            widget.onTabChanged?.call(_selectedTab);
          } else if (!hasLivestreamUrl && _selectedTab == MatchTab.live) {
            _selectedTab = MatchTab.scoreboard;
            widget.onTabChanged?.call(_selectedTab);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _livestreamUrl = null;
          _isCheckingLivestream = false;
          if (_selectedTab == MatchTab.live) {
            _selectedTab = MatchTab.scoreboard;
            widget.onTabChanged?.call(_selectedTab);
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(MatchHeaderMobileWidget oldWidget) {
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
          if (_selectedTab == MatchTab.live) {
            _selectedTab = MatchTab.scoreboard;
            widget.onTabChanged?.call(_selectedTab);
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
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.circular(16),
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
      case MatchTab.follow:
        return _buildTrackerContent();
      case MatchTab.live:
        return _buildLiveContent();
      case MatchTab.scoreboard:
      case MatchTab.statistics:
        return _buildStatisticsContent();
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
      case 7:
        return AppIcons.iconBadminton; // Cầu lông (dùng chung bg volleyball)
      default:
        return AppImages.soccerstadiumphotoshot1; // Fallback
    }
  }

  Widget _buildStatisticsContent() => Container(
    constraints: const BoxConstraints(minHeight: 140),
    child: Stack(
      children: [
        // Background image with overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: const Color.fromRGBO(255, 255, 255, 0.12),
                  width: 1.0,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(12),
          child: _buildStatisticsTable(),
        ),
      ],
    ),
  );

  Widget _buildStatisticsTable() {
    return switch (widget.sportId) {
      2 => StatisticsTableBasketball(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      4 => StatisticsTableTennis(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      5 => StatisticsTableVolleyball(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      7 => StatisticsTableBadminton(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
        isDesktop: false,
      ),
      _ => MobileStatisticsTableWidget(
        key: widget.statisticsTableKey,
        eventData: widget.eventData,
        pulseAnimation: _pulseAnimation,
      ),
    };
  }

  Widget _buildTrackerContent() => Container(
    constraints: const BoxConstraints(minHeight: 200),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: TrackerWidget(
        eventStatsId: widget.eventData.eventStatsId,
        sportId: widget.sportId,
        height: 250,
      ),
    ),
  );

  Widget _buildLiveContent() => Container(
    // constraints: const BoxConstraints(minHeight: 200),
    child: LivestreamWidget(
      key: widget.livestreamKey,
      url: _livestreamUrl ?? '',
      eventData: widget.eventData,
      onPiPActivated: () {
        // Chuyển tab sang "Bảng điểm" khi PiP được activate
        setTab(MatchTab.scoreboard);
      },
    ),
  );

  Widget _buildTabs() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Thống kê tab (left side)
      GestureDetector(
        onTap: () {
          _showStatsDialog(context);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 14),
          child: ImageHelper.load(
            path: AppIcons.iconChart,
            width: 20,
            height: 20,
          ),
        ),
      ),
      // Right side tabs container
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF111010),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Bảng điểm tab
            GestureDetector(
              onTap: () {
                // Pause video mỗi lần click (kể cả khi đã ở tab đó)
                // Fix Bug 1: Đảm bảo video luôn pause khi click tab "Bảng điểm"
                _pauseVideoIfPlaying();
                if (_selectedTab != MatchTab.scoreboard) {
                  setState(() {
                    _selectedTab = MatchTab.scoreboard;
                  });
                  widget.onTabChanged?.call(_selectedTab);
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
                  color: _selectedTab == MatchTab.scoreboard
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
                      color: _selectedTab == MatchTab.scoreboard
                          ? AppColorStyles.contentPrimary
                          : AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Theo dõi tab
            GestureDetector(
              onTap: () {
                // Pause video mỗi lần click (kể cả khi đã ở tab đó)
                // Fix Bug 1: Đảm bảo video luôn pause khi click tab "Theo dõi"
                _pauseVideoIfPlaying();
                if (_selectedTab != MatchTab.follow) {
                  setState(() {
                    _selectedTab = MatchTab.follow;
                  });
                  widget.onTabChanged?.call(_selectedTab);
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
                  color: _selectedTab == MatchTab.follow
                      ? AppColorStyles.backgroundQuaternary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Theo dõi',
                    style: AppTextStyles.textStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _selectedTab == MatchTab.follow
                          ? AppColorStyles.contentPrimary
                          : AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Trực tuyến tab
            if (hasLivestreamUrl)
              GestureDetector(
                onTap: hasLivestreamUrl
                    ? () {
                        if (_selectedTab != MatchTab.live) {
                          // Play video nếu đang pause khi switch về tab "Trực tuyến"
                          _playVideoIfPaused();
                          setState(() {
                            _selectedTab = MatchTab.live;
                          });
                          widget.onTabChanged?.call(_selectedTab);
                          // Note: Logic đóng PiP khi chọn tab "Trực tuyến"
                          // được xử lý trong LivestreamWidgetImpl.didUpdateWidget()
                          // để đảm bảo widget tự quản lý state của nó
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
                      color: _selectedTab == MatchTab.live
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
                            color: _selectedTab == MatchTab.live
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
          ],
        ),
      ),
    ],
  );
}
