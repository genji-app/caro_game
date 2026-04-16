import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// BetCard tối ưu cho performance
/// - Sử dụng StatelessWidget + Consumer để isolate rebuilds
/// - Chỉ rebuild phần cần thiết khi provider thay đổi
/// - Trên mobile: Không có hover state
/// - Trên desktop: Hover wrapper với parlay logic
///
/// Parlay Logic (Desktop):
/// - Nếu bet slip empty → show betting detail popup
/// - Nếu bet slip có items → add to slip + flying animation to header badge
class BetCard extends StatelessWidget {
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

  const BetCard({
    super.key,
    this.label,
    this.value,
    this.onTap,
    this.isSelected = false,
    this.selectionId,
    this.isUpRange = false,
    this.isDownRange = false,
    this.bettingPopupData,
  });

  // Static constants để tránh tạo object mới
  static const _defaultBgColor = Color(0x66000000);
  static const _selectedBgColor = AppColors.yellow600;
  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);
  static const _hoverBgColor = Color.fromRGBO(54, 48, 38, 1);
  static const _labelColor = Color(0xFF9C9B95);
  static const _selectedLabelColor = Colors.black;
  static const _valueColor = Color(0xFFFDE272);
  static const _selectedValueColor = Colors.white;
  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 11.5);
  static const _borderRadius = BorderRadius.all(Radius.circular(8));

  // Locked state constants
  static const _lockedOpacity = 0.5;
  static const _lockIconSize = 12.0;
  static const _lockIconColor = Colors.white54;

  /// Get bet key for provider lookup (eventId_selectionId)
  String? _getBetKey() {
    if (bettingPopupData == null) return null;
    final eventId = bettingPopupData!.eventData.eventId;
    final selId = bettingPopupData!.getSelectionId();
    if (selId == null) return null;
    return '${eventId}_$selId';
  }

  @override
  Widget build(BuildContext context) {
    // Consumer isolates all provider watches - parent won't rebuild
    return Consumer(
      builder: (context, ref, _) {
        // Get all reactive data inside Consumer
        final betCardData = _getBetCardData(ref);

        // Trên mobile, không cần hover state -> dùng widget đơn giản hơn
        if (PlatformUtils.isMobile) {
          return _buildCard(_defaultBgColor, context, ref, betCardData);
        }

        // Trên desktop, dùng hover wrapper với parlay logic
        return _HoverableCard(
          defaultColor: betCardData.isInSlip
              ? _selectedBgColor
              : betCardData.showUpRange
              ? _upRangeBgColor
              : betCardData.showDownRange
              ? _downRangeBgColor
              : _defaultBgColor,
          hoverColor: betCardData.isInSlip ? _selectedBgColor : _hoverBgColor,
          isUpRange: betCardData.showUpRange && !betCardData.isInSlip,
          isDownRange: betCardData.showDownRange && !betCardData.isInSlip,
          isInSlip: betCardData.isInSlip,
          isLocked: betCardData.isLocked,
          label: label ?? '',
          value: betCardData.effectiveValue ?? '',
          bettingPopupData: bettingPopupData,
          onTapWithAnimation: (triggerAnimation) {
            if (betCardData.isLocked) return;
            if (onTap != null) {
              onTap!();
            } else {
              _handleTapWithAnimation(
                context,
                ref,
                betCardData.isInSlip,
                betCardData.betKey,
                triggerAnimation,
              );
            }
          },
          child: _buildCardContent(
            context,
            betCardData.effectiveValue,
            betCardData.isInSlip,
          ),
        );
      },
    );
  }

  /// Get all reactive data for this card
  _BetCardData _getBetCardData(WidgetRef ref) {
    final betKey = _getBetKey();

    // Check locked status
    final isLocked = _isOddsLocked(ref);

    // Get direction from provider if selectionId exists
    final direction = selectionId != null
        ? ref.watch(oddsDirectionProvider(selectionId!))
        : OddsChangeDirection.none;

    // Get live odds value from WebSocket (if available)
    final liveValue = selectionId != null
        ? ref.watch(oddsValueProvider(selectionId!))
        : null;

    // Use live value from WebSocket or fallback to API value
    final effectiveValue = liveValue ?? value;

    // Determine up/down based on WebSocket direction or fallback
    final showUpRange =
        direction == OddsChangeDirection.up ||
        (direction == OddsChangeDirection.none && isUpRange);
    final showDownRange =
        direction == OddsChangeDirection.down ||
        (direction == OddsChangeDirection.none && isDownRange);

    // Check if this bet is in slip (for toggle state)
    final isInSlip = betKey != null
        ? ref.watch(isBetInSlipProvider(betKey))
        : false;

    return _BetCardData(
      betKey: betKey,
      isLocked: isLocked,
      effectiveValue: effectiveValue,
      showUpRange: showUpRange,
      showDownRange: showDownRange,
      isInSlip: isInSlip,
    );
  }

  /// Kiểm tra odds có bị khóa không
  ///
  /// Kiểm tra theo thứ tự ưu tiên (theo hướng dẫn Odds Locking):
  /// 1. Event level: Event.status != ACTIVE → Lock toàn bộ event
  /// 2. Market level: Market.status != Active(0) → Lock toàn bộ market
  /// 3. Odds level: Odds.isSuspended == true → Lock riêng odds đó (TODO)
  bool _isOddsLocked(WidgetRef ref) {
    if (bettingPopupData == null) return false;

    final eventData = bettingPopupData!.eventData;
    final eventId = eventData.eventId;
    final marketId = bettingPopupData!.marketData.marketId;

    // 1. CHECK EVENT LEVEL
    final isEventSuspended = ref.watch(isEventSuspendedProvider(eventId));
    if (isEventSuspended) return true;
    if (eventData.isSuspended) return true;

    // 2. CHECK MARKET LEVEL
    final isMarketSuspended = ref.watch(
      isMarketSuspendedProvider((eventId, marketId)),
    );
    if (isMarketSuspended) return true;

    // 3. ODDS LEVEL (TODO - Not implemented)
    // LeagueOddsData không có field isSuspended

    return false;
  }

  /// Handle tap - toggle add/remove from bet slip with animation
  Future<void> _handleTapWithAnimation(
    BuildContext context,
    WidgetRef ref,
    bool isInSlip,
    String? betKey,
    void Function() triggerAnimation,
  ) async {
    if (bettingPopupData != null) {
      if (isInSlip && betKey != null) {
        // Already in slip → remove it
        debugPrint('[BetCard] Removing bet from slip');
        final index = ref.read(betIndexInSlipProvider(betKey));
        if (index >= 0) {
          ref.read(parlayStateProvider.notifier).removeSingleBetAt(index);
        }
      } else {
        // Not in slip → add it
        debugPrint('[BetCard] Adding bet to slip');

        // Check if bet slip is empty BEFORE adding (for showing popup vs animation)
        final singleBets = ref.read(singleBetsProvider);
        final isBetSlipEmpty = singleBets.isEmpty;

        // Add bet to slip - now async with calculateBet validation
        final result = await ref
            .read(parlayStateProvider.notifier)
            .addSingleBetFromPopupData(bettingPopupData!);

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
          debugPrint('[BetCard] Bet slip was empty - showing bet detail popup');
          if (context.mounted) {
            BetDetailsBottomSheet.show(context, data: bettingPopupData);
          }
        } else {
          // Bet slip had items → trigger flying animation
          debugPrint('[BetCard] Bet slip has items - showing flying animation');
          triggerAnimation();
        }
      }
    } else {
      // Fallback: show popup if no betting data
      BetDetailsBottomSheet.show(context, data: bettingPopupData);
    }
  }

  Widget _buildCard(
    Color bgColor,
    BuildContext context,
    WidgetRef ref,
    _BetCardData data,
  ) {
    final effectiveBgColor = data.isInSlip
        ? _selectedBgColor
        : data.showUpRange
        ? _upRangeBgColor
        : data.showDownRange
        ? _downRangeBgColor
        : bgColor;

    return IgnorePointer(
      ignoring: data.isLocked,
      child: Opacity(
        opacity: data.isLocked ? _lockedOpacity : 1.0,
        child: GestureDetector(
          onTap: data.isLocked
              ? null
              : (onTap ??
                    () => BetDetailsBottomSheet.show(
                      context,
                      data: bettingPopupData,
                    )),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: _padding,
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: _borderRadius,
                ),
                child: _buildCardContent(
                  context,
                  data.effectiveValue,
                  data.isInSlip,
                ),
              ),
              // Lock icon when suspended
              if (data.isLocked)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.lock,
                    size: _lockIconSize,
                    color: _lockIconColor,
                  ),
                ),
              if (data.showUpRange && !data.isInSlip && !data.isLocked)
                Positioned(
                  top: 4,
                  right: 4,
                  child: ImageHelper.load(
                    path: AppIcons.upRangeBet,
                    width: 8,
                    height: 8,
                    fit: BoxFit.fill,
                  ),
                ),
              if (data.showDownRange && !data.isInSlip && !data.isLocked)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: ImageHelper.load(
                    path: AppIcons.downRangeBet,
                    width: 8,
                    height: 8,
                    fit: BoxFit.fill,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    String? displayValue,
    bool isInSlip,
  ) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (label != null)
        Expanded(
          child: Text(
            label!,
            style: AppTextStyles.displayStyle(
              fontSize: 11,
              fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w500,
              color: isInSlip ? _selectedLabelColor : _labelColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      else
        const SizedBox.shrink(),
      if (displayValue != null)
        Text(
          displayValue,
          style: AppTextStyles.displayStyle(
            fontSize: 13,
            fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w500,
            color: isInSlip ? _selectedValueColor : _valueColor,
          ),
          textAlign: TextAlign.right,
        ),
    ],
  );
}

