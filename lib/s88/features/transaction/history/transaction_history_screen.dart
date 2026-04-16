import 'dart:async';

import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/pagination/pagination.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/transaction/transaction.dart';
import 'package:co_caro_flame/s88/shared/animations/animations.dart';
import 'package:co_caro_flame/s88/shared/listener/listener.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/slivers/slivers.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtDepositAndWithdrawalHistory),
      bodyPadding: EdgeInsets.zero,
      body: Consumer(
        builder: (context, ref, _) {
          final canLoadMore = ref.watch(
            transactionHistoryProvider.select((s) => s.canLoadMore),
          );
          final notifier = ref.read(transactionHistoryProvider.notifier);

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              notifier.refresh();
            },
            child: LoadMoreListener(
              onLoadMore: notifier.loadMore,
              listen: canLoadMore,
              child: const _TransactionHistoryContent(),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionHistoryContent extends ConsumerWidget {
  const _TransactionHistoryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: Gap(20)),
        Consumer(
          builder: (context, ref, _) {
            final data = ref.watch(
              transactionHistoryProvider.select((s) => s.data),
            );
            return DateGroupedSliverList(
              data ?? [],
              onItemPressed: (t) {
                Navigator.of(context).push(TransactionDetailsScreen.route(t));
              },
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final status = ref.watch(
              transactionHistoryProvider.select((s) => s.status),
            );
            final notifier = ref.read(transactionHistoryProvider.notifier);

            return switch (status) {
              PaginatedStatus.loading => const SliverLoadingIndicator(),
              PaginatedStatus.loadingMore => const SliverLoadingIndicator(),
              PaginatedStatus.noData => _SliverNoTransactionData(
                onDepositPressed: () => _handleDepositPressed(context, ref),
              ),
              PaginatedStatus.error => SliverFillLoadingError(
                message: Text(
                  notifier.error?.toString() ?? I18n.msgSomethingWentWrong,
                ),
                onRetry: notifier.loadInitial,
              ),
              _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
            };
          },
        ),
        const SliverBottomPadding(),
      ],
    );
  }

  void _handleDepositPressed(BuildContext context, WidgetRef ref) {
    // Fetch deposit data (banks, codepay, etc.) when clicking Nạp
    // Invalidate and trigger fetch immediately
    ref.invalidate(configDepositProvider);
    // Trigger fetch by reading the future
    unawaited(ref.read(configDepositProvider.future));

    final deviceType = ResponsiveBuilder.getDeviceType(context);
    if (deviceType == DeviceType.mobile) {
      // Mobile: Show bottom sheet
      DepositMobileBottomSheet.show(context);
    } else {
      // Close ProfileOverlay and show DepositOverlay
      ProfileNavigation.of(context).close();
      ref.read(depositOverlayVisibleProvider.notifier).state = true;
    }
  }
}

class _SliverNoTransactionData extends StatelessWidget {
  const _SliverNoTransactionData({this.onDepositPressed});

  final VoidCallback? onDepositPressed;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      // hasScrollBody: false,
      child: ImmediateOpacityAnimation(
        duration: Durations.short4,
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 160,
                child: ImageHelper.load(
                  path: AppImages.imgTransactionEmpty,
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(48),
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
                child: const Text(I18n.msgNoTransaction),
              ),
              const Gap(16),
              ShineButton(
                style: ShineButtonStyle.primaryYellow,
                text: I18n.msgDepositNow,
                onPressed: onDepositPressed,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
