import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/providers/main_content_provider.dart';
import 'package:sun_sports/core/providers/scroll_controller_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/core/providers/slider_drawer_provider.dart';
import 'package:sun_sports/core/services/providers/app_init_provider.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_overlay.dart';
import 'package:sun_sports/features/profile/profile.dart';
import 'package:sun_sports/features/profile/withdraw/presentation/web_tablet/withdraw_overlay.dart';
import 'package:sun_sports/shared/layouts/animated_shell_header.dart';
import 'package:sun_sports/shared/layouts/shell_bottom_navigation.dart';
import 'package:sun_sports/shared/layouts/shell_content_switcher.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_header.dart';
import 'package:sun_sports/shared/layouts/shell_desktop_right_sidebar.dart';
// Import content widgets
import 'package:sun_sports/shared/layouts/shell_desktop_sidebar.dart';
import 'package:sun_sports/shared/layouts/shell_rive_loading.dart';
import 'package:sun_sports/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';
import 'package:sun_sports/shared/widgets/listeners/kick_event_listener.dart';
import 'package:sun_sports/shared/widgets/snackbars/bet_success_snackbar.dart';

/// Main shell layout cho toàn bộ app
/// - Desktop: 3 cột (sidebar trái, content giữa, chat phải)
/// - Tablet/Mobile: 1 cột với bottom navigation
class MainShellLayout extends ConsumerWidget {
  const MainShellLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(profileOverlayControllerProvider);
    final navigatorKey = ref.watch(profileNavigatorKeyProvider);

    return ProfileNavigation(
      controller: controller,
      navigatorKey: navigatorKey,
      initialRoute: ProfileRouter.root,
      onGenerateRoute: ProfileRouter.onGenerateRoute,
      child: const KickEventListener(
        child: ResponsiveLayout(
          mobile: _MobileLayout(),
          tablet: _MobileLayout(),
          desktop: _DesktopLayout(),
        ),
      ),
    );
  }
}

/// Desktop layout với 3 cột
class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kiểm tra trạng thái khởi tạo app
    final isInitializing = ref.watch(isAppInitializingProvider);

    // Hiển thị shimmer loading khi đang khởi tạo
    if (isInitializing) {
      return const ShellRiveLoading();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: const ShellDesktopHeader(),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF11100F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const Row(
                  children: [
                    // Left sidebar - menu
                    ShellDesktopSidebar(),
                    Gap(AppSpacingStyles.space300),
                    // Center content - thay đổi theo mainContentProvider
                    Expanded(child: ShellContentSwitcher()),
                    Gap(AppSpacingStyles.space300),
                    // Right sidebar - chat & hot section
                    ShellDesktopRightSidebar(),
                  ],
                ),
              ),
              // Specific overlays for Desktop
              const DepositOverlay(),
              const WithdrawOverlay(),
            ],
          ),
        ),
        MyBetPresenter.buildOverlay(context),
      ],
    );
  }
}

/// Tablet layout với bottom navigation
class _TabletLayout extends ConsumerWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kiểm tra trạng thái khởi tạo app
    final isInitializing = ref.watch(isAppInitializingProvider);

    // Hiển thị shimmer loading khi đang khởi tạo
    if (isInitializing) {
      return const ShellRiveLoading();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: const ShellDesktopHeader(),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF11100F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const Row(
                  children: [
                    Gap(AppSpacingStyles.space300),
                    Expanded(child: ShellContentSwitcher(isTablet: true)),
                    Gap(AppSpacingStyles.space300),
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ShellBottomNavigation(),
                ),
              ),
              // Specific overlays for Tablet
              const DepositOverlay(),
              const WithdrawOverlay(),
            ],
          ),
        ),
        MyBetPresenter.buildOverlay(context),
      ],
    );
  }
}

/// Mobile layout với bottom navigation
class _MobileLayout extends ConsumerStatefulWidget {
  const _MobileLayout();

