import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/layouts/layouts.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Widget for displaying a market drawer (expandable section)
///
/// Layout Strategy: BUILD BY COLUMNS, NOT ROWS
/// Each market is a separate column, displaying its odds vertically.
/// This prevents gaps when markets have different numbers of odds.
///
/// MarketPoolType layouts (based on FLUTTER_MARKET_LAYOUT_GUIDE.md):
/// - main6: 6 columns [HDP FT, O/U FT, 1X2 FT, HDP HT, O/U HT, 1X2 HT]
/// - main: 3 columns [HDP, O/U, 1X2] - portrait or single period
/// - correctScore6: 6 columns [Home FT, Draw FT, Away FT, Home HT, Draw HT, Away HT]
/// - correctScore: 3 columns [Home, Draw, Away] - portrait
/// - together4: 4 columns vertical list (Corner O/U by team)
/// - together: 2 columns vertical list (Total Score)
/// - only2x2: 4 columns 2×2 grid (Odd/Even, Draw No Bet)
/// - only3x2: 6 columns 3×2 grid (Double Chance)
/// - only2: 2 columns (To Qualify, Penalty Winner)
/// - only3: 3 columns (Double Chance portrait)
/// - only4: 4 columns (Which Team To Score)
/// - market2: 2 columns vertical O/U (Home O/U, Away O/U)
class MarketDrawerWidget extends StatelessWidget {
  final MarketDrawerData drawer;
  final OddsStyle oddsStyle;
  final VoidCallback onToggle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const MarketDrawerWidget({
    super.key,
    required this.drawer,
    required this.oddsStyle,
    required this.onToggle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: const Color(0x0AFFF6E6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drawer header
        _DrawerHeader(
          title: drawer.name,
          isExpanded: drawer.isExpanded,
          onToggle: onToggle,
        ),
        // Drawer content
        if (drawer.isExpanded) ...[
          // const Divider(height: 1, color: Color(0x1AFFFFFF)),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          _buildContent(),
        ],
      ],
    ),
  );

  /// Build content based on pool type
  Widget _buildContent() {
    if (drawer.markets.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (drawer.poolType) {
      case MarketPoolType.main6:
        return Main6Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.main:
        return _buildMain3Layout();

      case MarketPoolType.correctScore6:
        return CorrectScoreLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is6Columns: true,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.correctScore:
        return CorrectScoreLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is6Columns: false,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only2x2:
        return Only2x2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only3x2:
        return Only3x2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only2:
        return Only2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only3:
        return Only3Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.only4:
        return Only4Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together4:
        return TogetherLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is4Columns: true,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together:
        return TogetherLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          is4Columns: false,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.market2:
        return Market2Layout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );
    }
  }

  /// Build 3-column main layout (simplified version of Main6)
  Widget _buildMain3Layout() {
    // For now, use Main6Layout which handles both 3 and 6 column cases
    return Main6Layout(
      markets: drawer.markets,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }
}

/// Drawer header with title and expand/collapse button
class _DrawerHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DrawerHeader({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onToggle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFCDB),
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xB3FFFCDB),
            size: 24,
          ),
        ],
      ),
    ),
  );
}
