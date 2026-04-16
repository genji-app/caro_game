import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/layouts/layouts.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Mobile widget for displaying a market drawer (expandable section)
///
/// Layout Strategy: BUILD BY COLUMNS, NOT ROWS
/// Each market is a separate column, displaying its odds vertically.
/// This prevents gaps when markets have different numbers of odds.
///
/// Mobile layouts (max 3 columns):
/// - main3: 3 columns [HDP, O/U, 1X2] (FT or HT separated)
/// - correctScore3: 3 columns [Home, Draw, Away]
/// - together: 2 columns vertical list
/// - only2: 2 columns
/// - only3: 3 columns
class MarketDrawerMobileWidget extends StatelessWidget {
  final MarketDrawerData drawer;
  final OddsStyle oddsStyle;
  final VoidCallback onToggle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const MarketDrawerMobileWidget({
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
      // Mobile main layout always uses 3 columns (FT or HT separated)
      case MarketPoolType.main6:
      case MarketPoolType.main:
        return Main3MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // Correct Score - always 3 columns on mobile
      case MarketPoolType.correctScore6:
      case MarketPoolType.correctScore:
        return CorrectScoreMobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // 2x2 → 2 columns on mobile
      case MarketPoolType.only2x2:
        return Only2MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // 3x2 → 3 columns on mobile
      case MarketPoolType.only3x2:
        return Only3MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // 2 columns
      case MarketPoolType.only2:
        return Only2MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // 3 columns
      case MarketPoolType.only3:
        return Only3MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // 4 columns → 2 columns on mobile
      case MarketPoolType.only4:
        return Only4MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // Together layouts
      case MarketPoolType.together4:
        return TogetherMobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      case MarketPoolType.together:
        return TogetherMobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );

      // Market2 O/U layout
      case MarketPoolType.market2:
        return Market2MobileLayout(
          markets: drawer.markets,
          oddsStyle: oddsStyle,
          eventData: eventData,
          leagueData: leagueData,
        );
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFCDB),
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xB3FFFCDB),
            size: 20,
          ),
        ],
      ),
    ),
  );
}
