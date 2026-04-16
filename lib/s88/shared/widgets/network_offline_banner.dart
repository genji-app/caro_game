import 'dart:async';

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/network_manger.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Chiều cao nội dung (Row) chung cho offline/online banner để đồng bộ height.
const double kNetworkBannerContentHeight = 44.0;

/// Design: Figma Sun Sport — full-width top banner when network is lost.
/// - Dark red background (#4A1412)
/// - No-WiFi icon, message "Không kết nối mạng. Thử lại"
/// - "Thử lại" underlined, tappable (không countdown)
class NetworkOfflineBanner extends StatelessWidget {
  const NetworkOfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  Future<void> _doRetry(BuildContext context) async {
    final connected = await NetworkManager.instance.checkIsConnected();
    if (!context.mounted) return;
    if (connected) {
      onRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF4A1412);
    const textColor = Color(0xFFF4B8B8);
    const iconColor = Color(0xFFE57373);

    final style = AppTextStyles.paragraphSmall(color: textColor);
    final retryStyle = style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: textColor,
    );

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: kNetworkBannerContentHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Flexible(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Text('Không kết nối mạng...', style: style),
                      Semantics(
                        button: true,
                        label: I18n.txtRetry,
                        child: GestureDetector(
                          onTap: () => _doRetry(context),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Text(I18n.txtRetry, style: retryStyle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Design: Figma Sun Sport — banner khi đã kết nối lại.
/// - Nền xanh đậm, icon Wi-Fi + text "Đã kết nối" màu xanh sáng.
/// - Tự động dismiss sau [dismissAfterSeconds] (mặc định 3s).
class NetworkOnlineBanner extends StatefulWidget {
  const NetworkOnlineBanner({
    super.key,
    this.dismissAfterSeconds = 3,
    this.onDismiss,
  });

  final int dismissAfterSeconds;
  final VoidCallback? onDismiss;

  @override
  State<NetworkOnlineBanner> createState() => _NetworkOnlineBannerState();
}

class _NetworkOnlineBannerState extends State<NetworkOnlineBanner> {
  static const Color _background = Color(0xFF1B3D1B);
  static const Color _textAndIconColor = Color(0xFF4ADE80);

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(Duration(seconds: widget.dismissAfterSeconds), () {
      if (!mounted) return;
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.paragraphSmall(color: _textAndIconColor);

    return Material(
      color: _background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: kNetworkBannerContentHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.wifi_rounded, color: _textAndIconColor, size: 22),
                const SizedBox(width: 12),
                Text('Đã kết nối', style: style),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
