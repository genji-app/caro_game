import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

/// Sport type identifiers
///
/// Each sport has a unique ID used across the API
enum SportType {
  soccer(1, 'Soccer', 'Bong da'),
  basketball(2, 'Basketball', 'Bong ro'),
  boxing(3, 'Boxing/MMA', 'Quyen anh'),
  tennis(4, 'Tennis', 'Quan vot'),
  volleyball(5, 'Volleyball', 'Bong chuyen'),
  tableTennis(6, 'Table Tennis', 'Bong ban'),
  badminton(7, 'Badminton', 'Cau long');

  final int id;
  final String nameEn;
  final String nameVi;

  const SportType(this.id, this.nameEn, this.nameVi);

  /// Get sport by ID
  static SportType? fromId(int id) {
    try {
      return SportType.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  String get iconPath {
    switch (this) {
      case SportType.soccer:
        return AppIcons.iconSoccer;
      case SportType.basketball:
        return AppIcons.iconBasketball;
      case SportType.tennis:
        return AppIcons.iconTennis;
      case SportType.volleyball:
        return AppIcons.iconVolleyball;
      case SportType.tableTennis:
        return AppIcons.iconTableTennis;
      case SportType.badminton:
        return AppIcons.iconBadminton;
      default:
        return '';
    }
  }

  /// Get display name based on locale
  String displayName({bool vietnamese = true}) => vietnamese ? nameVi : nameEn;
}

/// Time range for event filtering
///
/// Maps to the `timeRange` query parameter in the API
enum EventTimeRange {
  /// Live/Running events (timeRange = 0)
  live(0, 'Live', 'Truc tuyen'),

  /// Today's events (timeRange = 1)
  today(1, 'Today', 'Hom nay'),

  /// Early/Upcoming events (timeRange = 2)
  early(2, 'Early', 'Dau som'),

  /// Today + Early combined (timeRange = 3)
  todayAndEarly(3, 'All', 'Tat ca');

  final int value;
  final String labelEn;
  final String labelVi;

  const EventTimeRange(this.value, this.labelEn, this.labelVi);

  /// Get display label based on locale
  String displayLabel({bool vietnamese = true}) =>
      vietnamese ? labelVi : labelEn;

  /// Get time range by value
  static EventTimeRange fromValue(int value) {
    return EventTimeRange.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventTimeRange.live,
    );
  }
}

/// Boxing/MMA sport types
///
/// Only applicable when sportId = 3 (Boxing)
enum BoxingType {
  muayThai(1, 'Muay Thai'),
  mma(2, 'MMA/UFC'),
  boxing(3, 'Boxing');

  final int id;
  final String name;

  const BoxingType(this.id, this.name);

  /// Get boxing type by ID
  static BoxingType? fromId(int? id) {
    if (id == null) return null;
    try {
      return BoxingType.values.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Game part indicators for live events
///
/// Indicates the current phase of the match
enum GamePart {
  notStarted(0, 'Not Started', 'Chua bat dau'),
  firstHalf(1, '1st Half', 'Hiep 1'),
  secondHalf(2, '2nd Half', 'Hiep 2'),
  halfTime(3, 'Half Time', 'Nghi giua hiep'),
  extraTime1(4, 'ET 1st', 'Hiep phu 1'),
  extraTime2(5, 'ET 2nd', 'Hiep phu 2'),
  penalties(6, 'Penalties', 'Luan luu'),
  fullTime(7, 'Full Time', 'Ket thuc'),
  running(8, 'Running', 'Dang chay');

  final int value;
  final String labelEn;
  final String labelVi;

  const GamePart(this.value, this.labelEn, this.labelVi);

  /// Get game part by value
  static GamePart fromValue(int value) {
    return GamePart.values.firstWhere(
      (g) => g.value == value,
      orElse: () => GamePart.notStarted,
    );
  }

  /// Get display label based on locale
  String displayLabel({bool vietnamese = true}) =>
      vietnamese ? labelVi : labelEn;

  /// Check if this is a live state
  bool get isLive => value >= 1 && value <= 6 || value == 8;

  /// Check if match is finished
  bool get isFinished => value == 7;
}
