import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:http/http.dart' as http;
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/cached_manager.dart';

class ImageHelper {
  // static String imageURL(String path) {
  //   return '${Constants.SERVER_URL}/view-file?path=$path';
  // }

  /// Create default placeholder widget (empty SizedBox)
  /// Shared helper để tránh code duplication
  static Widget _defaultPlaceholder(double? width, double? height) {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: SizedBox.shrink()),
    );
  }

  /// Normalize path: decode URL encoding và remove assets/ prefix nếu cần
  /// Shared helper để tránh code duplication
  static String _normalizePath(String path) {
    String normalizedPath = path.trim();

    // Decode URL if it was double-encoded (fix for web issue)
    // Example: "assets/https%253A//" -> "https://"
    try {
      // Decode multiple times if needed (handle double/triple encoding)
      // %253A = double-encoded %3A, %3A = encoded :
      int maxDecodeAttempts = 3;
      for (int i = 0; i < maxDecodeAttempts; i++) {
        if (normalizedPath.contains('%25') || normalizedPath.contains('%3A')) {
          try {
            final decoded = Uri.decodeComponent(normalizedPath);
            // Only update if decoding actually changed something
            if (decoded != normalizedPath) {
              normalizedPath = decoded;
            } else {
              break; // No more decoding needed
            }
          } catch (e) {
            // If decoding fails, stop trying
            break;
          }
        } else {
          break; // No encoding found, stop
        }
      }

      // IMPORTANT: Only remove "assets/" prefix if it's a network URL
      // (web issue - Flutter engine may add "assets/" prefix to network URLs)
      // Do NOT remove for local asset paths like "assets/icons/icon.svg"
      if (normalizedPath.startsWith('assets/')) {
        // Check if it's a network URL (after decoding)
        // If it contains encoded URL patterns, it's likely a network URL
        if (normalizedPath.contains('%3A') ||
            normalizedPath.contains('http') ||
            normalizedPath.contains('://')) {
          // This is a network URL with "assets/" prefix added by Flutter engine
          normalizedPath = normalizedPath.substring(7);
        }
        // Otherwise, keep "assets/" prefix for local assets
      }
    } catch (e) {
      // If decoding fails, use original path
      // This can happen if path is already properly formatted
    }

    return normalizedPath;
  }

  //Widget svg or imge
  static Widget getSVG({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.scaleDown,
  }) {
    // Normalize path: decode URL encoding và remove assets/ prefix nếu cần
    final normalizedPath = _normalizePath(path);

    // Check if path is a network URL (after normalization)
    final isNetwork =
        normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://');

    if (isNetwork) {
      // On web, use cached SVG widget to avoid duplicate network requests
      if (kIsWeb) {
        return _CachedSvgNetworkWidget(
          key: ValueKey('svg_${normalizedPath}_${color?.value ?? 0}'),
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

    // It's a local asset path
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

  /// Precache SVG để tránh delay khi hiển thị
  /// Bằng cách load và parse SVG để cache picture
  ///
  /// On Web: Load và parse SVG để cache picture (memory).
  /// On Mobile/Desktop: Parse SVG để cache picture
  static Future<void> precacheSVG(BuildContext context, String path) async {
    try {
      // Check if path is a network URL
      final isNetwork =
          path.startsWith('http://') || path.startsWith('https://');

      if (isNetwork) {
        // Mobile/Desktop: Parse SVG để cache picture (flutter_svg sẽ cache)
        try {
          final loader = svg.SvgNetworkLoader(path);
          await svg.vg.loadPicture(loader, null);
        } catch (e) {
          // Ignore precache errors - SVG will load when needed
        }
      } else {
        // For local assets, use SvgAssetLoader
        try {
          final loader = svg.SvgAssetLoader(path);
          await svg.vg.loadPicture(loader, null);
        } catch (e) {
          // Ignore precache errors - SVG will load when needed
        }
      }

      // Picture đã được cache tự động bởi flutter_svg
      // Khi sử dụng SvgPicture.asset hoặc SvgPicture.network sau này, nó sẽ lấy từ cache
    } catch (e) {
      // Nếu precache thất bại, SVG vẫn sẽ được load khi cần
      // Ignore precache errors để không ảnh hưởng đến app
    }
  }

  static Widget getImage({
    required String path,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    Widget? errorWidget,
    int? cacheWidth,
    int? cacheHeight,
  }) => Image.asset(
    path,
    width: width,
    height: height,
    color: color,
    fit: fit,
    cacheWidth: cacheWidth,
    cacheHeight: cacheHeight,
    errorBuilder: (context, error, stackTrace) => Container(
      width: width,
      height: height ?? 144,
      decoration: const BoxDecoration(color: AppColorStyles.backgroundPrimary),
      child: Center(
        child:
            errorWidget ??
            const Icon(Icons.error, color: AppColorStyles.contentSecondary),
      ),
    ),
  );

  /// Precache Image để tránh delay khi hiển thị
  ///
  /// On Web: Browser tự động cache assets, không cần precache
  /// On Mobile/Desktop: Precache để tăng tốc độ load
  static Future<void> precacheAssetImage(
    BuildContext context,
    String path,
  ) async {
    // Web: Không cần precache, browser tự động cache assets
    if (kIsWeb) {
      return;
    }

    try {
      final imageProvider = AssetImage(path);
      await precacheImage(imageProvider, context);
    } catch (e) {
      // Ignore precache errors
    }
  }

  /// Precache network image để load vào browser memory cache
  /// Giúp images load nhanh hơn từ memory cache thay vì disk cache
  ///
  /// IMPORTANT:
  /// - Web/Mobile/Desktop: Precache để load vào memory cache
  /// - Chỉ dùng cho regular images (PNG, JPEG, WebP), KHÔNG dùng cho SVG
  /// - Để precache SVG, dùng precacheSVG() thay vì method này
  ///
  /// Usage: Call on app startup để preload critical images
  ///
  /// Example:
  /// ```dart
  /// await ImageHelper.precacheNetworkImage(context, AppImages.logoChampion);
  /// ```
  static Future<void> precacheNetworkImage(
    BuildContext context,
    String imageUrl,
  ) async {
    // Check if it's SVG - don't precache SVG with Image.network
    // SVG should use precacheSVG() instead
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      // Skip SVG - use precacheSVG() instead
      return;
    }

    try {
      // Mobile/Desktop: Precache image để tăng tốc độ load
      final image = Image.network(imageUrl);
      await precacheImage(image.image, context);
    } catch (e) {
      // Ignore precache errors - image will load when needed
    }
  }

  static Widget getNetworkImage({
    required String imageUrl,
    double? height,
    double? width,
    Widget? errorWidget,
    BoxFit? fit,
    Widget? placeholder,
    double? borderRadius,
    double? sizeLoading = 50,
  }) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      maxHeightDiskCache: 1200,
      maxWidthDiskCache: 1200,
      filterQuality: FilterQuality.high,
      fadeInDuration: Duration.zero,
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height ?? 144,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 6),
          color: AppColorStyles.backgroundPrimary,
        ),
        child: Center(
          child:
              errorWidget ??
              const Icon(Icons.error, color: AppColorStyles.contentSecondary),
        ),
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

  /// Optimized method cho logo nhỏ (team, league logos)
  /// Sử dụng cache size phù hợp và FilterQuality.low để giảm CPU usage
  static Widget getSmallLogo({
    required String imageUrl,
    required double size,
    Widget? errorWidget,
    Widget? placeholder,
    double? borderRadius,
  }) {
    // Cache size = 2x display size để đảm bảo chất lượng trên high DPI screens
    final cacheSize = (size * 2).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // Cache size phù hợp với kích thước hiển thị
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        maxHeightDiskCache: cacheSize,
        maxWidthDiskCache: cacheSize,
        // FilterQuality.low cho logo nhỏ - tiết kiệm CPU
        filterQuality: FilterQuality.low,
        // Không fade để hiển thị ngay
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        // Placeholder nhẹ
        placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Icon(
              Icons.sports_soccer,
              size: size * 0.7,
              color: AppColorStyles.contentSecondary,
            ),
      ),
    );
  }

  // static Future<Uint8List?> getVideoThumbnail(String videoUrl) async {
  //   try {
  //     final data = await VideoThumbnail.thumbnailData(
  //       video: videoUrl,
  //       imageFormat: ImageFormat.JPEG,
  //       maxHeight: 300,
  //       quality: 90,
  //       maxWidth: 300,
  //     );

  //     return data;
  //   } catch (e) {
  //     LogHelper.error('Error getting video thumbnail: $e');
  //     return null;
  //   }
  // }

  static Widget getAvatar({
    required String imageUrl,
    double? height,
    double? width,
    Widget? errorWidget,
    BoxFit? fit,
    Widget? placeholder,
  }) {
    final size = width ?? height ?? 60;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: size,
        width: size,
        fit: fit ?? BoxFit.cover,
        maxHeightDiskCache: 600,
        maxWidthDiskCache: 600,
        filterQuality: FilterQuality.high,
        fadeInDuration: Duration.zero,
        // placeholder: (context, url) =>
        //     placeholder ??
        //     Container(
        //       height: size,
        //       width: size,
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: AppColors.grey.withOpacity(0.1),
        //       ),
        //       child: Center(
        //         child: LoadingAnimationWidget.threeArchedCircle(
        //           color: AppColors.grey,
        //           size: size / 2,
        //         ),
        //       ),
        //     ),
        // errorWidget: (context, url, error) =>
        //     errorWidget ??
        //     Container(
        //       height: size,
        //       width: size,
        //       decoration:const  BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: AppColors.white,
        //       ),
        //       child: SvgPicture.asset(
        //        AppIcons.defaultAvatar,
        //         width: size,
        //         height: size,
        //         fit: BoxFit.cover,
        //       ),
        //     ),
      ),
    );
  }

  /// Unified method để load icon/image từ asset hoặc network
  /// Auto-detect dựa trên path (http/https = network, còn lại = asset)
  /// Hỗ trợ cả SVG và regular images
  ///
  /// Lazy Loading Strategy với Parallel Processing:
  /// 1. Show cached version ngay (~3-50ms) ✅
  /// 2. Download và check hash trong background (~106-825ms)
  /// 3. Update UI nếu hash khác
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
  }) {
    // Normalize path: decode URL encoding và remove assets/ prefix nếu cần
    final normalizedPath = _normalizePath(path);

    // Check if path is a network URL (after normalization)
    final isNetwork =
        normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://');
    // Cache lowercase result để tránh gọi nhiều lần
    final lowerPath = normalizedPath.toLowerCase();
    final isSvg = lowerPath.endsWith('.svg');

    if (!isNetwork) {
      // Asset: Load trực tiếp
      if (isSvg) {
        return getSVG(
          path: normalizedPath,
          width: width,
          height: height,
          color: color, // getSVG handles colorFilter internally
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
      );
    }

    // Network: Dùng lazy loading strategy với parallel processing
    // Trên Web: Dùng browser cache tự động (CachedNetworkImage/SvgPicture.network)
    // Trên Mobile/Desktop: Dùng disk cache với lazy loading
    if (kIsWeb) {
      // Web: Browser tự động cache qua HTTP cache headers
      // Không cần disk cache, dùng browser cache

      // Debug logging removed - no debug output

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
      );
    }

    // Mobile/Desktop: Dùng disk cache với lazy loading
    return _LazyLoadingImageWidget(
      url: normalizedPath,
      isSvg: isSvg,
      width: width,
      height: height,
      color: color,
      fit: fit,
      errorWidget: errorWidget,
      placeholder: placeholder,
      borderRadius: borderRadius,
    );
  }
}

