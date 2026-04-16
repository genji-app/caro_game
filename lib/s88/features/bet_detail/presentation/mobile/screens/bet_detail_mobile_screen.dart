// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gap/gap.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
// import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
// import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
// import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
// import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';
// import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data.dart';
// import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_mobile_provider.dart';
// import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_provider.dart';
// import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/market_drawer_mobile_widget.dart';
// import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart';
// import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
// import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
// import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
// import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

// /// Mobile Bet Detail screen with real data.
// ///
// /// Displays all markets for a selected event, organized into drawers.
// /// Maximum 3 columns per market on mobile.
// /// Supports WebSocket real-time odds updates.
// class BetDetailMobileScreen extends HookConsumerWidget {
//   const BetDetailMobileScreen({super.key});

//   // Chiều cao của live chat - phải khớp với SportLiveChat
//   static const double _collapsedHeight = 100.0;
//   static const double _expandedHeight = 200.0;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(betDetailMobileProvider);
//     final selectedEvent = ref.watch(selectedEventProvider);
//     final selectedLeague = ref.watch(selectedLeagueProvider);
//     final isExpanded = ref.watch(liveChatExpandedProvider);
//     final liveChatHeight = isExpanded ? _expandedHeight : _collapsedHeight;

//     // Initialize provider when event/league data is available
//     useEffect(() {
//       if (selectedEvent != null && selectedLeague != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ref
//               .read(betDetailMobileProvider.notifier)
//               .init(eventData: selectedEvent, leagueData: selectedLeague);
//         });
//       }
//       return () {
//         // Cleanup when leaving screen
//         ref.read(betDetailMobileProvider.notifier).clear();
//       };
//     }, [selectedEvent, selectedLeague]);

//     // Determine event data (use state.eventData if available, otherwise selectedEvent)
//     final eventData = state.eventData ?? selectedEvent;
//     final leagueData = state.leagueData ?? selectedLeague;
//     final isLive = eventData?.isLive ?? false;

