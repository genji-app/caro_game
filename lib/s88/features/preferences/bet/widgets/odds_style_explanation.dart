import 'package:flutter/material.dart';

import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

import 'odds_style_explanation_content.dart';

class OddsStyleExplanationButton extends StatefulWidget {
  const OddsStyleExplanationButton({required this.odds, super.key});

  final OddsStyle odds;

  @override
  State<OddsStyleExplanationButton> createState() =>
      OddsStyleExplanationButtonState();
}

class OddsStyleExplanationButtonState extends State<OddsStyleExplanationButton>
    with SmartTooltipPositioning {
  // ✅ Each button has its own controller
  late final CompositedTooltipController _tooltipController;

  // ✅ Tooltip configuration constants
  static const double _tooltipMaxWidth = 299.0;
  static const double _tooltipMaxHeight = 440.0;
  static const double _tooltipArrowOffset = 0.0;
  static const double _tooltipBottomThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _tooltipController = CompositedTooltipController();
  }

  @override
  void dispose() {
    _tooltipController.remove();
    super.dispose();
  }

  void _showTooltip(BuildContext context) {
    // 1. Build tooltip content
    final tooltipContent = _buildTooltipContent();

    // 2. Calculate positioning based on available space (from mixin)
    final positioning = calculateTooltipPosition(
      context,
      tooltipHeight: _tooltipMaxHeight,
      bottomThreshold: _tooltipBottomThreshold,
      customOffsetAbove: const Offset(0, 4),
      customOffsetBelow: const Offset(0, -4),
    ).copyWith(arrowPosition: ArrowPosition.none);

    // 3. Show tooltip
    _tooltipController.show(
      context: context,
      targetAnchor: positioning.targetAnchor,
      followerAnchor: positioning.followerAnchor,
      offset: positioning.offset,
      rootOverlay: false, // ✅ Use parent overlay for accurate positioning
      autoCloseOnScroll: true,
      dismissOnTapOutside: true,
      builder: (onClose) => TooltipContainer(
        padding: EdgeInsets.zero,
        arrowPosition: positioning.arrowPosition,
        arrowOffset: _tooltipArrowOffset,
        child: tooltipContent,
      ),
    );
  }

  /// Build tooltip content widget
  Widget _buildTooltipContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _tooltipMaxWidth,
        maxHeight: _tooltipMaxHeight,
      ),
      child: SingleChildScrollView(
        child: OddsStyleExplanationContent(odds: widget.odds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tooltipController.wrapTarget(
      child: Builder(
        builder: (iconContext) => SizedBox.square(
          dimension: 44,
          child: InkWell(
            borderRadius: BorderRadius.circular(1000),
            onTap: () => _showTooltip(iconContext),
            child: SizedBox.square(
              dimension: 20,
              child: ImageHelper.load(path: AppIcons.helpCircle),
            ),
          ),
        ),
      ),
    );
  }
}
