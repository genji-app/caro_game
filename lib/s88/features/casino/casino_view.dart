import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';

import 'casino_banners.dart';

/// A unified public component that builds the actual Casino content based on device type and settings.
class CasinoView extends ConsumerStatefulWidget {
  const CasinoView({
    required this.showLiveChat,
    required this.isMobile,
    super.key,
    this.backgroundColor,
    this.padding,
  });

  final bool showLiveChat;
  final bool isMobile;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<CasinoView> createState() => _CasinoViewState();
}

class _CasinoViewState extends ConsumerState<CasinoView> {
  // Height constants for the live chat — must match SportLiveChat requirements.
  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

  final _filterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(mainScrollControllerProvider);
    final isExpanded = ref.watch(liveChatExpandedProvider);
    final liveChatHeight = isExpanded ? _expandedHeight : _collapsedHeight;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Live chat is currently specific to mobile view and requires authentication.
    final canShowChat = widget.showLiveChat && isAuthenticated;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Dismiss keyboard and collapse chat when tapping outside the chat header.
        if (isExpanded) {
          FocusScope.of(context).unfocus();
          ref.read(liveChatExpandedProvider.notifier).state = false;
        }
      },
      child: Container(
        color: widget.backgroundColor,
        padding: widget.padding,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            // Use the shared scroll controller on mobile to sync with shell behavior.
            controller: widget.isMobile ? scrollController : null,
            slivers: [
              // Sticky Live Chat Header (Adaptive visibility)
              if (canShowChat)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyLiveChatDelegate(
                    minHeight: liveChatHeight,
                    maxHeight: liveChatHeight,
                    onStickyChanged: (isSticky) {
                      ref.read(liveChatStickyProvider.notifier).state =
                          isSticky;
                    },
                  ),
                ),

              // Main content body
              SliverList.list(
                children: [
                  Gap(canShowChat ? 12 : 6),
                  CasinoBanners(
                    onSun88Pressed: () {
                      ref.read(mainContentProvider.notifier).goToSport();
                    },
                    onCasinoGamePressed: () {
                      final filterContext = _filterKey.currentContext;
                      if (filterContext != null) {
                        Scrollable.ensureVisible(
                          filterContext,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const Gap(20),
                  GameFilterView(
                    key: _filterKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  Gap(widget.isMobile ? 80 : 96),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A specialized delegate for the sticky Live Chat header.
class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  _StickyLiveChatDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.onStickyChanged,
  });

  final double minHeight;
  final double maxHeight;
  final ValueChanged<bool>? onStickyChanged;
  bool _lastStickyState = false;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // isSticky is true when the header is pinned or the content has scrolled past it.
    final isSticky = overlapsContent || shrinkOffset > 0;

    if (isSticky != _lastStickyState) {
      _lastStickyState = isSticky;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onStickyChanged?.call(isSticky);
      });
    }

    return SizedBox(
      height: maxHeight,
      child: Stack(
        children: [
          const RepaintBoundary(child: SportLiveChat(isMobile: true)),
          // Gradient shadow when pinned to improve visual separation.
          if (isSticky)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        onStickyChanged != oldDelegate.onStickyChanged;
  }
}
