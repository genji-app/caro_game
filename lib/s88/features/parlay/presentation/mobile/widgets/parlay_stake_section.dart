import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_explanation_button.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/odds_change_provider.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/quick_amount_buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/dashed_divider_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/status_information/status_information.dart';
import 'package:co_caro_flame/s88/shared/widgets/texts/texts.dart';

class ParlayStakeSection extends ConsumerStatefulWidget {
  const ParlayStakeSection({super.key});

  @override
  ConsumerState<ParlayStakeSection> createState() => _ParlayStakeSectionState();
}

class _ParlayStakeSectionState extends ConsumerState<ParlayStakeSection> {
  late final TextEditingController _controller;
  final _formatter = NumberFormat.decimalPattern('vi');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _format(ref.read(parlayStateProvider).stake),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Select only the fields needed for this widget
    final comboBets = ref.watch(parlayStateProvider.select((s) => s.comboBets));
    final hasEnoughMatches = ref.watch(
      parlayStateProvider.select((s) => s.hasEnoughMatches),
    );
    final minMatches = ref.watch(
      parlayStateProvider.select((s) => s.minMatches),
    );
    final notifier = ref.read(parlayStateProvider.notifier);

    // Sync text field when stake changes (only listen to stake)
    ref.listen(parlayStateProvider.select((s) => s.stake), (previous, next) {
      final formatted = _format(next);
      if (_controller.text != formatted) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });

    // Empty state
    if (comboBets.isEmpty) {
      return const _EmptyComboState();
    }

    // Count valid (non-disabled) bets for header display
    final validBetsCount = comboBets.where((bet) => !bet.isDisabled).length;

    return Column(
      children: [
        if (!hasEnoughMatches) _MinMatchesWarning(minMatches: minMatches),
        Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(label: 'Xiên $validBetsCount Chân'),
              // Warning if not enough matches
              _StakeCard(
                controller: _controller,
                formatter: _formatter,
                notifier: notifier,
              ),
              for (var i = 0; i < comboBets.length; i++) ...[
                _ComboLegTile(
                  bet: comboBets[i],
                  onRemove: () => notifier.removeFromComboParlay(i),
                ),
              ],
              Container(
                width: double.infinity,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(num value) => _formatter.format(value);
}

/// Empty state when no combo bets
class _EmptyComboState extends StatelessWidget {
  const _EmptyComboState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: const BetSlipBlank(),
    );
  }
}

/// Warning shown when combo has less than minMatches
class _MinMatchesWarning extends StatelessWidget {
  final int minMatches;

