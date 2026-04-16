import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_hide_provider.dart';
import 'package:co_caro_flame/s88/core/providers/slider_drawer_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/app_init_provider.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/deposit_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/web_tablet/withdraw_overlay.dart';
import 'package:co_caro_flame/s88/shared/layouts/animated_shell_header.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_bottom_navigation.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_content_switcher.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_desktop_header.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_desktop_right_sidebar.dart';
// Import content widgets
import 'package:co_caro_flame/s88/shared/layouts/shell_desktop_sidebar.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_rive_loading.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_layout.dart';
import 'package:co_caro_flame/s88/shared/widgets/listeners/kick_event_listener.dart';
import 'package:co_caro_flame/s88/shared/widgets/snackbars/bet_success_snackbar.dart';

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
class _MobileLayout extends ConsumerWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: NotificationListener<ScrollNotification>(
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
                  // [0] Header + Content column
                  // AnimatedShellHeader takes 68px for migrated pages (sportDetail,
                  // betDetail), 0px for others. This ensures pinned
                  // SliverPersistentHeaders in the content pin below the header.
                  const Column(
                    children: [
                      AnimatedShellHeader(),
                      Expanded(child: ShellContentSwitcher(isMobile: true)),
                    ],
                  ),
                  // [1] Bottom Navigation (always at screen bottom)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ShellBottomNavigation(isMobile: true),
                    ),
                  ),
                  // [2] Bet Success Snackbar - positioned above bottom navigation
                  // Phase 1: still uses bottomNavVisibilityProvider for positioning
                  Builder(
                    builder: (context) {
                      final visibility = ref.watch(bottomNavVisibilityProvider);
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
      ),
    );
  }
}
