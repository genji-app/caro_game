import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/match_filter_tab_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_list_event_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/tab_layout/s88_tab.dart';

class MatchFilterTabs extends ConsumerStatefulWidget {
  const MatchFilterTabs({super.key});

  @override
  ConsumerState<MatchFilterTabs> createState() => _MatchFilterTabsState();
}

class _MatchFilterTabsState extends ConsumerState<MatchFilterTabs> {
  static final List<S88TabItem> _tabItems = [
    S88TabItem(text: 'Sảnh', iconPath: AppIcons.iconHomeSport),
    S88TabItem(text: 'Sắp diễn ra', iconPath: AppIcons.iconComingSport),
    S88TabItem(text: 'Yêu thích', iconPath: AppIcons.iconFavoriteSport),
  ];

  int? _pendingIndex;

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(matchFilterSelectedProvider);
    final fromProvider = MatchFilterType.values.indexOf(selected);
    final effectiveIndex = (_pendingIndex ?? fromProvider).clamp(
      0,
      _tabItems.length - 1,
    );

    return S88Tab(
      tabs: _tabItems,
      selectedIndex: effectiveIndex,
      onTabChanged: (index) {
        setState(() => _pendingIndex = index);
        ref.read(matchFilterProvider.notifier).selectTab(index);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _pendingIndex = null);
        });
      },
      width: 450,
      height: 44,
      borderRadius: BorderRadius.circular(1000),
    );
  }
}
