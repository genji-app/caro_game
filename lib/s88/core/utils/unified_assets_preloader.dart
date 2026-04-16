import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/preload_storage.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_rive.dart';

/// Preload: phase 1 = exclude game → onComplete; phase 2 = game (background khi vào màn).
/// Pool concurrency + per-host cap + HTTP client reuse (web) + gzip.
const int _concurrency = 32;
const int _perHostCap = 8;
const Duration _perUrlTimeout = Duration(seconds: 5);

const Map<String, String> _webPreloadHeaders = {
  'Accept-Encoding': 'gzip, deflate, br',
};

class UnifiedAssetsPreloader {
  UnifiedAssetsPreloader._();

  static bool _gamePreloadStarted = false;

  static void startPreloadingInBackground(
    BuildContext context, {
    required void Function(double progress) onProgress,
    required VoidCallback onComplete,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run(context, onProgress, onComplete);
    });
  }

  static Future<void> _run(
    BuildContext context,
    void Function(double progress) onProgress,
    VoidCallback onComplete,
  ) async {
    final mainUrls = _collectUrlsMain();
    if (mainUrls.isEmpty) {
      onProgress(1.0);
      onComplete();
      return;
    }

    http.Client? client;
    if (kIsWeb) {
      client = http.Client();
    }
    try {
      await _runWithPool(
        context,
        mainUrls,
        (completed, total) =>
            onProgress((completed / total).clamp(0.0, 1.0)),
        client,
      );
    } finally {
      client?.close();
    }

    if (kIsWeb) {
      savePreloadedUrls(mainUrls);
    }
    onProgress(1.0);
    onComplete();
  }

  /// Throttle: cập nhật progress tối đa mỗi ~50ms để giảm rebuild.
  static const Duration _progressThrottle = Duration(milliseconds: 50);

  /// Pool: [_concurrency] toàn cục, tối đa [_perHostCap] mỗi host để tránh nghẽn 1 domain.
  static Future<void> _runWithPool(
    BuildContext context,
    List<String> urls,
    void Function(int completed, int total) onProgress,
    http.Client? client,
  ) async {
    if (urls.isEmpty) return;

    final total = urls.length;
    var completed = 0;
    var lastProgressTime = DateTime.now();
    final completer = Completer<void>();

    final hostToPending = <String, List<int>>{};
    for (var i = 0; i < urls.length; i++) {
      final host = Uri.tryParse(urls[i])?.host ?? '';
      hostToPending.putIfAbsent(host, () => []).add(i);
    }
    final activePerHost = <String, int>{};
    var active = 0;

    void maybeReportProgress() {
      completed++;
      final now = DateTime.now();
      final shouldReport =
          completed == total ||
          now.difference(lastProgressTime) >= _progressThrottle;
      if (shouldReport) {
        lastProgressTime = now;
        onProgress(completed, total);
      }
    }

    void startNext() {
      if (!context.mounted) return;
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
        activePerHost[pickHost] = (activePerHost[pickHost] ?? 0) + 1;
        active++;
        _preloadOneWithTimeout(context, url, client).whenComplete(() {
          activePerHost[pickHost!] = (activePerHost[pickHost] ?? 1) - 1;
          active--;
          maybeReportProgress();
          startNext();
          if (completed == total && !completer.isCompleted) {
            completer.complete();
          }
        });
      }
    }

    startNext();
    await completer.future;
  }

  static void startGamePreloadInBackground(BuildContext context) {
    if (_gamePreloadStarted) return;
    final gameUrls = _collectUrlsGame();
    if (gameUrls.isEmpty) return;
    _gamePreloadStarted = true;
    unawaited(_runGamePreload(context, gameUrls));
  }

  static Future<void> _runGamePreload(
    BuildContext context,
    List<String> gameUrls,
  ) async {
    http.Client? client;
    if (kIsWeb) {
      client = http.Client();
    }
    try {
      await _runWithPool(context, gameUrls, (_, __) {}, client);
    } finally {
      client?.close();
    }
  }

  static List<String> _collectUrlsMain() {
    final fromIcons = AppIcons.remoteUrlsForPreloadOrderedByScreenExcludeGame;
    final fromImages = AppImages.remoteUrlsForPreloadExcludeGame;
    final fromRive = AppRive.remoteUrlsForPreload;
    final combined = <String>[...fromIcons, ...fromImages, ...fromRive];
    return combined
        .where((url) =>
            url.startsWith('http://') || url.startsWith('https://'))
        .toSet()
        .toList();
  }

  static List<String> _collectUrlsGame() {
    final fromIcons = AppIcons.remoteUrlsForPreloadGameOnly;
    final fromImages = AppImages.remoteUrlsForPreloadGameOnly;
    final combined = <String>[...fromIcons, ...fromImages];
    return combined
        .where((url) =>
            url.startsWith('http://') || url.startsWith('https://'))
        .toSet()
        .toList();
  }

  static Future<void> _preloadOneWithTimeout(
    BuildContext context,
    String url, [
    http.Client? client,
  ]) async {
    try {
      await _preloadOne(context, url, client).timeout(
        _perUrlTimeout,
        onTimeout: () => Future<void>.value(),
      );
    } catch (_) {}
  }

  /// Web: http.get (browser cache). Mobile/Desktop: precache vào Flutter cache.
  static Future<void> _preloadOne(
    BuildContext context,
    String url, [
    http.Client? client,
  ]) async {
    if (kIsWeb) {
      await _preloadOneWeb(url, client);
    } else {
      final lower = url.toLowerCase();
      if (lower.endsWith('.riv')) {
        await _preloadOneWeb(url, client);
        return;
      }
      // Mobile/tablet: SVG → loadPicture cache; raster → precacheImage cache.
      final isSvg = lower.endsWith('.svg');
      if (isSvg) {
        await ImageHelper.precacheSVG(context, url);
      } else {
        await ImageHelper.precacheNetworkImage(context, url);
      }
    }
  }

  static Future<void> _preloadOneWeb(String url, [http.Client? client]) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (client != null) {
      await client.get(uri, headers: _webPreloadHeaders);
    } else {
      await http.get(uri, headers: _webPreloadHeaders);
    }
  }
}
