import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:orientation_guard/orientation_guard.dart';

/// Core Game Status
enum MockGameStatus {
  initial,
  settingUp,
  connecting,
  loadingAssets,
  playing,
  reconnecting,
  error,
  exiting,
}

/// Abstract event for 1-way UI notifications
abstract class GameEvent {}

class GameExitEvent extends GameEvent {}

class GameMessageEvent extends GameEvent {
  final String message;
  GameMessageEvent(this.message);
}

/// Controller/View-Model Layer for GameScreen.
///
/// Bridges the logic with Flutter's UI using `ChangeNotifier`
/// and manages orientation guard interactions.
class MockGameNotifier extends ChangeNotifier {
  MockGameNotifier({
    required OrientationController controller,
    required OrientationPolicy? previousPolicy,
  }) : _controller = controller,
       _previousPolicy = previousPolicy;

  final OrientationController _controller;
  final OrientationPolicy? _previousPolicy;

  final _eventsController = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get events => _eventsController.stream;

  // ---- State ----
  MockGameStatus _status = MockGameStatus.initial;
  MockGameStatus get state => _status;

  double _progress = 0.0;
  double get progress => _progress;

  bool _simulateFailure = false;
  bool get simulateFailure => _simulateFailure;

  Timer? _sequenceTimer;
  bool _isDisposed = false;

  void _updateStatus(MockGameStatus newStatus) {
    if (_isDisposed) return;
    _status = newStatus;
    notifyListeners();
  }

  void _updateProgress(double value) {
    if (_isDisposed) return;
    _progress = value;
    notifyListeners();
  }

  // ---- Public API ----

  /// Runs the initialization sequence:
  /// 1. Set state to settingUp (shows setting up view)
  /// 2. Apply target orientation policy
  /// 3. Start game loading process
  Future<void> initialize(OrientationPolicy targetPolicy) async {
    if (_isDisposed) return;
    _updateStatus(MockGameStatus.settingUp);

    // 1. Wait a bit for the page transition to finish before rotating
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isDisposed) return;

    // 2. Apply the orientation policy for the game
    await _controller.apply(targetPolicy);
    if (_isDisposed) return;

    // 3. Start the actual game process logic
    await startLoading();
  }

  /// Starts the loading sequence.
  Future<void> startLoading() async {
    if (_isDisposed) return;
    _sequenceTimer?.cancel();
    _updateProgress(0.0);

    if (_status != MockGameStatus.settingUp) {
      _updateStatus(MockGameStatus.settingUp);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (_status == MockGameStatus.exiting || _isDisposed) return;

    _updateStatus(MockGameStatus.connecting);
    await Future.delayed(const Duration(milliseconds: 600));
    if (_status == MockGameStatus.exiting || _isDisposed) return;

    _updateStatus(MockGameStatus.loadingAssets);

    // Simulate loading progress
    for (int i = 1; i <= 10; i++) {
      if (_status == MockGameStatus.exiting || _isDisposed) return;
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isDisposed) return;
      _updateProgress(i * 0.1);
    }

    if (_simulateFailure) {
      _updateStatus(MockGameStatus.error);
    } else {
      _updateStatus(MockGameStatus.playing);
    }
  }

  /// Retries loading when in error state.
  void retry() {
    if (_status != MockGameStatus.error || _isDisposed) return;
    startLoading();
  }

  /// Initiates the smooth exit sequence:
  /// 1. Restore previous orientation policy (Rotate)
  /// 2. Tell the process to begin its exit flow
  Future<void> requestExit() async {
    if (_status == MockGameStatus.exiting || _isDisposed) return;

    // Immediately mark as exiting to prevent concurrent calls
    _updateStatus(MockGameStatus.exiting);

    // 1. Restore previous orientation
    await _controller.apply(_previousPolicy ?? OrientationPolicy.portrait);
    if (_isDisposed) return;

    // 2. Tell the process to exit
    _sequenceTimer?.cancel();

    // Process cleanup logic delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isDisposed) return;

    _eventsController.add(GameExitEvent());
  }

  /// Toggles simulated failure mode for demo purposes.
  void toggleFailMode() {
    if (_isDisposed) return;
    _simulateFailure = !_simulateFailure;
    if (_simulateFailure && _status == MockGameStatus.playing) {
      _updateStatus(MockGameStatus.error);
    } else if (!_simulateFailure && _status == MockGameStatus.error) {
      retry();
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sequenceTimer?.cancel();
    _eventsController.close();
    super.dispose();
  }
}
