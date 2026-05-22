import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:http/http.dart' as http;

import 'package:sun_sports/core/utils/extensions/cached_manager.dart';
import 'package:sun_sports/core/utils/preload_storage.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

/// Preload pipeline:
/// - Phase 1: main assets (exclude game) → run trong splash, fire onComplete khi xong.
/// - Phase 2: game assets → background khi vào màn chính.
///
/// QUAN TRỌNG về cache layer:
/// - Mobile/Desktop: ghi thẳng vào DISK cache thông qua [AssetsCacheManager]
///   (`flutter_cache_manager`) — CÙNG key system mà [ImageHelper.load] đọc khi
///   render. Như vậy file đã preload sẽ thực sự được dùng lại.
/// - Web: warm HTTP browser cache bằng `http.get`. Browser tự cache theo
///   `Cache-Control` headers; subsequent requests từ `CachedNetworkImage` /
///   `SvgPicture.network` sẽ hit cache.
///
/// Retry strategy:
/// - Mỗi pass duyệt hết URLs đang fail. Sau pass, các URL fail/timeout sẽ
///   được retry tối đa [_maxPreloadRetryPasses] lần với exponential backoff.
/// - Per-URL timeout = [_perUrlTimeout]. Vượt timeout → fail → vào pass tiếp.
/// - Progress phản ánh số URL ĐÃ THỰC SỰ thành công, không phải số đã thử.
const int _concurrency = 32;
const int _perHostCap = 8;
const Duration _perUrlTimeout = Duration(seconds: 10);
const int _maxPreloadRetryPasses = 2;

/// Threshold (% URLs success) để coi game preload là "đủ tốt", không cần retry.
/// Dưới threshold → reset state để lần sau gọi sẽ thử lại.
const double _gamePreloadSuccessThreshold = 0.8;

const Map<String, String> _webPreloadHeaders = {
  'Accept-Encoding': 'gzip, deflate, br',
};

class UnifiedAssetsPreloader {
  UnifiedAssetsPreloader._();

  /// Game preload state machine:
  /// - [idle]: chưa chạy hoặc đã chạy nhưng fail nhiều → cho phép retry.
  /// - [running]: đang chạy (chặn re-entry).
  /// - [completed]: thành công ≥ threshold → không cần chạy lại.
  static _GamePreloadState _gamePreloadState = _GamePreloadState.idle;

