import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/breakpoints.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/wallet/wallet.dart';
import 'package:co_caro_flame/s88/shared/widgets/inset_shadow/inset_shadow.dart'
    as inset;

/// Helper class to present the MyBet module in different modes
class MyBetPresenter {
  static const _radius = Radius.circular(24);
  static const _backgroundColor = Color(0xFF111010);

  static final _shadows = [
    inset.BoxShadow(
      color: Colors.white.withValues(alpha: 0.12),
      offset: const Offset(0, -0.65),
      blurRadius: 0.5,
      spreadRadius: 0.5,
      blurStyle: BlurStyle.inner,
      inset: true,
    ),
  ];

  static final decorationForBottomSheet = inset.BoxDecoration(
    color: _backgroundColor,
    boxShadow: _shadows,
    borderRadius: const BorderRadius.vertical(top: _radius),
  );

  static final decorationForOverlay = BoxDecoration(
    color: _backgroundColor,
    boxShadow: _shadows,
    borderRadius: const BorderRadiusDirectional.only(topStart: _radius),
  );

  /// Show as a Bottom Sheet
  static Future<void> showAsBottomSheet(
    BuildContext context, {
    PreferredSizeWidget? appBar,
    VoidCallback? onClosePressed,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints.tightFor(width: Breakpoints.tablet),
      // constraints: const BoxConstraints.tightForFinite(),
      builder: (context) => Container(
        decoration: decorationForBottomSheet,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: MyBetEntry(
          bodyDecoration: decorationForBottomSheet,
          appBar: AppBar(
            leading: const SizedBox.shrink(),
            backgroundColor: Colors.black,
            scrolledUnderElevation: 0,
            elevation: 0,
            centerTitle: true,
            title: const WalletBalanceView(),
          ),
          onClosePressed: onClosePressed,
        ),
      ),
    );
  }

  /// Use inside an Overlay (Side Panel)
  static Widget buildOverlay(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return MyBetOverlay(
          visibleProvider: myBetOverlayVisibleProvider,
          decoration: decorationForOverlay,
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadiusDirectional.only(topStart: _radius),
            child: MyBetEntry(
              bodyDecoration: decorationForOverlay,
              onClosePressed: () =>
                  ref.read(myBetOverlayVisibleProvider.notifier).close(),
            ),
          ),
        );
      },
    );
  }
}

/// The main entry point for the isolated Betting App (Router)
class MyBetEntry extends ConsumerWidget {
  const MyBetEntry({
    super.key,
    this.appBar,
    this.onClosePressed,
    this.bodyDecoration,
  });

  final PreferredSizeWidget? appBar;
  final VoidCallback? onClosePressed;
  final BoxDecoration? bodyDecoration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MyBetScreen(
      appBar: appBar,
      onClosePressed: onClosePressed,
      bodyDecoration: bodyDecoration,
    );
  }
}
