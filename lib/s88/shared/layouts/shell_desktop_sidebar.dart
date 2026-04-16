import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/features/download_app/dialog_download_app.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
// V2 imports for navigation
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/top_league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/navigation_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Left sidebar chung cho desktop layout
/// Hiển thị menu và tabs Thể thao/Casino
class ShellDesktopSidebar extends ConsumerStatefulWidget {
  final VoidCallback? onItemTap;

  /// Khi set (mobile/drawer): tap "Top giải đấu" gọi callback thay vì goToTournaments().
  final VoidCallback? onTopTournamentsTapForMobile;

  final bool isDesktop;

  const ShellDesktopSidebar({
    super.key,
    this.onItemTap,
    this.onTopTournamentsTapForMobile,
    this.isDesktop = true,
  });

  @override
  ConsumerState<ShellDesktopSidebar> createState() =>
      _ShellDesktopSidebarState();
}

class _ShellDesktopSidebarState extends ConsumerState<ShellDesktopSidebar> {
  MenuItemType? _selectedItem = MenuItemType.allSports;

  String _getIconPath(MenuItemType type, bool isSelected) {
    switch (type) {
      case MenuItemType.allSports:
        return isSelected ? AppIcons.iconHomeSelected : AppIcons.iconHome;
      case MenuItemType.live:
        return AppIcons.liveDot;
      case MenuItemType.upcoming:
        return isSelected ? AppIcons.iconTimerSelected : AppIcons.iconComming;
      case MenuItemType.myBets:
        return isSelected ? AppIcons.iconBet1Selected : AppIcons.iconMyOrder;
      case MenuItemType.topTournaments:
        return isSelected ? AppIcons.iconTrophySelected : AppIcons.iconTrophy;
      case MenuItemType.events:
        return isSelected ? AppIcons.iconEventSelected : AppIcons.iconEvent;
      case MenuItemType.volta:
      case MenuItemType.soccer:
        return isSelected ? AppIcons.iconSoccerSelected : AppIcons.iconSoccer;
      case MenuItemType.badminton:
        return isSelected
            ? AppIcons.iconBadmintonSelected
            : AppIcons.iconBadminton;
      case MenuItemType.tennis:
        return isSelected ? AppIcons.iconTennisSelected : AppIcons.iconTennis;
      case MenuItemType.basketball:
        return isSelected
            ? AppIcons.iconBasketballSelected
            : AppIcons.iconBasketball;
      case MenuItemType.tableTennis:
        return isSelected
            ? AppIcons.iconTableTennisSelected
            : AppIcons.iconTableTennis;
      case MenuItemType.volleyball:
        return isSelected
            ? AppIcons.iconVolleyballSelected
            : AppIcons.iconVolleyball;
      case MenuItemType.liveChat:
        return isSelected ? AppIcons.iconChatSelected : AppIcons.iconLivechat;
      case MenuItemType.depositWithdraw:
        return isSelected
            ? AppIcons.iconTransferSelected
            : AppIcons.arrowsOppositeDirection;
      case MenuItemType.trollSport:
        return isSelected
            ? AppIcons.iconEmojiSelected
            : AppIcons.iconTrollSport;
      case MenuItemType.analysis:
        return isSelected ? AppIcons.iconNewsSelected : AppIcons.iconRemark;
      case MenuItemType.support:
        return isSelected ? AppIcons.iconSupportSelected : AppIcons.iconSupport;
      case MenuItemType.settings:
        return isSelected ? AppIcons.iconSettingSelected : AppIcons.iconSetting;
      case MenuItemType.downloadApp:
        return isSelected
            ? AppImages.iconDownloadApp
            : AppImages.iconDownloadApp;
    }
  }

