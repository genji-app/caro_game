import 'package:flutter/material.dart';

import 'adaptive_overlay_controller.dart';
import 'animated_overlay.dart';

/// Private [InheritedWidget] that propagates the [AdaptiveOverlayController]
/// and responsive configuration down the widget tree.
///
/// This is an implementation detail of [AdaptiveOverlay]. Use the static
/// methods on [AdaptiveOverlay] to access the controller and breakpoint.
class _InheritedAdaptiveOverlay extends InheritedWidget {
  const _InheritedAdaptiveOverlay({
    required this.controller,
    required super.child,
    this.mobileBreakpoint = 733.0,
  });

  final AdaptiveOverlayController controller;
  final double mobileBreakpoint;

  @override
  bool updateShouldNotify(_InheritedAdaptiveOverlay oldWidget) {
    return controller != oldWidget.controller ||
        mobileBreakpoint != oldWidget.mobileBreakpoint;
  }
}

/// {@template adaptive_overlay}
/// A widget that manages the display of feature UI in an adaptive way.
///
/// On mobile devices, it displays the content as a Modal Bottom Sheet.
/// On desktop and tablet devices, it displays the content as a side overlay
/// in a [Stack] over the [child].
///
/// It also provides the [controller] and [mobileBreakpoint] to its subtree
/// via an internal [InheritedWidget], accessible through [AdaptiveOverlay.of],
/// [AdaptiveOverlay.maybeOf], [AdaptiveOverlay.isMobile], and
/// [AdaptiveOverlay.breakpointOf].
/// {@endtemplate}
class AdaptiveOverlay extends StatefulWidget {
  /// {@macro adaptive_overlay}
  const AdaptiveOverlay({
    required this.controller,
    super.key,
    this.child,
    this.overlay,
    this.overlayBuilder,
    this.overlayConstraints = const BoxConstraints.tightFor(width: 430),
    this.overlayAlignment = Alignment.centerRight,
    this.mobileBreakpoint = 733.0,
  }) : assert(
         overlay != null || overlayBuilder != null,
         'Either overlay or overlayBuilder must be provided.',
       );

  /// The main screen content to be wrapped by this overlay system.
  final Widget? child;

  /// The controller that manages the visibility state of the overlay.
  final AdaptiveOverlayController controller;

  /// The static content to display in the overlay area.
  final Widget? overlay;

  /// A builder function to lazily create the overlay content.
  final AdaptiveOverlayBuilder? overlayBuilder;

  /// Size constraints for the side overlay (used on desktop/tablet).
  final BoxConstraints overlayConstraints;

  /// The alignment of the side overlay (used on desktop/tablet).
  final Alignment overlayAlignment;

  /// The width threshold at which the UI switches to mobile mode.
  /// Defaults to 733.0.
  final double mobileBreakpoint;

  // ---------------------------------------------------------------------------
  // Static accessors (powered by _InheritedAdaptiveOverlay)
  // ---------------------------------------------------------------------------

  /// Retrieves the [AdaptiveOverlayController] from the nearest
  /// [AdaptiveOverlay] ancestor.
  ///
  /// Throws a [FlutterError] if no [AdaptiveOverlay] is found
  /// in the given [context].
  static AdaptiveOverlayController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveOverlay>();
    if (result != null) {
      return result.controller;
    }
    throw FlutterError(
      'AdaptiveOverlay.of() called with a context that does not '
      'contain an AdaptiveOverlay.\n'
      'No AdaptiveOverlay found in context. This widget must be used '
      'within an AdaptiveOverlay subtree.',
    );
  }

  /// Retrieves the [AdaptiveOverlayController] from the nearest
  /// [AdaptiveOverlay] ancestor, or null if none is found.
  static AdaptiveOverlayController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveOverlay>()
        ?.controller;
  }

  /// Returns the nearest [AdaptiveOverlay]'s breakpoint,
  /// or a default value of 733.0.
  static double breakpointOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveOverlay>()
            ?.mobileBreakpoint ??
        733.0;
  }

  /// Utility to check if the current context is considered "mobile"
  /// based on the injected breakpoint.
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < breakpointOf(context);
  }

  @override
  State<AdaptiveOverlay> createState() => _AdaptiveOverlayState();
}

class _AdaptiveOverlayState extends State<AdaptiveOverlay> {
  late final AnimatedOverlayController _animatedOverlayController;
  bool _isSheetShown = false;
  bool _isMobile = false;

  /// The currently active bottom sheet route, if any.
  ModalBottomSheetRoute<void>? _currentSheetRoute;

