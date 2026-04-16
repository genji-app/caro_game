import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/scroll_aware_controller.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

// Re-export shared BetCardSport component
export 'package:co_caro_flame/s88/shared/widgets/sport/bet/bet_card_sport.dart'
    show BetCardSport;

class BetCardMobile extends ConsumerStatefulWidget {
  final String? label;
  final String? value;
  final VoidCallback? onTap;
  final bool isSelected;

  /// SelectionId để track thay đổi odds từ WebSocket
  final String? selectionId;

  /// Fallback cho isUpRange (dùng khi không có selectionId)
  final bool isUpRange;

  /// Fallback cho isDownRange (dùng khi không có selectionId)
  final bool isDownRange;

  /// Betting popup data - nếu có sẽ truyền vào popup khi click
  final BettingPopupData? bettingPopupData;

  /// Layout mode: true = vertical (sport view), false = horizontal (bet detail)
  final bool isVertical;

  final bool isDesktop;

  final bool isSetHeightOdds;

  const BetCardMobile({
    super.key,
    this.label,
    this.value,
    this.onTap,
    this.isSelected = false,
    this.selectionId,
    this.isUpRange = false,
    this.isDownRange = false,
    this.bettingPopupData,
    this.isVertical = false,
    this.isDesktop = false,
    this.isSetHeightOdds = false,
  });

  // Static constants để tránh tạo object mới
  static const defaultBgColor =
      AppColorStyles.backgroundTertiary; // rgba(0,0,0,0.4)
  static const selectedBgColor = AppColors.yellow600; // Yellow when selected
  static const upRangeBgColor = Color(0x33669F2A);
  static const downRangeBgColor = Color(0x33F04438);

  // Locked state constants
  static const lockedOpacity = 1.0;
  static const lockIconSize = 20.0;
  static const lockIconColor = Colors.white54;

  @override
  ConsumerState<BetCardMobile> createState() => _BetCardMobileState();
}

