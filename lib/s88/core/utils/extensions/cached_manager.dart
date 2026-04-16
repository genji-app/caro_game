import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/assets_data.dart';

class AssetsCacheManager {
  AssetsCacheManager._();
  static CacheManager? _cacheManager;
  static const Duration defaultMaxAge = Duration(days: 14);

  // Memory cache cho SVG strings để tránh đọc file nhiều lần
  // Key: URL, Value: SVG string content
  static final Map<String, String> _svgMemoryCache = {};

  // Memory cache cho file paths để tránh query database nhiều lần
  // Key: URL, Value: File path
  static final Map<String, String> _filePathMemoryCache = {};

  // Registry để map URL → AssetsData (cho versioning)
  // Key: normalized URL, Value: AssetsData
  // Khi URL được register, _loadCachedVersion() sẽ tự động dùng versioning
  static final Map<String, AssetsData> _urlToAssetRegistry = {};

  /// Register AssetsData để enable versioning cho URL
  /// Nên gọi khi app khởi động hoặc khi có AssetsData mới
  ///
  /// Example:
  /// ```dart
  /// AssetsCacheManager.registerAsset(AssetsData(
  ///   label: 'icon_logo',
  ///   urlPath: 'https://.../icon_logo.svg',
  ///   oldVersion: 1,
  ///   newVersion: 2,
  /// ));
  /// ```
  ///
  /// Sau khi register, ImageHelper.load() sẽ tự động dùng versioning:
  /// - Cache key: `icon_logo_v2`
  /// - Tự động clear cache cũ: `icon_logo_v1` (nếu oldVersion != newVersion)
  ///
  /// Note: Tự động clear old version cache khi register (async, không block)
  /// Safe: Wrap trong try-catch để tránh crash nếu có lỗi
  static void registerAsset(AssetsData asset) {
    try {
      final normalizedUrl = asset.urlPath.trim();
      _urlToAssetRegistry[normalizedUrl] = asset;

      // Tự động clear old version cache nếu có version mới
      // Chạy async để không block register process
      if (asset.oldVersion != asset.newVersion) {
        // Use unawaited để không block, catch errors để tránh crash
        Future.microtask(() {
          clearOldVersionsForIcon(asset).catchError((Object e) {
            // Ignore errors khi clear old version - không crash app
            if (kDebugMode) {
              debugPrint(
                'Warning: Failed to clear old version for ${asset.label}: $e',
              );
            }
          });
        });
      }
    } catch (e) {
      // Catch any synchronous errors during registration
      if (kDebugMode) {
        debugPrint('Error registering asset ${asset.label}: $e');
      }
    }
  }

  /// Register nhiều AssetsData cùng lúc
  static void registerAssets(List<AssetsData> assets) {
    for (final asset in assets) {
      registerAsset(asset);
    }
  }

  /// Get AssetsData từ URL (nếu đã register)
  /// Trả về null nếu URL chưa được register
  static AssetsData? getAssetForUrl(String url) {
    return _urlToAssetRegistry[url.trim()];
  }

  /// Clear registry (dùng khi cần reset)
  static void clearRegistry() {
    _urlToAssetRegistry.clear();
  }

  static CacheManager? getInstance({Duration? maxAge}) {
    // Web không support flutter_cache_manager (cần path_provider)
    // Trên web, browser tự động cache qua HTTP headers
    if (kIsWeb) {
      return null;
    }

    _cacheManager ??= CacheManager(
      Config(
        'sports_images_cache',
        stalePeriod: maxAge ?? defaultMaxAge,
        maxNrOfCacheObjects: 100,
        repo: JsonCacheInfoRepository(databaseName: 'sports_images_cache.db'),
      ),
    );
    return _cacheManager!;
  }

  /// Clear toàn bộ cache (disk + memory)
  static Future<void> clearCache() async {
    // Web: Chỉ clear memory cache (browser tự động cache qua HTTP headers)
    if (kIsWeb) {
      _svgMemoryCache.clear();
      _filePathMemoryCache.clear();
      return;
    }

    final cacheManager = getInstance();
    if (cacheManager != null) {
      await cacheManager.emptyCache();
    }
    _cacheManager = null;
    // Clear memory cache
    _svgMemoryCache.clear();
    _filePathMemoryCache.clear();
  }

