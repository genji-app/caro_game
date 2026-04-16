import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Bet card for displaying odds with direction animation
///
/// Performance optimizations:
/// - Uses Consumer widgets for scoped rebuilds
/// - Uses ref.select for fine-grained subscriptions
/// - Animation controller managed separately from provider state
class BetCardSport extends StatefulWidget {
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

  const BetCardSport({
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
  });

  @override
  State<BetCardSport> createState() => _BetCardSportState();
}

class _BetCardSportState extends State<BetCardSport>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final Animation<double> _opacityAnimation;

  final GlobalKey _cardKey = GlobalKey();

  // Cached values to avoid recalculation
  String? _cachedBetKey;
  int? _eventId;
  int? _marketId;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _updateCachedValues();
  }

  @override
  void didUpdateWidget(BetCardSport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bettingPopupData != widget.bettingPopupData) {
      _updateCachedValues();
    }
  }

  void _updateCachedValues() {
    if (widget.bettingPopupData != null) {
      _eventId = widget.bettingPopupData!.eventData.eventId;
      _marketId = widget.bettingPopupData!.marketData.marketId;
      final selId = widget.bettingPopupData!.getSelectionId();
      _cachedBetKey = selId != null ? '${_eventId}_$selId' : null;
    } else {
      _eventId = null;
      _marketId = null;
      _cachedBetKey = null;
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  /// Format value để loại bỏ đuôi .00
  String _formatValue(String value) {
    if (value.endsWith('.00')) {
      return value.substring(0, value.length - 3);
    }
    return value;
  }

  /// Control blink animation based on state
  void _updateBlinkAnimation(
    bool isLocked,
    bool showUpRange,
    bool showDownRange,
  ) {
    if (isLocked) {
      if (_blinkController.isAnimating) {
        _blinkController.stop();
        _blinkController.reset();
      }
    } else if (showUpRange || showDownRange) {
      if (!_blinkController.isAnimating) {
        _blinkController.repeat(reverse: true);
      }
    } else {
      if (_blinkController.isAnimating) {
        _blinkController.stop();
        _blinkController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for scoped rebuilds - only rebuilds when these specific values change
    return Consumer(
      builder: (context, ref, _) {
        // Check locked state with select for fine-grained subscription
        final isLocked = _checkIsLocked(ref);

        return _LockedStateWrapper(
          isLocked: isLocked,
          child: Consumer(
            builder: (context, ref, _) {
              // Watch only the specific values we need
              final isInSlip = _cachedBetKey != null
                  ? ref.watch(isBetInSlipProvider(_cachedBetKey!))
                  : false;

              return _BetCardContent(
                cardKey: _cardKey,
                widget: widget,
                isLocked: isLocked,
                isInSlip: isInSlip,
                betKey: _cachedBetKey,
                opacityAnimation: _opacityAnimation,
                onUpdateBlinkAnimation: _updateBlinkAnimation,
                onTap: () => _handleTap(context, ref, isInSlip, _cachedBetKey),
                formatValue: _formatValue,
                isDesktop: widget.isDesktop,
                isVertical: widget.isVertical,
              );
            },
          ),
        );
      },
    );
  }

  /// Check if odds is locked using select for minimal rebuilds
  bool _checkIsLocked(WidgetRef ref) {
    if (widget.bettingPopupData == null) return false;

    final eventData = widget.bettingPopupData!.eventData;

    // Check static isSuspended first (no provider needed)
    if (eventData.isSuspended) return true;

    // Use select to only rebuild when the boolean value changes
    if (_eventId != null) {
      final isEventSuspended = ref.watch(isEventSuspendedProvider(_eventId!));
      if (isEventSuspended) return true;
    }

    if (_eventId != null && _marketId != null) {
      final isMarketSuspended = ref.watch(
        isMarketSuspendedProvider((_eventId!, _marketId!)),
      );
      if (isMarketSuspended) return true;
    }

    return false;
  }

  /// Handle tap - toggle add/remove from bet slip
  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    bool isInSlip,
    String? betKey,
  ) async {
    if (widget.bettingPopupData != null) {
      if (!ref.read(isAuthenticatedProvider)) {
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
        final parlayState = ref.read(parlayStateProvider);
        final isBetSlipEmpty = parlayState.singleBets.isEmpty;

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

        if (isBetSlipEmpty) {
          if (context.mounted) {
            BetDetailsBottomSheet.show(context, data: widget.bettingPopupData);
          }
        } else {
          if (context.mounted) {
            _triggerFlyingAnimation(context);
          }
        }
      }
    } else {
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

  void _triggerFlyingAnimation(BuildContext context) {
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
      label: widget.label ?? '',
      value: widget.value ?? '',
    );
  }
}

/// Wrapper widget that handles locked state opacity and pointer events
class _LockedStateWrapper extends StatelessWidget {
  final bool isLocked;
  final Widget child;

  const _LockedStateWrapper({required this.isLocked, required this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLocked,
      child: Opacity(opacity: isLocked ? 0.5 : 1.0, child: child),
    );
  }
}

/// Main content widget that uses Consumer for odds direction updates
class _BetCardContent extends StatelessWidget {
  final GlobalKey cardKey;
  final BetCardSport widget;
  final bool isLocked;
  final bool isInSlip;
  final String? betKey;
  final Animation<double> opacityAnimation;
  final void Function(bool, bool, bool) onUpdateBlinkAnimation;
  final VoidCallback onTap;
  final String Function(String) formatValue;
  final bool isDesktop;
  final bool isVertical;

  const _BetCardContent({
    required this.cardKey,
    required this.widget,
    required this.isLocked,
    required this.isInSlip,
    required this.betKey,
    required this.opacityAnimation,
    required this.onUpdateBlinkAnimation,
    required this.onTap,
    required this.formatValue,
    required this.isDesktop,
    required this.isVertical,
  });

  static const _defaultBgColor = AppColorStyles.backgroundTertiary;
  static const _selectedBgColor = AppColors.yellow600;
  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);
  static const _lockIconSize = 10.0;
  static const _lockIconColor = Colors.white54;

  @override
  Widget build(BuildContext context) {
    // Use Consumer for odds direction - only this part rebuilds when odds change
    return Consumer(
      builder: (context, ref, _) {
        // Get direction from provider if selectionId exists
        final direction = widget.selectionId != null
            ? ref.watch(oddsDirectionProvider(widget.selectionId!))
            : OddsChangeDirection.none;

        // Get WebSocket odds value
        final wsOddsValue = widget.selectionId != null
            ? ref.watch(oddsValueProvider(widget.selectionId!))
            : null;
        final displayValue = wsOddsValue ?? widget.value;

        // Determine up/down based on direction
        final showUpRange =
            direction == OddsChangeDirection.up ||
            (direction == OddsChangeDirection.none && widget.isUpRange);
        final showDownRange =
            direction == OddsChangeDirection.down ||
            (direction == OddsChangeDirection.none && widget.isDownRange);

        // Update blink animation (called during build, but only affects animation controller)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onUpdateBlinkAnimation(isLocked, showUpRange, showDownRange);
        });

        // Determine background color
        final bgColor = isInSlip
            ? _selectedBgColor
            : showUpRange
            ? _upRangeBgColor
            : showDownRange
            ? _downRangeBgColor
            : _defaultBgColor;

        // Text colors
        final labelColor = isInSlip ? Colors.black : const Color(0xFFAAA49B);
        final valueColor = isInSlip ? Colors.white : AppColors.green200;

        return GestureDetector(
          onTap: isLocked ? null : onTap,
          child: Stack(
            key: cardKey,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: isVertical
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                    : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isVertical && !isDesktop
                    ? _buildVerticalLayout(labelColor, valueColor, displayValue)
                    : _buildHorizontalLayout(
                        labelColor,
                        valueColor,
                        displayValue,
                      ),
              ),

              // Lock icon when suspended
              if (isLocked)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.lock,
                    size: _lockIconSize,
                    color: _lockIconColor,
                  ),
                ),

              // Up range indicator
              if (showUpRange && !isInSlip && !isLocked)
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedBuilder(
                    animation: opacityAnimation,
                    builder: (_, child) =>
                        Opacity(opacity: opacityAnimation.value, child: child),
                    child: ImageHelper.load(
                      path: AppIcons.upRangeBet,
                      width: 8,
                      height: 8,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

              // Down range indicator
              if (showDownRange && !isInSlip && !isLocked)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: AnimatedBuilder(
                    animation: opacityAnimation,
                    builder: (_, child) =>
                        Opacity(opacity: opacityAnimation.value, child: child),
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
        );
      },
    );
  }

  Widget _buildVerticalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty)
          Text(
            widget.label!,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelXSmall(color: labelColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (displayValue != null)
          Text(
            formatValue(displayValue),
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall(color: valueColor),
          ),
      ],
    );
  }

  Widget _buildHorizontalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
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
                    fontSize: isDesktop ? 12 : 11.5,
                    fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w400,
                    color: labelColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Spacer(),
            if (displayValue != null)
              widget.isSelected && !isInSlip
                  ? ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFF4FFC0), Color(0xFFB9CF55)],
                      ).createShader(bounds),
                      child: Text(
                        formatValue(displayValue),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.displayStyle(
                          fontSize: isDesktop ? 14 : 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      formatValue(displayValue),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.displayStyle(
                        fontSize: isDesktop ? 14 : 13,
                        fontWeight: isInSlip
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: valueColor,
                      ),
                    ),
          ],
        ),
      ],
    );
  }
}
