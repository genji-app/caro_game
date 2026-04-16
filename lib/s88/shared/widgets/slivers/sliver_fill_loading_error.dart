import 'package:flutter/material.dart';

import 'package:co_caro_flame/s88/shared/widgets/status_information/status_information.dart';

/// A [LoadingError] widget as a sliver that fills the remaining space in the
/// viewport.
class SliverFillLoadingError extends StatelessWidget {
  const SliverFillLoadingError({
    required this.message,
    this.onRetry,
    this.onChangeFilter,
    super.key,
  });

  final Widget message;
  final VoidCallback? onRetry;
  final VoidCallback? onChangeFilter;

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: LoadingError(
      message: message,
      onRetry: onRetry != null ? () => onRetry!() : null,
      onChangeFilter: onChangeFilter,
    ),
  );
}
