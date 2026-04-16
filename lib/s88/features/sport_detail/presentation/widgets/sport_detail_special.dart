import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport/data/model/special_outright_model.dart';
import 'package:co_caro_flame/s88/features/sport/domain/providers/sport_providers.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';

/// Future Provider for Special Outright Data by [sportId].
/// Use selected sport so tab "Đặc biệt" shows data for current sport (e.g. bóng rổ).
final specialOutrightProvider = FutureProvider.autoDispose
    .family<List<SpecialOutrightModel>, int>((ref, sportId) async {
      final useCase = ref.read(fetchSpecialOutrightUseCaseProvider);
      final result = await useCase(sportId);
      return result.fold((failure) => throw failure, (data) => data);
    });

/// Sport Detail Mobile Special Tab Widget
/// Displays special bets (outright events) in a virtualized list.
/// Uses SliverList + SliverChildBuilderDelegate for smooth scroll performance.
class SportDetailMobileSpecial extends ConsumerWidget {
  const SportDetailMobileSpecial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportId = ref.watch(
      selectedSportV2Provider.select((sport) => sport.id),
    );
    return _SpecialOutrightSliver(sportId: sportId);
  }
}

/// Sliver content that returns virtualized list for smooth scroll.
/// Lifts expanded state to parent so collapsed items stay collapsed after scroll.
class _SpecialOutrightSliver extends ConsumerStatefulWidget {
  final int sportId;

  const _SpecialOutrightSliver({required this.sportId});

  @override
  ConsumerState<_SpecialOutrightSliver> createState() =>
      _SpecialOutrightSliverState();
}

class _SpecialOutrightSliverState
    extends ConsumerState<_SpecialOutrightSliver> {
  /// Collapsed outright IDs - preserved across scroll (virtualization)
  final Set<int> _collapsedOutrightIds = {};

  void _toggleExpanded(int outrightId) {
    setState(() {
      if (_collapsedOutrightIds.contains(outrightId)) {
        _collapsedOutrightIds.remove(outrightId);
      } else {
        _collapsedOutrightIds.add(outrightId);
      }
    });
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    SpecialOutrightModel outright,
  ) async {
    final notifier = ref.read(favoriteProvider.notifier);
    final sportId = widget.sportId;
    final wasFavorited = ref.read(favoriteProvider).isLeagueFavorite(
          sportId,
          outright.leagueId,
        );
    final success = wasFavorited
        ? await notifier.removeFavoriteLeague(
            sportId: sportId,
            leagueId: outright.leagueId,
          )
        : await notifier.addFavoriteLeague(
            sportId: sportId,
            leagueId: outright.leagueId,
          );
    if (success && context.mounted) {
      AppToast.showSuccess(
        context,
        message: wasFavorited
            ? 'Đã xoá giải đấu khỏi Yêu thích'
            : 'Đã thêm giải đấu vào Yêu thích',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialOutrightAsync = ref.watch(
      specialOutrightProvider(widget.sportId),
    );
    final favoriteState = ref.watch(favoriteProvider);

    return specialOutrightAsync.when(
      data: (specialOutrights) {
        if (specialOutrights.isEmpty) {
          return const SliverToBoxAdapter(child: SportEmptyPage());
        }

        return SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= specialOutrights.length) {
                  return const SizedBox.shrink();
                }
                final outright = specialOutrights[index];
                final isExpanded = !_collapsedOutrightIds.contains(
                  outright.outrightId,
                );
                final isFavorited = favoriteState.isLeagueFavorite(
                  widget.sportId,
                  outright.leagueId,
                );
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SpecialOutrightCard(
                      key: ValueKey(outright.outrightId),
                      specialOutright: outright,
                      isExpanded: isExpanded,
                      isFavorited: isFavorited,
                      onToggle: () => _toggleExpanded(outright.outrightId),
                      onFavoriteTap: () =>
                          _toggleFavorite(context, outright),
                    ),
                  ),
                );
              },
              childCount: specialOutrights.length,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
            ),
          ),
        );
      },
      loading: () => SliverFillRemaining(
        hasScrollBody: false,
        child: _buildLoadingState(context),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Color(0xFF1B1A19)),
    child: const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(color: Color(0xFFACDC79)),
      ),
    ),
  );

  Widget _buildErrorState(BuildContext context, String error) => Container(
    decoration: const BoxDecoration(color: Color(0xFF1B1A19)),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Lỗi: $error',
          style: AppTextStyles.textStyle(
            fontSize: 14,
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ),
    ),
  );
}

