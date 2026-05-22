/// Single source of truth cho môi trường (staging/prod).
///
/// Build chỉ cần truyền MỘT define duy nhất:
///   --dart-define=APP_ENV=staging   (mặc định)
///   --dart-define=APP_ENV=prod
///
/// Mọi URL khác nhau giữa staging/prod gom hết về đây — không truyền URL
/// qua --dart-define nữa để release & Shorebird patch không bao giờ bị lệch.
enum AppEnvironment { staging, prod }

class AppEnv {
  AppEnv._();

  static const _raw =
      String.fromEnvironment('APP_ENV', defaultValue: 'staging');

  static final AppEnvironment current =
      _raw == 'prod' ? AppEnvironment.prod : AppEnvironment.staging;

  static bool get isProd => current == AppEnvironment.prod;
  static bool get isStaging => current == AppEnvironment.staging;

  // ===== Brand config (sun88) =====
  static String get brandConfigUrl => isProd
      ? 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88.json'
      : 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/s88_staging.json';

  // ===== Caxilo (casino) config =====
  static String get caxiloConfigUrl => isProd
      ? 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_prod.json'
      : 'https://raw.githubusercontent.com/Vulcan-dev-25/configs/main/caxilo_staging.json';
}
