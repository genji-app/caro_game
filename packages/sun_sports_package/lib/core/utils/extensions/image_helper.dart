import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:http/http.dart' as http;
import 'package:sun_sports/core/utils/extensions/cached_manager.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class ImageHelper {
  /// Số lần retry khi load image bị lỗi (network only).
  static const int maxRetryAttempts = 3;

  /// Base delay giữa các lần retry (exponential backoff).
  static const Duration _baseRetryDelay = Duration(milliseconds: 500);

  /// Timeout cho mỗi attempt download. Mạng yếu/chậm vượt mức này → fail fast,
  /// trigger retry (thay vì để request treo vô hạn).
  static const Duration _perAttemptTimeout = Duration(seconds: 10);

  /// Minimum valid file size (bytes) — file nhỏ hơn coi như corrupted.
  static const int _minValidFileSize = 10;

  /// Default placeholder widget (empty SizedBox).
  static Widget _defaultPlaceholder(double? width, double? height) {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: SizedBox.shrink()),
    );
  }

  /// Default error widget (icon error trên nền backgroundPrimary).
  static Widget _defaultErrorWidget({
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? 144,
      decoration: BoxDecoration(
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius)
            : null,
        color: AppColorStyles.backgroundPrimary,
      ),
      child: const Center(
        child: Icon(Icons.error, color: AppColorStyles.contentSecondary),
      ),
    );
  }

  static bool _isNetworkPath(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// Normalize path: decode URL encoding và remove `assets/` prefix
  /// CHỈ KHI sau prefix là URL scheme thật sự (`http://` / `https://`).
  /// Tránh case `assets/icons/http_icon.png` bị strip nhầm.
  static String _normalizePath(String path) {
    String normalizedPath = path.trim();

    try {
      const int maxDecodeAttempts = 3;
      for (int i = 0; i < maxDecodeAttempts; i++) {
        if (normalizedPath.contains('%25') ||
            normalizedPath.contains('%3A')) {
          try {
            final decoded = Uri.decodeComponent(normalizedPath);
            if (decoded != normalizedPath) {
              normalizedPath = decoded;
            } else {
              break;
            }
          } catch (_) {
            break;
          }
        } else {
          break;
        }
      }

      if (normalizedPath.startsWith('assets/')) {
        final afterPrefix = normalizedPath.substring(7);
        if (afterPrefix.startsWith('http://') ||
            afterPrefix.startsWith('https://')) {
          normalizedPath = afterPrefix;
        }
      }
    } catch (_) {
      // Use original path
    }

    return normalizedPath;
  }

  /// Download file với retry + validation.
  ///
  /// - Retry tối đa [maxRetryAttempts] lần với exponential backoff.
  /// - Validate file size >= [_minValidFileSize] để loại file rỗng/corrupted.
  /// - Nếu retry mà fail/invalid → CLEAR cache cho URL để KHÔNG giữ file lỗi.
  /// - Web: trả về null (browser tự cache qua HTTP headers).
  static Future<File?> _downloadFileWithRetry(String url) async {
    if (kIsWeb) return null;

    Object? lastError;
    for (int attempt = 1; attempt <= maxRetryAttempts; attempt++) {
      try {
        // Timeout per-attempt: mạng chậm vượt _perAttemptTimeout sẽ throw
        // TimeoutException → trigger retry thay vì để request treo vô hạn.
        final file = await AssetsCacheManager
            .getSingleFileForUrlWithVersioning(url)
            .timeout(_perAttemptTimeout);

        if (await file.exists()) {
          final size = await file.length();
          if (size >= _minValidFileSize) {
            return file;
          }
        }
        // File không tồn tại hoặc quá nhỏ → coi như fail, clear cache
        await AssetsCacheManager.clearCacheForUrl(url);
      } on TimeoutException catch (e) {
        lastError = e;
        // Timeout: clear cache (file partial có thể đã ghi 1 phần) rồi retry
        try {
          await AssetsCacheManager.clearCacheForUrl(url);
        } catch (_) {
          // Ignore cleanup errors
        }
      } catch (e) {
        lastError = e;
        // Clear cache để retry không lấy file lỗi
        try {
          await AssetsCacheManager.clearCacheForUrl(url);
        } catch (_) {
          // Ignore cleanup errors
        }
      }

      if (attempt < maxRetryAttempts) {
        await Future<void>.delayed(_baseRetryDelay * attempt);
      }
    }

    // All retries failed → đảm bảo không còn file lỗi trong cache
    try {
      await AssetsCacheManager.clearCacheForUrl(url);
    } catch (_) {
      // Ignore cleanup errors
    }
    debugPrint(
      'ImageHelper: load failed after $maxRetryAttempts retries: $url '
      '(last error: $lastError)',
    );
    return null;
  }

  /// Widget SVG hoặc image (asset / network).
  static Widget getSVG({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.scaleDown,
  }) {
    final normalizedPath = _normalizePath(path);
    final isNetwork = _isNetworkPath(normalizedPath);

    if (isNetwork) {
      // On web, use cached SVG widget to avoid duplicate network requests
      if (kIsWeb) {
        return _CachedSvgNetworkWidget(
          // Dùng hashCode thay cho `Color.value` (deprecated từ Flutter 3.27)
          key: ValueKey(
            'svg_${normalizedPath}_${color?.hashCode ?? 0}',
          ),
          url: normalizedPath,
          width: width,
          height: height,
          color: color,
          fit: fit,
        );
      }

      return svg.SvgPicture.network(
        normalizedPath,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => _defaultPlaceholder(width, height),
      );
    }

    // Local asset
    return svg.SvgPicture.asset(
      normalizedPath,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) => _defaultPlaceholder(width, height),
    );
  }

  /// Precache SVG để tránh delay khi hiển thị.
  static Future<void> precacheSVG(BuildContext context, String path) async {
    try {
      if (_isNetworkPath(path)) {
        try {
          final loader = svg.SvgNetworkLoader(path);
          await svg.vg.loadPicture(loader, null);
        } catch (_) {
          // Ignore precache errors
        }
      } else {
        try {
          final loader = svg.SvgAssetLoader(path);
          await svg.vg.loadPicture(loader, null);
        } catch (_) {
          // Ignore precache errors
        }
      }
    } catch (_) {
      // Ignore precache errors
    }
  }

  /// Image asset với errorWidget + borderRadius support.
  static Widget getImage({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    Widget? errorWidget,
    int? cacheWidth,
    int? cacheHeight,
    double? borderRadius,
  }) {
    final image = Image.asset(
      path,
      width: width,
      height: height,
      color: color,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ??
          _defaultErrorWidget(
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
    );

    if (borderRadius != null && borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }
    return image;
  }

  /// Precache asset image. Web: skip (browser tự cache).
  static Future<void> precacheAssetImage(
    BuildContext context,
    String path,
  ) async {
    if (kIsWeb) return;
    try {
      await precacheImage(AssetImage(path), context);
    } catch (_) {
      // Ignore precache errors
    }
  }

  /// Precache network image. Web: skip (browser tự cache qua HTTP headers).
  /// Skip cho SVG (dùng [precacheSVG] thay thế).
  static Future<void> precacheNetworkImage(
    BuildContext context,
    String imageUrl,
  ) async {
    if (kIsWeb) return;
    if (imageUrl.toLowerCase().endsWith('.svg')) return;

    try {
      final image = Image.network(imageUrl);
      await precacheImage(image.image, context);
    } catch (_) {
      // Ignore precache errors
    }
  }

  /// Network image với retry. Khi fail tất cả retry → clear cache, hiển thị errorWidget.
  static Widget getNetworkImage({
    required String imageUrl,
    double? height,
    double? width,
    Widget? errorWidget,
    BoxFit? fit,
    Widget? placeholder,
    double? borderRadius,
    double? sizeLoading = 50,
    int maxRetries = maxRetryAttempts,
  }) {
    return _CachedNetworkImageWithRetry(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      maxHeightDiskCache: 1200,
      maxWidthDiskCache: 1200,
      filterQuality: FilterQuality.high,
      maxRetries: maxRetries,
    );
  }

  /// Optimized cho logo nhỏ (team, league logos) — cache size phù hợp + retry.
  static Widget getSmallLogo({
    required String imageUrl,
    required double size,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
    int maxRetries = maxRetryAttempts,
  }) {
    final cacheSize = (size * 2).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: _CachedNetworkImageWithRetry(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        maxHeightDiskCache: cacheSize,
        maxWidthDiskCache: cacheSize,
        filterQuality: FilterQuality.low,
        placeholder: placeholder ?? const SizedBox.shrink(),
        errorWidget: errorWidget ??
            Icon(
              Icons.sports_soccer,
              size: size * 0.7,
              color: AppColorStyles.contentSecondary,
            ),
        borderRadius: borderRadius,
        maxRetries: maxRetries,
      ),
    );
  }

  /// Avatar với retry + fallback đúng cho cả error và placeholder.
  /// Tôn trọng cả `width` và `height` riêng biệt.
  static Widget getAvatar({
    required String imageUrl,
    double? height,
    double? width,
    Widget? errorWidget,
    BoxFit? fit,
    Widget? placeholder,
    int maxRetries = maxRetryAttempts,
  }) {
    final w = width ?? height ?? 60;
    final h = height ?? width ?? 60;
    final fallbackSize = w < h ? w : h;

    final defaultErr = errorWidget ??
        Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorStyles.backgroundPrimary,
          ),
          child: Icon(
            Icons.person,
            size: fallbackSize * 0.6,
            color: AppColorStyles.contentSecondary,
          ),
        );

    final defaultPh = placeholder ??
        Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorStyles.backgroundPrimary,
          ),
        );

    return ClipOval(
      child: _CachedNetworkImageWithRetry(
        imageUrl: imageUrl,
        height: h,
        width: w,
        fit: fit ?? BoxFit.cover,
        maxHeightDiskCache: 600,
        maxWidthDiskCache: 600,
        filterQuality: FilterQuality.high,
        placeholder: defaultPh,
        errorWidget: defaultErr,
        maxRetries: maxRetries,
      ),
    );
  }

  /// Unified method để load icon/image từ asset hoặc network.
  /// Auto-detect (http/https = network, còn lại = asset). Hỗ trợ cả SVG và regular images.
  ///
  /// Lazy Loading Strategy với Retry:
  /// 1. Show cached version ngay (~3-50ms) ✅
  /// 2. Verify + (re)download trong background, tối đa [maxRetries] lần
  /// 3. Nếu fail tất cả retry → clear cache, hiển thị errorWidget
  static Widget load({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
    int? cacheWidth,
    int? cacheHeight,
    int maxRetries = maxRetryAttempts,
  }) {
    final normalizedPath = _normalizePath(path);
    final isNetwork = _isNetworkPath(normalizedPath);
    final lowerPath = normalizedPath.toLowerCase();
    final isSvg = lowerPath.endsWith('.svg');

    if (!isNetwork) {
      if (isSvg) {
        return getSVG(
          path: normalizedPath,
          width: width,
          height: height,
          color: color,
          fit: fit ?? BoxFit.scaleDown,
        );
      }
      return getImage(
        path: normalizedPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorWidget: errorWidget,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        borderRadius: borderRadius,
      );
    }

    // Network on web → dùng browser cache (CachedNetworkImage / SvgPicture.network)
    if (kIsWeb) {
      if (isSvg) {
        return getSVG(
          path: normalizedPath,
          width: width,
          height: height,
          color: color,
          fit: fit ?? BoxFit.scaleDown,
        );
      }
      return getNetworkImage(
        imageUrl: normalizedPath,
        width: width,
        height: height,
        fit: fit,
        errorWidget: errorWidget,
        placeholder: placeholder,
        borderRadius: borderRadius,
        maxRetries: maxRetries,
      );
    }

    // Mobile/Desktop: lazy loading với disk cache + retry
    return _LazyLoadingImageWidget(
      key: ValueKey('lazy_${normalizedPath}_${color?.hashCode ?? 0}'),
      url: normalizedPath,
      isSvg: isSvg,
      width: width,
      height: height,
      color: color,
      fit: fit,
      errorWidget: errorWidget,
      placeholder: placeholder,
      borderRadius: borderRadius,
      maxRetries: maxRetries,
    );
  }
}

