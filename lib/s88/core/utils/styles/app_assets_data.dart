import 'package:co_caro_flame/s88/core/utils/extensions/assets_data.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';

/// AssetsData definitions cho AppIcons và AppImages
///
/// File này chứa versioning information cho các icons/images cần cache với versioning.
/// Khi update icon/image, chỉ cần thay đổi `oldVersion` và `newVersion` ở đây.
///
/// Usage:
/// 1. Thêm AssetsData cho icon/image cần versioning
/// 2. Register trong app.dart: AssetsCacheManager.registerAssets(AppAssetsData.allIcons)
/// 3. ImageHelper.load() sẽ tự động dùng versioning
class AppAssetsData {
  AppAssetsData._();

  // ===== ICONS =====

  /// Icon: Icon_Basketball_selected.svg
  static AssetsData get iconBasketballSelected => AssetsData(
    label: 'icon_basketball_selected',
    urlPath: AppIcons.iconBasketballSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Football_selected.svg
  static AssetsData get iconFootballSelected => AssetsData(
    label: 'icon_football_selected',
    urlPath: AppIcons.iconFootballSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Tennis_selected.svg
  static AssetsData get iconTennisSelected => AssetsData(
    label: 'icon_tennis_selected',
    urlPath: AppIcons.iconTennisSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Volleyball_selected.svg
  static AssetsData get iconVolleyballSelected => AssetsData(
    label: 'icon_volleyball_selected',
    urlPath: AppIcons.iconVolleyballSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_table_tennis_selected.svg
  static AssetsData get iconTableTennisSelected => AssetsData(
    label: 'icon_table_tennis_selected',
    urlPath: AppIcons.iconTableTennisSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Bet_1_selected.svg
  static AssetsData get iconBet1Selected => AssetsData(
    label: 'icon_bet_1_selected',
    urlPath: AppIcons.iconBet1Selected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Chat_selected.svg
  static AssetsData get iconChatSelected => AssetsData(
    label: 'icon_chat_selected',
    urlPath: AppIcons.iconChatSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Setting_selected.svg
  static AssetsData get iconSettingSelected => AssetsData(
    label: 'icon_setting_selected',
    urlPath: AppIcons.iconSettingSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Support_selected.svg
  static AssetsData get iconSupportSelected => AssetsData(
    label: 'icon_support_selected',
    urlPath: AppIcons.iconSupportSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Trophy_selected.svg
  static AssetsData get iconTrophySelected => AssetsData(
    label: 'icon_trophy_selected',
    urlPath: AppIcons.iconTrophySelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_event_selected.svg
  static AssetsData get iconEventSelected => AssetsData(
    label: 'icon_event_selected',
    urlPath: AppIcons.iconEventSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_chart_selected.svg
  static AssetsData get iconChartSelected => AssetsData(
    label: 'icon_chart_selected',
    urlPath: AppIcons.iconChartSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_basketball.svg
  static AssetsData get iconBasketball => AssetsData(
    label: 'icon_basketball',
    urlPath: AppIcons.iconBasketball,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_soccer.svg
  static AssetsData get iconSoccer => AssetsData(
    label: 'icon_soccer',
    urlPath: AppIcons.iconSoccer,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: soccer.svg
  static AssetsData get soccer => AssetsData(
    label: 'soccer',
    urlPath: AppIcons.soccer,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: tennis.svg
  static AssetsData get tennis => AssetsData(
    label: 'tennis',
    urlPath: AppIcons.tennis,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: volleyball.svg
  static AssetsData get volleyball => AssetsData(
    label: 'volleyball',
    urlPath: AppIcons.volleyball,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_volleyball.svg
  static AssetsData get iconVolleyball => AssetsData(
    label: 'icon_volleyball',
    urlPath: AppIcons.iconVolleyball,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_bar_chart.svg
  static AssetsData get iconBarChart => AssetsData(
    label: 'icon_bar_chart',
    urlPath: AppIcons.iconBarChart,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_chart.svg
  static AssetsData get iconChart => AssetsData(
    label: 'icon_chart',
    urlPath: AppIcons.iconChart,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_parlay.svg
  static AssetsData get iconParlay => AssetsData(
    label: 'icon_parlay',
    urlPath: AppIcons.iconParlay,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: chevron_up.svg
  static AssetsData get chevronUp => AssetsData(
    label: 'chevron_up',
    urlPath: AppIcons.chevronUp,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: sport_status_selected.svg
  static AssetsData get sportStatusSelected => AssetsData(
    label: 'sport_status_selected',
    urlPath: AppIcons.sportStatusSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_s.svg
  static AssetsData get iconS => AssetsData(
    label: 'icon_s',
    urlPath: AppIcons.iconS,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: Icon_Menu_selected.svg
  static AssetsData get iconMenuSelected => AssetsData(
    label: 'icon_menu_selected',
    urlPath: AppIcons.iconMenuSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_soccer_selected.svg
  static AssetsData get iconSoccerSelected => AssetsData(
    label: 'icon_soccer_selected',
    urlPath: AppIcons.iconSoccerSelected,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_home_sport.svg
  static AssetsData get iconHomeSport => AssetsData(
    label: 'icon_home_sport',
    urlPath: AppIcons.iconHomeSport,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_coming_sport.svg
  static AssetsData get iconComingSport => AssetsData(
    label: 'icon_coming_sport',
    urlPath: AppIcons.iconComingSport,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Icon: icon_favorite_sport.svg
  static AssetsData get iconFavoriteSport => AssetsData(
    label: 'icon_favorite_sport',
    urlPath: AppIcons.iconFavoriteSport,
    oldVersion: 1,
    newVersion: 1,
  );

  // ===== IMAGES =====

  /// Image: live.webp
  static AssetsData get live => AssetsData(
    label: 'live',
    urlPath: AppImages.live,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: header_shadow.webp
  static AssetsData get headerShadow => AssetsData(
    label: 'header_shadow',
    urlPath: AppImages.headerShadow,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: avatar.webp
  static AssetsData get avatar => AssetsData(
    label: 'avatar',
    urlPath: AppImages.avatar,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: btn_refill.png
  static AssetsData get btnRefill => AssetsData(
    label: 'btn_refill',
    urlPath: AppImages.btnRefill,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: person_soccer.webp
  static AssetsData get personSoccer => AssetsData(
    label: 'person_soccer',
    urlPath: AppImages.personSoccer,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: person_tennis.webp
  static AssetsData get personTennis => AssetsData(
    label: 'person_tennis',
    urlPath: AppImages.personTennis,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: person_volleyball.webp
  static AssetsData get personVolleyball => AssetsData(
    label: 'person_volleyball',
    urlPath: AppImages.personVolleyball,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: person_table_tennis.webp
  // static AssetsData get personTableTennis => AssetsData(
  //   label: 'person_table_tennis',
  //   urlPath: AppImages.personTableTennis,
  //   oldVersion: 1,
  //   newVersion: 1,
  // );

  // /// Image: person_horse_racing.webp
  // static AssetsData get personHorseRacing => AssetsData(
  //   label: 'person_horse_racing',
  //   urlPath: AppImages.personHorseRacing,
  //   oldVersion: 1,
  //   newVersion: 1,
  // );

  /// Image: logo_bundesliga.png
  static AssetsData get logoBundesliga => AssetsData(
    label: 'logo_bundesliga',
    urlPath: AppImages.logoBundesliga,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_champion.png
  static AssetsData get logoChampion => AssetsData(
    label: 'logo_champion',
    urlPath: AppImages.logoChampion,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_laliga.png
  static AssetsData get logoLaliga => AssetsData(
    label: 'logo_laliga',
    urlPath: AppImages.logoLaliga,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_league1.png
  static AssetsData get logoLeague1 => AssetsData(
    label: 'logo_league1',
    urlPath: AppImages.logoLeague1,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_premileague.png
  static AssetsData get logoPremileague => AssetsData(
    label: 'logo_premileague',
    urlPath: AppImages.logoPremileague,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_seriA.png
  static AssetsData get logoSeriA => AssetsData(
    label: 'logo_seriA',
    urlPath: AppImages.logoSeriA,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_sun88.svg
  static AssetsData get logoSun88 => AssetsData(
    label: 'logo_sun88',
    urlPath: AppImages.logoSun88,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: logo_s88_home.webp
  static AssetsData get logoS88Home => AssetsData(
    label: 'logo_s88_home',
    urlPath: AppImages.logoS88Home,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: background_balance.png
  static AssetsData get backgroundBalance => AssetsData(
    label: 'background_balance',
    urlPath: AppImages.backgroundBalance,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: background_bet_dialog.webp
  static AssetsData get backgroundBetDialog => AssetsData(
    label: 'background_bet_dialog',
    urlPath: AppImages.backgroundBetDialog,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: background_hot.webp
  static AssetsData get backgroundHot => AssetsData(
    label: 'background_hot',
    urlPath: AppImages.backgroundHot,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: background_hot_tablet.webp
  static AssetsData get backgroundHotTablet => AssetsData(
    label: 'background_hot_tablet',
    urlPath: AppImages.backgroundHotTablet,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: image_soccer.webp
  static AssetsData get imageSoccer => AssetsData(
    label: 'image_soccer',
    urlPath: AppImages.imageSoccer,
    oldVersion: 1,
    newVersion: 1,
  );

  /// Image: image_tennis.webp
  static AssetsData get imageTennis => AssetsData(
    label: 'image_tennis',
    urlPath: AppImages.imageTennis,
    oldVersion: 1,
    newVersion: 1,
  );

  // ===== HELPER METHODS =====

  /// Tất cả icons cần versioning
  /// Register trong app.dart: AssetsCacheManager.registerAssets(AppAssetsData.allIcons)
  static List<AssetsData> get allIcons => [
    // Selected icons
    iconBasketballSelected,
    iconFootballSelected,
    iconTennisSelected,
    iconVolleyballSelected,
    iconTableTennisSelected,
    iconBet1Selected,
    iconChatSelected,
    iconSettingSelected,
    iconSupportSelected,
    iconTrophySelected,
    iconEventSelected,
    iconChartSelected,
    // Regular icons
    iconBasketball,
    iconSoccer,
    soccer,
    tennis,
    iconVolleyball,
    volleyball,
    iconBarChart,
    iconChart,
    iconParlay,
    chevronUp,
    sportStatusSelected,
    iconS,
    iconMenuSelected,
    iconSoccerSelected,
    iconHomeSport,
    iconComingSport,
    iconFavoriteSport,
  ];

  /// Tất cả images cần versioning
  static List<AssetsData> get allImages => [
    // Common images
    live,
    headerShadow,
    avatar,
    btnRefill,
    // Person images
    personSoccer,
    personTennis,
    personVolleyball,
    // personTableTennis,
    // personHorseRacing,
    // League logos
    logoBundesliga,
    logoChampion,
    logoLaliga,
    logoLeague1,
    logoPremileague,
    logoSeriA,
    // Brand logos
    logoSun88,
    logoS88Home,
    // Backgrounds
    backgroundBalance,
    backgroundBetDialog,
    backgroundHot,
    backgroundHotTablet,
    // Sport images
    imageSoccer,
    imageTennis,
  ];

  /// Tất cả assets (icons + images)
  /// Register trong app.dart: AssetsCacheManager.registerAssets(AppAssetsData.all)
  static List<AssetsData> get all => [...allIcons, ...allImages];
}
