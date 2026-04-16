import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/pagination/paginated_notifier_mixin.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/shared/widgets/sb_tab_bar.dart';
import 'package:co_caro_flame/s88/shared/widgets/slivers/slivers.dart';

import 'betting_history_provider.dart';

/// Internal content widget that uses the scoped provider
class BettingHistoryView extends ConsumerStatefulWidget {
  const BettingHistoryView({super.key});

  @override
  ConsumerState<BettingHistoryView> createState() => BettingHistoryViewState();
}

class BettingHistoryViewState extends ConsumerState<BettingHistoryView> {
  @override
  void initState() {
    super.initState();

    // Initialize notifier when view mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bettingHistoryProvider.notifier).initialize();
    });
  }

  void _onFilterChanged(MyBetFilter filter) {
    final notifier = ref.read(bettingHistoryProvider.notifier);
    notifier.setFilter(filter);
    notifier.loadInitial();
  }

  Future<bool> _onSellConfirm(BetSlip bet) {
    final resellController = ref.read(betResellControllerProvider)(ref);
    return resellController.startResellFlow(context, bet);
  }

  Future<void> _onItemPressed(BetSlip bet) {
    final route = MaterialPageRoute<void>(
      builder: (_) => BetSlipDetailsScreen(slip: bet),
    );
    return Navigator.of(context).push<void>(route);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async =>
          ref.read(bettingHistoryProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          PinnedHeaderSliver(
            child: BettingHistoryFilterTabbar(onChanged: _onFilterChanged),
          ),
          const SliverToBoxAdapter(child: Gap(20)),

          // Use Consumer + select for list data only
          Consumer(
            builder: (context, ref, _) {
              final data =
                  ref.watch(bettingHistoryProvider.select((s) => s.data)) ?? [];
              return SliverPadding(
                sliver: BettingHistorySliverList(
                  data,
                  onSellConfirm: _onSellConfirm,
                  onItemPressed: _onItemPressed,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              );
            },
          ),

          // Use Consumer + select for status only
          Consumer(
            builder: (context, ref, _) {
              final status = ref.watch(
                bettingHistoryProvider.select((s) => s.status),
              );
              return switch (status) {
                PaginatedStatus.loading => const SliverLoadingIndicator(),
                PaginatedStatus.loadingMore => const SliverLoadingIndicator(),
                PaginatedStatus.noData => const _SliverNoData(),
                PaginatedStatus.error => SliverFillLoadingError(
                  message: const Text(I18n.msgSomethingWentWrong),
                  onRetry: ref
                      .read(bettingHistoryProvider.notifier)
                      .loadInitial,
                ),
                _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
              };
            },
          ),
          const SliverBottomPadding(),
        ],
      ),
    );
  }
}

class BettingHistorySliverList extends StatelessWidget {
  const BettingHistorySliverList(
    this.data, {
    super.key,
    this.onItemPressed,
    this.onSellConfirm,
  });

  final List<BetSlip> data;
  final void Function(BetSlip bet)? onItemPressed;

  /// Callback when user confirms resell, returns true if successful
  final Future<bool> Function(BetSlip bet)? onSellConfirm;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: data.length,
      separatorBuilder: (_, i) => const Gap(20),
      itemBuilder: (context, i) {
        final bet = data[i];

        // Build action button if cashout is available
        final actionButton = bet.isCashoutAvailable
            ? BetSlipResellButton(
                buttonKey: bet.ticketId,
                onConfirm: () =>
                    onSellConfirm?.call(bet) ?? Future.value(false),
                amount: bet.cashOutAbleAmount?.toDouble() ?? 0,
              )
            : null;

        return BetSlipCard(
          bet: bet,
          onPressed: () => onItemPressed?.call(bet),
          actionButton: actionButton,
        );
      },
      // Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }
}

class BettingHistoryFilterTabbar extends StatelessWidget
    implements PreferredSizeWidget {
  const BettingHistoryFilterTabbar({this.onChanged, super.key});

  final ValueChanged<MyBetFilter>? onChanged;

  static final tabs = [
    SBTab(label: I18n.txtCurrentlyActive),
    SBTab(label: I18n.txtPaymentHasBeenMade),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
    // color: AppColorStyles.backgroundSecondary,
    child: SBTabBar(
      initialIndex: 0,
      tabs: tabs,
      onChanged: (int value) {
        final filter = value == 0 ? MyBetFilter.active : MyBetFilter.settled;
        onChanged?.call(filter);
      },
    ),
  );
}

class _SliverNoData extends StatelessWidget {
  const _SliverNoData();

  @override
  Widget build(BuildContext context) {
    return SliverFillInfoMessage(
      primaryMessage: const Text(I18n.msgEmptyBettingSlip),
      secondaryMessage: const Text(I18n.msgStartBettingNow),
      image: SizedBox.square(
        dimension: 160,
        child: ImageHelper.load(
          path: AppImages.imgBetTicket,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
