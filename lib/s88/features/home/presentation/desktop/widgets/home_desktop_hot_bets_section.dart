import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/providers/upcoming_events_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart' as shimmer;
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';

const int _sportIdFootball = 1;
const double _cardWidth = 200;
const double _separatorWidth = 12;
const double _scrollStep = _cardWidth + _separatorWidth;

class HomeDesktopHotBetsSection extends ConsumerStatefulWidget {
  const HomeDesktopHotBetsSection({super.key});

  @override
  ConsumerState<HomeDesktopHotBetsSection> createState() =>
      _HomeDesktopHotBetsSectionState();
}

class _HomeDesktopHotBetsSectionState
    extends ConsumerState<HomeDesktopHotBetsSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeft = false;
  bool _showRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final atStart = pos.pixels <= 1;
    final atEnd = pos.pixels >= pos.maxScrollExtent - 1;
    if (mounted) {
      setState(() {
        _showLeft = !atStart;
        _showRight = !atEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLeagues = ref.watch(
      upcomingLeagueEventsProvider(_sportIdFootball),
    );

    return SizedBox(
      height: 100,
      child: asyncLeagues.when(
        data: (leagues) {
          final items = _flattenUpcomingEvents(leagues);
          if (items.isEmpty) {
            return const SportEmptyPage();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onScroll();
          });
          return LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              return Stack(
                children: [
                  SizedBox(
                    width: viewportWidth,
                    child: ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: _separatorWidth),
                      itemBuilder: (context, index) {
                        final (event, league) = items[index];
                        return RepaintBoundary(
                          child: _HotBetCard(
                            event: event,
                            league: league,
                            onTap: () {
                              ref.read(selectedEventV2Provider.notifier).state =
                                  event;
                              ref
                                      .read(selectedLeagueV2Provider.notifier)
                                      .state =
                                  league;
                              ref
                                  .read(mainContentProvider.notifier)
                                  .goToBetDetail();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF141414), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showLeft)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (!_scrollController.hasClients) return;
                            final pos = _scrollController.position;
                            final target = (pos.pixels - _scrollStep).clamp(
                              0.0,
                              pos.maxScrollExtent,
                            );
                            _scrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColorStyles.backgroundQuaternary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.transparent, Color(0xFF141414)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showRight)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (!_scrollController.hasClients) return;
                            final pos = _scrollController.position;
                            final target = (pos.pixels + _scrollStep).clamp(
                              0.0,
                              pos.maxScrollExtent,
                            );
                            _scrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColorStyles.backgroundQuaternary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        loading: () => const _HotBetsSectionShimmer(),
        error: (_, __) => Center(
          child: Text(
            'Không tải được dữ liệu',
            style: AppTextStyles.labelXSmall(color: AppColors.gray400),
          ),
        ),
      ),
    );
  }

  static List<(EventModelV2, LeagueModelV2)> _flattenUpcomingEvents(
    List<LeagueModelV2> leagues,
  ) {
    final result = <(EventModelV2, LeagueModelV2)>[];
    for (final league in leagues) {
      for (final event in league.upcomingEvents) {
        result.add((event, league));
      }
    }
    return result;
  }
}

class _HotBetCard extends StatelessWidget {
  const _HotBetCard({
    required this.event,
    required this.league,
    required this.onTap,
  });

  final EventModelV2 event;
  final LeagueModelV2 league;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLive = event.isLive;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: InnerShadowCard(
          borderRadius: 16,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isLive: isLive),
                const Gap(4),
                Column(
                  children: [
                    _TeamRow(
                      teamName: event.homeName,
                      teamLogo: event.homeLogo,
                    ),
                    _TeamRow(
                      teamName: event.awayName,
                      teamLogo: event.awayLogo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isLive}) {
    if (isLive) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.red500,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Trực tiếp',
              style: AppTextStyles.labelXXSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          const Gap(8),
          Text(
            _formatGameTime(event.gameTime),
            style: AppTextStyles.labelXXSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(4),
          Container(width: 1, height: 10, color: AppColors.gray400),
          const Gap(4),
          Text(
            _gamePartLabel(event.gamePart),
            style: AppTextStyles.labelXXSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ],
      );
    }

    final (dateStr, timeStr) = _formatStartDateAndTime();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            dateStr,
            style: AppTextStyles.labelXXSmall(
              color: const Color(0xFFBEBEBE).withValues(alpha: 0.7),
            ),
          ),
          const Gap(4),
          Container(width: 1, height: 10, color: AppColors.gray400),
          const Gap(4),
          Text(
            timeStr,
            style: AppTextStyles.labelXXSmall(
              color: const Color(0xFFBEBEBE).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _formatStartDateAndTime() {
    DateTime? dt;
    if (event.startDate.isNotEmpty) {
      dt = DateTime.tryParse(event.startDate);
    }
    if (dt == null && event.startTime > 0) {
      dt = DateTime.fromMillisecondsSinceEpoch(event.startTime);
    }
    if (dt == null) return ('--/--/----', '--:--');
    return (
      DateFormat('dd/MM/yyyy').format(dt),
      DateFormat('HH:mm').format(dt),
    );
  }

  static String _formatGameTime(int gameTime) {
    if (gameTime <= 0) return '0"';
    final minutes = gameTime ~/ 60000;
    return '$minutes"';
  }

  static String _gamePartLabel(int gamePart) {
    switch (gamePart) {
      case 1:
        return 'Hiệp 1';
      case 2:
        return 'Hiệp 2';
      default:
        return 'Hiệp $gamePart';
    }
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.teamName, required this.teamLogo});

  final String teamName;
  final String teamLogo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: teamLogo.isEmpty
                ? const SizedBox.shrink()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ImageHelper.load(
                      path: teamLogo,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorWidget: const SizedBox.shrink(),
                    ),
                  ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              teamName.isEmpty ? '--' : teamName,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotBetsSectionShimmer extends StatelessWidget {
  const _HotBetsSectionShimmer();

  static const _shimmerBaseColor = Color(0xFF2A2A2A);
  static const _shimmerHighlightColor = Color(0xFF3D3D3D);

  static Widget _box({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return shimmer.Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: _shimmerHighlightColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      padding: const EdgeInsets.only(right: 50),
      separatorBuilder: (_, __) => const SizedBox(width: _separatorWidth),
      itemBuilder: (_, __) => InnerShadowCard(
        borderRadius: 16,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(width: 48, height: 10, borderRadius: 4),
                  const Gap(4),
                  _box(width: 1, height: 10),
                  const Gap(4),
                  _box(width: 32, height: 10, borderRadius: 4),
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  _box(width: 24, height: 24, borderRadius: 4),
                  const Gap(8),
                  _box(width: 100, height: 12, borderRadius: 4),
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  _box(width: 24, height: 24, borderRadius: 4),
                  const Gap(8),
                  _box(width: 100, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
