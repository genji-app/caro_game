import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_videos.dart';
import 'package:sun_sports/core/utils/unified_assets_preloader.dart';
import 'package:sun_sports/core/utils/video_cache_manager.dart';
import 'package:sun_sports/shared/widgets/splash/splash_web_video_rotator.dart';
import 'package:video_player/video_player.dart';

/// Splash Screen: luôn hiển thị logo + progress. Khi video sẵn sàng → render
/// đè lên trên. Navigate khi cả preload xong VÀ video xong (hoặc fail).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

enum _VideoState { loading, playing, finished, failed }

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _preloadProgress = 0.0;
  bool _preloadDone = false;

  VideoPlayerController? _videoController;
  _VideoState _videoState = _VideoState.loading;
  bool _orientationLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startPreload();
      _startVideo();
    });
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _videoController = null;
    resetWebVideoElement();
    if (_orientationLocked) {
      _orientationLocked = false;
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Preload
  // ---------------------------------------------------------------------------

  void _startPreload() {
    UnifiedAssetsPreloader.startPreloadingInBackground(
      context,
      onProgress: (progress) {
        if (mounted) setState(() => _preloadProgress = progress);
      },
      onComplete: () {
        if (!mounted) return;
        setState(() => _preloadDone = true);
        _maybeNavigate();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Video
  // ---------------------------------------------------------------------------

  Future<void> _startVideo() async {
    try {
      final controller = await _buildController();
      if (controller == null) {
        debugPrint('[Splash] video controller null → fallback');
        _onVideoFailed();
        return;
      }
      _videoController = controller;

      debugPrint('[Splash] video.initialize() start');
      await controller.initialize();
      debugPrint(
        '[Splash] video.initialize() done. '
        'size=${controller.value.size}, '
        'duration=${controller.value.duration}',
      );
      if (!mounted) {
        controller.dispose();
        _videoController = null;
        return;
      }

      await controller.setVolume(0);
      await controller.setLooping(false);
      controller.addListener(_onVideoTick);

      _lockLandscapeIfMobile();
      setState(() => _videoState = _VideoState.playing);
      await controller.play();
      debugPrint('[Splash] video.play() returned');
      if (_shouldRotateOnWeb()) {
        rotateWebVideoElement(onSkip: _skip);
      }
    } catch (e, st) {
      debugPrint('[Splash] video failed: $e\n$st');
      _onVideoFailed();
    }
  }

  Future<VideoPlayerController?> _buildController() async {
    final url = AppVideos.iconBTI;
    debugPrint('[Splash] video url=$url kIsWeb=$kIsWeb');
    if (kIsWeb) {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
    final file = await VideoCacheManager.instance.getOrDownload(url);
    if (file == null) return null;
    return VideoPlayerController.file(file);
  }

  void _onVideoTick() {
    final c = _videoController;
    if (c == null) return;
    final v = c.value;
    if (v.hasError) {
      debugPrint('[Splash] video error: ${v.errorDescription}');
      c.removeListener(_onVideoTick);
      _onVideoFailed();
      return;
    }
    if (v.duration > Duration.zero &&
        v.position >= v.duration &&
        !v.isPlaying) {
      c.removeListener(_onVideoTick);
      if (mounted) {
        setState(() => _videoState = _VideoState.finished);
        // Element được move ra body khi rotate trên web mobile → Flutter
        // unmount VideoPlayer widget không xóa nó. Reset thủ công ở đây.
        resetWebVideoElement();
        _maybeNavigate();
      }
    }
  }

  void _onVideoFailed() {
    if (!mounted) return;
    setState(() => _videoState = _VideoState.failed);
    resetWebVideoElement();
    _maybeNavigate();
  }

  // ---------------------------------------------------------------------------
  // Orientation
  // ---------------------------------------------------------------------------

  void _lockLandscapeIfMobile() {
    if (kIsWeb) return;
    final size = MediaQuery.sizeOf(context);
    if (size.shortestSide >= 600) return;
    _orientationLocked = true;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  bool _shouldRotateOnWeb() {
    if (!kIsWeb) return false;
    final size = MediaQuery.sizeOf(context);
    return size.shortestSide < 600 && size.height > size.width;
  }

  // ---------------------------------------------------------------------------
  // Skip
  // ---------------------------------------------------------------------------

  void _skip() {
    if (_videoState == _VideoState.finished ||
        _videoState == _VideoState.failed) {
      return;
    }
    final c = _videoController;
    c?.removeListener(_onVideoTick);
    c?.pause();
    if (mounted) setState(() => _videoState = _VideoState.finished);
    resetWebVideoElement();
    _maybeNavigate();
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _maybeNavigate() {
    if (!_preloadDone) return;
    if (_videoState != _VideoState.finished &&
        _videoState != _VideoState.failed) {
      return;
    }
    ref.read(splashProvider.notifier).complete();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = _videoController;
    final showVideo =
        _videoState == _VideoState.playing &&
        c != null &&
        c.value.isInitialized;

    // Web mobile rotated: HTML skip button được tạo bởi rotator (đè video qua
    // z-index 1000000). Flutter widget không thể đè video z-index 999999, nên
    // chỉ render Flutter skip button cho desktop web + native.
    final webMobileVideoMode = showVideo && _shouldRotateOnWeb();

    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildLogo(),
          if (showVideo) _buildVideoLayer(c),
          if (showVideo && !webMobileVideoMode) _buildSkipButton(context),
        ],
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Mobile + iPad → bottom right. Desktop → top right.
    final isMobileOrTablet = size.shortestSide < 900;

    return Positioned(
      top: isMobileOrTablet ? null : 24,
      bottom: isMobileOrTablet ? 24 : null,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _skip,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Bỏ qua',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLayer(VideoPlayerController c) {
    // Note: trên web mobile portrait, rotation được apply bởi
    // [rotateWebVideoElement] qua CSS trực tiếp lên `<video>` element
    // (xem splash_web_video_rotator_web.dart) — KHÔNG dùng RotatedBox của
    // Flutter để tránh bug iOS Safari (transform parent → black frames).
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: ImageHelper.load(
              path: AppImages.logoS88Home,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorWidget: const Icon(
                Icons.image,
                size: 200,
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: LinearProgressIndicator(
              value: _preloadProgress,
              backgroundColor: AppColorStyles.backgroundTertiary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.yellow300,
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider quản lý trạng thái splash.
class SplashNotifier extends StateNotifier<bool> {
  SplashNotifier() : super(true);

  void complete() {
    state = false;
  }

  void reset() {
    state = true;
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, bool>(
  (ref) => SplashNotifier(),
);
