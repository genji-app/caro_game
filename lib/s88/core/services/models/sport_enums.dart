// DEPRECATED: Use SportType from package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart
// enum SportType {
//   football(1, 'Football'),
//   basketball(2, 'Basketball'),
//   boxing(3, 'Boxing'),
//   tennis(4, 'Tennis'),
//   volleyball(5, 'Volleyball'),
//   tableTennis(6, 'Table Tennis'),
//   badminton(7, 'Badminton'),
//   baseball(8, 'Baseball'),
//   iceHockey(9, 'Ice Hockey'),
//   esports(10, 'E-Sports');
//
//   const SportType(this.id, this.name);
//   final int id;
//   final String name;
//
//   static SportType fromId(int id) {
//     return SportType.values.firstWhere(
//       (type) => type.id == id,
//       orElse: () => SportType.football,
//     );
//   }
// }

/// Bet Status
enum BetStatus {
  pending('pending', 'Pending'),
  won('won', 'Won'),
  lost('lost', 'Lost'),
  voided('void', 'Void'),
  cashout('cashout', 'Cashed Out');

  const BetStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static BetStatus fromValue(String value) {
    return BetStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BetStatus.pending,
    );
  }
}

/// Market Class (Bet Type)
enum MarketClass {
  matchWinner('1x2', 'Match Winner'),
  asianHandicap('asian_handicap', 'Asian Handicap'),
  overUnder('over_under', 'Over/Under'),
  bothTeamsToScore('both_teams_to_score', 'Both Teams To Score'),
  correctScore('correct_score', 'Correct Score'),
  doubleChance('double_chance', 'Double Chance'),
  drawNoBet('draw_no_bet', 'Draw No Bet'),
  halfTimeFullTime('half_time_full_time', 'Half Time/Full Time'),
  firstHalf('first_half', 'First Half'),
  secondHalf('second_half', 'Second Half');

  const MarketClass(this.value, this.displayName);
  final String value;
  final String displayName;

  static MarketClass? fromValue(String value) {
    try {
      return MarketClass.values.firstWhere((cls) => cls.value == value);
    } catch (e) {
      return null;
    }
  }
}

/// User Status
enum UserStatus {
  active('Active'),
  inactive('Inactive'),
  suspended('Suspended'),
  banned('Banned');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromValue(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.inactive,
    );
  }
}

/// Error Codes
enum SbErrorCode {
  success(0, 'Success'),
  tokenRefreshFailed(111, 'Token refresh failed'),
  httpManagerNotInitialized(222, 'HTTP Manager not initialized'),
  noUserToken(333, 'No user token'),
  configLoadFailed(401, 'Config load failed'),
  sbTokenFailed(402, 'Sportbook token failed'),
  authFailed(403, 'Authentication failed'),
  userNotFound(404, 'User not found'),
  refreshTokenFailed(444, 'Refresh token failed'),
  connectionRetryExceeded(555, 'Connection retry exceeded'),
  requestTimeout(666, 'Request timeout');

  const SbErrorCode(this.code, this.message);
  final int code;
  final String message;

  static SbErrorCode fromCode(int code) {
    return SbErrorCode.values.firstWhere(
      (error) => error.code == code,
      orElse: () => SbErrorCode.authFailed,
    );
  }
}