//     // Show loading or empty state
//     if (eventData == null) {
//       return Scaffold(
//         backgroundColor: const Color(0xFF111111),
//         body: ScrollConfiguration(
//           behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//           child: CustomScrollView(
//             slivers: [
//               // Header - scrolls away
//               SliverToBoxAdapter(
//                 child: _buildHeader(context, ref, null),
//               ),
//               const SliverToBoxAdapter(
//                 child: Gap(12),
//               ),
//               // Live Chat - sticky
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _StickyLiveChatDelegate(
//                   minHeight: liveChatHeight,
//                   maxHeight: liveChatHeight,
//                 ),
//               ),
//               // Loading indicator
//               const SliverFillRemaining(
//                 child: Center(
//                   child: CircularProgressIndicator(color: Color(0xFFFFD700)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFF111111),
//       body: ScrollConfiguration(
//         behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//         child: CustomScrollView(
//           slivers: [
//             // Header - scrolls away khi user scroll lên
//             SliverToBoxAdapter(
//               child: _buildHeader(context, ref, eventData.homeName),
//             ),
//             const SliverToBoxAdapter(
//               child: Gap(12),
//             ),
//             // Live Chat - sticky khi scroll đến top
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _StickyLiveChatDelegate(
//                 minHeight: liveChatHeight,
//                 maxHeight: liveChatHeight,
//               ),
//             ),
//             // Phần content - dùng SliverList để lazy loading
//             SliverList.list(
//               children: [
//                 const Gap(12),
//                 // Match header - only show when live
//                 if (isLive)
//                   MatchHeaderMobileWidget(
//                     eventData: eventData,
//                     leagueData: leagueData,
//                   ),
//                 if (isLive) const SizedBox(height: 12),
//                 // Bet tabs with market drawers
//                 if (state.eventData != null)
//                   _BetTabsWithMarkets(
//                     currentFilter: state.currentFilter,
//                     hasMarketsForFilter: state.hasMarketsForFilter,
//                     drawers: state.filteredDrawers,
//                     oddsStyle: ref.watch(oddsStyleProvider),
//                     onFilterChanged: (filter) {
//                       ref
//                           .read(betDetailMobileProvider.notifier)
//                           .changeFilter(filter);
//                     },
//                     onDrawerToggle: (index) {
//                       ref
//                           .read(betDetailMobileProvider.notifier)
//                           .toggleDrawer(index);
//                     },
//                     eventData: eventData,
//                     leagueData: leagueData,
//                   ),
//                 const Gap(80), // Space for bottom navigation
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(
//     BuildContext context,
//     WidgetRef ref,
//     String? title,
//   ) =>
//       Container(
//         color: const Color(0xFF111111),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0)
//             .copyWith(top: 12, bottom: 12),
//         child: SafeArea(
//           bottom: false,
//           child: Row(
//             children: [
//               // Back button
//               GestureDetector(
//                 onTap: () {
//                   ref.read(betDetailMobileProvider.notifier).clear();
//                   // Navigate back to the previous page (sport or sport detail)
//                   ref.read(mainContentProvider.notifier).goBackFromBetDetail();
//                 },
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1B1A19),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.all(5),
//                   child: const Padding(
//                     padding: EdgeInsets.only(left: 5),
//                     child: Icon(
//                       Icons.arrow_back_ios,
//                       size: 13,
//                       color: AppColorStyles.contentPrimary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // Title container
//               Container(
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1B1A19),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Center(
//                   child: Text(
//                     title ?? 'Chi tiết trận đấu',
//                     style: AppTextStyles.textStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF9C9B95),
//                       height: 20 / 14, // line height 20px / font size 14px
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.justify,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
// }

// /// Delegate cho sticky live chat header
// class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;

//   _StickyLiveChatDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//   });

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) =>
//       Container(
//         color: const Color(0xFF111111),
//         height: maxHeight,
//         child: const RepaintBoundary(
//           child: SportLiveChat(
//             isMobile: true,
//           ),
//         ),
//       );

//   @override
//   bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) =>
//       minHeight != oldDelegate.minHeight || maxHeight != oldDelegate.maxHeight;
// }

// /// Bet tabs with market drawers - combined component
// class _BetTabsWithMarkets extends StatelessWidget {
//   final MarketFilter currentFilter;
//   final bool Function(MarketFilter) hasMarketsForFilter;
//   final List<MarketDrawerData> drawers;
//   final OddsStyle oddsStyle;
//   final void Function(MarketFilter) onFilterChanged;
//   final void Function(int) onDrawerToggle;
//   final LeagueEventData? eventData;
//   final LeagueData? leagueData;

//   const _BetTabsWithMarkets({
//     required this.currentFilter,
//     required this.hasMarketsForFilter,
//     required this.drawers,
//     required this.oddsStyle,
//     required this.onFilterChanged,
//     required this.onDrawerToggle,
//     this.eventData,
//     this.leagueData,
//   });

//   /// Bet tab data
//   static const List<_BetTabData> _betTabs = [
//     _BetTabData(label: 'Chính', filter: MarketFilter.match),
//     _BetTabData(label: 'Toàn trận', filter: MarketFilter.all),
//     _BetTabData(label: 'Phạt góc', filter: MarketFilter.corner),
//     _BetTabData(label: 'Tỷ số', filter: MarketFilter.score),
//     _BetTabData(label: 'Thẻ phạt', filter: MarketFilter.booking),
//   ];

//   @override
//   Widget build(BuildContext context) => InnerShadowCard(
//         child: Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF1B1A19),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Tabs section - horizontal scrollable
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: _betTabs.map((tab) {
//                       final isSelected = currentFilter == tab.filter;
//                       final hasMarkets = hasMarketsForFilter(tab.filter);

//                   return Padding(
//                     padding: const EdgeInsets.only(right: 4),
//                     child: GestureDetector(
//                       onTap: hasMarkets
//                           ? () => onFilterChanged(tab.filter)
//                           : null,
//                       child: Stack(
//                         children: [
//                           if (isSelected)
//                             Positioned.fill(
//                               child: ImageHelper.load(path: AppIcons.tabActive,
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 tab.label,
//                                 style: AppTextStyles.textStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                   color: isSelected
//                                       ? const Color(0xFFF9DBAF)
//                                       : hasMarkets
//                                       ? const Color(0xFF9C9B95)
//                                       : const Color(0xFF5C5B55),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           // Market drawers section
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: _MarketDrawersList(
//               drawers: drawers,
//               oddsStyle: oddsStyle,
//               onDrawerToggle: onDrawerToggle,
//               eventData: eventData,
//               leagueData: leagueData,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// /// Bet tab data
// class _BetTabData {
//   final String label;
//   final MarketFilter filter;

//   const _BetTabData({required this.label, required this.filter});
// }

// /// Market drawers list
// class _MarketDrawersList extends StatelessWidget {
//   final List<MarketDrawerData> drawers;
//   final OddsStyle oddsStyle;
//   final void Function(int) onDrawerToggle;
//   final LeagueEventData? eventData;
//   final LeagueData? leagueData;

//   const _MarketDrawersList({
//     required this.drawers,
//     required this.oddsStyle,
//     required this.onDrawerToggle,
//     this.eventData,
//     this.leagueData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (drawers.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(24),
//         alignment: Alignment.center,
//         child: Text(
//           'Không có thị trường nào',
//           style: AppTextStyles.textStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//             color: const Color(0x80FFFCDB),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: drawers.asMap().entries.map((entry) {
//         final index = entry.key;
//         final drawer = entry.value;

//         return MarketDrawerMobileWidget(
//           drawer: drawer,
//           oddsStyle: oddsStyle,
//           onToggle: () => onDrawerToggle(index),
//           eventData: eventData,
//           leagueData: leagueData,
//         );
//       }).toList(),
//     );
//   }
// }
