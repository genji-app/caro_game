import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_card_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';

// ===== STATE =====

class PopularLeagueState {
  final List<LeagueModelV2> leagues;
  final bool isLoading;
  final String? error;

  const PopularLeagueState({
    this.leagues = const [],
    this.isLoading = false,
    this.error,
  });

  PopularLeagueState copyWith({
    List<LeagueModelV2>? leagues,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PopularLeagueState(
      leagues: leagues ?? this.leagues,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ===== NOTIFIER =====

class PopularLeagueNotifier extends StateNotifier<PopularLeagueState> {
  final SbHttpManager _httpManager;

  PopularLeagueNotifier(this._httpManager) : super(const PopularLeagueState());

  Future<void> fetchPopularLeagues() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final leagues = await _httpManager.getPopularLeagues();
      state = state.copyWith(leagues: leagues, isLoading: false);
    } catch (e) {
      debugPrint('[PopularLeague] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ===== PROVIDER =====

final popularLeagueProvider =
    StateNotifierProvider<PopularLeagueNotifier, PopularLeagueState>((ref) {
      final httpManager = ref.read(sbHttpManagerProvider);
      return PopularLeagueNotifier(httpManager);
    });

// ===== SELECTORS =====

final _popularLeaguesSelector = popularLeagueProvider.select((s) => s.leagues);
final _popularLoadingSelector = popularLeagueProvider.select(
  (s) => s.isLoading,
);

// ===== WIDGET =====

class SportDesktopPopularLeagueSection extends ConsumerStatefulWidget {
  const SportDesktopPopularLeagueSection({super.key});

  @override
  ConsumerState<SportDesktopPopularLeagueSection> createState() =>
      _SportDesktopPopularLeagueSectionState();
}

class _SportDesktopPopularLeagueSectionState
    extends ConsumerState<SportDesktopPopularLeagueSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(popularLeagueProvider.notifier).fetchPopularLeagues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A19),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -0.65),
            blurRadius: 0.5,
            spreadRadius: 0.05,
            blurStyle: BlurStyle.inner,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Consumer(
            builder: (context, ref, _) {
              final isLoading = ref.watch(_popularLoadingSelector);
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SportShimmerLoading(isDesktop: true),
                  ),
                );
              }

              final leagues = ref.watch(_popularLeaguesSelector);
              final nonEmpty = leagues
                  .where((l) => l.events.isNotEmpty)
                  .toList();

              if (nonEmpty.isEmpty) return const SportEmptyPage();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: nonEmpty
                    .map<Widget>(
                      (league) => LeagueCardV2(league: league, isDesktop: true),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        'Phổ biến',
        style: AppTextStyles.textStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFEF5),
        ),
      ),
    );
  }
}