// ============================================================
// Internal stateful widgets
// ============================================================

/// Wrapper cho [CachedNetworkImage] với retry logic.
///
/// - Retry tối đa [maxRetries] lần khi load lỗi (exponential backoff).
/// - Sau mỗi lần fail → evict khỏi memory image cache + clear disk cache cho URL,
///   để retry tiếp theo download lại từ đầu (KHÔNG dùng file lỗi).
/// - Sau khi hết retry → clear cache lần cuối + hiển thị errorWidget.
class _CachedNetworkImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int maxHeightDiskCache;
  final int maxWidthDiskCache;
  final FilterQuality filterQuality;
  final int maxRetries;

  const _CachedNetworkImageWithRetry({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxHeightDiskCache = 1200,
    this.maxWidthDiskCache = 1200,
    this.filterQuality = FilterQuality.high,
    this.maxRetries = ImageHelper.maxRetryAttempts,
  });

  @override
  State<_CachedNetworkImageWithRetry> createState() =>
      _CachedNetworkImageWithRetryState();
}

class _CachedNetworkImageWithRetryState
    extends State<_CachedNetworkImageWithRetry> {
  int _retryCount = 0;
  bool _scheduledRetry = false;
  bool _scheduledFailureCleanup = false;

  @override
  void didUpdateWidget(_CachedNetworkImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retryCount = 0;
      _scheduledRetry = false;
      _scheduledFailureCleanup = false;
    }
  }

  Future<void> _scheduleRetry() async {
    if (_scheduledRetry || !mounted) return;
    _scheduledRetry = true;

    // Evict broken entry trước khi retry
    try {
      await CachedNetworkImage.evictFromCache(widget.imageUrl);
      await AssetsCacheManager.clearCacheForUrl(widget.imageUrl);
    } catch (_) {
      // Ignore cleanup errors
    }

    // Exponential backoff
    final delay = Duration(milliseconds: 500 * (_retryCount + 1));
    await Future<void>.delayed(delay);

    if (!mounted) return;
    setState(() {
      _retryCount++;
      _scheduledRetry = false;
    });
  }

  Future<void> _onPermanentFailure() async {
    if (_scheduledFailureCleanup) return;
    _scheduledFailureCleanup = true;
    try {
      await CachedNetworkImage.evictFromCache(widget.imageUrl);
      await AssetsCacheManager.clearCacheForUrl(widget.imageUrl);
    } catch (_) {
      // Ignore cleanup errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      // Đổi key mỗi lần retry để force re-fetch (tránh đọc lại broken cache trong session)
      key: ValueKey('${widget.imageUrl}_$_retryCount'),
      imageUrl: widget.imageUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      maxHeightDiskCache: widget.maxHeightDiskCache,
      maxWidthDiskCache: widget.maxWidthDiskCache,
      filterQuality: widget.filterQuality,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!
          : null,
      errorWidget: (context, url, error) {
        if (_retryCount < widget.maxRetries) {
          // Schedule retry trên next frame, hiển thị placeholder trong khi chờ
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scheduleRetry();
          });
          return widget.placeholder ??
              ImageHelper._defaultPlaceholder(widget.width, widget.height);
        }
        // Hết retry → clear cache + show error widget
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onPermanentFailure();
        });
        return widget.errorWidget ??
            ImageHelper._defaultErrorWidget(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
            );
      },
    );

    if (widget.borderRadius != null && widget.borderRadius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        child: image,
      );
    }
    return image;
  }
}

