import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/widgets/bet_details_header.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/widgets/match_stats_table.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/widgets/handicap_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/widgets/bet_amount_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/widgets/bet_action_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Check if this is a special outright bet (from sport_detail_special.dart)
bool _isSpecialOutrightBet(BettingPopupData? data) {
  if (data == null) return false;

  // Check if event has no home/away teams (typical for outright bets)
  // Or check market name for outright indicators
  final hasNoTeams =
      (data.eventData.homeName.isEmpty && data.eventData.awayName.isEmpty);
  final marketName = data.getMarketName().toLowerCase();
  final isOutrightMarket =
      marketName.contains('winner') ||
      marketName.contains('vô địch') ||
      marketName.contains('outright');

  return hasNoTeams || isOutrightMarket;
}

class BetDetailsContent extends ConsumerStatefulWidget {
  const BetDetailsContent({
    super.key,
    this.isMobile = false,
    this.isVibrating = false,
    this.isBottomSheet = false,
  });
  final bool isMobile;
  final bool isVibrating;
  final bool isBottomSheet;

  @override
  ConsumerState<BetDetailsContent> createState() => _BetDetailsContentState();
}

class _BetDetailsContentState extends ConsumerState<BetDetailsContent> {
  final _betAmountKey = GlobalKey<BetAmountSectionState>();

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to add padding when keyboard is visible
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Watch betting popup state
    final bettingState = ref.watch(bettingPopupProvider);
    final bettingNotifier = ref.read(bettingPopupProvider.notifier);