  MenuItemType _sportTypeToMenuItem(v2.SportType sport) {
    switch (sport) {
      case v2.SportType.soccer:
        return MenuItemType.soccer;
      case v2.SportType.badminton:
        return MenuItemType.badminton;
      case v2.SportType.tennis:
        return MenuItemType.tennis;
      case v2.SportType.basketball:
        return MenuItemType.basketball;
      case v2.SportType.tableTennis:
        return MenuItemType.tableTennis;
      case v2.SportType.volleyball:
        return MenuItemType.volleyball;
      default:
        return MenuItemType.allSports;
    }
  }

  void _onMenuItemTap(MenuItemType type) {
    setState(() {
      _selectedItem = type;
    });

    switch (type) {
      case MenuItemType.myBets:
        ref.read(myBetOverlayVisibleProvider.notifier).open();
      case MenuItemType.allSports:
        ref.read(mainContentProvider.notifier).goToSport();
      case MenuItemType.live:
        ref.read(mainContentProvider.notifier).goToLive();
      case MenuItemType.topTournaments:
        if (widget.onTopTournamentsTapForMobile != null) {
          widget.onTopTournamentsTapForMobile!();
        } else {
          ref.read(mainContentProvider.notifier).goToTournaments();
        }
      case MenuItemType.upcoming:
        ref.read(mainContentProvider.notifier).goToUpcoming();
      case MenuItemType.events:
        _dontSupportSportDetailMenuItemTap();
      case MenuItemType.volta:
        _dontSupportSportDetailMenuItemTap();
      case MenuItemType.soccer:
        _onSportDetailMenuItemTap(SportType.soccer.id);
      case MenuItemType.badminton:
        _onSportDetailMenuItemTap(SportType.badminton.id);
      case MenuItemType.tennis:
        _onSportDetailMenuItemTap(SportType.tennis.id);
      case MenuItemType.basketball:
        _onSportDetailMenuItemTap(SportType.basketball.id);
      case MenuItemType.tableTennis:
        _onSportDetailMenuItemTap(SportType.tableTennis.id);
      case MenuItemType.volleyball:
        _onSportDetailMenuItemTap(SportType.volleyball.id);
      case MenuItemType.support:
        widget.onItemTap?.call();
        if (kIsWeb) {
          launchUrl(
            Uri.parse(
              SbConfig.livechatUrl,
            ),
            mode: LaunchMode.externalApplication,
          );
        } else {
          ref.read(mainContentProvider.notifier).goToSun247();
        }
        return;
      case MenuItemType.downloadApp:
        showDialog(
          context: context,
          builder: (context) => const DialogDownloadApp(),
        );
        return;
      case MenuItemType.liveChat:
      case MenuItemType.depositWithdraw:
      case MenuItemType.trollSport:
      case MenuItemType.analysis:
      case MenuItemType.settings:
        _dontSupportSportDetailMenuItemTap();
    }

    widget.onItemTap?.call();
  }

  void _onSportDetailMenuItemTap(int sportId) {
    // Navigate to sport detail
    ref.read(previousContentProvider.notifier).state = MainContentType.home;
    // Use V2 provider for sport selection
    final sport = v2.SportType.fromId(sportId) ?? v2.SportType.soccer;
    ref.read(selectedSportV2Provider.notifier).state = sport;

    // Update socket subscription (V2 protocol: unsub old sport / sub new sport)
    ref
        .read(sportSocketAdapterProvider)
        .subscriptionManager
        .setActiveSport(sportId);

    ref.read(mainContentProvider.notifier).goToSportDetail();
  }

