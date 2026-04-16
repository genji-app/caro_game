import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/parlay_tooltip.dart';

// Re-export shared sport components for easy access
// Note: SportDetailFilterType not exported here to avoid conflicts with existing definitions
export 'package:co_caro_flame/s88/shared/widgets/sport/sport_widgets.dart'
    show
        LeagueCard,
        MatchRow,
        SportShimmerLoading,
        LiveIndicator,
        ScoreDisplay,
        VisibleLeagueData,
        LeagueListPagination;

/// Parlay icon button with tooltip displayed on tap
class ParlayIconButton extends StatefulWidget {
  const ParlayIconButton({super.key});

  @override
  State<ParlayIconButton> createState() => _ParlayIconButtonState();
}

class _ParlayIconButtonState extends State<ParlayIconButton> {
  final GlobalKey _iconKey = GlobalKey();

  void _showTooltip() {
    ParlayTooltip.show(
      context: context,
      targetKey: _iconKey,
      message: 'Trận này chưa thêm vào cược xiên',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTooltip,
      child: SizedBox(
        key: _iconKey,
        width: 20,
        height: 20,
        child: RepaintBoundary(
          child: ImageHelper.load(
            path: AppIcons.iconParlay,
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ),
    );
  }
}
