import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

enum BottomNavigationItem {
  menu,
  casino,
  bettingTickets,
  sports,
  sun247,
  home;

  /// Get the tab index of the navigation item
  int get tabIndex {
    switch (this) {
      case BottomNavigationItem.home:
        return 0;
      case BottomNavigationItem.casino:
        return 1;
      case BottomNavigationItem.bettingTickets:
        return 2;
      case BottomNavigationItem.sports:
        return 3;
      case BottomNavigationItem.menu:
        return 4;
      case BottomNavigationItem.sun247:
        return 5;
    }
  }

  /// Get the label for the navigation item
  String get label {
    switch (this) {
      case BottomNavigationItem.home:
        return 'Trang chủ';
      case BottomNavigationItem.casino:
        return 'Casino';
      case BottomNavigationItem.bettingTickets:
        return 'Phiếu cược';
      case BottomNavigationItem.sports:
        return 'Thể thao';
      case BottomNavigationItem.menu:
        return 'Menu';
      case BottomNavigationItem.sun247:
        return 'Sun 24/7';
    }
  }

  /// Get the icon path for the navigation item (unselected state)
  String get iconPath {
    switch (this) {
      case BottomNavigationItem.home:
        return AppIcons.iconS;
      case BottomNavigationItem.casino:
        return AppIcons.iconCasino;
      case BottomNavigationItem.bettingTickets:
        return AppIcons.iconBet;
      case BottomNavigationItem.sports:
        return AppIcons.iconSoccer;
      case BottomNavigationItem.menu:
        return AppIcons.iconMenu;
      case BottomNavigationItem.sun247:
        return AppIcons.iconLivechat;
    }
  }

  /// Get the selected icon path for the navigation item
  String get iconSelectedPath {
    switch (this) {
      case BottomNavigationItem.home:
        return AppIcons.iconSSelected;
      case BottomNavigationItem.casino:
        return AppIcons.iconCasinoSelected;
      case BottomNavigationItem.bettingTickets:
        return AppIcons.iconBetSelected;
      case BottomNavigationItem.sports:
        return AppIcons.iconSoccerSelected;
      case BottomNavigationItem.menu:
        return AppIcons.iconMenuSelected;
      case BottomNavigationItem.sun247:
        return AppIcons.iconChatSelected;
    }
  }

  /// Check if this is a sports item
  bool get isSport {
    return this == BottomNavigationItem.sports;
  }

  /// Get BottomNavigationItem from index (matches order in [all])
  static BottomNavigationItem fromIndex(int index) {
    switch (index) {
      case 0:
        return BottomNavigationItem.menu;
      case 1:
        return BottomNavigationItem.casino;
      case 2:
        return BottomNavigationItem.bettingTickets;
      case 3:
        return BottomNavigationItem.sports;
      case 4:
        return BottomNavigationItem.sun247;
      default:
        return BottomNavigationItem.sports; // Default to sports
    }
  }

  /// Get all navigation items in order
  static List<BottomNavigationItem> get all => [
    BottomNavigationItem.menu,
    BottomNavigationItem.casino,
    BottomNavigationItem.bettingTickets,
    BottomNavigationItem.sports,
    BottomNavigationItem.sun247,
  ];
}
