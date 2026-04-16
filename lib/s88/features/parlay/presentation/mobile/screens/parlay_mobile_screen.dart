import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/bet_success/bet_success.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_header.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_match_card.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_multi_section.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_shimmer_loading.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_stake_section.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_summary_section.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/widgets/parlay_tab_bar.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class ParlayMobileScreen extends ConsumerStatefulWidget {
  const ParlayMobileScreen({super.key});

  @override
  ConsumerState<ParlayMobileScreen> createState() => _ParlayMobileScreenState();
}

class _ParlayMobileScreenState extends ConsumerState<ParlayMobileScreen> {
  bool _hasTriggeredRecalculate = false;

  /// Whether bet is currently being placed (shows loading state)
  bool _isPlacingBet = false;

  /// Whether to show success view after bet placement (single bets)
  bool _showSuccessView = false;

  /// List of successfully placed bets (single bets)
  List<SingleBetData> _successfulBets = [];

  /// Whether to show combo success view after combo bet placement
  bool _showComboSuccessView = false;

  /// Combo bet success data
  ComboBetSuccessData? _comboBetSuccessData;

  @override
  void initState() {
    super.initState();
    // Trigger recalculate when bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerRecalculateIfReady();
    });
  }

  /// Trigger recalculate all bets if betting is ready
  void _triggerRecalculateIfReady() {
    if (!mounted || _hasTriggeredRecalculate) return;

    final isBettingReady = ref.read(isBettingReadyProvider);
    if (isBettingReady) {
      _hasTriggeredRecalculate = true;
      debugPrint(
        '[ParlayMobileScreen] Triggering recalculateAllBets on sheet open',
      );

      // Sync scores from events cache first
      _syncScoresFromEventsCache();

      // Then recalculate all bets (odds, min/max stake)
      ref.read(parlayStateProvider.notifier).recalculateAllBets();
    }
  }

  /// Sync scores from events cache to get latest scores
  void _syncScoresFromEventsCache() {
    final parlayState = ref.read(parlayStateProvider);
    final eventsCache = ref.read(eventsProvider).eventCache;

    // Collect all event IDs from single and combo bets
    final eventIds = <int>{};
    for (final bet in parlayState.singleBets) {
      eventIds.add(bet.eventData.eventId);
    }
    for (final bet in parlayState.comboBets) {
      eventIds.add(bet.eventData.eventId);
    }

    if (eventIds.isEmpty) return;

    // Build scores map from events cache
    final scoresMap = <int, ({int home, int away})>{};
    for (final eventId in eventIds) {
      final cachedEvent = eventsCache[eventId];
      if (cachedEvent != null && cachedEvent.score != null) {
        scoresMap[eventId] = (
          home: cachedEvent.score!.home,
          away: cachedEvent.score!.away,
        );
      }
    }

    if (scoresMap.isNotEmpty) {
      debugPrint(
        '[ParlayMobileScreen] Syncing ${scoresMap.length} scores from events cache',
      );
      ref.read(parlayStateProvider.notifier).syncScoresFromCache(scoresMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only watch specific fields needed for this widget's build
    // Using select() to prevent unnecessary rebuilds
    final currentTab = ref.watch(
      parlayStateProvider.select((state) => state.tab),
    );
    final isBettingReady = ref.watch(isBettingReadyProvider);

    // Listen for betting ready (in case it wasn't ready when sheet opened)
    ref.listen<bool>(isBettingReadyProvider, (previous, next) {
      if (next && !_hasTriggeredRecalculate) {
        _hasTriggeredRecalculate = true;
        debugPrint(
          '[ParlayMobileScreen] Triggering recalculateAllBets on betting ready',
        );
        ref.read(parlayStateProvider.notifier).recalculateAllBets();
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Save all bets to storage when bottom sheet closes
          ref.read(parlayStateProvider.notifier).saveAllToStorage();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, AppColorStyles.backgroundSecondary],
            stops: [0, 0.25],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.75),
                    blurRadius: 80,
                    offset: Offset(-20, 4),
                  ),
                ],
              ),
              child: _showSuccessView
                  ? _buildSuccessView()
                  : _showComboSuccessView
                  ? _buildComboSuccessView()
                  : AbsorbPointer(
                      absorbing: _isPlacingBet,
                      child: Column(
                        children: [
                          const ParlayHeader(),
                          const ParlayTabBar(),
                          const Gap(12),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: isBettingReady
                                  ? _buildContent(currentTab)
                                  : _buildShimmerLoading(currentTab),
                            ),
                          ),
                          ParlaySummarySection(
                            isPlacingBetOverride: _isPlacingBet,
                            onPlaceBetPressed: _handlePlaceBet,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle place bet button press
  Future<void> _handlePlaceBet() async {
    debugPrint('[ParlayMobileScreen] _handlePlaceBet called');

    final state = ref.read(parlayStateProvider);

    // Handle based on current tab
    if (state.tab == ParlayTab.combo) {
      await _handlePlaceComboBet();
      return;
    }

    // Handle single bets
    final betsToPlace = state.singleBets
        .where((bet) => bet.canPlaceBet)
        .toList();

    if (betsToPlace.isEmpty) {
      debugPrint('[ParlayMobileScreen] No valid bets to place');
      return;
    }

    // Set loading state
    setState(() {
      _isPlacingBet = true;
    });

    try {
      // Call API to place all bets in parallel
      // final result = await ref
      //     .read(parlayStateProvider.notifier)
      //     .placeAllSingleBetsParallel();

      if (!mounted) return;

      // if (result.hasSuccessfulBets) {
      if (true) {
        // Show toast with total stake
        // final formattedStake = _formatCurrency(result.totalStake);
        // AppToast.showSuccess(
        //   context,
        //   message:
        //       'Cược đơn của bạn trị giá \$$formattedStake đã được đặt thành công',
        // );

        // Close the bottom sheet after successful bet placement
        // debugPrint(
        //   '[ParlayMobileScreen] ${result.successCount} bets placed successfully, closing sheet',
        // );
        setState(() {
          _isPlacingBet = false;
        });

        // Close the parlay sheet
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // All bets failed
        debugPrint('[ParlayMobileScreen] All bets failed');
        setState(() {
          _isPlacingBet = false;
        });
        if (mounted) {
          // AppToast.showError(
          //   context,
          //   message: result.firstErrorMessage ??
          //       'Đặt cược thất bại. Vui lòng thử lại!',
          // );
        }
      }

      // Log any failed bets
      // if (result.hasFailedBets) {
      //   debugPrint(
      //     '[ParlayMobileScreen] ${result.failedCount} bets failed and remain in list',
      //   );
      // }
    } catch (e) {
      debugPrint('[ParlayMobileScreen] Place bet error: $e');
      if (!mounted) return;
      setState(() {
        _isPlacingBet = false;
      });
      AppToast.showError(
        context,
        message: bettingApiPlaceBetFailureFallback,
      );
    }
  }

  /// Format currency for display
  /// Input is in VND (actual currency amount)
  /// e.g., 20000000 -> "20,000,000 đ"
  String _formatCurrency(int amountInVnd) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amountInVnd)}';
  }

  /// Handle place combo bet button press
  Future<void> _handlePlaceComboBet() async {
    debugPrint('[ParlayMobileScreen] _handlePlaceComboBet called');

    final state = ref.read(parlayStateProvider);
    final comboBets = List<SingleBetData>.from(state.comboBets);

    if (comboBets.isEmpty) {
      return;
    }

    // Validate can place bet
    if (!state.canPlaceBet) {
      debugPrint(
        '[ParlayMobileScreen] Cannot place combo bet - validation failed',
      );
      return;
    }

    // Set loading state
    setState(() {
      _isPlacingBet = true;
    });

    try {
      // Call API to place parlay bet
      final success = await ref
          .read(parlayStateProvider.notifier)
          .placeComboParlay();

      if (!mounted) return;

      if (success) {
        // Show toast with stake amount
        final formattedStake = _formatCurrency(state.stake);
        AppToast.showSuccess(
          context,
          message:
              'Cược Xiên của bạn trị giá \$$formattedStake đã được đặt thành công',
        );

        // Close the bottom sheet after successful bet placement
        debugPrint(
          '[ParlayMobileScreen] Combo bet placed successfully, closing sheet',
        );
        setState(() {
          _isPlacingBet = false;
        });

        // Close the parlay sheet
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // API call failed
        debugPrint('[ParlayMobileScreen] Combo bet placement failed');
        setState(() {
          _isPlacingBet = false;
        });

        // Error message will be shown by the provider listener in ParlaySummarySection
        // But also show toast for immediate feedback
        final error = ref.read(parlayErrorProvider);
        if (mounted) {
          AppToast.showError(
            context,
            message: error ?? bettingApiParlayComboFailureFallback,
          );
        }
      }
    } catch (e) {
      debugPrint('[ParlayMobileScreen] Place combo bet error: $e');
      if (!mounted) return;
      setState(() {
        _isPlacingBet = false;
      });
      AppToast.showError(
        context,
        message: bettingApiParlayComboFailureFallback,
      );
    }
  }

  /// Build success view after bet placement (single bets)
  Widget _buildSuccessView() => BetSuccessView(
    successfulBets: _successfulBets,
    onClose: _handleCloseSuccess,
    onViewMyBets: _handleViewMyBets,
    onRemoveBet: _handleRemoveSuccessBet,
    onReuseBets: _handleReuseBets,
    onClearAll: _handleClearAll,
  );

  /// Build combo success view after combo bet placement
  Widget _buildComboSuccessView() => ComboSuccessView(
    comboBetData: _comboBetSuccessData!,
    onClose: _handleCloseComboSuccess,
    onViewMyBets: _handleViewMyBetsCombo,
    onReuseBet: _handleReuseComboBet,
    onClearAll: _handleClearAllCombo,
  );

  /// Handle close success view
  void _handleCloseSuccess() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    // Successful bets are already removed from state by placeAllSingleBetsParallel
    Navigator.of(context).pop();
  }

  /// Handle "Xem cược của tôi" button
  void _handleViewMyBets() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    // Successful bets are already removed from state by placeAllSingleBetsParallel
    Navigator.of(context).pop();
    // TODO: Navigate to my bets screen
  }

  /// Handle removing a bet from success view
  void _handleRemoveSuccessBet(int index) {
    setState(() {
      _successfulBets = List.from(_successfulBets)..removeAt(index);
      if (_successfulBets.isEmpty) {
        _showSuccessView = false;
      }
    });
  }

  /// Handle "Dùng lại phiếu" - reuse the same bets
  void _handleReuseBets() {
    // Re-add successful bets back to provider with reset stake
    for (final bet in _successfulBets) {
      ref
          .read(parlayStateProvider.notifier)
          .addSingleBetDirect(
            bet.copyWith(stake: 0), // Reset stake to 0
          );
    }
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
  }

  /// Handle "Xóa hết" - clear all successful bets (just close, bets already removed)
  void _handleClearAll() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    // Successful bets are already removed, also clear any remaining failed bets
    ref.read(parlayStateProvider.notifier).clearAllSingleBets();
  }

  // ===== COMBO SUCCESS HANDLERS =====

  /// Handle close combo success view
  void _handleCloseComboSuccess() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    // Combo bets already cleared by provider on success
    Navigator.of(context).pop();
  }

  /// Handle "Xem cược của tôi" button in combo success view
  void _handleViewMyBetsCombo() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    // Combo bets already cleared by provider on success
    Navigator.of(context).pop();
    // TODO: Navigate to my bets screen
  }

  /// Handle "Dùng lại phiếu" - reuse the same combo bet
  void _handleReuseComboBet() {
    // Re-add combo bets back to provider with reset stake
    // (bets were cleared on success, so we need to re-add them)
    if (_comboBetSuccessData != null) {
      final notifier = ref.read(parlayStateProvider.notifier);
      for (final bet in _comboBetSuccessData!.selections) {
        notifier.addComboBetDirect(bet);
      }
      // Reset stake and recalculate
      notifier.clearStake();
      // Recalculate parlay limits
      notifier.calculateComboParlay();
    }
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
  }

  /// Handle "Xóa hết" - clear all combo bets (already cleared on success)
  void _handleClearAllCombo() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    // Combo bets already cleared by provider on success
  }

  /// Build actual content when betting is ready
  Widget _buildContent(ParlayTab tab) => switch (tab) {
    ParlayTab.single => const Column(children: [ParlayMatchCard(), Gap(24)]),
    ParlayTab.combo => const Column(children: [ParlayStakeSection(), Gap(24)]),
    ParlayTab.multi => const Column(children: [ParlayMultiSection(), Gap(24)]),
  };

  /// Build shimmer loading while waiting for token and websocket
  Widget _buildShimmerLoading(ParlayTab tab) => switch (tab) {
    ParlayTab.single => const Column(
      children: [
        ParlayShimmerLoading(cardCount: 2, type: ParlayShimmerType.single),
        Gap(24),
      ],
    ),
    ParlayTab.combo => const Column(
      children: [
        ParlayShimmerLoading(type: ParlayShimmerType.combo),
        Gap(24),
      ],
    ),
    ParlayTab.multi => const Column(
      children: [
        ParlayShimmerLoading(cardCount: 2, type: ParlayShimmerType.single),
        Gap(24),
      ],
    ),
  };
}
