/// Enum định nghĩa các loại content có thể hiển thị ở phần giữa
enum MainContentType {
  home,
  sport,
  casino,
  betDetail,
  sportDetail,
  sun247,
  tournaments,
  live,
  upcoming,
  leagueDetail,
}

/// Extension để lấy thông tin của mỗi content type
extension MainContentTypeExtension on MainContentType {
  /// Lấy tên hiển thị
  String get displayName {
    switch (this) {
      case MainContentType.home:
        return 'Trang chủ';
      case MainContentType.sport:
        return 'Thể thao';
      case MainContentType.casino:
        return 'Casino';
      case MainContentType.betDetail:
        return 'Chi tiết cược';
      case MainContentType.sportDetail:
        return 'Chi tiết thể thao';
      case MainContentType.sun247:
        return 'Sun 24/7';
      case MainContentType.tournaments:
        return 'Top giải đấu';
      case MainContentType.live:
        return 'Đang diễn ra';
      case MainContentType.upcoming:
        return 'Sắp diễn ra';
      case MainContentType.leagueDetail:
        return 'Chi tiết giải đấu';
    }
  }

  /// Check nếu là sport tab
  bool get isSport => this == MainContentType.sport;

  /// Check nếu là casino tab
  bool get isCasino => this == MainContentType.casino;

  /// Check nếu là home
  bool get isHome => this == MainContentType.home;

  /// Check nếu là bet detail
  bool get isBetDetail => this == MainContentType.betDetail;

  /// Check nếu là sport detail
  bool get isSportDetail => this == MainContentType.sportDetail;
}

/// Enum cho các menu item trong sidebar
enum MenuItemType {
  allSports,
  live,
  upcoming,
  myBets,
  topTournaments,
  volta,
  events,
  soccer,
  tennis,
  basketball,
  badminton,
  tableTennis,
  volleyball,
  liveChat,
  depositWithdraw,
  trollSport,
  analysis,
  support,
  settings,
  downloadApp,
}
