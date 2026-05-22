import 'dart:async';

import 'package:game_engine/game_engine.dart';

/// Event bus between a game runner widget and [GamePlayerNotifier].
///
/// Owned by the notifier — created on construction, disposed on teardown.
/// The View receives the controller via [GamePlayerNotifier.runnerController]
/// and passes it down to [GameRunnerView], which forwards it to the active
/// runner widget. The runner widget calls [add] to emit events; the notifier
/// handles them via its stream subscription.
class GameRunnerController {
  final _streamController = StreamController<GameRunnerEvent>.broadcast(
    sync: true,
  );

  /// Stream of runner events consumed by [GamePlayerNotifier].
  Stream<GameRunnerEvent> get events => _streamController.stream;

  /// Emits [event] to all current subscribers.
  ///
  /// No-op if [dispose] has already been called.
  void add(GameRunnerEvent event) {
    if (!_streamController.isClosed) _streamController.add(event);
  }

  /// Closes the stream. Must be called when the notifier is disposed.
  void dispose() => _streamController.close();
}

/// Contract for all signals a game runner can emit.
///
/// Each runner (IH, PL, future types) emits a subset of these events.
/// The notifier subscribes to a [GameRunnerController] stream and handles
/// them in a single switch — adding a new runner type requires zero changes
/// to the notifier as long as it only emits events already in this class.
sealed class GameRunnerEvent {
  const GameRunnerEvent();
}

/// WebView began loading the game page.
final class RunnerLoadStarted extends GameRunnerEvent {
  const RunnerLoadStarted();
}

/// WebView finished loading the game page.
final class RunnerLoadStopped extends GameRunnerEvent {
  const RunnerLoadStopped();
}

/// A fatal load error occurred in the WebView.
final class RunnerErrorOccurred extends GameRunnerEvent {
  const RunnerErrorOccurred({required this.message});

  final String message;
}

/// A log message was emitted by the runner or its underlying engine.
///
/// [prefix] disambiguates the source runner ('IH', 'PL', etc.).
final class RunnerLogEmitted extends GameRunnerEvent {
  const RunnerLogEmitted({
    required this.prefix,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final String prefix;
  final String level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
}

/// A host message was received from an in-house game bridge.
///
/// Only emitted by [GameIHRunnerView]. PL runners never emit this event.
final class RunnerHostMessageReceived extends GameRunnerEvent {
  const RunnerHostMessageReceived({required this.hostEvent});

  final GameHostEvent hostEvent;
}
