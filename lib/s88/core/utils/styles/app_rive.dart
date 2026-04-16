import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';

/// Remote CDN URLs cho Rive animations.

class AppRive {
  static String get networkPath => SbConfig.cdnRives;

  static String get animCardBig => '$networkPath/anim_card_big.riv';

  static String get animCardBigGlow =>
      '$networkPath/anim_card_big_glow.riv';

  static String get animCardNho => '$networkPath/anim_nho.riv';

  static String get animLoading => '$networkPath/anim_loading.riv';

  static List<String> get remoteUrlsForPreload => <String>[
        animCardBig,
        animCardBigGlow,
        animCardNho,
      ];
}
