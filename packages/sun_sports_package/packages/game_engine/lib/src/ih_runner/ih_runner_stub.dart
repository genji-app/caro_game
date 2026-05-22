import 'package:flutter/widgets.dart';
import 'package:game_engine/game_engine.dart';

import 'inapp/inapp_runner_ctrl.dart';

/// Stub implementation for non-IO and non-JS platforms.
class IHInAppRunnerView extends StatelessWidget {
  /// Stub constructor.
  const IHInAppRunnerView({
    required this.gameUrl,
    required this.controller,
    required this.logger,
    super.key,
    this.enableHostMessage = true,
  });

  /// The game URL.
  final String gameUrl;

  /// The controller.
  final IHInAppRunnerCtrl controller;

  /// The engine logger.
  final GameEngineLogger logger;

  /// Injection flag.
  final bool enableHostMessage;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Platform not supported for IHRunner'));
  }
}