  void _dontSupportSportDetailMenuItemTap() {
    AppToast.showError(context, message: 'Tính năng này chưa được hỗ trợ');
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = ref.watch(mainContentProvider);
    final isHome = currentContent == MainContentType.home;
    final isCasinoActive = currentContent == MainContentType.casino;
    final isSportActive = !isCasinoActive && !isHome;
    // Khi ở home: không selected menu item nào.
    // Khi dùng trong drawer (mobile): sync selected với content để "Top giải đấu" selected khi đang ở tournaments.
    // Derive selected item from mainContentProvider so sidebar reflects navigation from outside (e.g. banners).
    final MenuItemType? effectiveSelectedItem;
    if (isHome) {
      effectiveSelectedItem = null;
    } else if (widget.onTopTournamentsTapForMobile != null &&
        currentContent == MainContentType.tournaments) {
      effectiveSelectedItem = MenuItemType.topTournaments;
    } else if (currentContent == MainContentType.sport) {
      effectiveSelectedItem = MenuItemType.allSports;
    } else if (currentContent == MainContentType.live) {
      effectiveSelectedItem = MenuItemType.live;
    } else if (currentContent == MainContentType.upcoming) {
      effectiveSelectedItem = MenuItemType.upcoming;
    } else if (currentContent == MainContentType.tournaments) {
      effectiveSelectedItem = MenuItemType.topTournaments;
    } else if (currentContent == MainContentType.sportDetail) {
      final sport = ref.watch(selectedSportV2Provider);
      effectiveSelectedItem = _sportTypeToMenuItem(sport);
    } else if (currentContent == MainContentType.leagueDetail) {
      // League sub-item handles its own selected state in _buildLeagueItem,
      // so don't highlight the parent sport menu item.
      effectiveSelectedItem = null;
    } else {
      effectiveSelectedItem = _selectedItem;
    }

    return SizedBox(
      width: widget.isDesktop ? 260 : double.infinity,
      child: Container(
        alignment: Alignment.topCenter,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs: Thể thao / Casino
                Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: widget.isDesktop ? 0 : 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Thể thao',
                          iconPlatform: AppIcons.iconSoccer,
                          iconPlatformSelected: AppIcons.iconSoccerSelected,
                          icon: AppImages.sportcasinotrueactivefalse,
                          iconSelected: AppImages.sportcasinotrueactivetrue,
                          isActive: isSportActive,
                          onTap: () {
                            ref.read(mainContentProvider.notifier).goToSport();
                            setState(() {
                              _selectedItem = MenuItemType.allSports;
                            });
                          },
                        ),
                      ),
                      const Gap(AppSpacingStyles.space200),
                      Expanded(
                        child: _TabButton(
                          label: 'Casino',
                          iconPlatform: AppIcons.iconCasino,
                          iconPlatformSelected: AppIcons.iconCasinoSelected,
                          icon: AppImages.sportcasinofalseactivefalse,
                          iconSelected: AppImages.sportcasinofalseactivetrue,
                          isActive: isCasinoActive,
                          onTap: () {
                            ref.read(mainContentProvider.notifier).goToCasino();
                            _updateCasinoSelection(
                              const GameCategorySelection(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacingStyles.space400),
                // Conditionally show sport or casino menu items
                if (isCasinoActive)
                  ..._buildCasinoMenuItems()
                else ...[
                  // Main menu
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.allSports,
                      effectiveSelectedItem == MenuItemType.allSports,
                    ),
                    label: 'Tất cả thể thao',
                    isSelected: effectiveSelectedItem == MenuItemType.allSports,
                    onTap: () => _onMenuItemTap(MenuItemType.allSports),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.live,
                      effectiveSelectedItem == MenuItemType.live,
                    ),
                    label: 'Đang diễn ra',
                    txtColorDefault: const Color(0xFF989582),
                    isSelected: effectiveSelectedItem == MenuItemType.live,
                    onTap: () => _onMenuItemTap(MenuItemType.live),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.upcoming,
                      effectiveSelectedItem == MenuItemType.upcoming,
                    ),
                    label: 'Sắp diễn ra',
                    isSelected: effectiveSelectedItem == MenuItemType.upcoming,
                    onTap: () => _onMenuItemTap(MenuItemType.upcoming),
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final betCount = ref.watch(
                        myBetNotifierProvider.select((s) => s.betSlipCount),
                      );
                      return _MenuItem(
                        icon: _getIconPath(
                          MenuItemType.myBets,
                          effectiveSelectedItem == MenuItemType.myBets,
                        ),
                        label: 'Cược của tôi',
                        isSelected:
                            effectiveSelectedItem == MenuItemType.myBets,
                        badge: betCount > 0
                            ? (betCount > 99 ? '99+' : betCount.toString())
                            : null,
                        onTap: () {
                          if (effectiveSelectedItem != MenuItemType.myBets) {
                            _onMenuItemTap(MenuItemType.myBets);
                          }
                        },
                        showSelectedShadow:
                            widget.onTopTournamentsTapForMobile == null,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.topTournaments,
                      effectiveSelectedItem == MenuItemType.topTournaments,
                    ),
                    label: 'Top giải đấu',
                    isSelected:
                        effectiveSelectedItem == MenuItemType.topTournaments,
                    onTap: () => _onMenuItemTap(MenuItemType.topTournaments),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                  _buildDivider(),
                  // Sport types section
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Text(
                      'Môn thể thao',
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAA49B),
                      ),
                    ),
                  ),
                  const Gap(2),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.soccer.id,
                    type: MenuItemType.soccer,
                    label: 'Bóng đá',
                    isSelected: effectiveSelectedItem == MenuItemType.soccer,
                    onTap: () => _onMenuItemTap(MenuItemType.soccer),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                    initExpanded: true,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.badminton.id,
                    type: MenuItemType.badminton,
                    label: 'Cầu lông',
                    isSelected: effectiveSelectedItem == MenuItemType.badminton,
                    onTap: () => _onMenuItemTap(MenuItemType.badminton),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                    initExpanded: true,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.tennis.id,
                    type: MenuItemType.tennis,
                    label: 'Quần vợt',
                    isSelected: effectiveSelectedItem == MenuItemType.tennis,
                    onTap: () => _onMenuItemTap(MenuItemType.tennis),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.basketball.id,
                    type: MenuItemType.basketball,
                    label: 'Bóng rổ',
                    isSelected:
                        effectiveSelectedItem == MenuItemType.basketball,
                    onTap: () => _onMenuItemTap(MenuItemType.basketball),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                  ),
                  _ExpandableSportMenuItem(
                    sportId: v2.SportType.volleyball.id,
                    type: MenuItemType.volleyball,
                    label: 'Bóng chuyền',
                    isSelected:
                        effectiveSelectedItem == MenuItemType.volleyball,
                    onTap: () => _onMenuItemTap(MenuItemType.volleyball),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                    getIconPath: _getIconPath,
                    onLeagueTap: widget.onItemTap,
                  ),
                  _buildDivider(),
                  Visibility(
                    visible: kIsWeb,
                    child: _MenuItem(
                      icon: _getIconPath(
                        MenuItemType.downloadApp,
                        effectiveSelectedItem == MenuItemType.downloadApp,
                      ),
                      label: 'Tải app cho IOS & Android',
                      isSelected:
                          effectiveSelectedItem == MenuItemType.downloadApp,
                      onTap: () => _onMenuItemTap(MenuItemType.downloadApp),
                      showSelectedShadow:
                          widget.onTopTournamentsTapForMobile == null,
                    ),
                  ),
                  _MenuItem(
                    icon: _getIconPath(
                      MenuItemType.support,
                      effectiveSelectedItem == MenuItemType.support,
                    ),
                    label: 'Hỗ trợ',
                    isSelected: effectiveSelectedItem == MenuItemType.support,
                    onTap: () => _onMenuItemTap(MenuItemType.support),
                    showSelectedShadow:
                        widget.onTopTournamentsTapForMobile == null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Casino categories to show above the divider (priority items).
  static const _casinoPriorityTypes = {GameType.jackpot};

  /// Casino game types to exclude from the standard section.
  static const _casinoExcludedTypes = {GameType.sport};

  /// Update shared casino category selection and notify filter provider.
  void _updateCasinoSelection(GameCategorySelection selection) {
    ref.read(gameCategorySelectionProvider.notifier).state = selection;
    ref.read(gameFilterProvider.notifier).setCategorySelection(selection);
    widget.onItemTap?.call();
  }

  List<Widget> _buildCasinoMenuItems() {
    final categoryData = ref.watch(gameCategoriesProvider);
    final categories = categoryData.categories;
    final selection = ref.watch(gameCategorySelectionProvider);
    final showShadow = widget.onTopTournamentsTapForMobile == null;

    // Split categories into priority (SunWin, Jackpot) and standard groups
    final priorityCategories = <GameCategory>[];
    final standardCategories = <GameCategory>[];

    for (final category in categories) {
      switch (category) {
        case ProviderCategory():
          priorityCategories.add(category);
        case GameTypeCategory(type: final type):
          if (_casinoPriorityTypes.contains(type)) {
            priorityCategories.add(category);
          } else if (!_casinoExcludedTypes.contains(type)) {
            standardCategories.add(category);
          }
        case CustomCategory():
          // Skip custom categories (e.g. New Games) in sidebar
          break;
      }
    }

    return [
      // "Tất cả casino"
      _MenuItem(
        icon: allCategoryConfig.getIconPath(active: selection.isEmpty),
        label: 'Tất cả casino',
        isSelected: selection.isEmpty,
        onTap: () => _updateCasinoSelection(const GameCategorySelection()),
        showSelectedShadow: showShadow,
      ),
      // Priority categories (SunWin, Jackpot)
      for (final category in priorityCategories)
        _MenuItem(
          icon: category.getIconPath(
            active: selection.category?.id == category.id,
          ),
          label: category.label,
          isSelected: selection.category?.id == category.id,
          onTap: () => _updateCasinoSelection(
            GameCategorySelection.fromCategory(category),
          ),
          showSelectedShadow: showShadow,
        ),
      _buildDivider(),
      // Standard game type categories
      for (final category in standardCategories)
        _MenuItem(
          icon: category.getIconPath(
            active: selection.category?.id == category.id,
          ),
          label: category.label,
          isSelected: selection.category?.id == category.id,
          onTap: () => _updateCasinoSelection(
            GameCategorySelection.fromCategory(category),
          ),
          showSelectedShadow: showShadow,
        ),
    ];
  }

  Widget _buildDivider() => RepaintBoundary(
    child: Padding(
      padding: const EdgeInsets.only(left: 8, right: 0, bottom: 8, top: 10),
      child: ImageHelper.load(
        path: AppIcons.hr,
        width: double.infinity,
        height: 2,
        fit: BoxFit.fill,
      ),
    ),
  );
}

