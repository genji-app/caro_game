// ─────────────────────────────────────────────────────────────
// Basketball (sportId = 2)
// ─────────────────────────────────────────────────────────────

abstract class BasketballGamePart {
  static const int rtPause = 4;
  static const int secondHalf = 8;
  static const int finished = 16;
  static const int finishRt = 32;
  static const int timeout = 157;
  static const int quarterBreak = 2000;
  static const int firstQuarter = 2001;
  static const int secondQuarter = 2002;
  static const int thirdQuarter = 2003;
  static const int fourthQuarter = 2004;
  static const int overtime = 2005;
  static const int overtimeBreak = 2006;
  static const int halfTimeBreak = 2008;
}

// ─────────────────────────────────────────────────────────────
// Tennis (sportId = 4)
// ─────────────────────────────────────────────────────────────

abstract class TennisGamePart {
  static const int scoreBoard = 0;
  static const int set1 = 1;
  static const int set2 = 2;
  static const int set3 = 3;
  static const int set4 = 4;
  static const int set5 = 5;
  static const int set6 = 6;
  static const int set7 = 7;
  static const int game = 60;
  static const int tieBreak = 61;
  static const int breakTime = 80;
  static const int fullTime = 100;
}

// ─────────────────────────────────────────────────────────────
// Volleyball (sportId = 5)
// ─────────────────────────────────────────────────────────────

abstract class VolleyballGamePart {
  static const int scoreBoard = 0;
  static const int set1 = 1;
  static const int set2 = 2;
  static const int set3 = 3;
  static const int set4 = 4;
  static const int set5 = 5;
  static const int totalPoints = 8;
  static const int goldenSet = 50;
  static const int fullTime = 100;
}

// ─────────────────────────────────────────────────────────────
// Table Tennis (sportId = 6)
// ─────────────────────────────────────────────────────────────

abstract class TableTennisGamePart {
  static const int scoreBoard = 0;
  static const int set1 = 1;
  static const int set2 = 2;
  static const int set3 = 3;
  static const int set4 = 4;
  static const int set5 = 5;
  static const int set6 = 6;
  static const int set7 = 7;
  static const int totalPoints = 9;
  static const int fullTime = 100;
}
