import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_hide_provider.dart';
import 'package:co_caro_flame/s88/core/providers/slider_drawer_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/enums/bottom_navigation_item.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/preferences/preferences.dart';
import 'package:co_caro_flame/s88/features/profile/profile_router.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/tablet/widgets/sport_tablet_bottom_navigation.dart';
import 'package:co_caro_flame/s88/features/wallet/wallet_balance_view.dart';
import 'package:co_caro_flame/s88/shared/layouts/shell_desktop_sidebar.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/src/profile_navigation.dart';
import 'package:co_caro_flame/s88/shared/widgets/collapsed_betting_ticket.dart';

/// Bottom navigation chung cho tablet/mobile
/// - Mobile: scroll-driven hide/show (Twitter/X style)
/// - Tablet: velocity-based collapse/expand (legacy)
class ShellBottomNavigation extends ConsumerStatefulWidget {
  final bool isMobile;

  const ShellBottomNavigation({super.key, this.isMobile = false});

  @override
  ConsumerState<ShellBottomNavigation> createState() =>
      _ShellBottomNavigationState();
}

class _ShellBottomNavigationState extends ConsumerState<ShellBottomNavigation>
    with SingleTickerProviderStateMixin {
  // Animation controller kept for tablet only
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return _buildMobile(context);
    }
    return _buildTablet(context);
  }

  // === Mobile: scroll-driven progress ===
  Widget _buildMobile(BuildContext context) {
    final scrollHide = ref.watch(scrollHideProvider);
    final currentContent = ref.watch(mainContentProvider);
    final selectedIndex = _getSelectedIndex(currentContent);

    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: scrollHide.progress,
        builder: (context, progress, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Expanded navigation — slide down + fade out
              if (progress < 1.0)
                Transform.translate(
                  offset: Offset(0, progress * 80),
                  child: Opacity(
                    opacity: (1.0 - progress).clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              // Collapsed betting ticket — fade in
              if (progress > 0.3)
                Opacity(
                  opacity: ((progress - 0.3) / 0.7).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CollapsedBettingTicket(
                      onTap: () {
                        ref.read(scrollHideProvider).show();
                        _showParlayBottomSheet(context);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
        child: SportTabletBottomNavigation(
          selectedIndex: selectedIndex,
          isMobile: true,
          onItemSelected: (index) => _handleItemSelected(context, ref, index),
        ),
      ),
    );
  }

  // === Tablet: velocity-based collapse/expand (legacy) ===
  Widget _buildTablet(BuildContext context) {
    final currentContent = ref.watch(mainContentProvider);
    final visibility = ref.watch(bottomNavVisibilityProvider);
    final selectedIndex = _getSelectedIndex(currentContent);

    if (visibility == BottomNavVisibility.collapsed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final isCollapsed = _animationController.value > 0.5;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (!isCollapsed)
              Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scaleX: _scaleAnimation.value,
                  alignment: Alignment.center,
                  child: SportTabletBottomNavigation(
                    selectedIndex: selectedIndex,
                    onItemSelected: (index) {
                      _handleItemSelected(context, ref, index);
                    },
                  ),
                ),
              ),
            if (isCollapsed)
              Opacity(
                opacity: 1.0 - _opacityAnimation.value,
                child: Transform.scale(
                  scale: 1.0 - _scaleAnimation.value,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CollapsedBettingTicket(
                      onTap: () {
                        ref.read(bottomNavVisibilityProvider.notifier).expand();
                        _showParlayBottomSheet(context);
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Map MainContentType to bottom navigation index (position in BottomNavigationItem.all)
  int _getSelectedIndex(MainContentType contentType) {
    switch (contentType) {
      case MainContentType.home:
        return 0;
      case MainContentType.casino:
        return 1;
      case MainContentType.sport:
      case MainContentType.sportDetail:
      case MainContentType.betDetail:
        return 3;
      case MainContentType.tournaments:
        return 0;
      case MainContentType.sun247:
        return 4;
      default:
        return 0;
    }
  }

  /// Handle bottom navigation item selection
  void _handleItemSelected(BuildContext context, WidgetRef ref, int index) {
    final item = BottomNavigationItem.all[index];
    final notifier = ref.read(mainContentProvider.notifier);

    // Pause scroll detection when switching pages
    if (widget.isMobile) {
      ref.read(scrollHideProvider).show();
      ref.read(scrollHideProvider).pauseDetection();
    } else {
      ref.read(bottomNavVisibilityProvider.notifier).pauseDetection();
    }

    switch (item) {
      case BottomNavigationItem.home:
        notifier.goToHome();
        break;
      case BottomNavigationItem.casino:
        notifier.goToCasino();
        break;
      case BottomNavigationItem.sports:
        notifier.goToSport();
        break;
      case BottomNavigationItem.bettingTickets:
        _showParlayBottomSheet(context);
        break;
      case BottomNavigationItem.sun247:
        notifier.goToSun247();
        break;
      case BottomNavigationItem.menu:
        _showMenuDrawer(context);
        break;
    }
  }

  /// Show parlay/bet slip bottom sheet
  void _showParlayBottomSheet(BuildContext context) {
    MyBetPresenter.showAsBottomSheet(
      context,
      onClosePressed: () => Navigator.pop(context),
      appBar: AppBar(title: WalletBalanceView()),
    );
  }

  /// Toggle the slider drawer (mobile only)
  void _showMenuDrawer(BuildContext context) {
    ref.read(sliderDrawerKeyProvider).currentState?.toggle();
  }
}

/// Drawer content hiển thị sidebar menu (used by SliderDrawer)
class MenuDrawerContent extends ConsumerWidget {
  const MenuDrawerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);

    // Auto-close drawer when navigation changes
    ref.listen<MainContentType>(mainContentProvider, (prev, next) {
      if (prev != next) {
        ref.read(sliderDrawerKeyProvider).currentState?.closeSlider();
      }
    });

    return Material(
      color: AppColorStyles.backgroundSecondary,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(mainContentProvider.notifier).goToHome();
                    },
                    child: SizedBox(
                      child: ImageHelper.getNetworkImage(
                        imageUrl: AppImages.logoS88Home,
                        width: 60,
                        height: 56,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildOddStyleButton(context, ref),
                ],
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: ShellDesktopSidebar(
                    isDesktop: false,
                    onItemTap: () {
                      ref
                          .read(sliderDrawerKeyProvider)
                          .currentState
                          ?.closeSlider();
                    },
                    onTopTournamentsTapForMobile: () {
                      ref
                          .read(sliderDrawerKeyProvider)
                          .currentState
                          ?.closeSlider();
                      ref.read(previousContentProvider.notifier).state = ref
                          .read(mainContentProvider);
                      ref.read(mainContentProvider.notifier).goToTournaments();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOddStyleButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(sliderDrawerKeyProvider).currentState?.closeSlider();
        ProfileNavigation.of(context).pushToSettingsAndRemoveUntil();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x33FFFFFF)),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1000),
          child: Stack(
            children: [
              Positioned.fill(
                right: -1,
                child: ImageHelper.load(
                  path: AppIcons.backgroundOddStyle,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Text(
                      'Tỷ lệ cược:',
                      style: AppTextStyles.labelXSmall(
                        color: AppColorStyles.contentTertiary,
                      ),
                    ),
                    const Gap(30),
                    Row(
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final oddsStyle = ref.watch(
                              betPreferencesProvider.select((s) => s.oddsStyle),
                            );
                            return Text(
                              oddsStyle.label,
                              style: AppTextStyles.labelXSmall(
                                color: AppColors.green300,
                              ),
                            );
                          },
                        ),
                        const Gap(8),
                        ImageHelper.load(
                          path: AppIcons.iconSwitch,
                          width: 16,
                          height: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
