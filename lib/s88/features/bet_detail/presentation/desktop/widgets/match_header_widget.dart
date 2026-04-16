import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Match header widget displaying team names, score, match status, and statistics
///
/// Based on Figma design: https://www.figma.com/design/Kmxt5j4aqDHQBPQNOCpuEw/Sun-Sport?node-id=1396-132690
class MatchHeaderWidget extends StatefulWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  const MatchHeaderWidget({
    super.key,
    required this.eventData,
    this.leagueData,
  });

  @override
  State<MatchHeaderWidget> createState() => _MatchHeaderWidgetState();
}

enum _MatchTab {
  scoreboard, // Bảng điểm
  live, // Trực tuyến
}

class _MatchHeaderWidgetState extends State<MatchHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late _MatchTab _selectedTab;

  /// Actual livestream URL from API (null if not available)
  String? _livestreamUrl;

  /// Loading state for checking livestream URL
  bool _isCheckingLivestream = false;

  /// Check if match has livestream URL
  /// According to FLUTTER_LIVE_MATCH_DISPLAY_GUIDE.md:
  /// - isLive = true && isLivestream = true → check API for actual URL
  /// - Must have h5Link in API response to show livestream
  bool get hasLivestreamUrl {
    // First check: isLive && isLivestream (prerequisite)
    if (!widget.eventData.isLive || !widget.eventData.isLivestream) {
      return false;
    }
    // Second check: actual livestream URL from API exists
    return _livestreamUrl != null && _livestreamUrl!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    // Set default tab - will update after checking livestream URL
    _selectedTab = _MatchTab.scoreboard;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animation if match is live
    if (widget.eventData.isLive) {
      _pulseController.repeat(reverse: true);
    }

    // Check livestream URL from API if prerequisites are met
    if (widget.eventData.isLive && widget.eventData.isLivestream) {
      _checkLivestreamUrl();
    }
  }

  /// Check livestream URL from API
  /// According to FLUTTER_LIVE_MATCH_DISPLAY_GUIDE.md:
  /// - Call getLiveLink(eventId, brandLogo) to get actual URL
  /// - Response: { "h5Link": "https://...", "type": 1 }
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

          // Update selected tab based on livestream URL availability
          // If has livestream URL → default to "Trực tuyến"
          // Otherwise → default to "Bảng điểm"
          if (hasLivestreamUrl && _selectedTab == _MatchTab.scoreboard) {
            _selectedTab = _MatchTab.live;
          } else if (!hasLivestreamUrl && _selectedTab == _MatchTab.live) {
            _selectedTab = _MatchTab.scoreboard;
          }
        });
      }
    } catch (e) {
      // If API call fails, assume no livestream URL
      if (mounted) {
        setState(() {
          _livestreamUrl = null;
          _isCheckingLivestream = false;
          if (_selectedTab == _MatchTab.live) {
            _selectedTab = _MatchTab.scoreboard;
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(MatchHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation state when live status changes
    if (widget.eventData.isLive != oldWidget.eventData.isLive) {
      if (widget.eventData.isLive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Check if livestream prerequisites changed
    final hadPrerequisites =
        oldWidget.eventData.isLive && oldWidget.eventData.isLivestream;
    final hasPrerequisites =
        widget.eventData.isLive && widget.eventData.isLivestream;

    // If prerequisites changed, re-check livestream URL
    if (hasPrerequisites != hadPrerequisites) {
      if (hasPrerequisites) {
        // New prerequisites met, check for livestream URL
        _checkLivestreamUrl();
      } else {
        // Prerequisites no longer met, clear livestream URL
        setState(() {
          _livestreamUrl = null;
          if (_selectedTab == _MatchTab.live) {
            _selectedTab = _MatchTab.scoreboard;
          }
        });
      }
    }

    // Update selected tab if livestream URL availability changes
    if (hadPrerequisites &&
        !hasLivestreamUrl &&
        _selectedTab == _MatchTab.live) {
      setState(() {
        _selectedTab = _MatchTab.scoreboard;
      });
    } else if (!hadPrerequisites &&
        hasLivestreamUrl &&
        _selectedTab == _MatchTab.scoreboard) {
      setState(() {
        _selectedTab = _MatchTab.live;
      });
    }
  }

  /// Get statistics background image URL based on sportId
  String _getStatisticsBackgroundImageUrl() {
    final sportId = SbHttpManager.instance.sportTypeId;
    switch (sportId) {
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

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main content with background
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: Stack(
            children: [
              // Background image with overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: ImageHelper.getNetworkImage(
                          imageUrl: _getStatisticsBackgroundImageUrl(),
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Dark overlay
                      Container(
                        color: const Color(0xFF1B1A19).withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
              // Content with statistics table
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 40,
                ),
                child: _buildStatisticsTable(),
              ),
            ],
          ),
        ),
        // Tabs section
        Padding(padding: const EdgeInsets.all(4), child: _buildTabs()),
      ],
    ),
  );

  Widget _buildStatisticsTable() => ClipRRect(
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
                  // height: 40,
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
                        Text(
                          widget.eventData.minuteString,
                          style: AppTextStyles.paragraphSmall(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getGamePartDisplayText(
                            widget.eventData.gamePartEnum,
                          ),
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
                // 1st half goals column
                _buildStatColumn(
                  icon: Text(
                    '1st',
                    style: AppTextStyles.labelXSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  homeValue: 0, // TODO: Get from API when available
                  awayValue: 0, // TODO: Get from API when available
                ),
                // 2nd half goals column
                _buildStatColumn(
                  icon: Text(
                    '2nd',
                    style: AppTextStyles.labelXSmall(
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                  homeValue: 0, // TODO: Get from API when available
                  awayValue: 0, // TODO: Get from API when available
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
            padding: const EdgeInsets.all(12),
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
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF111010), // var(--color/gray/900)
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Bảng điểm tab
            GestureDetector(
              onTap: () {
                if (_selectedTab != _MatchTab.scoreboard) {
                  setState(() {
                    _selectedTab = _MatchTab.scoreboard;
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
                  color: _selectedTab == _MatchTab.scoreboard
                      ? AppColorStyles.backgroundQuaternary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Bảng điểm',
                    style: AppTextStyles.labelXSmall(
                      color: _selectedTab == _MatchTab.scoreboard
                          ? AppColorStyles.contentPrimary
                          : AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Trực tuyến tab
            GestureDetector(
              onTap: hasLivestreamUrl
                  ? () {
                      if (_selectedTab != _MatchTab.live) {
                        setState(() {
                          _selectedTab = _MatchTab.live;
                        });
                      }
                    }
                  : null, // Disable if no livestream URL
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
                    color: _selectedTab == _MatchTab.live
                        ? AppColorStyles.backgroundQuaternary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Trực tuyến',
                        style: AppTextStyles.labelXSmall(
                          color: _selectedTab == _MatchTab.live
                              ? AppColorStyles.contentPrimary
                              : AppColorStyles.contentSecondary,
                        ),
                      ),
                      // Dot live hiển thị luôn nếu có livestream URL (không phụ thuộc tab nào đang chọn)
                      if (hasLivestreamUrl) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFD6F8E), // var(--color/red/400)
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

  /// Get Vietnamese display text for game part
  String _getGamePartDisplayText(GamePart gamePart) {
    switch (gamePart) {
      case GamePart.firstHalf:
        return 'Hiệp 1';
      case GamePart.secondHalf:
        return 'Hiệp 2';
      case GamePart.halfTime:
        return 'Nghỉ giữa giờ';
      case GamePart.firstHalfExtraTime:
        return 'Hiệp phụ 1';
      case GamePart.secondHalfExtraTime:
        return 'Hiệp phụ 2';
      case GamePart.halfTimeOfExtraTime:
        return 'Nghỉ hiệp phụ';
      case GamePart.extraTimeFinished:
        return 'Hết hiệp phụ';
      case GamePart.penalties:
        return 'Penalty';
      case GamePart.finished:
      case GamePart.regulaTimeFinished:
        return 'Kết thúc';
      case GamePart.notStarted:
        return gamePart.displayName;
    }
  }
}