  const _MinMatchesWarning({required this.minMatches});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    height: 52,
    decoration: BoxDecoration(
      color: AppColors.green700,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Stack(
      children: [
        // Inner layer with inset shadow
        const Positioned.fill(
          child: CustomPaint(painter: _InnerShadowPainter()),
        ),
        // Content layer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: ImageHelper.load(
                  path: AppIcons.iconSoccer,
                  color: AppColorStyles.contentPrimary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Center(
                  child: Text(
                    'Cần tối thiểu $minMatches trận để cược xiên',
                    style: AppTextStyles.labelLarge(
                      color: AppColorStyles.contentPrimary,
                    ).copyWith(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Gap(12),
              SizedBox(
                width: 20,
                height: 20,
                child: ImageHelper.load(
                  path: AppIcons.iconSoccer,
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Shine effect painter for MinMatchesWarning (based on ShineButtonDefaultPainter)
class _InnerShadowPainter extends CustomPainter {
  const _InnerShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const radius = Radius.circular(12);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    // Clip to rounded rect
    canvas.save();
    canvas.clipRRect(rrect);

    // Background gradient: top center to bottom center
    // rgba(255,255,255,0.24) 0% -> rgba(255,255,255,0) 55.23%
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.4),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        stops: [0.0, 0.523],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);
    canvas.restore();

    // // Border with sweep gradient
    // const strokeWidth = 1.0;
    // final borderRRect = RRect.fromRectAndRadius(
    //   Rect.fromLTWH(
    //     strokeWidth / 2,
    //     strokeWidth / 2,
    //     size.width - strokeWidth,
    //     size.height - strokeWidth,
    //   ),
    //   const Radius.circular(12 - strokeWidth / 2),
    // );

    // final borderPaint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = strokeWidth
    //   ..shader = const SweepGradient(
    //     center: Alignment.center,
    //     startAngle: 0,
    //     endAngle: 2.62 * 2,
    //     transform: GradientRotation(3.7 * 3 / 4),
    //     colors: [
    //       Color.fromRGBO(0, 0, 0, 0.0),
    //       Color.fromRGBO(255, 255, 255, 0.12),
    //       Color.fromRGBO(255, 255, 255, 0.18),
    //       Color.fromRGBO(255, 255, 255, 0.24),
    //       Color.fromRGBO(255, 255, 255, 0.18),
    //       Color.fromRGBO(255, 255, 255, 0.12),
    //       Color.fromRGBO(0, 0, 0, 0.0),
    //       Color.fromRGBO(0, 0, 0, 0.0),
    //     ],
    //     stops: [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
    //   ).createShader(rect);

    // canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        SizedBox.square(
          dimension: 20,
          child: ImageHelper.getSVG(
            path: AppIcons.iconAddToParlayPrimary,
            color: AppColorStyles.contentSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    ),
  );
}

class _StakeCard extends ConsumerWidget {
  final TextEditingController controller;
  final NumberFormat formatter;
  final ParlayStateNotifier notifier;

  const _StakeCard({
    required this.controller,
    required this.formatter,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the fields needed for this widget
    final totalOdds = ref.watch(parlayStateProvider.select((s) => s.totalOdds));
    final potentialWin = ref.watch(
      parlayStateProvider.select((s) => s.potentialWin),
    );
    final stake = ref.watch(parlayStateProvider.select((s) => s.stake));
    final minStake = ref.watch(parlayStateProvider.select((s) => s.minStake));
    final maxStake = ref.watch(parlayStateProvider.select((s) => s.maxStake));

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
      ),
      padding: const EdgeInsets.all(12).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng tỷ lệ',
                  style: AppTextStyles.labelMedium(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
              Text(
                totalOdds.toStringAsFixed(2),
                style: AppTextStyles.labelMedium(
                  color: const Color(0xFFACDC79),
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorStyles.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColorStyles.borderPrimary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.labelMedium(
                            color: AppColorStyles.contentPrimary,
                          ),
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                          onChanged: notifier.setStakeFromInput,
                        ),
                      ),

                      const Gap(8),
                      const CurrencySymbol(size: 20),
                    ],
                  ),
                ),
              ),

              const Gap(12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      I18n.txtEstimatedPayout,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CurrencyText(
                          formatter.format(potentialWin),
                          iconSize: 20,
                          style: AppTextStyles.labelMedium(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          _StakeLimitRow(
            stake: stake,
            minStake: minStake,
            maxStake: maxStake,
            onMinTap: () => notifier.setStake(minStake),
            onMaxTap: () => notifier.setStake(maxStake),
          ),
          const Gap(12),
          QuickAmountButtons(
            buttons: const [
              QuickAmountButton(label: '+50K', value: '50000'),
              QuickAmountButton(label: '+500K', value: '500000'),
              QuickAmountButton(label: '+5M', value: '5000000'),
              QuickAmountButton(label: '+10M', value: '10000000'),
              QuickAmountButton(label: 'All-in', value: 'all'),
            ],
            columnsPerRow: 5,
            onButtonTap: (value) {
              if (value == 'all') {
                notifier.setStake(maxStake);
                return;
              }
              notifier.addStake(int.tryParse(value) ?? 0);
            },
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị thông tin mức cược với 3 trạng thái:
/// - Normal: Min: 50K ... Max: 236.86M
/// - Error min: Mức cược tối thiểu: 50K (tappable)
/// - Error max: Mức cược tối đa: 236.86M (tappable)
class _StakeLimitRow extends StatelessWidget {
  final num stake;
  final int minStake;
  final int maxStake;
  final VoidCallback onMinTap;
  final VoidCallback onMaxTap;

  const _StakeLimitRow({
    required this.stake,
    required this.minStake,
    required this.maxStake,
    required this.onMinTap,
    required this.onMaxTap,
  });

  @override
  Widget build(BuildContext context) {
    // State 1: stake < min (and stake > 0)
    if (stake > 0 && stake < minStake) {
      return Row(
        children: [
          Text(
            'Mức cược tối thiểu: ',
            style: AppTextStyles.labelXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: onMinTap,
            child: Text(
              MoneyFormatter.formatCompact(minStake),
              style: AppTextStyles.labelXSmall(color: AppColors.yellow500)
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
            style: AppTextStyles.labelXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: onMaxTap,
            child: Text(
              MoneyFormatter.formatCompact(maxStake),
              style: AppTextStyles.labelXSmall(color: AppColors.yellow500)
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

    // Normal state: show Min and Max
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     GestureDetector(
    //       onTap: onMinTap,
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text(
    //             'Min: ',
    //             style: AppTextStyles.labelXSmall(
    //               color: AppColorStyles.contentSecondary,
    //             ),
    //           ),
    //           Text(
    //             MoneyFormatter.formatCompact(minStake),
    //             style: AppTextStyles.labelXSmall(
    //               color: AppColorStyles.contentPrimary,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     GestureDetector(
    //       onTap: onMaxTap,
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text(
    //             'Max: ',
    //             style: AppTextStyles.labelXSmall(
    //               color: AppColorStyles.contentSecondary,
    //             ),
    //           ),
    //           Text(
    //             MoneyFormatter.formatCompact(maxStake),
    //             style: AppTextStyles.labelXSmall(
    //               color: AppColorStyles.contentPrimary,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}

class _ComboLegTile extends ConsumerStatefulWidget {
  final SingleBetData bet;
  final VoidCallback onRemove;

  const _ComboLegTile({required this.bet, required this.onRemove});

  @override
  ConsumerState<_ComboLegTile> createState() => _ComboLegTileState();
}

class _ComboLegTileState extends ConsumerState<_ComboLegTile>
    with SingleTickerProviderStateMixin {
  static const _cancelledTextColor = Color(0xFFB42318);

  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDirectionChange(OddsChangeDirection direction) {
    final showRange =
        direction == OddsChangeDirection.up ||
        direction == OddsChangeDirection.down;
    if (showRange) {
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
    final bet = widget.bet;
    final isDisabled = bet.isDisabled;
    final selectionId = bet.selectionId;

    // Listen for direction changes to control animation (không rebuild widget)
    if (selectionId != null) {
      ref.listen<OddsChangeDirection>(
        oddsDirectionProvider(selectionId),
        (previous, next) => _handleDirectionChange(next),
      );
    }

    // Text colors based on disabled state
    final headerTextColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;
    final marketNameColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;
    final selectionNameColor = isDisabled
        ? AppColorStyles.contentTertiary
        : AppColorStyles.contentPrimary;
    final infoIconColor = isDisabled
        ? AppColorStyles.contentQuaternary
        : AppColorStyles.contentSecondary;

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(12),
          const _Divider(),
          const Gap(12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Opacity(
                      opacity: isDisabled ? 0.12 : 1,
                      child: SizedBox.square(
                        dimension: 20,
                        child: ImageHelper.getSVG(
                          path: AppIcons.iconFootballSelected,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                    const Gap(6),
                    if (bet.isLive) ...[
                      isDisabled ? _DisabledPulseDot() : _PulseDot(),
                      const Gap(6),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bet.eventData.homeName} vs ${bet.eventData.awayName}',
                            style: AppTextStyles.labelSmall(
                              color: headerTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: widget.onRemove,
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox.square(
                        dimension: 20,
                        child: Center(
                          child: ImageHelper.getSVG(path: AppIcons.icRemove),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColorStyles.backgroundTertiary,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bet.marketName,
                                    style: AppTextStyles.paragraphMedium(
                                      color: marketNameColor,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    bet.displayName,
                                    style: AppTextStyles.labelMedium(
                                      color: selectionNameColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Gap(4),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 4.0,
                                ),
                                child: ParlayExplanationButton(
                                  data: bet.toHintData(),
                                  color: infoIconColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 12.0,
                                  bottom: 8,
                                ),
                                child: isDisabled
                                    ? Text(
                                        'Hủy',
                                        style: AppTextStyles.labelMedium(
                                          color: _cancelledTextColor,
                                        ),
                                      )
                                    : _OddsText(
                                        selectionId: selectionId,
                                        fallbackOdds: bet.displayOddsString,
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Up range indicator - chỉ rebuild khi direction thay đổi
                    if (selectionId != null && !isDisabled)
                      _UpRangeIndicator(
                        selectionId: selectionId,
                        opacityAnimation: _opacityAnimation,
                      ),
                    // Down range indicator - chỉ rebuild khi direction thay đổi
                    if (selectionId != null && !isDisabled)
                      _DownRangeIndicator(
                        selectionId: selectionId,
                        opacityAnimation: _opacityAnimation,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget riêng để chỉ rebuild khi odds value thay đổi
class _OddsText extends ConsumerWidget {
  final String? selectionId;
  final String fallbackOdds;

  const _OddsText({required this.selectionId, required this.fallbackOdds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayOdds = selectionId != null
        ? ref.watch(
            oddsValueProvider(selectionId!).select((v) => v ?? fallbackOdds),
          )
        : fallbackOdds;

    return Text(
      displayOdds,
      style: AppTextStyles.labelMedium(color: const Color(0xFFACDC79)),
    );
  }
}

/// Widget riêng cho Up range indicator - chỉ rebuild khi direction thay đổi
class _UpRangeIndicator extends ConsumerWidget {
  final String selectionId;
  final Animation<double> opacityAnimation;

  const _UpRangeIndicator({
    required this.selectionId,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showUpRange = ref.watch(
      oddsDirectionProvider(
        selectionId,
      ).select((d) => d == OddsChangeDirection.up),
    );

    if (!showUpRange) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 4,
      right: 4,
      child: AnimatedBuilder(
        animation: opacityAnimation,
        builder: (context, child) =>
            Opacity(opacity: opacityAnimation.value, child: child),
        child: ImageHelper.load(
          path: AppIcons.upRangeBet,
          width: 8,
          height: 8,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

/// Widget riêng cho Down range indicator - chỉ rebuild khi direction thay đổi
class _DownRangeIndicator extends ConsumerWidget {
  final String selectionId;
  final Animation<double> opacityAnimation;

  const _DownRangeIndicator({
    required this.selectionId,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDownRange = ref.watch(
      oddsDirectionProvider(
        selectionId,
      ).select((d) => d == OddsChangeDirection.down),
    );

    if (!showDownRange) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 4,
      right: 4,
      child: AnimatedBuilder(
        animation: opacityAnimation,
        builder: (context, child) =>
            Opacity(opacity: opacityAnimation.value, child: child),
        child: ImageHelper.load(
          path: AppIcons.downRangeBet,
          width: 8,
          height: 8,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
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

/// Disabled state pulse dot (matching single bet styling - red/500)
class _DisabledPulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Opacity(opacity: 0.12, child: _PulseDot());
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const DashedDivider.horizontal(
      thickness: 4,
      dashGap: 6,
      height: 20,
      color: AppColorStyles.backgroundTertiary,
    );
  }
}
