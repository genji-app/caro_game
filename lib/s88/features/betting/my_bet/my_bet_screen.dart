import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/screens/parlay_view.dart';

class MyBetScreen extends StatelessWidget {
  const MyBetScreen({
    super.key,
    this.appBar,
    this.bodyDecoration,
    this.onClosePressed,
  });

  final PreferredSizeWidget? appBar;
  final Decoration? bodyDecoration;
  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar,
      body: MyBetView(
        onClosePressed: onClosePressed,
        decoration: bodyDecoration,
      ),
    );
  }
}

class MyBetView extends ConsumerStatefulWidget {
  const MyBetView({super.key, this.onClosePressed, this.decoration});

  final VoidCallback? onClosePressed;
  final Decoration? decoration;

  @override
  ConsumerState<MyBetView> createState() => _MyBetViewState();
}

class _MyBetViewState extends ConsumerState<MyBetView> {
  MyBetMenuEntry _selectedMenu = MyBetMenuEntry.bettingSlip;

  Widget _buildContent() {
    if (_selectedMenu == MyBetMenuEntry.bettingSlip) {
      return const ParlayView();
    }
    return const BettingHistoryView();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final betSlipCount = ref.watch(
                myBetNotifierProvider.select((state) => state.betSlipCount),
              );
              final myBetsCount = ref.watch(
                myBetNotifierProvider.select((state) => state.myBetsCount),
              );
              return MyBetHeader(
                bettingSlipCount: betSlipCount,
                myBetCount: myBetsCount,
                onMenuChanged: (value) => setState(() => _selectedMenu = value),
                onClosePressed: widget.onClosePressed,
              );
            },
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
