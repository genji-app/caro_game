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

/// Computes the back action for the overlay header based on current content type.
final _headerBackActionProvider = Provider<VoidCallback?>((ref) {
  final contentType = ref.watch(mainContentProvider);

  switch (contentType) {
    case MainContentType.sportDetail:
      return () {
        final previous = ref.read(previousContentProvider);
        if (previous == MainContentType.home) {
          ref.read(mainContentProvider.notifier).goToHome();
        } else {
          ref.read(mainContentProvider.notifier).goToSport();
        }
        // ref.read(previousContentProvider.notifier).state = null;
      };
    case MainContentType.betDetail:
      return () {
        ref.read(betDetailMobileV2Provider.notifier).clear();
        ref.read(mainContentProvider.notifier).goBackFromBetDetail();
      };
    case MainContentType.leagueDetail:
      final previous = ref.watch(previousContentProvider);
      if (previous == null) return null;
      return () {
        ref.read(mainContentProvider.notifier).switchTo(previous);
        ref.read(previousContentProvider.notifier).state = null;
      };
    default:
      return null;
  }
});

/// Header that slides up/down based on scroll progress.
///
/// Height changes dynamically: 68px (fully visible) → 6px (mostly hidden).
/// Sits in a Column above the content area, so pinned SliverPersistentHeaders
/// in the content always pin just below the header's visible bottom edge.
///
/// Uses OverflowBox + ClipRect: the header content is always 68px tall,
/// but the outer container shrinks. ClipRect clips the overflow, showing
/// only the bottom portion of the header (slide-up effect).
class AnimatedShellHeader extends ConsumerWidget {
  const AnimatedShellHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);

    // Non-migrated pages: no header, 0px in Column
    if (!migratedHeaderContentTypes.contains(contentType)) {
      return const SizedBox.shrink();
    }

    final scrollHide = ref.watch(scrollHideProvider);

    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: scrollHide.progress,
        builder: (context, progress, child) {
          // Visible height shrinks from 68 → 6 as progress goes 0 → 1
          final visibleHeight =
              ScrollHideNotifier.headerHeight -
              progress * ScrollHideNotifier.maxOffset;
          return SizedBox(
            height: visibleHeight,
            child: ClipRect(
              child: OverflowBox(
                minHeight: ScrollHideNotifier.headerHeight,
                maxHeight: ScrollHideNotifier.headerHeight,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
        child: SizedBox(
          height: ScrollHideNotifier.headerHeight,
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
                  return SportDetailMobileHeader(onBackPressed: onBackPressed);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
