import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';

/// One event item from search API response key "1".
/// API keys: "0"=sportId, "1"=eventId, "2"=leagueName, "3"=leagueId, "4"=eventName,
/// "5"=startTimeIso, "6"=startTimeMs, "7"=isLive, "8"=status,
/// "9"=leagueIconUrl, "10"=homeTeamLogoUrl, "11"=awayTeamLogoUrl.
class SearchResultItem {
  const SearchResultItem({
    required this.sportId,
    required this.eventId,
    required this.leagueName,
    required this.leagueId,
    required this.eventName,
    required this.startTimeIso,
    required this.startTimeMs,
    required this.isLive,
    required this.status,
    this.leagueIconUrl = '',
    this.homeTeamLogoUrl = '',
    this.awayTeamLogoUrl = '',
  });

  final int sportId;
  final int eventId;
  final String leagueName;
  final int leagueId;
  final String eventName;
  final String startTimeIso;
  final int startTimeMs;
  final bool isLive;
  final int status;

  /// Icon/logo URL của giải đấu (key "9").
  final String leagueIconUrl;

  /// Logo đội nhà (key "10").
  final String homeTeamLogoUrl;

  /// Logo đội khách (key "11").
  final String awayTeamLogoUrl;

  /// Parse from API map (numeric string keys).
  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      sportId: _intFrom(json['0']),
      eventId: _intFrom(json['1']),
      leagueName: json['2']?.toString().trim() ?? '',
      leagueId: _intFrom(json['3']),
      eventName: json['4']?.toString().trim() ?? '',
      startTimeIso: json['5']?.toString() ?? '',
      startTimeMs: _intFrom(json['6']),
      isLive: json['7'] == true,
      status: _intFrom(json['8']),
      leagueIconUrl: json['9']?.toString().trim() ?? '',
      homeTeamLogoUrl: json['10']?.toString().trim() ?? '',
      awayTeamLogoUrl: json['11']?.toString().trim() ?? '',
    );
  }

  static int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// Parse eventName "Home vs Away" into home and away names
  (String homeName, String awayName) get teamNames {
    final parts = eventName.split(' vs ');
    final homeName = parts.isNotEmpty ? parts[0].trim() : '';
    final awayName = parts.length > 1 ? parts[1].trim() : '';
    return (homeName, awayName);
  }

  /// Convert to EventModelV2 (minimal) for bet detail navigation
  EventModelV2 toEventModelV2() {
    final (homeName, awayName) = teamNames;
    return EventModelV2(
      sportId: sportId > 0 ? sportId : 1,
      leagueId: leagueId,
      eventId: eventId,
      startDate: startTimeIso,
      startTime: startTimeMs,
      type: status,
      homeName: homeName,
      awayName: awayName,
      homeLogo: homeTeamLogoUrl,
      awayLogo: awayTeamLogoUrl,
      isLive: isLive,
      markets: [],
    );
  }

  /// Convert to LeagueModelV2 (minimal) for bet detail navigation
  LeagueModelV2 toLeagueModelV2() {
    return LeagueModelV2(
      sportId: sportId > 0 ? sportId : 1,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueNameEn: leagueName,
      leagueLogo: leagueIconUrl,
      events: [toEventModelV2()],
    );
  }
}
