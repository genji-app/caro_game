import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_flash_manager.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';
import 'package:co_caro_flame/s88/shared/widgets/rive_vibrating/rive_vibrating.dart';
import 'package:co_caro_flame/s88/shared/widgets/snackbars/providers/bet_success_snackbar_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/features/betting/my_bet/my_bet_overlay/my_bet_overlay.dart';
import 'package:co_caro_flame/s88/features/betting/my_bet/my_bet_providers.dart';

/// BetCardMobile V2 using BettingPopupDataV2
///
/// PERFORMANCE OPTIMIZED:
/// - Replaced AnimationController.repeat() with TweenAnimationBuilder (one-shot)
/// - Uses OddsFlashManager for centralized flash state management
/// - Reduced rebuilds with targeted Consumers
class BetCardMobileV2 extends ConsumerStatefulWidget {
  final String? label;
  final String? value;
  final VoidCallback? onTap;
  final bool isSelected;

  /// SelectionId to track odds changes from WebSocket
  final String? selectionId;

  /// Fallback for isUpRange
  final bool isUpRange;

  /// Fallback for isDownRange
  final bool isDownRange;

  /// Betting popup data - V2 version
  final BettingPopupDataV2? bettingPopupData;

  /// Layout mode: true = vertical (sport view), false = horizontal (bet detail)
  final bool isVertical;

  final bool isDesktop;

  final bool isSetHeightOdds;