/// Special Outright Card - displays special outright bet data.
/// isExpanded and onToggle come from parent to preserve state across scroll.
class _SpecialOutrightCard extends StatelessWidget {
  final SpecialOutrightModel specialOutright;
  final bool isExpanded;
  final bool isFavorited;
  final VoidCallback onToggle;
  final VoidCallback onFavoriteTap;

  const _SpecialOutrightCard({
    required this.specialOutright,
    required this.isExpanded,
    required this.isFavorited,
    required this.onToggle,
    required this.onFavoriteTap,
    super.key,
  });

  /// Remove date bracket from outright name safely
  /// Example: "[23/05/2026] England Premier League 2025/2026 - Winner"
  /// Returns: "England Premier League 2025/2026 - Winner"
  String _removeDateBracket(String outrightName) {
    if (outrightName.isEmpty) return outrightName;

    // Match pattern: [dd/mm/yyyy] or [dd/mm/yy] at the start
    // Pattern: [dd/mm/yyyy] or [dd/mm/yy] followed by optional whitespace
    final regex = RegExp(r'^\[\d{2}/\d{2}/\d{2,4}\]\s*');
    final result = outrightName.replaceFirst(regex, '');

    // Trim any leading/trailing whitespace
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary, // background/quaternary
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Outright header
          _buildOutrightHeader(context),
          // Selections list (if expanded)
          if (isExpanded) _buildSelectionsList(context),
        ],
      ),
    );
  }

  /// Build outright header with icon, name, and collapse button
  Widget _buildOutrightHeader(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.transparent, width: 0.75),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // League icon
                _buildLeagueIcon(context),
                const SizedBox(width: 8),
                // Outright name (remove date bracket if exists)
                Expanded(
                  child: Text(
                    _removeDateBracket(specialOutright.outrightName),
                    style: AppTextStyles.paragraphSmall(
                      color: AppColorStyles.contentPrimary,
                    ).copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Favorite icon
          GestureDetector(
            onTap: onFavoriteTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ImageHelper.load(
                path: isFavorited
                    ? AppIcons.iconFavoriteSelected
                    : AppIcons.iconUnFavorite,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                color: isFavorited
                    ? null
                    : const Color(0xB3FFFCDB),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Collapse/Expand button
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Transform.rotate(
                angle: isExpanded ? 0 : 3.14159, // 180 degrees in radians
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build league icon (24x24)
  Widget _buildLeagueIcon(BuildContext context) {
    // Use league logo if available, otherwise use default icon
    if (specialOutright.leagueLogo.isNotEmpty) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white, // C1 blue background
          borderRadius: BorderRadius.circular(48),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(48),
          child: ImageHelper.getNetworkImage(
            imageUrl: specialOutright.leagueLogo,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorWidget: ImageHelper.load(
              path: AppIcons.iconSoccer,
              width: 24,
              height: 24,
            ),
          ),
        ),
      );
    }

    // Default icon with colored background
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF00004B),
        borderRadius: BorderRadius.circular(1000),
      ),
      child: ImageHelper.load(path: AppIcons.iconSoccer, width: 24, height: 24),
    );
  }

  /// Build selections list with icons, names, and odds
  Widget _buildSelectionsList(BuildContext context) {
    final selections = specialOutright.selections;

    if (selections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: selections.map((selection) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RepaintBoundary(
              child: _buildSelectionRow(context, selection),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build selection row with icon, name, and odds
  Widget _buildSelectionRow(
    BuildContext context,
    SpecialOutrightSelection selection,
  ) {
    return GestureDetector(
      onTap: () => _handleSelectionTap(context, selection),
      child: Row(
        children: [
          // Selection icon (24x24) - load() uses cache for network URLs
          SizedBox(
            width: 24,
            height: 24,
            child: selection.logoUrl.isNotEmpty
                ? ImageHelper.load(
                    path: selection.logoUrl,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    errorWidget: ImageHelper.load(
                      path: AppIcons.iconSoccer,
                      width: 24,
                      height: 24,
                    ),
                  )
                : ImageHelper.load(
                    path: AppIcons.iconSoccer,
                    width: 24,
                    height: 24,
                  ),
          ),
          const SizedBox(width: 8),
          // Selection name
          Expanded(
            child: Text(
              selection.selectionName,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentPrimary,
              ).copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          // Odds
          Container(
            width: 185,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A19), // background/tertiary
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              selection.odds > 0 ? selection.odds.toStringAsFixed(2) : '-',
              style: AppTextStyles.paragraphSmall(
                color: const Color(0xFFACDC79), // accent/green
              ).copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle selection tap - show bet details popup
  void _handleSelectionTap(
    BuildContext context,
    SpecialOutrightSelection selection,
  ) {
    // Create BettingPopupData from special outright data
    final bettingData = _createBettingPopupDataFromSpecialOutright(
      specialOutright,
      selection,
    );

    if (bettingData != null) {
      BetDetailsBottomSheet.show(context, data: bettingData);
    }
  }

  /// Create BettingPopupData from SpecialOutrightModel and Selection
  BettingPopupData? _createBettingPopupDataFromSpecialOutright(
    SpecialOutrightModel outright,
    SpecialOutrightSelection selection,
  ) {
    try {
      // Create LeagueData - use leagueName from API "8" when available
      final leagueData = LeagueData(
        leagueId: outright.leagueId,
        leagueName: outright.leagueName.isNotEmpty
            ? outright.leagueName
            : _extractLeagueName(outright.outrightName),
        leagueLogo: outright.leagueLogo,
      );

      // startTime from API "5" (timestamp ms), or parse endDate "4" if needed
      int startTime = outright.startTime;
      if (startTime == 0 && outright.endDate.isNotEmpty) {
        try {
          startTime = DateTime.parse(outright.endDate).millisecondsSinceEpoch;
        } catch (_) {}
      }

      // Create LeagueEventData - for outright bets, use selection name as homeName
      // Store full outright name (after removing date bracket) in eventName to match header display
      final eventData = LeagueEventData(
        eventId: outright.outrightId,
        eventName: _removeDateBracket(
          outright.outrightName,
        ), // Full name like "England Premier League 2025/2026 - Winner"
        homeName: selection.selectionName, // Selection name (e.g., "Arsenal")
        awayName: '', // Empty for outright bets
        startTime: startTime,
        isParlay: true, // Outright bets typically support parlay
      );

      // Create LeagueMarketData - use marketId for outright winner (typically 0 or a special ID)
      // For now, use marketId 0 as placeholder - you may need to adjust based on your API
      final marketData = LeagueMarketData(
        marketId: 0, // Outright winner market - adjust if needed
        marketName: _extractMarketName(outright.outrightName),
        isParlay: true,
        odds: [],
      );

      // Create LeagueOddsData with selection data
      // For special outright bets, store selectionCode in points for cls extraction
      final oddsData = LeagueOddsData(
        points: selection
            .selectionCode, // Store selectionCode (e.g., "155") for cls
        selectionHomeId: selection.selectionId,
        offerId: selection.offerId,
        oddsHome: OddsValue(
          decimal: selection.odds,
          malay: _convertDecimalToMalay(selection.odds),
          indo: _convertDecimalToIndo(selection.odds),
          hongKong: _convertDecimalToHongKong(selection.odds),
        ),
        oddsAway: const OddsValue(),
        oddsDraw: const OddsValue(),
      );

      // Create BettingPopupData
      return BettingPopupData(
        oddsData: oddsData,
        marketData: marketData,
        eventData: eventData,
        oddsType: OddsType.home, // Use home for selection in outright bets
        leagueData: leagueData,
        oddsStyle: OddsStyle.decimal,
      );
    } catch (e) {
      debugPrint('Error creating BettingPopupData: $e');
      return null;
    }
  }

  /// Extract league name from outright name
  /// Example: "England Premier League 2025/2026 - Winner" -> "England Premier League"
  String _extractLeagueName(String outrightName) {
    // Remove date bracket if exists
    final cleanName = _removeDateBracket(outrightName);

    // Try to extract league name before " - " or year pattern
    final parts = cleanName.split(' - ');
    if (parts.isNotEmpty) {
      // Remove year pattern (e.g., "2025/2026")
      final leaguePart = parts[0].replaceAll(RegExp(r'\d{4}/\d{4}'), '').trim();
      return leaguePart.isNotEmpty ? leaguePart : cleanName;
    }
    return cleanName;
  }

  /// Extract market name from outright name
  /// Example: "England Premier League 2025/2026 - Winner" -> "Winner" or "2025/2026 Winner"
  String _extractMarketName(String outrightName) {
    final cleanName = _removeDateBracket(outrightName);
    final parts = cleanName.split(' - ');
    if (parts.length > 1) {
      return parts.last;
    }
    return cleanName;
  }

  /// Convert decimal odds to Malay format
  double _convertDecimalToMalay(double decimal) {
    if (decimal <= 1.0) return -100;
    if (decimal >= 2.0) {
      return (decimal - 1) * -1;
    }
    return decimal - 1;
  }

  /// Convert decimal odds to Indo format
  double _convertDecimalToIndo(double decimal) {
    if (decimal <= 1.0) return -100;
    return (decimal - 1) * -1;
  }

  /// Convert decimal odds to Hong Kong format
  double _convertDecimalToHongKong(double decimal) {
    if (decimal <= 1.0) return -100;
    return decimal - 1;
  }
}
