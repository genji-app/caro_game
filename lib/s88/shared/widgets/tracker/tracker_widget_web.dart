import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';

/// Web implementation of Tracker Widget using IFrame
class TrackerWidgetImpl extends StatefulWidget {
  final int eventStatsId;
  final int sportId;
  final double height;

  const TrackerWidgetImpl({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height = 200,
  });

  @override
  State<TrackerWidgetImpl> createState() => _TrackerWidgetImplState();
}

class _TrackerWidgetImplState extends State<TrackerWidgetImpl> {
  late String _viewType;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _viewType =
        'tracker-iframe-${widget.eventStatsId}-${DateTime.now().millisecondsSinceEpoch}';
    _registerIFrame();
  }

  @override
  void didUpdateWidget(TrackerWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventStatsId != widget.eventStatsId) {
      _viewType =
          'tracker-iframe-${widget.eventStatsId}-${DateTime.now().millisecondsSinceEpoch}';
      _registerIFrame();
    }
  }

  void _registerIFrame() {
    final trackerUrl = _buildTrackerUrl();

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = trackerUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..style.backgroundColor = 'black'
        // fullscreen: cho phép content trong iframe gọi requestFullscreen()
        ..allow = 'autoplay; encrypted-media; fullscreen';

      iframe.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      iframe.onError.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      return iframe;
    });
  }

  String _buildTrackerUrl() {
    final http = SbHttpManager.instance;
    final urlStatistics = http.urlStatistics;
    final token = http.userTokenSb;
    final agentId = SbConfig.agentId;

    return '$urlStatistics/?token=$token&agentId=$agentId&lng=vi&sportId=${widget.sportId}&route=8&m=${widget.eventStatsId}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eventStatsId == 0) {
      return _buildPlaceholder('Không có dữ liệu tracker');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: widget.height,
        color: const Color(0xFF1A1A1A),
        child: Stack(
          children: [
            Positioned.fill(child: HtmlElementView(viewType: _viewType)),
            if (_isLoading)
              Container(
                color: const Color(0xFF1A1A1A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                        strokeWidth: 2,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Đang tải tracker...',
                        style: AppTextStyles.paragraphXSmall(
                          color: const Color(0xFFFFFCDB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_hasError) _buildPlaceholder('Không thể tải tracker'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) => Container(
    height: widget.height,
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_soccer, color: Color(0xFF666666), size: 48),
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
