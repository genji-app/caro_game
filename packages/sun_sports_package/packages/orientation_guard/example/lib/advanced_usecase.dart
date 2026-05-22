import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  OrientationPolicy _currentPolicy = OrientationPolicy.portrait;
  OrientationPolicy? _previousPolicy;
  OrientationController? _controller;
  bool _captured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture the policy and controller from the previous screen
    if (!_captured) {
      _previousPolicy = OrientationScope.maybePolicyOf(context);
      _controller = OrientationScope.of(context);
      _captured = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // Manual application if not using OrientationGuard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyCurrentPolicy();
    });
  }

  void _applyCurrentPolicy() {
    if (_controller == null) return;

    // Manual check to avoid jitter if already in that policy
    // Although PlatformOrientationController does this, it's good practice
    // to avoid triggering logic/rebuilds if nothing changed.
    _controller!.apply(_currentPolicy);
  }

  @override
  void dispose() {
    // Manually restore the previous policy when leaving
    // We use the stored controller because context might not be valid here
    if (_controller != null && _previousPolicy != null) {
      _controller!.apply(_previousPolicy!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: We are NOT using OrientationGuard here to demonstrate manual control
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This screen uses manual controller calls,\nNOT OrientationGuard.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Text('Active Policy: ${_currentPolicy.debugLabel}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => _currentPolicy = OrientationPolicy.portrait);
                    _applyCurrentPolicy();
                  },
                  child: const Text('To Portrait'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(
                      () => _currentPolicy = OrientationPolicy.landscape,
                    );
                    _applyCurrentPolicy();
                  },
                  child: const Text('To Landscape'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Notice: We are manually restoring orientation in dispose().\n'
                'OrientationGuard does this automatically for you!',
                style: TextStyle(color: Colors.orange, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomMismatchScreen extends StatelessWidget {
  const CustomMismatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationGuard(
      policy: OrientationPolicy.landscape,
      mismatchBuilder: (context) => Scaffold(
        backgroundColor: Colors.red.shade900,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'CUSTOM MISMATCH UI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please rotate to Landscape to see the game!',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Custom Mismatch Game')),
        body: const Center(child: Text('You are in Landscape!')),
      ),
    );
  }
}
