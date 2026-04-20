import 'package:flutter/material.dart';

/// Controller để điều khiển trạng thái của AnimatedOverlay
class AnimatedOverlayController extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void open() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}

/// Một widget Overlay hoạt hình có thể tái sử dụng, trượt từ các cạnh màn hình vào.
///
/// Hỗ trợ:
/// - Slide animation tùy chỉnh hướng (trái, phải, trên, dưới)
/// - Backdrop mờ (có thể tắt/bật)
/// - Tùy chỉnh kích thước và giao diện content
/// - Callbacks khi mở/đóng/backdrop tap
/// - Điều khiển bằng [isVisible] property HOẶC [controller]
class AnimatedOverlay extends StatefulWidget {
  /// Widget con sẽ được hiển thị bên trong overlay
  final Widget child;

  /// Điều khiển trạng thái hiển thị của overlay (nếu không dùng controller)
  final bool isVisible;

  /// Controller tùy chọn để điều khiển trạng thái hiển thị
  final AnimatedOverlayController? controller;

  /// Callback khi người dùng chạm vào backdrop (thường dùng để đóng overlay)
  final VoidCallback? onBackdropTap;

  /// Thời gian thực hiện animation
  final Duration duration;

  /// Hướng trượt vào của overlay
  final Offset slideBeginOffset;

  /// Căn chỉnh của content trong Stack
  final AlignmentGeometry alignment;

  /// Màu của backdrop.
  final Color backdropColor;

  /// Ràng buộc kích thước cho content
  final BoxConstraints? constraints;

  /// Decoration cho container chứa content
  final BoxDecoration? decoration;

  /// Tùy chọn clipping cho content
  final Clip clipBehavior;

  const AnimatedOverlay({
    required this.child,
    required this.alignment,
    super.key,
    this.isVisible = false,
    this.controller,
    this.onBackdropTap,
    this.duration = const Duration(milliseconds: 300),
    this.slideBeginOffset = const Offset(1.0, 0.0), // Mặc định từ phải qua
    this.backdropColor = Colors.black54,
    this.constraints,
    this.decoration,
    this.clipBehavior = Clip.none,
  });

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Trạng thái nội bộ để track visibility khi dùng controller hoặc property
  bool get _shouldBeVisible => widget.controller?.isVisible ?? widget.isVisible;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _setupAnimations();

    // Khởi tạo trạng thái ban đầu
    if (_shouldBeVisible) {
      _animationController.value = 1.0;
    }

    // Lắng nghe controller nếu có
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant AnimatedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cập nhật animation settings nếu có thay đổi
    if (widget.duration != oldWidget.duration ||
        widget.slideBeginOffset != oldWidget.slideBeginOffset) {
      _animationController.duration = widget.duration;
      _setupAnimations();
    }

    // Nếu controller thay đổi
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }

    // Trigger animation dựa trên thay đổi isVisible (chỉ khi không dùng controller hoặc logic kết hợp)
    // Ưu tiên: Nếu có controller -> dùng controller state. Nếu không -> dùng isVisible prop.
    if (oldWidget.isVisible != widget.isVisible && widget.controller == null) {
      _updateAnimationState(widget.isVisible);
    }
  }

  void _handleControllerChange() {
    if (widget.controller != null) {
      _updateAnimationState(widget.controller!.isVisible);
    }
  }

  void _updateAnimationState(bool visible) {
    if (visible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _setupAnimations() {
    // Animation trượt
    _slideAnimation =
        Tween<Offset>(begin: widget.slideBeginOffset, end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Animation mờ dần cho backdrop
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tối ưu: Nếu không visible và animation đã kết thúc (đã đóng hoàn toàn), trả về SizedBox.shrink
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Kiểm tra xem animation đã đóng hẳn chưa
        if (_animationController.isDismissed && !_shouldBeVisible) {
          // Double check controller state để tránh flash frame cuối
          if (!_shouldBeVisible) return const SizedBox.shrink();
        }

        return Stack(
          children: [
            // Backdrop
            if (widget.backdropColor != Colors.transparent)
              FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: widget.onBackdropTap,
                  behavior: HitTestBehavior
                      .opaque, // Bắt sự kiện tap cả vùng trong suốt
                  child: Container(color: widget.backdropColor),
                ),
              )
            else if (widget.onBackdropTap != null)
              // Cover transparent backdrop để bắt sự kiện tap
              GestureDetector(
                onTap: widget.onBackdropTap,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),

            // Content
            Align(
              alignment: widget.alignment,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  clipBehavior: widget.clipBehavior,
                  constraints: widget.constraints,
                  decoration: widget.decoration,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
