import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';

/// Web implementation of Livestream Widget using IFrame
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
  late String _viewType;
  bool _hasError = false;
  bool _isPiPMode = false; // Local state cho web (không có PipManager)
  bool _iframeRegistered = false; // Track xem IFrame đã được register chưa
  html.EventListener? _messageListener; // Listener cho postMessage events

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // viewType ổn định theo URL để tránh đăng ký vô hạn khi State bị recreate.
    // Không dùng DateTime để khi scroll lên lại cùng URL vẫn dùng cùng view.
    _viewType = 'livestream-iframe-${widget.url.hashCode}';
    _registerIFrame();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _removeMessageListener();
    super.dispose();
  }

  @override
  void didUpdateWidget(LivestreamWidgetImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _iframeRegistered = false;
      _viewType = 'livestream-iframe-${widget.url.hashCode}';
      setState(() {
        _hasError = false;
      });
      _registerIFrame();
    }

    // Khi widget được rebuild (có thể do tab được chọn),
    // nếu đang ở PiP mode thì đóng PiP để hiển thị video fullscreen
    // Điều này đảm bảo khi user chọn tab "Trực tuyến", video sẽ hiển thị fullscreen
    if (_isPiPMode) {
      setState(() {
        _isPiPMode = false;
      });
    }
  }

  void _registerIFrame() {
    if (widget.url.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    // Tránh register nhiều lần với cùng viewType
    if (_iframeRegistered) {
      return;
    }

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      _iframeRegistered = true;

      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen =
            false // Bỏ fullscreen
        ..style.backgroundColor = 'black'
        ..allow =
            'autoplay; encrypted-media; picture-in-picture'; // Thêm picture-in-picture permission

      // Lưu ý: Không thể ẩn time display trong IFrame nếu là cross-origin
      // (bị chặn bởi CORS policy)
      // Nếu cần ẩn time display, có thể:
      // 1. Thêm CSS overlay để che time display (không recommended)
      // 2. Yêu cầu backend cung cấp player không có time display
      // 3. Sử dụng custom video player thay vì IFrame

      // Thử detect PiP event từ IFrame content
      iframe.onLoad.listen((_) {
        _trySetupPiPDetection(iframe);
      });

      // Chỉ track error, không cần track loading vì IFrame tự load
      iframe.onError.listen((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });

      return iframe;
    });
  }

  /// Setup message listener để bắt sự kiện từ IFrame (như PiP click)
  void _setupMessageListener() {
    _messageListener = (html.Event event) {
      if (event is html.MessageEvent) {
        // Debug: Log tất cả messages để xem format
        print('📨 Message from IFrame: ${event.data}, origin: ${event.origin}');
        _handleMessageFromIFrame(event);
      }
    };
    html.window.addEventListener('message', _messageListener);
  }

  /// Remove message listener khi dispose
  void _removeMessageListener() {
    if (_messageListener != null) {
      html.window.removeEventListener('message', _messageListener);
      _messageListener = null;
    }
  }

  /// Try setup PiP detection từ IFrame content
  /// Lưu ý: Chỉ work nếu IFrame là same-origin hoặc player cho phép
  void _trySetupPiPDetection(html.IFrameElement iframe) {
    try {
      // Thử access IFrame content để lắng nghe PiP events
      // Lưu ý: Có thể bị chặn bởi CORS nếu là cross-origin
      final iframeWindow = iframe.contentWindow;
      if (iframeWindow != null) {
        // Thử lắng nghe enterpictureinpicture event trên window
        iframeWindow.addEventListener('enterpictureinpicture', (event) {
          print('🎬 PiP event detected from IFrame window');
          _handlePiPActivated();
        });

        // Thử tìm video element trong IFrame và lắng nghe events
        // (chỉ work nếu same-origin)
        // Lưu ý: Dart HTML API không hỗ trợ truy cập document từ WindowBase
        // Cần dùng JavaScript interop hoặc chấp nhận rằng chỉ có thể detect qua postMessage
        try {
          // Thử dùng js.context để access document (nếu cần)
          // Tuy nhiên, với cross-origin IFrame, điều này sẽ bị chặn bởi CORS
        } catch (e) {
          // CORS error - không thể access IFrame content
          print('⚠️ Cannot access IFrame content (CORS): $e');
        }
      }
    } catch (e) {
      // Ignore errors
      print('⚠️ Error setting up PiP detection: $e');
    }
  }

  /// Handle messages từ IFrame
  /// Có thể detect PiP events nếu video player gửi postMessage
  void _handleMessageFromIFrame(html.MessageEvent event) {
    if (!mounted) return;

    try {
      // Kiểm tra origin để đảm bảo an toàn (optional, có thể bỏ qua nếu cần)
      // final origin = event.origin;
      // if (!origin.contains('your-trusted-domain.com')) return;

      // Parse message data
      final data = event.data;
      print('📨 Parsing message data: $data (type: ${data.runtimeType})');

      // Kiểm tra các loại message có thể liên quan đến PiP
      // Format có thể khác nhau tùy vào video player
      if (data is Map) {
        // Ví dụ: { type: 'pip', action: 'enter' } hoặc { event: 'picture-in-picture' }
        final type = data['type'] ?? data['event'] ?? '';
        final action = data['action'] ?? '';

        print('📨 Message type: $type, action: $action');

        if (type.toString().toLowerCase().contains('pip') ||
            type.toString().toLowerCase().contains('picture-in-picture') ||
            action.toString().toLowerCase().contains('pip')) {
          // Detect PiP event - gọi callback
          print('✅ PiP event detected from message!');
          _handlePiPActivated();
        }
      } else if (data is String) {
        // Nếu message là string, kiểm tra keywords
        final lowerData = data.toLowerCase();
        print('📨 Message string: $lowerData');
        if (lowerData.contains('pip') ||
            lowerData.contains('picture-in-picture') ||
            lowerData.contains('enterpictureinpicture')) {
          print('✅ PiP event detected from string message!');
          _handlePiPActivated();
        }
      }
    } catch (e) {
      // Ignore parsing errors
      print('❌ Error parsing message: $e');
    }
  }

  /// Handle PiP activated event
  void _handlePiPActivated() {
    if (!mounted) return;

    print('🎬 _handlePiPActivated called - switching to scoreboard tab');

    setState(() {
      _isPiPMode = true;
    });

    // Gọi callback để chuyển tab sang "Bảng điểm"
    if (widget.onPiPActivated != null) {
      print('✅ Calling onPiPActivated callback');
      widget.onPiPActivated!();
    } else {
      print('⚠️ onPiPActivated callback is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (widget.url.isEmpty) {
      return _buildPlaceholder(context);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // Tính height của video player theo tỉ lệ 16:9
    final videoPlayerHeight = screenWidth * 9 / 16;

    // Full width container - không có border radius
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: const Color(0xFF000000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Statistics overlay
            if (widget.eventData != null) _buildStatisticsOverlay(),
            // Video player container - height cố định theo tỉ lệ 16:9
            SizedBox(
              width: double.infinity,
              height: videoPlayerHeight,
              child: _buildVideoPlayerStack(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder widget khi không có URL
  Widget _buildPlaceholder(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoPlayerHeight = screenWidth * 9 / 16;
    final totalHeight = widget.eventData != null
        ? 130.0 +
              videoPlayerHeight // statisticsOverlayHeight = 130.0
        : videoPlayerHeight;

    return Container(
      width: double.infinity,
      height: totalHeight,
      decoration: const BoxDecoration(color: Color(0xFF000000)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv, color: Color(0xFF666666), size: 48),
            const SizedBox(height: 12),
            Text(
              'Không có link livestream',
              style: AppTextStyles.paragraphXSmall(
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics overlay trên VideoPlayer
  Widget _buildStatisticsOverlay() {
    if (widget.eventData == null) return const SizedBox.shrink();

    return MobileStatisticsTableWidget(
      eventData: widget.eventData!,
      hideBottomBorderRadius: true,
    );
  }

  /// Build video player Stack (web-specific)
  /// IFrame tự có controls riêng, không cần thêm overlay
  Widget _buildVideoPlayerStack() {
    if (_hasError) {
      return _buildErrorOverlay('Không thể tải livestream');
    }

    if (_isPiPMode) {
      return const SizedBox.shrink();
    }

    // IFrame video player - fill toàn bộ container
    return SizedBox.expand(child: HtmlElementView(viewType: _viewType));
  }

  // Removed controls methods - IFrame tự có controls riêng, không cần thêm

  Widget _buildErrorOverlay(String message) => Container(
    color: const Color(0xFF000000),
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
