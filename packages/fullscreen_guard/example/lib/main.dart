import 'package:flutter/material.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the app with PlatformUiGuard to manage initial system UI state
    return PlatformUiGuard(
      initialConfig: const PlatformUiConfig.systemDefault(),
      child: Builder(
        builder: (context) {
          return FullscreenGuard(
            platformUiController: PlatformUiGuard.of(context),
            child: MaterialApp(
              title: 'Fullscreen Guard Example',
              theme: ThemeData.dark(),
              home: const GameSimulationScreen(),
            ),
          );
        },
      ),
    );
  }
}

class GameSimulationScreen extends StatefulWidget {
  const GameSimulationScreen({super.key});

  @override
  State<GameSimulationScreen> createState() => _GameSimulationScreenState();
}

class _GameSimulationScreenState extends State<GameSimulationScreen> {
  FullscreenGuardController? _guard;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guard == null) {
      _guard = FullscreenGuard.of(context);
      // Use addPostFrameCallback to avoid calling setState during build phase,
      // as clearing the guard notifies the parent FullscreenGuard widget.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _guard?.clear();
      });
    }
  }

  @override
  void dispose() {
    // Cleanup when leaving the screen
    _guard?.clear();
    super.dispose();
  }

  void _enterImmersiveGame() {
    _guard?.request(
      const FullscreenGateRequest(
        tag: 'game_player',
        requiresGestureOnIosSafari: true,
      ),
    );
  }

  void _exitImmersiveGame() {
    _guard?.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isFullscreen = _guard?.isFullscreen.value ?? false;

    return Scaffold(
      appBar: isFullscreen ? null : AppBar(title: const Text('Game Lobby')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isFullscreen) ...[
              const Text('You are in the lobby.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enterImmersiveGame,
                child: const Text('Start Game (Enter Immersive Mode)'),
              ),
            ] else ...[
              const Text(
                '🎮 GAME RUNNING FULLSCREEN 🎮',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _exitImmersiveGame,
                child: const Text('Exit Game'),
              ),
            ],
            const SizedBox(height: 40),
            Text('Current status: ${isFullscreen ? "Immersive" : "Normal"}'),
          ],
        ),
      ),
    );
  }
}