/// Widget để handle lazy loading strategy với parallel processing
/// Show cached version trước, verify hash sau trong background
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

  const _LazyLoadingImageWidget({
    required this.url,
    required this.isSvg,
    this.width,
    this.height,
    this.color,
    this.fit,
    this.errorWidget,
    this.placeholder,
    this.borderRadius,
  });

  @override
  State<_LazyLoadingImageWidget> createState() =>
      _LazyLoadingImageWidgetState();
}

class _LazyLoadingImageWidgetState extends State<_LazyLoadingImageWidget> {
  // Static cache để tránh duplicate verification requests
  // Key: URL, Value: Future<void> của verification process
  static final Map<String, Future<void>> _verificationCache = {};
  // Memory limit: max 50 verification futures in cache (prevent memory leak)
  static const int _maxVerificationCacheSize = 50;

  File? _cachedFile;
  String?
  _cachedSvgContent; // Cache SVG content để tránh đọc file mỗi lần build
  bool _isVerifying = false;
  bool _hasError = false;

  /// Cleanup old verification cache entries if cache size exceeds limit
  static void _cleanupVerificationCacheIfNeeded() {
    if (_verificationCache.length > _maxVerificationCacheSize) {
      // Remove oldest entries (simple FIFO: remove first 20%)
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
    _loadCachedVersion();
    _verifyInBackground();
  }

  /// Step 1: Load cached version ngay (optimistic)
  /// Sử dụng AssetsCacheManager với memory cache layer và versioning support
  /// Tự động detect AssetsData từ registry để dùng versioning
  Future<void> _loadCachedVersion() async {
    try {
      final normalizedUrl = widget.url.trim();

      // Check if URL has registered AssetsData (versioning)
      final asset = AssetsCacheManager.getAssetForUrl(normalizedUrl);
      final cacheKey = asset != null
          ? AssetsCacheManager.getCacheKeyForIcon(asset)
          : normalizedUrl;

      // Step 1: Check memory cache cho SVG string (fastest)
      // Dùng cacheKey để check memory cache (support versioning)
      if (widget.isSvg) {
        final cachedSvgString = AssetsCacheManager.getCachedSvgString(cacheKey);
        if (cachedSvgString != null && mounted) {
          setState(() {
            _cachedSvgContent = cachedSvgString;
          });
          return; // Đã có trong memory cache, không cần load file
        }
      }

      // Step 2: Get cached file với versioning support
      // Method này tự động detect AssetsData và dùng versioning nếu có
      final cachedFile =
          await AssetsCacheManager.getCachedFileForUrlWithVersioning(
            normalizedUrl,
          );

      if (cachedFile != null && mounted) {
        setState(() {
          _cachedFile = cachedFile;
        });
        // Pre-load SVG content vào memory cache nếu là SVG
        // Dùng cacheKey để cache vào memory (support versioning)
        if (widget.isSvg) {
          cachedFile.readAsString().then((content) {
            if (mounted) {
              // Cache vào memory với cacheKey (có versioning nếu có AssetsData)
              AssetsCacheManager.cacheSvgString(cacheKey, content);
              setState(() {
                _cachedSvgContent = content;
              });
            }
          });
        }
      }
    } catch (e) {
      // Ignore errors, sẽ download trong background
    }
  }

  /// Step 2: Verify hash trong background (parallel processing)
  /// Note: AssetsCacheManager đã được init ở app startup (app.dart)
  /// Sử dụng static cache để tránh duplicate requests cho cùng URL
  Future<void> _verifyInBackground() async {
    if (_isVerifying) return;

    // Normalize URL
    final normalizedUrl = widget.url.trim();

    // Check if verification is already in progress for this URL
    final existingVerification = _verificationCache[normalizedUrl];
    if (existingVerification != null) {
      // Wait for existing verification to complete
      await existingVerification;
      // Reload cached file after verification completes
      if (mounted) {
        _loadCachedVersion();
      }
      return;
    }

    _isVerifying = true;

    // Cleanup old entries if cache is too large
    _cleanupVerificationCacheIfNeeded();

    // Create verification future and cache it
    final verificationFuture = _performVerification(normalizedUrl);
    _verificationCache[normalizedUrl] = verificationFuture;

    try {
      await verificationFuture;
    } finally {
      // Remove from cache after completion
      _verificationCache.remove(normalizedUrl);
      _isVerifying = false;
    }
  }

  /// Perform actual verification (download and check hash)
  /// Sử dụng AssetsCacheManager với memory cache layer và versioning support
  /// Tự động detect AssetsData từ registry để dùng versioning
  Future<void> _performVerification(String normalizedUrl) async {
    try {
      // Sử dụng getSingleFileForUrlWithVersioning để download và cache tự động
      // Method này tự động detect AssetsData và dùng versioning nếu có
      final file = await AssetsCacheManager.getSingleFileForUrlWithVersioning(
        normalizedUrl,
      );

      // Check if file exists and is valid
      if (!await file.exists()) {
        if (mounted && _cachedFile == null) {
          setState(() {
            _hasError = true;
          });
        }
        return;
      }

      // Check file size (minimum 10 bytes)
      final fileSize = await file.length();
      if (fileSize < 10) {
        if (mounted && _cachedFile == null) {
          setState(() {
            _hasError = true;
          });
        }
        return;
      }

      // File đã được cache bởi flutter_cache_manager và memory cache
      // Pre-load SVG content vào memory cache nếu là SVG
      // Dùng cacheKey để cache (support versioning)
      if (widget.isSvg) {
        try {
          final content = await file.readAsString();
          // Get cacheKey với versioning support
          final asset = AssetsCacheManager.getAssetForUrl(normalizedUrl);
          final cacheKey = asset != null
              ? AssetsCacheManager.getCacheKeyForIcon(asset)
              : normalizedUrl;
          AssetsCacheManager.cacheSvgString(cacheKey, content);
        } catch (e) {
          // Ignore read errors
        }
      }

      // Reload cached file để update UI
      if (mounted) {
        await _loadCachedVersion();
      }
    } catch (e) {
      // Ignore errors trong background check
      // Cached version vẫn hiển thị, không ảnh hưởng UX
      if (mounted && _cachedFile == null) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show cached version nếu có
    if (_cachedFile != null) {
      if (widget.isSvg) {
        // SvgPicture.file() không chấp nhận File từ dart:io
        // Sử dụng SvgPicture.string với cached content từ memory cache
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
        // Nếu chưa có cached content, load async và cache vào memory
        return FutureBuilder<String>(
          future: _cachedFile!.readAsString(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final content = snapshot.data!;
              // Cache vào memory cache để lần sau load nhanh hơn
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  // Use cacheKey với versioning support (đã tính toán ở _loadCachedVersion)
                  final normalizedUrl = widget.url.trim();
                  final asset = AssetsCacheManager.getAssetForUrl(
                    normalizedUrl,
                  );
                  final cacheKey = asset != null
                      ? AssetsCacheManager.getCacheKeyForIcon(asset)
                      : normalizedUrl;
                  AssetsCacheManager.cacheSvgString(cacheKey, content);
                  setState(() {
                    _cachedSvgContent = content;
                  });
                }
              });
              return svg.SvgPicture.string(
                content,
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
            widget.errorWidget ?? const Icon(Icons.error),
      );

      if (widget.borderRadius != null && widget.borderRadius! > 0) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius!),
          child: image,
        );
      }

      return image;
    }

