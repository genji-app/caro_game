import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';

/// Extension methods to convert bet models to HintData
///
/// These extensions provide a consistent way to create HintData
/// from different bet model types across the application.

/// Convert SingleBetData to HintData
extension SingleBetDataToHintData on SingleBetData {
  /// Convert SingleBetData to HintData for tooltip content generation
  HintData toHintData() {
    return HintData(
      marketId: marketData.marketId,
      market: HintData.getMarketCategory(marketData.marketId),
      period: HintData.getPeriod(marketData.marketId),
      handicap: double.tryParse(oddsData.points) ?? 0.0,
      ratio: displayOdds,
      style: oddsStyle,
      team: HintData.mapOddsTypeToTeam(oddsType),
      homeName: eventData.homeName,
      awayName: eventData.awayName,
      teamName: displayName,
      homeScore: eventData.homeScore,
      awayScore: eventData.awayScore,
      homeCorner: eventData.cornersHome,
      awayCorner: eventData.cornersAway,
      homeBookings: eventData.redCardsHome * 2 + eventData.yellowCardsHome,
      awayBookings: eventData.redCardsAway * 2 + eventData.yellowCardsAway,
      stake: stake > 0 ? stake.toDouble() : 100000.0,
      isLive: eventData.isLive,
    );
  }
}

/// Convert BetSlip to HintData
extension BetSlipToHintData on BetSlip {
  /// Convert BetSlip to HintData for tooltip content generation
  HintData toHintData() {
    // Extract handicap/points from cls or oddsName if available
    final handicap = _extractHandicap(cls, oddsName);

    return HintData(
      marketId: marketId,
      market: HintData.getMarketCategory(marketId),
      period: HintData.getPeriod(marketId),
      handicap: handicap,
      ratio: double.tryParse(displayOdds) ?? 0.0,
      style: _parseOddsStyle(oddsStyle),
      team: _parseTeamFromOddsName(oddsName),
      homeName: homeName ?? '',
      awayName: awayName ?? '',
      teamName: homeName ?? '',
      homeScore: _parseScore(score).home,
      awayScore: _parseScore(score).away,
      homeCorner: 0,
      awayCorner: 0,
      homeBookings: 0,
      awayBookings: 0,
      stake: stake > 0 ? stake.toDouble() : 100000.0,
      isLive: isMatchLive,
    );
  }
}

/// Convert ChildBet to HintData
extension ChildBetToHintData on ChildBet {
  /// Convert ChildBet to HintData for tooltip content generation
  HintData toHintData() {
    // Extract handicap/points from cls or oddsName if available
    final handicap = _extractHandicap(cls, oddsName);

    return HintData(
      marketId: marketId,
      market: HintData.getMarketCategory(marketId),
      period: HintData.getPeriod(marketId),
      handicap: handicap,
      ratio: double.tryParse(displayOdds) ?? 0.0,
      style: _parseOddsStyle(oddsStyle),
      team: _parseTeamFromOddsName(oddsName),
      homeName: homeName ?? '',
      awayName: awayName ?? '',
      teamName: homeName ?? '',
      homeScore: _parseScore(score).home,
      awayScore: _parseScore(score).away,
      homeCorner: 0,
      awayCorner: 0,
      homeBookings: 0,
      awayBookings: 0,
      stake: stake > 0 ? stake.toDouble() : 100000.0,
      isLive: isMatchLive,
    );
  }
}

// ============================================================
// PRIVATE HELPERS
// ============================================================

/// Parse odds style string to OddsStyle enum
OddsStyle _parseOddsStyle(String style) {
  return switch (style.toLowerCase()) {
    'ma' || 'malay' || 'my' => OddsStyle.malay,
    'indo' || 'id' => OddsStyle.indo,
    'hk' || 'hongkong' => OddsStyle.hongKong,
    'de' || 'decimal' => OddsStyle.decimal,
    _ => OddsStyle.decimal,
  };
}

/// Extract handicap value from cls or oddsName
///
/// Examples:
/// - cls: "Home -0.5" -> -0.5
/// - oddsName: "Over 2.5" -> 2.5
double _extractHandicap(String cls, String oddsName) {
  // Try to extract from cls first (e.g., "Home -0.5", "Away +1.0")
  final clsMatch = RegExp(r'[-+]?\d+\.?\d*').firstMatch(cls);
  if (clsMatch != null) {
    return double.tryParse(clsMatch.group(0) ?? '0') ?? 0.0;
  }

  // Try to extract from oddsName (e.g., "Over 2.5", "Under 1.5")
  final oddsMatch = RegExp(r'\d+\.?\d*').firstMatch(oddsName);
  if (oddsMatch != null) {
    return double.tryParse(oddsMatch.group(0) ?? '0') ?? 0.0;
  }

  return 0.0;
}

/// Parse team type from oddsName
///
/// Examples:
/// - "Home" -> HintTeamType.home
/// - "Away" -> HintTeamType.away
/// - "Over" -> HintTeamType.home (for O/U markets)
/// - "Under" -> HintTeamType.away (for O/U markets)
HintTeamType _parseTeamFromOddsName(String oddsName) {
  final name = oddsName.toLowerCase();

  if (name.contains('home') || name.contains('over') || name.contains('odd')) {
    return HintTeamType.home;
  }

  if (name.contains('away') ||
      name.contains('under') ||
      name.contains('even')) {
    return HintTeamType.away;
  }

  if (name.contains('draw')) {
    return HintTeamType.draw;
  }

  return HintTeamType.none;
}

/// Parse score string to extract home and away scores
///
/// Examples:
/// - "[2-1]" -> (home: 2, away: 1)
/// - "3-0" -> (home: 3, away: 0)
/// - "" -> (home: 0, away: 0)
({int home, int away}) _parseScore(String score) {
  if (score.isEmpty) return (home: 0, away: 0);

  // Remove brackets if present
  final cleaned = score.replaceAll('[', '').replaceAll(']', '');

  // Split by dash
  final parts = cleaned.split('-');
  if (parts.length != 2) return (home: 0, away: 0);

  final home = int.tryParse(parts[0].trim()) ?? 0;
  final away = int.tryParse(parts[1].trim()) ?? 0;

  return (home: home, away: away);
}
