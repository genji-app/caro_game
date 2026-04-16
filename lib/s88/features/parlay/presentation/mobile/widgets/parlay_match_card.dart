import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_explanation_button.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:co_caro_flame/s88/shared/widgets/status_information/status_information.dart';
import 'package:co_caro_flame/s88/shared/widgets/texts/texts.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/widgets/bet_amount_section.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_provider.dart'
    hide OddsChangeDirection;
import 'package:co_caro_flame/s88/core/services/providers/event_live_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/event_status.dart';

/// Widget hiển thị danh sách các vé cược đơn
class ParlayMatchCard extends ConsumerWidget {
  const ParlayMatchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleBets = ref.watch(singleBetsProvider);

    if (singleBets.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      children: [
        for (int i = singleBets.length - 1; i >= 0; i--) ...[
          _SingleBetCard(index: i, singleBet: singleBets[i]),
          if (i > 0) const Gap(12),
        ],
      ],
    );
  }
}

/// Card cho từng vé cược đơn
class _SingleBetCard extends ConsumerStatefulWidget {
  final int index;
  final SingleBetData singleBet;

  const _SingleBetCard({required this.index, required this.singleBet});

  @override
  ConsumerState<_SingleBetCard> createState() => _SingleBetCardState();
}

class _SingleBetCardState extends ConsumerState<_SingleBetCard> {
  late final TextEditingController _controller;
  final _formatter = NumberFormat('#,###');
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    final initialStake = widget.singleBet.stake;
    _controller = TextEditingController(
      text: initialStake > 0 ? _formatter.format(initialStake) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SingleBetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.singleBet.stake != widget.singleBet.stake) {
      _updateControllerText(widget.singleBet.stake);
    }
  }

  void _updateControllerText(int stake) {
    if (_isInternalUpdate) return;

    final formatted = stake > 0 ? _formatter.format(stake) : '';
    if (_controller.text != formatted) {
      _isInternalUpdate = true;
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _isInternalUpdate = false;
    }
  }

  void _onStakeChanged(String value) {
    if (_isInternalUpdate) return;

    final numeric = value.replaceAll(RegExp(r'[^0-9]'), '');
    int parsed = int.tryParse(numeric) ?? 0;

    // Get max stake for this bet (already in VND)
    final maxStakeActual = widget.singleBet.maxStakeActual;

    // Cap the value if it exceeds max stake allowed
    if (parsed > maxStakeActual && maxStakeActual > 0) {
      parsed = maxStakeActual;
      // Update the text field with the capped value
      _updateControllerText(parsed);
    }

    ref
        .read(parlayStateProvider.notifier)
        .setSingleBetStakeAt(widget.index, parsed);
  }

  @override
  Widget build(BuildContext context) {
    final singleBet = widget.singleBet;

    // 🔧 PERFORMANCE FIX: Sử dụng derived providers thay vì watch toàn bộ parlayStateProvider
    // Chỉ rebuild khi isInParlay hoặc isParlayButtonDisabled thay đổi
    final isInParlay = ref.watch(
      isSelectionInComboProvider(singleBet.selectionId),
    );
    final isParlayButtonDisabled = ref.watch(
      hasOtherSelectionInComboProvider((
        singleBet.eventData.eventId,
        singleBet.selectionId,
      )),
    );

    // Check if bet is disabled (error 607 - odds not found)
    final isBetDisabled = singleBet.isDisabled;

    // Check if event is hidden (Hidden/AutoHidden) from WebSocket - means event ended or no longer available
    // 🔧 PERFORMANCE FIX: Sử dụng select để chỉ rebuild khi status thay đổi, không phải toàn bộ eventLiveData
    final isEventHidden = ref.watch(
      eventLiveDataProvider(
        singleBet.eventData.eventId,
      ).select((data) => EventStatusX.fromString(data?.status).isHidden),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColorStyles.backgroundTertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: _TicketHeader(
                singleBet: singleBet,
                isDisabled: isBetDisabled || isEventHidden,
                onRemove: () => ref
                    .read(parlayStateProvider.notifier)
                    .removeSingleBetAt(widget.index),
                onMatchTitleTap: (isBetDisabled || isEventHidden)
                    ? null
                    : () => _navigateToBetDetail(context),
              ),
            ),
            _SelectionStakeCard(
              singleBet: singleBet,
              isCalculating: singleBet.isCalculating,
              isDisabled: isBetDisabled,
              formatter: _formatter,
              controller: _controller,
              onChanged: _onStakeChanged,
            ),
            // Hide parlay button if bet is disabled or event is hidden
            if (!isBetDisabled && !isEventHidden)
              // Check only marketData.isParlay to match bet_details_content.dart logic
              if (!singleBet.marketData.isParlay)
                const _ParlayNotSupportedNotification()
              else
                _ParlayButton(
                  singleBet: singleBet,
                  isInParlay: isInParlay,
                  isDisabled: isParlayButtonDisabled,
                  onTap: () => _handleParlayToggle(singleBet, isInParlay),
                ),
          ],
        ),
      ),
    );
  }

  void _handleParlayToggle(SingleBetData singleBet, bool isInParlay) async {
    if (isInParlay) {
      // Remove this selection from combo by selectionId
      ref
          .read(parlayStateProvider.notifier)
          .removeFromComboBySelectionId(singleBet.selectionId);
    } else {
      // Check if another selection from same event is already in combo
      final state = ref.read(parlayStateProvider);
      if (state.hasOtherSelectionInCombo(
        singleBet.eventData.eventId,
        singleBet.selectionId,
      )) {
        AppToast.showError(
          context,
          message: 'Đã có kèo khác từ trận này trong cược xiên',
        );
        return;
      }

      // Check if market supports parlay (only check marketData.isParlay to match bet_details_content.dart)
      if (!singleBet.marketData.isParlay) {
        AppToast.showError(context, message: 'Kèo này không hỗ trợ cược xiên');
        return;
      }

      // Add to combo parlay
      final success = await ref
          .read(parlayStateProvider.notifier)
          .addToComboParlay(widget.index);

      if (success && mounted) {
        AppToast.showSuccess(context, message: 'Đã thêm vào cược xiên');
      }
    }
  }

  void _navigateToBetDetail(BuildContext context) {
    final singleBet = widget.singleBet;

    // Set selected event and league for bet detail screen
    ref.read(selectedEventProvider.notifier).state = singleBet.eventData;
    ref.read(selectedLeagueProvider.notifier).state = singleBet.leagueData;

    // Close the bottom sheet
    Navigator.of(context).pop();

    // Navigate to bet detail screen
    ref.read(mainContentProvider.notifier).goToBetDetail();
  }
}

