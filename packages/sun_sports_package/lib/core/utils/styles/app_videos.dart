import 'package:sun_sports/core/services/config/sb_config.dart';

class AppVideos {
  static String get NETWORK_PATH => SbConfig.cdnVideos;

  /// CDN base cho video (remote). Thay cho bundle [assets/videos].
  static String REMOTE_PATH = NETWORK_PATH;

  // ===== VIDEO GETTERS =====
  // Thêm getter video tại đây theo pattern:
  // static String get videoIntro => '$REMOTE_PATH/intro.mp4';

  /// Danh sách tất cả URL remote ([REMOTE_PATH]) để preload.
  static List<String> get remoteUrlsForPreload =>
      _remoteVideoSuffixes.map((s) => '$REMOTE_PATH/$s').toList();

  /// Chỉ suffix đang được dùng trong source (qua getter hoặc path).
  static const List<String> _remoteVideoSuffixes = [];

  static String get iconBTI => '$REMOTE_PATH/intro_sun88.mp4';
}
