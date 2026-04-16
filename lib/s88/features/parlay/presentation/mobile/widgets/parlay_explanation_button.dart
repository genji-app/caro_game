import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_explanation/bet_explanation.dart';

class ParlayExplanationButton extends StatelessWidget {
  /// The bet data to display explanation for
  final HintData data;

  /// Color of the info icon
  final Color? color;

  const ParlayExplanationButton({required this.data, super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32,
      child: BetExplanationTooltip(
        hintData: data,
        config: BetTooltipConfig(
          triggerColor: color,
          triggerSize: 18.0,
          triggerPadding: EdgeInsets.zero,
          offset: const Offset(8, -4),
        ),
        triggerBuilder: (onTap) => IconButton.outlined(
          style: IconButton.styleFrom(
            side: BorderSide.none,
            padding: EdgeInsets.zero,
            iconSize: 18,
          ),
          onPressed: onTap,
          icon: SizedBox.square(
            dimension: 18,
            child: ImageHelper.load(path: AppIcons.iconInfo, color: color),
          ),
        ),
      ),
    );
  }
}
