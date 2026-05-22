import 'package:sun_sports/core/utils/extensions/assets_data.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_rive.dart';

/// Auto-register asset versioning cho TOÀN BỘ static URLs trong app
/// (icons / images / rive). Mỗi URL được auto-register với version mặc định = 1.
///
/// ─────────────────────────────────────────────────────────────────
/// QUY TẮC SỬ DỤNG
/// ─────────────────────────────────────────────────────────────────
///
/// 1. **Thêm icon/image MỚI** → chỉ cần thêm URL vào AppIcons / AppImages /
///    AppRive như bình thường. Auto-registration tự pickup. KHÔNG cần đụng
///    file này.
///
/// 2. **Server đổi NỘI DUNG ở cùng URL** (vd hot-fix icon, đổi logo team) →
///    thêm 1 dòng vào [_versionOverrides]:
///
///    ```dart
///    AppIcons.iconBasketballSelected: 2,   // bump 1 → 2
///    AppImages.logoChampion: 3,            // bump 2 → 3 lần thứ 2
///    ```
///
///    `oldVersion` được auto-derive = `newVersion - 1`. Khi user mở app,
///    `AssetsCacheManager.registerAssets` sẽ tự clear cache cũ cho key đó.
///
/// 3. **QUY TẮC BUMP**: tăng tuần tự (1→2→3→…), KHÔNG skip. Skip vẫn chạy
///    được nhưng để lại file rác `_v1`/`_v2` trong disk cache cho đến khi
///    flutter_cache_manager tự dọn (stalePeriod 14 ngày hoặc LRU evict).
///
/// 4. **URL ĐỘNG** (team logo từ API, avatar user, banner CMS, …) KHÔNG đăng
///    ký ở đây — bản chất không biết URL trước build-time. Chúng vẫn được
///    cache (key = URL gốc, không versioned). Để force update, gọi
///    `AssetsCacheManager.clearCacheForUrl(url)` khi nhận signal đổi.
///
/// ─────────────────────────────────────────────────────────────────
/// CALLED BY
/// ─────────────────────────────────────────────────────────────────
/// `app.dart` → `AssetsCacheManager.registerAssets(AppAssetsData.all)`
/// chạy 1 lần ở app startup.
class AppAssetsData {
  AppAssetsData._();

  // ============================================================
  // BUMP VERSION KHI CẦN UPDATE ICON / IMAGE
  // ============================================================

  /// Map URL → newVersion. Default version = 1 nếu URL không có ở đây.
  ///
  /// CHỈ thay đổi map này khi cần update server-side asset (cùng URL nhưng
  /// nội dung mới). Mọi URL không có ở đây = version 1.
  ///
  /// Example:
  /// ```dart
  /// static final Map<String, int> _versionOverrides = <String, int>{
  ///   AppIcons.iconBasketballSelected: 2,
  ///   AppImages.logoChampion: 3,
  ///   AppRive.someAnimation: 2,
  /// };
  /// ```
  static final Map<String, int> _versionOverrides = <String, int>{
    // Thêm entries ở đây khi cần bump version cụ thể.
  };

  // ============================================================
  // PUBLIC API — caller dùng `all` để register
  // ============================================================

  /// Tất cả assets (icons + images + rive) đã được auto-register.
  /// Dùng ở `app.dart`: `AssetsCacheManager.registerAssets(AppAssetsData.all)`.
  static List<AssetsData> get all =>
      _allUrls.map(_buildAsset).toList(growable: false);

  /// Subset: chỉ icons (cho callers cần group riêng).
  static List<AssetsData> get allIcons =>
      _iconUrls.map(_buildAsset).toList(growable: false);

  /// Subset: chỉ images.
  static List<AssetsData> get allImages =>
      _imageUrls.map(_buildAsset).toList(growable: false);

  /// Subset: chỉ rive animations.
  static List<AssetsData> get allRive =>
      _riveUrls.map(_buildAsset).toList(growable: false);

  // ============================================================
  // INTERNAL HELPERS
  // ============================================================

  /// Tất cả URLs static, dedup qua Set (giữ insertion order).
  static Set<String> get _allUrls => <String>{
    ..._iconUrls,
    ..._imageUrls,
    ..._riveUrls,
  };

  static Set<String> get _iconUrls => <String>{
    ...AppIcons.remoteUrlsForPreload,
    ...AppIcons.remoteUrlsForPreloadGameOnly,
  };

  static Set<String> get _imageUrls => <String>{
    ...AppImages.remoteUrlsForPreload,
  };

  static Set<String> get _riveUrls => <String>{
    ...AppRive.remoteUrlsForPreload,
  };

  /// Build AssetsData cho 1 URL: auto-derive label, version từ override map.
  static AssetsData _buildAsset(String url) {
    final newV = _versionOverrides[url] ?? 1;
    final oldV = newV > 1 ? newV - 1 : 1;
    return AssetsData(
      label: _labelOf(url),
      urlPath: url,
      oldVersion: oldV,
      newVersion: newV,
    );
  }

  /// Sinh label deterministic từ URL (làm cache key prefix).
  /// Lấy filename, strip extension, sanitize special chars → snake_case.
  ///
  /// Caveat: 2 URLs cùng filename ở 2 thư mục/CDN khác → label trùng.
  /// App hiện tại tất cả assets đều ở 1 CDN root → an toàn. Nếu sau này có
  /// CDN thứ 2, cần thêm namespace prefix vào label để tránh collision.
  static String _labelOf(String url) {
    final filename = url.split('/').last;
    final base = filename
        .replaceAll(RegExp(r'\.\w+$'), '') // strip extension
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_'); // sanitize
    return 'asset_$base';
  }
}
