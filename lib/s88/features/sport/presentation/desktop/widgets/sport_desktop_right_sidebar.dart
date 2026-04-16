import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/shared/widgets/authenticated_widget.dart';

class SportDesktopRightSidebar extends StatelessWidget {
  const SportDesktopRightSidebar({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 340, // Fixed width according to Figma
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Hot section - self-contained with Riverpod
          const SportHotSection(),
          const SizedBox(height: 12),
          // Live chat section
          Expanded(child: AuthenticatedWidget(child: SportLiveChat())),
        ],
      ),
    ),
  );
}
