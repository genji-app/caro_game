import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Web implementation of the desktop livestream iframe
class DesktopLivestreamIframe extends StatefulWidget {
  final String url;

  const DesktopLivestreamIframe({super.key, required this.url});

  @override
  State<DesktopLivestreamIframe> createState() =>
      _DesktopLivestreamIframeState();
}

class _DesktopLivestreamIframeState extends State<DesktopLivestreamIframe>
    with AutomaticKeepAliveClientMixin {
  String? _viewType;
  bool _registered = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _registerIframe();
  }

  void _registerIframe() {
    if (_registered || _viewType != null) return;
    if (widget.url.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    _registered = true;
    _viewType = 'desktop-livestream-${widget.url.hashCode}';

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType!, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..style.backgroundColor = 'black'
        ..allow = 'autoplay; encrypted-media';

      iframe.onError.listen((_) {
        if (mounted) setState(() => _hasError = true);
      });

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_hasError || _viewType == null) {
      return _buildPlaceholder('Không thể tải livestream');
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: const Color(0xFF1A1A1A),
          child: HtmlElementView(viewType: _viewType!),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) => Container(
    constraints: const BoxConstraints(minHeight: 200),
    decoration: const BoxDecoration(
      color: Color(0xFF1A1A1A),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.live_tv, color: Color(0xFF666666), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.paragraphXSmall(
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    ),
  );
}
