import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/animations/animations.dart';
import 'package:co_caro_flame/s88/shared/widgets/status_information/status_information.dart';

/// A loading indicator for the beginning or end of a [CustomScrollView].
class SliverLoadingIndicator extends StatelessWidget {
  const SliverLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: ImmediateOpacityAnimation(
      duration: Durations.medium1,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: AlignmentDirectional.center,
        // child: const CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
        // child: const CircularProgressIndicator(),
        child: const Sun88LoadingIndicator(),
      ),
    ),
  );
}
