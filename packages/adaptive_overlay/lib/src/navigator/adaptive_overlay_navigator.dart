import 'package:flutter/material.dart';

import '../overlay/adaptive_overlay_controller.dart';

/// {@template adaptive_overlay_navigator}
/// A specialized navigator for adaptive overlays that ensures the overlay
/// is visible before performing navigation operations.
///
/// This is an [InheritedWidget] that provides itself to descendants,
/// encapsulating a [GlobalKey<NavigatorState>] and an [AdaptiveOverlayController].
/// {@endtemplate}
class AdaptiveOverlayNavigator extends InheritedWidget {
  /// {@macro adaptive_overlay_navigator}
  AdaptiveOverlayNavigator({
    required this.controller,
    required super.child,
    GlobalKey<NavigatorState>? navigatorKey,
    super.key,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  /// The controller that manages the visibility of the overlay.
  final AdaptiveOverlayController controller;

  /// The key used to access the internal [NavigatorState].
  final GlobalKey<NavigatorState> navigatorKey;

  /// Current visibility status of the overlay.
  bool get isVisible => controller.isVisible;

  /// Returns the name of the current route.
  String? get currentRouteName {
    String? name;
    navigatorKey.currentState?.popUntil((route) {
      name = route.settings.name;
      return true;
    });
    return name;
  }

  /// Returns true if the [routeName] is the current route.
  bool isCurrent(String routeName) => currentRouteName == routeName;

  /// Opens the associated overlay.
  void open() => controller.open();

  /// Closes the associated overlay.
  void close() => controller.close();

  /// Toggles the associated overlay visibility.
  void toggle() => controller.toggle();

  /// Pops the top route from the internal navigator.
  void pop<T>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  /// Ensures the overlay is open before proceeding.
  void _ensureOpen() {
    if (!controller.isVisible) {
      controller.open();
    }
  }

  /// Ensures the overlay is open and the navigator is ready.
  Future<NavigatorState?> _prepareNavigator() async {
    if (!isVisible) {
      _ensureOpen();
      // Small delay to allow overlay animation to start and Navigator to mount
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    // Wait for a frame to ensure the Navigator is initialized and ready
    // if the overlay was just opened.
    await Future<void>.delayed(Duration.zero);

    return navigatorKey.currentState;
  }

  /// Pushes a new [page] onto the internal navigator.
  ///
  /// If the overlay is currently hidden, it will be opened automatically.
  Future<T?> push<T>(Widget page) async {
    final state = await _prepareNavigator();
    return state?.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Pushes a named route onto the internal navigator.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) async {
    final state = await _prepareNavigator();
    return state?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces the current route of the internal navigator by pushing a new [page].
  Future<T?> pushReplacement<T, TO>(Widget page, {TO? result}) async {
    final state = await _prepareNavigator();
    return state?.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  /// Replaces the current route of the internal navigator by pushing a named route.
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    final state = await _prepareNavigator();
    return state?.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Pushes a new [page] and removes all the previous routes until the [predicate] returns true.
  Future<T?> pushAndRemoveUntil<T>(
    Widget page,
    RoutePredicate predicate,
  ) async {
    final state = await _prepareNavigator();
    return state?.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }

  /// Pushes a named route and removes all the previous routes until the [predicate] returns true.
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    final state = await _prepareNavigator();
    return state?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Pops routes until the [predicate] returns true.
  void popUntil(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  /// Tries to pop the current route.
  Future<bool> maybePop<T>([T? result]) async {
    return navigatorKey.currentState?.maybePop<T>(result) ??
        Future.value(false);
  }

  /// Whether the internal navigator can be popped.
  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Retrieves the [AdaptiveOverlayNavigator] from the nearest ancestor.
  static AdaptiveOverlayNavigator of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AdaptiveOverlayNavigator found in context');
    return result!;
  }

  /// Retrieves the [AdaptiveOverlayNavigator] from the nearest ancestor, if it exists.
  static AdaptiveOverlayNavigator? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AdaptiveOverlayNavigator>();
  }

  @override
  bool updateShouldNotify(AdaptiveOverlayNavigator oldWidget) {
    return controller != oldWidget.controller ||
        navigatorKey != oldWidget.navigatorKey;
  }
}

/// Extension on [BuildContext] to provide convenient access to
/// the nearest adaptive overlay components.
extension AdaptiveOverlayNavigatorContextX on BuildContext {
  /// Retrieves the [AdaptiveOverlayController] from the nearest ancestor.
  ///
  /// This will return null if no [InheritedAdaptiveOverlay] is found.
  AdaptiveOverlayController? get adaptiveOverlayController =>
      adaptiveOverlayNavigator?.controller;

  /// Retrieves the [AdaptiveOverlayNavigator] from the nearest ancestor.
  ///
  /// This will return null if no [InheritedAdaptiveOverlayNavigator] is found.
  AdaptiveOverlayNavigator? get adaptiveOverlayNavigator =>
      AdaptiveOverlayNavigator.maybeOf(this);

  /// Opens the nearest adaptive overlay.
  void open() => adaptiveOverlayController?.open();

  /// Closes the nearest adaptive overlay.
  void close() => adaptiveOverlayController?.close();

  /// Toggles the visibility of the nearest adaptive overlay.
  void toggle() => adaptiveOverlayController?.toggle();

  /// Pops the top route from the adaptive overlay navigator.
  void pop<T>([T? result]) => adaptiveOverlayNavigator?.pop<T>(result);

  /// Pushes a new page onto the adaptive overlay navigator.
  Future<T?> push<T>(Widget page) =>
      adaptiveOverlayNavigator?.push<T>(page) ?? Future.value(null);

  /// Pushes a named route onto the adaptive overlay navigator.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      adaptiveOverlayNavigator?.pushNamed<T>(routeName, arguments: arguments) ??
      Future.value(null);

  /// Replaces the current route of the adaptive overlay navigator by pushing a new [page].
  Future<T?> pushReplacement<T, TO>(Widget page, {TO? result}) =>
      adaptiveOverlayNavigator?.pushReplacement<T, TO>(page, result: result) ??
      Future.value(null);

  /// Replaces the current route of the adaptive overlay navigator by pushing a named route.
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) =>
      adaptiveOverlayNavigator?.pushReplacementNamed<T, TO>(
        routeName,
        result: result,
        arguments: arguments,
      ) ??
      Future.value(null);

  /// Pushes a new [page] and removes all the previous routes until the [predicate] returns true.
  Future<T?> pushAndRemoveUntil<T>(Widget page, RoutePredicate predicate) =>
      adaptiveOverlayNavigator?.pushAndRemoveUntil<T>(page, predicate) ??
      Future.value(null);

  /// Pushes a named route and removes all the previous routes until the [predicate] returns true.
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) =>
      adaptiveOverlayNavigator?.pushNamedAndRemoveUntil<T>(
        routeName,
        predicate,
        arguments: arguments,
      ) ??
      Future.value(null);

  /// Pops routes until the [predicate] returns true.
  void popUntil(RoutePredicate predicate) =>
      adaptiveOverlayNavigator?.popUntil(predicate);

  /// Tries to pop the current route.
  Future<bool> maybePop<T>([T? result]) =>
      adaptiveOverlayNavigator?.maybePop<T>(result) ?? Future.value(false);

  /// Whether the internal navigator can be popped.
  bool canPop() => adaptiveOverlayNavigator?.canPop() ?? false;

  /// Returns the name of the current route of the adaptive overlay navigator.
  String? get currentRouteName => adaptiveOverlayNavigator?.currentRouteName;

  /// Returns true if the [routeName] is the current route of the adaptive overlay navigator.
  bool isCurrent(String routeName) =>
      adaptiveOverlayNavigator?.isCurrent(routeName) ?? false;
}
