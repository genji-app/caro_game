import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/back_to_top_overlay.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_flat_item_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_header_widget_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row_v2.dart';

/// Virtualized sliver for rendering leagues and events (V2 Version)
///
/// Uses LeagueModelV2 and EventModelV2 directly without legacy conversion.
///
/// Uses Flat List Pattern for true virtualization:
/// - Only visible items are built (+ cache extent)
/// - Supports 100+ events with smooth 60fps scrolling
/// - Handles real-time WebSocket updates safely
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverToBoxAdapter(child: Header()),
///     LeagueEventsSliverV2(leagues: leagues, isDesktop: true),
///     SliverToBoxAdapter(child: Footer()),
///   ],
/// )
/// ```
class LeagueEventsSliverV2 extends ConsumerStatefulWidget {
  final List<LeagueModelV2> leagues;
  final bool isDesktop;

  /// When true, leagues with no events still show their header (name only).
  final bool includeEmptyLeagues;

  /// When true (default), a back-to-top overlay is shown when scroll > 2.5x
  /// viewport. Set to false if the screen adds its own BackToTopOverlay sliver.
  final bool showBackToTop;

  /// League favorite star on section header (e.g. false when screen has its own).
  final bool showLeagueFavorite;

  const LeagueEventsSliverV2({
    super.key,
    required this.leagues,
    this.isDesktop = false,
    this.includeEmptyLeagues = false,
    this.showBackToTop = true,
    this.showLeagueFavorite = true,
  });

  @override
  ConsumerState<LeagueEventsSliverV2> createState() =>
      _LeagueEventsSliverV2State();
}

class _LeagueEventsSliverV2State extends ConsumerState<LeagueEventsSliverV2> {
  /// Track collapsed leagues by ID
  final Set<int> _collapsedLeagueIds = {};

  void _toggleLeague(int leagueId) {
    setState(() {
      if (_collapsedLeagueIds.contains(leagueId)) {
        _collapsedLeagueIds.remove(leagueId);
      } else {
        _collapsedLeagueIds.add(leagueId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build flat list snapshot at start of build
    // This prevents RangeError when data changes mid-build
    final flatItems = buildFlatItemsV2(
      widget.leagues,
      collapsedLeagueIds: _collapsedLeagueIds,
      includeEmptyLeagues: widget.includeEmptyLeagues,
    );

    if (flatItems.isEmpty) {
      return const SliverToBoxAdapter(
        child: SportEmptyPage(),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= flatItems.length) {
                return const SizedBox.shrink();
              }
              final item = flatItems[index];
              return RepaintBoundary(child: _buildItem(item));
            },
            childCount: flatItems.length,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            findChildIndexCallback: (Key key) {
              if (key is ValueKey<String>) {
                final itemKey = key.value;
                final index = flatItems.indexWhere(
                  (item) => item.key == itemKey,
                );
                return index >= 0 ? index : null;
              }
              return null;
            },
          ),
        ),
        if (widget.showBackToTop)
          const SliverToBoxAdapter(child: BackToTopOverlay()),
      ],
    );
  }

  Widget _buildItem(FlatItemV2 item) {
    // debugPrint(
    //   'league item v2: ${item.league.leagueId} - ${item.league.leagueName}',
    // );
    switch (item.type) {
      case FlatItemTypeV2.leagueHeader:
        final isExpanded = !_collapsedLeagueIds.contains(item.league.leagueId);
        final topSpacing = item.leagueIndex > 0 ? 8.0 : 0.0;
        return Padding(
          padding: EdgeInsets.only(top: topSpacing),
          child: SizedBox(
            height: item.getHeight(isDesktop: widget.isDesktop),
            child: LeagueHeaderWidgetV2(
              key: ValueKey(item.key),
              league: item.league,
              isDesktop: widget.isDesktop,
              isExpanded: isExpanded,
              onToggleExpand: () => _toggleLeague(item.league.leagueId),
              showFavorite: widget.showLeagueFavorite,
            ),
          ),
        );

      case FlatItemTypeV2.eventRow:
        // IMPORTANT: MatchRowV2 uses Expanded internally, so it needs bounded height
        // Without SizedBox, SliverList gives unbounded constraints causing overflow
        final matchRow = SizedBox(
          height: item.getHeight(isDesktop: widget.isDesktop),
          child: MatchRowV2(
            key: ValueKey(item.key),
            event: item.event!,
            league: item.league,
            isDesktop: widget.isDesktop,
          ),
        );

        if (item.isLastEventInLeague) {
          final radius = Radius.circular(widget.isDesktop ? 12 : 10);
          return ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: radius,
              bottomRight: radius,
            ),
            child: matchRow,
          );
        }

        return matchRow;
    }
  }
}