/// Data class chứa tất cả reactive data cho BetCard
class _BetCardData {
  final String? betKey;
  final bool isLocked;
  final String? effectiveValue;
  final bool showUpRange;
  final bool showDownRange;
  final bool isInSlip;

  const _BetCardData({
    required this.betKey,
    required this.isLocked,
    required this.effectiveValue,
    required this.showUpRange,
    required this.showDownRange,
    required this.isInSlip,
  });
}

/// Widget wrapper cho hover effect và flying animation - chỉ dùng trên desktop
class _HoverableCard extends StatefulWidget {
  final Color defaultColor;
  final Color hoverColor;
  final Widget child;
  final bool isUpRange;
  final bool isDownRange;
  final bool isInSlip;
  final bool isLocked;
  final String label;
  final String value;
  final BettingPopupData? bettingPopupData;

  /// Callback when tap occurs, receives a function to trigger flying animation
  final void Function(void Function() triggerAnimation) onTapWithAnimation;

  const _HoverableCard({
    required this.defaultColor,
    required this.hoverColor,
    required this.onTapWithAnimation,
    required this.label,
    required this.value,
    required this.child,
    this.isUpRange = false,
    this.isDownRange = false,
    this.isInSlip = false,
    this.isLocked = false,
    this.bettingPopupData,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;
  final GlobalKey _cardKey = GlobalKey();

  static const _padding = EdgeInsets.symmetric(horizontal: 8, vertical: 11.5);
  static const _borderRadius = BorderRadius.all(Radius.circular(8));

  /// Trigger flying animation from card to desktop header badge
  void _triggerFlyingAnimation() {
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    FlyingBetController.instance.fly(
      context: context,
      sourcePosition: Offset(
        position.dx + size.width / 2,
        position.dy + size.height / 2,
      ),
      sourceSize: size,
      label: widget.label,
      value: widget.value,
    );
  }

  void _handleTap() {
    // Pass animation trigger function to parent for decision making
    widget.onTapWithAnimation(_triggerFlyingAnimation);
  }

  // Locked state constants
  static const _lockedOpacity = 0.5;
  static const _lockIconSize = 12.0;
  static const _lockIconColor = Colors.white54;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: widget.isLocked,
    child: Opacity(
      opacity: widget.isLocked ? _lockedOpacity : 1.0,
      child: MouseRegion(
        onEnter: widget.isLocked
            ? null
            : (_) => setState(() => _isHovered = true),
        onExit: widget.isLocked
            ? null
            : (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.isLocked ? null : _handleTap,
          child: Stack(
            key: _cardKey,
            children: [
              Container(
                padding: _padding,
                decoration: BoxDecoration(
                  color: _isHovered && !widget.isLocked
                      ? widget.hoverColor
                      : widget.defaultColor,
                  borderRadius: _borderRadius,
                ),
                child: widget.child,
              ),
              // Lock icon when suspended
              if (widget.isLocked)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.lock,
                    size: _lockIconSize,
                    color: _lockIconColor,
                  ),
                ),
              if (widget.isUpRange && !widget.isLocked)
                Positioned(
                  top: 4,
                  right: 4,
                  child: ImageHelper.load(
                    path: AppIcons.upRangeBet,
                    width: 8,
                    height: 8,
                    fit: BoxFit.fill,
                  ),
                ),
              if (widget.isDownRange && !widget.isLocked)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: ImageHelper.load(
                    path: AppIcons.downRangeBet,
                    width: 8,
                    height: 8,
                    fit: BoxFit.fill,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
