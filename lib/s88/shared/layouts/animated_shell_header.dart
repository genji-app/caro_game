import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_hide_provider.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_mobile_v2_provider.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_header.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_mobile_header.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_tablet_header.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

/// Pages that have been migrated to use the overlay header.
const migratedHeaderContentTypes = {
  MainContentType.home,
  MainContentType.casino,
  MainContentType.sportDetail,
  MainContentType.betDetail,
  MainContentType.tournaments,
  MainContentType.live,
  MainContentType.upcoming,
  MainContentType.leagueDetail,
};

/// Computes the back action for the overlay header based on current content
/// type.
///
/// **Riverpod pitfall** — the returned callbacks mutate providers that this
/// provider `watch`es (mainContentProvider, previousContentProvider). Once a
/// watched dependency changes, calling `ref.*` again before the provider
/// rebuilds trips Riverpod's `_didChangeDependency` assertion and crashes.
///
/// Every branch below therefore:
///   1. Resolves every required notifier/value via `ref.*` up front, while
///      the provider is still rebuilding (safe zone).
///   2. Returns a closure that only uses the cached locals — no `ref.*`
///      calls happen after the first state mutation.
final _headerBackActionProvider = Provider<VoidCallback?>((ref) {
  final contentType = ref.watch(mainContentProvider);

  switch (contentType) {
    case MainContentType.sportDetail:
      final previous = ref.read(previousContentProvider);
      final mainNotifier = ref.read(mainContentProvider.notifier);
      return () {
        if (previous == MainContentType.home) {
          mainNotifier.goToHome();
        } else {
          mainNotifier.goToSport();
        }
      };
    case MainContentType.betDetail:
      final betDetailNotifier = ref.read(betDetailMobileV2Provider.notifier);
      final mainNotifier = ref.read(mainContentProvider.notifier);
      return () {
        betDetailNotifier.clear();
        mainNotifier.goBackFromBetDetail();
      };
    case MainContentType.leagueDetail:
      final previous = ref.watch(previousContentProvider);
      if (previous == null) return null;
      final mainNotifier = ref.read(mainContentProvider.notifier);
      final previousNotifier = ref.read(previousContentProvider.notifier);
      return () {
        previousNotifier.state = null;
        mainNotifier.switchTo(previous);
      };
    default:
      return null;
  }
});

/// Header that slides up/down based on scroll progress.
///
/// **Layout strategy (Option A):**
/// The outer [SizedBox] height is **fixed** at [ScrollHideNotifier.headerHeight].
/// Hiding is done via [Transform.translate] — which only triggers a repaint,
/// not a relayout. This avoids the layout thrash that would occur if the
/// parent had to rebalance its children every frame.
///
/// Usage: sit this widget inside a [Stack] as a `Positioned(top: 0, ...)`
/// overlay. The shell content underneath receives a matching animated top
/// padding (see `_ShellContentWithHeaderSpacer` in `main_shell_layout.dart`)
/// so the content grows/shrinks in lock-step with the header — no gap is ever
/// left between the residual header and the content.
class AnimatedShellHeader extends ConsumerWidget {
  const AnimatedShellHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);

    // Non-migrated pages: no header
    if (!migratedHeaderContentTypes.contains(contentType)) {
      return const SizedBox.shrink();
    }

    final scrollHide = ref.watch(scrollHideProvider);

    return RepaintBoundary(
      child: SizedBox(
        // Fixed height — Transform.translate below handles the slide, so the
        // parent never sees the size change during scroll.
        height: ScrollHideNotifier.headerHeight,
        child: ClipRect(
          child: ValueListenableBuilder<double>(
            valueListenable: scrollHide.progress,
            builder: (context, progress, child) => Transform.translate(
              // progress 0 → offset 0 (fully visible)
              // progress 1 → offset -maxOffset (only minVisibleHeight left)
              offset: Offset(0, -progress * ScrollHideNotifier.maxOffset),
              child: child,
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final content = ref.watch(mainContentProvider);
                switch (content) {
                  case MainContentType.home:
                  case MainContentType.casino:
                  case MainContentType.tournaments:
                  case MainContentType.live:
                  case MainContentType.upcoming:
                    return ResponsiveBuilder.isMobile(context)
                        ? const ShellMobileHeader()
                        : const ShellTabletHeader();
                  case MainContentType.leagueDetail:
                    final onBackPressed = ref.watch(_headerBackActionProvider);
                    if (onBackPressed != null) {
                      return SportDetailMobileHeader(
                        onBackPressed: onBackPressed,
                      );
                    }
                    return ResponsiveBuilder.isMobile(context)
                        ? const ShellMobileHeader()
                        : const ShellTabletHeader();
                  case MainContentType.sportDetail:
                  case MainContentType.betDetail:
                    final onBackPressed = ref.watch(_headerBackActionProvider);
                    return SportDetailMobileHeader(
                      onBackPressed: onBackPressed,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