    // Handle popup close - only when isClosed changes to true from user action
    if (bettingState.isClosed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Re-check isClosed with latest state (may have been reset by initialize())
        final currentState = ref.read(bettingPopupProvider);
        if (!currentState.isClosed) {
          return; // State was reset for new popup, don't close
        }

        if (currentState.error != null && context.mounted) {
          // Show error toast for WebSocket errors (odds changed, market closed, etc.)
          AppToast.showError(context, message: currentState.error!);

          // Refresh league when odds/line changed (603, mapped text, or WS copy).
          // Use fetchLeaguesSilent() to avoid UI freeze on web.
          final isOddsChangedError = bettingApiErrorIndicatesOddsChanged(
            errorCode: currentState.errorCode,
            message: currentState.error,
          );
          if (isOddsChangedError) {
            ref.read(leagueProvider.notifier).fetchLeaguesSilent();
          }
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BetDetailsHeader(
            isVibrating: widget.isVibrating,
            isMobile: widget.isMobile,
            isBottomSheet: widget.isBottomSheet,
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Check if this is a special outright bet (from sport_detail_special)
                          // Special outright bets typically don't have match stats
                          if (_isSpecialOutrightBet(bettingState.bettingData))
                            _SpecialOutrightBetDetails(
                              data: bettingState.bettingData,
                              currentOdds: bettingState.getCurrentOdds(),
                              stake:
                                  int.tryParse(bettingState.betAmount) ?? 100,
                            )
                          else ...[
                            MatchStatsTable(
                              data: bettingState.bettingData,
                              isVibrating: widget.isVibrating,
                            ),
                            const SizedBox(height: 8),
                            HandicapSection(
                              data: bettingState.bettingData,
                              currentOdds: bettingState.getCurrentOdds(),
                              stake:
                                  int.tryParse(bettingState.betAmount) ?? 100,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Parlay button or notification
                    if (!_isSpecialOutrightBet(bettingState.bettingData)) ...[
                      if (bettingState.bettingData?.marketData.isParlay ==
                          false)
                        const _ParlayNotSupportedNotification()
                      else
                        _ParlayToggleButton(
                          bettingData: bettingState.bettingData,
                        ),
                      const SizedBox(height: 24),
                    ],
                    ImageHelper.load(
                      path: AppIcons.sunLine,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BetAmountSection(
                        key: _betAmountKey,
                        betAmount: bettingState.betAmount,
                        onBetAmountChanged: (amount) {
                          // Remove commas before updating
                          final cleanAmount = amount.replaceAll(',', '');
                          bettingNotifier.updateBetAmount(cleanAmount);
                        },
                        data: bettingState.bettingData,
                        minStake: bettingState.minStake,
                        maxStake: bettingState.maxStake,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          BetActionSection(
            isMobile: widget.isMobile,
            onAddAmount: (amount) =>
                _betAmountKey.currentState?.addAmount(amount),
            onSetAllIn: () => _betAmountKey.currentState?.setAllIn(),
          ),
        ],
      ),
    );
  }
}

/// Notification widget when parlay is not supported for this bet
class _ParlayNotSupportedNotification extends StatelessWidget {
  const _ParlayNotSupportedNotification();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
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

/// Parlay toggle button - shows "Thêm vào cược xiên" or "Xóa khỏi cược xiên"
class _ParlayToggleButton extends ConsumerWidget {
  final BettingPopupData? bettingData;

  const _ParlayToggleButton({required this.bettingData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bettingData == null) return const SizedBox.shrink();

    // Watch parlay state to check if selection is in combo
    final parlayState = ref.watch(parlayStateProvider);
    final selectionId = bettingData!.getSelectionId();
    final isInParlay = parlayState.isSelectionInCombo(selectionId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _handleTap(context, ref, isInParlay),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isInParlay
                ? AppColorStyles.backgroundSecondary
                : AppColors.yellow300.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isInParlay
                  ? Icon(
                      Icons.remove,
                      color: AppColorStyles.contentPrimary,
                      size: 20,
                    )
                  : ImageHelper.getSVG(path: AppIcons.iconAddToParlayPrimary),
              const SizedBox(width: 6),
              Text(
                isInParlay ? 'Xóa khỏi cược xiên' : 'Thêm vào cược xiên',
                style: AppTextStyles.buttonMedium(
                  color: isInParlay
                      ? AppColorStyles.contentPrimary
                      : AppColors.yellow200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, bool isInParlay) {
    final data = bettingData;
    if (data == null) return;

    final parlayNotifier = ref.read(parlayStateProvider.notifier);
    final parlayState = ref.read(parlayStateProvider);
    final selectionId = data.getSelectionId();

    if (isInParlay) {
      // Remove from combo
      parlayNotifier.removeFromComboBySelectionId(selectionId);
      if (context.mounted) {
        AppToast.showSuccess(context, message: 'Đã xóa khỏi cược xiên');
      }
    } else {
      // Check if market supports parlay
      if (!data.marketData.isParlay) {
        if (context.mounted) {
          AppToast.showError(
            context,
            message: 'Kèo này không hỗ trợ cược xiên',
          );
        }
        return;
      }

      // Check if another selection from same event is already in combo
      // Use hasOtherSelectionInCombo to exclude disabled bets and current selection
      final eventId = data.eventData.eventId;
      if (parlayState.hasOtherSelectionInCombo(eventId, selectionId)) {
        if (context.mounted) {
          AppToast.showError(
            context,
            message: 'Đã có kèo khác từ trận này trong cược xiên',
          );
        }
        return;
      }

      // Create SingleBetData from BettingPopupData and add directly to combo
      // Note: calculateComboParlay will be called when user opens combo ticket, not here
      final singleBetData = SingleBetData.fromBettingPopupData(data);
      parlayNotifier.addComboBetDirect(singleBetData);

      if (context.mounted) {
        AppToast.showSuccess(context, message: 'Đã thêm vào cược xiên');
      }
    }
  }
}

/// Special Outright Bet Details Section
/// Displays league info and selection for special outright bets (from sport_detail_special.dart)
class _SpecialOutrightBetDetails extends StatelessWidget {
  final BettingPopupData? data;
  final double? currentOdds;
  final int stake;

  const _SpecialOutrightBetDetails({
    this.data,
    this.currentOdds,
    this.stake = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    // Extract league info
    final leagueLogo = data!.leagueData?.leagueLogo ?? '';

    // For special outright bets, use eventName directly (already contains full outright name)
    // This matches _buildOutrightHeader() which displays _removeDateBracket(outrightName)
    final eventName = data!.eventData.eventName ?? '';
    final outrightName = eventName.isNotEmpty
        ? eventName
        : data!.getLeagueName().isNotEmpty
        ? data!.getLeagueName()
        : 'Outright Bet';

    // For special outright bets, try to get team name from selection
    // Fallback to selectionName() method
    String selectionName;
    if (data!.eventData.homeName.isNotEmpty) {
      // If homeName exists, it might be the selection (for outright bets)
      selectionName = data!.eventData.homeName;
    } else if (data!.eventData.awayName.isNotEmpty) {
      selectionName = data!.eventData.awayName;
    } else {
      selectionName = data!.getSelectionName();
    }

    final oddsValue = data!.getDisplayOdds();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section: League header with icon, name, and event name
        Stack(
          children: [
            Positioned.fill(
              child: ImageHelper.load(
                path: AppIcons.backgroundSpecialLeague,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              // decoration: BoxDecoration(
              // color: AppColorStyles.backgroundTertiary,
              // borderRadius: BorderRadius.circular(12),
              // border: Border(
              //   bottom: BorderSide(color: Colors.transparent, width: 0.5),
              // ),
              // ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // League icon (96px)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(96),
                      child: leagueLogo.isNotEmpty
                          ? ImageHelper.getNetworkImage(
                              imageUrl: leagueLogo,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: ImageHelper.load(
                                path: AppIcons.iconSoccer,
                                width: 48,
                                height: 48,
                              ),
                            )
                          : ImageHelper.load(
                              path: AppIcons.iconSoccer,
                              width: 48,
                              height: 48,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Outright name (1 line) - same format as _buildOutrightHeader()
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // Split outrightName into league name and season info
                        // Pattern: "UEFA Champions League 2025/2026 - Winner"
                        // -> leagueName: "UEFA Champions League"
                        // -> seasonInfo: "2025/2026 - Winner"
                        final yearPattern = RegExp(r'\d{4}/\d{4}');
                        final match = yearPattern.firstMatch(outrightName);

                        String leagueName;
                        String seasonInfo;

                        if (match != null) {
                          leagueName = outrightName
                              .substring(0, match.start)
                              .trim();
                          seasonInfo = outrightName
                              .substring(match.start)
                              .trim();
                        } else {
                          leagueName = outrightName;
                          seasonInfo = '';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leagueName,
                              style: AppTextStyles.labelSmall(
                                color: AppColorStyles.contentPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (seasonInfo.isNotEmpty) ...[
                              const Gap(2),
                              Text(
                                seasonInfo,
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.cyan500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bottom section: Selection with label, name, odds, and help icon
        Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Label and selection name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đội vô địch', // Label from design
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectionName.isNotEmpty ? selectionName : 'N/A',
                      style: AppTextStyles.labelMedium(
                        color: AppColorStyles.contentPrimary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              // Right: Help icon and odds
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Help icon (18x18) - tappable to show hint bubble
                  GestureDetector(
                    onTap: () => _showHintBubble(context),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Odds value
                  Text(
                    oddsValue,
                    style: AppTextStyles.labelMedium(color: AppColors.green300),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show hint bubble dialog
  void _showHintBubble(BuildContext context) {
    if (data == null) return;

    final odds = currentOdds ?? data!.getSelectedOddsValue();

    // stake is in VND (int), convert to double for HintData
    final stakeInVND = stake.toDouble();

    final hintData = HintData.fromBettingPopup(
      popupData: data!,
      currentOdds: odds,
      stake: stakeInVND,
    );

    final hintContent = HintService.generateHint(hintData);

    showHintBubble(
      context: context,
      title: 'Đội Vô Địch',
      content: hintContent,
      ratio: odds,
    );
  }
}
