import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';

import 'mock_game_notifier.dart';

class GameScreen extends StatefulWidget {
  final OrientationPolicy gamePolicy;
  final String gameName;
  final bool autoStart;

  const GameScreen({
    super.key,
    required this.gamePolicy,
    required this.gameName,
    this.autoStart = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final MockGameNotifier _notifier;
  late final StreamSubscription<GameEvent> _eventSub;
  bool _isInitialized = false;
  final ValueNotifier<bool> _isMismatched = ValueNotifier<bool>(false);
  bool _lastRawMismatch = false;
  Timer? _mismatchTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _notifier = MockGameNotifier(
        controller: OrientationScope.of(context),
        previousPolicy: OrientationScope.maybePolicyOf(context),
      );
      _notifier.addListener(_syncMismatchState);
      _eventSub = _notifier.events.listen(_onGameEvent);
      _isInitialized = true;

      // Case 2: Auto Start
      if (widget.autoStart) {
        // We use a small delay or scheduleTask to ensure the build finishes
        // and the AnimatedSwitcher is ready to catch the state change.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _notifier.initialize(widget.gamePolicy);
        });
      }
    }
  }

  void _onGameEvent(GameEvent event) {
    if (event is GameExitEvent && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleMismatch(bool mismatched) {
    _lastRawMismatch = mismatched;
    _syncMismatchState();
  }

  void _syncMismatchState() {
    _mismatchTimer?.cancel();

    if (_lastRawMismatch) {
      // Don't show mismatch during sensitive transitions
      if (_notifier.state == MockGameStatus.exiting ||
          _notifier.state == MockGameStatus.settingUp ||
          _notifier.state == MockGameStatus.connecting ||
          _notifier.state == MockGameStatus.loadingAssets ||
          _notifier.state == MockGameStatus.initial) {
        _isMismatched.value = false;
        return;
      }

      // If we are already showing it, don't debounce again
      if (_isMismatched.value) return;

      // 1s debounce to prevent flicker during normal rotations
      _mismatchTimer = Timer(const Duration(seconds: 1), () {
        _isMismatched.value = true;
      });
    } else {
      _isMismatched.value = false;
    }
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    _isMismatched.dispose();
    _eventSub.cancel();
    _notifier.removeListener(_syncMismatchState);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PopScope always prevents system back to ensure our custom exit sequence runs
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _notifier.requestExit();
      },
      child: OrientationGuard(
        policy: widget.gamePolicy,
        blockOnMismatch: false, // We handle mismatch UI manually
        onMismatchChanged: _handleMismatch,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Main Content Layer (Reactive to Notifier state)
          ListenableBuilder(
            listenable: _notifier,
            builder: (context, _) {
              final state = _notifier.state;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: switch (state) {
                  MockGameStatus.initial => _GameInitialView(
                    key: const ValueKey('initial'),
                    onStart: () => _notifier.initialize(widget.gamePolicy),
                  ),
                  MockGameStatus.settingUp => const _GameBrandLoadingView(
                    key: ValueKey('game_loading'),
                    title: 'Setting Up',
                    subtitle: 'Configuring game environment...',
                  ),
                  MockGameStatus.connecting => const _GameBrandLoadingView(
                    key: ValueKey('game_loading'),
                    title: 'Connecting',
                    subtitle: 'Establishing secure connection...',
                  ),
                  MockGameStatus.loadingAssets => _GameBrandLoadingView(
                    key: const ValueKey('game_loading'),
                    title: 'Loading Assets',
                    subtitle: 'Downloading game resources...',
                    progress: _notifier.progress,
                  ),
                  MockGameStatus.playing => _GamePlayView(
                    key: const ValueKey('playing'),
                    notifier: _notifier,
                    gameName: widget.gameName,
                  ),
                  MockGameStatus.reconnecting => const _GameBrandLoadingView(
                    key: ValueKey('game_loading'),
                    title: 'Reconnecting',
                    subtitle: 'Connection lost, trying again...',
                  ),
                  MockGameStatus.error => _GameErrorView(
                    key: const ValueKey('error'),
                    notifier: _notifier,
                  ),
                  MockGameStatus.exiting => const _GameBrandLoadingView(
                    key: ValueKey('game_loading'),
                    title: 'Exiting',
                    subtitle: 'Restoring system settings...',
                  ),
                },
              );
            },
          ),

          // 2. Mismatch Overlay Layer
          ValueListenableBuilder<bool>(
            valueListenable: _isMismatched,
            builder: (context, isMismatched, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isMismatched
                    ? Material(
                        key: const ValueKey('mismatch-overlay'),
                        color: Colors.black87,
                        child: OrientationMismatchView(
                          policy: widget.gamePolicy,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Sub-widgets (Internal) ---

// Removed _SmartMismatchBuilder as logic moved to MockGameNotifier

/// Unified, branded loading screen for all game states (entry, exit, mismatch).
class _GameBrandLoadingView extends StatefulWidget {
  final String title;
  final String subtitle;
  final double? progress;

  const _GameBrandLoadingView({
    super.key,
    required this.title,
    required this.subtitle,
    this.progress,
  });

  @override
  State<_GameBrandLoadingView> createState() => _GameBrandLoadingViewState();
}

class _GameBrandLoadingViewState extends State<_GameBrandLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use Material here to ensure Text has proper style context (no yellow underline)
    // and provide a consistent background for the gradient.
    return Material(
      color: Colors.black,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Branded Logo with smooth Rotation
              // RepaintBoundary isolates this animation from the rest of the layout during rotation
              RepaintBoundary(
                child: RotationTransition(
                  turns: _controller,
                  child: const Icon(
                    Icons.blur_on_rounded,
                    size: 80,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Themed Linear Progress (feels more premium and stable than circular during rotation)
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    color: Colors.amber,
                    backgroundColor: Colors.white10,
                    minHeight: 2,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Primary Text
              Text(
                widget.title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Text
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamePlayView extends StatelessWidget {
  final MockGameNotifier notifier;
  final String gameName;

  const _GamePlayView({
    super.key,
    required this.notifier,
    required this.gameName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videogame_asset, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            gameName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Demo controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: notifier.simulateFailure
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notifier.simulateFailure
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : Colors.white10,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  notifier.simulateFailure
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  size: 16,
                  color: notifier.simulateFailure
                      ? Colors.redAccent
                      : Colors.greenAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Simulate Failure:',
                  style: TextStyle(
                    color: notifier.simulateFailure
                        ? Colors.redAccent
                        : Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: notifier.simulateFailure,
                  onChanged: (_) => notifier.toggleFailMode(),
                  activeThumbColor: Colors.redAccent,
                  activeTrackColor: Colors.red.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => notifier.requestExit(),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Exit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => notifier.startLoading(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameErrorView extends StatelessWidget {
  final MockGameNotifier notifier;

  const _GameErrorView({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Failed to load game',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (notifier.simulateFailure)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '(Simulate Failure is ACTIVE)',
                style: TextStyle(
                  color: Colors.redAccent.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 32),

          // Allow toggling it off directly from error view
          OutlinedButton(
            onPressed: () => notifier.toggleFailMode(),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text('Disable Failure Mode'),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => notifier.requestExit(),
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => notifier.retry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _ExitOverlay was removed and unified into _GameBrandLoadingView.

class _GameInitialView extends StatelessWidget {
  const _GameInitialView({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            'Ready to Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'TAP TO START',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
