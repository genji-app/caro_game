import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_rive.dart';

/// Loading screen hiển thị Rive animation khi app đang khởi tạo.
/// Tự dispose animation khi widget bị remove khỏi tree.
class ShellRiveLoading extends StatefulWidget {
  const ShellRiveLoading({super.key});

  @override
  State<ShellRiveLoading> createState() => _ShellRiveLoadingState();
}

class _ShellRiveLoadingState extends State<ShellRiveLoading> {
  rive.RiveWidgetController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await rive.File.url(
        AppRive.animLoading,
        riveFactory: rive.Factory.rive,
      );
      if (file != null && mounted) {
        setState(() {
          _controller = rive.RiveWidgetController(file);
          _isLoading = false;
        });
      }
    } catch (_) {
      // Nếu load fail thì giữ màn hình background
      if (mounted) {
        setState(() => _isLoading = false);
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
    return Scaffold(
      backgroundColor: AppColorStyles.backgroundSecondary,
      body: Center(
        child: _controller != null
            ? SizedBox(
                width: 400,
                height: 400,
                child: rive.RiveWidget(
                  controller: _controller!,
                  fit: rive.Fit.contain,
                ),
              )
            : _isLoading
                ? const SizedBox.shrink()
                : const SizedBox.shrink(),
      ),
    );
  }
}
