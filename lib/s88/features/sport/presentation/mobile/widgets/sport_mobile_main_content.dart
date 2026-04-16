import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/breakpoints.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/utils/scroll_aware_controller.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/home/presentation/mobile/widgets/home_mobile_welcome_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/sport_mobile_live_matches_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_mobile_header.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_tablet_header.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/authenticated_widget.dart';

class SportMobileMainContent extends StatelessWidget {
  const SportMobileMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorStyles.backgroundPrimary,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification ||
                notification is ScrollUpdateNotification) {
              ScrollAwareController.instance.onScrollStart();
            } else if (notification is ScrollEndNotification) {
              ScrollAwareController.instance.onScrollEnd();
            }
            return false; // Don't stop propagation
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MediaQuery.sizeOf(context).width <= Breakpoints.mobile
                    ? const ShellMobileHeader()
                    : const ShellTabletHeader(),
              ),
              // Live Chat - sticky khi scroll đến top (chỉ rebuild phần này khi provider thay đổi)
              const _LiveChatSliver(),
              // Top gap
              const SliverToBoxAdapter(child: Gap(AppSpacingStyles.space300)),
              // Live matches section - fixed height to avoid SliverFillRemaining + LayoutBuilder intrinsic error
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height - 280,
                    child: SportMobileLiveMatchesSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget riêng cho Live Chat sliver - dùng Consumer để tối ưu rebuild
class _LiveChatSliver extends StatelessWidget {
  const _LiveChatSliver();

  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    // Consumer ngoài chỉ watch auth state
    return Consumer(
      builder: (context, ref, _) {
        final isAuthenticated = ref.watch(
          isAuthenticatedProvider.select((value) => value),
        );

        if (!isAuthenticated) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // Consumer trong chỉ watch expanded state khi đã authenticated
        return Consumer(
          builder: (context, ref, _) {
            final isExpanded = ref.watch(
              liveChatExpandedProvider.select((value) => value),
            );
            final liveChatHeight = isExpanded
                ? _expandedHeight
                : _collapsedHeight;

            return SliverPersistentHeader(
              pinned: true,
              delegate: _StickyLiveChatDelegate(
                minHeight: liveChatHeight,
                maxHeight: liveChatHeight,
              ),
            );
          },
        );
      },
    );
  }
}

/// Delegate cho sticky live chat header
class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _StickyLiveChatDelegate({required this.minHeight, required this.maxHeight});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: Colors.transparent,
    height: maxHeight,
    child: const RepaintBoundary(
      child: AuthenticatedWidget(child: SportLiveChat(isMobile: true)),
    ),
  );

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) =>
      minHeight != oldDelegate.minHeight || maxHeight != oldDelegate.maxHeight;
}
