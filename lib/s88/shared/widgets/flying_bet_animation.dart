import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Controller for flying bet animation
class FlyingBetController {
  static final FlyingBetController instance = FlyingBetController._();
  FlyingBetController._();

  OverlayEntry? _overlayEntry;
  final GlobalKey betSlipIconKey = GlobalKey();
  final GlobalKey collapsedTicketKey = GlobalKey();

  /// GlobalKey for desktop header betting badge (phiếu cược trên header)
  final GlobalKey desktopBettingBadgeKey = GlobalKey();

  /// Trigger flying animation from source position to bet slip icon
  void fly({
    required BuildContext context,
    required Offset sourcePosition,
    required Size sourceSize,
    required String label,
    required String value,
  }) {
    // Get target position - priority: desktop badge > collapsed ticket > bottom nav
    final targetPosition =
        _getDesktopBettingBadgePosition() ??
        _getCollapsedTicketPosition() ??
        _getBetSlipIconPosition();
    if (targetPosition == null) {
      debugPrint('[FlyingBet] Target position not found');
      return;
    }

    // Remove any existing overlay
    _overlayEntry?.remove();

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _FlyingBetWidget(
        sourcePosition: sourcePosition,
        sourceSize: sourceSize,
        targetPosition: targetPosition,
        label: label,
        value: value,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  Offset? _getBetSlipIconPosition() {
    final renderBox =
        betSlipIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Return center of the icon
    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }

  Offset? _getCollapsedTicketPosition() {
    final renderBox =
        collapsedTicketKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Return center of the collapsed ticket
    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }

  /// Get position of desktop betting badge in header
  Offset? _getDesktopBettingBadgePosition() {
    final renderBox =
        desktopBettingBadgeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Return center of the desktop betting badge
    return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
  }
}

class _FlyingBetWidget extends StatefulWidget {
  final Offset sourcePosition;
  final Size sourceSize;
  final Offset targetPosition;
  final String label;
  final String value;
  final VoidCallback onComplete;

  const _FlyingBetWidget({
    required this.sourcePosition,
    required this.sourceSize,
    required this.targetPosition,
    required this.label,
    required this.value,
    required this.onComplete,
  });

  @override
  State<_FlyingBetWidget> createState() => _FlyingBetWidgetState();
}

class _FlyingBetWidgetState extends State<_FlyingBetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Cache the bet card widget to avoid rebuilding every frame
  late Widget _cachedBetCard;

  @override
  void initState() {
    super.initState();

    // Pre-build the card once
    _cachedBetCard = _buildBetCard();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Scale down as it flies
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);

    // Fade out near the end
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.linear),
      ),
    );

    // Start animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward().then((_) {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate current position along a straight line
        final t = _controller.value;

        // Linear interpolation - fly straight from source to target
        final currentX =
            widget.sourcePosition.dx +
            (widget.targetPosition.dx - widget.sourcePosition.dx) * t;
        final currentY =
            widget.sourcePosition.dy +
            (widget.targetPosition.dy - widget.sourcePosition.dy) * t;

        return Positioned(
          left:
              currentX - (widget.sourceSize.width * _scaleAnimation.value) / 2,
          top:
              currentY - (widget.sourceSize.height * _scaleAnimation.value) / 2,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          ),
        );
      },
      // Use cached child - only built once, not every frame
      child: _cachedBetCard,
    );
  }

  Widget _buildBetCard() {
    return RepaintBoundary(
      child: Container(
        width: widget.sourceSize.width,
        height: widget.sourceSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9BF5A),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80F9BF5A),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label.isNotEmpty)
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTextStyles.textStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Spacer(),
            Text(
              widget.value,
              style: AppTextStyles.displayStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
