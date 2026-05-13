import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:caxilo_config/caxilo_config.dart' as cc;

class AppImages {
  static String get NETWORK_PATH => SbConfig.cdnImages;

  /// CDN base cho ảnh (remote). Thay cho bundle [assets/images].
  static String REMOTE_PATH = NETWORK_PATH;

  static String IMAGES_GAME_REMOTE_PATH = '$REMOTE_PATH/games';

  static String get activatedglow => '$REMOTE_PATH/activatedglow.webp';

  static String get avatar => '$REMOTE_PATH/avatar.webp';

  static String get backgroundBalance => '$REMOTE_PATH/background_balance.png';

  static String get backgroundBetDialog =>
      '$REMOTE_PATH/background_bet_dialog.webp';

  static String get backgroundHot => '$REMOTE_PATH/background_hot.webp';

  static String get backgroundHotTablet =>
      '$REMOTE_PATH/background_hot_tablet.webp';

  static String get backgroundJoin => '$REMOTE_PATH/background_join.webp';

  static String get btnRefill => '$REMOTE_PATH/btn_refill.png';

  static String get headerShadow => '$REMOTE_PATH/header_shadow.webp';

  static String get icCryptoKdg => '$REMOTE_PATH/ic_crypto_kdg.webp';

  static String get icPaymentGiftcode =>
      '$REMOTE_PATH/ic_payment_giftcode.webp';

  static String get imageSoccer => '$REMOTE_PATH/image_soccer.webp';

  static String get imageTennis => '$REMOTE_PATH/image_tennis.webp';

  static String get logoBundesliga => '$REMOTE_PATH/logo_bundesliga.png';

  static String get logoChampion => '$REMOTE_PATH/logo_champion.png';

  static String get logoLaliga => '$REMOTE_PATH/logo_laliga.png';

  static String get logoLeague1 => '$REMOTE_PATH/logo_league1.png';

  static String get logoPremileague => '$REMOTE_PATH/logo_premileague.png';

  static String get logoSeriA => '$REMOTE_PATH/logo_seriA.png';

  // static String get personHorseRacing => '$REMOTE_PATH/person_horse_racing.webp';

  static String get personSoccer => '$REMOTE_PATH/person_soccer.webp';

  // static String get personTableTennis => '$REMOTE_PATH/person_table_tennis.webp';

  static String get personTennis => '$REMOTE_PATH/person_tennis.webp';

  static String get personVolleyball => '$REMOTE_PATH/person_volleyball.webp';

  static String get personBasketball => '$REMOTE_PATH/person_basketball.webp';

  static String get personBadminton => '$REMOTE_PATH/person_badminton.webp';

  static String get betDetailBackgroundVolleyball =>
      '$REMOTE_PATH/bet_detail_background_volleyball.webp';

  static String get betDetailBackgroundBaseketball =>
      '$REMOTE_PATH/bet_detail_background_basketball.webp';

  static String get betDetailBackgroundTennis =>
      '$REMOTE_PATH/bet_detail_background_tennis.webp';

  static String get soccerstadiumphotoshot1 =>
      '$REMOTE_PATH/soccerstadiumphotoshot1.webp';
  //
  // static String get sportcasinofalseactivefalse =>
  //     '$REMOTE_PATH/sportcasinofalseactivefalse.webp';
  //
  // static String get sportcasinofalseactivetrue =>
  //     '$REMOTE_PATH/sportcasinofalseactivetrue.webp';
  //
  // static String get sportcasinotrueactivefalse =>
  //     '$REMOTE_PATH/sportcasinotrueactivefalse.webp';
  //
  // static String get sportcasinotrueactivetrue =>
  //     '$REMOTE_PATH/sportcasinotrueactivetrue.webp';

  static String get logoSun88 => '$REMOTE_PATH/logo_sun88.svg';
  static String get live => '$REMOTE_PATH/live.webp';
  static String get logoS88Home => '$REMOTE_PATH/logo_s88_home.webp';

  static String get imgBetTicket => '$REMOTE_PATH/img_bet_ticket.webp';

  static String get imgTransactionEmpty =>
      '$REMOTE_PATH/img_transaction_empty.webp';
  static String get imgGameBgSelected =>
      '$REMOTE_PATH/img_game_bg_selected.webp';
  static String get imgGameBanner => '$REMOTE_PATH/img_game_banner.webp';

