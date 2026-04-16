import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/play_history/play_history.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';

class BettingHistoryScreen extends StatefulWidget {
  const BettingHistoryScreen({super.key});

  @override
  State<BettingHistoryScreen> createState() => _BettingHistoryScreenState();
}

class _BettingHistoryScreenState extends State<BettingHistoryScreen> {
  late final ValueNotifier<BettingHistoryFilter> _filterNotifier;

  @override
  void initState() {
    super.initState();
    _filterNotifier = ValueNotifier(BettingHistoryFilter.sports);
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ProfileNavigationScaffold.withCenterTitle(
    //   bodyPadding: EdgeInsets.zero,
    //   title: const Text(I18n.txtBetHistory),
    //   body: const BettingHistoryView(),
    // );

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtBetHistory),
      bodyPadding: EdgeInsets.zero,
      body: Scaffold(
        appBar: BettingHistoryFilterMenu(
          initialValue: _filterNotifier.value,
          onChanged: (selection) => _filterNotifier.value = selection,
        ),
        body: ValueListenableBuilder(
          valueListenable: _filterNotifier,
          builder: (context, value, child) => switch (value) {
            BettingHistoryFilter.sports => const BettingHistoryView(),
            BettingHistoryFilter.casino => const PlayHistoryView(),
          },
        ),
      ),
    );
  }
}
