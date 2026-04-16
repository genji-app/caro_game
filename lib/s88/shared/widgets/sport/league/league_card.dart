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
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row.dart';

/// Unified LeagueCard for both mobile and desktop
///
/// Features:
/// - Expand/collapse animation
/// - Progressive rendering for large lists
/// - Platform-aware styling
///
/// Performance:
/// - Uses ConsumerStatefulWidget (not Hook)
/// - Children manage their own reactive state
/// - Parent only handles structure and animation
class LeagueCard extends ConsumerStatefulWidget {
  final LeagueData league;

  /// Platform mode: true = desktop layout, false = mobile layout
  final bool isDesktop;

  /// Max matches to show (for pagination). null = show all
  final int? maxVisibleMatches;

  /// Enable progressive rendering (batch loading)
  /// Only used when maxVisibleMatches is null
  final bool enableProgressiveRendering;

  /// Initial expanded state
  final bool initiallyExpanded;

  /// Callback when expand state changes
  final ValueChanged<bool>? onExpandChanged;

  const LeagueCard({
    super.key,
    required this.league,
    this.isDesktop = false,
    this.maxVisibleMatches,
    this.enableProgressiveRendering = true,
    this.initiallyExpanded = true,
    this.onExpandChanged,
  });

  @override
  ConsumerState<LeagueCard> createState() => _LeagueCardState();
}

class _LeagueCardState extends ConsumerState<LeagueCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _rotationAnimation;

  bool _isExpanded = true;
  int _renderedCount = 0;

  /// Token to cancel progressive rendering when widget updates or disposes
  /// Prevents memory leak from accumulated Future.doWhile chains
  int _progressiveRenderingToken = 0;

  // Progressive rendering config
  static const int _batchSize = 10;
  static const Duration _batchDelay = Duration(milliseconds: 50);

  // Fixed height for each match row item for performance optimization
  static const double _matchRowHeight = 220.0;
  static const double _matchRowHeightDesktop = 200.0;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isExpanded ? 0.0 : 1.0,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    // Start progressive rendering
    if (widget.enableProgressiveRendering && widget.maxVisibleMatches == null) {
      _startProgressiveRendering();
    } else {
      _renderedCount = _effectiveMatchCount;
    }
  }

  int get _effectiveMatchCount {
    final total = widget.league.events.length;
    return widget.maxVisibleMatches?.clamp(0, total) ?? total;
  }

  double get _itemHeight =>
      widget.isDesktop ? _matchRowHeightDesktop : _matchRowHeight;

  void _startProgressiveRendering() {
    // Increment token to cancel any previous progressive rendering chain
    // This prevents memory leak from accumulated Future.doWhile chains
    _progressiveRenderingToken++;
    final currentToken = _progressiveRenderingToken;

    _renderedCount = _batchSize.clamp(0, _effectiveMatchCount);

    Future.doWhile(() async {
      // Check if this chain is still valid (not cancelled by new chain or dispose)
      if (!mounted || currentToken != _progressiveRenderingToken) return false;
      if (_renderedCount >= _effectiveMatchCount) return false;

      await Future<void>.delayed(_batchDelay);

      // Re-check after delay
      if (!mounted || currentToken != _progressiveRenderingToken) return false;

      setState(() {
        _renderedCount = (_renderedCount + _batchSize).clamp(
          0,
          _effectiveMatchCount,
        );
      });

      return _renderedCount < _effectiveMatchCount;
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }

    widget.onExpandChanged?.call(_isExpanded);
  }

  @override
  void didUpdateWidget(LeagueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset if league changed
    if (oldWidget.league.leagueId != widget.league.leagueId) {
      _renderedCount = 0;
      if (widget.enableProgressiveRendering &&
          widget.maxVisibleMatches == null) {
        _startProgressiveRendering();
      } else {
        _renderedCount = _effectiveMatchCount;
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.league.events;
    if (events.isEmpty) return const SizedBox.shrink();

    // IMPORTANT: Clamp _renderedCount to actual events.length
    // This prevents RangeError when events list shrinks after WebSocket refresh
    final safeRenderedCount = _renderedCount.clamp(0, events.length);

    // Get current sport ID for icon fallback
    final currentSportId = ref.watch(
      leagueProvider.select((s) => s.currentSportId),
    );

    return Container(
      margin: EdgeInsets.only(bottom: widget.isDesktop ? 8 : 4),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League header
          _LeagueHeader(
            league: widget.league,
            isExpanded: _isExpanded,
            isDesktop: widget.isDesktop,
            currentSportId: currentSportId,
            rotationAnimation: _rotationAnimation,
            onTap: _toggleExpand,
          ),

          // Matches section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Column(
                    children: [
                      SizedBox(
                        height: safeRenderedCount * _itemHeight,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: safeRenderedCount,
                          itemExtent: _itemHeight,
                          addAutomaticKeepAlives: true,
                          addRepaintBoundaries: true,
                          cacheExtent: 500,
                          itemBuilder: (context, i) => RepaintBoundary(
                            child: MatchRow(
                              key: ValueKey(events[i].eventId),
                              event: events[i],
                              league: widget.league,
                              isDesktop: widget.isDesktop,
                            ),
                          ),
                        ),
                      ),
                      // Loading indicator when more items are being loaded
                      if (safeRenderedCount < _effectiveMatchCount)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFFFD700).withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// League header with expand/collapse button
class _LeagueHeader extends StatelessWidget {
  final LeagueData league;
  final bool isExpanded;
  final bool isDesktop;
  final int currentSportId;
  final Animation<double> rotationAnimation;
  final VoidCallback onTap;

  static const _logoDecoration = BoxDecoration(
    color: Color(0xFFE0E0E0),
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );

  const _LeagueHeader({
    required this.league,
    required this.isExpanded,
    required this.isDesktop,
    required this.currentSportId,
    required this.rotationAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDesktop ? 48 : 40,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // League logo (no RepaintBoundary needed for small static icons)
                league.leagueLogo.isNotEmpty
                    ? Container(
                        width: isDesktop ? 28 : 26,
                        height: isDesktop ? 28 : 26,
                        decoration: _logoDecoration,
                        padding: const EdgeInsets.all(2),
                        child: ImageHelper.getNetworkImage(
                          imageUrl: league.leagueLogo,
                          width: isDesktop ? 24 : 22,
                          height: isDesktop ? 24 : 22,
                          fit: BoxFit.contain,
                          errorWidget: ImageHelper.load(
                            path: AppIcons.iconSoccer,
                          ),
                          placeholder: const SizedBox.shrink(),
                        ),
                      )
                    : ImageHelper.load(
                        path: SportType.fromId(currentSportId)?.iconPath ?? '',
                        width: isDesktop ? 26 : 24,
                        height: isDesktop ? 26 : 24,
                        fit: BoxFit.contain,
                        color: const Color(0xB3FFFCDB),
                      ),
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
          // Chevron icon
          GestureDetector(
            onTap: onTap,
            child: RotationTransition(
              turns: rotationAnimation,
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
        ],
      ),
    );
  }
}
