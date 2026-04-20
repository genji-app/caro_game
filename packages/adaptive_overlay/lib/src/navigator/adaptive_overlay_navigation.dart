import 'package:flutter/material.dart';

import '../overlay/adaptive_overlay.dart';
import '../overlay/adaptive_overlay_controller.dart';
import 'adaptive_overlay_navigator.dart';

/// {@template adaptive_overlay_navigation}
/// A widget that provides navigation capabilities within an adaptive overlay.
///
/// It establishes an [AdaptiveOverlayNavigator] and provides it to the subtree.
/// It also renders the base [MaterialApp] that serves as the internal navigator
/// for the overlay.
/// {@endtemplate}
class AdaptiveOverlayNavigation extends StatefulWidget {
  /// {@macro adaptive_overlay_navigation}
  const AdaptiveOverlayNavigation({
    this.child,
    this.controller,
    this.navigatorKey,
    this.navigator,
    this.overlayBuilder,
    this.overlayConstraints = const BoxConstraints.tightFor(width: 430),
    this.overlayAlignment = Alignment.centerRight,
    this.mobileBreakpoint = 733.0,
    this.pages = const <Page<dynamic>>[],
    this.initialRoute,
    this.onGenerateInitialRoutes = Navigator.defaultGenerateInitialRoutes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.reportsRouteUpdateToEngine = false,
    this.clipBehavior = Clip.hardEdge,
    this.observers = const <NavigatorObserver>[],
    this.requestFocus = true,
    this.restorationScopeId,
    this.routeTraversalEdgeBehavior = kDefaultRouteTraversalEdgeBehavior,
    this.routeDirectionalTraversalEdgeBehavior =
        kDefaultRouteDirectionalTraversalEdgeBehavior,
    this.onDidRemovePage,
    super.key,
  });

  /// The main screen content to be wrapped by this overlay system.
  final Widget? child;

  /// The controller managing the overlay visibility.
  ///
  /// If not provided, it will be looked up from the nearest [InheritedAdaptiveOverlay].
  final AdaptiveOverlayController? controller;

  /// An optional key to use for the internal [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// An optional pre-instantiated navigator to use.
  ///
  /// If provided, [controller] and [navigatorKey] are ignored.
  final AdaptiveOverlayNavigator? navigator;

  /// Size constraints for the side overlay (used on desktop/tablet).
  final BoxConstraints overlayConstraints;

  /// The alignment of the side overlay (used on desktop/tablet).
  final Alignment overlayAlignment;

  /// A builder to wrap or replace the internal [MaterialApp] used for overlay navigation.
  final Widget Function(BuildContext context, Widget materialApp)?
  overlayBuilder;

  /// The width threshold at which the UI switches to mobile mode.
  /// Defaults to 733.0.
  final double mobileBreakpoint;

  /// {@macro flutter.widgets.navigator.pages}
  final List<Page<dynamic>> pages;

  /// {@macro flutter.widgets.navigator.initialRoute}
  final String? initialRoute;

  /// {@macro flutter.widgets.navigator.onGenerateInitialRoutes}
  final List<Route<dynamic>> Function(NavigatorState, String)
  onGenerateInitialRoutes;

  /// {@macro flutter.widgets.navigator.onGenerateRoute}
  final RouteFactory? onGenerateRoute;

  /// {@macro flutter.widgets.navigator.onUnknownRoute}
  final RouteFactory? onUnknownRoute;

  /// {@macro flutter.widgets.navigator.transitionDelegate}
  final TransitionDelegate<dynamic> transitionDelegate;

  /// {@macro flutter.widgets.navigator.reportsRouteUpdateToEngine}
  final bool reportsRouteUpdateToEngine;

  /// {@macro flutter.widgets.navigator.clipBehavior}
  final Clip clipBehavior;

  /// {@macro flutter.widgets.navigator.observers}
  final List<NavigatorObserver> observers;

  /// {@macro flutter.widgets.navigator.requestFocus}
  final bool requestFocus;

  /// {@macro flutter.widgets.navigator.restorationScopeId}
  final String? restorationScopeId;

  /// {@macro flutter.widgets.navigator.routeTraversalEdgeBehavior}
  final TraversalEdgeBehavior routeTraversalEdgeBehavior;

  /// {@macro flutter.widgets.navigator.routeDirectionalTraversalEdgeBehavior}
  final TraversalEdgeBehavior routeDirectionalTraversalEdgeBehavior;

  /// {@macro flutter.widgets.navigator.onDidRemovePage}
  final void Function(Page<Object?>)? onDidRemovePage;

  @override
  State<AdaptiveOverlayNavigation> createState() =>
      _AdaptiveOverlayNavigationState();
}

class _AdaptiveOverlayNavigationState extends State<AdaptiveOverlayNavigation> {
  AdaptiveOverlayController? _controller;
  GlobalKey<NavigatorState>? _navigatorKey;
  Widget? _cachedMaterialApp;
  ThemeData? _cachedTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.navigator != null) {
      _controller = widget.navigator!.controller;
      _navigatorKey = widget.navigator!.navigatorKey;
    } else {
      _controller = widget.controller ?? AdaptiveOverlay.of(context);
      _navigatorKey = widget.navigatorKey;
    }
  }

  Widget _buildNavigatorContent() {
    final parentTheme = Theme.of(context);
    _cachedTheme ??= parentTheme;

    // Use Navigator directly instead of MaterialApp to preserve state
    // when moving between bottom sheet and side overlay
    _cachedMaterialApp ??= Theme(
      data: _cachedTheme!,
      child: Navigator(
        key: _navigatorKey,
        pages: widget.pages,
        initialRoute: widget.initialRoute,
        onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
        onGenerateRoute: widget.onGenerateRoute,
        onUnknownRoute: widget.onUnknownRoute,
        transitionDelegate: widget.transitionDelegate,
        reportsRouteUpdateToEngine: widget.reportsRouteUpdateToEngine,
        clipBehavior: widget.clipBehavior,
        observers: widget.observers,
        requestFocus: widget.requestFocus,
        restorationScopeId: widget.restorationScopeId,
        routeTraversalEdgeBehavior: widget.routeTraversalEdgeBehavior,
        routeDirectionalTraversalEdgeBehavior:
            widget.routeDirectionalTraversalEdgeBehavior,
        onDidRemovePage: widget.onDidRemovePage,
      ),
    );

    return _cachedMaterialApp!;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return AdaptiveOverlayNavigator(
      controller: _controller!,
      navigatorKey: _navigatorKey,
      child: AdaptiveOverlay(
        controller: _controller!,
        overlayConstraints: widget.overlayConstraints,
        overlayAlignment: widget.overlayAlignment,
        mobileBreakpoint: widget.mobileBreakpoint,
        overlayBuilder: (context, controller) {
          // Build the navigator content
          final navigatorContent = _buildNavigatorContent();

          final content = widget.overlayBuilder != null
              ? widget.overlayBuilder!(context, navigatorContent)
              : navigatorContent;

          // Re-inject AdaptiveOverlayNavigator so it's available when
          // displayed as a ModalBottomSheet (different widget tree).
          return AdaptiveOverlayNavigator(
            controller: _controller!,
            navigatorKey: _navigatorKey,
            child: content,
          );
        },
        child: widget.child,
      ),
    );
  }
}