    // No cache hoặc error → Show placeholder hoặc download normally
    if (_hasError) {
      return widget.errorWidget ??
          const Icon(Icons.error, color: AppColorStyles.contentSecondary);
    }

    // Show placeholder while downloading
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    // Download normally (fallback)
    return widget.isSvg
        ? ImageHelper.getSVG(
            path: widget.url,
            width: widget.width,
            height: widget.height,
            color: widget.color,
            fit: widget.fit ?? BoxFit.scaleDown,
          )
        : ImageHelper.getNetworkImage(
            imageUrl: widget.url,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorWidget: widget.errorWidget,
            borderRadius: widget.borderRadius,
          );
  }
}

/// Cached SVG network widget for web
/// Reuses the same SVG string for the same URL to avoid duplicate network requests
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
  // Static cache for SVG strings (web only)
  // Key: URL, Value: completed SVG string (null if still loading)
  static final Map<String, String?> _svgStringCache = {};
  // Cache for in-progress requests to avoid duplicate network calls
  static final Map<String, Future<String>> _svgFutureCache = {};
  // Memory limit: max 100 SVG strings in cache (prevent memory leak)
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
    // Reload if URL changed
    if (oldWidget.url != widget.url) {
      _loadSvg();
    }
  }

  /// Cleanup old cache entries if cache size exceeds limit
  static void _cleanupCacheIfNeeded() {
    if (_svgStringCache.length > _maxCacheSize) {
      // Remove oldest entries (simple FIFO: remove first 20%)
      final keysToRemove = _svgStringCache.keys
          .take(_maxCacheSize ~/ 5)
          .toList();
      for (final key in keysToRemove) {
        _svgStringCache.remove(key);
      }
    }
  }

  void _loadSvg() {
    // Normalize URL using shared helper method
    final normalizedUrl = ImageHelper._normalizePath(widget.url);

    // WEB: Browser tự động cache qua HTTP headers, không cần versioning
    // Chỉ cần memory cache với URL đơn giản để tránh duplicate requests trong session
    // Cache key = URL (không cần version)
    final cacheKey = normalizedUrl;

    // Step 1: Check static cache (web memory cache - session only)
    _cachedSvgString = _svgStringCache[cacheKey];
    if (_cachedSvgString != null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    // Step 3: Load from network
    if (_cachedSvgString == null) {
      // Get or create SVG string future from cache
      // This ensures only ONE request per URL, even if multiple widgets are created
      // WEB: Use URL as cache key (browser handles HTTP cache automatically)
      _svgStringFuture = _svgFutureCache.putIfAbsent(cacheKey, () async {
        try {
          final response = await http.get(Uri.parse(normalizedUrl));
          if (response.statusCode == 200) {
            final svgString = response.body;
            // Cache to static memory cache (session only)
            // Browser sẽ tự động cache qua HTTP headers, không cần disk cache
            _svgStringCache[cacheKey] = svgString;
            // Cleanup old entries if cache is too large
            _cleanupCacheIfNeeded();
            // Remove from future cache once completed
            _svgFutureCache.remove(cacheKey);
            return svgString;
          }
          throw Exception('Failed to load SVG: ${response.statusCode}');
        } catch (e) {
          // Remove from future cache on error
          _svgFutureCache.remove(cacheKey);
          rethrow;
        }
      });

      // If future completes, cache the result and update UI
      _svgStringFuture!
          .then((svgString) {
            // Update static memory cache (web session cache)
            // Browser sẽ tự động cache qua HTTP headers, không cần versioning
            // Use cacheKey thay vì normalize lại (đã normalize ở _loadSvg)
            _svgStringCache[cacheKey] = svgString;
            // Cleanup old entries if cache is too large
            _cleanupCacheIfNeeded();

            if (mounted) {
              setState(() {
                _cachedSvgString = svgString;
              });
            }
          })
          .catchError((_) {
            // Error handled in FutureBuilder
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If already cached, show immediately
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

    // Otherwise, wait for future
    if (_svgStringFuture == null) {
      // Should not happen, but handle gracefully
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
          // Show error placeholder
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: Icon(Icons.error)),
          );
        }

        // Show placeholder while loading
        return ImageHelper._defaultPlaceholder(widget.width, widget.height);
      },
    );
  }
}
