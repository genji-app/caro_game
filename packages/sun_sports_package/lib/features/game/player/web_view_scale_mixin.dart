import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Mixin chịu trách nhiệm tính toán tỷ lệ scale (phóng to/thu nhỏ trục ngang)
/// của Web Game khi nó được đưa lên màn hình lớn hoặc đổi khung.
///
/// Nhờ việc tách mixin này, `GameWebView` nguyên bản sẽ được giữ sạch hoàn toàn,
/// không bị xâm lấn bởi logic scale, qua đó dễ dàng theo dõi lỗi hoặc maintain sau này.
mixin WebViewScaleMixin<T extends StatefulWidget> on State<T> {
  // ---- Scale variables cho Web ----
  double? _initialWidth;
  double _scaleX = 1.0;

  /// Lấy hệ số scale khung ngang hiện tại.
  double get webViewScaleX => _scaleX;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Logic này chỉ dành cho bản Web vì App Native tự làm responsive.
    if (!kIsWeb) return;

    final containerSize = MediaQuery.sizeOf(context);

    if (_initialWidth == null) {
      if (containerSize.width <= 0) return;

      try {
        // Cố gắng bắt lén kích thước thiết bị vật lý trên màn hình gốc
        // để tạo origin mốc ổn định nhất.
        final view = View.maybeOf(context);
        if (view != null) {
          _initialWidth = view.physicalSize.width / view.devicePixelRatio;
        }

        // Cẩn tắc vô áy náy: nếu Flutter Web trả về 0 hoặc view null thì fallback về container.
        if (_initialWidth == null || _initialWidth == 0) {
          _initialWidth = containerSize.width;
        }
      } catch (_) {
        _initialWidth = containerSize.width;
      }

      _scaleX = containerSize.width / _initialWidth!;
    } else {
      final scaleX = containerSize.width / _initialWidth!;
      if ((scaleX - _scaleX).abs() > 0.001) {
        _scaleX = scaleX;
      }
    }
  }

  /// Trợ thủ (Helper) để bọc cái WebView vào trong lớp ScaleTransform
  /// nếu chạy trên nền Web.
  Widget applyWebViewScale(Widget child) {
    if (!kIsWeb) return child;

    return Transform.scale(
      scaleX: _scaleX,
      alignment: Alignment.topLeft,
      child: child,
    );
  }
}
