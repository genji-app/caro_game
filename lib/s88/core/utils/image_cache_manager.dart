import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Singleton class để quản lý cache cho icons và images
/// Sử dụng content hash (SHA256) để detect content changes
/// Implement lazy loading strategy: show cached version trước, verify hash sau
///
/// Optimized với index file để fast lookup
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  static const String _cacheDirName = 'image_cache';
  static const String _indexFileName = 'index.json';
  static const Duration _cacheExpiration = Duration(days: 7);
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB

  Directory? _cacheDir;
  File? _indexFile;

  // In-memory cache để tránh đọc index file nhiều lần
  Map<String, _CacheEntry>? _indexCache;
  bool _indexCacheDirty = false;
  bool _isInitialized = false;

  // Cache URL hash calculations
  final Map<String, String> _urlHashCache = {};

  /// Initialize cache directory và load index
  /// Idempotent: có thể gọi nhiều lần mà không ảnh hưởng
  /// Returns true nếu init thành công, false nếu fail (nhưng không throw exception)
  ///
  /// Note: Web platform không support disk cache, sẽ return false ngay
  Future<bool> init() async {
    // Web không support disk cache
    // Note: Web sử dụng browser HTTP cache tự động, không cần disk cache
    if (kIsWeb) {
      // Không log warning vì đây là expected behavior
      // Web sẽ dùng browser cache thay vì disk cache
      return false;
    }

    // Nếu đã init rồi, skip
    if (_isInitialized && _cacheDir != null) return true;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirName');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      _indexFile = File('${_cacheDir!.path}/$_indexFileName');
      await _loadIndex();
      _isInitialized = true;
      return true;
    } catch (e) {
      // Log error để debug (có thể dùng debugPrint hoặc logger)
      // ignore: avoid_print
      print('ImageCacheManager.init() failed: $e');
      // Fail gracefully: app vẫn chạy được, chỉ là không có cache
      return false;
    }
  }

  /// Check if cache manager đã được init thành công
  bool get isInitialized => _isInitialized && _cacheDir != null;

  /// Load index từ file
  Future<void> _loadIndex() async {
    if (_indexFile == null || !await _indexFile!.exists()) {
      _indexCache = {};
      return;
    }

    try {
      final content = await _indexFile!.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      _indexCache = json.map((key, value) {
        final entry = value as Map<String, dynamic>;
        return MapEntry(
          key,
          _CacheEntry(
            key: entry['key'] as String,
            contentHash: entry['contentHash'] as String?,
            accessTime: DateTime.parse(entry['accessTime'] as String),
            fileSize: entry['fileSize'] as int? ?? 0,
          ),
        );
      });
    } catch (e) {
      // Nếu index file corrupt, reset
      _indexCache = {};
    }
  }

  /// Save index to file
  Future<void> _saveIndex() async {
    if (!_indexCacheDirty || _indexFile == null || _indexCache == null) return;

    try {
      final json = _indexCache!.map(
        (key, value) => MapEntry(key, {
          'key': value.key,
          'contentHash': value.contentHash,
          'accessTime': value.accessTime.toIso8601String(),
          'fileSize': value.fileSize,
        }),
      );

      await _indexFile!.writeAsString(jsonEncode(json));
      _indexCacheDirty = false;
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Get URL hash (cached)
  String _getUrlHash(String url) {
    return _urlHashCache.putIfAbsent(url, () {
      final bytes = utf8.encode(url);
      return sha256.convert(bytes).toString();
    });
  }

  /// Generate cache key từ URL và content hash
  /// Format: {urlHash}_{contentHash} (nếu có contentHash)
  /// Hoặc: {urlHash} (nếu không có contentHash - dùng cho lazy loading)
  String _generateKey(String url, {String? contentHash}) {
    final urlHash = _getUrlHash(url);

    if (contentHash != null && contentHash.isNotEmpty) {
      // Key format: urlHash_contentHash (64 chars + 1 + 64 chars = 129 chars)
      return '${urlHash}_$contentHash';
    }

    // Fallback: chỉ dùng URL hash (dùng cho lazy loading - show cached trước)
    return urlHash;
  }

  /// Get cache file path
  /// Returns null nếu cacheDir chưa được init
  String? _getCachePath(String key) {
    if (_cacheDir == null) return null;
    return '${_cacheDir!.path}/$key';
  }

  /// Check if cached file exists và chưa expired
  Future<bool> isCached(String url, {String? contentHash}) async {
    if (_cacheDir == null || !await _cacheDir!.exists()) return false;

    await _loadIndexIfNeeded();
    if (_indexCache == null) return false;

    // Check trong index
    final entry = _indexCache![url];
    if (entry == null) return false;

    // Check expiration
    final age = DateTime.now().difference(entry.accessTime);
    if (age > _cacheExpiration) {
      // Expired - remove from index
      await _removeFromIndex(url);
      return false;
    }

    // Check content hash nếu có
    if (contentHash != null && entry.contentHash != null) {
      if (entry.contentHash != contentHash) {
        // Content đã thay đổi - remove from index
        await _removeFromIndex(url);
        return false;
      }
    }

    // Check file exists
    final cachePath = _getCachePath(entry.key);
    if (cachePath == null) return false;

    final file = File(cachePath);
    if (!await file.exists()) {
      await _removeFromIndex(url);
      return false;
    }

    return true;
  }

  /// Get cached file (optimistic - không check hash match)
  /// Dùng cho lazy loading: show cached version trước, check hash sau
  Future<File?> getCachedFile(String url, {bool useAnyCache = false}) async {
    if (_cacheDir == null || !await _cacheDir!.exists()) return null;

    await _loadIndexIfNeeded();
    if (_indexCache == null) return null;

    // Lookup trong index
    final entry = _indexCache![url];
    if (entry == null) return null;

    // Check expiration
    final age = DateTime.now().difference(entry.accessTime);
    if (age > _cacheExpiration) {
      await _removeFromIndex(url);
      return null;
    }

    // Get file
    final cachePath = _getCachePath(entry.key);
    if (cachePath == null) return null;

    final file = File(cachePath);
    if (!await file.exists()) {
      await _removeFromIndex(url);
      return null;
    }

    // Update access time
    entry.accessTime = DateTime.now();
    _indexCacheDirty = true;
    _saveIndex(); // Save async, không block

    return file;
  }

  /// Verify if content hash matches cached version
  Future<bool> verifyCacheHash(String url, String contentHash) async {
    await _loadIndexIfNeeded();
    if (_indexCache == null) return false;

    final entry = _indexCache![url];
    if (entry == null) return false;

    return entry.contentHash == contentHash;
  }

  /// Save to cache
  Future<void> saveToCache(
    String url,
    List<int> data, {
    String? contentHash,
  }) async {
    // Web không support disk cache
    if (kIsWeb) return;

    // Skip nếu data empty hoặc quá nhỏ (có thể là error response)
    // Minimum size: 10 bytes (để tránh cache invalid/error responses)
    if (data.isEmpty || data.length < 10) {
      return;
    }

    // Try init nếu chưa init
    if (_cacheDir == null || !await _cacheDir!.exists()) {
      final initSuccess = await init();
      if (!initSuccess) {
        // Init fail → không thể save cache, nhưng không throw exception
        // App vẫn chạy được, chỉ là không có cache
        return;
      }
    }

    // Double check sau khi init
    if (_cacheDir == null) return;

    try {
      await _loadIndexIfNeeded();
      if (_indexCache == null) {
        _indexCache = {};
      }

      // Generate content hash nếu chưa có
      if (contentHash == null && data.isNotEmpty) {
        final hash = sha256.convert(data);
        contentHash = hash.toString();
      }

      // Generate key với content hash
      final key = _generateKey(url, contentHash: contentHash);
      final cachePath = _getCachePath(key);
      if (cachePath == null) return;

      final file = File(cachePath);

      // Cleanup old file nếu đã có entry cũ cho cùng URL với key khác
      final oldEntry = _indexCache![url];
      if (oldEntry != null && oldEntry.key != key) {
        // Delete old file để tránh orphaned files
        final oldPath = _getCachePath(oldEntry.key);
        if (oldPath != null) {
          try {
            final oldFile = File(oldPath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } catch (e) {
            // Ignore delete errors (file might be in use or already deleted)
          }
        }
      }

      // Save file
      await file.writeAsBytes(data);

      // Update index
      final fileSize = data.length;
      _indexCache![url] = _CacheEntry(
        key: key,
        contentHash: contentHash,
        accessTime: DateTime.now(),
        fileSize: fileSize,
      );

      _indexCacheDirty = true;
      await _saveIndex();
    } catch (e) {
      // Nếu save fail (disk full, permission, etc.) → không throw exception
      // App vẫn chạy được, chỉ là không có cache
      // ignore: avoid_print
      print('ImageCacheManager.saveToCache() failed: $e');
    }
  }

  /// Remove entry from index
  Future<void> _removeFromIndex(String url) async {
    if (_indexCache == null) return;

    final entry = _indexCache!.remove(url);
    if (entry != null) {
      try {
        // Delete cache file
        final cachePath = _getCachePath(entry.key);
        if (cachePath != null) {
          final file = File(cachePath);
          if (await file.exists()) {
            await file.delete();
          }
        }

        _indexCacheDirty = true;
        await _saveIndex();
      } catch (e) {
        // Ignore delete errors
      }
    }
  }

  /// Load index nếu chưa load
  Future<void> _loadIndexIfNeeded() async {
    if (_indexCache == null) {
      await _loadIndex();
    }
  }

  /// Force refresh cache (xóa cache cũ và download lại)
  Future<void> invalidateCache(String url) async {
    await _removeFromIndex(url);
  }

  /// Cleanup old/unused cache
  Future<void> cleanup() async {
    if (_cacheDir == null || !await _cacheDir!.exists()) return;

    await _loadIndexIfNeeded();
    if (_indexCache == null) return;

    final now = DateTime.now();
    int totalSize = 0;
    final entriesToRemove = <String>[];

    // Check expiration và calculate total size
    for (final entry in _indexCache!.entries) {
      final age = now.difference(entry.value.accessTime);

      // Mark expired entries for removal
      if (age > _cacheExpiration) {
        entriesToRemove.add(entry.key);
        continue;
      }

      totalSize += entry.value.fileSize;
    }

    // Remove expired entries
    for (final url in entriesToRemove) {
      await _removeFromIndex(url);
    }

    // Nếu cache size vượt limit, delete LRU files
    if (totalSize > _maxCacheSize) {
      // Sort entries by access time (LRU first)
      final sortedEntries = _indexCache!.entries.toList()
        ..sort((a, b) => a.value.accessTime.compareTo(b.value.accessTime));

      // Delete files until size < 80MB
      final int targetSize = (_maxCacheSize * 0.8).toInt();
      for (final entry in sortedEntries) {
        if (totalSize <= targetSize) break;

        totalSize -= entry.value.fileSize;
        await _removeFromIndex(entry.key);
      }
    }

    await _saveIndex();
  }

  /// Clear all cache
  Future<void> clearAll() async {
    if (_cacheDir == null || !await _cacheDir!.exists()) return;

    final files = _cacheDir!.listSync();
    for (final file in files) {
      if (file is File) {
        await file.delete();
      }
    }

    _indexCache = {};
    _indexCacheDirty = true;
    await _saveIndex();
  }
}

/// Cache entry trong index
class _CacheEntry {
  final String key; // Cache file key
  final String? contentHash; // Content hash
  DateTime accessTime; // Last access time
  final int fileSize; // File size in bytes

  _CacheEntry({
    required this.key,
    required this.contentHash,
    required this.accessTime,
    required this.fileSize,
  });
}