class _TabButton extends StatelessWidget {
  final String label;
  final String icon;
  final String iconSelected;
  final String iconPlatform;
  final String iconPlatformSelected;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.iconSelected,
    required this.isActive,
    required this.onTap,
    required this.iconPlatform,
    required this.iconPlatformSelected,
  });

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    color: Colors.white.withValues(alpha: 0.02),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 69,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 69,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    child: ImageHelper.load(
                      path: isActive ? iconSelected : icon,
                      width: double.infinity,
                      height: 69,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageHelper.load(
                      path: isActive ? iconPlatformSelected : iconPlatform,
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                    ),
                    const Gap(10),
                    Text(
                      label,
                      style: AppTextStyles.displayStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.yellow300
                            : AppColorStyles.contentSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final String? badge;
  final Widget? trailing;
  final Color? txtColorDefault;
  final VoidCallback? onTap;

  /// Khi false (drawer/mobile): không load menuSelectedShadow/menuSelected từ network để tránh crash ENOMEM.
  final bool showSelectedShadow;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.badge,
    this.trailing,
    this.txtColorDefault,
    this.onTap,
    this.showSelectedShadow = true,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        if (isSelected && showSelectedShadow)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: -30,
                child: RepaintBoundary(
                  child: ImageHelper.load(
                    path: AppIcons.menuSelectedShadow,
                    width: 30,
                    height: 97,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.menuSelected,
                  width: 1,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 36,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0x14FFD791), Color(0x00FFD791)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  RepaintBoundary(
                    child: ImageHelper.load(
                      path: icon,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFFFD691)
                            : txtColorDefault ?? const Color(0xFFAAA49B),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      width: 28,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.green300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Center(
                        child: Text(
                          int.parse(badge ?? '0') > 99 ? '99+' : (badge ?? '0'),
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray950,
                          ),
                        ),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ExpandableSportMenuItem extends ConsumerStatefulWidget {
  final int sportId;
  final MenuItemType type;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showSelectedShadow;
  final String Function(MenuItemType, bool) getIconPath;
  final VoidCallback? onLeagueTap;

  final bool initExpanded;

  const _ExpandableSportMenuItem({
    required this.sportId,
    required this.type,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.showSelectedShadow,
    required this.getIconPath,
    this.onLeagueTap,
    this.initExpanded = false,
  });

  @override
  ConsumerState<_ExpandableSportMenuItem> createState() =>
      _ExpandableSportMenuItemState();
}

class _ExpandableSportMenuItemState
    extends ConsumerState<_ExpandableSportMenuItem> {
  bool _isExpanded = false;
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final leaguesAsync = ref.watch(topLeagueEventsProvider(widget.sportId));
    final leagues = leaguesAsync.valueOrNull;
    final hasData = leagues != null && leagues.isNotEmpty;

    // Auto expand synchronously - no Future.microtask needed.
    // Setting state flags outside setState is safe during build when
    // we only read them later in the same build call.
    if (widget.initExpanded && hasData && !_hasInitialized) {
      _hasInitialized = true;
      _isExpanded = true;
    }

    return Column(
      children: [
        _MenuItem(
          icon: widget.getIconPath(widget.type, widget.isSelected),
          label: widget.label,
          isSelected: widget.isSelected,
          onTap: widget.onTap,
          showSelectedShadow: widget.showSelectedShadow,
          trailing: hasData
              ? InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFAAA49B),
                      size: 20,
                    ),
                  ),
                )
              : null,
        ),
        if (_isExpanded && hasData)
          Container(
            margin: const EdgeInsets.only(left: 24),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColorStyles.borderPrimary, width: 2),
              ),
            ),
            child: Column(
              children: leagues
                  .map((league) => _buildLeagueItem(league))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLeagueItem(LeagueModelV2 league) {
    final selectedLeague = ref.watch(selectedLeagueInfoProvider);
    final currentContent = ref.watch(mainContentProvider);
    final isSelected =
        currentContent == MainContentType.leagueDetail &&
        selectedLeague?.leagueId == league.leagueId;

    return Row(
      children: [
        if (isSelected && widget.showSelectedShadow)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: -30,
                child: RepaintBoundary(
                  child: ImageHelper.load(
                    path: AppIcons.menuSelectedShadow,
                    width: 30,
                    height: 97,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              RepaintBoundary(
                child: ImageHelper.load(
                  path: AppIcons.menuSelected,
                  width: 1,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        Expanded(
          child: InkWell(
            onTap: () {
              ref
                  .read(selectedLeagueInfoProvider.notifier)
                  .state = SelectedLeagueInfo(
                sportId: league.sportId,
                leagueId: league.leagueId,
                leagueName: league.leagueName,
                leagueLogo: league.leagueLogo,
              );
              ref.read(mainContentProvider.notifier).goToLeagueDetail();
              // Clear previous content so league detail header won't show back button
              ref.read(previousContentProvider.notifier).state = null;
              widget.onLeagueTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0x14FFD791), Color(0x00FFD791)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (league.leagueLogo.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        color: Colors.white,
                        width: 20,
                        height: 20,
                        child: ImageHelper.load(
                          path: league.leagueLogo,
                          fit: BoxFit.contain,
                          errorWidget: const SizedBox(width: 20),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      league.leagueName,
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFFFFD691)
                            : const Color(0xFFAAA49B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
