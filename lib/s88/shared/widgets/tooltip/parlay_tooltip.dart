import 'dart:async';
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Tooltip widget hiển thị thông báo với mũi tên chỉ xuống bên trái
/// Theo design Figma: background quaternary, text primary, border radius 8
class ParlayTooltip {
  ParlayTooltip._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Show tooltip phía trên widget được tap
  /// [context] - BuildContext của widget trigger
  /// [targetKey] - GlobalKey của widget để xác định vị trí
  /// [message] - Nội dung tooltip
  /// [duration] - Thời gian hiển thị (default 2 giây)
  static void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Dismiss any existing tooltip
    dismiss();

    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    final overlayState = Overlay.of(context, rootOverlay: true);

    _currentEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        targetPosition: targetPosition,
        targetSize: targetSize,
        message: message,
        onDismiss: dismiss,
      ),
    );

    overlayState.insert(_currentEntry!);

    // Auto dismiss after duration
    _dismissTimer = Timer(duration, dismiss);
  }

  /// Dismiss tooltip hiện tại
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _TooltipOverlay extends StatefulWidget {
  final Offset targetPosition;
  final Size targetSize;
  final String message;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.targetPosition,
    required this.targetSize,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Arrow dimensions
  static const double _arrowWidth = 12.0;
  static const double _arrowHeight = 6.0;
  static const double _tooltipSpacing = 4.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(children: [_buildTooltip(context)]),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate tooltip position (above the target, arrow pointing to target)
    // Arrow position: bottom-left of tooltip
    final arrowLeftOffset = 8.0; // Distance from left edge to arrow start

    // Position tooltip so arrow aligns with center of target
    final targetCenterX =
        widget.targetPosition.dx + (widget.targetSize.width / 2);
    final tooltipLeft = targetCenterX - arrowLeftOffset - (_arrowWidth / 2);

    return Positioned(
      left: tooltipLeft.clamp(8.0, screenWidth - 200),
      top: widget.targetPosition.dy - _tooltipSpacing - _arrowHeight,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tooltip content
              Transform.translate(
                offset: const Offset(0, _arrowHeight),
                child: _buildContent(),
              ),
              // Arrow pointing down-left
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CustomPaint(
                  size: const Size(_arrowWidth, _arrowHeight),
                  painter: _ArrowPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 2,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 12),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Text(
        widget.message,
        style: AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColorStyles.contentPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Custom painter for arrow pointing down
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColorStyles.backgroundQuaternary
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0) // Top left
      ..lineTo(size.width / 2, size.height) // Bottom center
      ..lineTo(size.width, 0) // Top right
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