class _TicketHeader extends StatelessWidget {
  final SingleBetData singleBet;
  final bool isDisabled;
  final VoidCallback onRemove;
  final VoidCallback? onMatchTitleTap;

  const _TicketHeader({
    required this.singleBet,
    required this.onRemove,
    this.isDisabled = false,
    this.onMatchTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    // Disabled state uses quaternary color
    final textColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;

    if (singleBet.isLive) {
      final matchTitle =
          '${singleBet.homeName} ${singleBet.eventData.homeScore} - ${singleBet.eventData.awayScore} ${singleBet.awayName}';

      return Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: ImageHelper.getSVG(
              path: SportType.fromId(singleBet.sportId)?.iconPath ?? '',
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const Gap(6),
          isDisabled ? const _DisabledLiveDot() : const _LiveDot(),
          const Gap(6),
          Expanded(
            child: GestureDetector(
              onTap: onMatchTitleTap,
              child: Text(
                matchTitle,
                maxLines: 1,
                style: AppTextStyles.labelSmall(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _CloseButton(onTap: onRemove),
        ],
      );
    }

    // Scheduled variant (non-live)
    final matchTitle = '${singleBet.homeName} - ${singleBet.awayName}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 20,
          child: ImageHelper.getSVG(
            path: SportType.fromId(singleBet.sportId)?.iconPath ?? '',
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const Gap(6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onMatchTitleTap,
                child: Text(
                  matchTitle,
                  style: AppTextStyles.labelSmall(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _CloseButton(onTap: onRemove),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: SizedBox.square(
      dimension: 20,
      child: Center(child: ImageHelper.getSVG(path: AppIcons.icRemove)),
    ),
  );
}

class _SelectionStakeCard extends ConsumerStatefulWidget {
  final SingleBetData singleBet;
  final bool isCalculating;
  final bool isDisabled;
  final NumberFormat formatter;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SelectionStakeCard({
    required this.singleBet,
    required this.isCalculating,
    required this.formatter,
    required this.controller,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  ConsumerState<_SelectionStakeCard> createState() =>
      _SelectionStakeCardState();
}

class _SelectionStakeCardState extends ConsumerState<_SelectionStakeCard>
    with SingleTickerProviderStateMixin {
  // Disabled state color - red/700 from Figma
  static const _cancelledTextColor = Color(0xFFB42318);

  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

  /// Calculate potential winnings based on odds and stake
  static double _calculatePotentialWinnings({
    required int stake,
    required double odds,
    required OddsStyle oddsStyle,
  }) {
    if (stake <= 0) return 0;
    if (odds <= 0 || odds == -100) return 0;

    switch (oddsStyle) {
      case OddsStyle.decimal:
        return stake * odds;
      case OddsStyle.malay:
        if (odds > 0 && odds <= 1) {
          return stake * odds + stake;
        } else if (odds < 0) {
          return stake + stake / odds.abs();
        }
        return stake.toDouble();
      case OddsStyle.indo:
        if (odds >= 1) {
          return stake * odds + stake;
        } else if (odds < -1) {
          return stake + stake / odds.abs();
        }
        return stake.toDouble();
      case OddsStyle.hongKong:
        return stake * odds + stake;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation(bool shouldAnimate) {
    if (shouldAnimate) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final singleBet = widget.singleBet;
    final selectionId = singleBet.selectionId;
    final eventId = singleBet.eventData.eventId;
    final marketId = singleBet.marketData.marketId;

    // Watch market suspended status - use select to only rebuild when this specific value changes
    final isMarketSuspended = ref.watch(
      isMarketSuspendedProvider((eventId, marketId)),
    );

    // Watch event hidden status with select - only rebuild when status changes
    final isEventHidden = ref.watch(
      eventLiveDataProvider(
        eventId,
      ).select((data) => EventStatusX.fromString(data?.status).isHidden),
    );

    final isEffectivelyDisabled =
        widget.isDisabled || isMarketSuspended || isEventHidden;

    // Disabled state colors
    final marketNameColor = isEffectivelyDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;
    final selectionNameColor = isEffectivelyDisabled
        ? AppColorStyles.contentTertiary
        : AppColorStyles.contentPrimary;
    final infoIconColor = isEffectivelyDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    Text(
                      singleBet.marketName,
                      style: AppTextStyles.paragraphMedium(
                        color: marketNameColor,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      singleBet.displayName,
                      style: AppTextStyles.labelMedium(
                        color: selectionNameColor,
                      ),
                    ),
                    if (singleBet.errorMessage != null &&
                        !isEffectivelyDisabled) ...[
                      const Gap(4),
                      Text(
                        singleBet.errorMessage!,
                        style: AppTextStyles.labelXSmall(
                          color: const Color(0xFFFF5172),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ParlayExplanationButton(
                      data: singleBet.toHintData(),
                      color: infoIconColor,
                    ),
                  ),
                  // Status indicator section - use Consumer for isolated rebuild
                  if (widget.isDisabled || isEventHidden)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.labelMedium(
                          color: _cancelledTextColor,
                        ),
                      ),
                    )
                  else if (isMarketSuspended)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Color(0xFFAAA49B),
                          ),
                          const Gap(4),
                          Text(
                            'Tạm khóa',
                            style: AppTextStyles.labelMedium(
                              color: const Color(0xFFAAA49B),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (widget.isCalculating)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFDE272),
                          ),
                        ),
                      ),
                    )
                  else
                    // Odds display with animation - isolated in Consumer
                    _OddsDisplay(
                      selectionId: selectionId,
                      singleBet: singleBet,
                      animationController: _animationController,
                      opacityAnimation: _opacityAnimation,
                      onDirectionChanged: _updateAnimation,
                    ),
                ],
              ),
            ],
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StakeInput(
                        controller: widget.controller,
                        singleBet: singleBet,
                        onChanged: widget.onChanged,
                        isDisabled: isEffectivelyDisabled,
                      ),
                      const Gap(8),
                      if (!isEffectivelyDisabled) ...[
                        if (widget.isCalculating)
                          Row(
                            children: [
                              Text(
                                'Mức cược: ',
                                style: AppTextStyles.paragraphXSmall(
                                  color: AppColorStyles.contentSecondary,
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColorStyles.contentSecondary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          _StakeLimitInfo(
                            singleBet: singleBet,
                            onMinTap: () => widget.onChanged(
                              singleBet.minStakeActual.toString(),
                            ),
                            onMaxTap: () => widget.onChanged(
                              singleBet.maxStakeActual.toString(),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const Gap(12),
                // Potential winnings - isolated in Consumer for odds/stake changes
                Expanded(
                  child: _PotentialWinningsDisplay(
                    singleBet: singleBet,
                    formatter: widget.formatter,
                    isDisabled: isEffectivelyDisabled,
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

/// Isolated widget for odds display with animation - only rebuilds when odds/direction changes
class _OddsDisplay extends ConsumerStatefulWidget {
  final String? selectionId;
  final SingleBetData singleBet;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final ValueChanged<bool> onDirectionChanged;

  const _OddsDisplay({
    required this.selectionId,
    required this.singleBet,
    required this.animationController,
    required this.opacityAnimation,
    required this.onDirectionChanged,
  });

  @override
  ConsumerState<_OddsDisplay> createState() => _OddsDisplayState();
}

class _OddsDisplayState extends ConsumerState<_OddsDisplay> {
  static const _upRangeBgColor = Color(0x33669F2A);
  static const _downRangeBgColor = Color(0x33F04438);

  OddsChangeDirection _lastDirection = OddsChangeDirection.none;

  @override
  Widget build(BuildContext context) {
    final selectionId = widget.selectionId;

    // Watch only direction for this selection
    final direction = selectionId != null
        ? ref.watch(oddsDirectionProvider(selectionId))
        : OddsChangeDirection.none;

    // Watch odds style
    final currentOddsStyle = ref.watch(oddsStyleProvider);

    // Watch odds data for this selection only
    final oddsChangeData = ref.watch(oddsChangeDataProvider(selectionId ?? ''));

    // Get initial odds from SingleBetData (API data) as fallback
    final initialOdds = widget.singleBet.getOddsByStyle(currentOddsStyle);

    // Determine effective odds with proper fallback
    // Priority: WebSocket odds (if valid) > Initial API odds
    double effectiveOdds;
    if (oddsChangeData != null &&
        oddsChangeData.oddsValues != null &&
        oddsChangeData.oddsValues!.isValid) {
      final wsOdds = oddsChangeData.oddsValues!.getByStyleIndex(
        currentOddsStyle.index,
      );
      // Only use WebSocket odds if it's valid (> 0 and != -100), otherwise fall back to initial
      effectiveOdds = (wsOdds > 0 && wsOdds != -100) ? wsOdds : initialOdds;
    } else {
      effectiveOdds = initialOdds;
    }

    final displayOddsString = effectiveOdds == 0 || effectiveOdds == -100
        ? '-'
        : effectiveOdds.toStringAsFixed(2);

    final showUpRange = direction == OddsChangeDirection.up;
    final showDownRange = direction == OddsChangeDirection.down;

    // Notify parent about direction change for animation control
    if (direction != _lastDirection) {
      _lastDirection = direction;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDirectionChanged(showUpRange || showDownRange);
      });
    }

    final oddsBgColor = showUpRange
        ? _upRangeBgColor
        : showDownRange
        ? _downRangeBgColor
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: oddsBgColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              displayOddsString,
              style: AppTextStyles.labelMedium(color: const Color(0xFFACDC79)),
            ),
          ),
          if (showUpRange)
            Positioned(
              right: -5,
              top: 0,
              child: AnimatedBuilder(
                animation: widget.opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: widget.opacityAnimation.value,
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
          if (showDownRange)
            Positioned(
              right: -5,
              bottom: 0,
              child: AnimatedBuilder(
                animation: widget.opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: widget.opacityAnimation.value,
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
    );
  }
}

/// Isolated widget for potential winnings - only rebuilds when odds/stake changes
class _PotentialWinningsDisplay extends ConsumerWidget {
  final SingleBetData singleBet;
  final NumberFormat formatter;
  final bool isDisabled;

  const _PotentialWinningsDisplay({
    required this.singleBet,
    required this.formatter,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch odds style
    final currentOddsStyle = ref.watch(oddsStyleProvider);

    // 🔧 PERFORMANCE FIX: Chỉ watch oddsValues thay vì toàn bộ OddsChangeData
    // Tránh rebuild khi direction/lastChangeTime thay đổi
    final oddsValues = ref.watch(
      oddsChangeDataProvider(
        singleBet.selectionId ?? '',
      ).select((data) => data?.oddsValues),
    );

    // Get initial odds from SingleBetData (API data) as fallback
    final initialOdds = singleBet.getOddsByStyle(currentOddsStyle);

    // Determine effective odds with proper fallback
    // Priority: WebSocket odds (if valid) > Initial API odds
    double effectiveOdds;
    if (oddsValues != null && oddsValues.isValid) {
      final wsOdds = oddsValues.getByStyleIndex(currentOddsStyle.index);
      // Only use WebSocket odds if it's valid (> 0 and != -100), otherwise fall back to initial
      effectiveOdds = (wsOdds > 0 && wsOdds != -100) ? wsOdds : initialOdds;
    } else {
      effectiveOdds = initialOdds;
    }

    // Calculate potential winnings
    final potentialWinnings =
        _SelectionStakeCardState._calculatePotentialWinnings(
          stake: singleBet.stake,
          odds: effectiveOdds,
          oddsStyle: currentOddsStyle,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          I18n.txtEstimatedPayout,
          style: AppTextStyles.labelSmall(
            color: isDisabled
                ? AppColorStyles.contentQuaternary
                : AppColorStyles.contentSecondary,
          ),
          textAlign: TextAlign.right,
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CurrencyText(
              isDisabled ? '0' : formatter.format(potentialWinnings.round()),
              iconSize: 20,
              style: AppTextStyles.labelMedium(
                color: isDisabled
                    ? AppColorStyles.contentQuaternary
                    : AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StakeInput extends StatelessWidget {
  final TextEditingController controller;
  final SingleBetData singleBet;
  final ValueChanged<String> onChanged;
  final bool isDisabled;

  const _StakeInput({
    required this.controller,
    required this.singleBet,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Disabled state colors
    final textColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentPrimary;
    final currencyColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorStyles.borderPrimary, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              enabled: !isDisabled,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              style: AppTextStyles.labelMedium(color: textColor),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Nhập số tiền',
                hintStyle: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentQuaternary,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
          const Gap(8),
          const CurrencySymbol(size: 20),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: AppColors.red500,
      ),
      child: Text(
        'Trực tiếp',
        style: AppTextStyles.labelXXSmall(color: AppColorStyles.contentPrimary),
      ),
    );
  }
}

/// Disabled state live dot - uses red/500 color from Figma
class _DisabledLiveDot extends StatelessWidget {
  const _DisabledLiveDot();

  @override
  Widget build(BuildContext context) =>
      const Opacity(opacity: 0.12, child: _LiveDot());
}

/// Widget hiển thị thông tin mức cược với 3 trạng thái:
/// - Normal: Mức cược: 50K - 236.86M
/// - Error min: Mức cược tối thiểu: 50K (tappable)
/// - Error max: Mức cược tối đa: 236.86M (tappable)
class _StakeLimitInfo extends StatelessWidget {
  final SingleBetData singleBet;
  final VoidCallback onMinTap;
  final VoidCallback onMaxTap;

  const _StakeLimitInfo({
    required this.singleBet,
    required this.onMinTap,
    required this.onMaxTap,
  });

  @override
  Widget build(BuildContext context) {
    final stake = singleBet.stake;
    final minStake = singleBet.minStakeActual;
    final maxStake = singleBet.maxStakeActual;

    // State 1: stake < min (and stake > 0)
    if (stake > 0 && stake < minStake) {
      return Row(
        children: [
          Text(
            'Mức cược tối thiểu: ',
            style: AppTextStyles.paragraphXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: onMinTap,
            child: Text(
              MoneyFormatter.formatCompact(minStake),
              style: AppTextStyles.paragraphXSmall(color: AppColors.yellow500)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow500,
                  ),
            ),
          ),
        ],
      );
    }

    // State 2: stake > max
    if (stake > maxStake) {
      return Row(
        children: [
          Text(
            'Mức cược tối đa: ',
            style: AppTextStyles.paragraphXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: onMaxTap,
            child: Text(
              MoneyFormatter.formatCompact(maxStake),
              style: AppTextStyles.paragraphXSmall(color: AppColors.yellow500)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow500,
                  ),
            ),
          ),
        ],
      );
    }

    // Normal state: show range
    return Row(
      children: [
        Text(
          'Mức cược: ',
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
        Text(
          '${MoneyFormatter.formatCompact(minStake)} - ${MoneyFormatter.formatCompact(maxStake)}',
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    );
  }
}

/// Notification widget when parlay is not supported for this bet
class _ParlayNotSupportedNotification extends StatelessWidget {
  const _ParlayNotSupportedNotification();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColorStyles.backgroundQuaternary,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1FEF6820), // 0.12 opacity = 0x1F
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.orange500, size: 24),
          const Gap(12),
          Text(
            'Vé này không hỗ trợ cược xiên',
            style: AppTextStyles.labelMedium(color: AppColors.orange200),
          ),
        ],
      ),
    ),
  );
}

class _ParlayButton extends StatelessWidget {
  final SingleBetData singleBet;
  final bool isInParlay;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ParlayButton({
    required this.singleBet,
    required this.isInParlay,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Disabled state - another selection from same event is in combo
    if (isDisabled) {
      return Container(
        color: AppColorStyles.backgroundQuaternary,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          width: double.infinity,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColorStyles.borderPrimary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 20,
                child: ImageHelper.getSVG(
                  path: AppIcons.iconAddToParlayPrimary,
                ),
              ),
              const Gap(6),
              Text(
                'Thêm vào cược xiên',
                style: AppTextStyles.buttonMedium(
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isInParlay) {
      // Remove from parlay button - gray background
      return Container(
        color: AppColorStyles.backgroundQuaternary,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppColorStyles.borderPrimary, // gray-600
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: Center(
                    child: ImageHelper.getSVG(
                      path: AppIcons.icRemove,
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),

                const Gap(6),
                Text(
                  'Xóa khỏi cược xiên',
                  style: AppTextStyles.buttonMedium(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Add to parlay button - yellow background
      return Container(
        color: AppColorStyles.backgroundQuaternary,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFDE272,
              ).withOpacity(0.08), // rgba(253,226,114,0.08)
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: ImageHelper.getSVG(
                    path: AppIcons.iconAddToParlayPrimary,
                  ),
                ),
                const Gap(6),
                Text(
                  'Thêm vào cược xiên',
                  style: AppTextStyles.buttonMedium(
                    color: const Color(0xFFFEEE95), // yellow-200
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: const BetSlipBlank(),
    );
  }
}
