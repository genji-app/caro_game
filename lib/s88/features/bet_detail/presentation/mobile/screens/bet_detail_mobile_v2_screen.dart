import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data_v2.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_mobile_v2_provider.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/market_drawer_v2_mobile_widget.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/match_header_mobile_widget.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/mobile_statistics_table_widget.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/shared/widgets/livestream/pip_manager.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row_shared_v2.dart' show extractCurrentSet;

/// Mobile Bet Detail V2 screen with new design.
///
/// New Design Features:
/// - Each market type is a separate expandable card
/// - Header: "{Period} - {Market Type}" + expand/collapse arrow
/// - Body: Different layouts based on market type
///
/// Example:
/// - "Toàn trận - Kèo chấp" (Full match - Handicap)
/// - "Toàn trận - Tài xỉu" (Full match - Over/Under)
/// - "Toàn trận - 1x2"
class BetDetailMobileV2Screen extends ConsumerStatefulWidget {
  const BetDetailMobileV2Screen({super.key});

  @override
  ConsumerState<BetDetailMobileV2Screen> createState() =>
      _BetDetailMobileV2ScreenState();
}

class _BetDetailMobileV2ScreenState
    extends ConsumerState<BetDetailMobileV2Screen> {
  // Chiều cao của live chat - phải khớp với SportLiveChat
  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

  // ScrollController và GlobalKey cho fake sticky technique
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _statisticsTableKey = GlobalKey();
  final GlobalKey _betTabsKey = GlobalKey();
  final GlobalKey _livestreamKey = GlobalKey();
  final GlobalKey<State<MatchHeaderMobileWidget>> _matchHeaderKey =
      GlobalKey<State<MatchHeaderMobileWidget>>();
  bool _isStatisticsSticky = false;
  bool _isBetTabsSticky = false;
  MatchTab? _currentTab; // Track tab hiện tại
  double _lastScrollPosition = 0.0; // Track scroll position để detect direction

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    // Track navigation: đang ở video page
    // Initialize PipManager với fullscreen callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PipManager().setOnVideoPage(true);
      _initializeData();

      // Initialize PipManager nếu chưa được initialize
      // (có thể đã được gọi trong LivestreamWidgetImpl._loadVideo(), nhưng đảm bảo chắc chắn)
      if (!PipManager().hasContent) {
        PipManager().initialize(
          context,
          onFullscreenRequested: () {
            _handleFullscreenRequest();
          },
        );
      } else {
        PipManager().setFullscreenCallback(() {
          _handleFullscreenRequest();
        });
      }
    });
  }

  /// Initialize data from providers - chỉ gọi một lần khi initState
  void _initializeData() {
    final selectedEventV2 = ref.read(selectedEventV2Provider);
    final selectedLeagueV2 = ref.read(selectedLeagueV2Provider);
    final sportId =
        selectedLeagueV2?.sportId ?? ref.read(selectedSportV2Provider).id;

    if (selectedEventV2 != null && selectedLeagueV2 != null) {
      final eventData = selectedEventV2.toLegacy();
      final leagueData = selectedLeagueV2.toLegacy();
      final currentSet = extractCurrentSet(selectedEventV2) ?? 1;
      ref
          .read(betDetailMobileV2Provider.notifier)
          .init(eventData: eventData, leagueData: leagueData, sportId: sportId, currentSet: currentSet);
    }
  }

  @override
  void dispose() {
    // Track navigation: rời khỏi video page
    PipManager().setOnVideoPage(false);

    // Fix Bug 2: Dispose PipManager khi back từ bet_detail screen
    // Chỉ dispose khi:
    // 1. Đang ở tab "Trực tuyến" (_currentTab == MatchTab.live)
    // 2. Không ở PiP mode (isPiPMode == false)
    // Nếu đang show PiP window (isPiPMode == true), giữ logic trước đó (không dispose)
    final pipManager = PipManager();
    if (_currentTab == MatchTab.live && !pipManager.isPiPMode) {
      // Đang ở tab "Trực tuyến" và không ở PiP mode: Dispose để giải phóng tài nguyên
      pipManager.dispose().catchError((Object e) {
        debugPrint('Error disposing PipManager when back from bet_detail: $e');
      });
    } else {
      // Đang ở PiP mode hoặc không ở tab "Trực tuyến": Không dispose để giữ PiP window
      // Logic này đảm bảo PiP có thể hiển thị trên mọi màn hình
    }

    _scrollController.dispose();
    super.dispose();
  }

  /// Livestream đang hoạt động (tab Trực tuyến + có video hoặc webview)
  // bool get _isVideoWorking =>
  //     _currentTab == MatchTab.live && PipManager().hasContent;

  /// Handle scroll để detect khi Statistics Table và Bet Tabs cần sticky
  /// Pattern giống fake_sticky.dart: check offsetY của widget B
  /// Và tự động chuyển sang PiP mode khi scroll quá 60% của VideoPlayer
  /// Chỉ active sticky khi video working (tab Trực tuyến + video đã load)
  void _handleScroll() {
    _handleScrollAutoPiP();

    // if (!_isVideoWorking) {
    //   if (_isStatisticsSticky || _isBetTabsSticky) {
    //     setState(() {
    //       _isStatisticsSticky = false;
    //       _isBetTabsSticky = false;
    //     });
    //   }
    //   return;
    // }

    final context = _statisticsTableKey.currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final offsetY = box.localToGlobal(Offset.zero).dy;
    final topPadding = MediaQuery.of(context).padding.top;
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final isExpanded = ref.read(liveChatExpandedProvider);
    final liveChatHeight = isExpanded ? _expandedHeight : _collapsedHeight;
    final liveChatTop = topPadding + (isAuthenticated ? liveChatHeight : 0);

    // Khi Statistics Table scroll lên đến vị trí Live Chat, cần sticky
    final shouldStatisticsSticky = offsetY < liveChatTop - 20;

    if (shouldStatisticsSticky != _isStatisticsSticky) {
      setState(() {
        _isStatisticsSticky = shouldStatisticsSticky;
      });
    }

    // Check Bet Tabs sticky
    final tabsContext = _betTabsKey.currentContext;
    if (tabsContext != null) {
      final tabsBox = tabsContext.findRenderObject() as RenderBox?;
      if (tabsBox != null) {
        final tabsOffsetY = tabsBox.localToGlobal(Offset.zero).dy;
        // Bet Tabs sticky khi scroll lên đến vị trí Statistics Table (nếu Statistics Table đã sticky)
        // Hoặc scroll lên đến vị trí Live Chat (nếu Statistics Table chưa sticky)
        final statisticsTableHeight = 140.0; // Approximate height
        final tabsStickyTop = _isStatisticsSticky
            ? liveChatTop + statisticsTableHeight
            : liveChatTop;
        final shouldTabsSticky = tabsOffsetY <= tabsStickyTop;

        if (shouldTabsSticky != _isBetTabsSticky) {
          setState(() {
            _isBetTabsSticky = shouldTabsSticky;
          });
        }
      }
    }
  }

  /// Handle fullscreen request từ PiP window: PiP về container rồi switch tab Trực tuyến
  void _handleFullscreenRequest() {
    PipManager().returnToContainer();

    // Đảm bảo thứ tự thực thi:
    // 1. Reset sticky state (nếu đang ở tab 'bảng điểm')
    // 2. Switch tab sang 'Trực tuyến' (sau khi reset sticky state)

    // 1. Kiểm tra nếu đang ở tab 'bảng điểm' thì reset sticky state
    if (_currentTab == MatchTab.scoreboard) {
      if (_isStatisticsSticky || _isBetTabsSticky) {
        setState(() {
          _isStatisticsSticky = false;
          _isBetTabsSticky = false;
        });

        // Đợi frame hiện tại hoàn tất trước khi switch tab
        // Đảm bảo sticky state đã được reset
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _switchToLiveTab();
        });
        return; // Return để không gọi _switchToLiveTab() ngay lập tức
      }
    }

    // Nếu không cần reset sticky state, switch tab ngay
    _switchToLiveTab();
  }

  /// Switch tab sang 'Trực tuyến'
  void _switchToLiveTab() {
    final matchHeaderState = _matchHeaderKey.currentState;
    if (matchHeaderState != null) {
      final controller = matchHeaderState as MatchHeaderTabController;
      controller.setTab(MatchTab.live);
    }

    // Scroll về top position sau khi switch tab
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleScrollAutoPiP() {
    // Check auto PiP: Khi đang ở tab "Trực tuyến" và scroll quá 60% → show PiP overlay (kể cả khi đang embedded)
    if (_currentTab != MatchTab.live) return;

    // Early return: Kiểm tra context và render box
    final livestreamContext = _livestreamKey.currentContext;
    if (livestreamContext == null) return;

    final livestreamBox = livestreamContext.findRenderObject() as RenderBox?;
    if (livestreamBox == null) return;

    // Tính toán scroll percentage
    final livestreamOffsetY = livestreamBox.localToGlobal(Offset.zero).dy;
    final livestreamHeight = livestreamBox.size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final isExpanded = ref.read(liveChatExpandedProvider);
    final liveChatHeight = isExpanded ? _expandedHeight : _collapsedHeight;
    final screenTop = topPadding + (isAuthenticated ? liveChatHeight : 0);

    // Tính scroll position: Khi LivestreamWidget scroll lên trên màn hình
    // Nếu top của LivestreamWidget < screenTop, nghĩa là đã scroll quá widget
    // Tính phần trăm đã scroll: (screenTop - livestreamOffsetY) / livestreamHeight
    double scrollPercentage = 0.0;
    if (livestreamOffsetY < screenTop) {
      final scrolledAmount = screenTop - livestreamOffsetY;
      scrollPercentage = (scrolledAmount / livestreamHeight).clamp(0.0, 1.0);
    }

    // Detect scroll direction: so sánh với scroll position trước đó
    final currentScrollPosition = _scrollController.offset;
    final isScrollingUp = currentScrollPosition > _lastScrollPosition;
    _lastScrollPosition = currentScrollPosition;

    // Early return: Chỉ trigger khi:
    // 1. Scroll LÊN (isScrollingUp = true)
    // 2. Scroll quá 60%
    // 3. Có nội dung (video hoặc webview fallback)
    if (!isScrollingUp || scrollPercentage < 0.6 || !PipManager().hasContent) {
      return;
    }

    // Scroll quá ngưỡng trên tab Trực tuyến → show PiP trên overlay và chuyển tab Bảng điểm
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (!PipManager().isPiPMode) PipManager().showPiP();
      PipManager().liftToOverlay(context);
      final matchHeaderState = _matchHeaderKey.currentState;
      if (matchHeaderState != null) {
        final controller = matchHeaderState as MatchHeaderTabController;
        controller.setTab(MatchTab.scoreboard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColorStyles.backgroundPrimary,
      body: Consumer(
        builder: (context, ref, child) {
          // Chỉ watch những gì cần thiết cho layout chính
          final isAuthenticated = ref.watch(isAuthenticatedProvider);
          final isExpanded = ref.watch(liveChatExpandedProvider);
          final liveChatHeight = isExpanded
              ? _expandedHeight
              : _collapsedHeight;

          return _buildBody(
            context,
            ref,
            topPadding,
            isAuthenticated,
            liveChatHeight,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    double topPadding,
    bool isAuthenticated,
    double liveChatHeight,
  ) {
    // Sử dụng select để chỉ rebuild khi eventData thay đổi
    final eventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData),
    );
    final leagueData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.leagueData),
    );

    // Fallback to selected providers nếu state chưa có data
    // Sử dụng read thay vì watch vì đây chỉ là fallback một lần
    // Data thực sự được quản lý bởi betDetailMobileV2Provider
    final selectedEventV2 = ref.read(selectedEventV2Provider);
    final selectedLeagueV2 = ref.read(selectedLeagueV2Provider);
    final finalEventData = eventData ?? selectedEventV2?.toLegacy();
    final finalLeagueData = leagueData ?? selectedLeagueV2?.toLegacy();

    // Show loading or empty state
    if (finalEventData == null) {
      return _buildLoadingState(
        context,
        topPadding,
        isAuthenticated,
        liveChatHeight,
      );
    }

    return _buildContentState(
      context,
      ref,
      topPadding,
      isAuthenticated,
      liveChatHeight,
      finalEventData,
      finalLeagueData,
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    double topPadding,
    bool isAuthenticated,
    double liveChatHeight,
  ) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: Gap(12)),
          // Live Chat - sticky at top
          if (isAuthenticated)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyLiveChatDelegate(
                minHeight: liveChatHeight,
                maxHeight: liveChatHeight,
                topPadding: topPadding,
              ),
            ),
          // Loading indicator
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentState(
    BuildContext context,
    WidgetRef ref,
    double topPadding,
    bool isAuthenticated,
    double liveChatHeight,
    LeagueEventData eventData,
    LeagueData? leagueData,
  ) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false, overscroll: false),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: Gap(12)),
              // Live Chat - sticky at top
              if (isAuthenticated)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyLiveChatDelegate(
                    minHeight: liveChatHeight,
                    maxHeight: liveChatHeight,
                    topPadding: topPadding,
                  ),
                ),
              // Phần content - dùng SliverList để lazy loading
              SliverList.list(
                children: [
                  // Padding giữa LiveChat và MatchHeaderMobileWidget
                  const Gap(12),
                  // Match header - only show when live
                  MatchHeaderMobileWidget(
                    key: _matchHeaderKey,
                    eventData: eventData,
                    leagueData: leagueData,
                    sportId:
                        ref.read(selectedLeagueV2Provider)?.sportId ??
                        ref.read(selectedSportV2Provider).id,
                    statisticsTableKey: _statisticsTableKey,
                    hideStatisticsTableOpacity: _isStatisticsSticky,
                    livestreamKey: _livestreamKey,
                    onTabChanged: (tab) {
                      setState(() {
                        _currentTab = tab;
                      });
                      // Bảng điểm → Trực tuyến: overlay → embedded (PiP về trong container, remove overlay).
                      if (tab == MatchTab.live) {
                        PipManager().returnToContainer();
                      }
                    },
                  ),
                  // Bet tabs with market drawers - sử dụng Consumer riêng
                  _BetTabsConsumer(
                    betTabsKey: _betTabsKey,
                    hideBetTabsOpacity: _isBetTabsSticky,
                    eventData: eventData,
                    leagueData: leagueData,
                  ),
                  const Gap(80), // Space for bottom navigation
                ],
              ),
            ],
          ),
        ),
        // Statistics Table - Fake Sticky (chỉ khi video working)
        // if (_isVideoWorking)
        _buildStickyStatisticsTable(
          topPadding,
          isAuthenticated,
          liveChatHeight,
          eventData,
        ),
        // Bet Tabs - Fake Sticky (chỉ khi video working)
        // if (_isVideoWorking)
        _buildStickyBetTabs(ref, topPadding, isAuthenticated, liveChatHeight),
      ],
    );
  }

  Widget _buildStickyStatisticsTable(
    double topPadding,
    bool isAuthenticated,
    double liveChatHeight,
    LeagueEventData eventData,
  ) {
    return Positioned(
      top: topPadding + (isAuthenticated ? liveChatHeight : 0),
      left: 0,
      right: 0,
      child: Offstage(
        offstage: !_isStatisticsSticky,
        child: Material(
          color: AppColorStyles.backgroundSecondary,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: MobileStatisticsTableWidget(
                eventData: eventData,
                hideBottomBorderRadius: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBetTabs(
    WidgetRef ref,
    double topPadding,
    bool isAuthenticated,
    double liveChatHeight,
  ) {
    return Positioned(
      top: _isStatisticsSticky
          ? topPadding + (isAuthenticated ? liveChatHeight : 0) + 140.0
          : topPadding + (isAuthenticated ? liveChatHeight : 0),
      left: 0,
      right: 0,
      child: Offstage(
        offstage: !_isBetTabsSticky,
        child: Material(
          color: const Color(0xFF1B1A19),
          child: Consumer(
            builder: (context, ref, child) {
              final availableTabs = ref.watch(
                betDetailMobileV2Provider.select(
                  (state) => state.availableTabs,
                ),
              );
              final currentFilter = ref.watch(
                betDetailMobileV2Provider.select(
                  (state) => state.currentFilter,
                ),
              );

              return _BetTabsSection(
                availableTabs: availableTabs,
                currentFilter: currentFilter,
                onFilterChanged: (filter) {
                  ref
                      .read(betDetailMobileV2Provider.notifier)
                      .changeFilter(filter);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Consumer widget cho Bet Tabs - tách riêng để tối ưu rebuilds
class _BetTabsConsumer extends ConsumerWidget {
  final GlobalKey? betTabsKey;
  final bool hideBetTabsOpacity;
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  const _BetTabsConsumer({
    required this.hideBetTabsOpacity,
    required this.eventData,
    this.betTabsKey,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ watch khi eventData đã có trong state
    final hasEventData = ref.watch(
      betDetailMobileV2Provider.select((state) => state.eventData != null),
    );

    if (!hasEventData) {
      return const SizedBox.shrink();
    }

    return _BetTabsWithMarketsV2Consumer(
      betTabsKey: betTabsKey,
      hideBetTabsOpacity: hideBetTabsOpacity,
      eventData: eventData,
      leagueData: leagueData,
    );
  }
}

/// Consumer widget cho _BetTabsWithMarketsV2 - sử dụng select cho từng field
class _BetTabsWithMarketsV2Consumer extends ConsumerWidget {
  final GlobalKey? betTabsKey;
  final bool hideBetTabsOpacity;
  final LeagueEventData eventData;
  final LeagueData? leagueData;

  const _BetTabsWithMarketsV2Consumer({
    required this.hideBetTabsOpacity,
    required this.eventData,
    this.betTabsKey,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng select để chỉ rebuild khi field cụ thể thay đổi
    final currentFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.currentFilter),
    );
    final availableTabs = ref.watch(
      betDetailMobileV2Provider.select((state) => state.availableTabs),
    );
    final drawers = ref.watch(
      betDetailMobileV2Provider.select((state) => state.filteredDrawers),
    );
    final hasMarketsForFilter = ref.watch(
      betDetailMobileV2Provider.select((state) => state.hasMarketsForFilter),
    );
    final oddsStyle = ref.watch(oddsStyleProvider);

    return _BetTabsWithMarketsV2(
      currentFilter: currentFilter,
      hasMarketsForFilter: hasMarketsForFilter,
      drawers: drawers,
      oddsStyle: oddsStyle,
      availableTabs: availableTabs,
      onFilterChanged: (filter) {
        ref.read(betDetailMobileV2Provider.notifier).changeFilter(filter);
      },
      onDrawerToggle: (index) {
        ref.read(betDetailMobileV2Provider.notifier).toggleDrawer(index);
      },
      eventData: eventData,
      leagueData: leagueData,
      betTabsKey: betTabsKey,
      hideBetTabsOpacity: hideBetTabsOpacity,
    );
  }
}

/// Delegate cho sticky live chat header
class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final double topPadding;

  _StickyLiveChatDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.topPadding,
  });

  @override
  double get minExtent => minHeight + topPadding;

  @override
  double get maxExtent => maxHeight + topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: AppColorStyles.backgroundSecondary,
    padding: EdgeInsets.only(top: topPadding),
    child: SizedBox(
      height: maxHeight,
      child: const RepaintBoundary(child: SportLiveChat(isMobile: true)),
    ),
  );

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) =>
      minHeight != oldDelegate.minHeight ||
      maxHeight != oldDelegate.maxHeight ||
      topPadding != oldDelegate.topPadding;
}

/// Bet tabs with market drawers V2 - combined component
///
/// Dynamic tabs based on available markets in the match.
/// Tab order:
/// 1. "Chính" (Main) - Always first, shows all main markets (Handicap, O/U, 1X2)
/// 2. Period tabs: "Toàn trận", "Hiệp 1", "Hiệp 2", "Hiệp phụ" (if markets exist)
/// 3. Category tabs: "Phạt góc", "Tỷ số", "Thẻ phạt" (if markets exist)
class _BetTabsWithMarketsV2 extends StatelessWidget {
  final MarketFilter currentFilter;
  final bool Function(MarketFilter) hasMarketsForFilter;
  final List<MarketDrawerDataV2> drawers;
  final OddsStyle oddsStyle;
  final void Function(MarketFilter) onFilterChanged;
  final void Function(int) onDrawerToggle;
  final LeagueEventData? eventData;
  final LeagueData? leagueData;
  final List<BetTabData> availableTabs;
  final GlobalKey? betTabsKey; // Key để track vị trí cho fake sticky
  final bool
  hideBetTabsOpacity; // Ẩn bằng opacity khi sticky (fake sticky pattern)

  const _BetTabsWithMarketsV2({
    required this.currentFilter,
    required this.hasMarketsForFilter,
    required this.drawers,
    required this.oddsStyle,
    required this.onFilterChanged,
    required this.onDrawerToggle,
    required this.availableTabs,
    this.eventData,
    this.leagueData,
    this.betTabsKey,
    this.hideBetTabsOpacity = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs section - horizontal scrollable with dynamic tabs
        // Opacity để ẩn khi sticky (fake sticky pattern giống fake_sticky.dart)
        Opacity(
          opacity: hideBetTabsOpacity ? 0 : 1,
          child: _BetTabsSection(
            key: betTabsKey, // Key để track vị trí
            availableTabs: availableTabs,
            currentFilter: currentFilter,
            onFilterChanged: onFilterChanged,
          ),
        ),
        const SizedBox(height: 8),
        // Market drawers section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _MarketDrawersListV2(
            drawers: drawers,
            oddsStyle: oddsStyle,
            onDrawerToggle: onDrawerToggle,
            eventData: eventData,
            leagueData: leagueData,
          ),
        ),
      ],
    ),
  );
}

/// Market drawers list V2
class _MarketDrawersListV2 extends StatelessWidget {
  final List<MarketDrawerDataV2> drawers;
  final OddsStyle oddsStyle;
  final void Function(int) onDrawerToggle;
  final LeagueEventData? eventData;
  final LeagueData? leagueData;

  const _MarketDrawersListV2({
    required this.drawers,
    required this.oddsStyle,
    required this.onDrawerToggle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
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
          onToggle: () => onDrawerToggle(index),
          eventData: eventData,
          leagueData: leagueData,
        );
      }).toList(),
    );
  }
}

/// Bet Tabs Section Widget
///
/// Tách từ _BetTabsWithMarketsV2 để có thể reuse và làm fake sticky
/// Pattern giống fake_sticky.dart: widget có thể được sticky bằng Positioned
class _BetTabsSection extends StatelessWidget {
  final List<BetTabData> availableTabs;
  final MarketFilter currentFilter;
  final void Function(MarketFilter) onFilterChanged;

  const _BetTabsSection({
    super.key,
    required this.availableTabs,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      width: double.infinity,
      height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000), // #000000
            Color(0x00000000), // rgba(0,0,0,0) (transparent)
          ],
          stops: [0.0, 1.0],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF252423), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: availableTabs.map((tab) {
            final isSelected = currentFilter == tab.filter;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => onFilterChanged(tab.filter),
                child: Stack(
                  children: [
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        left: -20,
                        right: -20,
                        top: -10,
                        child: ImageHelper.load(
                          path: AppIcons.sportStatusSelected,
                          fit: BoxFit.fill,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          tab.label,
                          style: AppTextStyles.textStyle(
                            fontSize: 13,
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
            );
          }).toList(),
        ),
      ),
    );
  }
}