  /// Phase 1: preload main assets (gọi từ splash).
  ///
  /// [context] hiện tại không bắt buộc cho download (preload không cần BuildContext
  /// vì ghi thẳng vào disk cache hoặc browser cache), nhưng giữ trong signature
  /// để backward-compatible với callers.
  static void startPreloadingInBackground(
    BuildContext context, {
    required void Function(double progress) onProgress,
    required VoidCallback onComplete,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run(onProgress, onComplete);
    });
  }

  static Future<void> _run(
    void Function(double progress) onProgress,
    VoidCallback onComplete,
  ) async {
    final allUrls = _collectUrlsMain();
    if (allUrls.isEmpty) {
      onProgress(1.0);
      onComplete();
      return;
    }

    http.Client? client;
    if (kIsWeb) client = http.Client();

    final successful = <String>{};

    try {
      List<String> remaining = List<String>.unmodifiable(allUrls);

      for (int pass = 0; pass <= _maxPreloadRetryPasses; pass++) {
        if (remaining.isEmpty) break;

        await _runWithPool(
          urls: remaining,
          client: client,
          onUrlComplete: (url, ok) {
            if (ok) successful.add(url);
            // Progress phản ánh số URL THỰC SỰ thành công (không phải số đã thử)
            final progress = successful.length / allUrls.length;
            onProgress(progress.clamp(0.0, 1.0));
          },
        );

        remaining = allUrls
            .where((u) => !successful.contains(u))
            .toList(growable: false);

        if (pass < _maxPreloadRetryPasses && remaining.isNotEmpty) {
          // Exponential backoff giữa các pass: 1s, 2s
          await Future<void>.delayed(Duration(seconds: 1 << pass));
        }
      }

      final failedCount = allUrls.length - successful.length;
      if (failedCount > 0) {
        debugPrint(
          'UnifiedAssetsPreloader: main preload finished with '
          '$failedCount/${allUrls.length} URLs FAILED after '
          '${_maxPreloadRetryPasses + 1} passes',
        );
      }
    } finally {
      client?.close();
    }

    // Web: CHỈ lưu các URL THỰC SỰ thành công vào localStorage.
    // (URL fail không được lưu → caller dùng localStorage làm hint sẽ chính xác.)
    if (kIsWeb) {
      savePreloadedUrls(successful.toList());
    }

    onProgress(1.0);
    onComplete();
  }

  /// Throttle: hạn chế cập nhật progress quá dày để giảm rebuild splash.
  static const Duration _progressThrottle = Duration(milliseconds: 50);

  /// Pool runner. Gọi [onUrlComplete] với (url, success) cho từng URL khi xong.
  ///
  /// Concurrency: tối đa [_concurrency] requests đồng thời, [_perHostCap] mỗi host.
  /// Pool tự complete khi TẤT CẢ urls đã được report (không bị stall).
  static Future<void> _runWithPool({
    required List<String> urls,
    required http.Client? client,
    required void Function(String url, bool success) onUrlComplete,
  }) async {
    if (urls.isEmpty) return;

    final completer = Completer<void>();

    final hostToPending = <String, List<int>>{};
    for (var i = 0; i < urls.length; i++) {
      final host = Uri.tryParse(urls[i])?.host ?? '';
      hostToPending.putIfAbsent(host, () => []).add(i);
    }
    final activePerHost = <String, int>{};
    var active = 0;
    var completed = 0;
    var lastProgressTime = DateTime.now();
    final total = urls.length;

    void reportOne(String url, bool ok) {
      completed++;
      final now = DateTime.now();
      // Throttle progress khi success-flood, nhưng luôn fire callback đúng URL
      // (caller mới quyết định có throttle UI hay không).
      if (ok ||
          completed == total ||
          now.difference(lastProgressTime) >= _progressThrottle) {
        lastProgressTime = now;
      }
      onUrlComplete(url, ok);
    }

    void startNext() {
      while (active < _concurrency) {
        int? pickIndex;
        String? pickHost;
        for (final e in hostToPending.entries) {
          if (e.value.isEmpty) continue;
          final count = activePerHost[e.key] ?? 0;
          if (count < _perHostCap) {
            pickIndex = e.value.removeAt(0);
            pickHost = e.key;
            break;
          }
        }
        if (pickIndex == null || pickHost == null) break;

        final url = urls[pickIndex];
        final host = pickHost;
        activePerHost[host] = (activePerHost[host] ?? 0) + 1;
        active++;
        _preloadOneWithTimeout(url, client).then((ok) {
          activePerHost[host] = (activePerHost[host] ?? 1) - 1;
          active--;
          reportOne(url, ok);
          if (completed == total) {
            if (!completer.isCompleted) completer.complete();
          } else {
            startNext();
          }
        });
      }
    }

    startNext();
    await completer.future;
  }

  /// Phase 2: preload game assets (gọi từ app main shell khi user vào màn chính).
  ///
  /// State machine (xem [_GamePreloadState]):
  /// - idle → running khi gọi
  /// - running → completed nếu success ratio ≥ [_gamePreloadSuccessThreshold]
  /// - running → idle nếu fail nhiều → cho phép caller retry lần sau
  static void startGamePreloadInBackground(BuildContext context) {
    if (_gamePreloadState != _GamePreloadState.idle) return;

    final gameUrls = _collectUrlsGame();
    if (gameUrls.isEmpty) {
      _gamePreloadState = _GamePreloadState.completed;
      return;
    }
    _gamePreloadState = _GamePreloadState.running;
    unawaited(_runGamePreload(gameUrls));
  }

  static Future<void> _runGamePreload(List<String> gameUrls) async {
    final successful = <String>{};
    http.Client? client;
    if (kIsWeb) client = http.Client();

    try {
      List<String> remaining = List<String>.unmodifiable(gameUrls);

      for (int pass = 0; pass <= _maxPreloadRetryPasses; pass++) {
        if (remaining.isEmpty) break;

        await _runWithPool(
          urls: remaining,
          client: client,
          onUrlComplete: (url, ok) {
            if (ok) successful.add(url);
          },
        );

        remaining = gameUrls
            .where((u) => !successful.contains(u))
            .toList(growable: false);

        if (pass < _maxPreloadRetryPasses && remaining.isNotEmpty) {
          await Future<void>.delayed(Duration(seconds: 1 << pass));
        }
      }
    } catch (_) {
      // Lỗi pool runner — sẽ check qua [successful] set bên dưới
    } finally {
      client?.close();
    }

    final ratio =
        gameUrls.isEmpty ? 1.0 : successful.length / gameUrls.length;
    if (ratio >= _gamePreloadSuccessThreshold) {
      _gamePreloadState = _GamePreloadState.completed;
    } else {
      // Reset → cho phép caller (vào lại màn) retry preload
      _gamePreloadState = _GamePreloadState.idle;
      debugPrint(
        'UnifiedAssetsPreloader: game preload UNDER threshold '
        '(${(ratio * 100).toStringAsFixed(0)}% < '
        '${(_gamePreloadSuccessThreshold * 100).toStringAsFixed(0)}%) — '
        'state reset to idle, sẽ retry lần gọi tiếp theo',
      );
    }
  }

  /// Test-only / recovery hook: reset game preload state.
  ///
  /// Dùng khi muốn force re-preload (ví dụ user pull-to-refresh, login lại,
  /// hoặc app resume sau lâu offline).
  @visibleForTesting
  static void resetGamePreloadState() {
    _gamePreloadState = _GamePreloadState.idle;
  }

  static List<String> _collectUrlsMain() {
    final fromIcons =
        AppIcons.remoteUrlsForPreloadOrderedByScreenExcludeGame;
    final fromImages = AppImages.remoteUrlsForPreloadExcludeGame;
    final fromRive = AppRive.remoteUrlsForPreload;
    final combined = <String>[...fromIcons, ...fromImages, ...fromRive];
    return combined
        .where((url) =>
            url.startsWith('http://') || url.startsWith('https://'))
        .toSet()
        .toList(growable: false);
  }

  static List<String> _collectUrlsGame() {
    final fromIcons = AppIcons.remoteUrlsForPreloadGameOnly;
    final fromImages = AppImages.remoteUrlsForPreloadGameOnly;
    final combined = <String>[...fromIcons, ...fromImages];
    return combined
        .where((url) =>
            url.startsWith('http://') || url.startsWith('https://'))
        .toSet()
        .toList(growable: false);
  }

  /// Preload 1 URL với timeout. Trả về `true` chỉ khi THỰC SỰ thành công
  /// (download xong + file/response valid). `false` cho mọi failure khác:
  /// timeout, HTTP error, file rỗng, exception.
  static Future<bool> _preloadOneWithTimeout(
    String url, [
    http.Client? client,
  ]) async {
    try {
      await _preloadOne(url, client).timeout(_perUrlTimeout);
      return true;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Mobile/Desktop: ghi thẳng vào flutter_cache_manager DISK cache thông qua
  /// [AssetsCacheManager] — cùng key system mà [ImageHelper.load] đọc.
  /// Web: warm HTTP browser cache bằng `http.get`.
  ///
  /// Throw nếu không thực sự preload được — caller sẽ dịch thành `false`.
  static Future<void> _preloadOne(
    String url,
    http.Client? client,
  ) async {
    if (kIsWeb) {
      await _preloadOneWeb(url, client);
      return;
    }

    // Mobile/Desktop: download và lưu vào disk cache với cache key versioning.
    // _LazyLoadingImageWidget._loadCachedVersion sẽ đọc lại từ đây.
    final file =
        await AssetsCacheManager.getSingleFileForUrlWithVersioning(url);

    if (!await file.exists()) {
      throw Exception('Preloaded file does not exist: $url');
    }
    final size = await file.length();
    if (size < 10) {
      // File rỗng/corrupted → clear khỏi cache để không ai đọc nhầm file lỗi
      await AssetsCacheManager.clearCacheForUrl(url);
      throw Exception('Preloaded file too small ($size bytes): $url');
    }

    // Bonus: SVG → warm flutter_svg PictureCache + AssetsCacheManager memory
    // string cache để render lần đầu nhanh hơn (skip disk read + parse).
    final lower = url.toLowerCase();
    if (lower.endsWith('.svg')) {
      try {
        final content = await file.readAsString();
        final loader = svg.SvgStringLoader(content);
        await svg.vg.loadPicture(loader, null);

        // Cache string vào memory layer của AssetsCacheManager
        // (cùng cacheKey với versioning nếu có AssetsData đã register)
        final asset = AssetsCacheManager.getAssetForUrl(url);
        final cacheKey = asset != null
            ? AssetsCacheManager.getCacheKeyForIcon(asset)
            : url.trim();
        AssetsCacheManager.cacheSvgString(cacheKey, content);
      } catch (_) {
        // Disk cache vẫn hoạt động → không throw lên trên
      }
    }
  }

  /// Web: gọi `http.get` để warm browser HTTP cache.
  /// Browser tự cache response theo `Cache-Control` của server.
  static Future<void> _preloadOneWeb(
    String url, [
    http.Client? client,
  ]) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid URL: $url');
    }
    final response = client != null
        ? await client.get(uri, headers: _webPreloadHeaders)
        : await http.get(uri, headers: _webPreloadHeaders);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} for $url');
    }
    if (response.bodyBytes.length < 10) {
      throw Exception('Empty response for $url');
    }
  }
}

enum _GamePreloadState { idle, running, completed }
