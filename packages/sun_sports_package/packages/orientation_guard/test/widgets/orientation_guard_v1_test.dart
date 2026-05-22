import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/orientation_guard.dart';

class MockOrientationController extends ChangeNotifier implements OrientationController {
  OrientationPolicy? lastAppliedPolicy;
  OrientationPolicy? lastRestoredPolicy;
  int applyCount = 0;
  int restoreCount = 0;
  bool matched = true;
  bool _isApplying = false;

  @override
  bool get isApplying => _isApplying;

  void setApplying(bool value) {
    _isApplying = value;
    notifyListeners();
  }

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    _isApplying = true;
    notifyListeners();
    lastAppliedPolicy = policy;
    applyCount++;
    _isApplying = false;
    notifyListeners();
    return OrientationApplyResult.matched(policy);
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    _isApplying = true;
    notifyListeners();
    lastRestoredPolicy = previousPolicy;
    lastAppliedPolicy = previousPolicy; // Update activePolicy on restore
    restoreCount++;
    _isApplying = false;
    notifyListeners();
    return OrientationApplyResult.matched(previousPolicy ?? OrientationPolicy.adaptive);
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    // If explicit matched flag is set, return it (for simple tests)
    if (matched == false) return false;

    // For smarter tests:
    if (policy == OrientationPolicy.portrait) {
      return currentOrientation == Orientation.portrait;
    }
    if (policy == OrientationPolicy.landscape) {
      return currentOrientation == Orientation.landscape;
    }
    return true;
  }

  @override
  OrientationPolicy? get activePolicy => lastAppliedPolicy;
}

void main() {
  late MockOrientationController controller;

  setUp(() {
    controller = MockOrientationController();
  });

  Widget buildTestApp(Widget child, {OrientationController? providedController}) {
    return MaterialApp(
      home: OrientationScope(
        controller: providedController ?? controller,
        child: child,
      ),
    );
  }

  group('OrientationGuard V1', () {
    testWidgets('applies policy on mount', (tester) async {
      final policy = OrientationPolicy.portrait;

      await tester.pumpWidget(
        buildTestApp(
          OrientationGuard(
            policy: policy,
            child: const Text('Child'),
          ),
        ),
      );

      // Need to pump again because apply is in addPostFrameCallback
      await tester.pump();

      expect(controller.applyCount, 1);
      expect(controller.lastAppliedPolicy, policy);
    });

    testWidgets('restores policy on dispose', (tester) async {
      final policy = OrientationPolicy.portrait;

      await tester.pumpWidget(
        MaterialApp(
          home: OrientationScope(
            controller: controller,
            currentPolicy: OrientationPolicy.adaptive,
            child: OrientationGuard(
              policy: policy,
              child: const Text('Child'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Dispose by pumping a different widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Gone'))));

      expect(controller.restoreCount, 1);
      expect(controller.lastRestoredPolicy, OrientationPolicy.adaptive);
    });

    testWidgets('shows child when matched', (tester) async {
      controller.matched = true;

      await tester.pumpWidget(
        buildTestApp(
          OrientationGuard(
            policy: OrientationPolicy.portrait,
            child: const Text('Visible Child'),
          ),
        ),
      );

      expect(find.text('Visible Child'), findsOneWidget);
      expect(find.byType(OrientationMismatchView), findsNothing);
    });

    testWidgets('shows mismatch view when mismatched and blockOnMismatch is true', (tester) async {
      controller.matched = false;

      await tester.pumpWidget(
        buildTestApp(
          OrientationGuard(
            policy: OrientationPolicy.landscape,
            blockOnMismatch: true,
            child: const Text('Hidden Child'),
          ),
        ),
      );
      await tester.pump(); // First post-frame: apply() called
      await tester.pump(); // Second post-frame: _isApplying = false

      expect(find.text('Hidden Child'), findsNothing);
      expect(find.byType(OrientationMismatchView), findsOneWidget);
    });

    testWidgets('uses custom mismatchBuilder when provided', (tester) async {
      controller.matched = false;

      await tester.pumpWidget(
        buildTestApp(
          OrientationGuard(
            policy: OrientationPolicy.landscape,
            blockOnMismatch: true,
            mismatchBuilder: (context) => const Text('Custom Mismatch'),
            child: const Text('Hidden Child'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Hidden Child'), findsNothing);
      expect(find.text('Custom Mismatch'), findsOneWidget);
    });

    testWidgets('does not block when blockOnMismatch is false even if mismatched', (tester) async {
      controller.matched = false;

      await tester.pumpWidget(
        buildTestApp(
          OrientationGuard(
            policy: OrientationPolicy.landscape,
            blockOnMismatch: false,
            child: const Text('Visible Child'),
          ),
        ),
      );

      expect(find.text('Visible Child'), findsOneWidget);
      expect(find.byType(OrientationMismatchView), findsNothing);
    });

    testWidgets('parent guard does not block if overridden by child guard', (tester) async {
      // Setup: Device is in Landscape
      // Root Guard wants Portrait (mismatched)
      // Child Guard wants Landscape (matched, and is active)

      controller.lastAppliedPolicy = OrientationPolicy.landscape;

      await tester.pumpWidget(
        MaterialApp(
          home: OrientationScope(
            controller: controller,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(800, 600)),
              child: OrientationGuard(
                policy: OrientationPolicy.portrait,
                blockOnMismatch: true,
                child: OrientationGuard(
                  policy: OrientationPolicy.landscape,
                  child: const Text('Game Content'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Root Guard sees mismatch (Device Landscape vs Policy Portrait)
      // BUT controller.activePolicy is Landscape, so Root Guard is overridden.
      expect(find.text('Game Content'), findsOneWidget);
      expect(find.byType(OrientationMismatchView), findsNothing);
    });
  });
}
