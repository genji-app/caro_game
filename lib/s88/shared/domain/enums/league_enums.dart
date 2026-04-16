// DEPRECATED: Use SportType from package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart
// enum SportId {
//   unknown(0),
//   football(1),
//   basketball(2),
//   boxing(3),
//   tennis(4),
//   volleyball(5);
//
//   final int value;
//   const SportId(this.value);
//
//   static SportId fromInt(int value) {
//     return SportId.values.firstWhere(
//       (e) => e.value == value,
//       orElse: () => SportId.unknown,
//     );
//   }
//
//   String get iconPath {
//     switch (this) {
//       case SportId.football:
//         return AppIcons.iconSoccer;
//       case SportId.basketball:
//         return AppIcons.iconBasketball;
//       case SportId.tennis:
//         return AppIcons.iconTennis;
//       case SportId.volleyball:
//         return AppIcons.iconVolleyball;
//       default:
//         return '';
//     }
//   }
// }

/// Odds Style Enum
///
/// Different odds display formats
enum OddsStyle {
  malay(0, 'MY'),
  indo(1, 'ID'),
  decimal(2, 'DE'),
  hongKong(3, 'HK');

  final int value;
  final String shortName;
  const OddsStyle(this.value, this.shortName);

  static OddsStyle fromInt(int value) {
    return OddsStyle.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OddsStyle.malay,
    );
  }

  /// Parse from shortName ('MY', 'ID', 'DE', 'HK') or legacy full name ('malay', 'indo', 'decimal', 'hongkong')
  static OddsStyle fromShortName(String? name) {
    if (name == null) return OddsStyle.decimal;

    // Try shortName first
    for (final style in OddsStyle.values) {
      if (style.shortName == name) return style;
    }

    // Fallback to legacy full name (backwards compatibility)
    switch (name.toLowerCase()) {
      case 'malay':
        return OddsStyle.malay;
      case 'indo':
        return OddsStyle.indo;
      case 'decimal':
        return OddsStyle.decimal;
      case 'hongkong':
        return OddsStyle.hongKong;
      default:
        return OddsStyle.decimal; // Default to decimal, not malay
    }
  }
}

/// Odds Type Enum
///
/// Represents which odds value to use
enum OddsType {
  none(0),
  home(1), // Home team / Over / Odd
  away(2), // Away team / Under / Even
  draw(3); // Draw (for 1X2, Double Chance)

  final int value;
  const OddsType(this.value);
}

/// Game Part Enum (Football periods)
///
/// According to FLUTTER_LIVE_MATCH_STATS_GUIDE.md:
/// API values: firstHalf=2, halfTime=4, secondHalf=8, finished=16, etc.
enum GamePart {
  notStarted(0),
  firstHalf(2), // API value: 2
  halfTime(4), // API value: 4
  secondHalf(8), // API value: 8
  finished(16), // API value: 16
  regulaTimeFinished(32), // API value: 32
  firstHalfExtraTime(64), // API value: 64
  halfTimeOfExtraTime(128), // API value: 128
  secondHalfExtraTime(256), // API value: 256
  extraTimeFinished(512), // API value: 512
  penalties(1024); // API value: 1024 (penaltyShootout)

  final int value;
  const GamePart(this.value);

  /// Parse gamePart from API value
  /// According to FLUTTER_LIVE_MATCH_STATS_GUIDE.md, API uses bit flags:
  /// firstHalf=2, halfTime=4, secondHalf=8, finished=16, etc.
  static GamePart fromInt(int? value) {
    if (value == null || value == 0) return GamePart.notStarted;

    // Try exact match first
    try {
      return GamePart.values.firstWhere(
        (e) => e.value == value,
        orElse: () => GamePart.notStarted,
      );
    } catch (_) {
      return GamePart.notStarted;
    }
  }

  String get displayName {
    switch (this) {
      case GamePart.notStarted:
        return 'Not Started';
      case GamePart.firstHalf:
        return 'Hiệp 1';
      case GamePart.halfTime:
        return 'HT';
      case GamePart.secondHalf:
        return 'Hiệp 2';
      case GamePart.finished:
        return 'FT';
      case GamePart.regulaTimeFinished:
        return "90'";
      case GamePart.firstHalfExtraTime:
        return 'ET1';
      case GamePart.halfTimeOfExtraTime:
        return 'ET-HT';
      case GamePart.secondHalfExtraTime:
        return 'ET2';
      case GamePart.extraTimeFinished:
        return 'AET';
      case GamePart.penalties:
        return 'PEN';
    }
  }
}
