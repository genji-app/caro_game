import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/inset_shadow/inset_shadow.dart'
    as inset;

/// Widget chuyên dụng để kích hoạt trạng thái đóng/mở Profile module một cách adaptive.
typedef ProfileNavigationBuilder = AdaptiveOverlayBuilder;

/// Alias for [AdaptiveOverlayNavigator] specific to the Profile module.
typedef ProfileNavigator = AdaptiveOverlayNavigator;

/// A profile-specific widget that provides adaptive navigation capabilities.
///
/// It uses a bottom sheet on mobile and a side overlay on desktop/tablet.
/// It leverages [AdaptiveOverlayNavigation] which internally provides
/// an [AdaptiveOverlayNavigator] to its descendants.
class ProfileNavigation extends StatelessWidget {
  const ProfileNavigation({
    required this.controller,
    this.navigatorKey,
    this.child,
    this.initialRoute,
    this.onGenerateRoute,
    super.key,
  });

  /// The controller that manages the visibility of the overlay.
  final AdaptiveOverlayController controller;

  /// The key used to access the internal [NavigatorState].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The main content of the app behind the overlay.
  final Widget? child;

  /// {@macro flutter.widgets.navigator.initialRoute}
  final String? initialRoute;

  /// {@macro flutter.widgets.navigator.onGenerateRoute}
  final RouteFactory? onGenerateRoute;

  /// Retrieves the [ProfileNavigator] from the nearest ancestor.
  static ProfileNavigator of(BuildContext context) {
    return AdaptiveOverlayNavigator.of(context);
  }

  /// Retrieves the [ProfileNavigator] from the nearest ancestor, if it exists.
  static ProfileNavigator? maybeOf(BuildContext context) {
    return AdaptiveOverlayNavigator.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveOverlayNavigation(
      controller: controller,
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      overlayBuilder: _buildAdaptiveOverlay,
      child: child,
    );
  }

  Widget _buildAdaptiveOverlay(BuildContext context, Widget materialApp) {
    if (ResponsiveBuilder.isMobile(context)) {
      return _buildMobileOverlay(materialApp);
    }
    return _buildDesktopOverlay(materialApp);
  }

  Widget _buildMobileOverlay(Widget child) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(24));

    return Container(
      margin: const EdgeInsets.only(top: 1.5),
      decoration: inset.BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: _shadows,
        border: const Border(top: _borderSide),
      ),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }

  Widget _buildDesktopOverlay(Widget child) {
    const borderRadius = BorderRadiusDirectional.only(
      topStart: Radius.circular(24),
    );

    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: 64),
        decoration: inset.BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: _shadows,
          color: AppColorStyles.backgroundSecondary,
          border: const Border(left: _borderSide, top: _borderSide),
        ),
        child: ClipRRect(borderRadius: borderRadius, child: child),
      ),
    );
  }

  // Standard shadows for our design system
  static final _shadows = [
    inset.BoxShadow(
      color: Colors.black.withValues(alpha: 0.75),
      offset: const Offset(-20, 4),
      blurRadius: 80,
    ),
    inset.BoxShadow(
      color: Colors.white.withValues(alpha: 0.12),
      offset: const Offset(0, 0.5),
      blurRadius: 0.5,
      inset: true,
    ),
  ];

  static const _borderSide = BorderSide(
    color: AppColorStyles.borderPrimary,
    width: 1.5,
  );
}

/// Extension on [BuildContext] to provide a clean API for Profile module interactions.
extension ProfileContextX on BuildContext {
  /// Truy cập ProfileNavigator từ context.
  ProfileNavigator get profileNavigator => ProfileNavigation.of(this);

  /// Opens the profile using the adaptive strategy (BottomSheet on mobile, Overlay on desktop).
  void openProfile() => profileNavigator.open();

  /// Closes the profile (dismisses BottomSheet or hides Overlay).
  void closeProfile() => profileNavigator.close();

  /// Toggles the profile visibility.
  void toggleProfile() => profileNavigator.toggle();
}