  @override
  void initState() {
    super.initState();
    _animatedOverlayController = AnimatedOverlayController();

    if (widget.controller.isVisible) {
      _animatedOverlayController.open();
    }

    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _animatedOverlayController.dispose();
    _currentSheetRoute = null;
    super.dispose();
  }

  void _handleControllerChange() {
    final isVisible = widget.controller.isVisible;

    if (isVisible) {
      _animatedOverlayController.open();
    } else {
      _animatedOverlayController.close();
    }

    if (_isMobile) {
      _syncBottomSheet(isVisible);
    } else {
      setState(() {});
      // Rebuild to ensure side overlay is injected into the Stack if needed
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    return widget.overlayBuilder != null
        ? widget.overlayBuilder!(context, widget.controller)
        : widget.overlay!;
  }

  /// Shows the overlay content as a modal bottom sheet.
  ///
  /// Creates a [ModalBottomSheetRoute] manually and returns [route.completed]
  /// instead of [route.popped]. This is critical because:
  /// - [route.popped] completes immediately when pop() is called (before exit animation)
  /// - [route.completed] completes after the exit animation finishes and the route is disposed
  ///
  /// This ensures that `_isSheetShown` is only set to false after the bottom sheet's
  /// widgets (including any Navigator with GlobalKey) are fully removed from the tree.
  Future<void> _showAsBottomSheet() {
    final navigator = Navigator.of(context);

    _currentSheetRoute = ModalBottomSheetRoute<void>(
      builder: (sessionContext) => _InheritedAdaptiveOverlay(
        controller: widget.controller,
        child: _buildOverlayContent(sessionContext),
      ),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierLabel: MaterialLocalizations.of(
        context,
      ).scrimOnTapHint(MaterialLocalizations.of(context).bottomSheetLabel),
    );

    navigator.push(_currentSheetRoute!);

    // Use `completed` (fires after exit animation) instead of `popped` (fires on pop).
    return _currentSheetRoute!.completed.then((_) {});
  }

  void _syncBottomSheet(bool isVisible) {
    if (isVisible && !_isSheetShown) {
      _isSheetShown = true;
      _showAsBottomSheet().whenComplete(() {
        if (!mounted) return;

        _currentSheetRoute = null;

        // One frame delay for widget tree finalization after the route animation
        // has completed. The `completed` Future already guarantees the exit
        // animation is done, so we only need a single frame for cleanup.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isSheetShown) {
            setState(() {
              _isSheetShown = false;
            });

            // If we are still on mobile, it means the user closed the sheet manually.
            // Synchronize the controller.
            if (AdaptiveOverlay.isMobile(context)) {
              widget.controller.close();
            }
          }
        });
      });
    } else if (!isVisible && _isSheetShown) {
      // Don't set _isSheetShown = false here!
      // Stay true until the completed Future fires.
      _popSheetRoute();
    }
  }

  /// Pops the current bottom sheet route if it is still active.
  void _popSheetRoute() {
    if (!mounted) return;

    final route = _currentSheetRoute;
    if (route != null && route.isActive) {
      route.navigator?.pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = AdaptiveOverlay.isMobile(context);
    final isVisible = widget.controller.isVisible;

    if (_isMobile) {
      if (isVisible && !_isSheetShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.controller.isVisible) {
            _syncBottomSheet(true);
          }
        });
      }
    } else if (_isSheetShown) {
      // We are transitioning from mobile TO desktop while a sheet is open.
      // Pop the sheet route, but KEEP _isSheetShown = true until completed fires.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isSheetShown) {
          _popSheetRoute();
        }
      });
    }

    // Sync side overlay visibility
    if (isVisible) {
      _animatedOverlayController.open();
    } else {
      _animatedOverlayController.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: We only build the side overlay in the stack if we are not in mobile mode
    // AND the sheet is not actively being shown. This prevents "Multiple widgets used the same GlobalKey"
    // during transitions or resizing.
    final showStackOverlay = !_isMobile && !_isSheetShown;

    final overlayUI = showStackOverlay
        ? AnimatedOverlay(
            controller: _animatedOverlayController,
            alignment: widget.overlayAlignment,
            constraints: widget.overlayConstraints,
            backdropColor: Colors.transparent,
            child: _buildOverlayContent(context),
          )
        : const SizedBox.shrink();

    return _InheritedAdaptiveOverlay(
      controller: widget.controller,
      mobileBreakpoint: widget.mobileBreakpoint,
      child: widget.child == null
          ? overlayUI
          : Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child!,
                if (showStackOverlay) Positioned.fill(child: overlayUI),
              ],
            ),
    );
  }
}
