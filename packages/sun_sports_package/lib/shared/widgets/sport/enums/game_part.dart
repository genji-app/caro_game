/// Game part/period for live matches
///
/// Values match sport_socket library format.
enum GamePart {
  /// Not started
  notStarted(0),

  /// First half
  firstHalf(1),

  /// Second half
  secondHalf(2),

  /// Half time
  halfTime(3),

  /// Extra time
  extraTime(4),

  /// Penalty shootout
  penalties(5),

  /// Full time / Finished
  fullTime(6),

  /// Break (between periods)
  breakTime(7);

  final int value;
  const GamePart(this.value);

  /// Short display text (e.g., "1H", "2H", "HT")
  String get shortText {
    switch (this) {
      case GamePart.notStarted:
        return '';
      case GamePart.firstHalf:
        return '1H';
      case GamePart.secondHalf:
        return '2H';
      case GamePart.halfTime:
        return 'HT';
      case GamePart.extraTime:
        return 'ET';
      case GamePart.penalties:
        return 'PEN';
      case GamePart.fullTime:
        return 'FT';
      case GamePart.breakTime:
        return 'BRK';
    }
  }

  /// Full display text
  String get fullText {
    switch (this) {
      case GamePart.notStarted:
        return 'Not Started';
      case GamePart.firstHalf:
        return 'First Half';
      case GamePart.secondHalf:
        return 'Second Half';
      case GamePart.halfTime:
        return 'Half Time';
      case GamePart.extraTime:
        return 'Extra Time';
      case GamePart.penalties:
        return 'Penalties';
      case GamePart.fullTime:
        return 'Full Time';
      case GamePart.breakTime:
        return 'Break';
    }
  }

  /// Is match currently playing (not in break/finished)
  bool get isPlaying =>
      this == GamePart.firstHalf ||
      this == GamePart.secondHalf ||
      this == GamePart.extraTime ||
      this == GamePart.penalties;

  /// Is match in a break period
  bool get isBreak => this == GamePart.halfTime || this == GamePart.breakTime;

  /// Is match finished
  bool get isFinished => this == GamePart.fullTime;

  /// Parse từ int value
  static GamePart fromValue(int? value) {
    return GamePart.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GamePart.notStarted,
    );
  }
}
