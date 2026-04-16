import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

/// Scroll to top: instant jump when distance is large (avoids jank on long
/// lists), otherwise short smooth animation.
void _scrollToTop(ScrollController controller) {
  if (!controller.hasClients) return;
  final position = controller.position;
  final viewport = position.viewportDimension;
  final offset = position.pixels;
  if (viewport <= 0) return;
  if (offset > 4 * viewport) {
    position.jumpTo(0);
    return;
  }
  position.animateTo(
    0,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
  );
}

void _scrollToTopPosition(ScrollPosition position) {
  final viewport = position.viewportDimension;
  final offset = position.pixels;
  if (viewport <= 0) return;
  if (offset > 4 * viewport) {
    position.jumpTo(0);
    return;
  }
  position.animateTo(
    0,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
  );
}

/// Wraps a scroll view in a [Stack] and shows a fixed back-to-top button at
/// bottom-right. Uses no overlay so it works reliably on web and desktop.
///
/// Usage:
/// ```dart
/// BackToTopWrapper(
///   builder: (scrollController) => CustomScrollView(
///     controller: scrollController,
///     slivers: [...],
///   ),
/// )
/// ```
class BackToTopWrapper extends StatefulWidget {
  const BackToTopWrapper({super.key, required this.builder});

  /// Builds the scroll view; pass the [ScrollController] to it.
  final Widget Function(ScrollController scrollController) builder;

  @override
  State<BackToTopWrapper> createState() => _BackToTopWrapperState();
}

class _BackToTopWrapperState extends State<BackToTopWrapper> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder(_scrollController),
        Positioned(
          right: BackToTopFloatingButton.margin,
          bottom: BackToTopFloatingButton.bottomForContext(context),
          child: RepaintBoundary(
            child: BackToTopFloatingButton(controller: _scrollController),
          ),
        ),
      ],
    );
  }
}

/// Floating back-to-top button that listens to [controller] and shows when
/// scroll offset > 1.5x viewport. Use with an existing ScrollController
/// (e.g. from provider) inside a Stack + Positioned.
class BackToTopFloatingButton extends StatefulWidget {
  const BackToTopFloatingButton({super.key, required this.controller});

  final ScrollController controller;

  static const double margin = 8;
  static const double iconSize = 40;
  static const double bottomMobile = 72;
  static const double bottomDesktopTablet = 24;

  static double bottomForContext(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600
        ? bottomDesktopTablet
        : bottomMobile;
  }

  @override
  State<BackToTopFloatingButton> createState() =>
      _BackToTopFloatingButtonState();
}

class _BackToTopFloatingButtonState extends State<BackToTopFloatingButton> {
  bool _visible = false;
  bool _pendingCheck = false;
  static const _throttleMs = 100;
  int _lastCheckTime = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runVisibilityCheck();
    });
  }

  @override
  void didUpdateWidget(BackToTopFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients || _pendingCheck) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastCheckTime < _throttleMs) return;
    _pendingCheck = true;
    _lastCheckTime = now;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingCheck = false;
      if (mounted) _runVisibilityCheck();
    });
  }

  void _runVisibilityCheck() {
    if (!widget.controller.hasClients || !mounted) return;
    final position = widget.controller.position;
    if (!position.hasPixels || position.viewportDimension <= 0) return;
    final offset = position.pixels;
    final viewportHeight = position.viewportDimension;
    final shouldShow = offset > 1.5 * viewportHeight;
    if (shouldShow != _visible && mounted) {
      setState(() => _visible = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => _scrollToTop(widget.controller),
        child: ImageHelper.load(
          path: AppIcons.iconBackToTop,
          width: BackToTopFloatingButton.iconSize,
          height: BackToTopFloatingButton.iconSize,
        ),
      ),
    );
  }
}

/// Legacy: zero-size widget that shows back-to-top in the overlay.
/// Prefer [BackToTopWrapper] (Stack-based) for new code and for web/desktop.
class BackToTopOverlay extends StatefulWidget {
  const BackToTopOverlay({super.key});

  @override
  State<BackToTopOverlay> createState() => _BackToTopOverlayState();
}

class _BackToTopOverlayState extends State<BackToTopOverlay> {
  ScrollPosition? _position;
  OverlayEntry? _overlayEntry;
  OverlayState? _overlayState;
  bool _show = false;
  bool _entryInserted = false;

  static const double _margin = 8;
  static const double _iconSize = 40;
  static const double _bottomMobile = 72;
  static const double _bottomDesktopTablet = 24;

  void _removeEntry() {
    if (!_entryInserted || _overlayEntry == null) return;
    _overlayEntry!.remove();
    _entryInserted = false;
    _overlayEntry = null;
  }

  void _onScroll() {
    final position = _position;
    if (position == null) return;
    if (!position.hasPixels || position.viewportDimension <= 0) return;
    final viewportHeight = position.viewportDimension;
    final offset = position.pixels;
    final shouldShow = offset > 1.5 * viewportHeight;
    if (shouldShow == _show) return;
    _show = shouldShow;
    if (_overlayState != null) {
      if (_show) {
        _ensureOverlayEntry();
        if (_overlayEntry != null && !_entryInserted) {
          _overlayState!.insert(_overlayEntry!);
          _entryInserted = true;
          _overlayEntry!.markNeedsBuild();
        }
      } else {
        _removeEntry();
      }
    }
  }

  void _ensureOverlayEntry() {
    if (_overlayEntry != null || _position == null || _overlayState == null) {
      return;
    }
    final position = _position!;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isWide = MediaQuery.sizeOf(context).width >= 600;
        final bottom = isWide ? _bottomDesktopTablet : _bottomMobile;
        return Positioned(
          right: _margin,
          bottom: bottom,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => _scrollToTopPosition(position),
              child: ImageHelper.load(
                path: AppIcons.iconBackToTop,
                width: _iconSize,
                height: _iconSize,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = Scrollable.maybeOf(context);
    ScrollPosition? position = scrollable?.position;
    if (position == null) {
      final primary = PrimaryScrollController.maybeOf(context);
      position = primary?.position;
    }
    OverlayState? overlayState = kIsWeb
        ? Overlay.maybeOf(context, rootOverlay: false)
        : Overlay.maybeOf(context, rootOverlay: true);
    overlayState ??= Overlay.maybeOf(context, rootOverlay: true);

    if (position != _position) {
      _position?.removeListener(_onScroll);
      _removeEntry();
      _position = position;
      _position?.addListener(_onScroll);
    }
    _overlayState = overlayState;
    _ensureOverlayEntry();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onScroll();
      if (_position != null && !_position!.hasPixels) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onScroll();
        });
      }
    });
  }

  @override
  void deactivate() {
    _removeEntry();
    super.deactivate();
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    _position = null;
    _removeEntry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
