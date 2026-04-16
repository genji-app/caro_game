import 'package:flutter/material.dart';

/// Odds change direction for animation
///
/// Matches sport_socket library's OddsDirection for future integration.
///
/// Usage:
/// ```dart
/// final direction = OddsDirectionX.fromChange(
///   current: 1.95,
///   previous: 1.90,
/// );
/// // direction == OddsDirection.up
/// ```
enum OddsDirection {
  /// Không thay đổi hoặc giá trị đầu tiên
  none,

  /// Odds tăng (tốt cho player) → hiển thị màu xanh
  up,

  /// Odds giảm (xấu cho player) → hiển thị màu đỏ
  down,
}

extension OddsDirectionX on OddsDirection {
  bool get isUp => this == OddsDirection.up;
  bool get isDown => this == OddsDirection.down;
  bool get hasChange => this != OddsDirection.none;

  /// Color cho animation flash
  Color? get color {
    switch (this) {
      case OddsDirection.up:
        return const Color(0xFF4CAF50); // Green
      case OddsDirection.down:
        return const Color(0xFFF44336); // Red
      case OddsDirection.none:
        return null;
    }
  }

  /// Background color với opacity
  Color? backgroundColor([double opacity = 0.2]) {
    return color?.withOpacity(opacity);
  }

  /// Icon cho direction indicator
  IconData? get icon {
    switch (this) {
      case OddsDirection.up:
        return Icons.arrow_drop_up;
      case OddsDirection.down:
        return Icons.arrow_drop_down;
      case OddsDirection.none:
        return null;
    }
  }

  /// Factory từ giá trị trước và sau
  static OddsDirection fromChange({
    required double? current,
    required double? previous,
  }) {
    if (previous == null || current == null) return OddsDirection.none;
    if (current > previous) return OddsDirection.up;
    if (current < previous) return OddsDirection.down;
    return OddsDirection.none;
  }
}