/// Lazy loading image (Mobile/Desktop) với retry.
///
/// - Step 1: Hiển thị cached version ngay nếu có (optimistic).
/// - Step 2: Verify + (re)download trong background với retry tối đa [maxRetries] lần.
/// - Step 3: Nếu hết retry mà fail → clear cache, hiển thị error widget.
class _LazyLoadingImageWidget extends StatefulWidget {
  final String url;
  final bool isSvg;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final double? borderRadius;
  final int maxRetries;

  const _LazyLoadingImageWidget({
    super.key,
    required this.url,
    required this.isSvg,
    this.width,
    this.height,
    this.color,
    this.fit,
    this.errorWidget,
    this.placeholder,
    this.borderRadius,
    this.maxRetries = ImageHelper.maxRetryAttempts,
  });

  @override
  State<_LazyLoadingImageWidget> createState() =>
      _LazyLoadingImageWidgetState();
}

class _LazyLoadingImageWidgetState extends State<_LazyLoadingImageWidget> {
  // Static dedup cache để tránh nhiều widget cùng download một URL.
  // Key: URL, Value: future trả về File hợp lệ (hoặc null nếu fail tất cả retry).
  static final Map<String, Future<File?>> _verificationCache = {};
  static const int _maxVerificationCacheSize = 50;

