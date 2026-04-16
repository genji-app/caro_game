/// Sport detail filter type - shared between mobile and desktop
enum SportDetailFilterType { today, special, early, live, favorites }

extension SportDetailFilterTypeX on SportDetailFilterType {
  String get label {
    switch (this) {
      case SportDetailFilterType.today:
        return 'Hôm nay';
      case SportDetailFilterType.special:
        return 'Đặc biệt';
      case SportDetailFilterType.early:
        return 'Đấu sớm';
      case SportDetailFilterType.live:
        return 'Trực tiếp';
      case SportDetailFilterType.favorites:
        return 'Yêu thích';
    }
  }

  String get labelEn {
    switch (this) {
      case SportDetailFilterType.today:
        return 'Today';
      case SportDetailFilterType.special:
        return 'Special';
      case SportDetailFilterType.early:
        return 'Early';
      case SportDetailFilterType.live:
        return 'Live';
      case SportDetailFilterType.favorites:
        return 'Favorites';
    }
  }
}