  const BetCardMobileV2({
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

  static const defaultBgColor = AppColorStyles.backgroundTertiary;
  static const selectedBgColor = AppColors.yellow600;
  static const upRangeBgColor = Color(0x33669F2A);
  static const downRangeBgColor = Color(0x33F04438);
  static const lockedOpacity = 1.0;
  static const lockIconSize = 20.0;
  static const lockIconColor = Colors.white54;

  @override
  ConsumerState<BetCardMobileV2> createState() => _BetCardMobileV2State();
}

class _BetCardMobileV2State extends ConsumerState<BetCardMobileV2> {
  final GlobalKey _cardKey = GlobalKey();

  // Track direction changes for animation key
  OddsChangeDirection _prevDirection = OddsChangeDirection.none;
  int _animationKey = 0;

  String? _getBetKey() {
    if (widget.bettingPopupData == null) return null;
    final eventId = widget.bettingPopupData!.eventData.eventId;
    final selId = widget.bettingPopupData!.getSelectionId();
    if (selId == null) return null;
    return '${eventId}_$selId';
  }

  /// Track direction changes and trigger OddsFlashManager
  void _syncFlashState(OddsChangeDirection direction) {
    if (widget.selectionId == null) return;

    if (direction != _prevDirection && direction != OddsChangeDirection.none) {
      // Direction changed - trigger flash animation
      OddsFlashManager.instance.triggerFlash(widget.selectionId!, direction);
      _animationKey++;
    }
    _prevDirection = direction;
  }

  @override
  Widget build(BuildContext context) {
    final betKey = _getBetKey();

    // Use Consumer for locked state (event/market suspended)
    return _buildLockedConsumer(
      betKey: betKey,
      builder: (context, isLocked) {
        return IgnorePointer(
          ignoring: isLocked,
          child: Opacity(
            opacity: isLocked ? BetCardMobileV2.lockedOpacity : 1.0,
            child: _buildCardContent(context, betKey, isLocked),
          ),
        );
      },
    );
  }

  /// Consumer for locked state - only rebuilds when event/market suspended changes
  Widget _buildLockedConsumer({
    required String? betKey,
    required Widget Function(BuildContext context, bool isLocked) builder,
  }) {
    if (widget.bettingPopupData == null) {
      return builder(context, false);
    }

    final eventData = widget.bettingPopupData!.eventData;
    final eventId = eventData.eventId;
    final marketId = widget.bettingPopupData!.marketData.marketId;

    // Check static suspended state first
    if (eventData.isSuspended) {
      return builder(context, true);
    }

    return Consumer(
      builder: (context, ref, child) {
        final isEventSuspended = ref.watch(isEventSuspendedProvider(eventId));
        if (isEventSuspended) return builder(context, true);

        final isMarketSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );
        return builder(context, isMarketSuspended);
      },
    );
  }

  /// Build card content with bet slip state consumer
  Widget _buildCardContent(
    BuildContext context,
    String? betKey,
    bool isLocked,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        // Watch bet slip state
        final isInSlip = betKey != null
            ? ref.watch(isBetInSlipProvider(betKey))
            : false;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isLocked
                ? null
                : (widget.onTap ?? () => _handleTap(context, isInSlip, betKey)),
            child: Stack(
              key: _cardKey,
              children: [
                // Main card with odds direction consumer
                _buildMainCard(ref, isInSlip, isLocked),
                // Lock icon when suspended
                if (isLocked) _buildLockOverlay(),
                // Rive animation consumer
                if (!isInSlip && !isLocked) _buildVibratingConsumer(),
                // Up/Down range indicators consumer
                if (!isInSlip && !isLocked) _buildRangeIndicatorsConsumer(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build main card with odds direction state
  Widget _buildMainCard(WidgetRef ref, bool isInSlip, bool isLocked) {
    // Watch odds direction and value
    final direction = widget.selectionId != null
        ? ref.watch(oddsDirectionProvider(widget.selectionId!))
        : OddsChangeDirection.none;

    final wsOddsValue = widget.selectionId != null
        ? ref.watch(oddsValueProvider(widget.selectionId!))
        : null;

    // Priority: WebSocket value > bettingPopupData value (by oddsStyle) > widget.value
    String? displayValue;
    if (wsOddsValue != null) {
      displayValue = wsOddsValue;
    } else if (widget.bettingPopupData != null) {
      // Get odds value from bettingPopupData according to current oddsStyle
      final oddsStyle = ref.watch(oddsStyleProvider);
      displayValue = _getOddsValueByStyle(widget.bettingPopupData!, oddsStyle);
    }
    displayValue ??= widget.value;

    final showUpRange =
        direction == OddsChangeDirection.up ||
        (direction == OddsChangeDirection.none && widget.isUpRange);
    final showDownRange =
        direction == OddsChangeDirection.down ||
        (direction == OddsChangeDirection.none && widget.isDownRange);

    // Sync flash state with OddsFlashManager
    _syncFlashState(direction);

    final bgColor = isInSlip
        ? BetCardMobileV2.selectedBgColor
        : showUpRange
        ? BetCardMobileV2.upRangeBgColor
        : showDownRange
        ? BetCardMobileV2.downRangeBgColor
        : BetCardMobileV2.defaultBgColor;

    final labelColor = isInSlip ? Colors.black : const Color(0xFFAAA49B);
    final valueColor = isInSlip ? Colors.white : AppColors.green200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: widget.isVertical && widget.isDesktop == false
          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
          : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: widget.isVertical && widget.isDesktop == false
          ? _buildVerticalLayout(labelColor, valueColor, displayValue, isInSlip)
          : _buildHorizontalLayout(
              labelColor,
              valueColor,
              displayValue,
              isInSlip,
            ),
    );
  }

  /// Lock overlay widget
  Widget _buildLockOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.lock,
          size: BetCardMobileV2.lockIconSize,
          color: BetCardMobileV2.lockIconColor,
        ),
      ),
    );
  }