  File? _cachedFile;
  String? _cachedSvgContent;
  // Cache future để FutureBuilder không tạo lại file read mỗi lần build.
  Future<String>? _cachedSvgReadFuture;
  bool _hasError = false;
  bool _disposed = false;

  static void _cleanupVerificationCacheIfNeeded() {
    if (_verificationCache.length > _maxVerificationCacheSize) {
      final keysToRemove = _verificationCache.keys
          .take(_maxVerificationCacheSize ~/ 5)
          .toList();
      for (final key in keysToRemove) {
        _verificationCache.remove(key);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(_LazyLoadingImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.isSvg != widget.isSvg) {
      // URL/type thay đổi → reset state và load lại
      setState(() {
        _cachedFile = null;
        _cachedSvgContent = null;
        _cachedSvgReadFuture = null;
        _hasError = false;
      });
      _bootstrap();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadCachedVersion();
    if (_disposed) return;
    await _verifyInBackgroundWithRetry();
  }

  /// Step 1: Load cached version ngay (không download mới).
  /// Validate file size để bỏ qua file cache lỗi.
  Future<void> _loadCachedVersion() async {
    try {
      final normalizedUrl = widget.url.trim();
      final asset = AssetsCacheManager.getAssetForUrl(normalizedUrl);
      final cacheKey = asset != null
          ? AssetsCacheManager.getCacheKeyForIcon(asset)
          : normalizedUrl;

      // Memory cache cho SVG (fastest)
      if (widget.isSvg) {
        final cachedSvgString =
            AssetsCacheManager.getCachedSvgString(cacheKey);
        if (cachedSvgString != null && mounted) {
          setState(() {
            _cachedSvgContent = cachedSvgString;
          });
          return;
        }
      }

      final cachedFile =
          await AssetsCacheManager.getCachedFileForUrlWithVersioning(
        normalizedUrl,
      );

      if (cachedFile == null || !mounted) return;

      // Validate file size — nếu cached file lỗi → clear, để verification download lại
      try {
        final size = await cachedFile.length();
        if (size < ImageHelper._minValidFileSize) {
          await AssetsCacheManager.clearCacheForUrl(normalizedUrl);
          return;
        }
      } catch (_) {
        return;
      }

      if (!mounted) return;
      setState(() {
        _cachedFile = cachedFile;
      });

      if (widget.isSvg) {
        try {
          final content = await cachedFile.readAsString();
          if (!mounted) return;
          AssetsCacheManager.cacheSvgString(cacheKey, content);
          setState(() {
            _cachedSvgContent = content;
          });
        } catch (_) {
          // Ignore read errors
        }
      }
    } catch (_) {
      // Ignore — sẽ download trong background
    }
  }

  /// Step 2: Verify (hoặc download) với retry tối đa maxRetries lần.
  Future<void> _verifyInBackgroundWithRetry() async {
    final normalizedUrl = widget.url.trim();

    // Dedup: nếu đã có verification đang chạy cho URL này → đợi nó
    final existing = _verificationCache[normalizedUrl];
    if (existing != null) {
      try {
        final file = await existing;
        if (!mounted) return;
        if (file != null) {
          await _onDownloadSuccess(file);
        } else if (_cachedFile == null) {
          setState(() {
            _hasError = true;
          });
        }
      } catch (_) {
        if (mounted && _cachedFile == null) {
          setState(() {
            _hasError = true;
          });
        }
      }
      return;
    }

    _cleanupVerificationCacheIfNeeded();

    final future = ImageHelper._downloadFileWithRetry(normalizedUrl);
    _verificationCache[normalizedUrl] = future;

    try {
      final file = await future;
      if (!mounted) return;
      if (file != null) {
        await _onDownloadSuccess(file);
      } else if (_cachedFile == null) {
        setState(() {
          _hasError = true;
        });
      }
    } catch (_) {
      if (mounted && _cachedFile == null) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      _verificationCache.remove(normalizedUrl);
    }
  }

  Future<void> _onDownloadSuccess(File file) async {
    if (!mounted) return;
    final normalizedUrl = widget.url.trim();
    final asset = AssetsCacheManager.getAssetForUrl(normalizedUrl);
    final cacheKey = asset != null
        ? AssetsCacheManager.getCacheKeyForIcon(asset)
        : normalizedUrl;

    if (widget.isSvg) {
      try {
        final content = await file.readAsString();
        if (!mounted) return;
        AssetsCacheManager.cacheSvgString(cacheKey, content);
        setState(() {
          _cachedFile = file;
          _cachedSvgContent = content;
          _cachedSvgReadFuture = null;
          _hasError = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _cachedFile = file;
          _cachedSvgReadFuture = null;
          _hasError = false;
        });
      }
    } else {
      setState(() {
        _cachedFile = file;
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedFile != null) {
      if (widget.isSvg) {
        if (_cachedSvgContent != null) {
          return svg.SvgPicture.string(
            _cachedSvgContent!,
            width: widget.width,
            height: widget.height,
            colorFilter: widget.color != null
                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                : null,
            fit: widget.fit ?? BoxFit.scaleDown,
            placeholderBuilder: (context) =>
                widget.placeholder ??
                ImageHelper._defaultPlaceholder(widget.width, widget.height),
          );
        }
        // Cache future để không tạo lại Future read file mỗi lần build (anti-pattern)
        _cachedSvgReadFuture ??= _cachedFile!.readAsString();
        return FutureBuilder<String>(
          future: _cachedSvgReadFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return svg.SvgPicture.string(
                snapshot.data!,
                width: widget.width,
                height: widget.height,
                colorFilter: widget.color != null
                    ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                    : null,
                fit: widget.fit ?? BoxFit.scaleDown,
                placeholderBuilder: (context) =>
                    widget.placeholder ??
                    ImageHelper._defaultPlaceholder(
                      widget.width,
                      widget.height,
                    ),
              );
            }
            if (snapshot.hasError) {
              return widget.errorWidget ??
                  ImageHelper._defaultErrorWidget(
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                  );
            }
            return widget.placeholder ??
                ImageHelper._defaultPlaceholder(widget.width, widget.height);
          },
        );
      }

      final image = Image.file(
        _cachedFile!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) =>
            widget.errorWidget ??
            ImageHelper._defaultErrorWidget(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
            ),
      );
      if (widget.borderRadius != null && widget.borderRadius! > 0) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius!),
          child: image,
        );
      }
      return image;
    }

