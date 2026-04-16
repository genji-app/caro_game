import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:co_caro_flame/s88/shared/widgets/rive_vibrating/rive_vibrating_service.dart';

/// Widget hiển thị Rive vibrating animation overlay.
///
/// Sử dụng RiveVibratingService đã được pre-load để tránh init lại.
/// Widget này tự quản lý controller riêng để control animation độc lập.
///
/// NOTE: Widget này chỉ nên được tạo khi cần hiển thị animation.
/// Việc tạo widget này sẽ tạo một RiveWidgetController mới.
class RiveVibratingOverlay extends ConsumerStatefulWidget {
  const RiveVibratingOverlay({super.key});

  @override
  ConsumerState<RiveVibratingOverlay> createState() =>
      _RiveVibratingOverlayState();
}

class _RiveVibratingOverlayState extends ConsumerState<RiveVibratingOverlay> {
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final service = ref.read(riveVibratingServiceProvider);
    if (service.isInitialized) {
      _controller = service.createController();
    }
  }

  @override
  void didUpdateWidget(RiveVibratingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-init controller nếu service vừa được initialized
    if (_controller == null) {
      _initController();
      if (_controller != null && mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch initialized state để rebuild khi service ready
    final isServiceReady = ref.watch(riveVibratingInitializedProvider);

    // Re-init controller nếu service vừa ready
    if (isServiceReady && _controller == null) {
      _initController();
    }

    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: IgnorePointer(
        child: rive.RiveWidget(controller: _controller!, fit: rive.Fit.fill),
      ),
    );
  }
}

/// Positioned overlay để đặt trên BetCard
///
/// Chỉ render RiveVibratingOverlay khi isVisible=true để tránh:
/// - Tạo nhiều RiveWidgetController không cần thiết
/// - Gây memory leak và CPU usage cao
class PositionedRiveVibratingOverlay extends StatelessWidget {
  final bool isVisible;

  const PositionedRiveVibratingOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    // Chỉ tạo RiveVibratingOverlay khi cần hiển thị
    if (!isVisible) return const SizedBox.shrink();

    return const Positioned.fill(child: RiveVibratingOverlay());
  }
}