  /// Consumer for vibrating state - only rebuilds when vibrating changes
  Widget _buildVibratingConsumer() {
    if (widget.selectionId == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        final isVibrating = ref.watch(isVibratingProvider(widget.selectionId!));
        return PositionedRiveVibratingOverlay(isVisible: isVibrating);
      },
    );
  }

  /// Consumer for range indicators - uses TweenAnimationBuilder instead of AnimationController
  Widget _buildRangeIndicatorsConsumer() {
    return Consumer(
      builder: (context, ref, _) {
        final direction = widget.selectionId != null
            ? ref.watch(oddsDirectionProvider(widget.selectionId!))
            : OddsChangeDirection.none;

        final showUpRange =
            direction == OddsChangeDirection.up ||
            (direction == OddsChangeDirection.none && widget.isUpRange);
        final showDownRange =
            direction == OddsChangeDirection.down ||
            (direction == OddsChangeDirection.none && widget.isDownRange);

        if (!showUpRange && !showDownRange) {
          return const SizedBox.shrink();
        }

        // Use TweenAnimationBuilder for one-shot fade-in animation
        // Key changes when _animationKey changes, triggering new animation
        return TweenAnimationBuilder<double>(
          key: ValueKey('flash_$_animationKey'),
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.3, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, opacity, _) {
            return Stack(
              children: [
                if (showUpRange)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Opacity(
                      opacity: opacity,
                      child: ImageHelper.load(
                        path: AppIcons.upRangeBet,
                        width: 8,
                        height: 8,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                if (showDownRange)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Opacity(
                      opacity: opacity,
                      child: ImageHelper.load(
                        path: AppIcons.downRangeBet,
                        width: 8,
                        height: 8,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Handle tap - toggle add/remove from bet slip (V2 version)
  Future<void> _handleTap(
    BuildContext context,
    bool isInSlip,
    String? betKey,
  ) async {
    if (widget.bettingPopupData != null) {
      if (!ref.watch(isAuthenticatedProvider)) {
        AppToast.showError(
          context,
          message: 'Vui lòng đăng nhập để thực hiện hành động này',
        );
        return;
      }

      // Check if this is a vibrating odds
      final isVibrating = widget.selectionId != null
          ? ref.read(isVibratingProvider(widget.selectionId!))
          : false;

      // Vibrating odds: always show popup directly, no bet slip logic
      if (isVibrating) {
        if (context.mounted) {
          BetDetailsBottomSheetV2.show(
            context,
            data: widget.bettingPopupData,
            isVibrating: true,
          );
        }
        return;
      }

      // Normal odds: add/remove from bet slip
      if (isInSlip && betKey != null) {
        // Already in slip → remove it
        final index = ref.read(betIndexInSlipProvider(betKey));
        if (index >= 0) {
          ref.read(parlayStateProvider.notifier).removeSingleBetAt(index);
        }
      } else {
        // Not in slip → add it
        final result = await ref
            .read(parlayStateProvider.notifier)
            .addSingleBetFromPopupDataV2(widget.bettingPopupData!);

        // Check if add was successful
        if (!result.success) {
          if (context.mounted) {
            AppToast.showError(
              context,
              message: result.errorMessage ?? 'Không thể thêm cược',
            );
          }
          return;
        }

        if (context.mounted) {
          // Flying animation
          _triggerFlyingAnimation(context);

          // Open bet overlay (if not already open)
          final isOverlayVisible = ref.read(myBetOverlayVisibleProvider);
          if (!isOverlayVisible) {
            ref.read(myBetOverlayVisibleProvider.notifier).open();
          }

          // Show success snackbar
          final updatedParlayState = ref.read(parlayStateProvider);
          if (updatedParlayState.singleBets.isNotEmpty) {
            final addedBet = updatedParlayState.singleBets.last;
            ref.read(betSuccessSnackBarProvider.notifier).show(addedBet);
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

  String _formatValue(String value) {
    if (value.endsWith('.00')) {
      return value.substring(0, value.length - 3);
    }
    return value;
  }

  /// Get odds value from bettingPopupData according to OddsStyle
  String? _getOddsValueByStyle(BettingPopupDataV2 data, OddsStyle style) {
    // Convert OddsStyle to OddsFormatV2
    final format = switch (style) {
      OddsStyle.malay => OddsFormatV2.malay,
      OddsStyle.indo => OddsFormatV2.indo,
      OddsStyle.decimal => OddsFormatV2.decimal,
      OddsStyle.hongKong => OddsFormatV2.hk,
    };

    // Get odds value based on oddsType
    final oddsData = data.oddsData;
    double value;
    switch (data.oddsType) {
      case OddsType.home:
        value = oddsData.getHomeOdds(format);
      case OddsType.away:
        value = oddsData.getAwayOdds(format);
      case OddsType.draw:
        value = oddsData.getDrawOdds(format) ?? 0.0;
      default:
        value = 0.0;
    }

    if (value == 0) return null;
    return value.toStringAsFixed(2);
  }

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

  Widget _buildHorizontalLayout(
    Color labelColor,
    Color valueColor,
    String? displayValue,
    bool isInSlip,
  ) {
    return Container(
      height: widget.isSetHeightOdds ? double.infinity : null,
      alignment: Alignment.center,
      child: Row(
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
                      colors: [Color(0xFFF4FFC0), Color(0xFFB9CF55)],
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
                      fontWeight: isInSlip ? FontWeight.w600 : FontWeight.w500,
                      color: valueColor,
                    ),
                  ),
        ],
      ),
    );
  }
}