class _BetCardMobileState extends ConsumerState<BetCardMobile>
    with SingleTickerProviderStateMixin {
  // GlobalKey để lấy vị trí của card cho flying animation
  final GlobalKey _cardKey = GlobalKey();

  // Animation controller cho hiệu ứng chớp nháy
  late final AnimationController _animationController;

  // Tween animation cho opacity (từ 0.3 đến 1.0)
  late final Animation<double> _opacityAnimation;

  // Track previous up/down state để detect changes
  bool _prevShowUpRange = false;
  bool _prevShowDownRange = false;
  bool _prevIsLocked = false;

  // Scroll state listener
  late final VoidCallback _scrollListener;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to scroll state changes
    _scrollListener = _onScrollStateChanged;
    ScrollAwareController.instance.addListener(_scrollListener);

    // Initialize animation state based on initial props (fallback values)
    if (widget.isUpRange || widget.isDownRange) {
      _prevShowUpRange = widget.isUpRange;
      _prevShowDownRange = widget.isDownRange;
      if (!ScrollAwareController.instance.isScrolling) {
        _animationController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    ScrollAwareController.instance.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  /// Handle scroll state changes
  /// Pause animation when scrolling, resume when stopped
  void _onScrollStateChanged() {
    if (ScrollAwareController.instance.isScrolling) {
      // Pause animation when scrolling
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    } else {
      // Resume animation when scroll stops (if needed)
      if (_prevShowUpRange || _prevShowDownRange) {
        _animationController.repeat(reverse: true);
      }
    }
  }

  /// Get bet key for provider lookup (eventId_selectionId)
  String? _getBetKey() {
    if (widget.bettingPopupData == null) return null;
    final eventId = widget.bettingPopupData!.eventData.eventId;
    final selId = widget.bettingPopupData!.getSelectionId();
    if (selId == null) return null;
    return '${eventId}_$selId';
  }

  /// Update animation based on up/down range state
  /// Called only when state actually changes (not in build)
  void _updateAnimation(bool showUpRange, bool showDownRange, bool isLocked) {
    // Early exit if nothing changed
    if (showUpRange == _prevShowUpRange &&
        showDownRange == _prevShowDownRange &&
        isLocked == _prevIsLocked) {
      return;
    }

    // Update previous state
    _prevShowUpRange = showUpRange;
    _prevShowDownRange = showDownRange;
    _prevIsLocked = isLocked;

    // Stop animation when locked OR scrolling
    if (isLocked || ScrollAwareController.instance.isScrolling) {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
      return;
    }

    // Start or stop animation based on new state
    if (showUpRange || showDownRange) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  /// Kiểm tra odds có bị khóa không
  ///
  /// Kiểm tra theo thứ tự ưu tiên (theo hướng dẫn Odds Locking):
  /// 1. Event level: Event.status != ACTIVE → Lock toàn bộ event
  /// 2. Market level: Market.status != Active(0) → Lock toàn bộ market
  /// 3. Odds level: Odds.isSuspended == true → Lock riêng odds đó
  ///
  /// ⚠️ NOTE: Hiện tại chỉ check 2 level đầu vì:
  /// - LeagueOddsData (từ API) không có field isSuspended
  /// - WebSocket odds_up có isSuspended nhưng chưa được merge vào model
  /// - Khi Event/Market bị lock thì tất cả Odds bên trong cũng bị lock
  /// → Đủ cho business logic hiện tại
  bool _isOddsLocked(WidgetRef ref) {
    if (widget.bettingPopupData == null) return false;

    final eventData = widget.bettingPopupData!.eventData;
    final eventId = eventData.eventId;
    final marketId = widget.bettingPopupData!.marketData.marketId;

    // 1. CHECK EVENT LEVEL
    // Event bị suspended/hidden → Lock toàn bộ event
    // Via provider (realtime từ WebSocket event_up)
    final isEventSuspended = ref.watch(isEventSuspendedProvider(eventId));
    if (isEventSuspended) return true;

    // Via data model (từ API hoặc WebSocket)
    if (eventData.isSuspended) return true;

    // 2. CHECK MARKET LEVEL
    // Market bị suspended/hidden → Lock toàn bộ market
    // Via provider (realtime từ WebSocket market_up)
    final isMarketSuspended = ref.watch(
      isMarketSuspendedProvider((eventId, marketId)),
    );
    if (isMarketSuspended) return true;

    // 3. CHECK ODDS LEVEL (TODO - Not implemented yet)
    // Lý do chưa implement:
    // - LeagueOddsData không có field isSuspended
    // - Cần tạo OddsStatusProvider tương tự MarketStatusProvider
    // - Hoặc merge isSuspended từ WebSocket vào LeagueOddsData
    //
    // if (widget.bettingPopupData!.oddsData.isSuspended) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: FULL LIST behavior đã bị disable vì gây ra bug ẩn odds
    // Nguyên nhân: mỗi odds_up message chỉ chứa một số markets, không phải tất cả
    // Nếu cần implement lại, cần track valid selections theo marketId, không phải eventId

    // Check if odds is locked (Event or Market suspended)
    final isLocked = _isOddsLocked(ref);

    // Check if this bet is in slip (for toggle state)
    final betKey = _getBetKey();
    final isInSlip = betKey != null
        ? ref.watch(isBetInSlipProvider(betKey))
        : false;

    // Lấy direction từ provider nếu có selectionId
    final direction = widget.selectionId != null
        ? ref.watch(oddsDirectionProvider(widget.selectionId!))
        : OddsChangeDirection.none;

    // Lấy giá trị odds mới từ WebSocket (nếu có), fallback về value từ props
    final wsOddsValue = widget.selectionId != null
        ? ref.watch(oddsValueProvider(widget.selectionId!))
        : null;
    final displayValue = wsOddsValue ?? widget.value;

    // Xác định up/down dựa trên direction từ WebSocket hoặc fallback
    final showUpRange =
        direction == OddsChangeDirection.up ||
        (direction == OddsChangeDirection.none && widget.isUpRange);
    final showDownRange =
        direction == OddsChangeDirection.down ||
        (direction == OddsChangeDirection.none && widget.isDownRange);

    // Update animation state - uses early exit optimization
    // Only performs animation controller operations if state actually changed
    // (comparing booleans is O(1) and very fast)
    _updateAnimation(showUpRange, showDownRange, isLocked);

    // Determine background color
    // Priority: selected (yellow) > up/down range > default
    final bgColor = isInSlip
        ? BetCardMobile.selectedBgColor
        : showUpRange
        ? BetCardMobile.upRangeBgColor
        : showDownRange
        ? BetCardMobile.downRangeBgColor
        : BetCardMobile.defaultBgColor;

    // Text colors based on selected state
    final labelColor = isInSlip ? Colors.black : const Color(0xFFAAA49B);
    final valueColor = isInSlip ? Colors.white : AppColors.green200;

    return IgnorePointer(
      ignoring: isLocked,
      child: Opacity(
        opacity: isLocked ? BetCardMobile.lockedOpacity : 1.0,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isLocked
                ? null
                : (widget.onTap ?? () => _handleTap(context, isInSlip, betKey)),
            child: Stack(
              key: _cardKey,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  // Note: Don't use height: double.infinity - it causes layout errors
                  // when used inside unbounded constraints (e.g., Expanded in Row)
                  padding: widget.isVertical && widget.isDesktop == false
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
                      : const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: widget.isVertical && widget.isDesktop == false
                      ? _buildVerticalLayout(
                          labelColor,
                          valueColor,
                          displayValue,
                          isInSlip,
                        )
                      : _buildHorizontalLayout(
                          labelColor,
                          valueColor,
                          displayValue,
                          isInSlip,
                        ),
                ),
                // Lock icon when suspended
                if (isLocked)
                  Positioned.fill(
                    // top: 4,
                    // right: 4,
                    child: Container(
                      // height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColorStyles.backgroundTertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lock,
                        size: BetCardMobile.lockIconSize,
                        color: BetCardMobile.lockIconColor,
                      ),
                    ),
                  ),
                // Up range indicator with blinking animation
                if (showUpRange && !isInSlip && !isLocked)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) => Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                      child: ImageHelper.load(
                        path: AppIcons.upRangeBet,
                        width: 8,
                        height: 8,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                // Down range indicator with blinking animation
                if (showDownRange && !isInSlip && !isLocked)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) => Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                      child: ImageHelper.load(
                        path: AppIcons.downRangeBet,
                        width: 8,
                        height: 8,
                        fit: BoxFit.fill,
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

  /// Handle tap - toggle add/remove from bet slip
  Future<void> _handleTap(
    BuildContext context,
    bool isInSlip,
    String? betKey,
  ) async {
    if (widget.bettingPopupData != null) {
      debugPrint('[BetCardMobile] bettingPopupData available');
      debugPrint(
        '[BetCardMobile] offerId: ${widget.bettingPopupData!.getOfferId()}',
      );
      debugPrint(
        '[BetCardMobile] selectionId: ${widget.bettingPopupData!.getSelectionId()}',
      );

      if (!ref.watch(isAuthenticatedProvider)) {
        AppToast.showError(
          context,
          message: 'Vui lòng đăng nhập để thực hiện hành động này',
        );
        return;
      }

      if (isInSlip && betKey != null) {
        // Already in slip → remove it
        final index = ref.read(betIndexInSlipProvider(betKey));
        if (index >= 0) {
          ref.read(parlayStateProvider.notifier).removeSingleBetAt(index);
        }
      } else {
        // Not in slip → add it

        // Check if bet slip is empty BEFORE adding (for showing popup vs animation)
        // Read directly from parlayStateProvider to ensure latest state
        final parlayState = ref.read(parlayStateProvider);
        final singleBetsCount = parlayState.singleBets.length;
        final isBetSlipEmpty = singleBetsCount == 0;
        debugPrint(
          '[BetCardMobile] singleBets.length = $singleBetsCount, isBetSlipEmpty = $isBetSlipEmpty',
        );

        // Add bet to slip - now async with calculateBet validation
        final result = await ref
            .read(parlayStateProvider.notifier)
            .addSingleBetFromPopupData(widget.bettingPopupData!);

        // Check if add was successful
        if (!result.success) {
          // Show error toast
          if (context.mounted) {
            AppToast.showError(
              context,
              message: result.errorMessage ?? 'Không thể thêm cược',
            );
          }
          return;
        }

        // State 1: If bet slip was empty → show bet detail popup (NO animation)
        // State 2: If bet slip has items → flying animation (NO popup)
        if (isBetSlipEmpty) {
          debugPrint(
            '[BetCardMobile] Bet slip was empty - showing bet detail popup',
          );
          if (context.mounted) {
            BetDetailsBottomSheet.show(context, data: widget.bettingPopupData);
          }
        } else {
          debugPrint(
            '[BetCardMobile] Bet slip has items - showing flying animation',
          );
          if (context.mounted) {
            _triggerFlyingAnimation(context);
          }
        }
      }
    } else {
      // Fallback: show parlay screen if no betting data
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const FractionallySizedBox(
          heightFactor: 0.9,
          widthFactor: 1,
          child: ParlayMobileScreen(),
        ),
      );
    }
  }

  /// Trigger flying animation from card to bottom nav
  void _triggerFlyingAnimation(BuildContext context) {
    // Get card position and size
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Trigger flying animation
    FlyingBetController.instance.fly(
      context: context,
      sourcePosition: Offset(
        position.dx + size.width / 2,
        position.dy + size.height / 2,
      ),
      sourceSize: size,
      label: widget.label ?? '',
      value: widget.value ?? '',
    );
  }

  /// Format value để loại bỏ đuôi .00 (ví dụ: 100.00 → 100, 1.37 → 1.37)
  String _formatValue(String value) {
    if (value.endsWith('.00')) {
      return value.substring(0, value.length - 3);
    }
    return value;
  }

  /// Build vertical layout for sport view (label on top, value on bottom)
  Widget _buildVerticalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
    bool isInSlip,
  ) => SizedBox(
    height: double.infinity,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label on top
          if (widget.label != null && widget.label!.isNotEmpty)
            Text(
              widget.label!,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelXSmall(color: labelColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          // Value on bottom
          if (displayValue != null)
            Text(
              _formatValue(displayValue),
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall(color: valueColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    ),
  );

  /// Build horizontal layout for bet detail view (label left, value right)
  Widget _buildHorizontalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
    bool isInSlip,
  ) {
    return Container(
      height: widget.isSetHeightOdds ? double.infinity : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.label != null &&
                  widget.label!.isNotEmpty &&
                  displayValue != null)
                Flexible(
                  child: Text(
                    widget.label!,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.textStyle(
                      fontSize: widget.isDesktop ? 12 : 11.5,
                      fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w400,
                      color: labelColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox.shrink(),
              if (displayValue != null)
                widget.isSelected && !isInSlip
                    ? ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFF4FFC0), // from-[#f4ffc0]
                            Color(0xFFB9CF55), // to-[#b9cf55]
                          ],
                        ).createShader(bounds),
                        child: Text(
                          _formatValue(displayValue),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.displayStyle(
                            fontSize: widget.isDesktop ? 14 : 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _formatValue(displayValue),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.displayStyle(
                          fontSize: widget.isDesktop ? 14 : 13,
                          fontWeight: isInSlip
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: valueColor,
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}
