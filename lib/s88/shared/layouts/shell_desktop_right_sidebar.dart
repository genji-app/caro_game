import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/shared/widgets/authenticated_widget.dart';

class ShellDesktopRightSidebar extends ConsumerWidget {
  const ShellDesktopRightSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentType = ref.watch(mainContentProvider);
    final hideHot = contentType == MainContentType.sport;

    return SizedBox(
      width: 402,
      child: Column(
        children: [
          if (!hideHot)
            const Padding(
              padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
              child: const SportHotSection(isRightSidebar: true),
            ),
          if (!hideHot) const SizedBox(height: 12),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
              child: AuthenticatedWidget(child: SportLiveChat()),
            ),
          ),
        ],
      ),
    );
  }
}
