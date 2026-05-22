import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';

class PortraitScreen extends StatelessWidget {
  const PortraitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationGuard(
      policy: OrientationPolicy.portrait,
      child: Scaffold(
        appBar: AppBar(title: const Text('Portrait Screen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('This screen should be in Portrait.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LandscapeScreen extends StatelessWidget {
  const LandscapeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationGuard(
      policy: OrientationPolicy.landscape,
      child: Scaffold(
        appBar: AppBar(title: const Text('Landscape Screen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('This screen should be in Landscape.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdaptiveScreen extends StatelessWidget {
  const AdaptiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationGuard(
      policy: OrientationPolicy.adaptive,
      child: Scaffold(
        appBar: AppBar(title: const Text('Adaptive Screen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.screen_rotation, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'This screen is ADAPTIVE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'It supports both Portrait and Landscape. Try rotating your device/simulator!',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final orientation = MediaQuery.of(context).orientation;
                  return Text(
                    'Current Mode: ${orientation.name.toUpperCase()}',
                    style: TextStyle(
                      color: orientation == Orientation.portrait
                          ? Colors.orange
                          : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