    if (_hasError) {
      return widget.errorWidget ??
          ImageHelper._defaultErrorWidget(
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
          );
    }

    return widget.placeholder ??
        ImageHelper._defaultPlaceholder(widget.width, widget.height);
  }
}

/// SVG network widget cho web với memory cache + retry.
///
/// - Cache theo URL (web session) để tránh duplicate request trong session.
/// - Retry [ImageHelper.maxRetryAttempts] lần khi fetch fail.
/// - Khi fail tất cả retry → KHÔNG cache string (caller sẽ thấy errorWidget).
class _CachedSvgNetworkWidget extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const _CachedSvgNetworkWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.scaleDown,
  });

  @override
  State<_CachedSvgNetworkWidget> createState() =>
      _CachedSvgNetworkWidgetState();
}

class _CachedSvgNetworkWidgetState extends State<_CachedSvgNetworkWidget> {
  // Cache string đã thành công (KHÔNG cache khi fail).
  static final Map<String, String> _svgStringCache = {};
  // Dedup các request đang chạy.
  static final Map<String, Future<String>> _svgFutureCache = {};
  static const int _maxCacheSize = 100;

  String? _cachedSvgString;
  Future<String>? _svgStringFuture;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(_CachedSvgNetworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _cachedSvgString = null;
      _svgStringFuture = null;
      _loadSvg();
    }
  }

  static void _cleanupCacheIfNeeded() {
    if (_svgStringCache.length > _maxCacheSize) {
      final keysToRemove =
          _svgStringCache.keys.take(_maxCacheSize ~/ 5).toList();
      for (final key in keysToRemove) {
        _svgStringCache.remove(key);
      }
    }
  }

  /// Fetch SVG string với retry. Throw nếu fail hết retry.
  /// QUAN TRỌNG: Caller KHÔNG được cache nếu method này throw — đó là cách
  /// đảm bảo "load fail → không lưu vào cache".
  ///
  /// Timeout per-attempt: nếu mạng yếu, request vượt [ImageHelper._perAttemptTimeout]
  /// sẽ throw TimeoutException và trigger retry, không để request treo vô hạn.
  static Future<String> _fetchSvgWithRetry(String url) async {
    Object? lastError;
    for (int attempt = 1; attempt <= ImageHelper.maxRetryAttempts; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(ImageHelper._perAttemptTimeout);
        if (response.statusCode == 200 &&
            response.body.length >= ImageHelper._minValidFileSize) {
          return response.body;
        }
        lastError = Exception(
          'HTTP ${response.statusCode}, body length ${response.body.length}',
        );
      } on TimeoutException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }

      if (attempt < ImageHelper.maxRetryAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    throw Exception(
      'Failed to load SVG after ${ImageHelper.maxRetryAttempts} retries: '
      '$lastError',
    );
  }

  void _loadSvg() {
    final normalizedUrl = ImageHelper._normalizePath(widget.url);
    final cacheKey = normalizedUrl;

    // Step 1: Check static cache (chỉ chứa kết quả thành công)
    final cached = _svgStringCache[cacheKey];
    if (cached != null) {
      _cachedSvgString = cached;
      if (mounted) setState(() {});
      return;
    }

    // Step 2: Dedup + fetch with retry
    _svgStringFuture = _svgFutureCache.putIfAbsent(cacheKey, () async {
      try {
        final svgString = await _fetchSvgWithRetry(normalizedUrl);
        // CHỈ cache khi thành công
        _svgStringCache[cacheKey] = svgString;
        _cleanupCacheIfNeeded();
        _svgFutureCache.remove(cacheKey);
        return svgString;
      } catch (e) {
        // KHÔNG cache khi fail
        _svgFutureCache.remove(cacheKey);
        rethrow;
      }
    });

    _svgStringFuture!.then((svgString) {
      if (!mounted) return;
      setState(() {
        _cachedSvgString = svgString;
      });
    }).catchError((Object _) {
      // Lỗi sẽ được handle bởi FutureBuilder (hiển thị error icon)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedSvgString != null) {
      return svg.SvgPicture.string(
        _cachedSvgString!,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholderBuilder: (context) =>
            ImageHelper._defaultPlaceholder(widget.width, widget.height),
      );
    }

    if (_svgStringFuture == null) {
      return ImageHelper._defaultPlaceholder(widget.width, widget.height);
    }

    return FutureBuilder<String>(
      future: _svgStringFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return svg.SvgPicture.string(
            snapshot.data!,
            colorFilter: widget.color != null
                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                : null,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholderBuilder: (context) =>
                ImageHelper._defaultPlaceholder(widget.width, widget.height),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: Icon(Icons.error)),
          );
        }
        return ImageHelper._defaultPlaceholder(widget.width, widget.height);
      },
    );
  }
}
