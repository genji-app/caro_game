import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

class TeamDisplay extends StatelessWidget {
  final String teamName;
  final String? teamLogo;
  final bool isHome;

  const TeamDisplay({
    super.key,
    required this.teamName,
    this.teamLogo,
    this.isHome = true,
  });

  @override
  Widget build(BuildContext context) {
    // Note: Team logo display is currently disabled
    // If re-enabled, consider fetching sportId from context if needed
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Team logo
        // teamLogo?.isNotEmpty ?? false
        //     ? Container(
        //         width: 28,
        //         height: 28,
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(1000),
        //           child: ImageHelper.getNetworkImage(
        //             imageUrl: teamLogo!,
        //             fit: BoxFit.contain,
        //           ),
        //         ),
        //       )
        //     : const SizedBox.shrink(),
        // const SizedBox(width: 8),
        // Team name
        Expanded(
          child: Text(
            teamName,
            style: AppTextStyles.textStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFDE6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