  static String get iconSearchNoResultCasino =>
      '$REMOTE_PATH/icon_search_no_result_casino.webp';
  static String get iconSearchNoResultSport =>
      '$REMOTE_PATH/icon_search_no_result_sport.webp';

  static String get iconDownloadApp =>
      '$REMOTE_PATH/icon_menu_download_app.webp';
  static String get iconAppFake => '$REMOTE_PATH/icon_app_fake.webp';
  static String get imageAppDownload => '$REMOTE_PATH/image_app_download.webp';
  static String get imageDownloadByAndroid =>
      '$REMOTE_PATH/image_download_by_android.webp';
  static String get imageDownloadByAndroidAPK =>
      '$REMOTE_PATH/image_download_by_android_apk.webp';
  static String get imageDownloadByIos =>
      '$REMOTE_PATH/image_download_by_ios.webp';

  static String get profileActionBg => '$REMOTE_PATH/profile_action_bg.svg';

  static String get imageWorldCup => '$REMOTE_PATH/img_wwc.webp';
  static String get imageBannerSun88 => '$REMOTE_PATH/img_banner_sun88.webp';

  /// CDN filename typo: imge_banner_casino (giữ đúng tên file).
  static String get imageBannerCasino => '$REMOTE_PATH/imge_banner_casino.webp';

  static String get backgroundBetting => '$REMOTE_PATH/background_betting.webp';
  
  static String get imageBannerGame => '$REMOTE_PATH/img_banner_game.webp';

  //Spot and casino background
  static String get sportcasinofalseactivefalse =>
      '$REMOTE_PATH/background_casino.webp';

  static String get sportcasinofalseactivetrue =>
      '$REMOTE_PATH/background_casino_selected.webp';

  static String get sportcasinotrueactivefalse =>
      '$REMOTE_PATH/background_sport.webp';

  static String get sportcasinotrueactivetrue =>
      '$REMOTE_PATH/background_sport_selected.webp';

  static String get imgGameNotFound => '$REMOTE_PATH/img_game_not_found.webp';
  static String get imgGameBannerProvidersMedium =>
      '$REMOTE_PATH/img_game_banner_providers_medium.webp';

  /// Danh sách tất cả URL remote (ROOT_PATH) để preload. Không bao gồm assets.
  static List<String> get remoteUrlsForPreload => [
    ...remoteUrlsForPreloadExcludeGame,
    ...remoteUrlsForPreloadGameOnly,
  ];

  /// URL preload không bao gồm game (phase 1). Chỉ gồm getter đang được dùng trong source.
  static List<String> get remoteUrlsForPreloadExcludeGame => [
    activatedglow,
    avatar,
    backgroundBalance,
    backgroundBetDialog,
    backgroundHot,
    backgroundHotTablet,
    backgroundJoin,
    btnRefill,
    headerShadow,
    icCryptoKdg,
    icPaymentGiftcode,
    imageSoccer,
    imageTennis,
    logoBundesliga,
    logoChampion,
    logoLaliga,
    logoLeague1,
    logoPremileague,
    logoSeriA,
    // personHorseRacing,
    personSoccer,
    // personTableTennis,
    personTennis,
    personVolleyball,
    soccerstadiumphotoshot1,
    sportcasinofalseactivefalse,
    sportcasinofalseactivetrue,
    sportcasinotrueactivefalse,
    sportcasinotrueactivetrue,
    logoSun88,
    live,
    logoS88Home,
    betDetailBackgroundVolleyball,
    betDetailBackgroundBaseketball,
    betDetailBackgroundTennis,
    imgBetTicket,
    imgTransactionEmpty,
    imgGameBgSelected,
    imgGameBanner,
    iconSearchNoResultCasino,
    iconSearchNoResultSport,
    iconDownloadApp,
    iconAppFake,
    imageAppDownload,
    imageDownloadByAndroid,
    imageDownloadByAndroidAPK,
    imageDownloadByIos,
    profileActionBg,
    imageWorldCup,
    imageBannerSun88,
    imageBannerCasino,
    backgroundBetting,
    imgBetTicket,
    imgGameNotFound,
    imgGameBannerProvidersMedium,
  ];

  /// Chỉ ảnh game thumb (phase 2, preload sau khi xong phase 1).
  static List<String> get remoteUrlsForPreloadGameOnly => cc
      .CaxiloGameImages
      .allGameImages
      .map((String imageName) => '$IMAGES_GAME_REMOTE_PATH/$imageName')
      .toList();
}
