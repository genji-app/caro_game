// 1. Enum quản lý trạng thái trận đấu
// enum MatchPeriod {
//   firstHalf, // Hiệp 1
//   secondHalf, // Hiệp 2
//   halftime, // Nghỉ giữa hiệp
//   finished, // Kết thúc
//   notStarted, // Chưa đá
// }

// // 2. Model cho Đội bóng (Team)
// class Team {
//   final String id;
//   final String name;
//   final String logoUrl;

//   Team({required this.id, required this.name, required this.logoUrl});
// }

// // 3. Model cho thống kê chi tiết (Dùng cho bảng đen Live Stats)
// class MatchStats {
//   final int corners; // Phạt góc
//   final int yellowCards; // Thẻ vàng
//   final int redCards; // Thẻ đỏ
//   final int goals; // Bàn thắng

//   MatchStats({
//     required this.corners,
//     required this.yellowCards,
//     required this.redCards,
//     required this.goals,
//   });
// }

// // 4. Model thông tin trận đấu (Match Info)
// class MatchInfo {
//   final String matchId;
//   final Team homeTeam;
//   final Team awayTeam;
//   final DateTime matchDate; // "22:00 - 12/12/2025"
//   final int homeScore;
//   final int awayScore;

//   // Các field cho trạng thái Live (Nếu có)
//   final bool isLive;
//   final String? liveTimeDisplay; // "24'"
//   final MatchPeriod? period; // "Hiệp 1"
//   final MatchStats? homeStats; // Thống kê đội nhà
//   final MatchStats? awayStats; // Thống kê đội khách

//   MatchInfo({
//     required this.matchId,
//     required this.homeTeam,
//     required this.awayTeam,
//     required this.matchDate,
//     this.homeScore = 0,
//     this.awayScore = 0,
//     this.isLive = false,
//     this.liveTimeDisplay,
//     this.period,
//     this.homeStats,
//     this.awayStats,
//   });
// }

// 5. Model chi tiết kèo cược (Bet Selection)
// class BetSelection {
//   final String marketName; // "1X2"
//   final String selectionName; // "Chelsea FC"
//   final double odds; // 4.35

//   BetSelection({
//     required this.marketName,
//     required this.selectionName,
//     required this.odds,
//   });
// }

// // 5.1. Model cho Combo Bet Match (Match + Selection trong cược xiên)
// class ComboBetMatch {
//   final MatchInfo match;
//   final BetSelection selection;

//   ComboBetMatch({required this.match, required this.selection});
// }
