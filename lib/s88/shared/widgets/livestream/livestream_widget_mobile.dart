import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/pip_manager.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/livestream_widget_container.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';

/// Mobile implementation of Livestream Widget using WebView only.
class LivestreamWidgetImpl extends StatefulWidget {
  final String url;
  final LeagueEventData? eventData;
  final VoidCallback? onPiPActivated;

  const LivestreamWidgetImpl({
    super.key,
    required this.url,
    this.eventData,
    this.onPiPActivated,
  });

  @override
  State<LivestreamWidgetImpl> createState() => _LivestreamWidgetImplState();
}

class _LivestreamWidgetImplState extends State<LivestreamWidgetImpl>
    with AutomaticKeepAliveClientMixin {
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(LivestreamWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initWebView();
    }
    if (PipManager().isPiPMode) {
      PipManager().closePiP();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    // Đang PiP thì không release WebView (PiP overlay vẫn cần controller); không hide PiP.
    if (!PipManager().isPiPMode) {
      PipManager().releaseWebView();
      PipManager().hidePiP();
    }
    super.dispose();
  }

  void _initWebView() {
    if (widget.url.isEmpty) return;
    PipManager().initialize(
      context,
      onClose: _onPipClose,
      onPiPModeChanged: (_) {
        if (!mounted) return;
        try {
          setState(() {});
        } catch (_) {}
      },
    );
    PipManager().loadUrl(widget.url, context);
    if (mounted) setState(() {});
  }

  void _onPipClose() {
    if (!mounted) return;
    try {
      setState(() {});
    } catch (_) {}

    // Controller được quản lý bởi PipManager
    // PipManager sẽ xử lý dispose controller khi cần
  }

  void _showControlsWithAutoHide() {
    setState(() {
      _showControls = true;
    });
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _hideControls() {
    _controlsTimer?.cancel();
    setState(() {
      _showControls = false;
    });
  }

  void _onPiPActivated(BuildContext context) {
    final pip = PipManager();
    pip.setOnVideoPage(true);
    pip.showPiP();
    pip.liftToOverlay(context);
    _hideControls();
    widget.onPiPActivated?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final pip = PipManager();
    final controller = pip.webViewController;
    final isInitialized = controller != null;
    final isPiPMode = pip.isPiPMode;

    Widget? content;
    if (!isPiPMode && controller != null) {
      content = WebViewWidget(controller: controller);
    }

    return LivestreamWidgetContainer(
      url: widget.url,
      eventData: widget.eventData,
      webViewContent: content,
      isInitialized: isInitialized,
      isLoading: !isInitialized,
      hasError: false,
      showControls: _showControls,
      onTapContent: _showControlsWithAutoHide,
      onPiPActivated: () => _onPiPActivated(context),
    );
  }
}
