import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/pip_manager.dart';

/// Container widget chung cho Livestream Widget (Mobile và Web)
///
/// Xử lý:
/// - Layout chung (ClipRRect, AnimatedContainer, Column)
/// - Statistics overlay
/// - Placeholder khi không có URL
/// - Content height 16:9 (WebView)
class LivestreamWidgetContainer extends StatelessWidget {
  /// The livestream URL (h5Link from API)
  final String url;

  /// Event data for displaying statistics overlay
  final LeagueEventData? eventData;

  /// Nội dung livestream (WebViewWidget hoặc tương đương)
  final Widget? webViewContent;

  /// Placeholder message khi không có URL
  final String placeholderMessage;

  /// State và callbacks
  final bool isInitialized;
  final bool isLoading;
  final bool hasError;
  final bool showControls;
  final VoidCallback? onTapContent;
  final VoidCallback? onPiPActivated;
  final Widget Function(String)? buildErrorOverlay;

  /// Height của statistics overlay
  static const double statisticsOverlayHeight = 130.0;

  const LivestreamWidgetContainer({
    super.key,
    required this.url,
    this.eventData,
    this.webViewContent,
    this.placeholderMessage = 'Không có link livestream',
    this.isInitialized = false,
    this.isLoading = false,
    this.hasError = false,
    this.showControls = false,
    this.onTapContent,
    this.onPiPActivated,
    this.buildErrorOverlay,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _buildPlaceholder(context, placeholderMessage);
    }

    final pip = PipManager();
    pip.setOverlayControlsBuilder(_buildPiPOverlayControls);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentHeight = screenWidth * 9 / 16;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: const Color(0xFF000000),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (eventData != null) _buildStatisticsOverlay(),
            RepaintBoundary(
              child: SizedBox(
                height: contentHeight,
                child: _buildContentStack(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder widget khi không có URL
  Widget _buildPlaceholder(BuildContext context, String message) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentHeight = screenWidth * 9 / 16;
    final totalHeight = eventData != null
        ? statisticsOverlayHeight + contentHeight
        : contentHeight;

    return Container(
      height: totalHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
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

  /// Overlay controls cho PiP (fullscreen, close) – dùng chung khi PiP ở overlay.
  Widget _buildPiPOverlayControls(BuildContext context) {
    final pip = PipManager();
    return Stack(
      children: [
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            onTap: pip.requestFullscreen,
            child: ImageHelper.load(
              path: AppIcons.iconVideoFull,
              width: 32,
              height: 32,
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: pip.closePiP,
            child: ImageHelper.load(
              path: AppIcons.iconClosePip,
              width: 32,
              height: 32,
            ),
          ),
        ),
      ],
    );
  }

  /// Build statistics overlay trên content
  Widget _buildStatisticsOverlay() {
    if (eventData == null) return const SizedBox.shrink();

    return MobileStatisticsTableWidget(
      eventData: eventData!,
      hideBottomBorderRadius: true,
    );
  }

  /// Build content Stack: WebView + overlays (loading, error, controls, PiP)
  Widget _buildContentStack(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final contentHeight = constraints.maxHeight;
        final pip = PipManager();
        final showPiPIcon = showControls && !pip.isPiPMode;
        final showEmbeddedPiP = pip.isPiPMode && !pip.isLiftedToOverlay;

        return Stack(
          children: [
            if (isInitialized && webViewContent != null)
              Positioned.fill(
                child: SizedBox(
                  width: containerWidth,
                  height: contentHeight,
                  child: webViewContent!,
                ),
              ),
            if (onTapContent != null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTapContent,
                ),
              ),
            if (isLoading) _buildLoadingOverlay(),
            if (hasError && buildErrorOverlay != null)
              Positioned.fill(
                child: buildErrorOverlay!('Không thể tải livestream'),
              ),
            if (showPiPIcon)
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onPiPActivated,
                  child: ImageHelper.load(
                    path: AppIcons.iconPip,
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            if (showEmbeddedPiP)
              Positioned(
                right: 12,
                bottom: 12,
                child: pip.buildEmbeddedPiP(
                  context,
                  containerWidth: containerWidth,
                ),
              ),
          ],
        );
      },
    );
  }

  static const Color _loadingColor = Color(0xFFFFD700);
  static const Color _loadingTextColor = Color(0xFFFFFCDB);

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF000000),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: _loadingColor,
                strokeWidth: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'Đang tải...',
                style: AppTextStyles.paragraphXSmall(color: _loadingTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
