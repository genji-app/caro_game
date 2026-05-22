import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';

import 'advanced_usecase.dart';
import 'basic_usecase.dart';
import 'game/game_page_route.dart';
import 'game/game_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Orientation Guard Example',
      theme: ThemeData.dark(),
      // Moving the Guard inside MaterialApp ensures it has access to
      // the correct MediaQuery and Theme contexts.
      builder: (context, child) => OrientationScope.root(
        blockOnMismatch: false,
        config: const OrientationGuardConfig(
          forceEnforcementOnDesktopWeb: true,
        ),
        child: child!,
      ),
      home: const HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lock Home Screen to Portrait
    return Scaffold(
      appBar: AppBar(title: const Text('Orientation Guard V1')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader(title: 'Game Simulation'),
              _ExampleButton(
                title: 'Play Game (Auto Start)',
                subtitle: 'Bypasses the "Tap to Start" screen',
                icon: Icons.bolt,
                color: Colors.amber,
                onTap: () => _navigateTo(
                  context,
                  const GameScreen(
                    gamePolicy: OrientationPolicy.landscape,
                    gameName: 'Instant Action Game',
                    autoStart: true,
                  ),
                ),
              ),

              _ExampleButton(
                title: 'Play Portrait Game',
                subtitle: 'Simulates loading -> portrait',
                icon: Icons.portrait,
                onTap: () => _navigateTo(
                  context,
                  const GameScreen(
                    gamePolicy: OrientationPolicy.portrait,
                    gameName: 'Simple Portrait Game',
                    autoStart: true,
                  ),
                ),
              ),
              _ExampleButton(
                title: 'Play Adaptive Game',
                subtitle: 'Supports both orientations',
                icon: Icons.screen_rotation,
                onTap: () => _navigateTo(
                  context,
                  const GameScreen(
                    gamePolicy: OrientationPolicy.adaptive,
                    gameName: 'Adaptive Game (Both)',
                    autoStart: true,
                  ),
                ),
              ),
              _ExampleButton(
                title: 'Play Landscape Game',
                subtitle: 'Simulates loading -> landscape',
                icon: Icons.landscape,
                onTap: () => _navigateTo(
                  context,
                  const GameScreen(
                    gamePolicy: OrientationPolicy.landscape,
                    gameName: 'Super Landscape Game',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Policies'),
              _ExampleButton(
                title: 'Adaptive Screen',
                subtitle: 'Supports both orientations',
                icon: Icons.screen_rotation,
                color: Colors.blue,
                onTap: () => _navigateTo(context, const AdaptiveScreen()),
              ),
              _ExampleButton(
                title: 'Strict Landscape',
                subtitle: 'Forces landscape mode',
                icon: Icons.crop_landscape,
                onTap: () => _navigateTo(context, const LandscapeScreen()),
              ),
              _ExampleButton(
                title: 'Strict Portrait',
                subtitle: 'Forces portrait mode',
                icon: Icons.crop_portrait,
                onTap: () => _navigateTo(context, const PortraitScreen()),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Advanced'),
              _ExampleButton(
                title: 'Custom Mismatch UI',
                subtitle: 'Override the blocking view',
                icon: Icons.style,
                onTap: () => _navigateTo(context, const CustomMismatchScreen()),
              ),
              _ExampleButton(
                title: 'Manual Control',
                subtitle: 'Lifecycle vs Declarative',
                icon: Icons.settings_remote,
                color: Colors.orange,
                onTap: () => _navigateTo(context, const ManualControlScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, GamePageRoute(child: screen));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ExampleButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.greenAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: onTap,
      ),
    );
  }
}
