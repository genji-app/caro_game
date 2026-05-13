import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_app_config.freezed.dart';
part 'download_app_config.g.dart';

/// Config download app — load từ remote (GitHub raw, plain JSON).
///
/// Schema:
/// ```json
/// {
///   "app_name": "Caro AI - Classic",
///   "description": "...",
///   "full_description": "...",
///   "type": "Game",
///   "url_icon_app": "",
///   "url_ios_store": "https://apps.apple.com/...",
///   "url_android_store": "",
///   "url_file_android_apk": "https://.../app.apk"
/// }
/// ```
///
/// Mọi field empty string sẽ được dùng làm tín hiệu để ẩn widget tương ứng
/// trong [DialogDownloadApp].
@freezed
sealed class DownloadAppConfig with _$DownloadAppConfig {
  const factory DownloadAppConfig({
    @JsonKey(name: 'app_name') @Default('') String appName,
    @JsonKey(name: 'description') @Default('') String description,
    @JsonKey(name: 'full_description') @Default('') String fullDescription,
    @JsonKey(name: 'type') @Default('') String type,
    @JsonKey(name: 'url_demo_screen') @Default('') String demoScreenshot,
    @JsonKey(name: 'url_icon_app') @Default('') String urlIconApp,
    @JsonKey(name: 'url_ios_store') @Default('') String urlIosStore,
    @JsonKey(name: 'url_android_store') @Default('') String urlAndroidStore,
    @JsonKey(name: 'url_file_android_apk')
    @Default('')
    String urlFileAndroidApk,
  }) = _DownloadAppConfig;

  factory DownloadAppConfig.fromJson(Map<String, Object?> json) =>
      _$DownloadAppConfigFromJson(json);
}
