import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/enums/bottom_navigation_item.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class SportTabletBottomNavigation extends ConsumerStatefulWidget {
  final int selectedIndex;
  final bool isMobile;
  final ValueChanged<int>? onItemSelected;

  const SportTabletBottomNavigation({
    super.key,
    this.selectedIndex =
        3, // Default to "Thể thao" (BottomNavigationItem.sports)
    this.onItemSelected,
    this.isMobile = false,
  });

  @override
  ConsumerState<SportTabletBottomNavigation> createState() =>
      _SportTabletBottomNavigationState();
}

class _SportTabletBottomNavigationState
    extends ConsumerState<SportTabletBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  int _currentIndex = 3;
  double _lastContainerWidth = 0.0; // Track width changes for resize detection
  static const double _containerWidth = 477.0;
  static const double _horizontalPadding = 8.0;
  static const int _itemCount = 5;

  double _getContainerWidth(BuildContext context) {
    if (widget.isMobile) {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth;
    }
    return _containerWidth;
  }

  double _getContentWidth(BuildContext context) {
    return _getContainerWidth(context) - (_horizontalPadding * 2);
  }

  double _getItemWidth(BuildContext context) {
    return _getContentWidth(context) / _itemCount;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _animationController = AnimationController(
      vsync: this,
      // Tối ưu duration cho mobile - ngắn hơn một chút để responsive hơn
      duration: widget.isMobile
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 300),
    );
    // Initialize with a default value, will be updated in build
    _positionAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        // Sử dụng curve mượt hơn cho mobile
        curve: widget.isMobile ? Curves.fastOutSlowIn : Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(SportTabletBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync selectedIndex from parent (e.g., when switching between tablet/mobile)
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex != _currentIndex) {
      // Parent changed selectedIndex - sync it
      setState(() {
        _currentIndex = widget.selectedIndex;
      });
    }

    // Update animation duration if isMobile flag changed
    if (widget.isMobile != oldWidget.isMobile) {
      _animationController.duration = widget.isMobile
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 300);
    }
  }

  void _updateAnimation(int fromIndex, int toIndex, BuildContext context) {
    if (!mounted) return;
    final startPosition = _getItemPosition(fromIndex, context);
    final targetPosition = _getItemPosition(toIndex, context);
    _positionAnimation =
        Tween<double>(begin: startPosition, end: targetPosition).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _handleItemTap(int index, BuildContext context) {
    if (!ref.watch(isAuthenticatedProvider) &&
        index == BottomNavigationItem.bettingTickets.tabIndex) {
      AppToast.showError(
        context,
        message: 'Vui lòng đăng nhập để thực hiện hành động này',
      );
      return;
    }
    // Betting tickets and menu only trigger action, don't change selection
    final tappedItem = BottomNavigationItem.all[index];
    if (tappedItem == BottomNavigationItem.bettingTickets ||
        tappedItem == BottomNavigationItem.menu) {
      widget.onItemSelected?.call(index);
      return;
    }

    if (index != _currentIndex) {
      final previousIndex = _currentIndex;
      setState(() {
        _currentIndex = index;
        _updateAnimation(previousIndex, index, context);
        _animationController.reset();
        _animationController.forward();
      });
      widget.onItemSelected?.call(index);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getItemPosition(int index, BuildContext context) {
    return _horizontalPadding + (index * _getItemWidth(context));
  }

  List<_NavItemData> _buildNavItems(int betTicketCount) =>
      BottomNavigationItem.all.map((item) {
        // Show badge only for betting tickets when count > 0
        String? badge;
        if (item == BottomNavigationItem.bettingTickets && betTicketCount > 0) {
          badge = betTicketCount > 99 ? '99+' : betTicketCount.toString();
        }
        return _NavItemData(
          icon: item.iconPath,
          iconSelected: item.iconSelectedPath,
          label: item.label,
          badge: badge,
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    // Watch bet counts to show badge on betting tickets
    final singleBetsCount = ref.watch(singleBetsCountProvider);
    final comboBetsCount = ref.watch(comboBetsCountProvider);
    final minMatches = ref.watch(minMatchesProvider);
    // Combo only counts as 1 valid ticket if it has enough matches
    final hasValidCombo = comboBetsCount >= minMatches;
    final totalBetCount = singleBetsCount + (hasValidCombo ? 1 : 0);
    final navItems = _buildNavItems(totalBetCount);

    final containerWidth = _getContainerWidth(context);
    final itemWidth = _getItemWidth(context);
    final currentPosition = _getItemPosition(_currentIndex, context);

    // Detect width change (responsive resize) and sync animation immediately
    if (_lastContainerWidth != 0.0 && _lastContainerWidth != containerWidth) {
      // Width changed - force sync animation to new position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            // Update animation to reflect new position based on new width
            _positionAnimation = Tween<double>(
              begin: currentPosition,
              end: currentPosition,
            ).animate(_animationController);
            // Set animation to completed state (value = 1.0) to show at end position
            _animationController.value = 1.0;
          });
        }
      });
    }
    _lastContainerWidth = containerWidth;

    return Container(
      margin: !widget.isMobile ? const EdgeInsets.only(bottom: 16) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: containerWidth,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.77327],
          colors: [Color(0xFF1A1A17), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(widget.isMobile ? 0 : 16),
          bottomRight: Radius.circular(widget.isMobile ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withOpacity(0.12),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Animated SVG indicators
            // Sử dụng child parameter để cache SVG widgets và tránh rebuild mỗi frame
            AnimatedBuilder(
              animation: _positionAnimation,
              child: RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.bottomNavSelected,
                  fit: BoxFit.contain,
                ),
              ),
              builder: (context, cachedSvg) {
                // Use animation value when animating, otherwise use calculated position
                // This ensures sync during resize
                final position = _animationController.isAnimating
                    ? _positionAnimation.value
                    : currentPosition;
                return Positioned(
                  left: position - 5,
                  width: itemWidth,
                  top: (PlatformUtils.isMobile) ? -5 : 0,
                  bottom: 0,
                  child: cachedSvg!,
                );
              },
            ),
            AnimatedBuilder(
              animation: _positionAnimation,
              child: RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.bottomNavGlow,
                  fit: BoxFit.fill,
                ),
              ),
              builder: (context, cachedGlow) {
                // Use animation value when animating, otherwise use calculated position
                // This ensures sync during resize
                final position = _animationController.isAnimating
                    ? _positionAnimation.value
                    : currentPosition;
                return Positioned(
                  left: position - 50,
                  width: itemWidth + (_currentIndex != 4 ? 100 : 50),
                  top: PlatformUtils.isMobile ? -1.5 : 0,
                  bottom: 0,
                  child: cachedGlow!,
                );
              },
            ),
            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final _NavItemData item = entry.value;
                // Add GlobalKey to betting tickets icon (index 4)
                final isBetSlipIcon =
                    index == BottomNavigationItem.bettingTickets.tabIndex;
                final isSelected = _currentIndex == index;
                final navItem = _BottomNavItem(
                  key: ValueKey('nav_${index}_$isSelected'),
                  icon: item.icon,
                  iconSelected: item.iconSelected,
                  label: item.label,
                  isSelected: isSelected,
                  badge: item.badge,
                  onTap: () => _handleItemTap(index, context),
                );
                // Wrap bet slip icon with key for flying animation target
                if (isBetSlipIcon) {
                  return KeyedSubtree(
                    key: FlyingBetController.instance.betSlipIconKey,
                    child: navItem,
                  );
                }
                return navItem;
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String icon;
  final String iconSelected;
  final String label;
  final String? badge;

  const _NavItemData({
    required this.icon,
    required this.iconSelected,
    required this.label,
    this.badge,
  });
}

class _BottomNavItem extends StatelessWidget {
  final String icon;
  final String iconSelected;
  final String label;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _BottomNavItem({
    super.key,
    required this.icon,
    required this.iconSelected,
    required this.label,
    this.isSelected = false,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? const Color(0xFFFFD791)
        : const Color(0xFFAAA49B);
    // final iconColor = isSelected && isSport
    //     ? const Color(0xFFFFD791)
    //     : const Color(0xFFAAA49B);
    final iconPath = isSelected ? iconSelected : icon;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: ImageHelper.load(
                      path: iconPath,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Badge indicator
                  if (badge != null)
                    Positioned(
                      right: -12,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 14,
                        ),
                        child: Text(
                          badge!,
                          style: AppTextStyles.labelXXSmall(
                            color: AppColors.gray950,
                          ).copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelXSmall(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
