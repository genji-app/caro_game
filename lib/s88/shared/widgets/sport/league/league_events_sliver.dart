import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_flat_item.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_header_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row.dart';

/// Virtualized sliver for rendering leagues and events
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
///     LeagueEventsSliver(leagues: leagues, isDesktop: true),
///     SliverToBoxAdapter(child: Footer()),
///   ],
/// )
/// ```
class LeagueEventsSliver extends ConsumerStatefulWidget {
  final List<LeagueData> leagues;
  final bool isDesktop;

  const LeagueEventsSliver({
    super.key,
    required this.leagues,
    this.isDesktop = false,
  });

  @override
  ConsumerState<LeagueEventsSliver> createState() => _LeagueEventsSliverState();
}

class _LeagueEventsSliverState extends ConsumerState<LeagueEventsSliver> {
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
    final flatItems = buildFlatItems(
      widget.leagues,
      collapsedLeagueIds: _collapsedLeagueIds,
    );

    if (flatItems.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'Không có trận đấu nào',
              style: AppTextStyles.textStyle(
                fontSize: widget.isDesktop ? 16 : 14,
                color: const Color(0xFFAAA49B),
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Safety bounds check for real-time updates
          if (index >= flatItems.length) {
            return const SizedBox.shrink();
          }

          final item = flatItems[index];

          return RepaintBoundary(child: _buildItem(item));
        },
        childCount: flatItems.length,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,

        // Help Flutter find items after list changes (insert/remove/reorder)
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<String>) {
            final itemKey = key.value;
            final index = flatItems.indexWhere((item) => item.key == itemKey);
            return index >= 0 ? index : null;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildItem(FlatItem item) {
    switch (item.type) {
      case FlatItemType.leagueHeader:
        final isExpanded = !_collapsedLeagueIds.contains(item.league.leagueId);
        final topSpacing = item.leagueIndex > 0 ? 16.0 : 0.0;
        return Padding(
          padding: EdgeInsets.only(top: topSpacing),
          child: SizedBox(
            height: item.getHeight(isDesktop: widget.isDesktop),
            child: LeagueHeaderWidget(
              key: ValueKey(item.key),
              league: item.league,
              isDesktop: widget.isDesktop,
              isExpanded: isExpanded,
              onToggleExpand: () => _toggleLeague(item.league.leagueId),
            ),
          ),
        );

      case FlatItemType.eventRow:
        // IMPORTANT: MatchRow uses Expanded internally, so it needs bounded height
        // Without SizedBox, SliverList gives unbounded constraints causing overflow
        final matchRow = SizedBox(
          height: item.getHeight(isDesktop: widget.isDesktop),
          child: MatchRow(
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