  /// Clear cache cho một URL cụ thể (disk + memory)
  /// Dùng khi cần force refresh một icon/image cụ thể
  /// Tự động clear cả versioning cache nếu có AssetsData
  static Future<void> clearCacheForUrl(String url) async {
    try {
      final normalizedUrl = url.trim();

      // Web: Chỉ clear memory cache (browser tự động cache qua HTTP headers)
      if (kIsWeb) {
        // Clear memory cache
        _svgMemoryCache.remove(normalizedUrl);
        _filePathMemoryCache.remove(normalizedUrl);

        // Clear versioning cache nếu có
        final asset = getAssetForUrl(normalizedUrl);
        if (asset != null) {
          final cacheKey = getCacheKeyForIcon(
            asset,
            autoClearOldVersions: false,
          );
          _svgMemoryCache.remove(cacheKey);
          _filePathMemoryCache.remove(cacheKey);
        }
        return;
      }

      final cacheManager = getCacheManager();
      if (cacheManager == null) return;

      // Check if URL has registered AssetsData (versioning)
      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        // Clear versioning cache: clear cả old và new version
        final cacheKey = getCacheKeyForIcon(asset, autoClearOldVersions: false);
        await cacheManager.removeFile(cacheKey);
        _svgMemoryCache.remove(cacheKey);
        _filePathMemoryCache.remove(cacheKey);

        // Clear old version nếu có
        if (asset.oldVersion != asset.newVersion) {
          final oldCacheKey = '${asset.label}_v${asset.oldVersion}';
          await cacheManager.removeFile(oldCacheKey);
          _svgMemoryCache.remove(oldCacheKey);
          _filePathMemoryCache.remove(oldCacheKey);
        }
      }

      // Clear URL-based cache (backward compatible)
      await cacheManager.removeFile(normalizedUrl);
      _svgMemoryCache.remove(normalizedUrl);
      _filePathMemoryCache.remove(normalizedUrl);
    } catch (e) {
      debugPrint('Failed to clear cache for URL $url: $e');
    }
  }

  /// Clear cache cho nhiều URLs (disk + memory)
  /// Dùng khi update nhiều icons cùng lúc
  /// Tối ưu: Clear memory cache trước, disk cache sau (parallel)
  static Future<void> clearCacheForUrls(List<String> urls) async {
    try {
      final cacheManager = getCacheManager();
      final normalizedUrls = urls.map((url) => url.trim()).toList();

      // Clear memory cache ngay lập tức (synchronous)
      for (final url in normalizedUrls) {
        _svgMemoryCache.remove(url);
        _filePathMemoryCache.remove(url);
      }

      // Clear disk cache (parallel để tối ưu performance)
      if (cacheManager != null) {
        final futures = normalizedUrls
            .map((url) => cacheManager.removeFile(url).catchError((_) {}))
            .toList();
        await Future.wait(futures);
      }
    } catch (e) {
      debugPrint('Failed to clear cache for URLs: $e');
    }
  }

  /// Clear cache cho tất cả icons (disk + memory)
  /// Dùng khi update icons và cần force refresh tất cả
  /// Note: Sử dụng emptyCache() để clear toàn bộ, sau đó icons sẽ được cache lại khi load
  static Future<void> clearAllIconsCache() async {
    // Clear toàn bộ cache (bao gồm cả icons)
    // Icons sẽ được cache lại khi load lần sau
    await clearCache();
    debugPrint('Cleared all icons cache');
  }

  /// Get cached SVG string từ memory cache (nếu có)
  /// Tránh đọc file nhiều lần, cải thiện performance
  static String? getCachedSvgString(String url) {
    return _svgMemoryCache[url.trim()];
  }

  /// Cache SVG string vào memory
  /// Dùng sau khi đọc file hoặc download từ network
  static void cacheSvgString(String url, String svgString) {
    _svgMemoryCache[url.trim()] = svgString;
  }

  /// Get cached file path từ memory cache (nếu có)
  /// Tránh query database nhiều lần
  static String? getCachedFilePath(String url) {
    return _filePathMemoryCache[url.trim()];
  }

  /// Cache file path vào memory
  /// Dùng sau khi get file từ cache manager
  static void cacheFilePath(String url, String filePath) {
    _filePathMemoryCache[url.trim()] = filePath;
  }

  /// Lấy CacheManager dùng chung
  /// Trên web: Trả về null (browser tự động cache qua HTTP headers)
  /// Trên mobile/desktop: Trả về CacheManager instance
  static CacheManager? getCacheManager({Duration? maxAge}) {
    return AssetsCacheManager.getInstance(maxAge: maxAge);
  }

  /// Cache key cho icon: {label}_v{version}
  static String getCacheKeyForIcon(
    AssetsData icon, {
    int? version,
    bool autoClearOldVersions = true,
  }) {
    final effectiveVersion = version ?? icon.newVersion;

    if (autoClearOldVersions) {
      clearOldVersionsForIcon(icon);
    }

    return '${icon.label}_v$effectiveVersion';
  }

  /// Clear cache cho old version của icon (khi có version mới)
  /// Chỉ clear khi oldVersion != newVersion
  /// Clear cả disk cache và memory cache
  static Future<void> clearOldVersionsForIcon(AssetsData icon) async {
    // Chỉ clear khi có version mới (oldVersion != newVersion)
    if (icon.oldVersion != icon.newVersion) {
      final oldVersionCacheKey = '${icon.label}_v${icon.oldVersion}';
      try {
        // Web: Chỉ clear memory cache (browser tự động cache qua HTTP headers)
        if (kIsWeb) {
          _svgMemoryCache.remove(oldVersionCacheKey);
          _filePathMemoryCache.remove(oldVersionCacheKey);
          return;
        }

        final cacheManager = getCacheManager();
        if (cacheManager != null) {
          // Clear disk cache
          await cacheManager.removeFile(oldVersionCacheKey);
        }

        // Clear memory cache (SVG string và file path)
        _svgMemoryCache.remove(oldVersionCacheKey);
        _filePathMemoryCache.remove(oldVersionCacheKey);
      } catch (_) {
        // Ignore errors khi clear old version
      }
    }
  }

  /// Lấy path file SVG từ cache (nếu có), nếu không sẽ tải và cache theo version.
  /// Tối ưu: Check memory cache trước, sau đó mới check disk cache
  static Future<String> getCachedSvgPath(AssetsData icon) async {
    try {
      final cacheKey = getCacheKeyForIcon(icon);

      // Step 1: Check memory cache trước (fastest)
      final cachedPath = getCachedFilePath(cacheKey);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return cachedPath;
        }
        // File không tồn tại → remove khỏi memory cache
        _filePathMemoryCache.remove(cacheKey);
      }

      // Step 2: Check disk cache (skip trên web)
      if (!kIsWeb) {
        final cacheManager = getCacheManager();
        if (cacheManager != null) {
          final fileInfo = await cacheManager.getFileFromCache(cacheKey);

          if (fileInfo != null && await fileInfo.file.exists()) {
            final filePath = fileInfo.file.path;
            // Cache vào memory để lần sau load nhanh hơn
            cacheFilePath(cacheKey, filePath);
            return filePath;
          }

          // Step 3: Chưa có → tải và cache với key version mới
          final file = await cacheManager.getSingleFile(
            icon.urlPath,
            key: cacheKey,
          );

          if (await file.exists()) {
            final filePath = file.path;
            // Cache vào memory
            cacheFilePath(cacheKey, filePath);
            return filePath;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to cache SVG icon ${icon.label}: $e');
    }
    // Web: Trả về URL trực tiếp (browser tự động cache)
    // Mobile: Trả về URL nếu không cache được
    return icon.urlPath;
  }

  /// Get cached file cho URL với versioning support (nếu có AssetsData)
  /// Tự động detect AssetsData từ registry và dùng versioning
  /// Fallback về URL nếu không có AssetsData
  /// Web: Trả về null (browser tự động cache qua HTTP headers)
  static Future<File?> getCachedFileForUrlWithVersioning(String url) async {
    // Web: Không dùng disk cache, browser tự động cache qua HTTP headers
    if (kIsWeb) {
      return null;
    }

    try {
      final normalizedUrl = url.trim();

      // Check if URL has registered AssetsData (versioning)
      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        // Use versioning: get cache key với version
        final cacheKey = getCacheKeyForIcon(asset);

        // Step 1: Check memory cache với cache key
        final cachedPath = getCachedFilePath(cacheKey);
        if (cachedPath != null) {
          final file = File(cachedPath);
          if (await file.exists()) {
            return file;
          }
          _filePathMemoryCache.remove(cacheKey);
        }

        // Step 2: Check disk cache với cache key
        final cacheManager = getCacheManager();
        if (cacheManager == null) return null;

        final fileInfo = await cacheManager.getFileFromCache(cacheKey);

        if (fileInfo != null && await fileInfo.file.exists()) {
          final filePath = fileInfo.file.path;
          // Cache vào memory với cache key
          cacheFilePath(cacheKey, filePath);
          return fileInfo.file;
        }

        // Step 3: Download và cache với version key
        final file = await cacheManager.getSingleFile(
          normalizedUrl,
          key: cacheKey,
        );

        if (await file.exists()) {
          // Cache vào memory với cache key
          cacheFilePath(cacheKey, file.path);
          return file;
        }
      } else {
        // Fallback: không có AssetsData → dùng URL trực tiếp (backward compatible)
        return await getCachedFileForUrl(normalizedUrl);
      }
    } catch (e) {
      // Ignore errors, fallback to URL-based caching
      return await getCachedFileForUrl(url);
    }
    return null;
  }

  /// Get cached file cho URL (không qua AssetsData)
  /// Tối ưu với memory cache layer
  /// Note: Nên dùng getCachedFileForUrlWithVersioning() nếu có AssetsData
  /// Web: Trả về null (browser tự động cache qua HTTP headers)
  static Future<File?> getCachedFileForUrl(String url) async {
    // Web: Không dùng disk cache, browser tự động cache qua HTTP headers
    if (kIsWeb) {
      return null;
    }

    try {
      final normalizedUrl = url.trim();

      // Step 1: Check memory cache
      final cachedPath = getCachedFilePath(normalizedUrl);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return file;
        }
        _filePathMemoryCache.remove(normalizedUrl);
      }

      // Step 2: Check disk cache
      final cacheManager = getCacheManager();
      if (cacheManager == null) return null;

      final fileInfo = await cacheManager.getFileFromCache(normalizedUrl);

      if (fileInfo != null && await fileInfo.file.exists()) {
        final filePath = fileInfo.file.path;
        // Cache vào memory
        cacheFilePath(normalizedUrl, filePath);
        return fileInfo.file;
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  /// Get hoặc download file và cache với versioning support (nếu có AssetsData)
  /// Tự động detect AssetsData từ registry và dùng versioning
  /// Fallback về URL nếu không có AssetsData
  /// Web: Throw exception (không support disk cache trên web)
  static Future<File> getSingleFileForUrlWithVersioning(String url) async {
    // Web: Không support disk cache, browser tự động cache qua HTTP headers
    if (kIsWeb) {
      throw UnsupportedError(
        'getSingleFileForUrlWithVersioning is not supported on web',
      );
    }

    try {
      final normalizedUrl = url.trim();

      // Check if URL has registered AssetsData (versioning)
      final asset = getAssetForUrl(normalizedUrl);
      if (asset != null) {
        // Use versioning: get cache key với version
        final cacheKey = getCacheKeyForIcon(asset);

        // Check memory cache trước với cache key
        final cachedPath = getCachedFilePath(cacheKey);
        if (cachedPath != null) {
          final file = File(cachedPath);
          if (await file.exists()) {
            return file;
          }
          _filePathMemoryCache.remove(cacheKey);
        }

        // Get hoặc download từ cache manager với cache key
        final cacheManager = getCacheManager();
        if (cacheManager == null) {
          throw UnsupportedError('CacheManager is not available');
        }

        final file = await cacheManager.getSingleFile(
          normalizedUrl,
          key: cacheKey,
        );

        if (await file.exists()) {
          // Cache vào memory với cache key
          cacheFilePath(cacheKey, file.path);
        }

        return file;
      } else {
        // Fallback: không có AssetsData → dùng URL trực tiếp (backward compatible)
        return await getSingleFileForUrl(normalizedUrl);
      }
    } catch (e) {
      // Fallback to URL-based caching
      return await getSingleFileForUrl(url);
    }
  }

  /// Get hoặc download file và cache (cho URL trực tiếp)
  /// Tối ưu với memory cache và parallel loading
  /// Note: Nên dùng getSingleFileForUrlWithVersioning() nếu có AssetsData
  static Future<File> getSingleFileForUrl(String url) async {
    try {
      final normalizedUrl = url.trim();

      // Check memory cache trước
      final cachedPath = getCachedFilePath(normalizedUrl);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return file;
        }
        _filePathMemoryCache.remove(normalizedUrl);
      }

      // Get hoặc download từ cache manager
      final cacheManager = getCacheManager();
      if (cacheManager == null) {
        throw UnsupportedError('CacheManager is not available');
      }
      final file = await cacheManager.getSingleFile(
        normalizedUrl,
        key: normalizedUrl,
      );

      if (await file.exists()) {
        // Cache vào memory
        cacheFilePath(normalizedUrl, file.path);
      }

      return file;
    } catch (e) {
      // Re-throw để caller handle
      rethrow;
    }
  }
}
