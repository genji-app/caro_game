import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_mobile_v2_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row_shared_v2.dart' show extractCurrentSet;
import 'package:co_caro_flame/s88/features/bet_detail/presentation/desktop/widgets/match_header_desktop_widget.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/market_drawer_v2_mobile_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// Desktop Bet Detail screen with V2 design.
///
/// Uses the same V2 provider and components as mobile.
/// Layout naturally expands on desktop without intervention.
class BetDetailDesktopScreen extends ConsumerStatefulWidget {
  const BetDetailDesktopScreen({super.key});

  @override
  ConsumerState<BetDetailDesktopScreen> createState() =>
      _BetDetailDesktopScreenState();
}

class _BetDetailDesktopScreenState
    extends ConsumerState<BetDetailDesktopScreen> {
  @override
  void initState() {
    super.initState();
    _initBetDetail();
  }

  void _initBetDetail() {
    final selectedEventV2 = ref.read(selectedEventV2Provider);
    final selectedLeagueV2 = ref.read(selectedLeagueV2Provider);
    final sportId = selectedLeagueV2?.sportId ?? ref.read(selectedSportV2Provider).id;

    if (selectedEventV2 != null && selectedLeagueV2 != null) {
      final selectedEvent = selectedEventV2.toLegacy();
      final selectedLeague = selectedLeagueV2.toLegacy();
      final currentSet = extractCurrentSet(selectedEventV2) ?? 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(betDetailMobileV2Provider.notifier).init(
              eventData: selectedEvent,
              leagueData: selectedLeague,
              sportId: sportId,
              currentSet: currentSet,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 860),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: const SingleChildScrollView(
              child: _BetDetailContentConsumer(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Consumer widget for bet detail content - isolates rebuilds for event/league data
class _BetDetailContentConsumer extends ConsumerWidget {
  const _BetDetailContentConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to only rebuild when eventData/leagueData changes
    final eventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData),
    );
    final leagueData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.leagueData),
    );

    // Fallback to selected providers if state not ready - use read since these
    // are set before navigation and don't change during screen lifecycle
    final displayEventData =
        eventData ?? ref.read(selectedEventV2Provider)?.toLegacy();
    final displayLeagueData =
        leagueData ?? ref.read(selectedLeagueV2Provider)?.toLegacy();

    if (displayEventData == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BetDetailHeader(eventData: displayEventData),
        const SizedBox(height: 12),
        MatchHeaderDesktopWidget(
          key: ValueKey('match-header-${displayEventData.eventId}'),
          eventData: displayEventData,
          leagueData: displayLeagueData,
          sportId: ref.read(selectedLeagueV2Provider)?.sportId ?? ref.read(selectedSportV2Provider).id,
          isDesktop: true,
        ),
        const SizedBox(height: 12),
        if (eventData != null)
          _BetTabsConsumer(
            eventData: displayEventData,
            leagueData: displayLeagueData,
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

/// Header widget with back button - uses Consumer for goBack action
class _BetDetailHeader extends ConsumerWidget {
  final LeagueEventData eventData;

  const _BetDetailHeader({required this.eventData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                ref.read(mainContentProvider.notifier).goBackFromBetDetail();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1A19),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(5),
                child: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 13,
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A19),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Center(
              child: Text(
                '${eventData.homeName} - ${eventData.awayName}',
                style: AppTextStyles.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9C9B95),
                  height: 20 / 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Container widget for bet tabs - uses Consumer to isolate rebuilds
class _BetTabsConsumer extends StatelessWidget {
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  const _BetTabsConsumer({required this.eventData, required this.leagueData});

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A19),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs section - only rebuilds when tabs/filter changes
            const _TabsSection(),
            const SizedBox(height: 4),
            // Market drawers section - only rebuilds when drawers/oddsStyle changes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _DrawersSection(
                eventData: eventData,
                leagueData: leagueData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabs section - isolated Consumer for tab-related state only
class _TabsSection extends ConsumerWidget {
  const _TabsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final availableTabs = ref.watch(
      betDetailMobileV2Provider.select((state) => state.availableTabs),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: availableTabs.map((tab) {
              final isSelected = currentFilter == tab.filter;
              return _TabItem(
                tab: tab,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(betDetailMobileV2Provider.notifier)
                      .changeFilter(tab.filter);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Single tab item - StatelessWidget to avoid unnecessary rebuilds
class _TabItem extends StatelessWidget {
  final BetTabData tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(1000),
          child: Stack(
            children: [
              if (isSelected)
                Positioned.fill(
                  child: ImageHelper.load(
                    path: AppIcons.tabActive,
                    fit: BoxFit.fill,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Center(
                  child: Text(
                    tab.label,
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFF9DBAF)
                          : const Color(0xFF9C9B95),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drawers section - isolated Consumer for drawer-related state only
class _DrawersSection extends ConsumerWidget {
  final LeagueEventData? eventData;
  final LeagueData? leagueData;

  const _DrawersSection({this.eventData, this.leagueData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawers = ref.watch(
      betDetailMobileV2Provider.select((state) => state.filteredDrawers),
    );
    final oddsStyle = ref.watch(oddsStyleProvider);

    if (drawers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          'Không có thị trường nào',
          style: AppTextStyles.textStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0x80FFFCDB),
          ),
        ),
      );
    }

    return Column(
      children: drawers.asMap().entries.map((entry) {
        final index = entry.key;
        final drawer = entry.value;

        return MarketDrawerV2MobileWidget(
          drawer: drawer,
          oddsStyle: oddsStyle,
          onToggle: () {
            ref.read(betDetailMobileV2Provider.notifier).toggleDrawer(index);
          },
          eventData: eventData,
          leagueData: leagueData,
        );
      }).toList(),
    );
  }
}
