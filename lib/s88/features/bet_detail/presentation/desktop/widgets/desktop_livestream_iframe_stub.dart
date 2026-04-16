import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Stub implementation for non-web platforms
/// This widget will never be shown on mobile, but is needed to avoid compile errors
class DesktopLivestreamIframe extends StatelessWidget {
  final String url;

  const DesktopLivestreamIframe({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // This should never be called on non-web platforms
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          'Livestream chỉ hỗ trợ trên web',
          style: AppTextStyles.paragraphXSmall(color: const Color(0xFF888888)),
        ),
      ),
    );
  }
}
