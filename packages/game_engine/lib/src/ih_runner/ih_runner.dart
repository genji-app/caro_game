import 'dart:async';

import 'package:flutter/material.dart';

import '../logger.dart';
import 'ih_runner_ctrl.dart';
import 'ih_runner_stub.dart'
    if (dart.library.io) 'inapp/inapp_runner_view.dart'
    if (dart.library.js_interop) 'inapp/inapp_runner_view.dart';
import 'inapp/inapp_runner_ctrl.dart';

export 'game_bridge_mixin.dart';
export 'ih_runner_ctrl.dart';

/// {@template ih_runner}
/// Platform-agnostic WebView widget for running In-House games.
///
/// Supports bidirectional communication with the game via [IHRunnerCtrl]:
///
/// - **Flutter → Game**: [IHRunnerCtrl.sendMessage]
/// - **Game → Flutter**: [onHostMessage] callback or [IHRunnerCtrl.onHostMessage] stream.
///
/// ## Basic usage
///
/// ```dart
/// IHRunner(
///   gameUrl: 'https://inhouse-game.example.com',
///   onHostMessage: (event) {
///     if (event.isCloseWebView) Navigator.pop(context);
///   },
/// )
/// ```
///
/// ## Usage with external controller
///
/// ```dart
/// final ctrl = IHRunnerCtrl.inApp();
///
/// IHRunner(gameUrl: url, controller: ctrl)
///
/// // Send a message to the game:
/// await ctrl.sendMessage(GameHostEvent(type: 'ROUND_START'));
/// ```
/// {@endtemplate}
class IHRunner extends StatefulWidget {
  /// Creates an [IHRunner] widget.
  const IHRunner({
    required this.gameUrl,
    this.controller,
    this.logger = silentLogger,
    super.key,
    this.onLoadStart,
    this.onLoadStop,
    this.onError,
    this.onHostMessage,
    this.enableHostMessage = true,
    this.loadStopDebounce,
  });

  /// The entry-point URL of the IHRunner game.
  final String gameUrl;

  /// Optional external controller for programmatic access.
  ///
  /// When `null`, an [IHInAppRunnerCtrl] is created and managed internally.
  final IHRunnerCtrl? controller;

  /// Custom logger implementation.
  final GameEngineLogger logger;

  /// Called when the WebView starts loading the page.
  final VoidCallback? onLoadStart;

  /// Called when the WebView finishes loading the page.
  final VoidCallback? onLoadStop;

  /// Called when a fatal load error occurs.
  final ValueChanged<String>? onError;

  /// Called when a [GameHostEvent] is received from the game bridge.
  final ValueChanged<GameHostEvent>? onHostMessage;

  /// Whether to inject the Host Bridge JS channel. Defaults to `true`.
  final bool enableHostMessage;

  /// Extra delay after `onLoadStop` fires before emitting the event.
  final Duration? loadStopDebounce;

  @override
  State<IHRunner> createState() => _IHRunnerState();
}

class _IHRunnerState extends State<IHRunner> {
  // Nullable tracks ownership: non-null = we created it, null = external.
  IHInAppRunnerCtrl? _ownedController;

  late final IHInAppRunnerCtrl _ctrl;

  final List<StreamSubscription<dynamic>> _subs = [];

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initController();
    _setupForwarding();
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _ownedController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Init Helpers
  // ---------------------------------------------------------------------------

  void _initController() {
    final external = widget.controller;
    if (external != null) {
      if (external is! IHInAppRunnerCtrl) {
        throw ArgumentError(
          'IHRunner requires an IHInAppRunnerCtrl. '
          'Received: ${external.runtimeType}',
        );
      }
      _ctrl = external;
      // _ownedController stays null — external controllers are not disposed here.
    } else {
      _ownedController = IHInAppRunnerCtrl(
        logger: widget.logger,
        loadStopDebounce: widget.loadStopDebounce ?? Duration.zero,
        enableHostMessage: widget.enableHostMessage,
      );
      _ctrl = _ownedController!;
    }
  }

  /// Forwards controller stream events to widget callbacks.
  ///
  /// Subscriptions are stored in [_subs] and cancelled in [dispose] to prevent
  /// memory leaks.
  void _setupForwarding() {
    _subs.addAll([
      _ctrl.onStateChanged.listen((state) {
        if (!mounted) return;
        switch (state) {
          case IHRunnerState.loading:
            widget.onLoadStart?.call();
          case IHRunnerState.loaded:
            widget.onLoadStop?.call();
          case IHRunnerState.error:
            widget.onError?.call('Failed to load game');
          case IHRunnerState.idle:
            break;
        }
      }),
      _ctrl.onHostMessage.listen((event) {
        if (!mounted) return;
        widget.onHostMessage?.call(event);
      }),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // IHInAppRunnerView is imported via conditional import above.
    return IHInAppRunnerView(
      gameUrl: widget.gameUrl,
      controller: _ctrl,
      logger: widget.logger,
      enableHostMessage: widget.enableHostMessage,
    );
  }
}