  @override
  ConsumerState<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends ConsumerState<_MobileLayout> {
  /// Drives scrim opacity + hit-testing in lock-step with the SliderDrawer's
  /// open/close animation. 0.0 = closed (scrim off), 1.0 = fully open.
  final ValueNotifier<double> _drawerProgress = ValueNotifier<double>(0.0);
  AnimationController? _drawerAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hookDrawerAnim());
  }

  void _hookDrawerAnim() {
    if (!mounted) return;
    final state = ref.read(sliderDrawerKeyProvider).currentState;
    // SliderDrawer chưa build xong (ví dụ lúc đang initializing) → thử lại frame sau.
    if (state == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hookDrawerAnim());
      return;
    }
    _drawerAnim = state.animationController..addListener(_onDrawerAnim);
    _onDrawerAnim();
  }

  void _onDrawerAnim() {
    _drawerProgress.value = _drawerAnim?.value ?? 0.0;
  }

  @override
  void dispose() {
    _drawerAnim?.removeListener(_onDrawerAnim);
    _drawerProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái khởi tạo app
    final isInitializing = ref.watch(isAppInitializingProvider);

    // Hiển thị shimmer loading khi đang khởi tạo (ẩn luôn bottom navigation)
    if (isInitializing) {
      return const ShellRiveLoading();
    }

    final scrollHide = ref.read(scrollHideProvider);

    // Reset header/nav when switching pages
    ref.listen(mainContentProvider, (prev, next) {
      scrollHide.show();
      scrollHide.pauseDetection(const Duration(milliseconds: 500));
    });

    final sliderKey = ref.watch(sliderDrawerKeyProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      bottom: PlatformUtils.isAndroid,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, AppColorStyles.backgroundSecondary],
            stops: [0.01, 0.05],
          ),
        ),
        child: SliderDrawer(
          key: sliderKey,
          appBar: const SizedBox.shrink(),
          slider: const MenuDrawerContent(),
          sliderOpenSize: screenWidth * 0.8,
          animationDuration: 300,
          slideDirection: SlideDirection.leftToRight,
          sliderBoxShadow: SliderBoxShadow(color: Colors.black12),
          backgroundColor: Colors.transparent,
          isDraggable: true,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                // Outer listener: catches ScrollMetricsNotification (content
                // size changes — e.g. market drawers collapsing) which does NOT
                // extend ScrollNotification and therefore bypasses the inner
                // listener.
                body: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (notification) {
                    scrollHide.handleScrollMetricsNotification(notification);
                    return false;
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      scrollHide.handleScrollNotification(notification);
                      // Keep old provider for BetSuccessSnackBar positioning (Phase 1)
                      ref
                          .read(bottomNavVisibilityProvider.notifier)
                          .handleScrollNotification(notification);
                      return false;
                    },
                    child: Stack(
                      children: [
                        // [0] Content area — fills the viewport and receives an
                        // animated top padding (see _ShellContentWithHeaderSpacer)
                        // that shrinks in sync with the overlay header so no gap
                        // is ever left between header residual and content.
                        const Positioned.fill(
                          child: _ShellContentWithHeaderSpacer(),
                        ),
                        // [1] Animated header overlay — sits on top of content,
                        // slides up via Transform.translate when scrolling down.
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedShellHeader(),
                        ),
                        // [2] Bottom Navigation (always at screen bottom)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ShellBottomNavigation(isMobile: true),
                          ),
                        ),
                        // [3] Bet Success Snackbar - positioned above bottom navigation
                        // Phase 1: still uses bottomNavVisibilityProvider for positioning
                        Builder(
                          builder: (context) {
                            final visibility = ref.watch(
                              bottomNavVisibilityProvider,
                            );
                            final isCollapsed =
                                visibility == BottomNavVisibility.collapsed;
                            final bottomOffset = isCollapsed ? 60.0 : 80.0;

                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: 0,
                              right: 0,
                              bottom: bottomOffset,
                              child: const BetSuccessSnackBar(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Scrim: chặn toàn bộ pointer (tap/scroll/drag) lên main content
              // khi drawer đang mở, và đóng drawer khi tap. IgnorePointer tắt
              // hit-testing lúc drawer đóng hoàn toàn để không cản thao tác.
              Positioned.fill(
                child: ValueListenableBuilder<double>(
                  valueListenable: _drawerProgress,
                  builder: (context, progress, _) {
                    final isActive = progress > 0.001;
                    return IgnorePointer(
                      ignoring: !isActive,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            sliderKey.currentState?.closeSlider(),
                        child: ColoredBox(
                          color: Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders [ShellContentSwitcher] with a top padding that **animates in
/// lock-step with the overlay header's slide-up**.
///
///   progress 0.0 → padding = [ScrollHideNotifier.headerHeight] (68px, header fully visible)
///   progress 1.0 → padding = [ScrollHideNotifier.minVisibleHeight] (1px, header hidden)
///
/// The content therefore grows to fill the space freed by the disappearing
/// header — there is no empty gap between the residual header and the start
/// of the content at any progress value.
///
/// This is intentionally a `ValueListenableBuilder` (not `ref.watch` on the
/// notifier) so that only this subtree rebuilds per frame during scroll.
/// The `RepaintBoundary` around the content isolates the paint pass of the
/// slivers from the padding animation.
class _ShellContentWithHeaderSpacer extends ConsumerWidget {
  const _ShellContentWithHeaderSpacer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);
    final hasShellHeader = migratedHeaderContentTypes.contains(contentType);

    // Non-migrated pages: no header → no padding needed, just pass through.
    if (!hasShellHeader) {
      return const ShellContentSwitcher(isMobile: true);
    }

    final scrollHide = ref.watch(scrollHideProvider);

    return ValueListenableBuilder<double>(
      valueListenable: scrollHide.progress,
      builder: (context, progress, child) {
        // Sync with the AnimatedShellHeader's Transform.translate:
        //   headerVisibleHeight = headerHeight - progress * maxOffset
        // The content's top padding equals this visible height so the two
        // edges always meet — no gap, no overlap.
        final paddingTop =
            ScrollHideNotifier.headerHeight -
            progress * ScrollHideNotifier.maxOffset;
        return Padding(
          padding: EdgeInsets.only(top: paddingTop),
          child: child,
        );
      },
      child: const RepaintBoundary(
        child: ShellContentSwitcher(isMobile: true),
      ),
    );
  }
}
